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
