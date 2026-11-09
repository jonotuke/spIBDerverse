# Example network of 20 European cities

A small undirected igraph network of 20 European capitals and major
cities, with made-up transport links between them. Useful for trying out
[`plot_staticmap()`](https://jonotuke.github.io/spIBDerverse/reference/plot_staticmap.md)
at a continental scale.

## Usage

``` r
example_network_7
```

## Format

An igraph object with 20 vertices and 29 edges.

Vertex attributes:

- name, site:

  City name.

- country:

  Country the city is in.

- region:

  Broad region: "West", "South", "Central", "East" or "North".

- lat, long:

  Latitude and longitude in decimal degrees.

- population:

  Approximate city-proper population, in millions.

Edge attributes:

- edge_type:

  Type of link: "rail", "road", "ferry" or "air".

- weight:

  Made-up number of connections per week.

## Source

Coordinates and populations are approximate; links and weights are
invented for illustration. See `data-raw/europe_network.R`.

## Examples

``` r
igraph::vertex_attr(example_network_7, "site")
#>  [1] "London"     "Paris"      "Amsterdam"  "Brussels"   "Dublin"    
#>  [6] "Madrid"     "Lisbon"     "Barcelona"  "Rome"       "Milan"     
#> [11] "Athens"     "Berlin"     "Munich"     "Vienna"     "Prague"    
#> [16] "Warsaw"     "Budapest"   "Copenhagen" "Stockholm"  "Oslo"      
```
