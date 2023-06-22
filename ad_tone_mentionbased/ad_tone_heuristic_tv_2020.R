library(purrr)
library(data.table)
library(stringr)
library(tidyr)
library(dplyr)
library(pbapply)
library(haven)

el <- fread("../../entity_linking/tv/data/entity_linking_results_tv_2020_for_ad_tone.csv.gz", data.table = F)
el <- el %>% 
  mutate(detected_entities = str_remove_all(detected_entities, "'| |\\[|\\]")) %>%
  filter(adtype %in% c("CANDIDATE", "CANDIDATE & PARTY")) %>%
  mutate(sponsor = str_remove(sponsor, " &(.*?)$")) %>%
  mutate(race = str_extract(creative, "^(.*?)/")) %>%
  mutate(race = recode(
    race,
    "HOUSE/" = "US HOUSE",
    "PRES/" = "PRESIDENT",
    "USSEN/" = "US SENATE"
  ))

sponsor_to_fecid <- read_dta("../data/tv_sponsor_to_fecid/FECIDs_onTV_thru110320.dta")
sponsor_to_fecid <- sponsor_to_fecid %>% 
  select(sponsor_cmag, race, fecid)

el <- left_join(el, sponsor_to_fecid, by = c("sponsor" = "sponsor_cmag", "race"))

# Merge in candidate opponents
df2 <- fread("../../datasets/candidates/cand2020_05192022.csv", data.table = F)
df2 <- select(df2, c(fec_id, opponent_fecid))

# Turn Python list columns into R lists
convert_python_list <- function(x){
  x <- str_remove_all(x, "'")
  x <- str_remove_all(x, "\\[")
  x <- str_remove_all(x, "\\]")
  x <- str_remove_all(x, " ")
  return(x)
}

df2$opponent_fecid <- convert_python_list(df2$opponent_fecid)
df2$opponent_fecid <- str_split(df2$opponent_fecid, ",")
df2 <- df2[df2$opponent_fecid != "",]
df2 <- df2[!duplicated(df2$fec_id),] # remove duplicated candidates
df <- el
df <- left_join(df, df2, by = c("fecid" = "fec_id"))

df$aws_face <- str_split(df$aws_face, ",")
df$detected_entities <- str_split(df$detected_entities, ",")


# Assign NULL when empty makes merging easier
df$aws_face[df$aws_face == ""] <- list(NULL)
df$detected_entities[df$detected_entities == ""] <- list(NULL)

# Clean up the detected entities variable a little
df$detected_entities <- lapply(df$detected_entities, unique)
# Include pictured candidates
df$detected_entities <- map2(df$detected_entities, df$aws_face, ~union(.x, .y))
df <- df %>% select(-aws_face)
# Clean up more
df <- df[-which(unlist(lapply(df$detected_entities, is.null))), ]

# Check whether a candidate or their opponents are mentioned in an ad
compare_candidates <- function(x, y){
  # The any is only for the second use case,
  # but it doesn't break the first
  any(x %in% y)
}
df$candidate_in_ad <- pbmapply(df$fecid, df$detected_entities, FUN = compare_candidates)
df$opponent_in_ad <- pbmapply(df$opponent_fecid, df$detected_entities, FUN = compare_candidates)

# Code support/attack/contrast
df$ad_tone <- NA
df$ad_tone[df$candidate_in_ad & (df$opponent_in_ad == F)] <- "Support"
df$ad_tone[(df$candidate_in_ad == F) & df$opponent_in_ad] <- "Attack"
df$ad_tone[df$candidate_in_ad & df$opponent_in_ad] <- "Contrast"
# If no one is mentioned, we assume support
df$ad_tone[(df$candidate_in_ad == F) & (df$opponent_in_ad == F)] <- "Support"

# Remove ad if there is no candidate FEC ID
df <- df[df$fecid != "",]

# Keep only the relevant columns
df <- select(df, c(creative, ad_tone))
df <- df[is.na(df$creative) == F,]

# Save results
fwrite(df, "../data/ad_tone_mentionbased_fb2020_candidates_only.csv")
