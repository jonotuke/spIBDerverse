# Plot homophily

Plot homophily

## Usage

``` r
plot_homophily(RM, p = NULL)
```

## Arguments

- RM:

  Ringbauer tibble

- p:

  nework density

## Value

Plot of homophily density

## Examples

``` r
get_ringbauer_measures(example_network, "site") |> plot_homophily()
```
