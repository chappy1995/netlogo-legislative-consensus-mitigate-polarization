# netlogo-legislative-consensus-mitigate-polarization
Consider an electoral trigger mechanism that forces consensus-building by automatically reducing term limits of an elected government body if no consensus emerges on any topics from that elected government body. How could this mechanism impact polarization buildup? 
**Modeling objective:** agent-based model (ABM) as a tool to address this question.


## WHAT IS IT?

This model implements a framework to explore this research question: "No government can govern to the satisfaction of all its people and in fact policy-making can be assumed to be an instrument that favors some at the dissatisfaction of others (real or perceived). Elected official turnover permits renewal of priorities to satisfy others previously dissatisfied. However, polarization introduces a belief in groups that their demands must always be satisfied. Autocracies can arise as a consequence of such expectations. Consensus-building can reduce dissatisfaction and thus mitigate the polarization feedback. Consider an electoral trigger mechanism that forces consensus-building by automatically reducing term limits of an elected government body if no consensus emerges on any topics from that elected government body. How could this mechanism impact polarization buildup?"

As written, the question does not provide specifics on how satisfaction, or the lack thereof, is manifested, what type and level of governing body, the nuanced and multilayered factors that influence polarization (political party affiliation, lobbying, and the ideologies of both the elected official and their represented area), the specific features and dynamics of the governing body in question, and most importantly, how consensus is defined. Nonetheless, this model serves as a framework which could be adapted for the study of derivations of the question that address more specific and realistic scenarios.

The model's premise is that two conflicting forces impact each elected official's voting behavior: 
1) Polarization rating - this is oversimplified here as a single factor representing the culmination of the aforementioned influences, including satisfaction (note that a new legislator replacing one who reached the terms limit will have a polarization rating that can swing up to 20% in either direction from their predecessor). 
2) Reaching consensus to prevent further reduction in the terms limit.

The model makes the following assumptions for this framework:

•	Although not mentioned in the question, the model will focus on democratic consensus-building, where consensus decision-making asserts that consensus is built upon acceptance of a majority vote, not necessarily agreement with a majority vote.

•	A legislative body will be the environment; this is the only type of government body that is consistently subject to elections in all levels of government worldwide. 

•	The model assumes legislators are subject to elections each term. This is not the case for all legislatures (the model could be adapted for overlapping terms of legislators on different election cycles).

•	The model assumes a terms limit exists and will not factor in the opposite scenario given that the question focuses on the impact of term limits.

•	This model will use legislative policy votes as a measure of consensus-building, and henceforth will be referred as “policy votes.” The model assumes votes for substantive policy matters only – no renaming of post offices.

Note that this model intentionally does not implement representations of specific political parties and also makes no mention of where on the polarization scale is "left" or "right." To build a framework to examine polarization vs. consensus, these labels are not necessary and would only induce biases if implemented (future adaptations could use a different approach).


## HOW IT WORKS

•	The policy votes are the ticks. Specific time increments are not a factor in the model as designed, but the user may use inputs that reflect a realistic range of terms served for a specific legislature.

•	Each elected legislator has a polarization-rating which, as mentioned, is an oversimplified single value to represent multiple factors (see WHAT IS IT? section). This is on a scale of integers 0 to 49 with no legislator being assigned the exact middle of 24.5. This is randomly assigned at setup to assure a fairly even distribution for most model executions.

•	For each policy vote there is a policy-rating ranging from 15 to 34, which is the middle 40% of the polarization-rating scale under the premise that only those policies which stand a chance of enactment are brought up for a vote. 

•	Each legislator will have a compromise-tolerance, which gauges how far beyond their polarization-rating, in either direction, they would be willing to vote in the interest of consensus-building. At setup this will be randomly assigned as a value between 0 and a global max-compromise-tolerance value.

•	At setup each legislator will be randomly assigned a terms-of-service value to represent how many terms they have served thus far. A terms-limit global value will be the maximum for the randomly generated terms-of-service value.

•	The model will use legislative terms (global "term") with a varying number of policy votes per term. The user will be able to set the minimum-votes-per-term and maximum-votes-per-term values, and for each new session the number of votes will be randomly assigned within that range. If the user wants the same number of votes per term (which is not realistic), the user can set the min and max to the same value.

•	A global number of legislators will be set by the user, defaulting to 100. This will allow for examination of legislative bodies of different sizes. Local governing bodies are typically much smaller than those at state/province and national levels.

