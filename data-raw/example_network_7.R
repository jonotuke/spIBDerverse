nodes <- data.frame(
  # fmt: skip
  name = c(
    "London", "Paris", "Amsterdam", "Brussels", "Dublin",
    "Madrid", "Lisbon", "Barcelona", "Rome", "Milan", "Athens",
    "Berlin", "Munich", "Vienna", "Prague",
    "Warsaw", "Budapest",
    "Copenhagen", "Stockholm", "Oslo"
  ),
  # fmt: skip
  country = c(
    "United Kingdom", "France", "Netherlands", "Belgium", "Ireland",
    "Spain", "Portugal", "Spain", "Italy", "Italy", "Greece",
    "Germany", "Germany", "Austria", "Czechia",
    "Poland", "Hungary",
    "Denmark", "Sweden", "Norway"
  ),
  region = c(
    rep("West", 5),
    rep("South", 6),
    rep("Central", 4),
    rep("East", 2),
    rep("North", 3)
  ),
  # fmt: skip
  lat = c(
    51.507, 48.857, 52.370, 50.850, 53.350,
    40.417, 38.722, 41.385, 41.903, 45.464, 37.984,
    52.520, 48.135, 48.208, 50.076,
    52.230, 47.498,
    55.676, 59.329, 59.914
  ),
  # fmt: skip
  long = c(
    -0.128, 2.352, 4.895, 4.352, -6.260,
    -3.704, -9.139, 2.173, 12.496, 9.190, 23.728,
    13.405, 11.582, 16.373, 14.438,
    21.012, 19.040,
    12.568, 18.069, 10.752
  ),
  # fmt: skip
  # Approximate city-proper population, millions
  population = c(
    8.9, 2.1, 0.92, 1.2, 0.59,
    3.3, 0.55, 1.6, 2.8, 1.4, 0.64,
    3.7, 1.5, 2.0, 1.3,
    1.8, 1.7,
    0.65, 0.98, 0.71
  ),
  stringsAsFactors = FALSE
)
nodes$site <- nodes$name

edges <- data.frame(
  # fmt: skip
  from = c(
    # rail
    "London", "Paris", "Brussels", "Amsterdam", "Paris", "Barcelona",
    "Madrid", "Paris", "Munich", "Vienna", "Berlin", "Prague",
    "Berlin", "Milan", "Munich", "Copenhagen", "Stockholm", "Berlin",
    # road
    "Warsaw", "Milan", "Amsterdam",
    # ferry
    "Dublin", "Oslo",
    # air
    "Athens", "Athens", "Lisbon", "Stockholm", "Athens", "Dublin"
  ),
  # fmt: skip
  to = c(
    # rail
    "Paris", "Brussels", "Amsterdam", "Berlin", "Barcelona", "Madrid",
    "Lisbon", "Munich", "Vienna", "Budapest", "Prague", "Vienna",
    "Warsaw", "Rome", "Milan", "Stockholm", "Oslo", "Copenhagen",
    # road
    "Budapest", "Vienna", "Copenhagen",
    # ferry
    "London", "Copenhagen",
    # air
    "Rome", "Vienna", "London", "Warsaw", "Budapest", "Paris"
  ),
  edge_type = c(
    rep("rail", 18),
    rep("road", 3),
    rep("ferry", 2),
    rep("air", 6)
  ),
  # Made-up connections per week, spread over a wide range so a log scale
  # is useful
  # fmt: skip
  wij = c(
    120, 150, 90, 60, 25, 70,
    15, 40, 80, 55, 45, 50,
    35, 110, 30, 65, 20, 28,
    8, 12, 6,
    14, 7,
    42, 18, 95, 22, 10, 85
  ),
  stringsAsFactors = FALSE
)

example_network_7 <- igraph::graph_from_data_frame(
  edges,
  directed = FALSE,
  vertices = nodes
)
example_network_7 <- example_network_7 |>
  add_centrality_measures() |>
  add_clustering()

usethis::use_data(example_network_7, overwrite = TRUE)
