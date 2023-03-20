# Ad tone
This repository creates two variables, ad tone mention-based, and ad tone constructed.

### Ad tone mention-based
Mention-based (or reference-based) ad tone codes ads as 'Contrast' if both the candidate and their opponent are mentioned (either in text, or in image appearance), 'Promote' if only the candidate is mentioned, and 'Attack' if only the opponent is mentioned. If no candidate is mentioned, the ad is coded as 'Support' (given that the basic purpose of an ad is to further the preferred candidate's electoral prospects). This variable is available for the candidate ads in the 1.4m dataset. 

### Ad tone constructed
Based on [this](https://docs.google.com/presentation/d/11E9kX1oVYfMooTdD1GAJfwJtdPIQpYB3lJ7i5e83ZEw/edit#slide=id.g1062def0ba3_0_0) flowchart. When traditional mention-based ad tone is available, we use that, otherwise we sum over ABSA results (also using race of focus). The variable is available for a larger number of ads, the rest are either in the down ballot candidate or rightmost branch (blue box 4-5) of the flowchart and have no ad tone.

## Usage
To run the script for ad tone mention-based, the [candidates dataset](https://github.com/Wesleyan-Media-Project/datasets) and the [race of focus](https://github.com/Wesleyan-Media-Project/race_of_focus) results are required. Those repos are assumed to be cloned into the same top-level folder as the entity_linking repo. Then navigate to the folder and run the script, like this:
```
cd ad_tone_mentionbased
Rscript ad_tone_mentionbased_FB_140m.R
```

To run the script for ad tone constructed, [ABSA](https://github.com/Wesleyan-Media-Project/ABSA), [race of focus](https://github.com/Wesleyan-Media-Project/race_of_focus), and mention-based ad tone (see above) are required. Those repos are assumed to be cloned into the same top-level folder as the entity_linking repo. Then navigate to the folder and run the script, like this:

```
cd ad_tone_constructed
Rscript ad_tone_constructed_fb140m.R
```

## Requirements
The scripts use R (4.2.2). The packages we used are described in `requirements_r.txt`.

## To-do
The script for 2022 is not necessarily up-to-date, and the scripts for Google and TV (2020) only exist on my computer and are definitely not up-to-date.
