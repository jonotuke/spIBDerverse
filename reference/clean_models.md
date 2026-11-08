# clean model names

clean model names

## Usage

``` r
clean_models(x)
```

## Arguments

- x:

  vector of ergm model names

## Value

cleaned vector

## Examples

``` r
ergms <- example_network |>
  get_ergms(c("site", "genetic_sex"), c("nodemix", "nodematch")) |>
  purrr::map(broom::glance) |>
  purrr::list_rbind(names_to = "model")
clean_models(ergms$model) |> print()
#> [1] "nodemix(site)"                       
#> [2] "nodematch(genetic_sex)"              
#> [3] "nodemix(site)+nodematch(genetic_sex)"
#> [4] "null model"                          
```
