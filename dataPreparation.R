library(tidyverse)
library(anytime)
library(geosphere)

setwd("C:/Users/T430/Dropbox/PhD2/Concetration paper/Data/ShinyApp3")
# read the csv document
ships <- read.csv(file = "ships_.csv", header = TRUE, sep = ",", dec = ".")
#oniline source: https://drive.google.com/file/d/1IeaDpJNqfgUZzGdQmR6cz2H3EQ3_QfCV/view

#return datetime as POSIXct
ships$DATETIME <- str_replace_all(ships$DATETIME, "[T]", " ")
ships$DATETIME <- str_remove_all(ships$DATETIME, "[Z]")
ships$DATETIME <- anytime(ships$DATETIME)

#subset ships only in movement
ships <- subset(ships, is_parked == 0)

#calculating the trip inital and final date and distance
#I did not manage to calculate multiple unique trips per vessel. 
#I could not find a way to find a start and end of a trip.
#So if a ship shas ailed, stopped and sailed again, I couldn't capture that.  
#I think, in order to count the trips, I would need a shapefile (poligon) of the ports, how ever I found only 4 of 6. 
#If you know another way, could you please give me a tip about that? So I could try it again! 

ships <- ships %>%
  group_by(SHIPNAME) %>%
  slice(which.min(DATETIME),
        which.max(DATETIME)) %>%
  mutate(Long = lead(LON), Lat = lead(LAT)) %>%
  rowwise() %>%
  mutate(distance = distCosine(c(LON,LAT), c(Long, Lat)))

#reshaping data frame
ships <- subset(ships, select = c('LAT', "LON", "SHIPNAME", "ship_type", 
                                  "DATETIME", "distance"))
ships <- ships %>%
  group_by(grp = str_c('Column', rep(1:2, length.out = n()))) %>%
  mutate(rn = row_number()) %>%
  ungroup %>%
  pivot_wider(names_from = grp, values_from = c("LAT", "LON", "SHIPNAME", "ship_type", 
                                                "DATETIME", "distance")) %>%
  select(-rn)

#rearranging columns
ships <- ships[,c(1,3,2,4:12)]

#renaming columns
ships = rename(ships, LAT = LAT_Column1, LON = LON_Column1, latFinal = LAT_Column2, lonFinal = LON_Column2,
               SHIPNAME = SHIPNAME_Column1, shipName2 = SHIPNAME_Column2, ship_type = ship_type_Column1, shipType2 = ship_type_Column2,
               dateTimeInitial = DATETIME_Column1,dateTimeFinal = DATETIME_Column2, finalDistance = distance_Column1, InitalDistance = distance_Column2)
ships$finalDistance <- round(ships$finalDistance, digits = 0)

#removing stopped vessels (it seems that is_parked is not that accurate, I am removing trips lower than 1000 meters)
ships <- subset(ships, finalDistance > 1000)

#save dataframe
write_csv(ships, "ships.csv")
