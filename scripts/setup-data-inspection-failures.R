# setup-data-inspection-failures.R


###### Constants

my_caption <- "Plot: Daniel Moul\nData: Finland 2022 vehicle inspections\nTraficom tieto.traficom.fi, trafi2.stat.fi"

brand_cutoff_n <- 10
model_cutoff_n <- 25


###### Prepare data

fname <- "./data/processed/vehicle-inspections.rds"

if(!file.exists(fname)) {
  d_raw_2022 <- read_xlsx("./data/raw/Henkilöautojen-määräaikaiskatsastusten-vuositilasto-2022-cleaned.xlsx",
                          sheet = "HA malli vikatilasto",
                          skip = 6)
  
  xx_2022 <- d_raw_2022 |>
    mutate(across(where(is.character), ~ map_chr(.x, iconv, "UTF-8", "UTF-8", sub=''))) |>  # just in case
    mutate(across(where(is.character), str_trim))
  
  d_translations <- read_xlsx("./data/raw/Henkilöautojen-määräaikaiskatsastusten-vuositilasto-2022-cleaned.xlsx",
                              sheet = "translations") |>
    select(1:3) |>
    filter(!is.na(Finnish),
           !str_detect(Finnish, "^#")
    ) |>
    mutate(across(where(is.character), ~ map_chr(.x, iconv, "UTF-8", "UTF-8", sub=''))) |> # just in case
    #mutate(Finnish = str_replace_all(Finnish, "\r\n", " ")) |>
    mutate(across(where(is.character), ~ str_replace_all(.x, "^[0-9]+ ", ""))) |>
    mutate(across(where(is.character), ~ str_replace_all(.x, '["]', ""))) |>
    mutate(across(where(is.character), ~ str_replace_all(.x, "[']", ""))) |>
    mutate(across(where(is.character), str_trim))
  
  new_colnames <- d_translations |>
    filter(column_purpose == "column name")
  
  names(xx_2022) <- new_colnames$English
  
  # TODO: the below left_joins() should not be adding row
  dta_2022_tmp <- xx_2022  |>
    clean_names() |>
    left_join(d_translations |> select(-column_purpose),
              by = join_by(brand == Finnish),
              multiple = "first"
    ) |>
    # translate `brand` column
    mutate(brand = coalesce(English, brand)) |>
    select(-English) |>
    # translate `model` column
    left_join(d_translations |> select(-column_purpose),
              by = join_by(model == Finnish),
              multiple = "first"
    ) |>
    mutate(model = coalesce(English, model)) |>
    select(-English) |>
    # translate `most_common_reason_for_failure` column
    left_join(d_translations |> select(-column_purpose),
              by = join_by(failure_reason_1 == Finnish),
              multiple = "first"
    ) |>
    mutate(failure_reason_1 = coalesce(English, failure_reason_1)) |>
    select(-English) |>
    # translate `second_most_common_reason_for_failure` column
    left_join(d_translations |> select(-column_purpose),
              by = join_by(failure_reason_2 == Finnish),
              multiple = "first"
    ) |>
    mutate(failure_reason_2 = coalesce(English, failure_reason_2)) |>
    select(-English) |>
    # translate `third_most_common_reason_for_failure` column
    left_join(d_translations |> select(-column_purpose),
              by = join_by(failure_reason_3 == Finnish),
              multiple = "first"
    ) |>
    mutate(failure_reason_3 = coalesce(English, failure_reason_3)) |>
    select(-English) |>
    mutate(failure_reason_1 = if_else(is.na(failure_reason_1),
                                      "Not provided",
                                      failure_reason_1),
           failure_reason_2 = if_else(is.na(failure_reason_3),
                                      "Not provided",
                                      failure_reason_2),
           failure_reason_3 = if_else(is.na(failure_reason_3),
                                      "Not provided",
                                      failure_reason_3)
    )|>
    mutate(brand = str_replace_all(brand, c("Volkswagen" = "VW",
                                            "Mercedes-Benz" = "MB",
                                            "BMW i" = "BMW",
                                            "Jaguar Land Rover Limited" = "Jaguar Land Rover",
                                            "Jaguar$" = "Jaguar Land Rover",
                                            "^Land Rover" = "Jaguar Land Rover")),
           brand_model = glue("{brand} {model}"),
           model = str_replace_all(model, c("NEW BEETLE" = "BEETLE"))
           
    ) |>
    # TODO: fix the following kludge; not sure why translation above didn't work for this one string
    mutate(model_year = if_else(str_detect(model_year, "Vuodet"),
                                "All model years",
                                model_year)) 
  
  dta_2022 <- left_join(dta_2022_tmp,
                        dta_2022_tmp |>
                          filter(model_year != "All model years",
                                 brand != "All brands",
                                 model != "All models") |>
                          mutate(n_model_years_brand = n(),
                                 .by = c(brand)) |> # TODO: ??? using brand_model since brands are not unique (e.g, "3" and "5")
                          distinct(brand, n_model_years_brand),
                        by = join_by(brand)
  ) |>
    mutate(failure_rate = failure_rate / 100)
  
  write_rds(dta_2022, fname) 
  
  rm(xx_2022, dta_2022_tmp, new_colnames)
  
} else {
  
  dta_2022 <- read_rds(fname)
  
  d_translations <- read_xlsx("./data/raw/Henkilöautojen-määräaikaiskatsastusten-vuositilasto-2022-cleaned.xlsx",
                              sheet = "translations") |>
    select(1:3) |>
    filter(!is.na(Finnish),
           !str_detect(Finnish, "^#")
    ) |>
    mutate(across(where(is.character), ~ map_chr(.x, iconv, "UTF-8", "UTF-8", sub=''))) |> # just in case
    #mutate(Finnish = str_replace_all(Finnish, "\r\n", " ")) |>
    mutate(across(where(is.character), ~ str_replace_all(.x, "^[0-9]+ ", ""))) |>
    mutate(across(where(is.character), ~ str_replace_all(.x, '["]', ""))) |>
    mutate(across(where(is.character), ~ str_replace_all(.x, "[']", ""))) |>
    mutate(across(where(is.character), str_trim))
  
}

