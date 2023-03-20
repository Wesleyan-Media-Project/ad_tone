library(dplyr)
library(data.table)
library(purrr)
library(stringr)

# Input files
path_el <- "../../entity_linking_2022/facebook/data/detected_entities_fb22_for_ad_tone.csv.gz"
path_opponents <- "../../datasets/candidates/opponents_2022.csv"
path_master <- "../../datasets/facebook/fb2022_master_0905_1108.csv.gz"
path_wmpent <- "../../datasets/wmp_entity_files/Facebook/2022/wmp_fb_2022_entities_v120122.csv"
# Output files
path_out <- "../data/ad_tone_mentionbased_fb2022.csv"

# Entity linking results
el <- fread(path_el)
# Candidate opponents
opp <- fread(path_opponents) %>% select(wmpid, opponents)
# Masterfile
mf <- fread(path_master) %>% select(ad_id, pd_id)
# WMP entity file
ent <- fread(path_wmpent) %>% 
  filter(wmp_spontype == "campaign" & (wmp_office == "us house" | wmp_office == "us senate")) %>%
  select(pd_id, wmpid)

df <- left_join(mf, ent, by = "pd_id") %>%
  filter(is.na(wmpid) == F) %>%
  left_join(el, by = "ad_id") %>%
  left_join(opp, by = "wmpid") %>%
  mutate(detected_entities = str_split(detected_entities, "\\|")) %>%
  mutate(detected_entities = lapply(detected_entities, unique)) %>%
  mutate(opponents = str_split(opponents, "\\|"))


# Check whether a candidate or their opponents are mentioned in an ad
compare_candidates <- function(x, y){
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
df <- df[df$wmpid != "",]

# Keep only the relevant columns
df <- select(df, c(ad_id, ad_tone))

# Save results
fwrite(df, path_out)
