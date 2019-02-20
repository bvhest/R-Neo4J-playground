#
# turn data-frame into graph model ready for loading into Neo4j
#
# BvH, 2019-02-20
#
library(tidyverse)

# create df (see https://tibble.tidyverse.org/)
tw <-
  tibble::tribble(
    ~user, ~userID,
    "udenVH", 1,
    "udenVH", 2,
    "1", 2,
    "1", 3,
    "1", 4,
    "2", 5,
    "2", 6,
    "2", "udenVH"
  ) %>%
  dplyr::rename(fromID = user,
                toID = userID)

glimpse(tw)

# save to csv-file
readr::write_csv(tw, path = "./data/raw/twitter_relations.csv")

# use [neo4r](https://github.com/neo4j-rstats/neo4r) as R-Neo4J API.
# turn df into nodes & edges:


# setup neoj4 connection
library(neo4r)
con <- neo4j_api$new(url = "http://localhost:7474", 
                     user = "neo4j", password = "admin")

if (!(con$ping() == 401)) {
#  message("creating connection from R to Neo4j has failed!")
  stop("creating connection from R to Neo4j has failed!")
}
message("you should not see this") # frut... flow gaat door na stop()...

# Create the query that will create the nodes and relationships
on_load_query <- 'MERGE (u1:user { id: csvLine.fromID})
MERGE (u2:user { id: csvLine.toID}) 
MERGE (u1) -[:is_following] -> (u2);'

# load the csv into Neo4j
neo4r::load_csv(url = "./data/raw/twitter_relations.csv", 
                con = con, 
                header = TRUE, 
                periodic_commit = 50, 
                as = "csvLine", 
                on_load = on_load_query)



