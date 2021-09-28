# Labyrinth Walker

This Autohotkey script goes through the Labyrinth dungeons in Final Fantasy Record Keeper semi-automatically. It will play an alarm whenever a Treasure Room is entered so you can choose which chests to open.

Requirements:

- Autohotkey installed on your PC
- Your favorite Android emulator (I used Nox with a mobile window resolution of 540x960)
- Your FFRK settings must be set to "Simplified Display" or else some animations will cause Autohotkey's ImageSearch to fail.
- Your top team must be unbeatable even at 10 fatigue points. A Holy Magic team is highly recommended.

To get this script to work you need to replace the snips in the "images" folder with your own. Take screenshots with Windows Snipping Tool while going through the dungeon manually. After all the images have been replaced with your own press F1 to unpuase/pause the script. You can press F2 to panic close the script.

If you want to make your own changes to the script open FFRK Labyrinth.ahk with notepad. Remember to exit and reload the script after saving changes. You can change the priority of the paintings by simply changing the order variables inside the script with notepad.
```
PaintingPriority := []
PaintingPriority.Push("painting_treasure")
PaintingPriority.Push("painting_exploration")
PaintingPriority.Push("painting_restoration")
PaintingPriority.Push("painting_onslaught")
PaintingPriority.Push("painting_combatred")
PaintingPriority.Push("painting_combatorange")
PaintingPriority.Push("painting_combatgreen")
PaintingPriority.Push("painting_portal")
PaintingPriority.Push("painting_boss:)
```

## Additional Features:
### Chest
The script open the chest based on the state file supplied by other proxy app e.g. RK Squared, in the format of CSV
```
5,3,1
``` 
Representing the left, middle and right chest id, set *MinOpenChestId* to control the minimum type to collect from

The other configurations are:
```
OpenChest=yes ;set to yes to enable
MinOpenChestId=3
ChestFile=C:\Users\WindowUser\AppData\Roaming\RK Squared\state\chest.txt 
```
### Party Selection
The script also consider the party selection based on the state file supplied by other proxy app e.g. RK Squared, in the format of CSV
```
Bahamut,50,35,0
```
Representing enemy name, first party total fatigue, second party total fatigue, third party total fatigue

The script also defines the __CombatRules__ with format __"Enemy name":= \[order of party number\]__, 
```
CombatRules := {"Bahamut":[3,1,2]}
```
Configured that the 3rd party will be first preference followed by 1st and 2nd, remove the party number from the \[\] if do not wish to be selected (e.g. Red Giant absorb lightning). If __ConsiderFatigue__ set to yes, then it would read party fatigue from the state file and compare with the __FatigueThreshold__.
It then select the next best party from the order, default to first party when all party fatigue check failed.

The other configurations are:
```
SelectParty=yes ;Select party based on combat state text file and rules in CombatRules
SelectPartyOffsetY=60 ;offset click to reach center for party selection before Battle 
ConsiderFatigue=yes
FatigueThreshold := 35
CombatFile=C:\Users\WindowUser\AppData\Roaming\RK Squared\state\combat.txt ;change the path to your local RK Squared installation
CombatRules := {"Bahamut":[3,1,2], "Ramza": [3,2,1], "Ravus": [1,3,2], "Twintania": [1,2,3], "Vajra": [1,2,3], "Wendigo": [2,1,3]
,"Alexander": [2,3,1], "Behemoth": [3,1,2], "Brynhildr": [2,1,3], "Byblos": [2,1,3], "Chaos": [3,1,2], "Leviathan":[2,1,3]
,"Marilith": [3,1,2], "Nidhogg": [2,1,3], "Ultima Weapon":[1,2,3]
,"Adamanchelid": [2,1,3], "Atomos": [1,3,2], "Black Waltz No.2": [3,1,2], "Deathclaw": [1,2,3], "Green Dragon": [1,2,3]
,"Guard Scorpion": [2,1,3], "Iron Giant": [1,3], "Lunasaur": [2,1,3], "Red Giant & Catoblepas": [1,3]
,"Elvoret": [2,1,3]}
```
