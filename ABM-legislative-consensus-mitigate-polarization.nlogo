;;define global code variables
globals [
  consensus?
  term
  num-votes-current-term
  votes-remaining-current-term
  policy-rating
  percent-yes-votes
  avg-polarization
  avg-compromise-tolerance
  avg-terms-of-service
  num-terms-limited-this-term
  num-terms-limited-total
  model-status-message
]

;;define legislators
turtles-own [
  terms-of-service-count
  compromise-tolerance
  polarization-rating
  current-policy-yes-votes
]

;;
;; Setup Procedure to initialize code variables.
to setup
  clear-all
  set consensus? false
  set term 1
  set num-votes-current-term  (minimum-votes-per-term + random (maximum-votes-per-term - minimum-votes-per-term + 1))
  set votes-remaining-current-term num-votes-current-term
  set policy-rating ((random 20) + 15)
  set num-terms-limited-this-term 0
  set num-terms-limited-total 0
  legislator-turtle-setup
  reset-ticks
  ;;reset the pens for the term plots, which will be controlled by the Code here.
  set-current-plot "Average Polarization by Term"
  plot-pen-reset
  set-current-plot "Average Compromise Tolerance by Term"
  plot-pen-reset
  set-current-plot "Average Terms of Service by Term"
  plot-pen-reset
  set-current-plot "Number Term-limited by Term"
  plot-pen-reset
end

;;create the legislators
to legislator-turtle-setup ;; turtle procedure
  create-turtles number-of-legislators
  [
    ;;The initial legislators are assigned terms-of-service-count values randomly,
    ;;with the values distributed between 1 and the term-limit parameter.
    ;;This realistically assumes not all active legislators began serving at the
    ;;same time.
    let choice random 5
    set terms-of-service-count (ifelse-value
      choice = 0 [random round(terms-limit * .4)]
      choice = 1 [random round(terms-limit * .4)]
      choice = 2 [round(terms-limit * .4) + random round(terms-limit * .4)]
      choice = 3 [round(terms-limit * .4) + random round(terms-limit * .4)]
      choice = 4 [round(terms-limit * .8) + random round(terms-limit * .2)]
      )
    ;;each legislator given a polarization rating from 0 to 49.
    ;;24.5 represents the exact "middle" even though no leg can be assigned that.
    set polarization-rating random 50
    set compromise-tolerance (random (max-compromise-tolerance + 1)) ;;randomly assigned based on slider input.
  ]
end

;;
;; Runtime Procedures
;;

