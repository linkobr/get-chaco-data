library(here)
library(rvest)
library(tidyverse)

url <- 'http://www.chacoarchive.org/cra/query-the-database/'

page <- read_html(url)

tables <- page |> html_elements('.btn-list') |> html_attr('href')

# get the number of pages for each table, loop through all the pages, append to the url

num_pages <- read_html("http://www.chacoarchive.org/bibl_database/institutions/list?public=true") |> 
  html_element('.paginate_block.little_larger') |> 
  html_element("strong") |> 
  html_text2() |> 
  str_extract("[[:digit:]]+")

# get the tables 

get_table <- function(x){ 
  # same code as above, reads the html of a page, then grabs the max number of results
  n_rows <- read_html(x) |> 
    html_element('.paginate_block.little_larger') |> 
    html_element("strong") |> 
    html_text2() |> 
    str_extract("[[:digit:]]+")
  # make the max number of results (n_rows) the items per page
  # basically appending "&page=1&items_per_page=68" to the url
}

lapply(tables, get_table) |> unlist()


