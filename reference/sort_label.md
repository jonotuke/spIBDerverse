# sort labels

Takes two labels and sorts them so for example A and B becomes A-B, and
B and A becomes A-B. This means that you can find duplicate edges in an
undirected network as they will have the same label

## Usage

``` r
sort_label(label1, label2)
```

## Arguments

- label1:

  first label

- label2:

  second label

## Value

label of form first-second

## Examples

``` r
sort_label("A", "B")
#> [1] "A-B"
sort_label("B", "A")
#> [1] "A-B"
```