to go
  ;;each tick is a policy vote, but the votes are organized into terms
  ;;These first 20-ish lines of code manage the change of legislative terms.
  if (votes-remaining-current-term = 0)  ;;this marks that a term has completed.
  [
    update-histograms  ;;update the term histograms since a term just ended.
    if (not consensus?) [set terms-limit (terms-limit - 1)]
    if ((consensus?) or (terms-limit = 0)) ;;if consensus reached or terms-limit cannot be decreased further, then stop.
    [
      if (consensus?) [user-message ("Consensus reached!")]
      if (terms-limit = 0) [user-message ("Consensus not reached, terms limit may not be decreased further.")]
      stop
    ] ;;consensus? is checked in this section so all votes in the term are processed before stopping.
    set num-terms-limited-this-term 0
    set term (term + 1)  ;;increment the overall term identifier/count.
    set num-votes-current-term  (minimum-votes-per-term + random (maximum-votes-per-term - minimum-votes-per-term + 1))
    set votes-remaining-current-term num-votes-current-term
    ask turtles
    [
      set terms-of-service-count (terms-of-service-count + 1)  ;;increment terms count
      ;;if (terms-of-service-count != terms-limit) [set compromise-tolerance (compromise-tolerance + compromise-tolerance-increase-for-non-consensus)]
      ;;line below increases the compromise-tolerance progressively higher for the 5 terms leading up to the terms-limit.
      ;;If the terms-limit is initialized at less than 5, the increases would be same for those terms.
      if (terms-of-service-count < terms-limit) [set compromise-tolerance (compromise-tolerance + (max list 0 (8 - (terms-limit - terms-of-service-count))))]
      ;;tolerance (tolerance + (max 0 (6 - (terms-limit - terms-served)))
      if (terms-of-service-count >= terms-limit)  ;;only "=" should be needed but using ">=" as an extra precaution
      [
        set num-terms-limited-this-term (num-terms-limited-this-term + 1)
        set num-terms-limited-total (num-terms-limited-total + 1)
        set terms-of-service-count 0
        ;;each new legislator given a polarization rating.
        ;;The new legislator can only shift in polarization -10 to +10 from the terms limited one.
        ;;let polarization-shift ((random 21) - 10)  ;;this will assign random shift from -10 to 10
        ;;below the shift is applied to the turtle's polarization rating while staying in the 0 to 49 range.
        set polarization-rating (max(list 0 min(list 49 (polarization-rating + ((random 21) - 10)))))
        set compromise-tolerance (random (max-compromise-tolerance + 1)) ;;5 is based on a polarization-rating of 0 to 49
      ]
    ]
  ]
  ;;the rest of the go procedure performs the vote, determines if consensus is reached by
  ;;achieving a majority vote (consensus = accepting the majority opinion), and computing global aggregates.
  set policy-rating ((random 20) + 15)
  ask turtles
  [
    set current-policy-yes-votes ((abs(polarization-rating - policy-rating)) <= compromise-tolerance)
  ]
  set percent-yes-votes (count turtles with [ current-policy-yes-votes ]) / (count turtles) * 100
  if (percent-yes-votes > 50) [set consensus? true]
  set avg-polarization ((sum [polarization-rating] of turtles) / (count turtles))
  set avg-compromise-tolerance ((sum [compromise-tolerance] of turtles) / (count turtles))
  set avg-terms-of-service ((sum [terms-of-service-count] of turtles) / (count turtles))
  set votes-remaining-current-term (votes-remaining-current-term - 1)
  tick
end

;;The update-histograms procedure sets the values in the legislative term plots on the interface.
;;These are used to provide insights for the user of what is occurring at the legislative term level.
to update-histograms
  set-current-plot "Average Polarization by Term"
  ;;plot-pen-reset
  set-plot-pen-mode 1     ;; bar mode
  set-plot-pen-color red
  plot avg-polarization
  set-current-plot "Average Compromise Tolerance by Term"
  set-plot-pen-mode 1     ;; bar mode
  set-plot-pen-color green
  plot avg-compromise-tolerance
  set-current-plot "Average Terms of Service by Term"
  set-plot-pen-mode 1     ;; bar mode
  set-plot-pen-color blue
  plot avg-terms-of-service
  set-current-plot "Number Term-limited by Term"
  set-plot-pen-mode 1     ;; bar mode
  set-plot-pen-color orange
  plot num-terms-limited-this-term
end
@#$#@#$#@
GRAPHICS-WINDOW
0
10
33
44
-1
-1
12.5
1
10
1
1
1
0
1
1
1
0
1
0
1
1
1
1
ticks
30.0

BUTTON
0
50
80
90
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
85
50
175
90
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
180
50
270
90
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

TEXTBOX
45
10
650
46
1995 ABM Project: Term Limits for Consensus-Building
22
14.0
1

SLIDER
10
280
197
313
Minimum-Votes-Per-Term
Minimum-Votes-Per-Term
5
50
11.0
1
1
NIL
HORIZONTAL

SLIDER
10
315
200
348
Maximum-Votes-Per-Term
Maximum-Votes-Per-Term
10
100
20.0
1
1
NIL
HORIZONTAL

MONITOR
325
50
457
95
# of Votes This Term
num-votes-current-term
17
1
11

MONITOR
460
50
632
95
# Votes Remaining This Term
votes-remaining-current-term
17
1
11

MONITOR
275
50
325
95
Term
term
17
1
11

PLOT
225
115
750
330
Percentage of "Yay" by Policy Vote (red line = 50%, if shown)
Policy Votes
% of "Yay" Votes
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot percent-yes-votes"
"majority-line" 1.0 0 -2674135 true "" ";; we don't want the \"auto-plot\" feature to cause the\n;; plot's x range to grow when we draw the axis.  so\n;; first we turn auto-plot off temporarily\nauto-plot-off\n;; now we draw an axis by drawing a line from the origin...\nplotxy 0 50\n;; ...to a point that's way, way, way off to the right.\nplotxy 1000000000 50\n;; now that we're done drawing the axis, we can turn\n;; auto-plot back on again\nauto-plot-on"

PLOT
225
465
750
615
Votes by Legislative Term
Policy Votes
Term
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "plot term"

PLOT
765
10
1035
160
Average Polarization by Term
Terms
Average
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -7500403 true "" ""

PLOT
225
340
750
465
Policy Rating by Vote
Policy Votes
Rating
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot policy-rating"

PLOT
765
160
1035
310
Average Compromise Tolerance by Term
Terms
Average
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

PLOT
765
310
1035
435
Average Terms of Service by Term
Terms
Average
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

MONITOR
635
50
747
95
Total Term-limited 
num-terms-limited-total
17
1
11

PLOT
765
435
1035
615
Number Term-limited by Term
Terms
# Term-limited
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

SLIDER
0
135
210
168
Terms-limit
Terms-limit
1
30
7.0
1
1
NIL
HORIZONTAL

TEXTBOX
15
110
165
135
Setup Inputs:
16
0.0
1

SLIDER
10
410
202
443
Max-Compromise-Tolerance
Max-Compromise-Tolerance
1
20
7.0
1
1
NIL
HORIZONTAL

SLIDER
0
180
220
213
Number-of-Legislators
Number-of-Legislators
3
1000
100.0
1
1
NIL
HORIZONTAL

TEXTBOX
20
235
170
276
Minimum & Maximum votes per term set the range for the randomly determined number.
11
0.0
1

TEXTBOX
15
365
220
405
Max-Compromise-Tolerance sets the highest possible tolerance value assigned randomly at setup to each legislator.
11
0.0
1

@#$#@#$#@
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
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
