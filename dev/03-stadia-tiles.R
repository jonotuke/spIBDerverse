pacman::p_load(conflicted, tidyverse, targets, ggmap, sf)
ggmap::register_stadiamaps(
  key = "a7bf69ed-3e77-41ed-b1e2-52f9aa99ec19"
)
bboxE <- c(-12, 34, 50, 65)
# map.E <- get_stadiamap(
#   bbox = bboxE,
#   zoom = 6,
#   maptype = 'stamen_terrain_background'
# )
# write_rds(map.E, "dev/data/europe.rds")
# map.E.overlay <- get_stadiamap(
#   bbox = bboxE,
#   zoom = 5,
#   maptype = 'stamen_terrain_lines'
# )
# write_rds(map.E.overlay, "dev/data/europe-lines.rds")
europe <- read_rds("dev/data/europe.rds")
europe_lines <- read_rds("dev/data/europe-lines.rds")
nodes <- example_sf$nodes_sf
edges <- example_sf$edges_sf
bb <- st_bbox(nodes)
bb <- sf::st_bbox(nodes)
names(bb) <- c("left", "bottom", "right", "top")
tile <- get_stadiamap(
  bb,
  zoom = 11,
  maptype = 'stamen_terrain_background'
)
ggmap(tile) +
  geom_sf(data = nodes, inherit.aes = FALSE) +
  geom_sf(data = edges, inherit.aes = FALSE)
ggmap(europe) +
  inset_ggmap(europe_lines) +
  xlim(0, 1) +
  ylim(51, 52)
