library(dplyr)
library(data.table)
library(purrr)
library(stringr)

# Input files
path_el <- "../entity_linking_2022/google/data/entity_linking_results_google_2022_notext_combined.csv.gz"
# opponents_2022.csv is an output of the repo datasets
path_opponents <- "../datasets/candidates/opponents_2022.csv"
# "g2022_adid_01062021_11082022_var1.csv" is the output table from
# part of data-post-production repo that merges preprocessed results.
# Source: data-post-production/01-merge-results/01_merge_preprocessed_results
# The original repo fb_2022 and google_2022 are both now archived into the
# data-post-production repo, you may find this file in the data-post-production repo
# or in our Figshare collection.
path_master <- "../data_post_production/g2022_adid_01062021_11082022_var1.csv.gz"
# wmp_google_2022_entities_v112822.csv is an output of the repo datasets
path_wmpent <- "../datasets/wmp_entity_files/Google/wmp_google_2022_entities_v112822.csv"
# Output files
path_out <- "data/ad_tone_mentionbased_g2022.csv"

# Entity linking results
el <- fread(path_el)
# Candidate opponents
opp <- fread(path_opponents) %>% select(wmpid, opponents)
# Masterfile
mf <- fread(path_master)

mf <- mf %>% select(ad_id, advertiser_id)

# WMP entity file
ent <- fread(path_wmpent) %>%
  filter(wmp_spontype == "campaign" & (wmp_office == "us house" | wmp_office == "us senate")) %>%
  select(advertiser_id, wmpid)

df <- left_join(mf, ent, by = "advertiser_id") %>%
  filter(is.na(wmpid) == F) %>%
  left_join(el, by = "ad_id") %>%
  left_join(opp, by = "wmpid") %>%
  mutate(detected_entities = str_split(detected_entities, "\\|")) %>%
  mutate(detected_entities = lapply(detected_entities, unique)) %>%
  mutate(opponents = str_split(opponents, "\\|"))


# Check whether a candidate or their opponents are mentioned in an ad
compare_candidates <- function(x, y) {
  # The any is only for the second use case,
  # but it doesn't break the first
  any(x %in% y)
}

df$candidate_in_ad <- map2_lgl(df$wmpid, df$detected_entities, .f = compare_candidates)
df$opponent_in_ad <- map2_lgl(df$opponents, df$detected_entities, .f = compare_candidates)

# Code support/attack/contrast
df$ad_tone <- NA
df$ad_tone[df$candidate_in_ad & (df$opponent_in_ad == F)] <- "Promote"
df$ad_tone[(df$candidate_in_ad == F) & df$opponent_in_ad] <- "Attack"
df$ad_tone[df$candidate_in_ad & df$opponent_in_ad] <- "Contrast"
# If no one is mentioned, we assume support
df$ad_tone[(df$candidate_in_ad == F) & (df$opponent_in_ad == F)] <- "Promote"

# Remove ad if there is no candidate FEC ID
df <- df[df$wmpid != "", ]

# Keep only the relevant columns
df <- select(df, c(ad_id, ad_tone))

# Save results
fwrite(df, path_out)