•	As alluded above, years per term is intentionally not a global input. The user can and should use a max term limits value that is appropriate for the legislative body being examined. For example, for six-year terms a 15-term limit is not a reasonable setting; no elected legislator has ever served 90 years. Even though the model will reduce the terms limit for non-consensus, the expectation is that the user will initiate the model with a reasonable value.

OPERATIONAL NOTES:

•	A "Yay" vote is determined by whether each legislator's polarization-rating combined with their compromise-tolerance will reach the policy-rating for the policy raised for a vote.

•	To account for the competing interests of polarization and the need for consensus-building to avoid a reduction in the terms limit, each legislator’s compromise tolerance will increase after each term within five terms of the terms-limit where consensus is not reached. This is done progressively: increase of 1 for 5 terms away from the limit, increase of 2 for 4 terms away, etc.

•	Consensus will be measured simply by the number of votes in favor of each policy vote. If or when the vote reaches a 50% + 1 majority, consensus has been reached. 

•	When a legislator reaches the terms-limit, they are replaced by a new legislator who assigned the polarization-rating +/- 20% to represent public swings due to satisfaction/dissatisfaction, the terms-of-service-count is set to 0, and a new compromise-tolerance will be randomly assigned. (The model will actually use the same turtle with updated values instead of "killing" and recreating it).

•	The model will stop when either 1) consensus is reached within a legislative term - but note that the model will finish processing a term even if consensus is already reached - or 2) the terms-limit cannot be reduced further. A message will be posted to the user for either result.

## HOW TO USE IT

Set the inputs for number-of-legislators, terms-limit, minimum-votes-per-term, maximum-votes-per-term, and max-compromise-tolerance. The terms-limit is the only input that will change during the model execution. The others just impact initialization.

The "setup" button must be pushed first to initialize variables. Then the "go once" button will run the model through a single vote. The "go" button will run the model until either stop condition is met, which is either consensus being reached or a reduction in the terms-limit is no longer possible.

Pay most attention to the "Percentage of 'Yay' by Policy Vote (red line = 50%, if shown)" plot in the center to track the voting swings and general trend. Other plots are provided for both the votes-based activity and the terms-based activity to inform what is being seen in the main plot. These should be self-explanatory by their titles.

## THINGS TO NOTICE

•	If the terms-limit and max-compromise-tolerance are both set to 7 with the other inputs left at their default values (100 legislatures and 11-20 votes per term), a mix should be seen in the results of consensus being met and the terms-limit being reduced to the minimum (both scenarios causing the model to stop). This is a good place to start to enable understanding of the different model behaviors.

•	Both the max-compromise-tolerance and the terms-limit have an impact on whether consensus is met or not. Raising and lowering these two values for different executions will reveal various voting trends and behaviors.

•	It may be noticeable in the first few terms when a higher terms-limit and lower max-compromise-tolerance value is used that a spike occurs in votes that get close to the 50% line and then drop off (occasionally this does reach the 50% mark and an early consensus). The drop-off is suspected to be due to a number of legislators initialized with a higher terms-of-service-count reaching the terms-limit quickly.

•	Legislators discontinuing service due to other factors (change in profession, death, etc.) is not factored in the model in the interest of simplicity for creating this initial framework. This is a potential adaptation for future model derivations.

## THINGS TO TRY

The "THINGS TO NOTICE" section intertwines both things to notice and things to try in the current model.

POTENTIAL ADAPTATIONS FOR FUTURE MODELS:

•	The polarization-rating could be split into multiple factors of influence such as political party affiliation, lobbying, the legislator's personal views, the ideological rating of the district represented, etc. 

•	More flexibility could be applied to accommodate legislative terms where some legislators are not subject to reelection. For example, the U.S. Senate only holds elections for 1/3 of its members each term (which are called "sessions").

•	The progressive increases in compromise-tolerance after terms with no consensus reached is arbitrarily based on an assumption that a looming terms-limit will increase motivation as the limit approaches. Again, this was implemented in the interest of an operable framework. This aspect warrants further research and adaptation in future derivations of this model.

•	The distribution of terms-of-service-count values for legislators created at setup is also somewhat arbitrary and may warrant adjustments. Each legislator created is assigned a value based on percentages of the range of values allowed.

## NETLOGO FEATURES

This model is intended as a tool to assess the research question in the "WHAT IS IT?" section and as a framework upon which future models may be built to address more insightful and impactful derivations of that same question.

## RELATED MODELS



## CREDITS AND REFERENCES


## HOW TO CITE

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2009 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

<!-- 2009 Cite: Li, J. -->
