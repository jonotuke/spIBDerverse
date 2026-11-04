# edges to sf

edges to sf

## Usage

``` r
edges_to_sf(graph, lat = "lat", lon = "long")
```

## Arguments

- graph:

  igraph obj

- lat:

  lat attribute

- lon:

  long attribute

## Value

sf edge object

## Examples

``` r
edges_to_sf(example_network)
#> Simple feature collection with 134 features and 4 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: 138.5869 ymin: -34.92737 xmax: 138.6256 ymax: -34.80483
#> CRS:           NA
#> First 10 features:
#>    from to       wij edge_type                       geometry
#> 1     1  4 0.3212518         C LINESTRING (138.6196 -34.80...
#> 2     1  5 0.2897919         B LINESTRING (138.6196 -34.80...
#> 3     1  6 0.2363979         A LINESTRING (138.6196 -34.80...
#> 4     1  9 0.3855643         C LINESTRING (138.6196 -34.80...
#> 5     1 14 0.3415299         A LINESTRING (138.6196 -34.80...
#> 6     1 18 0.9767435         A LINESTRING (138.6196 -34.80...
#> 7     1 19 0.1005529         C LINESTRING (138.6196 -34.80...
#> 8     1 28 0.1348123         C LINESTRING (138.6196 -34.80...
#> 9     1 30 0.8850077         B LINESTRING (138.6196 -34.80...
#> 10    1 32 0.6536263         C LINESTRING (138.6196 -34.80...
```
