url <- "https://www.basketball-reference.com"

helper <- function(x, url) {
  x %>% paste0(url, .) %>% 
    read_html() %>%
    html_elements("#bottom_nav_container li:nth-child(8) a") %>%
    html_attr("href") %>%
    paste0(url, .)
}

# get url for shooting data table for each year 
final_url <- url %>% 
  read_html() %>%
  html_elements("li:nth-child(3) div a") %>%
  html_attr("href") %>% 
  purrr::map_chr(helper, url)

# store in raw data 
purrr::walk(final_url,
            ~ download.file(
              url = .x,
              destfile = here::here("raw-data/ShootingData", basename(.x)),
              quiet = T
            ))

