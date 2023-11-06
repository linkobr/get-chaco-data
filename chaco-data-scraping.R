library(furrr)
library(here)
library(rvest)
library(tidyverse)

url <- 'http://www.chacoarchive.org/cra/query-the-database/'

page <- read_html(url)

tables <- page |> html_elements('.btn-list') |> html_attr('href')

# running through an example - listing institutions
# num_pages <- read_html("http://www.chacoarchive.org/bibl_database/institutions/list?public=true") |> 
#   html_element('.paginate_block.little_larger') |> 
#   html_element("strong") |> 
#   html_text2() |> 
#   str_extract("[[:digit:]]+")

# get the number of pages for each table, loop through all the pages, append to the url

get_table <- function(x){ 
  # same code as above, reads the html of a page, then grabs the max number of results
  n_rows <- read_html(x) |> 
    html_element('.paginate_block.little_larger') |> 
    html_element("strong") |> 
    html_text2() |> 
    str_extract("[[:digit:]]+")
  
  # make the max number of results (n_rows) the items per page
  # basically appending "&page=1&items_per_page=(n_rows)" to the url
  full_table_url <- paste0(x, "&page=1&items_per_page=", n_rows)
  
  full_table_url |> 
    read_html() |> 
    html_nodes("table") |> 
    pluck(2) |> 
    html_table()
}


# plan(multisession, workers = 8)
# 
# chaco_tables <- future_map(tables, get_table)

als_ceramic_tallies <- get_table(tables[[27]]) |> 
  select(-24) |> 
  rename(
    "Site" = "Site Num",
    "type" = "Ceramic Type",
    "count" = "Frequency"
  ) |> 
  select(Site, type, count)

als_ceramic_types <- als_ceramic_tallies |> 
  pull(var = "Ceramic Type") |> 
  unique()

# ignoring an empty column, general cra notes, and the 
chaco_survey_ceramics <- get_table(tables[[25]]) |> 
  select(-c(55:57)) |> 
  separate_wider_delim(
    Site, 
    delim = ", ", 
    names = c("Site", "Site_Extra"), too_few = "align_start", too_many = "merge") |> 
  select(-Site_Extra) |> 
  pivot_longer(-Site, names_to = "type", values_to = "count")

all_ceramics <- bind_rows(als_ceramic_tallies, chaco_survey_ceramics) |> 
  group_by(Site, type) |>
  summarize(count = sum(count))
  arrange(Site, type)

ceramic_types2 <- wide_tbl |> select(2:15) |> names()

intersect(ceramic_types1, ceramic_types2)
