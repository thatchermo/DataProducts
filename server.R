#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(maps)
library(mapdata)
library(tools)
library(lubridate)
#library(ggmap)
options("scipen"=999)

# Load Map Data
counties <- map_data("county")
mo.counties <- counties %>% filter(region=="missouri")

# Load Missouri Tornado Data
motorn <- read.csv("motorn.csv")
motorn <-
  motorn %>% mutate(LATITUDE_E = ifelse(LATITUDE_E < 1, NA, LATITUDE_E/100)) %>%
  mutate(Year = as.factor(motorn$Year)) %>%
  mutate(LONGITUDE_ = ifelse(LONGITUDE_ < 1, NA, LONGITUDE_/100)) %>%
  #mutate(F = as.factor(F)) %>%
  mutate(LONGITUDE = -LONGITUDE) %>%
  mutate(LONGITUDE_ = -LONGITUDE_) %>%
  mutate(COUNTYNAME = toTitleCase(tolower(COUNTYNAME))) %>%
  mutate(Month = factor(month(as.Date(BGN_DATE)), labels=month.name)) %>%
  mutate(`Color: None` = "No Groups") %>%
  mutate(CountyEnd = "")

#
motorn <- reshape(motorn, timevar="Point Type", times=c("Start", "End"), direction="long",
                  varying=list(c("LONGITUDE", "LONGITUDE_"), c("LATITUDE", "LATITUDE_E"),
                               c("COUNTYNAME", "CountyEnd")),
                  v.names=c("Longitude", "Latitude", "COUNTYNAME")
)
motorn <- motorn %>% mutate(`Point Type` = factor(`Point Type`, 
                                                     levels=c("Start", "End")))

# Make the plot. Note that helpful mapping code came from
# http://eriqande.github.io/rep-res-web/lectures/making-maps-with-R.html
# For hover code: https://gitlab.com/snippets/16220
shinyServer(function(input, output) {
  
  #output$yearlog <- renderPrint({motorn$Year %in% input$Year})
  
  output$hover_info <- renderPrint({
    
    if(!is.null(input$plot_hover)){
      hover=input$plot_hover
      #point <- nearPoints(motorn[,c("LATITUDE", "LONGITUDE")], hover, threshold = 5, maxpoints = 1, addDist = TRUE)
      point <- nearPoints(motorn[motorn$Year %in% input$Year, ],
                          hover, xvar="Longitude", yvar="Latitude", threshold = 5,
                          maxpoints = 1, addDist = TRUE)
      if (nrow(point) == 0) return(cat(
        paste0("Date: \nCounty: \nF: \nProperty Damage: \nCrop Damage\n")
      ))
      cat(paste0("Date: ", point$BGN_DATE, "\nCounty: ", point$COUNTYNAME, "\nF: ", point$F,
                 "\nProperty Damage: $",
                 format(point$Damage, big.mark=",", scientific=FALSE),
                 "\nCrop Damage: $",
                 format(point$CropDamage, big.mark=",", scientific=FALSE)))
    }
  })
  
  output$moPlot <- renderPlot({
     
    plot.color <- case_when(
      input$plot.color == "Month" ~ "Month",
      input$plot.color == "Year" ~ "Year",
      input$plot.color == "None" ~ "`Color: None`"
    )
    plot.pts <- ggplot() +
      geom_polygon(data=mo.counties,  aes(x=long, y=lat, group=group),
                   fill=NA, color="black") +
      ylab("Latitude") + xlab("Longitude")
      
    if(any(input$plot.elements %in% c("Start", "End"))){
      plot.pts <- plot.pts +
        geom_point(data=motorn[(motorn$Year %in% input$Year &
                                 motorn[,"Point Type"] %in% input$plot.elements), ],
                   aes_string(x="Longitude", y="Latitude", color=plot.color,
                              size="F", shape="`Point Type`")
                   )
    }
    if("Track" %in% input$plot.elements){
      plot.pts <- plot.pts + 
        geom_line(data=motorn[motorn$Year %in% input$Year, ],
                     aes_string(x="Longitude", y="Latitude", group="id",
                         color=plot.color))
    }

    
    plot.pts + 
      coord_fixed(1.3) + scale_colour_discrete(drop = FALSE) +
      scale_shape_manual(values=c(16,13), drop=FALSE) +
      guides(color=guide_legend(ncol=2), shape=guide_legend(ncol=2, 
                                                            override.aes = list(size = 4)))
    
  })
  
})
