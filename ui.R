#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

motorn <- read.csv("motorn.csv")
motorn$Year <- as.factor(motorn$Year) 

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Missouri Tornado Data"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
    #    sliderInput("Year",
    #                "Year:",
    #                min = min(motorn$Year),
    #                max = max(motorn$Year)+1,
    #                value = c(2011,2012))
    #    #submitButton("Submit")
    checkboxGroupInput("Year", label = h3("Year"), 
                       choices = levels(motorn$Year), selected=2011, inline=TRUE)
    ,
    
    checkboxGroupInput("plot.elements", label = h3("Plot Elements"), 
                       choices = c("Start", "Track", "End"), selected="Start",
                       inline=TRUE),
    
    radioButtons("plot.color", label = h3("Color"), 
                       choices = c("Month", "Year", "None"), selected="Month",
                       inline=TRUE)
    ),
    
    # Show a plot of the generated distribution
    
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(type = "tabs",
        tabPanel("App", br(),
                  plotOutput("moPlot", hover = hoverOpts(id ="plot_hover")),# ,
                             #width="100%", height="450px"),
                  verbatimTextOutput("hover_info")
        ),
        tabPanel("Documentation", br(),
                 p(
                   "This Shiny app displays tonado event data for the years between 
                   1996 and 2011. This data is included as part of a much larger weather
                   event data set available from the ",
                   a(href="https://www.ncdc.noaa.gov/stormevents/", 
                     "National Climatic Data Center"), 
                   ", although this version of the data set was made available as part
                   of an assignment in the ", 
                   em("Reproducible Research "),
                   "component of the Coursera Data Science certificate.",
                   a(href="https://d396qusza40orc.cloudfront.net/repdata/data/StormData.csv.bz2",
                     "Click here for that raw data set."),
                   "The data represented here includes only Missouri storm events
                   whose event type was listed as 'TORNADO.' Data cleaning has been 
                   applied to calculate what we hope are correct dollar amounts for
                   damages, and to convert other variables into usable formats, but
                   no other cleaning has been done."
                  ),
                 p(
                   "Controls in this app allow the user to select the following
                   characteristics:"
                 ),
                 tags$ul(
                   tags$li("Year or years to visualize."),
                   tags$li("Whether any or all of the (1) starting point, (2) ending point,
                            or
                            (3) segment connecting the two is displayed for tornado events."),
                   tags$li("Whether color is used to display the month or year in
                           which the storm event took place.")
                 ),
                 p(
                   "Additionally, the app displays two other pieces of information:"
                 ),
                 tags$ul(
                   tags$li("Size of the map marker indicates the intensity of the tornado."),
                   tags$li("Additional information about date, location, and monetary damage
                            caused by the tornado is displayed when the cursor is placed
                            over a marker. Note that 'County' refers to the county in which
                            the event began, and will only be displayed for starting points.")
                 ),
                 p(
                   "Intensity of the tornado is measured on the Fujita scale, which ranges 
                    from F0 (least intense) to F5 (most intense).",
                   a(href="https://en.wikipedia.org/wiki/Fujita_scale",
                     "More information about the Fujita scale can be found here.")
                 ),
                 p(
                   "The National Climatic Data Center ",
                   em("Storm Data FAQ Page"),
                   "also gives the following caveat concerning tornado data in its
                    database:"
                 ),
                 tags$blockquote(style="font-size:100%",
                   "Tornadoes may contain multiple segments. A tornado that crosses a county line or state line is
                   considered a seperate segment. Also, a tornado that lifts off the ground for less that 5 minutes or 2.5
                   miles is considered a seperate segment. If the tornado lifts off the ground for greater than 5 minutes or
                   2.5 miles, it is considered a seperate tornado. Tornadoes reported in Storm Data and the Storm Events
                   Database are in segments."
                   ),
                 p(
                   "Therefore, information displayed in this app should be interpreted
                    with some caution."
                 )
        )
    )
  )
)))
