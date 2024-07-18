# CREATIVE --- Ad Tone

Welcome! This repo contains scripts for classifying political ads by ad tone (e.g., contrast, promote, attack).

This repo is part of the [Cross-platform Election Advertising Transparency Initiative (CREATIVE)](https://www.creativewmp.com/). CREATIVE is an academic research project that has the goal of providing the public with analysis tools for more transparency of political ads across online platforms. In particular, CREATIVE provides cross-platform integration and standardization of political ads collected from Google and Facebook. CREATIVE is a joint project of the [Wesleyan Media Project (WMP)](https://mediaproject.wesleyan.edu/) and the [privacy-tech-lab](https://privacytechlab.org/) at [Wesleyan University](https://www.wesleyan.edu).

To analyze the different dimensions of political ad transparency we have developed an analysis pipeline. The scripts in this repo are part of the Data Classification step in our pipeline.

![A picture of the repo pipeline with this repo highlighted](CREATIVE_step3_032524.png)

## Table of Contents

[1. Introduction](#1-introduction)  
[2. Data](#2-data)  
[3. Setup](#3-setup)  
[4. Thank you!](#4-thank-you)

## 1. Introduction

This repository contains code that generates two variables. First is called ad tone mention-based, which codes ad as 'contrast, 'promote' or 'attack'. We use the outputs from the entity linking [2022](https://github.com/Wesleyan-Media-Project/entity_linking_2022/tree/main) repo as an input for this. This coding is decided based on who is mentioned in the ad:

- If an ad from a candidate mentions the candidate in the ad and not their opponent: Promote
- If an ad from a candidate mentions their opponent in the ad and not themselves: Attack
- If an ad from a candidate mentions both the candidate and their opponent in the ad: Contrast

Second, we have ad tone constructed, which utilizes results from the mention-based classification, as well as results from [ABSA](https://github.com/Wesleyan-Media-Project/ABSA/tree/main) and [race of focus](https://github.com/Wesleyan-Media-Project/race_of_focus/tree/main) repos to code ads as 'contrast, 'promote' or 'attack'. To visualize our decision-making process for ad-tone constructed, consult this diagram. Also see below for more details.

Data output by the scripts is in the format ad_id,ad_tone. An example row looks like `x1949505221867086,Promote`.

![Diagram showing the process by which ad tone constructed is gotten](ad_tone_chart.png)

This repo contains eight R scripts, three that deal with ad tone constructed and five that deal with ad tone mention-based. Of the five scripts related to ad tone mention-based, scripts related to non-2022 data are in a folder called ["ad_tone_mentionbased"](https://github.com/Wesleyan-Media-Project/ad_tone/tree/main/ad_tone_mentionbased). The scripts that are related to Facebook and Google 2022 are in another folder called ["ad_tone_mentionbased_2022"](https://github.com/Wesleyan-Media-Project/ad_tone/tree/main/ad_tone_mentionbased_2022). Thus, if you only want to work on the 2022 data, you do not have to run anything in the ["ad_tone_mentionbased"](https://github.com/Wesleyan-Media-Project/ad_tone/tree/main/ad_tone_mentionbased) folder.
All of the a constructed scripts are in ["ad_tone_constructed"](https://github.com/Wesleyan-Media-Project/ad_tone/tree/main/ad_tone_constructed), regardless of whether they are related to 2022 or non-2022 data.

## 2. Data

The code in this repository creates two variables, ad tone mention-based, and ad tone constructed. Results are saved as a csv file, in the [data](https://github.com/Wesleyan-Media-Project/ad_tone/tree/main/data) folder:

- Mention-based Results for:
- - [Facebook 2020](https://github.com/Wesleyan-Media-Project/ad_tone/blob/main/data/ad_tone_mentionbased_fb140m.csv)
- - [Facebook 2022](https://github.com/Wesleyan-Media-Project/ad_tone/blob/main/data/ad_tone_mentionbased_fb2022.csv)
- - [Google 2020](https://github.com/Wesleyan-Media-Project/ad_tone/blob/main/data/ad_tone_mentionbased_google_2020.csv)
- - [Google 2022](https://github.com/Wesleyan-Media-Project/ad_tone/blob/main/data/ad_tone_mentionbased_g2022.csv)
- Constructed Results for:
- - [Facebook 2020](https://github.com/Wesleyan-Media-Project/ad_tone/blob/main/data/ad_tone_constructed_fb140m.csv.gz)
- - [Facebook 2022](https://github.com/Wesleyan-Media-Project/ad_tone/blob/main/data/ad_tone_constructed_fb2022.csv.gz)
- - [Google 2022](https://github.com/Wesleyan-Media-Project/ad_tone/blob/main/data/ad_tone_constructed_g2022.csv.gz)

### 2.1 Ad tone mention-based

Mention-based (or reference-based) results in ads coded as 'Contrast' if both the candidate and their opponent are mentioned in the ad (either in text, or in image appearance), 'Promote' if only the candidate is mentioned, and 'Attack' if only the opponent is mentioned. If no candidate is mentioned, the ad is coded as 'Support' (given that the basic purpose of an ad is to further the preferred candidate's electoral prospects). This variable is available for the candidate ads in the 1.4m dataset.

### 2.2 Ad tone constructed

The construction of ad tone is based on this flowchart.

![Diagram showing the process by which ad tone constructed is gotten](ad_tone_chart.png)

When traditional mention-based ad tone is available, we use that; otherwise we sum over ABSA results (also using race of focus). The variable is available for a larger number of ads, and the rest have no ad tone.

## 3. Setup

### 3.1 Install R and Packages

First, make sure you have R installed. In addition, while R can be run from the terminal, many people find it much easier to use r-studio along with R. A link to this program can be found [here](https://rstudio-education.github.io/hopr/starting.html)

The scripts use are tested on R 4.2, 4.3, and 4.4.

Next, make sure you have the following packages installed in R (the exact version we used of each package is listed in the [requirements_r.txt file](https://github.com/Wesleyan-Media-Project/ad_tone/blob/main/requirements_r.txt). These are the versions we tested our scripts on and thus, they may also work with more recent versions):

- data.table
- stringr
- purrr
- dplyr
- tidyr
- R.utils

### 3.2 Input Files

In order to use the scripts in this repo, you will need outputs from a number of other repos. Specifically which repositories are needed depends on which script you are executing.

#### 3.2.1 Mention-based Scripts

All the scripts for ad tone mention-based require [datasets](https://github.com/Wesleyan-Media-Project/datasets). In addition, depending on the specific script, various other repos must also be downloaded.

Looking at the scripts within the ad_tone_mentionbased_2022 folder, they all require [datasets](https://github.com/Wesleyan-Media-Project/datasets). In addition, depending on the specific script, various other repos must also be downloaded. Specifically:

- ad_tone_mentionbased_2022/ad_tone_mentionbased_fb2022.R requires the [`/entity_linking_2022/facebook/data/detected_entities_fb22_for_ad_tone.csv.gz"`](https://github.com/Wesleyan-Media-Project/entity_linking_2022/blob/main/facebook/data/detected_entities_fb22_for_ad_tone.csv.gz) file from the entity linking repo, and the [`fb_2022_adid_var1.csv.gz`](https://figshare.wesleyan.edu/account/articles/26124340) file that is found on Figshare.
- ad_tone_mentionbased_2022/ad_tone_mentionbased_g2022.R requires the [`entity_linking_results_google_2022_notext_combined.csv.gz `](https://github.com/Wesleyan-Media-Project/entity_linking_2022/blob/main/google/data/entity_linking_results_google_2022_notext_combined.csv.gz) file from the entity_linking_2022 repo and the [`g2022_adid_01062021_11082022_var1.csv.gz`](https://figshare.wesleyan.edu/account/articles/26124349) file that is found on Figshare.

Scripts in the ad_tone_mentionbased folder were not used for 2022 election ads data production are described down below. They are legacy scripts serving similar purposes towards our 2020 TV and online ads data. They are preserved here for internal use.

- ad_tone_mentionbased/ad_tone_heuristic_tv_2020.R requires the [`entity_linking_results_tv_2020_for_ad_tone.csv.gz`](tv/data/entity_linking_results_tv_2020_for_ad_tone.csv.gz) file of the entity linking repo.
- ad_tone_mentionbased/ad_tone_mentionbased_FB_140m.R requires the [`race_of_focus_140m.rdata`](https://github.com/Wesleyan-Media-Project/race_of_focus/blob/main/data/race_of_focus_140m.rdata) file of the race of focus repo, the [`fb_2020_140m_adid_var1.csv.gz`](https://figshare.wesleyan.edu/account/articles/26093254) file that is found on Figshare and [entity linking](https://github.com/Wesleyan-Media-Project/entity_linking).
- ad_tone_mentionbased/ad_tone_mentionbased_Google_2020.R requires [`race_of_focus_2020.rdata`](https://github.com/Wesleyan-Media-Project/race_of_focus/blob/main/data/race_of_focus_google_2020.rdata) from the race_of_focus directory, [`entity_linking_results_google_2020_notext_all_fields.csv.gz`](https://github.com/Wesleyan-Media-Project/entity_linking/blob/main/google/data/entity_linking_results_google_2020_notext_all_fields.csv.gz) from the entity_linking repo and [`google_2020_adid_var1.csv.gz`](https://github.com/Wesleyan-Media-Project/datasets/blob/main/google/google_2020_adid_var1.csv.gz) from the datasets repo.

--
Some input files for mention-based scripts require the metadata (e.g., var1 files) for Facebook or Google. These are too large to be uploaded to GitHub. You can download them through our Figshare page:

- For [Facebook 2022 script](https://github.com/Wesleyan-Media-Project/ad_tone/blob/main/ad_tone_mentionbased_2022/ad_tone_mentionbased_fb2022.R): [data_post_production/fb_2022_adid_var1.csv.gz](https://figshare.wesleyan.edu/account/articles/26124340).
- For [Google 2022 script](https://github.com/Wesleyan-Media-Project/ad_tone/blob/main/ad_tone_mentionbased_2022/ad_tone_mentionbased_g2022.R): [data_post_production/g2022_adid_01062021_11082022_var1.csv.gz](https://figshare.wesleyan.edu/account/articles/26124349).

Pre-2022 data production:

- For [Facebook 2020 script](https://github.com/Wesleyan-Media-Project/ad_tone/blob/main/ad_tone_mentionbased/ad_tone_mentionbased_FB_140m.R): [fb_2020/fb_2020_140m_adid_var1.csv.gz](https://figshare.wesleyan.edu/account/articles/26124340).
- For [Google 2020 script](https://github.com/Wesleyan-Media-Project/ad_tone/blob/main/ad_tone_mentionbased/ad_tone_mentionbased_Google_2020.R): [google_2020_adid_var1.csv.gz](https://github.com/Wesleyan-Media-Project/datasets/blob/main/google/google_2020_adid_var1.csv.gz)

#### 3.2.2 Constructed Scripts

Looking at the scripts within the ad_ton_constructed folder, they require:

- ad_tone_constructed/ad_tone_constructed_fb2022.R requires the [`fb2022_ABSA_pred.csv.gz`](https://github.com/Wesleyan-Media-Project/ABSA/blob/main/data/fb2022_ABSA_pred.csv.gz) file from the ABSA repo, as well as the [`race_of_focus_fb2022.rdata`](https://github.com/Wesleyan-Media-Project/race_of_focus/blob/main/data/race_of_focus_fb2022.rdata) file from the race_of_focus repo.
- ad_tone_constructed/ad_tone_constructed_g2022.R requires the [`google_2022_ABSA_pred.csv.gz`](https://github.com/Wesleyan-Media-Project/ABSA/blob/main/data/google_2022_ABSA_pred.csv.gz) file from the ABSA repo, as well as the [`race_of_focus_google_2022.rdata`](https://github.com/Wesleyan-Media-Project/race_of_focus/blob/main/data/race_of_focus_google_2022.rdata) file from the race_of_focus repo.

Legacy script for pre-2022 data production, preserved here for internal use:

- ad_tone_constructed/ad_tone_constructed_fb140m.R requires the [`140m_ABSA_pred.csv.gz`](https://github.com/Wesleyan-Media-Project/ABSA/blob/main/data/140m_ABSA_pred.csv.gz) file from the ABSA repo, as well as the [`race_of_focus_140m.rdata`](https://github.com/Wesleyan-Media-Project/race_of_focus/blob/main/data/race_of_focus_140m.rdata) file from the race_of_focus repo.

In addition, all scripts within the ad_tone_constructed folder require the ad tone mention-based results (see above).

### 3.3 Run Files

Now, depending on which variable and what data you are interested in analyzing, and you can run the script you want accordingly. For example, to do the mention-based classification for Facebook 2022 data, run [ad_tone_mentionbased_fb2022.R](https://github.com/Wesleyan-Media-Project/ad_tone/blob/main/ad_tone_mentionbased_2022/ad_tone_mentionbased_fb2022.R).

Running the scripts through the terminal would look like this

```bash
cd ad_tone_mentionbased_2022
Rscript ad_tone_mentionbased_fb2022.R
```

and can also alternatively be done through the RStudio interface.

## 4. Thank You

<p align="center"><strong>We would like to thank our supporters!</strong></p><br>

<p align="center">This material is based upon work supported by the National Science Foundation under Grant Numbers 2235006, 2235007, and 2235008.</p>

<p align="center" style="display: flex; justify-content: center; align-items: center;">
  <a href="https://www.nsf.gov/awardsearch/showAward?AWD_ID=2235006">
    <img class="img-fluid" src="nsf.png" height="150px" alt="National Science Foundation Logo">
  </a>
</p>

<p align="center">The Cross-Platform Election Advertising Transparency Initiative (CREATIVE) is a joint infrastructure project of the Wesleyan Media Project and privacy-tech-lab at Wesleyan University in Connecticut.

<p align="center" style="display: flex; justify-content: center; align-items: center;">
  <a href="https://www.creativewmp.com/">
    <img class="img-fluid" src="CREATIVE_logo.png"  width="220px" alt="CREATIVE Logo">
  </a>
</p>

<p align="center" style="display: flex; justify-content: center; align-items: center;">
  <a href="https://mediaproject.wesleyan.edu/">
    <img src="wmp-logo.png" width="218px" height="100px" alt="Wesleyan Media Project logo">
  </a>
</p>

<p align="center" style="display: flex; justify-content: center; align-items: center;">
  <a href="https://privacytechlab.org/" style="margin-right: 20px;">
    <img src="./plt_logo.png" width="200px" alt="privacy-tech-lab logo">
  </a>
</p>
