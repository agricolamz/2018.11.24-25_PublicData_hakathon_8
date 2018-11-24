setwd("/home/agricolamz/work/materials/2018.11.24-25_PublicData_hakathon/8")
library(tidyverse)

df <- read_csv("overall_dataset.csv")
  

df %>% 
  ggplot(aes(region_name, sum_mln, fill = gov_support_type))+
  geom_col()+
#  scale_y_log10()+
  coord_flip()+
  facet_wrap(~year, scales = "free")
# read shape file ---------------------------------------------------------
library(sf); library(leaflet)

ru <- geojsonio::geojson_read("russia.geojson", 
                              what = "sp")
contracts %>% 
  filter(year == 2017) %>% 
  group_by(region_code, region_name) %>% 
  summarise(sum_mln = sum(sum_mln)) %>% 
  ungroup() %>% 
  mutate(ratio = sum_mln/sum(sum_mln)) ->
  df

ru@data %>% 
  left_join(df) ->
  ru@data

pal <- colorNumeric(c("white", "red"), NULL)

leaflet(ru) %>% 
  addPolygons(stroke = TRUE,
              color = "black",
              weight = 1,
              smoothFactor = 0.3, 
              fillOpacity = 1,
              fillColor = ~pal(ru@data$ratio),
              label = ~paste0(ru@data$NAME_1,
                              ": ", 
                              round(ru@data$ratio*100, 4), "%")) %>%
  addLegend(pal = pal, 
            values = ru@data$ratio*100,
            labFormat = labelFormat(suffix = "%"))

