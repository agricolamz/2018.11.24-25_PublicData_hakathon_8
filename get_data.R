library(tidyverse); library(foreach); library(doParallel)
openngodb <- jsonlite::fromJSON("not_commit/openngodb_dump_07112017.json")


# create an empty df ------------------------------------------------------
data_frame(amount = openngodb$grants[58][[1]]$amount,
           year = lubridate::year(openngodb$grants[58][[1]]$date)) %>% 
  group_by(year) %>% 
  summarise(sum_mln = sum(amount)/1000000) %>% 
  mutate(organisation_name = openngodb$name[58],
         organisation_type_name = openngodb$type[58,]$name,
         organisation_type_code = openngodb$type[58,]$code,
         region_code = openngodb$region[58,]$code,
         region_name = openngodb$region[58,]$name,
         gov_support_type = "grants") -> empty

empty <- empty[FALSE,]


# get contracts -----------------------------------------------------------
system.time({  
  registerDoParallel(7)
  foreach(organisation_n = 1:nrow(openngodb), .combine = rbind) %:% 
    foreach(i = 1:length(openngodb$contracts[organisation_n]), .combine = rbind) %dopar% {
      if(length(openngodb$contracts[organisation_n][[i]]) > 0){
        data_frame(amount = openngodb$contracts[organisation_n][[i]]$amount,
                   year = lubridate::year(openngodb$contracts[organisation_n][[i]]$date)) %>% 
          group_by(year) %>% 
          summarise(sum_mln = sum(amount)/1000000) %>% 
          mutate(organisation_name = openngodb$name[organisation_n],
                 organisation_type_name = openngodb$type[organisation_n,]$name,
                 organisation_type_code = openngodb$type[organisation_n,]$code,
                 region_code = openngodb$region[organisation_n,]$code,
                 region_name = openngodb$region[organisation_n,]$name,
                 gov_support_type = "contracts")
      } else{empty}} %>% 
    write_csv("contracts.csv")
  stopImplicitCluster()
})


# get grants --------------------------------------------------------------
system.time({  
  registerDoParallel(7)
  foreach(organisation_n = 1:nrow(openngodb), .combine = rbind) %:% 
    foreach(i = 1:length(openngodb$grants[organisation_n]), .combine = rbind) %dopar% {
      if(length(openngodb$grants[organisation_n][[i]]) > 0){
        data_frame(amount = openngodb$grants[organisation_n][[i]]$amount,
                   year = lubridate::year(openngodb$grants[organisation_n][[i]]$date)) %>% 
          group_by(year) %>% 
          summarise(sum_mln = sum(amount)/1000000) %>% 
          mutate(organisation_name = openngodb$name[organisation_n],
                 organisation_type_name = openngodb$type[organisation_n,]$name,
                 organisation_type_code = openngodb$type[organisation_n,]$code,
                 region_code = openngodb$region[organisation_n,]$code,
                 region_name = openngodb$region[organisation_n,]$name,
                 gov_support_type = "grants") -> df
      } else{empty}} %>% 
    write_csv("grants.csv")
  stopImplicitCluster()
})


# get subsidies -----------------------------------------------------------
system.time({  
  registerDoParallel(7)
  foreach(organisation_n = 1:nrow(openngodb), .combine = rbind) %:% 
    foreach(i = 1:length(openngodb$subsidies[organisation_n]), .combine = rbind) %dopar% {
      if(length(openngodb$subsidies[organisation_n][[i]]) > 0){
        data_frame(amount = openngodb$subsidies[organisation_n][[i]]$amount,
                   year = lubridate::year(openngodb$subsidies[organisation_n][[i]]$date)) %>% 
          group_by(year) %>% 
          summarise(sum_mln = sum(amount)/1000000) %>% 
          mutate(organisation_name = openngodb$name[organisation_n],
                 organisation_type_name = openngodb$type[organisation_n,]$name,
                 organisation_type_code = openngodb$type[organisation_n,]$code,
                 region_code = openngodb$region[organisation_n,]$code,
                 region_name = openngodb$region[organisation_n,]$name,
                 gov_support_type = "subsidies")
      } else{empty}} %>% 
    write_csv("subsidies.csv")
  stopImplicitCluster()
})

# merged datasets into one ------------------------------------------------
s <- read_csv("subsidies.csv")
g <- read_csv("grants.csv")
c <- read_csv("contracts.csv")

rbind(s, g, c) %>% 
  group_by(year, organisation_name, organisation_type_name, organisation_type_code, region_code, region_name) %>% 
  summarise(sum_mln = sum(sum_mln)) %>% 
  mutate(gov_support_type = "overall") %>%
  rbind.data.frame(rbind(s, g, c)) %>% 
  write_csv("overall_dataset.csv")

