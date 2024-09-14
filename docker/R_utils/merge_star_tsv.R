#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)

suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(readr))
suppressPackageStartupMessages(library(purrr))
suppressPackageStartupMessages(library(tidyr))






if (interactive()) {
  args <- list("./C7205.starfusion.fusion_predictions.tsv")
}

if (length(args) == 0) {
  write_tsv(tibble(), file = "merged.tsv")
  quit(status = 0)
}

df_list <- args %>%
  map(\(x) read_tsv(x, id = "id", col_types = cols(.default = col_character()))) %>%
  bind_rows()

df_names <- df_list %>%
  colnames()

df_list <- df_list %>%
  separate_wider_delim(cols = 'id', delim = "/", names_sep = "")

name_ind <- colnames(df_list) %>% startsWith("id") %>% sum()
end_ind <- ncol(df_list)

df_list <- df_list[, name_ind:end_ind]

df_list <- df_list %>%
  separate_wider_delim(cols = 1, delim = ".", names_sep = "")

last_to_drop_ind <- colnames(df_list) %>% startsWith("id") %>% sum()
new_names <- df_list %>% colnames()

df_list <- df_list[-c(2:last_to_drop_ind)]

colnames(df_list) <- df_names

if (nrow(df_list) == 0) {
  df_list <- tibble()
  write_tsv(df_list, file = "merged.tsv")
  quit(status = 0)
}
write_tsv(df_list, file = "merged.tsv")
