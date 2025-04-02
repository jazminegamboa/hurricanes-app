# Title: 'Shiny App 1'
# Description: 'Storms Visualizer'
# Details: 
# Author: 'Jazmine Gamboa'
# Date: '10/23/23'


# ======================================================
# Packages (you can use other packages if you want)
# ======================================================
library(shiny)
library(tidyverse)      # for syntactic manipulation of tables
library(sf)             # provides classes and functions for vector data
library(rnaturalearth)  # map data sets from Natural Earth


# ======================================================
# Auxiliary objects (that don't depend on input widgets)
# ======================================================
# world map data for ggplot()
world_countries = ne_countries(returnclass = "sf")

# map to be used as canvas (feel free to customize it)
atlantic_map = ggplot(data = world_countries) +
  geom_sf() +
  coord_sf(xlim = c(-110, 0), ylim = c(5, 65))


# You may need to add one or more auxiliary objects for your analysis
# (by "auxiliary" we mean anything that doesn't depend on input widgets)

aux_tbl = storms |>
  mutate(id = paste0(name, '-', year)) |>
  group_by(id) |>
  summarize(wind_max = max(wind), .groups = 'drop') |>
  filter(wind_max >= 96)


# ===========================================================
# Define UI for graphing a map, and display data table
# ===========================================================
ui <- fluidPage(
  
  # Application title
  titlePanel("Tropical Storms in the North Atlantic"),
  
  # -------------------------------------------------------
  # Sidebar with input widgets 
  # -------------------------------------------------------
  sidebarLayout(
    sidebarPanel(
      # the following widgets are for template purposes,
      # please replace them with widgets of your choice
      textInput(inputId = "year",
                   label = "Enter a year from 1975 to 2021",
                   value = 2000),
      checkboxInput(inputId = "month",
                    label = "Facet by month",
                    value = FALSE),
      checkboxInput(inputId = "wind",
                    label = "Visualize by wind speed",
                    value = FALSE),
      checkboxInput(inputId = "major",
                   label = "Major hurricanes only",
                   value = FALSE),
      checkboxInput(inputId = "water",
                   label = "Add water!",
                   value = FALSE)
    ), # closes sidebarPanel
    
    # -----------------------------------------------------------
    # Main Panel with outputs: plot map of storms, and show table
    # -----------------------------------------------------------
    mainPanel(
      plotOutput(outputId = "plot_map", height = 600),
      hr(),
      dataTableOutput(outputId = "summary_table")
    )
  ) # closes sidebarLayout
) # closes fluidPage


# ======================================================
# Server logic to graph the map, and obtain table
# ======================================================
server <- function(input, output) {
  
  # ------------------------------------------------------------
  # Reactive table of filtered storms
  # (adapt code to manipulate storms according to your analysis)
  # ------------------------------------------------------------
  tbl = reactive({
    # the following filter() is just for demo purposes
    # adapt code to manipulate storms according to your analysis
    storms = storms |> 
      filter(year == input$year)
    
    if (input$major == TRUE) {
      all_storms = storms |>
        mutate(id = paste0(name, '-', year))
        storms = semi_join(all_storms, aux_tbl, by = 'id')}
    
   storms    
  })
  

  
  
  # ------------------------------------------------------------
  # Map of storms
  # (adapt code to make a map according to your analysis)
  # ------------------------------------------------------------
  output$plot_map <- renderPlot({
    
    # this is just starting code to get map for demo purposes
    # (yours will be more complex)
    p = atlantic_map +
        geom_path(data = tbl(), aes(x=long, y=lat, color=name)) +
        guides(alpha = "none")

    # map output
    if (input$month == TRUE){
      p = p +
        facet_wrap(~month)}
    
    if (input$wind == TRUE){
      p = p +
        geom_point(data = tbl(), aes(x = long, y = lat, size = wind, color=name))} 
    else {
      p = p +
        geom_point(data = tbl(), aes(x=long, y=lat, color=name))}
    
    if (input$water == TRUE){
      p = p +
        theme(panel.background = element_rect(fill = 'lightblue'),
              panel.grid.major = element_line(color = 'lightblue'))}
    
    p
    
  })
  
  
  
  # ----------------------------------------------------------
  # Summary Data Table
  # Should contain at least 5 columns:
  # - name
  # - start date
  # - end date
  # - maximum wind
  # - minimum pressure
  # ----------------------------------------------------------
  output$summary_table <- renderDataTable({
    # the following is a dummy table;
    # adapt code to manipulate tbl() according to your analysis
    tbl() |>
      group_by(name) |>
      summarize(start_date = paste0(first(month), '-', first(day)),
                end_date = paste0(last(month), '-', last(day)),
                max_wind = max(wind),
                min_pressure = min(pressure))
      
  })
} # closes server


# Run the application 
shinyApp(ui = ui, server = server)
