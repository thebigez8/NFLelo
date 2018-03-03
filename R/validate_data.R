library(tidyverse)
library(elo)

validate_data <- function(fp)
{
  dat <- read_csv(fp, col_names = TRUE, col_types = cols())

  stopifnot(dat$home.score == dat$h.defense + dat$h.offense)
  stopifnot(dat$visitor.score == dat$v.defense + dat$v.offense)
  stopifnot(dat$margin == abs(dat$home.score - dat$visitor.score))
  stopifnot(dat$home.wins == score(dat$home.score, dat$visitor.score))
  invisible(dat)
}

validate_data("data/nfl_results_1920-1969.csv")
validate_data("data/nfl_results_1970-2001.csv")
