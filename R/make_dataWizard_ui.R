make_dataWizard_ui <- function(x, id, edge_vars) {
  if (is.null(x)) {
    ui <- NULL
  }
  if (x == "example") {
    ui <- shiny::tagList(
      shiny::selectInput(
        shiny::NS(id, "example_data"),
        label = "Example dataset",
        choices = c(
          "example_network",
          "example_network_2",
          "example_network_3"
        )
      )
    )
  }
  if (x == "ibd") {
    ui <- shiny::tagList(
      shiny::fileInput(
        shiny::NS(id, "ibd_edge_file"),
        "Upload an IBD file (edges)"
      ) |>
        bslib::tooltip(
          "Upload pairwise IBD file. Each line should have two individuals, and how related that pair is. Additional columns can include pairwise information (like geographic distance for example). The first column should be called \"iid1\" and the second column \"iid2\"."
        ),
      shiny::fileInput(
        shiny::NS(id, "ibd_meta_file"),
        "Upload a meta data file (nodes)"
      ) |>
        bslib::tooltip(
          "Upload your meta data for the individuals. This can include any meta data you might like to plot or test. The first column should be called \"iid\"."
        ),
      shiny::checkboxInput(
        shiny::NS(id, "ibd_filter"),
        "Filter edges to just nodes in metafile",
        value = TRUE
      ) |>
        bslib::tooltip(
          "Toggle this off to keep ALL IBD information. Will slow down analyses!"
        ),
      shiny::textInput(
        shiny::NS(id, "ibd_cutoffs"),
        label = "Please enter cutoffs with commas between",
        value = "0,2,1,0"
      ) |>
        bslib::popover(
          "This defines the definition of two individuals being \"connected\". A comma-separated description of the cut-off for the minimum number of blocks of IBD of length >=8cM, >=12cM, >=16cM and >=20cM."
        ),
      shiny::numericInput(
        shiny::NS(id, "ibd_frac_cutoff"),
        label = "Minimum Frac GP",
        value = 0.7
      ) |>
        bslib::popover(
          "Used for quality control. The fraction of genotype likelihoods that had posterior values of >=0.99, indicating high quality imputation. Recommended default is 0.7."
        )
    )
  }
  if (x == "distance") {
    ui <- shiny::tagList(
      shiny::fileInput(
        shiny::NS(id, "dist_edge_file"),
        "Upload an edge file"
      ),
      shiny::fileInput(
        shiny::NS(id, "dist_meta_file"),
        "Upload a meta data file (nodes)"
      )
    )
  }
  if (x == "rds") {
    ui <- shiny::tagList(
      shiny::fileInput(
        shiny::NS(id, "rds_file"),
        "Upload a previous saved network"
      )
    )
  }
  return(ui)
}
