test_that("clean-models works", {
  expect_equal(
    clean_models("network ~ edges"),
    "null model"
  )
  expect_equal(
    clean_models("network ~ edges + nodemix('site')"),
    "nodemix(site)"
  )
  expect_equal(
    clean_models("network ~ edges + nodemix('genetic_sex')"),
    "nodemix(genetic_sex)"
  )
  expect_equal(
    clean_models(
      "network ~ edges + nodemix('site') + nodemix('genetic_sex')"
    ),
    "nodemix(site)+nodemix(genetic_sex)"
  )
  expect_equal(
    clean_models("network ~ edges + absdiff('A')"),
    "diff(A)"
  )
  expect_equal(
    clean_models("network ~ edges + nodecov('A')"),
    "sum(A)"
  )
  expect_equal(
    clean_models("network ~ edges + nodematch('A', diff = TRUE)"),
    "nodediff(A)"
  )
})

test_that("convert works", {
  expect_error(convert_to_network(list()))
  node_attr <- convert_to_network(example_network_6) |>
    network::list.vertex.attributes()
  expect_true(
    "Genetic Sex" %in% node_attr
  )
})

test_that("ergm_emmeans args", {
  net <- example_network_2 %>%
    intergraph::asNetwork()
  ergm_model <- ergm::ergm(
    net ~ edges +
      nodemix("site")
  ) |>
    suppressMessages() |>
    suppressWarnings()
  expect_error(
    ergm_emmeans(ergm_model = ergm_model, term_string = "site")
  )

  net <- example_network %>%
    intergraph::asNetwork()
  ergm_model <- suppressMessages(ergm::ergm(
    net ~ edges +
      nodematch("genetic_sex") +
      nodecov('lat') +
      nodematch("site", diff = TRUE)
  ))
  expect_error(
    ergm_emmeans(
      ergm_model = ergm_model,
      term_string = "bob"
    )
  )

  ergm_model <- suppressMessages(ergm::ergm(
    net ~ edges +
      nodematch("genetic_sex") +
      nodecov('lat')
  ))
  expect_error(
    ergm_emmeans(
      ergm_model = ergm_model,
      term_string = "site"
    )
  )
  expect_error(
    ergm_emmeans(
      ergm_model = ergm_model,
      term_string = "lat"
    )
  )
})
