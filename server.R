library(shiny)
library(ggplot2)
library(sqldf)
library(tcltk)
library(choroplethr)
library(choroplethrMaps)

#Finding working directory of current script
script.dir <- getwd()

#print(script.dir)
fileNameCodes <- paste(script.dir,"/FipsCountyCodes.csv",sep="")

fileNameSummary <- paste(script.dir,"/summarySCC_PM25.rds",sep="")

fileName <- paste(script.dir,"/c_unique.csv",sep="")

#Import US counties names
fcc <- read.csv(fileNameCodes)
names(fcc) <- c("fips", "county")
#load data NEI
NEI <- readRDS(fileNameSummary)
# data with name county
c_unique <- read.csv(fileName)

#function that build query using SQL fro R data.frame. Argument of function is name of county
getCountyEmissions <- function(name) {
  code <- subset(c_unique, county==name)$fips
  sql_query <-paste("SELECT year as Year, type as Type, county, sum(Emissions) as Emission FROM NEI JOIN fcc USING (fips) WHERE fips =",as.character(code)," GROUP BY fips, year, type")
  out<-sqldf(sql_query)
  return(out)
}



# Define server logic required to draw UI
shinyServer(function(input, output) {

  # plot
  output$ggPlot <- renderPlot({
     par(mar=c(5,5,4,2))
     plot3 <- qplot(Year, Emission, color = Type, data = getCountyEmissions(input$selection) , geom = "path") +
	      ggtitle(paste("Total PM 2.5 Emissions in",input$selection,"by Source [tonnes]")) +   xlab("Year") +  ylab(expression("Total" ~ PM[2.5] ~ "Emissions (t)"))
     print(plot3)

  })
# map of IS
  output$choropleth <- renderPlot({
     region <- c_unique$fips
     length <- length(region)
     index <- subset(c_unique, county==input$selection)$Number
     value <- as.vector(rep(0,length=length))
     value[index] <- 1
     input <- data.frame(region,value)
     #county_choropleth(input,
     #		 title      = "Selected county location",
     #		 num_colors =2 )
     choro = CountyChoropleth$new(input)
     choro$title = "Selected county location"
     choro$ggplot_scale = scale_fill_manual(name="State selected", values=c("white", "red"), drop=FALSE)
     choro$render()
  })
})
