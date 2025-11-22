# Plot homophily

Plot homophily

## Usage

``` r
plot_homophily(RM, g = NULL)
```

## Arguments

- RM:

  Ringbauer tibble

- g:

  IBD network

## Value

Plot of homophily density

## Examples

``` r
get_ringbauer_measures(example_network, "site") |> plot_homophily()
```
