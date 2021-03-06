# libraries needed for some neat charts

library(plyr)
library(lubridate)
library(dplyr)
library(ggplot2)
library(tidyr)
# The city gave us two separate files
garage1 <- read.csv("council_garage/garage_rawdata1.csv")
garage2 <- read.csv("council_garage/garage_rawdata2.csv")

# We have to bring them together, so we'll bind by rows. 
# This only works if column names are identical
garage <- rbind(garage1, garage2)

# We've been told that garage door is the more accurate measure.
# So let's filter out that dataset
garage_out <- subset(garage, Location=="EXECUTIVE GARAGE OVERHEAD DOOR (READER GARAGE OUT)")
garage_door <- subset(garage, Location=="EXECUTIVE GARAGE OVERHEAD DOOR (READER GARAGE OVERHEAD DOOR)")

# We've got a cleaner data set, but we want to focus on City Council members only
garage_council <- subset(garage_door, Who=="Linehan, William"
| Who=="Flaherty, Michael"
| Who=="Murphy, Stephen"
| Who=="Pressley, Ayanna"
| Who=="Wu, Michelle"
| Who=="Lamattina, Salvatore"
| Who=="Baker, Frank"
| Who=="Yancey, Charles"
| Who=="McCarthy, Timothy"
| Who=="O'Malley, Matthew"
| Who=="Jackson, Tito"
| Who=="Zakim, Josh"
| Who=="McCarthy, Timothy"
| Who=="Ciommo, Mark" )

# Now let's fix the dates using the lubridate package
garage_council$datetime <- mdy_hm(garage_council$Date.time)

# Let's extract the time of the day from the timestamp
garage_council$hour <- hour(garage_council$datetime)

# Making a basic histogram
hist(garage_council$hour)

#Kind of broad. Let's narrow it down
hist(garage_council$hour, breaks=(0:24))

# Better but that's the limits of out-of-the-box graphics. lets get into ggplot
qplot(hour, data=garage_council, geom="histogram")

# Prettier. But the viz looks off. Let's play around the binwidth
qplot(hour, data=garage_council, geom="histogram", binwidth=1)
qplot(hour, data=garage_council, geom="histogram", binwidth=.5)

# qplot is only a slight step up. ggplot is where it gets better
c <- ggplot(garage_council, aes(x=hour))
c + geom_histogram()

c + geom_histogram(binwidth=1)

#Let's add some color
c + geom_histogram(colour="darkred",fill="white", binwidth=1)

#Let's break it out by council person via facets
c <- c + geom_histogram(colour="darkred",fill="white", binwidth=1)
c + facet_grid(. ~ Who)

# Whoa, we're getting somewhere! But it looks funky. Way too wide. Let's swap it.
c + facet_grid(Who ~ .)

#Better. Try exporting as a PNG or a PDF throught he plot viewer on the right.

# Let's get ambitious. What about the day per councilor?

# We have to go back and add a column for day based on the timestamp
garage_council$day <- wday(garage_council$datetime)

head(garage_council$day)

# Hm. Day is a number... I want the day spelled out. How do I find out?
?wday

garage_council$day <- wday(garage_council$datetime, label=TRUE, abbr=TRUE)

# Great, let's try to generate the chart again
c + facet_grid(Who ~ day)

# That didn't work... why? 
# Because we have to reload the dataframe with new day column into "c"
c <- ggplot(garage_council, aes(x=hour))
c <- c + geom_histogram(colour="darkred",fill="white", binwidth=1)
c + facet_grid(Who ~ day)

#OK, I'm being picky now. Let's clean it up a little bit. I only want last names

#What's the variable ns the Who column?
typeof(garage_council$Who)

#Ok, it's a factor. We need to change it into a string so we can edit it
garage_council$Who <- as.character(garage_council$Who)

#Easy. Let's replace everything after the comma with a blank, leaving behind the last name
garage_council$Who <- gsub(",.*","",garage_council$Who)

#OK, let's chart it again
c <- ggplot(garage_council, aes(x=hour))
c <- c + geom_histogram(colour="darkred",fill="white", binwidth=1)
c + facet_grid(Who ~ day)

# Good. Let's add a chart title

c <- ggplot(garage_council, aes(x=hour))
c <- c + geom_histogram(colour="darkred",fill="white", binwidth=1)
c <- c + ggtitle("Council member garage door triggers by hour and day")
council_histograms <- c + facet_grid(Who ~ day) 

