# permutation-dunn-tests

``` r

library(spIBDerverse)
```

First we note that most of the calculations do not change after
permuation.

The Dunn statistic for each pair of groups, $`i`$, and $`j`$

``` math
z = \frac{\bar{R}_i - \bar{R}_j}{\sigma_{ij}},
```

and

``` math
\sigma_{ij} = \sqrt{
  \left(
    \frac{N(N+1)}{12}
  \right)
  \left(
    \frac{1}{n_i} + \frac{1}{n_j}
  \right)
}
```

where

- $`N`$ is the total number of observations,
- $`n_i`$ is the number of observations in group $`i`$,
- $`\bar{R}_i`$ is the mean rank of group $`i`$.

For ties, we adjust this to

``` math
\sigma_{ij} = \sqrt{
  \left(
    \frac{N(N+1)}{12} - \frac{\sum (t^3 - t)}{12(N-1)}
  \right)
  \left(
    \frac{1}{n_i} + \frac{1}{n_j}
  \right)
}
```

where $`t`$ is the number of observations for a given tie.

The following code set us the stuff we need. Of note is $`W`$. $`W`$ is
an $`N \times k`$ matrix.

- Row = observation,
- Column = group.

Entry (obs, g) is $`1/n_g`$ if that observation is in group g, otherwise
0.

``` r

dunn_setup <- function(y, group) {
  # Remove missing
  ok <- !is.na(y) & !is.na(group)
  y <- y[ok]
  g <- droplevels(factor(group[ok]))

  N <- length(y)
  r <- rank(y)
  t <- table(y)
  s2 <- N * (N + 1) / 12 - sum(t^3 - t) / (12 * (N - 1))
  k <- nlevels(g)
  n <- tabulate(g, k)
  W <- outer(as.integer(g), seq_len(k), "==") / rep(n, each = N)

  idx <- combn(k, 2)
  list(
    r = r,
    W = W,
    i1 = idx[1, ],
    i2 = idx[2, ],
    denom = sqrt(s2 * (1 / n[idx[1, ]] + 1 / n[idx[2, ]])),
    pairs = paste(levels(g)[idx[1, ]], levels(g)[idx[2, ]], sep = " - ")
  )
}
set.seed(1)
n <- 10
df <- tibble::tibble(
  y = c(
    sample(1:5, size = n, replace = TRUE),
    sample(3:8, size = n, replace = TRUE),
    sample(7:10, size = n, replace = TRUE)
  ),
  group = rep(LETTERS[1:3], each = 10)
)
DS <- dunn_setup(df$y, df$group)
DS |> print()
#> $r
#>  [1]  2.0 12.0  2.0  4.5 14.0  8.0  4.5  8.0  8.0  2.0 18.5 18.5 12.0 25.5 25.5
#> [16] 12.0  8.0 18.5 18.5  8.0 18.5 25.5 18.5 18.5 25.5 25.5 25.5 18.5 30.0 29.0
#> 
#> $W
#>       [,1] [,2] [,3]
#>  [1,]  0.1  0.0  0.0
#>  [2,]  0.1  0.0  0.0
#>  [3,]  0.1  0.0  0.0
#>  [4,]  0.1  0.0  0.0
#>  [5,]  0.1  0.0  0.0
#>  [6,]  0.1  0.0  0.0
#>  [7,]  0.1  0.0  0.0
#>  [8,]  0.1  0.0  0.0
#>  [9,]  0.1  0.0  0.0
#> [10,]  0.1  0.0  0.0
#> [11,]  0.0  0.1  0.0
#> [12,]  0.0  0.1  0.0
#> [13,]  0.0  0.1  0.0
#> [14,]  0.0  0.1  0.0
#> [15,]  0.0  0.1  0.0
#> [16,]  0.0  0.1  0.0
#> [17,]  0.0  0.1  0.0
#> [18,]  0.0  0.1  0.0
#> [19,]  0.0  0.1  0.0
#> [20,]  0.0  0.1  0.0
#> [21,]  0.0  0.0  0.1
#> [22,]  0.0  0.0  0.1
#> [23,]  0.0  0.0  0.1
#> [24,]  0.0  0.0  0.1
#> [25,]  0.0  0.0  0.1
#> [26,]  0.0  0.0  0.1
#> [27,]  0.0  0.0  0.1
#> [28,]  0.0  0.0  0.1
#> [29,]  0.0  0.0  0.1
#> [30,]  0.0  0.0  0.1
#> 
#> $i1
#> [1] 1 1 2
#> 
#> $i2
#> [1] 2 3 3
#> 
#> $denom
#> [1] 3.871648 3.871648 3.871648
#> 
#> $pairs
#> [1] "A - B" "A - C" "B - C"
```

So for each permutation, we can get the $`z`$ statistic using matrix
multiplication.

`crossprod(W, r)` computes $`W^Tr`$. Each group’s column multiplies the
rank vector and sums, which gives (sum of that group’s ranks) / $`n_g`$.
That is the group’s mean rank. So one multiply gives all k mean ranks.
If we pass multiple ranks, we get multiple $`z`$ for each comparison

``` r

# ---- z for one rank vector, or for a N x B matrix of permuted ranks ----
dunn_z <- function(s, R = s$r) {
  m <- crossprod(s$W, R)
  (m[s$i1, , drop = FALSE] - m[s$i2, , drop = FALSE]) / s$denom
}
dunn_z(DS, DS$r)
#>           [,1]
#> [1,] -2.582880
#> [2,] -4.390895
#> [3,] -1.808016
dunn_z(DS, cbind(DS$r, sample(DS$r)))
#>           [,1]        [,2]
#> [1,] -2.582880 -0.07748639
#> [2,] -4.390895  0.00000000
#> [3,] -1.808016  0.07748639
```

Now we wrap this in a perm test

``` r

dunn_perm <- function(y, group, B = 10000, chunk = 2000) {
  s <- dunn_setup(y, group)
  z_obs <- drop(dunn_z(s))
  a_obs <- abs(z_obs)

  ge_pair <- numeric(length(z_obs)) # per-pair exceedances
  ge_max <- numeric(length(z_obs)) # max-|z| exceedances (FWER-adjusted)
  done <- 0
  while (done < B) {
    b <- min(chunk, B - done)
    # b lots of sample, stacked as cols
    R <- vapply(
      seq_len(b),
      function(i) sample(s$r),
      numeric(length(s$r))
    )
    az <- abs(dunn_z(s, R))
    ge_pair <- ge_pair + rowSums(az >= a_obs)
    done <- done + b
  }

  data.frame(
    pair = s$pairs,
    z = z_obs,
    p_perm = (ge_pair + 1) / (B + 1)
  )
}

# Example
set.seed(1)
dat <- data.frame(
  y = c(rnorm(10), rnorm(10, 1), rnorm(10, 2)),
  group = rep(c("a", "b", "c"), each = 10)
)
dunn_perm(dat$y, dat$group, B = 10000)
#>    pair         z     p_perm
#> 1 a - b -2.133602 0.03059694
#> 2 a - c -3.352803 0.00029997
#> 3 b - c -1.219201 0.21787821
```
