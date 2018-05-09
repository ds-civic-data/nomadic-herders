library(shiny)
library(ggplot2)
library(lubridate)
library(tidyverse)
library(ggmap)
library(reshape)
library(lubridate)
library(leaflet)

df1<-read.csv("data/in_file.csv",stringsAsFactors=FALSE)
zipdata<-read.csv("data/Zip_Coords.csv", header=FALSE, col.names=c("Name", "Zip", "Lat","Long", "Pasture"), colClasses = c("character", "integer", "numeric", "numeric", "character"))


request_type=c("All", "Short Term Forecast", "Long Term Forecast", "Pasture Info" )


min_date <- as.Date("2016-01-01")
max_date <- as.Date("2018-01-01")

# Define UI for application that plots 
ui <- fluidPage(
  
  # Application title
  titlePanel("SMS Spatial usage"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      sliderInput("year_filter", "Select Earliest Year", min = min_date,
                  max=max_date, value = c(min_date,max_date)),
      
      selectInput("request_type", "Request Type", choice=request_type)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      leafletOutput("map"), 
      
      fluidRow(
        column(4, verbatimTextOutput("range")))
      
    )
  )
)

##Server is where all of the computations happen
server <- function(input, output) {
  
  output$range <- renderPrint({ input$year_filter })
  
  plotcodes <- reactive({
    df1 %>%
      filter(Date > input$year_filter[1], Date < input$year_filter[2]) %>%
      mutate(req_type=as.numeric(substr(Message,6,7)))%>%
      left_join(zipdata, by=c("area"="Zip")) %>%
      filter(
        if(input$request_type=="Short Term Forecast") {req_type==1} 
        else if(input$request_type=="Long Term Forecast") {req_type==2}
        else if(input$request_type=="Pasture Info") {req_type==3}
        else {req_type %in% c(1,2,3)}
      ) %>%
      group_by(area) %>%
      summarize(num=n(), lat=median(Lat), long=median(Long)) %>%
      mutate(radius=num*100) %>%
      arrange(desc(radius))})
  
  output$value <- renderPrint({head(output$df2)})
  
  output$map <- renderLeaflet({
    leaflet(plotcodes()) %>%
      addTiles() %>%
      setView(lng = 103, lat = 47, zoom = 5) %>%
      clearShapes() %>%
      addCircles(radius=plotcodes()$radius, label=as.character(plotcodes()$num))
    
  
  })
  
  
    
    
  
}

# Run the application 
shinyApp(ui = ui, server = server)
