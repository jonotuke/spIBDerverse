utils::globalVariables(
  c("AIC")
)
get_ergm_bic <- function(ergms) {
  ergms |>
    purrr::map(broom::glance) |>
    purrr::list_rbind(names_to = "Model") |>
    dplyr::arrange(BIC) |>
    dplyr::select(Model, AIC, BIC)
}
# pacman::p_load(conflicted, tidyverse, targets, ergm)
# ergms <- get_ergms(
#   example_network,
#   preds = c("site", "genetic_sex")
# )
# ergms |> get_ergm_bic()
