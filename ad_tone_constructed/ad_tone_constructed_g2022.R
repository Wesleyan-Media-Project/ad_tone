# Implements ad_tone_constructed, as detailed here:
# https://docs.google.com/presentation/d/11E9kX1oVYfMooTdD1GAJfwJtdPIQpYB3lJ7i5e83ZEw/edit#slide=id.g1062def0ba3_0_0

library(dplyr)
library(data.table)
library(purrr)

# Input files

# google_2022_ABSA_pred.csv.gz is an output from the repo ABSA
path_absa <- "../ABSA/data/google_2022_ABSA_pred.csv.gz"
# race_of_focus_google_2022.rdata is an output from the repo race_of_focus
path_rof <- "../race_of_focus/data/race_of_focus_google_2022.rdata"
path_mention_adtone <- "data/ad_tone_mentionbased_g2022.csv"
# Output files
path_output <- "data/ad_tone_constructed_g2022.csv.gz"

# Read ABSA data
absa <- fread(path_absa)

# Aggregate to ad-mention level
absa <- aggregate(absa$predicted_sentiment, list(absa$ad_id, absa$detected_entities), sum)
names(absa) <- c("ad_id", "target", "sentiment")

absa$sentiment[absa$sentiment > 0] <- "Promote"
absa$sentiment[absa$sentiment < 0] <- "Attack"
absa$sentiment[absa$sentiment == 0] <- "Contrast"

# Read race of focus data
load(path_rof)

df <- g2022_3 %>%
  select(ad_id, race_of_focus, sub_bucket, all_unique_entities, all_unique_entities_races, all_unique_entities_unique_races_N)

# How many candidates are mentioned/pictured from within the race of focus?
df$rof_cands_n <- unlist(map2(df$all_unique_entities_races, df$race_of_focus, function(x, y) {
  length(which(y == x))
}))
# How many candidates are mentioned/pictured?
df$all_unique_entities[df$all_unique_entities == ""] <- list(character(0))
df$cands_n <- unlist(lapply(df$all_unique_entities, length))
# Indices of the candidates in the race of focus
df$rof_cands_idx <- map2(df$race_of_focus, df$all_unique_entities_races, function(x, y) {
  which(x == y)
})
# Candidates in the race of focus
df$rof_cands <- map2(df$rof_cands_idx, df$all_unique_entities, function(x, y) {
  y[x]
})

# Merge in ABSA sums for when there is one ROF cand
df$merge_id <- paste(df$ad_id, "_", df$rof_cands)
df$merge_id[df$rof_cands_n != 1] <- NA
absa$merge_id <- paste(absa$ad_id, "_", absa$target)
absa <- select(absa, c(merge_id, sentiment))
df <- left_join(df, absa, by = "merge_id")

#----
# Bucket 3
df3 <- df[substr(df$sub_bucket, 1, 1) == "3", ]
df3$ad_tone_constructed <- NA

# Bucket 3, right branch
df3$ad_tone_constructed[df3$all_unique_entities_unique_races_N <= 1 & df3$cands_n > 1] <- "Contrast"
df3$ad_tone_constructed[df3$all_unique_entities_unique_races_N <= 1 & df3$cands_n == 1] <- "ABSA sum"
df3$ad_tone_constructed[df3$all_unique_entities_unique_races_N <= 1 & df3$cands_n == 0] <- "No ad tone"
# Bucket 3, left branch
df3$ad_tone_constructed[df3$all_unique_entities_unique_races_N > 1 & df3$cands_n > 1] <- "Contrast"
df3$ad_tone_constructed[df3$all_unique_entities_unique_races_N > 1 & df3$cands_n == 1] <- "ABSA sum"

# ABSA-based
df3$ad_tone_constructed[df3$ad_tone_constructed == "ABSA sum"] <- df3$sentiment[df3$ad_tone_constructed == "ABSA sum"]
df3$ad_tone_constructed[is.na(df3$ad_tone_constructed) & is.na(df3$sentiment)] <- "No ad tone, missing ABSA"

#----
# Bucket 1

# Read in mention-based ad tone
df1 <- fread(path_mention_adtone)
df1 <- df1 %>% select(ad_id, ad_tone)
names(df1) <- c("ad_id", "ad_tone_constructed")

#----
# Combine the buckets
df <- rbind(df1, df3 %>% select(c(ad_id, ad_tone_constructed)))

# We're missing bucket 2 which has no ad tone by definition

# Kick out no ad tone since it adds nothing and just wastes space
df <- df %>% filter(ad_tone_constructed %in% c("Attack", "Contrast", "Promote"))

fwrite(df, path_output)
