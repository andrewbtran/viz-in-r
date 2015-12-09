
#Here's how to modify the subset to discard
not_garage_council <- subset(garage_door, Who!="Linehan, William"
                         | Who!="Flaherty, Michael"
                         | Who!="Murphy, Stephen"
                         | Who!="Pressley, Ayanna"
                         | Who!="Wu, Michelle"
                         | Who!="Lamattina, Salvatore"
                         | Who!="Baker, Frank"
                         | Who!="Yancey, Charles"
                         | Who!="McCarthy, Timothy"
                         | Who!="O'Malley, Matthew"
                         | Who!="Jackson, Tito"
                         | Who!="Zakim, Josh"
                         | Who!="McCarthy, Timothy"
                         | Who!="Ciommo, Mark" )

#Hints: Think about the process before, the columns we modified or created. 
# Repeat that. Also change the name of the exported file so it doesn't overwrite

# More hints
# 1) Did you convert the time?
# 2) Did you extract the hour?
# 3) Did you extract the day by label?
# 4) Did you turn the factor column "Who" into a string?
# 5) Did you sub everything after the comma with a blank?

# Ok, here's the code
not_garage_council$datetime <- mdy_hm(not_garage_council$Date.time)
not_garage_council$hour <- hour(not_garage_council$datetime)
not_garage_council$day <- wday(not_garage_council$datetime, label=TRUE, abbr=TRUE)
not_garage_council$Who <- as.character(not_garage_council$Who)
not_garage_council$Who <- gsub(",.*","",not_garage_council$Who)

c <- ggplot(not_garage_council, aes(x=hour))
c <- c + geom_histogram(colour="darkred",fill="white", binwidth=1)
c <- c + ggtitle("Non-Council member garage door triggers by hour and day")
c <- c + ylab("Garage Triggers")
not_council_histograms <- c + facet_grid(Who ~ day)  

ggsave(not_council_histograms, file="not_council_histograms.pdf", width=10, height=20)

# Well, height is going to have to be set really high because there are a LOT of employees to list.
