#' Players' stats for 2016-2022 NBA season
#'
#' This table contains basic information about NBA players
#'
#' \itemize{
#'   \item name. first and last name of player
#'   \item person_id. unique ID for each player in NBA
#'   \item team_id. unique ID for team 
#'   \item jersey. jersey number
#'   \item pos. player position
#'   \item height_ft. number of feet in height
#'   \item height_in. number of additional inches in height
#'   \item weight_lbs. weight in pounds
#'   \item dob. date of birth
#'   \item years_exp. years of professional basketball experience
#'   \item country. country of origin
#'   \item team_name. full name of team
#'   \item team_abbr. abbreviated name of team
#' }
#'
#' @docType data
#' @keywords datasets
#' @name player_stats
#' @usage data(player_stats)
#' @format A data frame with 508 rows and 13 variables
"player_stats"

#' Shooting stats for 2016-2022 NBA season
#'
#' This table contains shooting data for NBA players from the 2016 to 2022 season
#'
#' \itemize{
#'   \item player. first and last name of player
#'   \item age. player age
#'   \item g. games played
#'   \item mp. minutes played
#'   \item fg. field goal percentage
#'   \item dist. average distance of field goal attempts
#'   \item pct_of_fg_2p. percentage of field goals that are 2 pointers
#'   \item pct_of_fg_0_3. percentage of field goals from 0-3 feet
#'   \item pct_of_fg_3_10. percentage of field goals from 3-10 feet
#'   \item pct_of_fg_10_16. percentage of field goals from 10-16 feet
#'   \item pct_of_fg_16_3p.  percentage of field goals from 16 feet to 13
#'   \item pct_of_fg_3p. percentage of field goals that are 3 pointers
#'   \item fg_pct_2p. 2 point field goal percentage
#'   \item fg_pct_0_3. percentage of field goals from 0-3 feet
#'   \item fg_pct_3_10. percentage of field goals from 3-10 feet
#'   \item fg_pct_10_16. percentage of field goals from 10-16 feet
#'   \item fg_pct_16_3p. percentage of field goals from 16 feet   to 3 pointers
#'   \item year. year of data 
#' }
#'
#' @docType data
#' @keywords datasets
#' @name shooting_data
#' @usage data(shooting_data)
#' @format A data frame with 3578 rows and 17 variables
"shooting_data"


#' Per game stats for 2016-2022 NBA season
#'
#' This table contains per-game data for NBA players from the 2016 to 2022 season
#'
#' \itemize{
#'   \item player. first and last name of player
#'   \item age. player age
#'   \item g. games played
#'   \item gs games started
#'   \item mp. minutes played per game
#'   \item fg. field goal per game
#'   \item fga. field goal attempted per game
#'   \item pct_fg. percentage of field goals 
#'   \item 3p. 3 points field goals per game
#'   \item 3pa. 3 points field goals attempts per game
#'   \item pct_3p. 3 points field goals percentage
#'   \item 2p.  2 points field goals per game
#'   \item 2pa. 2 points field goals attempted per game
#'   \item pct_2p. 2 point field goal percentage
#'   \item pct_efg. Effective field goal percentage
#'   \item ft. free throws per game
#'   \item fta. free throws attempts per game
#'   \item pct_ft. free throws percentage
#'   \item orb. offensive rebounds per game
#'   \item drb. defensive rebounds per game
#'   \item trb. total rebounds per game
#'   \item ast. assists per game
#'   \item stl. steals per game
#'   \item blk. blocks per game
#'   \item tov. Turnovers per game
#'   \item pf. personal fouls per game
#'   \item pts. points per game
#'   \item year. year of data
#' }
#'
#' @docType data
#' @keywords datasets
#' @name per_data
#' @usage data(per_data)
#' @format A data frame with 3580 rows and 28 variables
"per_data"