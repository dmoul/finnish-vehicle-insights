# setup-data-used-vehicle-imports.R


###### Constants

# TODO: add here if needed


###### Prepare data

fname <- "./data/processed/used-vehicle-imports.rds"

if(!file.exists(fname)) {
  d_raw <- read_xlsx("./data/raw/used-vehicle-imports-yksmaah_20240108-022107.xlsx",
                     skip = 2)
  
  dta_tmp <- d_raw |>
    fill(1:2, .direction = "down") |>
    rename(brand = 1,
           model_year = 2,
           power_train = 3) |>
    pivot_longer(cols = `2014`:`2023`,
                 names_to = "import_year",
                 values_to = "n") |>
    filter(n > 0) |>
    mutate(brand = if_else(brand == "Passenger cars total",
                           "All brands total",
                           brand))
  
  dta <- dta_tmp |>
    filter(model_year != "All model years",
           brand != "All brands total",
           power_train != "Total",
           !str_detect(brand, "classvaluenamegrp")
           ) |>
    mutate(brand = str_replace_all(brand, c("BMW I" = "BMW",
                                            "Mercedes-Benz" = "MB",
                                            "Jaguar" = "Jaguar Land Rover",
                                            "Range-Rover" = "Jaguar Land Rover",
                                            "^Land Rover" = "Jaguar Land Rover",
                                            "Volkswagen" = "VW"
    )),
    across(c(model_year, import_year, n), as.numeric)
    ) |>
    mutate(n_brand_model_year = sum(n),
           .by = c(model_year, brand)) |>
    mutate(n_brand_all_years = sum(n),
           .by = brand)
  
  write_rds(dta, fname)
  
  rm(dta_tmp)
  
} else {
  
  dta <- read_rds(fname)
  
}

dta_working_set <- dta |>
  filter(n_brand_all_years > 100,
         power_train != "Total")

dta_by_power_train <- dta_working_set |>
  summarize(count = sum(n),
            .by = c(model_year, power_train)) |>
  mutate(pct = count / sum(count),
         .by = model_year) |>
  mutate(power_train = fct_reorder(power_train, count, sum))

dta_by_brand_power_train <- dta_working_set |>
  summarize(count = sum(n),
            .by = c(model_year, brand, power_train)) |>
  mutate(pct = count / sum(count),
         .by = model_year) |>
  mutate(power_train = fct_reorder(power_train, count, sum))

min_model_year <- min(dta_by_power_train$model_year)
max_model_year <- max(dta_by_power_train$model_year)

model_year_range = glue("{min_model_year}-{max_model_year}")

#n_brands <- length(unique(dta$brand))
n_brands <- dta |>
  count(brand, wt = n)


my_breaks = dta_by_power_train |>
  distinct(model_year) |>
  filter(model_year %% 5 == 0 | model_year == min_model_year | model_year == max_model_year)

my_breaks_five_yearly = dta_by_power_train |>
  distinct(model_year) |>
  filter(model_year %% 5 == 0)
         
###### Get inspection data for model_year comparisons

dta_inspections <- read_rds("./data/processed/vehicle-inspections.rds") |>
  filter(model_year != "All years",
         brand != "All brands",
         model != "All models",
         model_year != "All model years") |>
  mutate(model_year = as.numeric(model_year)) |>
  filter(between(model_year, min_model_year, max_model_year))

dta_inspections_yearly_count <- dta_inspections |>
  count(model_year, wt = inspection_count, name = "inspection_count")
