function(
  ergm.list,
  form_v,
  ang = 35,
  plotmax = 20,
  tsize = 12,
  printRes = F,
  allowInf = T
) {
  bic_inf <- lapply(ergm.list, coef) %>%
    lapply(is.infinite) %>%
    lapply(any) %>%
    unlist() %>%
    ifelse(Inf, 1)

  if (allowInf) {
    bic_inf <- rep(1, length(bic_inf))
  }

  bic_v <- lapply(ergm.list, BIC) %>% unlist()
  coefs_v <- lapply(ergm.list, function(x) {
    return(length(x$coefficients))
  }) %>%
    unlist()
  bic_tib <- tibble(BIC = bic_v * bic_inf, n = coefs_v, call = form_v) %>%
    dplyr::filter(!is.infinite(BIC)) %>%
    dplyr::arrange(BIC) %>%
    dplyr::slice(1:plotmax) %>%
    dplyr::arrange(n) %>%
    dplyr::mutate(xrel = 1:n())

  rect_tib <- bic_tib %>%
    dplyr::group_by(n) %>%
    dplyr::summarise(xmin = min(xrel) - 0.5, xmax = max(xrel) + 0.5)

  outplot <- bic_tib %>%
    dplyr::mutate(best = BIC == min(BIC)) %>%
    ggplot(aes(x = xrel, y = BIC, group = 1)) +
    theme_bw() +
    geom_rect(
      inherit.aes = F,
      data = rect_tib,
      aes(ymin = -Inf, ymax = Inf, xmin = xmin, xmax = xmax, alpha = (n))
    ) +
    geom_line(linetype = 'dashed') +
    geom_point(pch = 19, size = 6) +
    geom_text(aes(label = n), col = 'white') +
    geom_point(
      data = bic_tib %>% dplyr::filter(BIC == min(BIC)),
      pch = 19,
      size = 5,
      col = 'red'
    ) +
    geom_text(
      data = bic_tib %>% dplyr::filter(BIC == min(BIC)),
      aes(label = n),
      col = 'black'
    ) +
    scale_x_continuous(
      breaks = bic_tib$xrel,
      labels = bic_tib$call,
      expand = c(0, 0)
    ) +
    scale_alpha_continuous(range = c(0.1, 0.5), name = '# coeffcients') +
    theme(
      axis.text.x = element_text(angle = ang, hjust = 1),
      legend.position = 'none',
      axis.text = element_text(size = tsize)
    ) +
    xlab(NULL)
  if (printRes) {
    bic_tib %>%
      dplyr::arrange(BIC) %>%
      base::print(n = 1e4)
  }
  return(outplot)
}
