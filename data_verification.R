final_normalized_data %>%
  filter(Sheet_Name == "CF (Tucson HEV)") %>% 
  filter(Category == "Sales") %>% 
  filter(Subcategory == "Retail Sales") %>% 
  filter(str_detect(Month, "Q3")) 

# Category Subcategory  Month   Value Model      Sheet_Name     
# <chr>    <chr>        <chr>   <dbl> <chr>      <chr>          
#   1 Sales    Retail Sales Q3...66     0 TUCSON HEV CF (Tucson HEV)
# 2 Sales    Retail Sales Q3...71  6194 TUCSON HEV CF (Tucson HEV)
# 3 Sales    Retail Sales Q3...75  6163 TUCSON HEV CF (Tucson HEV)
# 4 Sales    Retail Sales Q3...79  7826 TUCSON HEV CF (Tucson HEV)
# 5 Sales    Retail Sales Q3...83 15509 TUCSON HEV CF (Tucson HEV)