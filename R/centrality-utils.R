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
  checkmate::assert_number(k, lower = 2)
  n <- tabulate(g, k)
  W <- outer(as.integer(g), seq_len(k), "==") / rep(n, each = N)

  idx <- utils::combn(k, 2)
  list(
    r = r,
    W = W,
    n = n,
    s2 = s2,
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
kw_h <- function(s, R = s$r) {
  m <- crossprod(s$W, R)
  N <- length(s$r)
  colSums(s$n * (m - (N + 1) / 2)^2) / s$s2
}
dunn_perm <- function(y, group, B = 10000, chunk = 2000) {
  s <- dunn_setup(y, group)
  z_obs <- drop(dunn_z(s))
  a_obs <- abs(z_obs)
  h_obs <- kw_h(s)

  ge_pair <- numeric(length(z_obs))
  ge_h <- 0
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
    ge_h <- ge_h + sum(kw_h(s, R) >= h_obs - 1e-8 * h_obs)
    done <- done + b
  }

  res <- list()
  res[["dunn"]] <- tibble::tibble(
    pair = s$pairs,
    z = z_obs,
    dunn_pv = (ge_pair + 1) / (B + 1)
  )
  res[["kw"]] <- tibble::tibble(
    H = h_obs,
    KW_pv = (ge_h + 1) / (B + 1)
  )
  res
}

if (sys.nframe() == 5) {
  set.seed(1)
  n <- 10
  df <- data.frame(
    y = c(
      sample(1:4, size = n, replace = TRUE),
      sample(3:7, size = n, replace = TRUE),
      sample(6:10, size = n, replace = TRUE)
    ),
    grp = rep(LETTERS[1:3], each = n)
  )
  ds <- dunn_setup(df$y, df$grp)
  print(dunn_z(ds))
  print(kw_h(ds))
  dunn_perm(df$y, df$grp) |> print()
  rstatix::kruskal_test(df, y ~ grp) |> print()
  rstatix::dunn_test(df, y ~ grp) |> print()
}
