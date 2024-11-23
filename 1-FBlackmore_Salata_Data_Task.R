# Freya Blackmore Data Task 
# Pre-Doc in Environmental Economics, Salata Institute
# November 14th, 2024

# -----------------------------------------------------------

# Libraries ####

library(dplyr)
library(knitr)
library(ggplot2)
library(readr)
library(tidyr)

# Loading in data sets ####

geospatial_data <- read_csv("Documents/R/Salata_technical_screen/country_geospatial.csv")
daily_avg_temp <- read_csv("Documents/R/Salata_technical_screen/country_dailyavg_ERA5_tavg_2015.csv")


# -------------- Data Table Manipulation ------------------- ####


# Combining the both data sets into one one full data table

full_data <- geospatial_data %>% 
  select(c(ISO3, NAME, AREA, POP2005, LAT)) %>%
  # designating regions by latitude
  mutate(region = case_when(
    LAT > 23 ~ "extra tropical Northern Hemisphere",  
    LAT < -23 ~ "extra tropical Southern Hemisphere",
    LAT <= 23 & LAT >= -23 ~ "tropics")) %>%
  dplyr::group_by(region) %>%
  # adds column denoting total area of each region
  dplyr::mutate(regional_area = sum(AREA)) %>%   
  # adds column denoting total population of the region
  dplyr::mutate(regional_population = sum(POP2005)) %>%  
  dplyr::ungroup() %>%
  # adding in the daily temperature data, joined by country
  left_join(daily_avg_temp, by = c("ISO3" = "iso3", "NAME" = "name")) 


# ------------- Weighted Value Calculations ------------------------ ####


# Calculating population-weighted daily averages within each region  ####
# pop-weighted avg temp = sum(daily country temp * country population) / regional population

population_weighted_averages <- full_data %>%
  # multiplying each temp by that country's population
  rowwise() %>%
  mutate_at(vars(starts_with("m")), 
            ~ .*POP2005) %>%
  # summing all temp*population values in each region for each day
  dplyr::group_by(region, regional_population) %>%
  dplyr::summarise(across(starts_with("m"), sum, na.rm = TRUE)) %>%  
  dplyr::ungroup() %>%
  # dividing each daily sum(temp*population) by the regional population
  rowwise() %>%
  mutate_at(vars(starts_with("m")),
            ~ ./regional_population) %>%
  select(!c(regional_population))

# adding a column noting the weighting variable
population_weighted_averages <- cbind("weighting" = "population", population_weighted_averages)



# Calculating area-weighted daily averages within each region
# area-weighted avg temp = sum(daily country temp * country area) / regional area

area_weighted_averages <- full_data %>%
  # multiplying each temp by that country's area
  rowwise() %>%
  mutate_at(vars(starts_with("m")),
            ~ .*AREA) %>%
  # summing all temp*area values in each region for each day
  dplyr::group_by(region, regional_area) %>%
  dplyr::summarise(across(starts_with("m"), sum, na.rm = TRUE)) %>%
  dplyr::ungroup() %>%
  # dividing each daily sum(temp*area) by the regional area
  rowwise() %>%
  mutate_at(vars(starts_with("m")),
            ~ ./regional_area) %>%
  select(!c(regional_area))

# adding a column noting the weighting variable
area_weighted_averages <- cbind("weighting" = "area", area_weighted_averages)



# Combining area weighted averages and population weighted averages into one table

weighted_regional_daily_averages <- rbind(population_weighted_averages, area_weighted_averages)



# ------------- Distribution Plots ----------------- ####



# Extra tropical Northern Hemisphere distribution plot

# Lengthening data format for plotting
northern_hemisphere <- weighted_regional_daily_averages %>%
  filter(region == "extra tropical Northern Hemisphere") %>%
  pivot_longer(cols = starts_with("m"), 
               names_to = "day", 
               values_to = "temperature")

# Calculating the mean and variance for Northern Hemisphere weighted data
northern_mean <- ddply(northern_hemisphere, "weighting", summarise, temperature.mean=mean(temperature))
northern_variance <- ddply(northern_hemisphere, "weighting", summarise, temperature.variance = var(temperature))

# Creating distribution plot
ggplot(northern_hemisphere, aes(x = temperature, colour = weighting)) + 
  geom_density() +
  geom_vline(data = northern_mean, aes(xintercept = temperature.mean, colour = weighting),
             linetype = "dashed", size = .5) +
  labs(title = "Extra Tropical Northern Hemisphere", 
       subtitle = "Area-Weighted and Population-Weighted Temperature Distribution", 
       caption = "mean values denoted by dotted line")