#Better! Now what about the Y axis title... 
c <- ggplot(garage_council, aes(x=hour))
c <- c + geom_histogram(colour="darkred",fill="white", binwidth=1)
c <- c + ggtitle("Council member garage door triggers by hour and day")
c <- c + ylab("Garage Triggers")
council_histograms <- c + facet_grid(Who ~ day)  

#Ok, let's export the file (you can also export as a .pdf, if you want)
ggsave(council_histograms, file="council_histograms.png", width=10, height=20)

# Congratulations. For more great info about ggplots, 
# Check out Grammer of Graphics with R & ggplot

# Challenge time! export a .pdf checkins for everyone who's NOT a council member

# NEXT! Let's look at coffee
grow <- read.csv("starbucksgrowth.csv")

# Take a look at the data
grow

# Make a quick chart of US growth - plot(x, y,...)
plot(grow$Year, grow$US)

# Put line between the dots-- Check ?plot
?plot
plot(grow$Year, grow$US, type="l")

# Add another line for Worldwide growth
plot(grow$Year, grow$US, type="l")
lines(grow$Year, grow$Worldwide, type="l", col="red")

# Well, that's weird. 
# Here's the problem. Out-of-the box plotting is based on layers
# Start over but with the order flipped
plot(grow$Year, grow$Worldwide, type="l", col="red")
lines(grow$Year, grow$US, type="l", col="green")

# Much better. Let's clean up the axis titles and add a header
plot(grow$Year, grow$Worldwide, type="l", col="red", main="Starbucks by year", xlab="Year", ylab="Starbucks")
lines(grow$Year, grow$US, type="l", col="green")

# It's missing something.
legend("topleft", # places a legend at the appropriate place 
       c("Worldwide","US"), # puts text in the legend 
       lty=c(1,1), # gives the legend appropriate symbols (lines)
       lwd=c(2.5,2.5),col=c("red","green")) # gives the legend lines the correct color and width

# Alright, that's ok. Kinda boring. Let's ggplot it up
qplot(Year, Worldwide, data=grow, geom="line")

# Alternatively,
g <- ggplot(grow, aes(x=Year, y=Worldwide)) + geom_line()

# We can't plot the second line easily. We need to change the structure of the dataframe
# http://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf

growgg <- gather(grow, "Type", "Starbucks", 2:3)

# Ok, now we can plot it with two lines
ggplot(growgg, aes(x=Year, y=Starbucks, col=Type)) + geom_line()

qplot(factor(Year), data=growgg, geom="bar", fill=Type, binwidth=1)
ggplot(growgg, aes(Year, fill=Type)) + geom_bar(binwidth=1)


# Nice! Let's add a title
ggplot(growgg, aes(x=Year, y=Starbucks, col=Type)) + geom_line() + ggtitle("Starbucks growth since 1992")

# Something fun: Let's export the chart we made to Plot.ly

# First, assign the ggplot to a variable
plotlyggplot <- ggplot(growgg, aes(x=Year, y=Starbucks, col=Type)) + geom_line() + ggtitle("Starbucks growth since 1992")

# Next, download the library
# Get more thorough instructions here https://plot.ly/r/getting-started/
library(devtools)

# load the plotly library
library(plotly)

# set up your authorization. Create a login account and generate your own key
# https://plot.ly/settings/api

# edit this code with your username and API key and run it
set_credentials_file("PlotlyUserName", "APIKey")

# Now, prepare the plotly environment
py <- plotly()

# This will send your ggplot to Plotly and render it online
plotted <- py$ggplotly(plotlyggplot)

# Edit it a bit. Add sourceline, etc.

# Plotly has great documentation, guides for how to use R to make charts
# https://plot.ly/r/

# Another chart maker https://rstudio.github.io/dygraphs/index.html

library(dygraphs)
library(xts)

# Need to convert our years into a time series recognized by R
grow$Year <- strptime(grow$Year, "%Y")

# This is to convert the time series into another format called eXtensible Time Series
grow <- xts(grow[,-1],order.by=as.POSIXct(grow$Year))
dygraph(grow)

# Customize it
dygraph(grow) %>% dyRangeSelector()

# More customization on height and chart type and headline
dygraph(grow,  
        main = "Starbucks growth worldwide", 
        ylab = "Starbucks") %>%
  dySeries("Worldwide", label = "World") %>%
  dySeries("US", label = "US") %>%
  dyOptions(stackedGraph = TRUE) %>%
  dyRangeSelector(height = 20)

# Bring in some interesting data
sbux <- read.csv("starbucks.csv")

