# setup-libraries.R

###### Libraries

library(tidyverse)
library(readxl)
library(purrr)
library(janitor)
library(glue)
library(scales)
library(ggrepel)
library(gt)
library(broom)
library(patchwork)

options(scipen = 999)

# ggplot theme
theme_set(theme_light() +
            theme(panel.grid = element_blank(),
                  panel.border = element_blank(),
                  plot.title = element_text(size = rel(2.0), face = "bold"),
                  plot.title.position = "plot")
)


