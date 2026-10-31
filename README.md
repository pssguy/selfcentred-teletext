# Teletext TV

A 1980s-style teletext set rebuilt for the web, with live news headlines, invented retro adverts and an art lab.

**Live site:** https://teletext.selfcentred.me
Part of [selfcentred.me](https://selfcentred.me).

Inspired by the BBC's Ceefax. This is an independent hobby project, not affiliated with the BBC, CBC or North Shore News.

## What it does

- Draws a 40 x 24 teletext screen using the real rules: control codes that take up a cell, colour changes along a row, double-height text, flashing text and chunky block graphics.
- Two sets, switched with the UK and CAN buttons on the TV:
  - **UK:** BBC News headlines, with a clock in UK time.
  - **Canada:** CBC News headlines, plus local stories from the North Shore News, with a clock in Pacific time.
- Type a three-digit page number or use the coloured keys, as on a real remote. Pages with subpages cycle on their own.
- Each story page gets a small block-graphic icon chosen from the words in the headline.
- A new set of invented adverts is generated every day on page 700.
- An art lab on page 800 turns any image you choose into a teletext page. The image stays in your browser and is not uploaded anywhere.

Pages marked (s) on the UK index are invented samples, not real data.

## Pages

| Set | Pages |
| --- | --- |
| UK | 100 index, 101 top stories, 120 world, 140 UK, 200 business, 300 sport, 700 adverts, 800 art lab, 888 subtitles, plus invented samples: 390 and 391 football, 400 weather, 500 TV |
| Canada | 100 index, 101 top stories, 120 world, 140 Canada, 160 B.C., 180 local, 700 adverts, 800 art lab, 888 subtitles |

Story pages follow their section index, so 102 onwards are the top stories.

## How it works

```
scripts/fetch_feeds.R          reads the RSS feeds and writes _site/feed.json
.github/workflows/feed.yml     runs the script every 3 hours; commits only if the headlines changed
_site/index.html               the whole TV, in one file, with no build step
_site/feed.json                the latest headlines (written by the script)
wrangler.jsonc                 tells Cloudflare to serve _site as static assets
```

Cloudflare redeploys the site whenever the repo is pushed to, including the feed updates. If `feed.json` is missing, the page falls back to an invented demo feed, labelled as such on page 100.

## Running it locally

Needs R with the `tidyRSS`, `dplyr`, `purrr` and `jsonlite` packages.

```r
setwd("_site")
source("../scripts/fetch_feeds.R")   # writes feed.json
servr::httd(".")                     # serve the folder; opening the file directly will not load feed.json
```

## Sources and credits

- Headlines and summaries come from BBC News, CBC News and the North Shore News, and are credited on every page. They belong to those publishers. This is a free, non-commercial site; check each publisher's terms before reusing the feeds elsewhere.
- Typeface: [Bedstead](https://bjh21.me.uk/bedstead/) by Ben Harris (CC0 and the UK copyright provision for typefaces), cut down to Latin characters and embedded in the page.
- Advert phone numbers are drawn from ranges reserved for fiction (01632 960xxx in the UK, 604 555 01xx in Canada).

## Licence

Code copyright 2026 Andrew Clark. No licence has been chosen yet.
