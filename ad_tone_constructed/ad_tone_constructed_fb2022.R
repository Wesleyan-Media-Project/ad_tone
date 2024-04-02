library(dplyr)
library(data.table)
library(purrr)

# Input files

# fb2022_ABSA_pred.csv.gz is an output from the repo ABSA
path_absa <- "../ABSA/data/fb2022_ABSA_pred.csv.gz"
# race_of_focus_fb2022.rdata is an output from the repo race_of_focus
path_rof <- "../race_of_focus/data/race_of_focus_fb2022.rdata"
path_mention_adtone <- "data/ad_tone_mentionbased_fb2022.csv"
# Output files
path_output <- "data/ad_tone_constructed_fb2022.csv.gz"

# Read ABSA data
absa <- fread(path_absa)

# Aggregate to ad-mention level
absa <- aggregate(absa$predicted_sentiment, list(absa$ad_id, absa$text_detected_entities), sum)
names(absa) <- c("ad_id", "target", "sentiment")

absa$sentiment[absa$sentiment > 0] <- "Promote"
absa$sentiment[absa$sentiment < 0] <- "Attack"
absa$sentiment[absa$sentiment == 0] <- "No ad tone, ABSA 0"

# Read race of focus data
load(path_rof)

df2 <- df %>%
  select(ad_id, race_of_focus, sub_bucket, all_unique_entities, bucket,
         all_unique_entities_races, all_unique_entities_unique_races_N)

# How many candidates are mentioned/pictured from within the race of focus?
df2$rof_cands_n <- unlist(map2(df2$all_unique_entities_races, df2$race_of_focus, function(x, y) {
  length(which(y == x))
}))

# How many candidates are mentioned/pictured?
df2$all_unique_entities[df2$all_unique_entities == ""] <- list(character(0))
df2$cands_n <- unlist(lapply(df2$all_unique_entities, length))
#table(df2$cands_n, useNA = "ifany")
# Indices of the candidates in the race of focus
df2$rof_cands_idx <- map2(df2$race_of_focus, df2$all_unique_entities_races, function(x, y) {
  which(x == y)
})
# Candidates in the race of focus
df2$rof_cands <- map2(df2$rof_cands_idx, df2$all_unique_entities, function(x, y) {
  y[x]
})

# Buckets####
df2$ad_tone_constructed <- NA
## Filter down to bucket 3
dfb1 <- df2 %>%
  filter(bucket == '1')
dfb2 <- df2 %>%
  filter(bucket == '2')
dfb3 <- df2 %>%
  filter(bucket == '3')

### Separate into more/less than multiple race of focus
dfb3r <- dfb3 %>%
  filter(all_unique_entities_unique_races_N <= 1)
dfb3l <- dfb3 %>%
  filter(all_unique_entities_unique_races_N > 1)


#### For Left, separate into how many candidates within ROF
##### ROF == 1 (Use ABSA Scores)
dfb3l1 <- dfb3l %>%
  filter(rof_cands_n == 1) #1869 will use ABSA scores
dfb3l1$merge_id <- paste(dfb3l1$ad_id, "_", dfb3l1$rof_cands)
#df$merge_id[df$rof_cands_n != 1] <- NA
absa$merge_id <- paste(absa$ad_id, "_", absa$target)
absa2 <- select(absa, c(merge_id, sentiment))
dfb3l1a <- left_join(dfb3l1, absa2, by = "merge_id")
dfb3l1a$ad_tone_constructed <- dfb3l1a$sentiment
dfb3l1b <- dfb3l1a %>%
  select(ad_id, ad_tone_constructed)
dfb3l1b$ad_tone_constructed[is.na(dfb3l1b$ad_tone_constructed)] <- "No ad tone, missing ABSA"

##### ROF > 1
dfb3l2 <- dfb3l %>%
  filter(rof_cands_n > 1) #109 will be Contrast
dfb3l2$ad_tone_constructed <- "Contrast"
dfb3l2a <- dfb3l2 %>%
  select(ad_id, ad_tone_constructed)

