# fetch_feeds.R
# Pulls BBC RSS feeds and writes feed.json for the teletext page.
# The page looks for feed.json next to teletext.html and falls back to its demo feed if it is missing.
#
# Not run here (no R in my sandbox), so check the tidyRSS column names on your first run:
#   names(tidyRSS::tidyfeed("https://feeds.bbci.co.uk/news/rss.xml"))
#
# Before this goes public, read the BBC's current terms for feed reuse.
# Keep the "BBC News" attribution and do not use BBC logos.

library(tidyRSS)
library(dplyr)
library(purrr)
library(jsonlite)

feeds <- list(
  top      = "https://feeds.bbci.co.uk/news/rss.xml",
  world    = "https://feeds.bbci.co.uk/news/world/rss.xml",
  uk       = "https://feeds.bbci.co.uk/news/uk/rss.xml",
  business = "https://feeds.bbci.co.uk/news/business/rss.xml",
  sport    = "https://feeds.bbci.co.uk/sport/rss.xml"
)

pull <- function(url, n = 8) {
  tidyfeed(url) |>
    slice_head(n = n) |>
    transmute(
      title   = item_title,
      desc    = item_description,
      pubDate = format(item_pub_date, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
      link    = item_link
    )
}

sections <- feeds |>
  map(\(u) tryCatch(pull(u), error = \(e) NULL)) |>
  compact()

out <- list(
  source    = "BBC News",
  fetchedAt = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
  sections  = sections
)

write_json(out, "feed.json", auto_unbox = TRUE, pretty = TRUE, null = "null")
message("Wrote feed.json with ", length(sections), " sections")
