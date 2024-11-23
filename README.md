# Global Temperature Data Task

_Freya Blackmore_

_November 14th, 2024_

# Summary
This file includes a data task analyzing average daily temperature data taken from countries across the globe. The analysis is divided into three sections. 
1. Distribution plots of regional area-weighted and population-weighted daily average temperatures.
2. Animated mapping of monthly average temperatures for each country across the globe.
3. A Treemap depicting relative area and relative population sizes for countries in each region.


# Data
The imported data includes two data sets. 

``` country_geospatial.csv ```

This data set includes the country level geospatial data, include longitude, latitude, population data (2005), and area data.

``` country_dailyavg_ERA5_tavg_2015.csv ```

This data set includes the daily temperature data for each country in 2015. 


# Methods and Models
## Area-Weighted and Population-Weighted Daily Average Temperature Distributions
First, the data is organized by region. Countries are grouped into regions based on their corresponding latitutes. 
> LAT > 23 ~ "extra tropical Northern Hemisphere",
> 
> LAT < -23 ~ "extra tropical Southern Hemisphere",
> 
> LAT <= 23 & LAT >= -23 ~ "tropics"

Once categorized, the daily average area-weighted temperature and population-weighted temperatures are calculated for each region.


> $`AreaWeightedDailyAvg = {\sum(Daily Country Temp * Country Area)}/{Regional Area}`$
> 
> $`PopWeightedDailyAvg = {\sum(Daily Country Temp * Country Population)}/{Regional Population}`$


These averages are then plotted onto three regional distributions showing the variation in area-weighted daily averages and population-weighted averages, with each mean designated within the distribution (Fig 1, Fig 2, Fig 3).

These weighted temperatures differ due to differences in population density across the region. For example, in the extra tropical Northern Hemisphere there are large swaths of land that are uninhabited due to their exceedingly cold temperatures (ie. Siberia, Northern Canada). Therefore, the area-weighted temperatures skew colder than the population weighted temperatures in this region. 

### Fig 1. Population-Weighted and Area-Weighted Average Daily Temperature Data, Extra Tropical Northern Hemisphere
![Population Weighted and Area Weighted Data, Northern Hemisphere](/output/Final%20Northern.jpeg?raw=true "Northern Hemisphere")
### Fig 2. Population-Weighted and Area-Weighted Average Daily Temperature Data, Extra Tropical Southern Hemisphere
![Population Weighted and Area Weighted Data, Southern Hemisphere](/output/Final%20Southern.jpeg?raw=true "Southern Hemisphere")
### Fig 3. Population-Weighted and Area-Weighted Average Daily Temperature Data, Tropics
![Population Weighted and Area Weighted Data, Tropics](/output/Final%20Tropics.jpeg?raw=true "Tropics")

## Country Level Monthly Average Temperature Map
The next part of this program focuses on country level temperature data again. Using the original daily temperature data,  values are now grouped by month instead of by region. Using these groupings, a monthly average temperature is calculated for each country. 

Using several map-based R modules, the monthly average temperature for each country is mapped onto its corresponding position on the map using a color gradient scale. With *gganimate*, each month is animated through a .gif. This creates an animated file where each country changes color each month based on its average temperature that month. This creates an incredibly clear graphic of how temperatures change across the globe throughout the year. 

### Fig 4. .gif depicting average monthly temperature in each country
![Average Monthly Temperature, gif](/output/animation.gif?raw=true "Avg Monthly Temp Animation")

## Considering Area and Population
The final model depicts the relative area and population of each country compared to other countries in their region and around the globe, using a somewhat unorthodox model: the treemap. 

The area of each country determines the size of its corresponding box within the region, with larger areas resulting in larger boxes. The population determines the color of the box, with larger populations resulting in darker colored boxes. 

### Fig 5. Treemap 
![Area/Size, Population/Color, Treemap](/output/Treemap.jpeg?raw=true "Treemap")
