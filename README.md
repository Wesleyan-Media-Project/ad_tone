# Wesleyan Media Project - Ad Tone

Welcome! This repo is part of the Cross-platform Election Advertising Transparency initiatIVE (CREATIVE) project. CREATIVE is a joint infrastructure project of WMP and privacy-tech-lab at Wesleyan University. CREATIVE provides cross-platform integration and standardization of political ads collected from Google and Facebook.

This repo is part of the Final Data Classification section.

The scripts for ad tone mention-based, all require the [candidates dataset](https://github.com/Wesleyan-Media-Project/datasets) to be cloned into the same top-level folder as the ad_tone repo. Depending on the specific script being run, other repos are also required, which is discussed in more detail in setup.

The scripts in this repo that concern ad_tone_construced all require data from the [ABSA dataset](https://github.com/Wesleyan-Media-Project/ABSA) as well as the [race of focus dataset](https://github.com/Wesleyan-Media-Project/race_of_focus). In addition, mention-based ad tone is also needed (see above). Again, these are assumed to be cloned into the same top-level folder as the entity_linking repo. Some csv files in those repos are too large to be uploaded to GitHub. You can download them through our Figshare page.

[A picture of the repo pipeline with this repo highlighted]
https://camo.githubusercontent.com/f7339b7a62588f2b2931a9e7de16801f2686a1d8a69d979a3a440131abc82322/68747470733a2f2f6d6564696170726f6a6563742e7765736c6579616e2e6564752f77702d636f6e74656e742f75706c6f6164732f323032332f30362f776d705f706970656c696e655f3131313732325f746162732e706e67

## Table of Contents

- [Introduction](#introduction)

- [Objective](#objective)

- [Data](#data)

- [Setup](#setup)

## Introduction

This repository contains code that generates two variables: ad tone mention-based, which codes ad as 'contrast, 'promote' or 'attack', as well as ad tone constructed, which is based on [this](https://docs.google.com/presentation/d/11E9kX1oVYfMooTdD1GAJfwJtdPIQpYB3lJ7i5e83ZEw/edit#slide=id.g1062def0ba3_0_0) flowchart.

This repo contains 8 R scripts, three that deal with ad tone constructed and five that deal with ad tone mention-based. Of the five scripts related to ad tone mention-based, three are in one folder called "ad_tone_mentionebased" and another two are in another folder called "ad_tone_mentionbased_2022". All of the files in "ad_tone_constructed" do equivalent things to each other, they just do so for different data, and the same is true for all of the ad tone mention-based files.

## Objective

Each of our repos belongs to one or more of the the following categories:

- Data Collection
- Data Storage & Processing
- Preliminary Data Classification
- Final Data Classification

This repo is part of the Final Data Classification section.

## Data

The code in this repository creates two variables, ad tone mention-based, and ad tone constructed. Results are saved as a csv file, in the data folder.

### Ad tone mention-based

Mention-based (or reference-based) ad tone codes ads as 'Contrast' if both the candidate and their opponent are mentioned (either in text, or in image appearance), 'Promote' if only the candidate is mentioned, and 'Attack' if only the opponent is mentioned. If no candidate is mentioned, the ad is coded as 'Support' (given that the basic purpose of an ad is to further the preferred candidate's electoral prospects). This variable is available for the candidate ads in the 1.4m dataset.

### Ad tone constructed

The construction of ad tone is based on [this](https://docs.google.com/presentation/d/11E9kX1oVYfMooTdD1GAJfwJtdPIQpYB3lJ7i5e83ZEw/edit#slide=id.g1062def0ba3_0_0) flowchart. When traditional mention-based ad tone is available, we use that; otherwise we sum over ABSA results (also using race of focus). The variable is available for a larger number of ads, and the rest are either in the down ballot candidate or rightmost branch (blue box 4-5) of the flowchart and have no ad tone.

## Setup

### 1. Install R and Packages

First, make sure you have R installed. In addition, while R can be run from the terminal, many people find it much easier to use r-studio along with R. <br>
https://rstudio-education.github.io/hopr/starting.html
<br>
Here is a link that walks you through downloading and using both programs. <br>
The scripts use R (4.2.2).
<br>
Next, make sure you have the following packages installed in R (the exact version we used of each package is listed [in the requirements_r.txt file)](https://github.com/Wesleyan-Media-Project/ad_tone/blob/main/requirements_r.txt) : <br>
data.table <br>
stringr <br>
purrr <br>
dplyr <br>
tidyr <br>
R.utils

### 2. Download Files Needed

In order to use the scripts in this repo, you will need to download the repository into a top level folder. In addition, depending on which scripts you are running, additional repositories will also be necessary. Specifically which repositories are needed depends on which script you are executing.

All the scripts for ad tone mention-based require [datasets](https://github.com/Wesleyan-Media-Project/datasets). In addition, depending on the specific script, various other repos must also be downloaded. Looking at those scripts found within the ad_tone_mentionbased folder, ad_tone_mentionbased/ad_tone_heuristic_tv_2020.R requires the [entity linking repo](https://github.com/Wesleyan-Media-Project/entity_linking). ad_tone_mentionbased/ad_tone_mentionbased_FB_140m.R requires [race of focus](https://github.com/Wesleyan-Media-Project/race_of_focus), [fb_2020](https://github.com/Wesleyan-Media-Project/fb_2020) and [entity linking](https://github.com/Wesleyan-Media-Project/entity_linking). ad_tone_mentionbased/ad_tone_mentionbased_Google_2020.R requires [race of focus](https://github.com/Wesleyan-Media-Project/race_of_focus), [entity linking](https://github.com/Wesleyan-Media-Project/entity_linking) and [google_2020](https://github.com/Wesleyan-Media-Project/google_2020). Some csv files in those repos are too large to be uploaded to GitHub. You can download them through our Figshare page.

Looking at the scripts within the ad_tone_mentionbased_2022 folder, they again all require [datasets](https://github.com/Wesleyan-Media-Project/datasets). In addition, depending on the specific script, various other repos must also be downloaded. Specifically, ad_tone_mentionbased_2022/ad_tone_mentionbased_fb2022.R requires the [entity linking 2022 repo](https://github.com/Wesleyan-Media-Project/entity_linking_2022) and the [data-post-production repo](https://github.com/Wesleyan-Media-Project/data-post-production). ad_tone_mentionbased_2022/ad_tone_mentionbased_g2022.R requires the [entity linking 2022 repo](https://github.com/Wesleyan-Media-Project/entity_linking_2022) as well, along with the [data-post-production repo](https://github.com/Wesleyan-Media-Project/data-post-production). Some csv files in those repos are too large to be uploaded to GitHub. You can download them through our Figshare page.

All the scripts in this repo that concern ad_tone_constructed require the [ABSA dataset](https://github.com/Wesleyan-Media-Project/ABSA) as well as the [race of focus dataset](https://github.com/Wesleyan-Media-Project/race_of_focus) and ad tone mention-based (see above). This includes ad_tone_constructed/ad_tone_constructed_fb140m.R, ad_tone_constructed/ad_tone_constructed_fb2022.R and ad_tone_constructed/ad_tone_constructed_g2022.R.

### 3. Run Files

Now, depending on which variable and what data you are interested in analyzing, choose which file to run and do so.

Running the scripts through the terminal would look like this

```
cd ad_tone_mentionbased
Rscript ad_tone_mentionbased_FB_140m.R
```

and can also alternatively be done through the RStudio interface.
