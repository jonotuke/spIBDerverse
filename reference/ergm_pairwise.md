# Get pairwise differences for a categorical predictor in an ergm model

Get pairwise differences for a categorical predictor in an ergm model

## Usage

``` r
ergm_pairwise(ergm_model, term_string, max_cells = 50)
```

## Arguments

- ergm_model:

  fitted ermg model

- term_string:

  pred to perform pairwise on

- max_cells:

  limit on number of comparisons

## Value

pairwise tibble
