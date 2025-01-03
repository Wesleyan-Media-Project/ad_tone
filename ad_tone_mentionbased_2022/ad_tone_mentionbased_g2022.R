library(dplyr)
library(data.table)
library(purrr)
library(tidyr)
library(stringr)

# Input files
# Entity Linking results
path_el <- "../entity_linking_2022/google/data/entity_linking_results_google_2022_notext_combined.csv.gz"
# opponents_2022.csv is an output of the repo datasets
path_opponents <- "../datasets/candidates/opponents_2022.csv"
# "g2022_adid_var1.csv" is the output table from
# part of data-post-production repo that merges preprocessed results.
# Source: data-post-production/01-merge-results/01_merge_preprocessed_results
# The original repo fb_2022 and google_2022 are both now archived into the
# data-post-production repo, you may find this file in the data-post-production repo
# or in our Figshare collection.
path_master <- "../data_post_production/g2022_adid_var1.csv.gz"
# wmp_google_2022_entities_v112822.csv is an output of the repo datasets
path_wmpent <- "../datasets/wmp_entity_files/Google/wmp_google_2022_entities_v112822.csv"
# Output files
path_out <- "data/ad_tone_mentionbased_g2022.csv"

# Entity linking results
el <- fread(path_el)
el$detected_entities <- gsub(", ", "|", el$detected_entities)
# Candidate opponents
opp <- fread(path_opponents) %>% select(wmpid, opponents)
# Masterfile
mf <- fread(path_master)

mf <- mf %>% select(ad_id, advertiser_id, aws_face_img, aws_face_vid)

# Create the aws_face column in `mf` with values separated by '|'
mf <- mf %>%
  mutate(aws_face = apply(mf, 1, function(row) {
    aws_face_img <- as.character(row['aws_face_img'])
    aws_face_vid <- as.character(row['aws_face_vid'])
    
    if (!is.na(aws_face_img) && !is.na(aws_face_vid)) {
      # Split and remove duplicates, then combine with '|' separator
      faces_img <- unique(strsplit(aws_face_img, ';')[[1]])
      faces_vid <- unique(strsplit(aws_face_vid, ';')[[1]])
      return(paste(unique(c(faces_img, faces_vid)), collapse = '|'))
    } else if (is.na(aws_face_img) || is.na(aws_face_vid)) {
      # Handle missing aws_face_img or aws_face_vid and return with '|' separator
      faces_img <- strsplit(aws_face_img, ';')[[1]]
      faces_vid <- strsplit(aws_face_vid, ';')[[1]]
      all_faces <- c(faces_img, faces_vid)
      all_faces <- all_faces[all_faces != 'nan']  # Remove 'nan' values
      return(paste(all_faces, collapse = '|'))
    } else {
      return('')
    }
  }))


# Merge `el` and `mf` based on the common column 'ad id'
merged_df <- merge(el, mf[, c('ad_id', 'aws_face')], by = 'ad_id', all.x = TRUE)

# Concatenate detected_entities and aws_face into detected_entities_all
merged_df2 <- merged_df %>%
  mutate(detected_entities_all = if_else(
    !is.na(aws_face) & aws_face != "", 
    # If aws_face is not empty, concatenate detected_entities and aws_face with '|'
    paste(detected_entities, aws_face, sep = '|'),
    # If aws_face is empty or NA, just return detected_entities
    detected_entities
  ))

# Perform a left join between el and merged_df2 based on ad_id
el <- merge(el, merged_df2[, c("ad_id", "detected_entities_all")], by = "ad_id", all.x = TRUE)

# Now, the detected_entities_all column from merged_df2 will be in el
el$detected_entities <- el$detected_entities_all

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
