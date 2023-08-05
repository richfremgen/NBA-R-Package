# INITALIZATION # 
# load data
data("shooting_data", envir = environment())
data("per_data", envir = environment())
data("player_stats", envir = environment())
. <- NULL

# join game & shooting data 
merge_data <- merge(shooting_data, per_data)
team_aes <- teamcolors::teamcolors

# ensure filter player stats data based on available shooting data 
player_stats %>%
  filter(.data$name %in% merge_data$player) -> player_stats

# get stats list for comparison 
stats_list <- data.frame(col_names = names(per_data)[c(3:27)])
stats_list$display_name <- c("Games Played", "Games Started", 
                             "Min Played", "Field Goal", 
                             "Field Goal Attempts", "Field Goal %", "3-PT FG",
                             "3-PT Attempts", "3-PT %", "2-PT FG", "2-PT FG Attempts",
                             "2-PT %", "Effective FG %", "Free Throws", "Free Throw Attempts",
                             "Free Throw %", "Offensive Rebounds", "Defensive Rebounds",
                             "Total Rebounds", "Assists", "Steals", "Blocks",
                             "Turnovers", "Personal Fouls", "Points")

# tooltip function
with_tooltip <- function(value, tooltip) {
  span(style = "text-decoration: underline; text-decoration-style: dotted;", title = tooltip, value)
}

