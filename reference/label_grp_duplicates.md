# label_grp_duplicates

label_grp_duplicates

## Usage

``` r
label_grp_duplicates(df, grp1, grp2)
```

## Arguments

- df:

  data frame with two group columns

- grp1:

  name of first group col

- grp2:

  name of second group col

## Value

df with extra col called .grp_label that has can be used to remove
duplicated rows

## Examples

``` r
df <- tidyr::expand_grid(
  grp1 = LETTERS[1:3],
  grp2 = LETTERS[1:3]
) |>
dplyr::mutate(
  value = 1:9
)
label_grp_duplicates(df, grp1, grp2)
#> # A tibble: 9 × 4
#> # Rowwise: 
#>   grp1  grp2  value .grp_label
#>   <chr> <chr> <int> <chr>     
#> 1 A     A         1 A-A       
#> 2 A     B         2 A-B       
#> 3 A     C         3 A-C       
#> 4 B     A         4 A-B       
#> 5 B     B         5 B-B       
#> 6 B     C         6 B-C       
#> 7 C     A         7 A-C       
#> 8 C     B         8 B-C       
#> 9 C     C         9 C-C       
```