dta_2022_no_totals <- dta_2022 |>
  filter(model_year != "All years",
         brand != "All brands",
         model != "All models",
         model_year != "All model years") |>
  mutate(model_year = as.numeric(model_year))

all_brands_yearly <- dta_2022 |>
  filter(model_year %in% 2001:2023,
         brand == "All brands")

all_models_yearly <- dta_2022 |>
  filter(model_year %in% 2001:2023,
         model == "All models",
         brand != "All brands") |>
  mutate(model_year = as.numeric(model_year)) |>
  reframe(failure_rate = weighted.mean(failure_rate, w = inspection_count),
          average_km_driven = round(weighted.mean(average_km_driven, w = inspection_count)),
          median_km_driven = round(weighted.mean(median_km_driven, w = inspection_count)),
          inspection_count = sum(inspection_count),
          .by = c(model_year, brand)
  )

n_brands_all <- length(unique(dta_2022_no_totals$brand))
n_models_all <- length(unique(dta_2022_no_totals$brand_model))

min_model_year_all <- min(dta_2022_no_totals$model_year)
max_model_year_all <- max(dta_2022_no_totals$model_year)
model_year_range_all <- glue("{min_model_year_all} - {max_model_year_all}")

dta_working_set <- dta_2022_no_totals |>
  filter(model_year < 2019,
         n_model_years_brand >=3) |>
  mutate(vehicle_age = 2022 - model_year)

n_brands <- length(unique(dta_working_set$brand))
n_models <- length(unique(dta_working_set$brand_model))

min_model_year <- min(dta_working_set$model_year)
max_model_year <- max(dta_working_set$model_year)
model_year_range <- glue("{min_model_year} - {max_model_year}")

my_breaks = dta_working_set |>
  distinct(model_year) |>
  filter(model_year %% 5 == 0 | model_year == min_model_year | model_year == max_model_year)


reasons_df <- tribble(
  ~reason,                                 ~reason_short,
  "Parking brake dynamometer test",       "P-brake test",
  "Steering joints and rods",             "Steering",
  "OBD (on-board diagnostic system)",     "OBD",
  "Brakes dynamometer test",              "Brake test",
  "Chassis",                             "Chassis etc",
  "Chassis housing and underframe",       "Chassis etc",
  "Petrol engine exhaust measurement",    "Petrol Exhaust",
  "Diesel engine exhaust measurement",    "Diesel Exhaust",
  "Manufacturers plate",                  "Mfg plate",
  "Factual documents",                    "Factual docs",
  "Seat belts and safety equipment",      "Safety equip",
  "Registration markings",                "Registr markings",
  "Stability control system",             "Stability control"
)

