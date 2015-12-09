require(leaflet)
require(dplyr)

sbux <- read.csv("starbucks.csv")
dunk <- read.csv("dunkindonuts.csv")
sb <- sbux[,c("lat", "lon", "City", "Province")]
sb$type <- "Starbucks"
dd <- dunk[,c("lat", "lng", "city", "state")]
dd$type <- "Dunkin' Donuts"
colnames(sb) <- c("lat","lng","city", "state","type")
sbdd <- rbind(sb, dd)

sbdd$type <- as.factor(sbdd$type)

levels(sbdd$type)

cols2 <- c("#FF8000", "#00ff00")

sbdd$colors <- cols2[unclass(sbdd$type)]

m <- leaflet(sbdd) %>% addTiles('http://{s}.tile.stamen.com/toner/{z}/{x}/{y}.jpg') 
m %>% setView(-98.964844, 38.505191, zoom = 4)
m %>% addCircles(~lng, ~lat, weight = 1, radius=1, 
                 color=~colors, stroke = FALSE, fillOpacity = 0.3) 