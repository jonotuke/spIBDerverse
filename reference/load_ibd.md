# Load an IBD network

Load an IBD network

## Usage

``` r
load_ibd(
  ibd_file,
  meta_file,
  ibd_co = c(0, 2, 1, 0),
  frac_co = 0.7,
  filter_on_meta = FALSE
)
```

## Arguments

- ibd_file:

  ibd file

- meta_file:

  meta file

- ibd_co:

  cutoffs for edges

- frac_co:

  quality cutoff

- filter_on_meta:

  boolean - only keep edges whose nodes are in meta

## Value

igraph object
