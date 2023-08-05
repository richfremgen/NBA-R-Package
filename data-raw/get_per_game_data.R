url <- "https://www.basketball-reference.com"

helper <- function(x, url) {
  x %>% paste0(url, .) %>% 
    read_html() %>%
    html_elements("ul:nth-child(7) li:nth-child(1) a") %>%
    html_attr("href") %>% 
    paste0(url, .)
}

# find url of per game data table for each year 
final_url <- url %>% 
  read_html() %>%
  html_elements("li:nth-child(3) div a") %>%
  html_attr("href") %>% 
  purrr::map_chr(helper, url)

# store data in data raw folder 
purrr::walk(final_url,
            ~ download.file(
              url = .x,
              destfile = here::here("data-raw/PerGameData", basename(.x)),
              quiet = T
            ))

