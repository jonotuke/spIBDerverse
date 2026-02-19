library(sf)
library(maptiles)
pacman::p_load(conflicted, tidyverse, targets)
# import North Carolina counties
nc_raw <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
nc_raw
nc <- st_transform(nc_raw, "EPSG:3857")
nc
nc_osm <- get_tiles(nc, crop = TRUE)
nc_osm

ggplot(nc) +
  ggspatial::annotation_map_tile(
    zoom = 8
  ) +
  geom_sf(fill = NA)
ggsave("~/Downloads/test.pdf")