# SHINY APP # 
shinyApp(
  ui <- shinydashboard::dashboardPage(
    title = "nbaanalysis",
    shinydashboard::dashboardHeader(title = span(
      img(src = "nba_logo.png", width = 30),
      span(strong("NBA Analysis"), 
           style = "font-size: 20px")
    )), # end header
    shinydashboard::dashboardSidebar(
      uiOutput("pick_team"),
      uiOutput("pick_player")
    ),# end sidebar,
    
    shinydashboard::dashboardBody(fluidRow(
      column(3,
             style = "background-color:#FFFFFF; border: 2px solid black;margin-left:10px; ",
             uiOutput("player_sidecard")
      ),
      column(8,
             tabsetPanel(
               tabPanel("Player Overview", uiOutput("overview")%>% shinycssloaders::withSpinner(color="#404040")),
               tabPanel("Player Trends", uiOutput("trends")%>% shinycssloaders::withSpinner(color="#404040")),
               tabPanel("NBA Comparison", uiOutput("comparison")%>% shinycssloaders::withSpinner(color="#404040"))
               ))
    )), # end body
    skin = "black"
    ), # end ui
  
  server <- function(input, output, session) {
    # INITIAL SELECTION #
    # team selector 
    output$pick_team <- renderUI(selectizeInput("team", "Pick Team", c("All", unique(player_stats$team_name)), selected = "All"))
    # player selector
    observe({
      if(input$team == "All"){
        players <- unique(player_stats$name)
      }else{
        players <- unique(player_stats$name[player_stats$team_name == input$team])
      }
      output$pick_player <- renderUI(
        selectizeInput("player", "Pick Player", players, selected = "Stephen Curry")
      )
    }) %>% bindEvent(input$team) # end team selector 
    
    
    observe({
      # PLAYER SPECIFIC DATA #
      # get aesthetics from team colors
      team_logo <- team_aes$logo[team_aes$name == player_stats$team_name[player_stats$name == input$player]]
      primary_color <-team_aes$primary[team_aes$name == player_stats$team_name[player_stats$name == input$player]]
      sec_color <- team_aes$secondary[team_aes$name == player_stats$team_name[player_stats$name == input$player]]
      
      # get player stats by name selected
      selected_stats <- reactive({player_stats[player_stats$name == input$player,]})

      
      # PLAYER PROFILE #
      output$player_sidecard <- renderUI({
        fluidPage(
        # top line logos 
        if(isTruthy(team_logo)){
          fluidRow(column(1, tags$img(src = "nba_logo.png", width = 50)),
                   column(1, offset = 7, tags$img(src = team_logo, width = 80)),
                   style = "padding-top:10px")
          
        },
        # player name 
        fluidRow(h3(strong(input$player)), align = "center"),
        # player picture
        if(isTruthy(selected_stats()$person_id)){
          fluidRow(tags$img(src = paste0("https://ak-static.cms.nba.com/wp-content/uploads/headshots/nba/latest/260x190/", 
                                         selected_stats()$person_id, ".png")),align = "center")
        }else{
          fluidRow(tags$img(src = "default_avatar_pic.png"))
        },
        br(),
        # player stats
        fluidRow(h5(HTML(paste0("<b>","Position: ","</b>", selected_stats()$pos)))),
        fluidRow(h5(HTML(paste0("<b>","Date of Birth: ","</b>", selected_stats()$dob)))),
        if(input$player == ""){
          fluidRow(h5(HTML(paste0("<b>","Height: ","</b>"))))
        }else{
          fluidRow(h5(HTML(paste0("<b>","Height: ","</b>", selected_stats()$height_ft, "\' ", selected_stats()$height_in, "\""))))
        },
        if(input$player == ""){
          fluidRow(h5(HTML(paste0("<b>","Weight: ","</b>"))))
        }else{
          fluidRow(h5(HTML(paste0("<b>","Weight: ","</b>", selected_stats()$weight_lbs, " lbs"))))
        },
        fluidRow(h5(HTML(paste0("<b>","Country: ","</b>", selected_stats()$country)))),
        fluidRow(h5(HTML(paste0("<b>","Years in NBA: ","</b>", ifelse(selected_stats()$years_exp == 0, "Rookie", selected_stats()$years_exp))))),
        br()
      )}) # end sidecard
      
      
      # OVERVIEW TAB #
      # overview tab specific data 
      overview_table <- reactive({
        merge_data %>%
          filter(.data$player == input$player) %>%
          select(.data$year, .data$g, .data$mp, .data$fga, .data$`3pa`, .data$pct_3p, .data$ft,.data$orb, .data$drb, .data$ast,.data$stl, .data$blk, .data$tov) %>%
          mutate(across(.data$mp:.data$tov, round, 2)) %>% # round to two decimal places
          mutate(across(.data$mp:.data$tov, format, nsmall = 2)) %>% # format to two decimal places
          mutate(g = round(.data$g, 0)) %>%
          replace(is.na(.data$.), "-") %>% # rename missing with dash
          # rename column names
          arrange(desc(.data$year)) %>%
          rename_with(str_to_upper) %>%
          rename(Year = .data$YEAR, `3PCT` = .data$PCT_3P)
      }) # end of overview table

      heatmap_data <- reactive({
        merge_data %>%
          filter(.data$player == input$player) %>%
          select(.data$fg_pct_3p, .data$fg_pct_16_3p, .data$fg_pct_10_16, .data$fg_pct_3_10, .data$fg_pct_0_3) %>%
          # replace na with 0
          replace(is.na(.data$.), 0) %>%
          summarise(across(.data$fg_pct_3p:.data$fg_pct_0_3, mean))
      }) # end of heatmap data
      
      # overview ui 
      output$overview <- renderUI({
        validate(need(input$player != "", "No Player Selected"))
        validate(need(input$team != "", "No Player Selected"))
        fluidPage(
        br(),
        fluidRow(reactable::renderReactable(
          reactable::reactable(
            overview_table(), 
            defaultColDef = reactable::colDef(minWidth = 50, headerStyle = list(background = "#f7f7f8")),
            sortable = FALSE,
            columns = list(
              G = reactable::colDef(header = with_tooltip("G", "Games Played")),
              MP = reactable::colDef(header = with_tooltip("MP", "Minutes Played")),
              FGA = reactable::colDef(header = with_tooltip("FGA", "Field Goal Attempts")),
              `3PA` = reactable::colDef(header = with_tooltip("3PA", "3-Point Attempts")),
              `3PCT` = reactable::colDef(header = with_tooltip("3PCT", "3-Point Accuracy")),
              FT = reactable::colDef(header = with_tooltip("FT", "Free Throw Accuracy")),
              ORB = reactable::colDef(header = with_tooltip("ORB", "Offensive Rebounds")),
              DRB = reactable::colDef(header = with_tooltip("DRB", "Defensive Rebounds")),
              AST = reactable::colDef(header = with_tooltip("AST", "Assists")),
              STL = reactable::colDef(header = with_tooltip("STL", "Steals")),
              BLK = reactable::colDef(header = with_tooltip("BLK", "Blocks")),
              TOV = reactable::colDef(header = with_tooltip("TOV", "Turnovers"))
            )
          )),
          br(),
            fluidRow(renderPlot(height = 350,
                                plot_shooting_heatmap(heatmap_data()$fg_pct_0_3,
                                                      heatmap_data()$fg_pct_3_10, 
                                                      heatmap_data()$fg_pct_10_16, 
                                                      heatmap_data()$fg_pct_16_3p, 
                                                      heatmap_data()$fg_pct_3p, 
                                                      primary_color,
                                                      sec_color)
            ))
            ))}) # end of overview
        
      
      # TREND TAB #
      # generic trend plot function
      make_trend_plot <- function(var, var_title) {
        ggplot(
          merge_data[merge_data$player == input$player,], aes(x= .data$year, y = round(.data[[var]],2))) + 
          geom_line(aes(group = 1))+ 
          geom_point()+ 
          labs(x = "", y = "", title = var_title)+
          ggthemes::theme_fivethirtyeight()+
          theme(plot.title = element_text(size = 14, hjust = 0.5))
      } # end plot function
      
      # trends ui 
      output$trends <- renderUI({
        validate(need(input$player != "", "No Player Selected"))
        validate(need(input$team != "", "No Player Selected"))
        fluidPage(
          fluidRow( 
            splitLayout(cellWidths = c("33%", "33%", "33%"), 
                        renderPlot(make_trend_plot("fg_pct", "Field Goal %"), height = 200),
                        renderPlot(make_trend_plot("fg_pct_3p", "3-PT Field Goal %"), height = 200),
                        renderPlot(make_trend_plot("pct_ft", "Free Throw %"), height = 200)
                        )
          ), 
          br(),
          fluidRow( 
            splitLayout(cellWidths = c("33%", "33%", "33%"), 
                        renderPlot(make_trend_plot("orb", "Offensive Rebounds"), height = 200),
                        renderPlot(make_trend_plot("drb", "Defensive Rebounds"), height = 200),
                        renderPlot(make_trend_plot("blk", "Blocks"), height = 200)
                        )
          ),
          br(),
          fluidRow(
            splitLayout(cellWidths = c("33%", "33%", "33%"), 
                        renderPlot(make_trend_plot("ast", "Assists"), height = 200),
                        renderPlot(make_trend_plot("stl", "Steals"), height = 200),
                        renderPlot(make_trend_plot("tov", "Turnovers"), height = 200)
                        )
          )
        )
      }) # end trends

      
      # PLAYER COMPARISON TAB
      # inputs & plots for player comparison 
      output$comp_pick_x <- renderUI(
        selectInput("comp_x", "X Statistic", choices = sort(stats_list$display_name), selected = "Points"))
      output$comp_pick_y <- renderUI(
        selectInput("comp_y", "Y Statistic", choices = sort(stats_list$display_name), selected = "Field Goal Attempts"))
      output$comp_pick_years_exp <- renderUI(
        sliderInput("comp_years_exp", "Years Experience", 
                    min = min(player_stats$years_exp, na.rm = TRUE),
                    max = max(player_stats$years_exp, na.rm = TRUE),
                    value = c(min(player_stats$years_exp, na.rm = TRUE),
                              max(player_stats$years_exp, na.rm = TRUE))))
      output$comp_pick_position <- renderUI(
        selectInput("comp_pos", "Position", choices = c("All", unique(player_stats$pos)), selected = "All"))

      # comparison specific data
      comparison_avg_data <- reactive({
        per_data %>%
          mutate_if(is.numeric, ~replace(., is.na(.), 0)) %>%
          # replace(is.na(.), 0) %>%
          group_by(.data$player) %>%
          summarise(across(.data$g:.data$pts, mean))
      })
      
      comparison_selected_data <- reactive({
        req(input$comp_pos)
        player_stats %>%
          filter(
            if (input$comp_pos == "All")
              TRUE
            else
              .data$pos == input$comp_pos,
            between(.data$years_exp, input$comp_years_exp[1], input$comp_years_exp[2])
          ) %>%
          select(.data$name) %>%
          distinct() -> selected_players


        comparison_avg_data() %>%
          filter(.data$player %in% selected_players$name)
      })

      comparison_selected_axis <- reactive({
        data.frame(x = stats_list$col_names[stats_list$display_name == input$comp_x],
                   y = stats_list$col_names[stats_list$display_name == input$comp_y])
      })
      
      # comparison scatterplot
      observe({
        req(input$comp_years_exp, input$comp_x, input$comp_pos)
      output$comp_plot <- renderPlot(
        ggplot() +
          geom_point(data = comparison_selected_data(),
                     aes(x = .data[[comparison_selected_axis()$x]], y = .data[[comparison_selected_axis()$y]])) +
          ggrepel::geom_text_repel(aes(x = comparison_avg_data()[[comparison_selected_axis()$x]][comparison_avg_data()$player == input$player], 
                              y = comparison_avg_data()[[comparison_selected_axis()$y]][comparison_avg_data()$player == input$player], 
                              label = input$player), color = "red") + 
          ggthemes::theme_fivethirtyeight() 
      )
      })
        
      # comparison tab UI 
        output$comparison <- renderUI({
          validate(need(input$player != "", "No Player Selected"))
          validate(need(input$team != "", "No Player Selected"))
          fluidPage(
            br(),
            fluidRow(
              br(),
              column(3, uiOutput("comp_pick_x")),
              column(3, uiOutput("comp_pick_y")),
              column(3, uiOutput("comp_pick_years_exp")),
              column(3, uiOutput("comp_pick_position")),
              style = "background-color:#f7f7f8;"
            ),
            br(),
            fluidRow(plotOutput("comp_plot"))
          )
        }) # end comparison
    }) %>% bindEvent(input$player)# end player observe
  } # end server
) # end shiny app