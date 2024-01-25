# setup-libraries.R

###### Libraries

library(tidyverse)
library(readxl)
library(purrr)
library(janitor) # for clean_names() and adorn_totals()
library(glue) # for glue() and glue_collapse()
library(scales)
library(ggrepel) # for geom_text_repel() and geom_label_repel()
library(gt)
library(broom) # for tidy() and augment()
library(patchwork)
library(tidytext) # for reorder_within() and scale_y_reordered()
library(ggbump) # for geom_bump()
library(dagitty) # for dagitty()

options(scipen = 999)

# ggplot theme
theme_set(theme_light() +
            theme(panel.grid = element_blank(),
                  panel.border = element_blank(),
                  plot.title = element_text(size = rel(2.0), face = "bold"),
                  plot.title.position = "plot")
)


