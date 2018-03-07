
week_to_games <- function(pg)
{
  print(pg)
  pg %>%
    read_html() %>%
    html_nodes(".gamelink a") %>%
    html_attr("href")
}

scrape_scores <- function(pg)
{
  print(pg)

  page <- read_html(pg)
  scoring <- page %>%
    html_nodes("#scoring") %>%
    html_table() %>%
    "[["(1)
  boxscore <- page %>%
    html_nodes(".linescore.stats_table") %>%
    html_table() %>%
    "[["(1)
  list(scoring = scoring, boxscore = boxscore, pg = pg)
}

rm_col <- function(x, cn)
{
  x[[cn]] <- NULL
  x
}

interpret_scoring <- function(lst)
{
  plays <- paste0("rush|pass|(interception|fumble|punt|extra point|kickoff) return|",
                  "field goal|Safety|blocked punt|(offensive |defensive )?fumble recovery|",
                  "(kickoff|punt) recovery|(interception|punt) in end zone|on a lateral")
  lst$scoring %>%
    rm_col("Quarter") %>%
    rm_col("Time") %>%
    mutate(
      type = str_extract(Detail, plays),
      dst = !(type %in% c("rush", "pass", "offensive fumble recovery", "on a lateral", "field goal"))
    )
}



get_offense_defense_scores <- function(df)
{
  vis <- diff(c(0, df[[3]]))
  hom <- diff(c(0, df[[4]]))

  tibble(
    v.offense = sum(vis[!df$dst]),
    v.defense = sum(vis[ df$dst]),
    h.offense = sum(hom[!df$dst]),
    h.defense = sum(hom[ df$dst])
  )
}
