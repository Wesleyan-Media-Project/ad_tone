library(dplyr)
library(data.table)
library(purrr)
library(stringr)

# Input files
path_rof <- "../../race_of_focus/data/race_of_focus.rdata"
path_opponents <- "../../datasets/candidates/cand2020_01012022.csv"
# Output files
path_out <- "../data/ad_tone_mentionbased_fb118m.csv"


# Load race of focus data
load(path_rof)
df <- df %>% 
  filter(bucket == "1") %>%
  select(ad_id, pd_id, fecid_formerge, all_unique_entities)

# Turn Python list columns into R lists
convert_python_list <- function(x){
  x <- str_remove_all(x, "'")
  x <- str_remove_all(x, "\\[")
  x <- str_remove_all(x, "\\]")
  x <- str_remove_all(x, " ")
  return(x)
}

# Merge in cand opponents
df2 <- fread(path_opponents, data.table = F)
df2 <- select(df2, c(fec_id, opponent_fecid))
df2$opponent_fecid <- convert_python_list(df2$opponent_fecid)
df2$opponent_fecid <- str_split(df2$opponent_fecid, ",")
df2 <- df2[df2$opponent_fecid != "",]
df2 <- df2[!duplicated(df2$fec_id),] # remove duplicated candidates
df <- left_join(df, df2, by = c("fecid_formerge" = "fec_id"))

# Check whether a candidate or their opponents are mentioned in an ad
compare_candidates <- function(x, y){
  # The any is only for the second use case,
  # but it doesn't break the first
  any(x %in% y)
}
df$candidate_in_ad <- map2_lgl(df$fecid_formerge, df$all_unique_entities, .f = compare_candidates)
df$opponent_in_ad <- map2_lgl(df$opponent_fecid, df$all_unique_entities, .f = compare_candidates)

# Code support/attack/contrast
df$ad_tone <- NA
df$ad_tone[df$candidate_in_ad & (df$opponent_in_ad == F)] <- "Support"
df$ad_tone[(df$candidate_in_ad == F) & df$opponent_in_ad] <- "Attack"
df$ad_tone[df$candidate_in_ad & df$opponent_in_ad] <- "Contrast"
# If no one is mentioned, we assume support
df$ad_tone[(df$candidate_in_ad == F) & (df$opponent_in_ad == F)] <- "Support"

# Remove ad if there is no candidate FEC ID
df <- df[df$fecid_formerge != "",]

# Keep only the relevant columns
df <- select(df, c(ad_id, ad_tone))

# Save results
fwrite(df, path_out)
