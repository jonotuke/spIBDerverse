# Plot Ringbauer

Takes the Ringbauer matrix and plots it. This was based on the Ringbauer
paper and also the heatmap.2 function from gplots

## Usage

``` r
plot_ringbauer(RM, label_margin = 2, label_size = 3)
```

## Arguments

- RM:

  a Ringbauer matrix object

- label_margin:

  the margin around the heatmap - adjust to get enough space for labels

- label_size:

  adjust label and axis text

## Value

Ringbauer plot

## Examples

``` r
get_ringbauer_measures(example_network, "site") |>
convert_ringbauer_measures() |>
plot_ringbauer(label_margin = 10, label_size = 3)
```
