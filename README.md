
# NFL Elo Repository

This repo contains data on all NFL games from 1920 to present. Most of the data is from
[pro-football-reference.com](https://www.pro-football-reference.com) in conjunction with
[fivethirtyeight](https://github.com/fivethirtyeight/data/tree/master/nfl-elo).
Details on the files are below:

- `data/nfl_results_1920-1969.csv` contains data on NFL games pre-merger (era 1).
    
- `data/nfl_results_1970-2001.csv` contains data on NFL games post-merger but pre-today's NFL (era 2).

- `data/nfl_results_2002-today.csv` contains data on NFL games from the modern (post-expansion) NFL (era 3).

Note that this has [one game](https://www.pro-football-reference.com/boxscores/192912140fyj.htm)
not reported by fivethirtyeight. In addition, several dates of games have been changed.


Each file looks something like this:

- `era` (integer): The era of football as defined above.

- `date` (Date): The date of the game.

- `season` (integer): The season (year) of the game.

- `week` (integer): The week of the season in which the game was played.

- `neutral` (integer): An indicator variable for whether the game was played at a netural site
  (used for home-field advantage calculations).
  
- `playoff` (integer): An indicator variable for whether the game was a playoff game.

- `visitor` (character): The visiting team name.

- `visitor.abbr` (character): An abbreviation of the visiting team name, but consistent for when teams
  move to a new city.
  
- `home` (character): The home team name.

- `home.abbr` (character): The home-team version of `visitor.abbr`.

- `visitor.score` (integer): The score of the visiting team.

- `v.offense` (integer): An approximation of how many points the offense scored.
  In general, this corresponds to plays of the following types:
  "rush", "pass", "offensive fumble recovery", "on a lateral", "field goal".
  
- `v.defense` (integer): An approximation of how many points the defense/special teams scored.
  In general, this correponds to all other plays.
  
- `home.score` (integer): The score of the home team.

- `h.offense` (integer): The home-team version of `v.offense`.

- `h.defense` (integer): The home-team version of `v.defense`.

- `margin` (integer): `abs(home.score - visitor.score)`.

- `home.wins` (numeric): 1 if the home team won, 0.5 if the game ended in a tie, and 0 else.

- `visitor.elo.538` (numeric): The visiting team's Elo score as produced by fivethirtyeight.

- `home.elo.538` (numeric): The home team's Elo score as produced by fivethirtyeight.

- `home.prob.538` (numeric): The probability of the home team winning, as predicted by fivethirtyeight.
