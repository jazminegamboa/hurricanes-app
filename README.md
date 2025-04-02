# Storms in the North Atlantic Shiny App

This repository contains a shiny app to visualize the trajectories of tropical cyclones (hurricanes) in the North Atlantic. 


## Storms Data Set

The data set behind this app is the `storms` data from the R package "dplyr".


## Running the app


To run the app in Rstudio, execute the following code in R:


```r
library(shiny)

# Run an app from a subdirectory in the repo

runGitHub(
  repo = "hurricanes-app"
  useername = "jazmmiine")
  
```