# Load in some libraries
# Leaflet for R tutorial https://rstudio.github.io/leaflet/

require(leaflet)
require(dplyr)

# Make a simple map just to test
m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=-71.101936, lat=42.348799, popup="Storytelling with Data")
m  # Print the map

# How many rows are there? 
nrow(sbux)

m <- leaflet(sbux) %>% addTiles() 
  m %>% setView(-98.964844, 38.505191, zoom = 7)
  m %>% addCircles(~lon, ~lat) 

# Close, but needs some cleaning up. Add some map customization
# Add custom map tiles -- look up here http://homepage.ntlworld.com/keir.clarke/leaflet/leafletlayers.htm
m <- leaflet(sbux) %>% addTiles('http://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png') 
m %>% setView(-98.964844, 38.505191, zoom = 4)
m %>% addCircles(~lon, ~lat, weight = 2, radius=1, color = "#008000", stroke = FALSE, fillOpacity = 0.5) 

# Let's try another mapping library for R. This time from Google
library(ggmap)

# https://www.nceas.ucsb.edu/~frazier/RSpatialGuides/ggmap/ggmapCheatsheet.pdf

# Let's bring in another interesting data set
dunk <- read.csv("dunkindonuts.csv")

myLocation <- "Lebanon, KS"
myMap <- get_map(location=myLocation,
source="stamen", maptype="toner", crop=FALSE, zoom=4)

ggmap(myMap)+
  geom_point(aes(x = lng, y = lat), data=dunk, alpha=.5, 
             color="orange", size=1)

# Alright, let's bring it together. We need to put them on one dataframe

# Take just the latitude and longitude columns in Starbucks (and state, too)

sb <- sbux[,c("lat", "lon", "City", "Province")]

# Need a seperate column to distinguish between SB and DD when joined
sb$type <- "Starbucks"
head(sb)

dd <- dunk[,c("lat", "lng", "city", "state")]
dd$type <- "Dunkin' Donuts"

# Bring them together!
sbdd <- rbind(sb, dd)

# Error?? Oh right, the columns are named differently.
colnames(sb) <- c("lat","lng","city", "state","type")

# OK, try it again
sbdd <- rbind(sb, dd)

# Back to leaflet! because it was so pretty

#First, turn Type into a factor, and do some fancy work to assign a color per type
sbdd$type <- as.factor(sbdd$type)
levels(sbdd$type)
cols2 <- c("#FF8000", "#00ff00")
sbdd$colors <- cols2[unclass(sbdd$type)]

# new leaflet code. so exciting
m <- leaflet(sbdd) %>% addTiles('http://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png') 
m %>% setView(-98.964844, 38.505191, zoom = 4)
m %>% addCircles(~lng, ~lat, weight = 1, radius=1, 
                 color=~colors, stroke = FALSE, fillOpacity = 0.3) 

# OK, neat visual. Let's do some calculations

# Chart out the top 5 states for Starbucks
# Good guide for barcharts http://www.cookbook-r.com/Graphs/Bar_and_line_graphs_(ggplot2)/

# Count up the Starbucks per State, turn it into a dataframe
sbstate <- data.frame(table(sb$state))

head(sbstate)

# Need to name the columns for clarity
colnames(sbstate) <- c("id", "Starbucks")

# Order dataframer in descending order of number of Starbucks
sbstate <- sbstate[order(-sbstate$Starbucks),] 

sbgg <- ggplot(data=head(sbstate), aes(x=id, y=Starbucks)) +
   ggtitle("States with the most Starbucks") +
  xlab("State") +
   geom_bar(fill="darkgreen", stat="identity")

sbgg

# Hm... Order seems off, right? That's because of ordering of factors (states)
sbhead <- head(sbstate)

# Head only displays the top 5 We need to subset it out entirely
sbhead <- sbstate[1:5,]

levels(sbhead$id) 

# Whoa, that's messy. Let's fix it

# First, we purge the old factors by converting it to string and converting it back
sbhead$id <- as.character(sbhead$id)
sbhead$id <- as.factor(sbhead$id)

# Now, we can reorder it
levels(sbhead$id)
sbhead$id <- factor(sbhead$id,
          levels = c("CA", "TX", "WA", "FL", "NY"))
levels(sbhead$id)

# Ok, plot it again

sbgg <- ggplot(data=sbhead, aes(x=id, y=Starbucks)) +
  ggtitle("States with the most Starbucks") +
  xlab("State") +
  geom_bar(fill="darkgreen", stat="identity")

