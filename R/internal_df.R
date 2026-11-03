internal_df <- function() {
  tibble::tribble(
    ~name                  , ~full_name                    , ~type        ,
    ".degree"              , "Degree"                      , "centrality" ,
    ".closeness"           , "Closeness"                   , "centrality" ,
    ".betweenness"         , "Betweenness"                 , "centrality" ,
    ".eigencentrality"     , "Eigen-centrality"            , "centrality" ,
    ".louvain"             , "Louvain"                     , "clustering" ,
    ".louvain_weighted"    , "Weighted Louvain"            , "clustering" ,
    ".eigen"               , "Leading eigenvalue"          , "clustering" ,
    ".eigen_weighted"      , "Weighted leading eigenvalue" , "clustering" ,
    ".label_prop"          , "Label propagation"           , "clustering" ,
    ".label_prop_weighted" , "Weighted label propagation"  , "clustering"
  )
}
