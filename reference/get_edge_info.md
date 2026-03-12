# Get network edge information

Get network edge information

## Usage

``` r
get_edge_info(g)
```

## Arguments

- g:

  ibd network object

## Value

tibble of node information

## Examples

``` r
get_edge_info(example_network_2)
#> # A tibble: 2,103 × 14
#>    from   to     frac_gp1 frac_gp2 max_ibd sum_ibd_8 n_ibd_8 sum_ibd_12 n_ibd_12
#>    <chr>  <chr>     <dbl>    <dbl>   <dbl>     <dbl>   <dbl>      <dbl>    <dbl>
#>  1 KUP007 KUP023    0.893    0.896    284.     3403.      22      3403.       22
#>  2 RKC013 RKC029    0.820    0.884    284.     3399.      23      3399.       23
#>  3 RKC031 RKF238    0.891    0.913    269.     3394.      22      3394.       22
#>  4 RKF195 RKF196    0.876    0.874    284.     3390.      22      3390.       22
#>  5 RKC020 RKF142    0.884    0.913    284.     3389.      23      3389.       23
#>  6 KFJ018 KFJ017    0.899    0.919    284.     3387.      22      3387.       22
#>  7 RKF182 RKF148    0.856    0.884    269.     3383.      23      3383.       23
#>  8 RKF142 RKF002    0.821    0.884    280.     3382.      21      3382.       21
#>  9 RKF162 RKF118    0.859    0.870    284.     3376.      22      3376.       22
#> 10 RKC011 RKC029    0.820    0.878    282.     3370.      27      3370.       27
#> # ℹ 2,093 more rows
#> # ℹ 5 more variables: sum_ibd_16 <dbl>, n_ibd_16 <dbl>, sum_ibd_20 <dbl>,
#> #   n_ibd_20 <dbl>, wij <dbl>
```
