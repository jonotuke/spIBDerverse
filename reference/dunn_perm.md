# Performs a permuation test for Kruskal Wallis and Dunn test

Performs a permuation test for Kruskal Wallis and Dunn test

## Usage

``` r
dunn_perm(y, group, B = 10000, chunk = 2000)
```

## Arguments

- y:

  outcome var

- group:

  group var

- B:

  number of sims

- chunk:

  chunk size for sims

## Value

a named list with Dunn results and KW results

## Examples

``` r
dunn_perm(y = rnorm(30), group = rep(LETTERS[1:3], each = 10))
#> $dunn
#> # A tibble: 3 × 3
#>   pair       z dunn_pv
#>   <chr>  <dbl>   <dbl>
#> 1 A - B -0.813   0.422
#> 2 A - C -0.330   0.737
#> 3 B - C  0.483   0.628
#> 
#> $kw
#> # A tibble: 1 × 2
#>       H KW_pv
#>   <dbl> <dbl>
#> 1 0.668 0.722
#> 
```
