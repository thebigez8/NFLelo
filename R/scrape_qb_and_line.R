
library(tidyverse)
library(stringr)

innards <- function(x) str_replace_all(x, "<.*?>", "")

my_subset <- function(x, what)
{
  start <- which(str_detect(x, paste0('"', what, '"')))
  if(length(start) == 0) return("")
  start <- min(start)
  end <- which(str_detect(x, "</table>") & seq_along(x) > start)
  if(length(end) == 0) return("")
  end <- min(end)
  x[start:end]
}

get_qb <- function(str, what)
{
  qb <- str %>%
    my_subset(what) %>%
    str_replace_all("\\t", "") %>%
    paste0(collapse = "") %>%
    str_extract_all("<tr.*?</tr>") %>%
    "[["(1) %>%
    str_subset("QB") %>%
    str_extract("<a href=.*>.*?</a>") %>%
    innards()
  qb
}

scrape_qb_and_line <- function(pg)
{
  print(pg)
  pg2 <- readLines(pg)

  gi <- my_subset(pg2, "game_info")

  vegas.line <- gi %>%
    str_subset("Vegas Line") %>%
    str_extract("<td.*</td>") %>%
    innards()

  overunder <- gi %>%
    str_subset("Over/Under") %>%
    str_extract("<td.*</td>") %>%
    innards() %>%
    str_extract("[\\d\\.]+")

  roof <- gi %>%
    str_subset("Roof") %>%
    str_extract("<td.*</td>") %>%
    innards()

  list(vegas.line = vegas.line,
       overunder = overunder,
       roof = roof,
       home.qb = get_qb(pg2, "home_starters"),
       vis.qb = get_qb(pg2, "vis_starters"),
       pg = pg)
}
