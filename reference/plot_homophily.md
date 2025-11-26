# Plot homophily

Plot homophily

## Usage

``` r
plot_homophily(RM, show_sign = FALSE, filter_sign = FALSE)
```

## Arguments

- RM:

  Ringbauer tibble

- show_sign:

  boolean on whether to colour by significance

- filter_sign:

  boolean to show only significant edges

## Value

Plot of homophily density

## Examples

``` r
get_ringbauer_measures(example_network, "site") |> plot_homophily()
```
