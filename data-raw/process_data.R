# Shooting Stats ----------------------------------------------------------

#read in list of html for shooting stats data
html_list <- list.files(here::here("data-raw/ShootingData"),full.names = T)

#scraping helper function
scrap_nba <- function(url) {
  
  #read_html for the url
  html_vers <- readr::read_file(url) %>%
    read_html() %>% 
    html_element("#shooting_stats") %>% 
    html_table() %>% {.[,colSums(is.na(.))<nrow(.)]}
  html_vers <- html_vers[,-c(22:29)]

  colnames(html_vers) <- c("rk", "player", "pos","age", "tm", "g", "mp_total","fg_pct", "dist","fga_pct_2p",
                        "fga_pct_0_3", "fga_pct_3_10", "fga_pct_10_16","fga_pct_16_3p", "fga_pct_3p", 
                        "fg_pct_2p", "fg_pct_0_3", "fg_pct_3_10", "fg_pct_10_16", "fg_pct_16_3p", "fg_pct_3p")
  
  html_vers = html_vers[-1,]
  
  html_vers %>% 
    filter(rk!="Rk") %>% 
    mutate(across(-c(rk,player,pos,tm), ~ as.double(.x))) %>% 
    #deal with duplicate data, we used average across team per year
    group_by(player) %>% summarise(across(-c(rk,pos,tm), mean, na.rm=T))%>%
    mutate(year = str_extract(basename(url),pattern = "[0-9]+"))
  
}

#map to dataframe of all data.
shooting_data <- purrr::map_dfr(html_list, scrap_nba)

# save final dataframe 
usethis::use_data(shooting_data, overwrite = TRUE)


# Per Game Stats ----------------------------------------------------------

#read in list of html for per game data
html_list_per <- list.files(here::here("data-raw/PerGameData"),full.names = T)

#scraping helper function
scrap_nba_per <- function(url) {
  
  #read_html for the url
  html_vers <- readr::read_file(url) %>%
    read_html() %>% 
    html_element("#all_per_game_stats") %>% 
    html_table() %>% {.[,colSums(is.na(.))<nrow(.)]} 
  
  colnames(html_vers) <- c("rk", "player", "pos","age", "tm", "g","gs", "mp","fg", "fga","pct_fg",
                           "3p", "3pa", "pct_3p","2p", "2pa",
                           "pct_2p", "pct_efg", "ft", "fta", "pct_ft", "orb",
                           "drb", "trb",
                           "ast", "stl","blk","tov", "pf", "pts")
  
  html_vers %>% 
    filter(rk!="Rk") %>%
    dplyr::mutate(across(-c(rk,player,pos,tm), ~ as.double(.x))) %>%
    #deal with duplicate data, we used average across team per year
    group_by(player) %>% summarise(across(-c(rk,pos,tm), mean, na.rm=T)) %>%
    mutate(year = str_extract(basename(url),pattern = "[0-9]+"))
  
}

#map to dataframe of all data.
per_data <- purrr::map_dfr(html_list_per, scrap_nba_per)

# save final dataframe for per game data
usethis::use_data(per_data, overwrite = TRUE)

