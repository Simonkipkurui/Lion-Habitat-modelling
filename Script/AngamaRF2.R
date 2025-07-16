#clear enviroment
rm(list=ls())

##Get and set the working Directory
##
setwd("C:/Users/simon/Desktop/Angama_RSF2/Angama_RSF2")

##Load necessary libraries
library(sf)
library(terra)
library(tidyverse)

# Import lion file with xy locations, homerange polygon and habitat raster map

# csv file with all the lions points (lion dataframe)
# csv file with all the lions points (lion dataframe)
ANGaF3.df <-read.csv("C:/Users/simon/Desktop/Angama_RSF2/Angama_RSF2/ANGaF3_42559_Complete_RSF.csv")
# polygon (Home range polygon)
ANGaF3_HR_Poly <-st_read("C:/Users/simon/Desktop/Angama_RSF2/Angama_RSF2/ANGaF3_42559.shp")
summary(ANGaF3_HR_Poly)

# raster (Habitat Map from Fem)
Fem_Habitat_Map <-rast("C:/Users/simon/Desktop/Angama_RSF2/Angama_RSF2/habitatfinal.tif")

# Transform to sf object and UTM ------------------------------------------

lion.sf <- ANGaF3.df %>%
  st_as_sf(coords = c('Longitude', 'Latitude'),
           crs = 4326) %>% 
  st_transform(32736)

plot(ANGaF3_HR_Poly$geometry)
plot(lion.sf$geometry,add=T)

# Assign random points to 100% MCP (150*nrow lion track rs)

randompoints <- st_sample(ANGaF3_HR_Poly,12260) 
plot(ANGaF3_HR_Poly$geometry)
plot(randompoints)

Random_Points.sf <- randompoints %>% 
  st_as_sf()
# Convert the file to a regular tibble

randomdata <- Random_Points.sf %>%
  mutate(x = st_coordinates(Random_Points.sf)[ ,1],
         y = st_coordinates(Random_Points.sf)[ ,2]) %>%
  as_tibble() %>%
  mutate(case_ = FALSE) %>% 
  mutate(Collar_ID = 42562)

# Convert the lion file to a regular tibble

lion_track <- lion.sf %>%
  mutate(x = st_coordinates(lion.sf)[ ,1],
         y = st_coordinates(lion.sf)[ ,2]) %>%
  as_tibble() %>%
  select(Collar_ID, x, y) %>%
  mutate(case_ = TRUE) 

# Combine lion data and random data and add weights

lion_track_com <- rbind(randomdata, lion_track) %>%
  mutate(w = ifelse(case_ == T,
                    1,
                    5000))


lion_track_com_sf<-st_as_sf(lion_track_com,coords = c('x', 'y'),
                            crs = 32736)
head(lion_track_com_sf)
crs(lion_track_com_sf)
# Extract covariates
lion_rsf <- terra::extract(Fem_Habitat_Map, lion_track_com_sf)%>%
mutate(habitat_use = factor(classification, 
                              levels = c(1,2,3,4,5),
                    
                            labels = c("Water", "Open", "Semi-closed", "Closed", "Agriculture")))

lion_rsf <- cbind(lion_rsf, lion_track_com)
value_count<-sapply(lapply(lion_rsf,unique),length)
head(value_count)


terra::plot(Fem_Habitat_Map) 

m <- glm(case_ ~ habitat_use,
         family = binomial(link = "logit"), 
         weights = w,
         data = lion_rsf)

ggplot(lion_rsf,
       aes(x = habitat_use,
           y = after_stat(prop),
           group = case_,
           colour = case_)) +
  geom_bar(position = "dodge",
           aes(fill = case_))

#Get the summary 

summary(m)
exp(coef(m))