# Extra tropical Southern Hemisphere distribution plot

# Lengthening data format for plotting
southern_hemisphere <- weighted_regional_daily_averages %>%
  filter(region == "extra tropical Southern Hemisphere") %>%
  pivot_longer(cols = starts_with("m"), 
               names_to = "day", 
               values_to = "temperature")

# Calculating the mean and variance for Southern Hemisphere weighted data
southern_mean <- ddply(southern_hemisphere, "weighting", summarise, temperature.mean=mean(temperature))
southern_variance <- ddply(southern_hemisphere, "weighting", summarise, temperature.variance = var(temperature))


# Creating distribution plot
ggplot(southern_hemisphere, aes(x = temperature, colour = weighting)) + 
  geom_density() +
  geom_vline(data = southern_mean, aes(xintercept = temperature.mean, colour = weighting),
             linetype = "dashed", size = .5) +
  labs(title = "Extra Tropical Southern Hemisphere", 
       subtitle = "Area-Weighted and Population-Weighted Temperature Distribution", 
       caption = "mean values denoted by dotted line")


# Tropics distribution plot

# Lengthening data format for plotting
tropics <- weighted_regional_daily_averages %>%
  filter(region == "tropics") %>%
  pivot_longer(cols = starts_with("m"), 
               names_to = "day", 
               values_to = "temperature")

# Calculating the mean and variance for Tropics weighted data
tropics_mean <- ddply(tropics, "weighting", summarise, temperature.mean=mean(temperature))
tropics_variance <- ddply(tropics, "weighting", summarise, temperature.variance = var(temperature))


# Creating distribution plot
ggplot(tropics, aes(x = temperature, colour = weighting)) + 
  geom_density() +
  geom_vline(data = tropics_mean, aes(xintercept = temperature.mean, colour = weighting),
             linetype = "dashed", size = .5) +
  labs(title = "Tropics", 
       subtitle = "Area-Weighted and Population-Weighted Temperature Distribution", 
       caption = "mean values denoted by dotted line")



# ------------- World Mapping Data ---------------------- ####
library(gganimate)
library(rnaturalearth)
library(maps)
library(gifski)

# loading in world data for mapping, filtering out Antarctica

world <- ne_countries(scale = "medium", returnclass = "sf") %>%
  filter(iso_a3 != "ATA")


month_names <- c("January", "February", "March", "April", "May", 
                 "June", "July", "August", "September", "October", 
                 "November", "December")

# lengthening the daily average temperatures
# & adding a column containing only the month of each observation
# orders months chronologically for animation

map_daily_avg_temp <- daily_avg_temp %>%
  pivot_longer(cols = starts_with("m"), names_to = "day", values_to = "temperature") %>%
  arrange(day) %>%
  mutate(Month = substr(day, 2, 3)) %>%
  mutate(Month = factor(Month, levels = sprintf("%02d", 1:12), labels = month_names)) %>%
  # calculating each country's average monthly temperature 
  dplyr::group_by(iso3, name, Month) %>%
  summarise(monthly_avg_temp = mean(temperature, na.rm = TRUE))

# adding manipulated data to global data for mapping
  
world_monthly_avg_temps <- world %>%
  left_join(map_monthly_avg_temp, by = c("iso_a3" = "iso3")) %>%
  filter(!is.na(monthly_avg_temp))

# creating an animated that transitions temperature data based on month

map <- ggplot(world_monthly_avg_temps) +
  geom_sf(aes(fill = monthly_avg_temp), color = "white", lwd = 0.2) +
  scale_fill_viridis_c(option = "plasma", na.value = "gray90") +
  labs(title = "Monthly Average Temperature by Country - {closest_state}",
       fill = "Monthly Average Temp (°C)") +
  theme_minimal() +
  theme(panel.background = element_rect(fill = "aliceblue"),
        legend.position = "right") +
  transition_states(Month, transition_length = 2, state_length = 1) 

# setting the parameters of the desired animation
animate(map, nframes = 12, duration = 10, width = 800, height = 600, 
        renderer = gifski_renderer("animation.gif"))
  

# ---------------- Tree Map Data -------------------

library(treemap)

# creating treemap of area and population
treemap(full_data,
        index=c("region","NAME"),  
        vSize = "AREA",  # area determines the size of each box
        vColor = "POP2005", # population determines the color of each box
        type = "value", 
        palette = "Reds",
        title="Country Area to Population"
)
