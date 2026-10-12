# fetch_feeds.R
# Pulls the BBC (UK channel) and CBC (Canada channel) RSS feeds and writes feed.json for the teletext page.
# Run from the _site folder:  setwd("C:/dev/selfcentred-teletext/_site"); source("../scripts/fetch_feeds.R")
#
# If the column names from tidyRSS differ on your machine, check with:
#   names(tidyRSS::tidyfeed("https://feeds.bbci.co.uk/news/rss.xml"))
#
# Before this goes public, read each broadcaster's current terms for feed reuse.
# Keep the "BBC News" / "CBC News" credit and do not use their logos.

# Feed times must be read as UTC, whatever timezone this machine is in.
Sys.setenv(TZ = "UTC")

library(tidyRSS)
library(dplyr)
library(purrr)
library(jsonlite)

uk_feeds <- list(
  top      = "https://feeds.bbci.co.uk/news/rss.xml",
  world    = "https://feeds.bbci.co.uk/news/world/rss.xml",
  uk       = "https://feeds.bbci.co.uk/news/uk/rss.xml",
  business = "https://feeds.bbci.co.uk/news/business/rss.xml",
  sport    = "https://feeds.bbci.co.uk/sport/rss.xml"
)

ca_feeds <- list(
  top    = "https://www.cbc.ca/webfeed/rss/rss-topstories",
  world  = "https://www.cbc.ca/webfeed/rss/rss-world",
  canada = "https://www.cbc.ca/webfeed/rss/rss-canada",
  bc     = "https://www.cbc.ca/webfeed/rss/rss-canada-britishcolumbia"
  # local = "https://..."   # add a local feed here once you have one (page 180)
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

channel <- function(feeds, source) {
  sections <- feeds |>
    map(\(u) tryCatch(pull(u), error = \(e) NULL)) |>
    compact()
  if (!length(sections)) return(NULL)
  list(
    source    = source,
    fetchedAt = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
    sections  = sections
  )
}

out <- list(
  channels = compact(list(
    uk = channel(uk_feeds, "BBC News"),
    ca = channel(ca_feeds, "CBC News")
  ))
)

write_json(out, "feed.json", auto_unbox = TRUE, pretty = TRUE, null = "null")
message("Wrote feed.json with channels: ", paste(names(out$channels), collapse = ", "))
