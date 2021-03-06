library(tidyverse)
library(elo)
source("R/abbreviations.R")

validate_data <- function(fp, qb.and.line = FALSE)
{
  dat <- read_csv(fp, col_names = TRUE, col_types = cols())

  stopifnot(dat$home.score == dat$h.defense + dat$h.offense)
  stopifnot(dat$visitor.score == dat$v.defense + dat$v.offense)
  stopifnot(dat$margin == abs(dat$home.score - dat$visitor.score))
  stopifnot(dat$home.wins == score(dat$home.score, dat$visitor.score))

  stopifnot(sort(dat$date) == dat$date)

  if(!all(idx <- purrr::map2_lgl(dat$home, dat$home.abbr, ~ .x %in% ABBRS[[.y]])))
  {
    print(select(filter(dat, !idx), pg, home, home.abbr))
    stop("Mismatch between names of teams and abbreviations.")
  }

  if(!all(idx <- purrr::map2_lgl(dat$visitor, dat$visitor.abbr, ~ .x %in% ABBRS[[.y]])))
  {
    print(select(filter(dat, !idx), pg, visitor, visitor.abbr))
    stop("Mismatch between names of teams and abbreviations.")
  }

  if(qb.and.line)
  {
    stopifnot(!anyNA(dat$visitor.qb))
    stopifnot(!anyNA(dat$home.qb))
    stopifnot(!anyNA(dat$home.line))
    stopifnot(!anyNA(dat$overunder))
    stopifnot(!anyNA(dat$roof))
  }

  invisible(dat)
}

validate_data("data/nfl_results_1920-1969.csv")
validate_data("data/nfl_results_1970-2001.csv")
validate_data("data/nfl_results_2002-today.csv", qb.and.line = TRUE)
