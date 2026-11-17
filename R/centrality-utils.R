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

  idx <- utils::combn(k, 2)
  list(
    r = r,
    W = W,
    i1 = idx[1, ],
    i2 = idx[2, ],
    denom = sqrt(s2 * (1 / n[idx[1, ]] + 1 / n[idx[2, ]])),
    pairs = paste(levels(g)[idx[1, ]], levels(g)[idx[2, ]], sep = " - ")
  )
}
dunn_z <- function(s, R = s$r) {
  m <- crossprod(s$W, R)
  (m[s$i1, , drop = FALSE] - m[s$i2, , drop = FALSE]) / s$denom
}
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
