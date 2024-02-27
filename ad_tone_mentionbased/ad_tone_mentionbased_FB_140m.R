library(dplyr)
library(tidyr)
library(data.table)
library(purrr)
library(stringr)

# Input files

# race_of_focus_140m.rdata is an output of the repo race_of_focus
path_rof <- "../../race_of_focus/data/race_of_focus_140m.rdata"
# fb_2020_140m_adid_var1.csv.gz is an output of the repo fb_2020
path_140m_vars <- "../../fb_2020/fb_2020_140m_adid_var1.csv.gz"
# entity_linking_results_140m_notext_all_fields.csv.gz is an output of the repo entity_linking
path_el_results <- "../../entity_linking/facebook/data/entity_linking_results_140m_notext_all_fields.csv.gz"
# These files are outputs of the repo datasets
path_opponents <- "../../datasets/candidates/cand2020_01012022.csv"
path_cand_pol <- "../../datasets/candidates/face_url_politician.csv"

# Output files
path_out <- "../data/ad_tone_mentionbased_fb140m.csv"

# Read 1.40m variables file for aws_face
aws <- fread(path_140m_vars, encoding = "UTF-8") %>%
  select(ad_id, aws_face)

# Read entity linking, excluding page name and disclaimer
el <- fread(path_el_results, encoding = "UTF-8", data.table = F)
el <- select(el, c(ad_id, ends_with("detected_entities")))
el <- select(el, -c(page_name_detected_entities, disclaimer_detected_entities))
# Turn Python list columns into R lists
convert_python_list <- function(x) {
  x <- str_remove_all(x, "'")
  x <- str_remove_all(x, "\\[")
  x <- str_remove_all(x, "\\]")
  x <- str_remove_all(x, " ")
  return(x)
}
el <- el %>% mutate(across(ends_with("detected_entities"), convert_python_list))
el[el == ""] <- NA
el <- el %>% unite("detected_entities", ends_with("detected_entities"), sep = ",", na.rm = T)
# Combine pictured and mentioned entities
el <- inner_join(el, aws, by = "ad_id")
el[el == ""] <- NA
el <- el %>% unite("ad_tone_entities", c(detected_entities, aws_face), sep = ",", na.rm = T)

# Load race of focus data
load(path_rof)
df <- df %>%
  filter(bucket == "1") %>%
  select(ad_id, pd_id, fecid_formerge, all_unique_entities)
# Merge in ad tone entities
df <- inner_join(df, el, by = "ad_id")
df$ad_tone_entities <- str_split(df$ad_tone_entities, ",")
df$ad_tone_entities <- lapply(df$ad_tone_entities, unique)
# exclude scotus, former potus candidates, senators not up for reelection
# (just like in race of focus)
pol <- fread(path_cand_pol)
df$ad_tone_entities <-
  lapply(df$ad_tone_entities, function(x) {
    x[!x %in% pol$fec_ids]
  }) %>%
  # if one of those people is the only one mentioned,
  # it will be set to character(0), changing this to ""
  lapply(function(x) {
    x[x != ""]
  })
rm(pol)
df$ad_tone_entities[unlist(lapply(df$ad_tone_entities, length)) == 0] <- ""


# Merge in cand opponents
df2 <- fread(path_opponents, data.table = F)
df2 <- select(df2, c(fec_id, opponent_fecid))
df2$opponent_fecid <- convert_python_list(df2$opponent_fecid)
df2$opponent_fecid <- str_split(df2$opponent_fecid, ",")
df2 <- df2[df2$opponent_fecid != "", ]
df2 <- df2[!duplicated(df2$fec_id), ] # remove duplicated candidates
df <- left_join(df, df2, by = c("fecid_formerge" = "fec_id"))

# Check whether a candidate or their opponents are mentioned in an ad
compare_candidates <- function(x, y) {
  # The any is only for the second use case,
  # but it doesn't break the first
  any(x %in% y)
}
df$candidate_in_ad <- map2_lgl(df$fecid_formerge, df$ad_tone_entities, .f = compare_candidates)
df$opponent_in_ad <- map2_lgl(df$opponent_fecid, df$ad_tone_entities, .f = compare_candidates)

# Code support/attack/contrast
df$ad_tone <- NA
df$ad_tone[df$candidate_in_ad & (df$opponent_in_ad == F)] <- "Promote"
df$ad_tone[(df$candidate_in_ad == F) & df$opponent_in_ad] <- "Attack"
df$ad_tone[df$candidate_in_ad & df$opponent_in_ad] <- "Contrast"
# If no one is mentioned, we assume support
df$ad_tone[(df$candidate_in_ad == F) & (df$opponent_in_ad == F)] <- "Promote"

# Remove ad if there is no candidate FEC ID
df <- df[df$fecid_formerge != "", ]

# Keep only the relevant columns
df <- select(df, c(ad_id, ad_tone))

# Save results
fwrite(df, path_out)
