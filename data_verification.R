final_normalized_data %>%
  filter(Sheet_Name == "CF (HMA)") %>% 
  filter(Category == "Production, Stock & Fleet") %>% 
  filter(Subcategory == "Retail TCG TIV") %>% 
  filter(str_detect(Month, "Feb \\(A\\)")) 

