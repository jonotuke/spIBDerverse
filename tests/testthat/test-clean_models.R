test_that("clean-models works", {
  expect_equal(
    clean_models("network ~ edges"),
    "edges"
  )
  expect_equal(
    clean_models("network ~ edges + nodemix('site')"),
    "edges|NM(site)"
  )
  expect_equal(
    clean_models("network ~ edges + nodemix('genetic_sex')"),
    "edges|NM(genetic_sex)"
  )
  expect_equal(
    clean_models(
      "network ~ edges + nodemix('site') + nodemix('genetic_sex')"
    ),
    "edges|NM(site)|NM(genetic_sex)"
  )
})
