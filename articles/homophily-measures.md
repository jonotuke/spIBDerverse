# Homophily measures

``` r

library(spIBDerverse)
```

``` r

library(igraph)
#> 
#> Attaching package: 'igraph'
#> The following objects are masked from 'package:stats':
#> 
#>     decompose, spectrum
#> The following object is masked from 'package:base':
#> 
#>     union
```

In this vignette, we look at a method to identify edges that are more
prominent than expected if the nodes attributes had not effect on the
probability of an edge.

Consider a network with $`N`$ nodes and $`E`$ edges. From this, we get
that the probability at two randomly selected nodes have an edge
connected them is

``` math
p_{ij} = \frac{E}{{N \choose 2}}
```

``` r

obs <- example_network |> get_ringbauer_measures("site")
#> Warning in stats::prop.test(x = edge_count$n_edges[i], n =
#> edge_count$n_possible_edges[i], : Chi-squared approximation may be incorrect
```
