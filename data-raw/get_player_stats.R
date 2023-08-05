# get team specific data
team_data <- read.table("./data-raw/team_data.txt", sep = ",", header = TRUE)
team_data %>% 
  group_by(.data$Current_BBRef_Team_Name) %>%
  mutate(team_id = as.numeric(.data$NBA_Current_Link_ID)) %>%
  select(year = .data$Season, team_name = .data$Current_BBRef_Team_Name, 
         team_abbr = .data$BBRef_Team_Abbreviation, .data$team_id) %>%
  distinct() %>%
  arrange(desc(.data$year)) %>%
  slice(1) %>%
  select(-.data$year) -> team_data


# get player stats 
player_data <- jsonlite::fromJSON("https://data.nba.net/data/10s/prod/v1/2021/players.json", 
                 flatten = TRUE)

player_stats <- player_data$league$standard
player_stats %>%
  filter(isActive) %>%
  mutate(name = paste(.data$firstName, .data$lastName, sep = " ")) %>%
  mutate(team_id = as.numeric(.data$teamId),
         person_id = as.numeric(.data$personId),
         jersey = as.numeric(.data$jersey),
         height_ft = as.numeric(.data$heightFeet),
         height_in= as.numeric(.data$heightInches),
         weight_lbs = as.numeric(.data$weightPounds),
         years_exp = as.numeric(.data$yearsPro)) %>%
  select(.data$name, .data$person_id, .data$team_id, .data$jersey, .data$pos,
         .data$height_ft, .data$height_in, .data$weight_lbs,
         dob = .data$dateOfBirthUTC, y.data$ears_exp, .data$country) -> player_stats
  

# join player and team data
player_stats %>%
  left_join(team_data, by = "team_id") -> player_stats

usethis::use_data(player_stats, overwrite = TRUE)
