# Load an IBD network

Reads pairwise IBD data and node metadata, keeps pairs that pass the
`frac_gp` quality filter and the IBD segment-count cutoffs, and builds
an undirected igraph object weighted by `sum_ibd_8`.

## Usage

``` r
load_ibd_network(
  ibd_file,
  meta_file,
  ibd_co = c(0, 2, 1, 0),
  frac_co = 0.7,
  filter_on_meta = FALSE
)
```

## Arguments

- ibd_file:

  Path to a TSV or CSV file with pairwise IBD data. Must contain `iid1`,
  `iid2`, `n_ibd_8`, `n_ibd_12`, `n_ibd_16`, `n_ibd_20` and `sum_ibd_8`
  (after
  [`janitor::clean_names()`](https://sfirke.github.io/janitor/reference/clean_names.html)).

- meta_file:

  Path to a TSV or CSV file with node metadata. If there is no `iid`
  column, the first column is used as the node ID. Must contain
  `frac_gp` if the IBD file lacks `frac_gp1` and `frac_gp2`.

- ibd_co:

  Numeric vector of length 4: minimum values of `n_ibd_8`, `n_ibd_12`,
  `n_ibd_16` and `n_ibd_20` required to define an edge.

- frac_co:

  Quality-control cutoff; both nodes of a pair must have
  `frac_gp >= frac_co`. Default is 0.7.

- filter_on_meta:

  If `TRUE`, only keep edges whose two nodes are both present in the
  metadata.

## Value

An undirected igraph object with centrality measures added, or `NULL`
(with a message) if the inputs cannot be read or are invalid.

## Details

Input files can be tab-separated (`.tsv`, `.tab`, `.txt`) or
comma-separated (`.csv`), optionally compressed (e.g. `.csv.gz`). The
format is chosen from the file extension; for any other extension the
delimiter is guessed from the file contents.

## Examples

``` r
ibd_file <- fs::path_package(
  "extdata",
  "example-ibd-data.tsv",
  package = "spIBDerverse"
)
meta_file <- fs::path_package(
  "extdata",
  "example-meta-data.tsv",
  package = "spIBDerverse"
)
load_ibd_network(
  ibd_file,
  meta_file,
  ibd_co = c(0, 2, 1, 0)
)
```