##### ROF == 0
dfb3l3 <- dfb3l %>%
  filter(rof_cands_n == 0) #830 will be No Ad Tone
dfb3l3$ad_tone_constructed <- "No Ad Tone"
dfb3l3a <- dfb3l3 %>%
  select(ad_id, ad_tone_constructed)

##### Merge Lefts
dfb3l4 <- rbind(dfb3l1b, dfb3l2a, dfb3l3a)

#### For Right, separate into how many candidates in general
##### Cands == 1
dfb3r1 <- dfb3r %>%
  filter(cands_n == 1) #63641 will use ABSA scores
absa$count <- ave(rep(1, nrow(absa)), absa$ad_id, FUN = length)
absar <- absa %>%
  filter(count == 1) %>%
  select(ad_id, sentiment)
dfb3r1a <- merge(dfb3r1, absar, by = "ad_id", all.x = T)
dfb3r1a$ad_tone_constructed <- dfb3r1a$sentiment
dfb3r1b <- dfb3r1a %>%
  select(ad_id, ad_tone_constructed)
dfb3r1b$ad_tone_constructed[is.na(dfb3r1b$ad_tone_constructed)] <- "No ad tone, missing ABSA"

##### Cands > 1
dfb3r2 <- dfb3r %>%
  filter(cands_n > 1) #10013 will be Contrast
dfb3r2$ad_tone_constructed <- "Contrast"
dfb3r2a <- dfb3r2 %>%
  select(ad_id, ad_tone_constructed)

##### Cands == 0
dfb3r3 <- dfb3r %>%
  filter(cands_n == 0) #196867 will be No Ad Tone
dfb3r3$ad_tone_constructed <- "No Ad Tone"
dfb3r3a <- dfb3r3 %>%
  select(ad_id, ad_tone_constructed)

##### Merge Rights
dfb3r4 <- rbind(dfb3r1b, dfb3r2a, dfb3r3a)

### Merge Right and Left
dfb3_2 <- rbind(dfb3l4, dfb3r4)

#----
# Bucket 1

# Read in mention-based ad tone
df1 <- fread(path_mention_adtone)
df1 <- df1 %>% select(ad_id, ad_tone)
names(df1) <- c("ad_id", "ad_tone_constructed")

# We're missing bucket 2 which has no ad tone by definition
# Bucket 2
dfb2$ad_tone_constructed <- "No Ad Tone"
dfb2_2 <- dfb2 %>%
  select(ad_id, ad_tone_constructed)

#----
# Combine the buckets

df_2 <- rbind(df1, dfb3_2, dfb2_2)


#Check the results####
library(readr)
ent <- read_csv("../datasets/wmp_entity_files/Facebook/2022/wmp_fb_2022_entities_v120122.csv")
df0 <- read_csv("../data_post_production/fb_2022_adid_var.csv.gz")

df4 <- merge(df0, ent, by = 'pd_id', all.x = T)
df5 <- merge(df4, df_2, by = 'ad_id', all.x = T)
df6 <- merge(df5, df, by = 'ad_id', all.x = T)

table(df6$ad_tone_constructed.y[df6$wmp_spontype.y == 'group' & df6$federal_verified == 'Yes'])
table(df6$wmp_spontype.y[df6$federal_verified == 'Yes'], df6$ad_tone_constructed.y[df6$federal_verified == 'Yes'])

table(df6$wmp_spontype.x[df6$bucket.x == '3'], df6$federal_verified[df6$bucket.x == '3'])
table(df6$sentiment[df6$wmp_spontype.x =='group' & df6$federal_verified == 'Yes' & df6$bucket.y == '3'])
summary(df6$sentiment == 'No ad tone, ABSA 0' & df6$wmp_spontype.x =='group' & df6$federal_verified == 'Yes' & df6$bucket.y == '3' & df6$cands_n == 1)

el <- read_csv('../entity_linking_2022/facebook/data/detected_entities_fb22_for_ad_tone_new.csv.gz')
#####

fwrite(df_2, path_output)
