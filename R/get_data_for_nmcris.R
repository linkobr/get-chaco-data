library(here)
library(sf)
library(tidyverse)
library(tigris)

chaco_counties <- counties(state = "New Mexico") |> 
  rename_with(tolower) |> 
  select(countyfp, name) |> 
  filter(name %in% c("San Juan", "McKinley")) |> 
  st_transform(4326)

chaco_counties |> 
  st_geometry() |> 
  plot()

ggplot() +
  geom_sf(data = chaco_counties) +
  coord_sf(crs = 4326, datum = 4326) +
  theme_void()

write_sf(
  chaco_counties,
  dsn = here("data", "chaco-counties.shp")
)
