final_normalized_data %>%
  filter(Sheet_Name == "CF (Tucson HEV)") %>% 
  filter(Category == "Sales") %>% 
  filter(Subcategory == "Retail Sales") %>% 
  filter(str_detect(Month, "Q3")) 