sbgg

# Want to see it on plotly? Go for it

plottedsb <- py$ggplotly(sbgg)

# Which states have the most SB or DD per capita?

# Bring in the population table
uspop <- read.csv("uspopulation.csv")

# Let's join them together, using the plyr library
library(plyr)

sb <- join(sbstate, uspop)

head(sb)

# It worked! OK, let's do some calculations

sb$Per100kPeople <- (sb$Starbucks/sb$population)*100000

sb2 <- arrange(sb, desc(Per100kPeople))

sbhead2 <- sb2[1:5,]
sbhead2$id <- as.character(sbhead2$id)
sbhead2$id <- as.factor(sbhead2$id)
sbhead2$id <- factor(sbhead2$id,
                    levels = c("DC", "WA", "OR", "CO", "NV"))
levels(sbhead2$id)


sb2gg <- ggplot(data=sbhead2, aes(x=id, y=Per100kPeople)) +
  ggtitle("Most Starbucks per capita") +
  xlab("State") +
  geom_bar(fill="darkgreen", stat="identity")

sb2gg

# Some fancy Chart layout

require(gridExtra)

grid.arrange(sbgg, sb2gg, ncol=2, main="Starbucks popularity")

test < - grid.arrange(sbgg, sb2gg, ncol=2, main="Starbucks popularity")

# Want to try it in Plotly? Go ahead.

plottedpc <- py$ggplotly(test)

# Well, it won't work all the time... 
# Because it used a new library (gridExtra) on top of ggplot


# OK, back to spatial join!

# Load these packages
require(gtools)
require(rgdal)
require(scales)
require(Cairo)
require(gpclib)
require(maptools)
require(reshape)

# Let's manipulate the Dunkin' Donuts data now. 
# Focus on Dunkin' Donuts in Massachusetts only

str(dd)

massdunk <- filter(dd, state == "MA")

# Let's get the count by town
masscount <- data.frame(table(massdunk$city))

# Name the columns of the new dataframe
colnames(masscount) <- c("id", "DD")

gpclibPermit()
gpclibPermitStatus()

towntracts <- readOGR(dsn="towns", layer="town_shapes")
towntracts <- fortify(towntracts, region="TOWN")

MassData <- left_join(towntracts, masscount)

# That didn't work. Why?

# Because id in towntracts is in uppercase while masscount is not
masscount$id <- toupper(masscount$id)

# Try again

MassData <- left_join(towntracts, masscount)
head (MassData)

# Nice!

# Ok, now it's going to get a little crazy
ddtowns <- ggplot() +
  geom_polygon(data = MassData, aes(x=long, y=lat, group=group, 
                                    fill=DD), color = "black", size=0.2) +
  coord_map() +
  scale_fill_distiller(type="seq", palette = "Reds", breaks=pretty_breaks(n=5)) +
  theme_nothing(legend=TRUE) +
  labs(title="Dunkin Donut towns", fill="")

ggsave(ddtowns, file = "map1.png", width = 6, height = 4.5, type = "cairo-png")
ddtowns

# Now, we sit and wait

# neat!

# There's a slightly easier way

# Back to leaflet! (I love leaflet)

pal <- colorQuantile("YlGn", NULL, n = 5)

town_popup <- paste0("<strong>Dunkin' Donuts: </strong>", 
                      MassData$DD)

mb_tiles <- "http://a.tiles.mapbox.com/v3/kwalkertcu.l1fc0hab/{z}/{x}/{y}.png"

mb_attribution <- 'Mapbox <a href="http://mapbox.com/about/maps" target="_blank">Terms &amp; Feedback</a>'

leaflet(data = MassData) %>%
  addTiles(urlTemplate = mb_tiles,  
           attribution = mb_attribution) %>%
  addPolygons(fillColor = ~pal(order), 
              fillOpacity = 0.8, 
              color = "#BDBDC3", 
              weight = 1, 
              popup = town_popup)

# Real quick, let's take a look at this amazing choropleth package

library(acs)
library(choroplethr)
library(choroplethrMaps)
# Let's play with Census data-- Sign up for an API key
# http://www.census.gov/developers/

api.key.install("yourkeygoeshere")

choroplethr_acs("B01003", "state")

# You can look up more Census tables to map out 
# http://censusreporter.org/topics/table-codes/

# Try it again but at the county level

choroplethr_acs("YourTableofChoice", "county")

# So many choropleth options: Animated, Custom shape files
