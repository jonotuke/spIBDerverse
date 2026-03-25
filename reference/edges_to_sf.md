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
#> Simple feature collection with 99 features and 4 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: 138.5872 ymin: -34.92732 xmax: 138.6235 ymax: -34.80634
#> CRS:           NA
#> First 10 features:
#>    from to       wij edge_type                       geometry
#> 1     1 21 0.4073892         C LINESTRING (138.6163 -34.80...
#> 2     1 26 0.4753938         B LINESTRING (138.6163 -34.80...
#> 3     1 31 0.1535906         C LINESTRING (138.6163 -34.80...
#> 4     1 39 0.5229230         A LINESTRING (138.6163 -34.80...
#> 5     2  3 0.4245830         A LINESTRING (138.6161 -34.80...
#> 6     2 16 0.5748161         B LINESTRING (138.6161 -34.80...
#> 7     2 20 0.3075784         C LINESTRING (138.6161 -34.80...
#> 8     2 31 0.9981113         B LINESTRING (138.6161 -34.80...
#> 9     3  8 0.6680249         C LINESTRING (138.6219 -34.80...
#> 10    3 16 0.8685398         A LINESTRING (138.6219 -34.80...
```
