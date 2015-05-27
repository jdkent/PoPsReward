# PoPsReward
HOW TO (SET VARIABLES OF/USE) THE SCRIPT:
You still need to open script to make changes (not typically recommended, but you have to in this instance). At the top of the script there should be indicators of where the user can change the experimental variables. This includes but is not limited to: inter-stimulus-interval, size of targets/distractors, what the reward images are, etc. After the proper changes are made, simply open matlab and navigate to the directory this script is located (currently /Users/grad_user/Desktop/PoPsReward_Summer_2015/PoPsReward-master) and type "PoPsReward" (without quotes) on the matlab command line interface. Then enter the subject number as instructed and follow the directions given by the script.


To Do (Relatively simple to complete before using task):
1) Find what Bills need to used as the reward

2) Change the instructions to reflect the change in target orientation (previously Up/Down, currently Left/Right)

3) Decide on key bindings to correspond to left target and right target.



To Do (relatively complex, not essential changes, but for the longevity of the script)

1) 
Priority: medium
The target color is not completely balanced between subjects or between blocks, This is due to the determination of whether a target repetition will occur during that trial by the variable "TargetRepetition". So in order to make sure target color is completely balanced, certain constraints have to be placed on whether the current trial can repeat the target or not (so instead of TargetRepetition being pseudo-randomized within each block, an additional counter will have to make sure that target color is balanced and make changes to the order of TargetRepetition as necessary). 
This problem doesn't widely skew the number of Green and Red targets, and should balance out between Blocks and subjects (not necessarily, but probabilistically through the law of large numbers), but this quirk is worth noting and thinking about.

2)
Priority: low
The code is still somewhat messy and some lines could be repetitious, but this has not yet proved to be a problem for testing the script. Could be useful exercise to walk through and comment script in order to understand what is going on at each step of the code.

3)
Priority: medium-high
In addition to messiness, the user still has to open script to make relevant changes to variables, and does not provide optimal user experience. While the variables to be defined by the user are at the top of the script, I've had to abandon the current coding dogma of defining variables when I need them, not at the top of the script. A better solution will be to change the script such that it can take more arguments to change the experimental settings and provide a help dialogue to help make those changes. 

4) 
Priority: High?
The first trial for each block will be the exact same. This is done because we wanted there to be equal numbers or repeat/switch trials, so I had to repeat the first trial at some point during the block, and this was the most efficient solution given the code. However, participants may catch on and develop a predictive action for the first trial. However, However, The first trial is not of particular interest since it cannot be a repeat or switch trial and is typically excluded from analysis.
