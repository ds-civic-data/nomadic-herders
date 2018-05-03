##02 - Reactives
#
## anything you load here can be seen by both ui and server
library(shiny)
library(ggplot2)
library(lubridate)
library(tidyverse)
library(ggmap)
library(reshape)
library(lubridate)


select_color_options <- c("type_of_subject", "subject_race", "subject_sex")

min_date <- as.Date("2016-01-01")
max_date <- as.Date("2018-01-01")

# Define UI for application that plots 
ui <- fluidPage(
  
  # Application title
  titlePanel("Adding a Reactive"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      sliderInput("year_filter", "Select Earliest Year", min = min_date,
                  max=max_date, value = min_date)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("map_plot"),
    )
  )
)

##Server is where all of the computations happen
server <- function(input, output) {
  
  df1<-read.csv("data/LTS_deidentified.csv",stringsAsFactors=FALSE)
  
  zipdata<-read.csv("data/Zip_Coords.csv", header=FALSE, col.names=c("Name", "Zip", "Lat","Long", "Pasture"), colClasses = c("character", "integer", "numeric", "numeric", "character"))
  
  mutate(df1, month=month(Date)) %>%
    ggplot(aes(x=month))+geom_bar()
  
  mutate(df1, month=month(Date)) %>%
    group_by(id) %>%
    summarize(mindate=min(Date), maxdate=max(Date)) %>%
    group_by(maxdate) %>%
    summarize(maxcount=n()) %>%
    ggplot(aes(x=maxcount))+geom_bar(binwidth = 30)
  
  strsplit(df1$Message[[3]], " ")[[1]][[1]]
  
  bbox <- c(left = 87, bottom = 40.5, right = 120, top =52.5)
  ggmap(get_stamenmap(bbox, zoom = 13))
  devtools::install_github("dkahle/ggmap")
  m<-get_stamenmap(bbox, maptype = "terrain", zoom = 5)
  
  calls_filtered <- reactive({
    df2<-filter(df1, Type=="in") %>%
      filter(Date > min_date, Date < max_date)
      mutate(Zip=as.numeric(substr(Message,0,5))) %>%
      inner_join(zipdata, by=c("Zip"="Zip")) %>%
      mutate(Pasture=ifelse(Pasture=="pasture",TRUE, FALSE)) %>%
      group_by(Zip) %>%
      summarize(count=n(), lat=mean(Lat), long=mean(Long))})
  
  output$map_plot <- renderPlot({ggmap(m) +
      geom_point(data = df2, aes(x = long, y = lat, size=count, alpha=.05))+ guides(alpha=FALSE)
  })

}

# Run the application 
shinyApp(ui = ui, server = server)

