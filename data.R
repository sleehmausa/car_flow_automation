# Load necessary libraries
library(readxl)
library(dplyr)
library(tidyr)
library(stringr)
library(purrr)

# Step 1: Define File Path & List Sheets
file_path <- "2024CY HMA OP Carflow 09+03_v1.0_10.08.24_'Official' (distr).xlsx"
sheets <- excel_sheets(file_path)

# Exclude unwanted sheets
excluded_sheets <- c("9-Box Models", "Market Share", "MOS", "Sales Avail%", "DSR")
filtered_sheets <- setdiff(sheets, excluded_sheets)

# Step 2: Extract Model Names Dynamically
model_names <- list()
for (sheet in filtered_sheets) {
  model_name <- read_excel(file_path, sheet = sheet, range = "C4", col_names = FALSE) %>% pull(1)
  model_names[[sheet]] <- model_name
}

# Step 3: Initialize an empty list to store cleaned data
normalized_data_list <- list()

# Step 4: Process **All Sheets Dynamically**
for (sheet in filtered_sheets) {
  
  print(paste("Processing sheet:", sheet))  
  
  # Step 4.1: Read Data from the Current Sheet (Skipping First 3 Rows)
  raw_data <- read_excel(file_path, sheet = sheet, skip = 3)
  
  print(paste("Data loaded without cleaning column names for sheet:", sheet))
  print(head(raw_data))  
  
  # Step 4.2: Identify the Last Valid Column Before the Unwanted Data
  col_na_counts <- colSums(is.na(raw_data))  # Count NA values per column
  empty_col_indices <- which(col_na_counts == nrow(raw_data))  # Find fully empty columns
  
  if (length(empty_col_indices) >= 2) {
    last_valid_col <- empty_col_indices[1] - 1  # Get the column before the first empty column
    raw_data <- raw_data[, 1:last_valid_col]  # Keep only valid columns
  }
  
  print(paste("Unwanted columns removed for sheet:", sheet))
  print(head(raw_data))  
  
  # Step 4.3: Rename Columns & Fill Down Merged Values
  colnames(raw_data)[1] <- "Category"
  colnames(raw_data)[2] <- "Subcategory"  # Assign the second column as "Subcategory"
  
  raw_data <- raw_data %>%
    fill(Category, .direction = "down") %>%
    fill(Subcategory, .direction = "down")  # Ensure all subcategories are filled down

  
  print(paste("First two columns renamed to 'Category' and 'Subcategory', merged values filled for sheet:", sheet))
  print(head(raw_data))  
  
  # Step 4.4: Convert Wide Format to Long Format Safely
  tidy_data <- raw_data %>%
    mutate(across(-c(Category, Subcategory), as.character)) %>%  
    pivot_longer(cols = -c(Category, Subcategory), names_to = "Month", values_to = "Value") %>%
    mutate(Value = as.numeric(Value))  
  
  print(paste("Converted to long format for sheet:", sheet))
  print(head(tidy_data))  
  
  # Step 4.5: Add Model Name (Extracted from C4)
  tidy_data <- tidy_data %>%
    mutate(Model = model_names[[sheet]])
  print(paste("Model name added for sheet:", sheet))
  print(head(tidy_data))  
  
  # Step 4.6: Add Sheet Name for Tracking
  tidy_data <- tidy_data %>%
    mutate(Sheet_Name = sheet)
  print(paste("Sheet name added for tracking:", sheet))
  print(head(tidy_data))  
  
  # Step 5: Store Cleaned Data for This Sheet
  normalized_data_list[[sheet]] <- tidy_data
}

# Step 6: Combine All Sheets into a Single Dataset (AFTER All Sheets Are Processed)
final_normalized_data <- bind_rows(normalized_data_list)

# Print first few rows of the final dataset
print("Final combined dataset:")
print(head(final_normalized_data))


### **🔹 Additional Step: Clean & Format Numeric Values**
# Function to clean and format numeric values
clean_numeric_values <- function(value) {
  if (is.na(value)) return(NA)  # Skip NA values
  value <- as.character(value)  # Ensure it's a character for processing
  value <- str_replace_all(value, "[^0-9.-]", "")  # Remove non-numeric characters
  value <- suppressWarnings(as.numeric(value))  # Convert back to numeric safely
  return(value)
}

# Function to identify and correctly format percentage values while preserving decimals
clean_percentage_values <- function(value) {
  if (is.na(value)) return(NA)  # Skip NA values
  
  value <- as.character(value)  # Ensure it's a character
  if (!is.na(value) && str_detect(value, "%")) {  # If it contains a percentage
    value <- str_replace_all(value, "[^0-9.-]", "")  # Remove '%' and other characters
    value <- suppressWarnings(as.numeric(value) / 100)  # Convert to decimal format
  } else {
    value <- clean_numeric_values(value)  # Otherwise, clean normally
  }
  return(value)
}

# Ensure 'Value' exists and apply cleaning functions while preserving decimal format
if ("Value" %in% colnames(final_normalized_data)) {
  final_normalized_data <- final_normalized_data %>%
    mutate(Value = map_dbl(Value, ~ ifelse(is.na(.x), NA_real_, clean_percentage_values(.x)))) %>%
    mutate(Value = round(Value, 1))  # Ensure 1 decimal place
} else {
  print("ERROR: 'Value' column not found in final_normalized_data!")
}

# Print first few rows to verify
print("Final dataset with properly formatted numeric values (1 decimal place):")
print(head(final_normalized_data))

