# setup-data-vehicles-on-road-snapshot.R


###### Constants

# TODO: add here if needed


###### Prepare data

fname <- "./data/processed/vehicle-snapshot.rds"

if(!file.exists(fname)) {
  d_raw <- read_xlsx("./data/raw/kanta_010_20231218-231953.xlsx",
                     range = "A3:RN2125") # starting in 2001; if starting in 1980: "A3:AHR2125"
  
  dta_tmp <- d_raw |>
    fill(1, .direction = "down") |>
    rename(area = 1,
           brand = 2)
  
  x1 <- names(dta_tmp)
  x2 <- dta_tmp[1, ]
  x2t <- t(x2) |>
    as.data.frame() |>
    rownames_to_column() |>
    set_names(c("col1", "power_train")) |>
    mutate(col1 = ifelse(str_detect(col1, "^[.]"),
                         NA_character_,
                         col1)
    ) |>
    fill(col1, .direction = "down") |>
    mutate(my_col_name = paste0(power_train, "-", col1),
           my_col_name = str_remove(my_col_name, "^NA-"))
  
  names(dta_tmp) <- x2t$my_col_name
  dta_tmp[1, ] <- NA
  
  dta <- dta_tmp |>
    filter(area == "MAINLAND FINLAND",
           brand != "Passenger cars total") |>
    select(-ends_with("-Total")) %>%
    pivot_longer(cols = 3:ncol(.)) |>
    rename(power_train = name) |>
    mutate(power_train = str_replace_all(power_train, c("Electricity" = "Electric") #,
                                                        #"^Electric" = "Battery Electric")
                                         ),
           power_train = str_replace_all(power_train, c("^Electric" = "Battery Electric")),
           model_year = as.numeric(str_extract(power_train, "[0-9]+$")),
           power_train = str_remove(power_train, "[-][0-9]+$"),
           value = as.numeric(value)) |>
    filter(power_train != "Total",
           !str_detect(brand, "Campervans")) |>
    mutate(brand = str_replace_all(brand, c("BMW I" = "BMW",
                                            "Mercedes-Benz" = "MB",
                                            "Jaguar" = "Jaguar Land Rover",
                                            "Range-Rover" = "Jaguar Land Rover",
                                            "^Land Rover" = "Jaguar Land Rover",
                                            "Volkswagen" = "VW"
    ))) |>
    mutate(power_train = fct_lump_min(power_train, w = value, min = 100)) |>
    count(area, model_year, brand, power_train,
          wt = value)
  
  write_rds(dta, fname)
  
  rm(dta_tmp, x1, x2, x2t)
  
} else {
  
  dta <- read_rds(fname)
  
}

dta_by_power_train <- dta |>
  summarize(count = sum(n),
            .by = c(model_year, power_train)) |>
  mutate(pct = count / sum(count),
         .by = model_year) |>
  mutate(power_train = fct_reorder(power_train, count, sum))

dta_by_brand_power_train <- dta |>
  mutate(n_count_brand = sum(n),
         .by = brand) |>
  filter(n_count_brand > 0) |>
  summarize(count = sum(n),
            .by = c(model_year, brand, power_train)) |>
  mutate(pct = count / sum(count),
         .by = model_year) |>
  mutate(power_train = fct_reorder(power_train, count, sum))

min_model_year <- min(dta_by_power_train$model_year)
max_model_year <- max(dta_by_power_train$model_year)

model_year_range = glue("{min_model_year}-{max_model_year}")

n_brands <- length(unique(dta_by_brand_power_train$brand))

my_breaks = dta_by_power_train |>
  distinct(model_year) |>
  filter(model_year %% 5 == 0 | model_year == min_model_year | model_year == max_model_year)

my_breaks_five_yearly = dta_by_power_train |>
  distinct(model_year) |>
  filter(model_year %% 5 == 0)
         
