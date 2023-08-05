#' Run NBA Analysis Shiny App
#' 
#' @return runs shiny app 
#' @examples \dontrun{
#' run_nba_analysis()}
#' @export 
run_nba_analysis <- function(){
  devtools::load_all()
  shiny::runApp(here::here('R/app.R'))
}

