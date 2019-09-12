
library(tidyverse)
library(rvest)

era3 <- "data/nfl_results_2002-today.csv" %>%
  read_csv(col_names = TRUE, col_types = cols(), guess_max = 2000)


results538 <- "https://projects.fivethirtyeight.com/nfl-api/nfl_elo.csv" %>%
  read_csv(col_names = TRUE, col_types = cols(), guess_max = 3000) %>%
  filter(date > max(era3$date)) %>%
  filter(date < Sys.Date())

# results538 %>%
#   mutate(
#     swap = neutral & !(row_number() %in% c(
#       2937,3204,3471,3521,3564,3578,3788,3832,3847,3899,4005,4038,4054,4102,4113,4162,4272,4352,4367,4381
#     )),
#     tmp = team1,
#     team1 = ifelse(swap, team2, tmp),
#     team2 = ifelse(swap, tmp, team2),
#     home.prob.qb.538 = ifelse(swap, qbelo_prob2, qbelo_prob1)
#   ) %>%
#   select(date, team1, team2, home.prob.qb.538) %>%
#   inner_join(x = era3, by = c(date = "date", visitor.abbr = "team2", home.abbr = "team1")) %>%
#   write.csv("data/nfl_results_2002-today.csv", row.names = FALSE)


if(nrow(results538))
{
  source("R/abbreviations.R")
  results.538.clean <- results538 %>%
    rename(home.abbr = "team1", visitor.abbr = "team2", home.elo.538 = "elo1_pre",
           visitor.elo.538 = "elo2_pre", home.prob.538 = "elo_prob1", home.prob.qb.538 = "qbelo_prob1",
           home.score = "score1", visitor.score = "score2") %>%
    select(date, home.abbr, visitor.abbr, home.elo.538, visitor.elo.538, home.prob.538, home.prob.qb.538,
           home.score, visitor.score, season, neutral, playoff) %>%
    mutate(
      playoff = as.integer(!is.na(playoff)),
      week = as.numeric(floor((date - as.Date("1920-08-25"))/7)),
      margin = abs(home.score - visitor.score),
      era = ifelse(season < 1970, 1, ifelse(season < 2002, 2, 3)),
      home.wins = elo::score(home.score, visitor.score),
      home = map_chr(home.abbr, ~ ABBRS[[.x]][1]),
      visitor = map_chr(visitor.abbr, ~ ABBRS[[.x]][1])
    )

  #### fill in the gaps with data from pro-football-reference.com ####
  source("R/scrape_scores.R")
  source("R/scrape_qb_and_line.R")

  pgs <- "https://www.pro-football-reference.com/years/2019/" %>%
    read_html() %>%
    html_nodes("#inner_nav ul div ul li a") %>%
    html_attr("href") %>%
    grep(pattern = "^.*week_[0-9]+\\.htm$", value = TRUE) %>%
    unique() %>%
    paste0("https://www.pro-football-reference.com", .) %>%
    map(week_to_games) %>%
    unique() %>%
    unlist() %>%
    paste0("https://www.pro-football-reference.com", .) %>%
    "["(!(. %in% era3$pg))

  pfr <- tibble(
    pg = pgs,
    date = as.Date(map_chr(pg, str_extract, "\\d+"), format = "%Y%m%d")
  ) %>%
    filter(date < Sys.Date()) %>%
    mutate(
      scores = map(pg, scrape_scores),
      scoring = map(scores, interpret_scoring),
      boxscore = map(scores, "boxscore"),
      visitor = map_chr(boxscore, function(x) x[[2]][1]),
      home = map_chr(boxscore, function(x) x[[2]][2]),
      visitor.score = map_int(boxscore, function(x) x[["Final"]][1]),
      home.score = map_int(boxscore, function(x) x[["Final"]][2]),
      off.def = map(scoring, get_offense_defense_scores)
    ) %>%
    select(-boxscore, scoring) %>%
    unnest(off.def) %>%
    mutate(
      lines.and.qbs = map(pg, scrape_qb_and_line),
      home.qb = map_chr(lines.and.qbs, function(x) x$home.qb[1]),
      visitor.qb  = map_chr(lines.and.qbs, function(x) x$vis.qb[1]),
      vegas.line = map_chr(lines.and.qbs, "vegas.line"),
      vegas.line = stringr::str_replace(vegas.line, "San Francisco", "San Francisco 49ers"),
      line.tm = trimws(stringr::str_extract(vegas.line, "^[^\\d-]+(49ers)?")),
      line = if_else(vegas.line == "Pick", 0.0, as.numeric(stringr::str_extract(vegas.line, "-\\d+\\.\\d$"))),
      home.line = case_when(
        line.tm == "Pick" ~ 0,
        line.tm == home ~ as.numeric(line),
        line.tm == visitor ~ -as.numeric(line),
        TRUE ~ NA_real_
      ),
      overunder = map_chr(lines.and.qbs, "overunder"),
      roof = map_chr(lines.and.qbs, "roof")
    ) %>%
    select(-lines.and.qbs, -line, -line.tm, -scores, -scoring)

  stopifnot(nrow(pfr) == nrow(results.538.clean))

  results.538.clean2 <- results.538.clean %>%
    full_join(pfr, by = c("date", "visitor", "home", "visitor.score", "home.score", "visitor.score")) %>%
    mutate(overunder = as.numeric(overunder))
  stopifnot(nrow(pfr) == nrow(results.538.clean2))

  write.csv(bind_rows(era3, results.538.clean2), "data/nfl_results_2002-today.csv", row.names = FALSE)
}
