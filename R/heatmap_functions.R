#' Generates points on circle in terms of cartesian coordinates
#' 
#' @param r radius
#' @param x_center coordinate for x center
#' @param y_center coordinate for y center
#' @return returns dataframe of x and y coordinates circle with desired parameters
#' @keywords internal
generate_circle <- function(r, x_center, y_center) {
  circle <- matrix(NA, nrow = 5000, ncol = 2)
  for(i in seq_len(5000)){
    theta <- stats::runif(1) * 2 * pi 
    x <- x_center + r * cos(theta)
    y <- y_center + r * sin(theta)
    circle[i, 1] <- x
    circle[i, 2] <- y
  }
  return(data.frame(x = circle[,1], y = circle[,2]))
}

#' Use diagram of half court to create heatmap based on shooting accuracy from different distances to basket where gradient of heatmap is bounded by player's team's colors 
#' 
#' @param dist_0_3 Shooting accuracy percentage between 0 and 3 feet
#' @param dist_3_10 Shooting accuracy percentage between 3 and 10 feet
#' @param dist_10_16 Shooting accuracy percentage between 10 and 16 feet
#' @param dist_16_3p Shooting accuracy percentage between 16 feet and 3-pt line
#' @param dist_3p Shooting accuracy percentage for 3-pts 
#' @param primary Hexcode of primary color of player's team
#' @param secondary Hexcode of secondary color of player's team
#' @return A ggplot heatmap of player scoring accuracy 
#' @keywords internal
plot_shooting_heatmap <- function(dist_0_3, dist_3_10, dist_10_16, dist_16_3p, dist_3p, primary, secondary) {
  # generate circles of larger radius for each distance band 
  # value column equal to corresponding shooting accuracy 
  generate_circle(25, x_center = 25, y_center = 5.25) %>%
      filter(.data$y >= 4.75) %>%
      mutate(type = "3pt", value = dist_3p) %>%
      arrange(.data$x) -> three_pt_circle
  generate_circle(23.75, x_center = 25, y_center = 5.25) %>%
      filter(.data$y >= 4.75) %>%
      mutate(type = "16-3pt", value = dist_16_3p) %>%
      arrange(.data$x) -> sixteen_three_circle
  generate_circle(16, x_center = 25, y_center = 5.25) %>%
    filter(.data$y >= 4.75) %>%
    mutate(type = "10-16", value = dist_10_16) %>%
    arrange(.data$x) -> ten_sixteen_circle
  generate_circle(10, x_center = 25, y_center = 5.25) %>%
    filter(.data$y >= 4.75) %>%
    mutate(type = "3-10", value = dist_3_10) %>%
    arrange(.data$x) -> three_ten_circle
  generate_circle(3, x_center = 25, y_center = 5.25) %>%
    filter(.data$y >= 4.75) %>%
    mutate(type = "0-3", value = dist_0_3) %>%
    arrange(.data$x) -> zero_three_circle
  # bind circles together 
  bind_rows(three_pt_circle, sixteen_three_circle) %>%
      bind_rows(ten_sixteen_circle) %>%
      bind_rows(three_ten_circle) %>%
      bind_rows(zero_three_circle) -> shooting_fg
    
  shooting_fg$type <- factor(shooting_fg$type, levels = c("3pt", "16-3pt", "10-16", "3-10", "0-3"))
  
  # court graphics 
  generate_circle(4, x_center = 25, y_center = 5.25)  %>% 
    filter(.data$y >= 5.5) %>%
    arrange(.data$x) -> basket_circle
  generate_circle(23.75, x_center = 25, y_center = 5.25)%>%
    filter(.data$y >= 14) %>%
    arrange(.data$x) -> three_pt_circle
  left_triangle <- data.frame(x = c(0, 0, 38), y = c(0, 15, 0))
  right_triangle <- data.frame(x = c(12, 50, 50), y = c(0, 15, 0))
  
  # combined graph of court and distance bands 
  ggplot() +
      geom_polygon(data = shooting_fg, aes(x = .data$x, y = .data$y, group = .data$type, fill = .data$value)) +
      geom_polygon(data = left_triangle, aes(.data$x,.data$y), fill = "#242526") +
      geom_polygon(data = right_triangle, aes(.data$x,.data$y), fill = "#242526") +
      geom_segment(aes(x = 3 , y = 0, xend = 3, yend = 14.1), color = "white") + 
      geom_segment(aes(x = 47 , y = 0, xend = 47, yend = 14.1), color = "white") +
      geom_segment(aes(x = 17 , y = 0, xend = 17, yend = 19), color = "white") +
      geom_segment(aes(x = 33 , y = 0, xend = 33, yend = 19), color = "white") +
      geom_segment(aes(x = 19 , y = 0, xend = 19, yend = 19), color = "white") +
      geom_segment(aes(x = 31 , y = 0, xend = 31, yend = 19), color = "white") + 
      geom_segment(aes(x = 17 , y = 19, xend = 33, yend = 19), color = "white") + 
      geom_segment(aes(x = 22 , y = 4, xend = 28, yend = 4), color = "white") + 
      ggforce::geom_circle(aes(x0 = 25, y0 = 5.25, r = 0.75), color = "white") +
      ggforce::geom_circle(aes(x0 = 25, y0 = 19, r = 6), color = "white") +
      geom_path(data = basket_circle, aes(.data$x, .data$y), color = "white") + 
      geom_path(data = three_pt_circle, aes(.data$x, .data$y), color = "white") + 
      coord_fixed() + 
      xlim(0, 50) + 
      ylim(0, 35) +
      scale_fill_gradient(low = primary, high = secondary)+
      theme(axis.title = element_blank(), 
            axis.ticks = element_blank(),
            axis.text = element_blank(),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            plot.background = element_rect(fill = '#242526'),
            panel.background = element_rect(fill = '#242526'),
            legend.background = element_rect(fill = '#F5F5F5', color = "black"), 
            legend.title = element_text(size = 12), 
            legend.text = element_text(size = 11),
            plot.title = element_text(color = "white", size = 17, hjust = 0.5, face = "bold", margin=margin(20,0,0,0))
      ) +
      labs(fill = "Field Goal %", title = "Shooting Accuracy by Distance from Net")
}
