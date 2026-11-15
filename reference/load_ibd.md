# Load an IBD network

Load an IBD network

## Usage

``` r
load_ibd(
  ibd_file,
  meta_file,
  ibd_co = c(0, 2, 1, 0),
  frac_co = 0.7,
  crawl_length = 2L
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

- crawl_length:

  classifies nodes as seed, in crawl length of outside of crawl length

## Value

igraph object
