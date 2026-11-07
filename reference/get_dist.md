# Get geodistance for points in network

Get geodistance for points in network

## Usage

``` r
get_dist(g, lat, long)
```

## Arguments

- g:

  igraph object

- lat:

  node attribute that is lat

- long:

  node attribute that is long

## Value

distance matrix in km's

## Examples

``` r
get_dist(example_network, "lat", "long")
```
