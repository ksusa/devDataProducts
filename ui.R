library(shiny)
library(ggplot2)
library(sqldf)
library(tcltk)
library(choroplethr)
library(choroplethrMaps)

#Finding working directory of current script
script.dir <- getwd()
fileName <- paste(script.dir,"/c_unique.csv",sep="")

c_unique <- read.csv(fileName)

# Define UI for application
shinyUI(fluidPage(

  # Application title
  h1("Emissions by USA counties", align="center"),

  
  p("Data on emissions of fine particulate matter (PM2.5) obtained  from ",
    a(" The National Emissions Inventory (NEI) database ",
      href = " https://www.epa.gov/air-emissions-inventories")),
  
  p("Data including fips and name of county for USA obtained  from ",
    a("  ERDDAP data server ",
      href = "http://coastwatch.pfeg.noaa.gov/erddap/convert/fipscounty.html")),
  
  fluidRow(
    column(6,plotOutput("ggPlot")),
    column(6,plotOutput("choropleth")
  ),
  hr(),
  selectizeInput("selection",
	       label = h3("Choose a US county"),
	       choices = as.list(as.vector(c_unique$county)),
	       selected="FL, Palm Beach",
	       options = list(maxOptions = 3221))
  
     )

 
))
