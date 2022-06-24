# Ad tone

## Ad tone constructed
Based on [this](https://docs.google.com/presentation/d/11E9kX1oVYfMooTdD1GAJfwJtdPIQpYB3lJ7i5e83ZEw/edit#slide=id.g1062def0ba3_0_0) flowchart. The variable is available for about 750k ads, the rest are either in the down ballot candidate or rightmost branch (blue box 4-5) of the flowchart and have no ad tone.

To run the script that constructs this variable, [ABSA](https://github.com/Wesleyan-Media-Project/ABSA), [race of focus](https://github.com/Wesleyan-Media-Project/race_of_focus), and mention-based ad tone are required.

## Ad tone mention-based
Mention-based ad tone codes ads as 'Contrast' if both the candidate and their opponent are mentioned (either in text, or in image appearance), 'Promote' if only the candidate is mentioned, and 'Attack' if only the opponent is mentioned. If no candidate is mentioned, the ad is coded as 'Support' (given that the basic purpose of an ad is to further the preferred candidate's electoral prospects). This variable is available for the 494,348 candidate ads in the 1.18m dataset. 

To run the script that constructs this variable, the candidates dataset and the [race of focus](https://github.com/Wesleyan-Media-Project/race_of_focus) results are required.

