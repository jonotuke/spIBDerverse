# Get network node information

Get network node information

## Usage

``` r
get_node_info(g)
```

## Arguments

- g:

  ibd network object

## Value

tibble of node information

## Examples

``` r
get_node_info(example_network)
#> # A tibble: 40 × 9
#>    genetic_sex site   name .degree .closeness .betweenness .eigencentrality
#>    <chr>       <chr> <int>   <dbl>      <dbl>        <dbl>            <dbl>
#>  1 M           A         1       9    0.0122          72.5           0.662 
#>  2 F           A         2       6    0.0119          46.4           0.378 
#>  3 F           B         3       6    0.0105          64.2           0.254 
#>  4 F           B         4       8    0.0112          56.4           0.398 
#>  5 M           C         5       9    0.0123          74.2           0.781 
#>  6 F           A         6       1    0.00752          0             0.0376
#>  7 M           C         7       7    0.0115          28.4           0.763 
#>  8 F           A         8       2    0.00909          0             0.118 
#>  9 M           C         9      10    0.0132          59.0           1     
#> 10 M           B        10       5    0.0116          26.3           0.446 
#> # ℹ 30 more rows
#> # ℹ 2 more variables: lat <dbl>, long <dbl>
```
