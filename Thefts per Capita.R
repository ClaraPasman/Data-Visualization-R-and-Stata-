
setwd("/Users/clara/Documents/MAESTRIA/HERRAMIENTAS COMPUTACIONALES/R/videos 2 y 3")


#########################GGPLOT MAP####################################
library(rgdal)
library(dplyr)
lnd <- readOGR(dsn = "data/london_sport.shp")


lnd_f <- broom::tidy(lnd)

## Creo un id para las observaciones dentro del shapefile
lnd$id <- row.names(lnd)

##Uno las bases 
lnd_f <- left_join(lnd_f, lnd@data) 

lnd$id <- row.names(lnd)
##Uno las bases 

lnd@data <- left_join(lnd_f, lnd@data) 


#Join el shapefile  con base crime
crime_data <- read.csv("data/mps-recordedcrime-borough.csv",
                       stringsAsFactors = FALSE)

#Selecciono solo los thefts
crime_theft <- crime_data[crime_data$CrimeType == "Theft & Handling", ]

#Calculo la cantidad total de thefts per area 
crime_ag <- aggregate(CrimeCount ~ Borough, FUN = sum, data = crime_theft)


##Uno esta base con la data del shapefile

lnd_f$name %in% crime_ag$Borough
lnd$name[!lnd_f$name %in% crime_ag$Borough]
head(lnd_f$name,100)
head(crime_ag$Borough,100) 

##Uno las bases
lnd@data <- left_join(lnd@data, crime_ag, by = c('name' = 'Borough'))

##Genero la nueva variable thefts per cap 
lnd@data$Pop<- as.numeric(lnd@data$Pop_2001)

lnd@data$theft_per_cap<-(lnd@data$CrimeCount/lnd@data$Pop)*1000

##Genero el mapa con ggplot 
library(ggplot2)
map <- ggplot(lnd, aes(long, lat, group= group, fill = lnd@data$theft_per_cap)) +
  geom_polygon(colour = "grey30") + coord_equal() +
  labs(x = "Easting (m)", y = "Northing (m)",
       fill = "Thefts per capita") +
  ggtitle("London's thefts per capita ")
map + scale_fill_gradient2(low= "orange", high = "red", midpoint = 0,)
map

#########################TMAP MAP####################################
library(rgdal) 

lnd <- readOGR("data/london_sport.shp")

crime_data <- read.csv("data/mps-recordedcrime-borough.csv",
                       stringsAsFactors = FALSE)

head(crime_data$CrimeType) # information about crime type

crime_theft <- crime_data[crime_data$CrimeType == "Theft & Handling", ]

crime_ag <- aggregate(CrimeCount ~ Borough, FUN = sum, data = crime_theft)

lnd$name %in% crime_ag$Borough
lnd$name[!lnd$name %in% crime_ag$Borough]

library(dplyr)

head(lnd$name,100) 
head(crime_ag$Borough,100) 

##Uno las bases
lnd@data <- left_join(lnd@data, crime_ag, by = c('name' = 'Borough'))

##Genero la nueva variable thefts per cap 
lnd@data$Pop<- as.numeric(lnd@data$Pop_2001)

lnd@data$theft_per_cap<-(lnd@data$CrimeCount/lnd@data$Pop)*1000

install.packages("raster")
install.packages("tmap")
library(tmap)

##Genero el mapa con tmap 
qtm(shp = lnd,fill="theft_per_cap", fill.palette = "Blues",fill.title = " ") + tm_layout("Thefts per capita", title.size=1, aes.palette="Blues", legend.width=0.3, legend.title.size=0.75)


