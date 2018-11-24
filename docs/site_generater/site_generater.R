library(tidyverse)
setwd("/home/agricolamz/work/materials/2018.11.24-25_PublicData_hakathon/8")
df <- read_csv("site_generater/for_site_generater.csv")
part_1 <- read_lines("site_generater/part_1.txt")
part_2 <- read_lines("site_generater/part_2.txt")
part_3 <- read_lines("site_generater/part_3.txt")

sapply(1:nrow(df), function(id){
  result <- c(
    part_1,
    paste0('selected <- "', df$title[id], '"'),
    paste0('selected_t <- "', df$selected[id], '"'),
    "```\n",
    paste0(
      "```{r}\ns_year <- ",
      df$year[id],
      "\n```\n### **",
      paste0("[", 2010:2017, "](", df$page[id], "_", 2010:2017, ".html)", collapse = " "),
      "**\n",
      paste0(part_2, collapse = "\n"))
  )
  write_lines(result, paste0(df$page[id], "_", df$year[id], ".Rmd"))
})



rmarkdown::render_site()
