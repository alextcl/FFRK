# Labyrinth Walker

This Autohotkey script goes through the Labyrinth dungeons in Final Fantasy Record Keeper semi-automatically. It will play an alarm whenever a Treasure Room is entered so you can choose which chests to open.

Requirements:

- Autohotkey installed on your PC
- Your favorite Android emulator (I used Nox with a mobile window resolution of 540x960)
- Your FFRK settings must be set to "Simplified Display" or else some animations will cause Autohotkey's ImageSearch to fail.
- Your top/first team must be unbeatable even at 10 fatigue points. A Holy Magic team is highly recommended.

## Getting started and basic usage
If you want to make your own changes to the script open FFRK Labyrinth.ahk with notepad. Remember to exit and reload the script after saving changes. Keep the emulator resolution as small as possible (e.g. 540*960 in Nox).

The basic configuration are 
```AutoHotkey
SearchMethod:="ImageSearch" ;use FindText or ImageSearch
EmulatorAppName:= "NoxPlayer" ;set this to the name of the emulator app
StateFileDir=C:\Users\{User}\AppData\Roaming\RK Squared\state\ ;change the path to your local RK Squared installation
DefaultSleepTime=1500 ;reduce to increase response time
LongSleepTime=10000 ;set wait for n seconds x 1000 during battle before check again, to reduce CPU time
CrashScanWhenElapsedSec:=120 ;interval before start scanning for crash 
```
Specify your emulator name to allow script to move it to the top left and calculate the position to scan. You can configure the sleep time to improve the responsiveness or increase it when you expect slower nextwork.
Customise the crash scan interval **CrashScanWhenElapsedSec** if you experience crash frequently. Setup the **StateFileDir** if you used RK Squared proxy to identify treasure chest content, 
select party, or skip painting.

Depending if you used **FindText** or **ImageSearch** to search for FFRK click area:
### ImageSearch
To get this script to work you need to replace the snips in the "images" folder with your own. Take screenshots with Windows Snipping Tool while going through the dungeon manually. Remember to take as small as possible and as unique colour/text as possible to speed up match. Tweak the *n* value in **DefaultVariation** or in each **TryFindImage** to higher if there are failure before retry image capture.
### FindText
While AHK image search is fast and work most of the time, it is inconsistent after some times. If your PC resolution or colour rendering changes or after minor update, it will fail to find the image. Hence the alternative search method is **FindText**, thanks to the AHK community developer feiyue. 
You can start with using the existing image texts in script and customise the **err1** and **err2** value in each **TryFindImage**. It may works if you used Nox player.
Otherwise, Locate the line started with "SetupImageText" and you will find a lot text value for each image. Launch the [FindText.ahk](./Labyrinth%20Walker/Lib/FindText.ahk) to capture your own image text. I would suggest following https://www.youtube.com/watch?v=aWRAtvJq9ZE to capture the image text for each type of image (check [images](./Labyrinth%20Walker/images) folder for reference image if you dont know what to capture). 


After all the images have been replaced with your own press F1 to unpause/pause the script. You can press F2 to panic close the script. 
## Additional Features:
### Painting
You can change the priority of the paintings by simply changing the order of painting line.
Add **;** infront of the  "painting_boss" if you want to choose a different team for the boss battle.
```AutoHotkey
;Paitings Priority
;Change the order to adjust priority
PaintingPriority := []
PaintingPriority.Push("painting_treasure")
PaintingPriority.Push("painting_exploration")
PaintingPriority.Push("painting_restoration")
PaintingPriority.Push("painting_onslaught")
PaintingPriority.Push("painting_combatred")
PaintingPriority.Push("painting_combatorange")
PaintingPriority.Push("painting_combatgreen")
PaintingPriority.Push("painting_portal")
PaintingPriority.Push("painting_boss")

OpenSealedDoor=yes ;yes or no , must be provide
SkipPainting=yes ;skip painting skip with proxy state file
SkipExploreTreasureCount=2 ;skip explore depending on at min how many treasure behind, set 0 to not skip
SkipCombatExploreCount=0 ;skip combat and end floor early, depending at max how many explore to ignore (also check no treasure left), set -1 to not skip 
```
Configure the **SkipPainting** to whether skip to Exploration Painting (if there are treasure behind) or Combat Painting (Go to portal early if no more treasure or exploration). **SkipExploreTreasureCount** is the minimum number of treasure painting behind before start skipping exploration, set 0 not skip exploration and take chance. **SkipCombatExploreCount** is the maximum exploration behind allowed to be ignored before it go to portal/boss early, set -1 if you dont want skip combat.
The state file wil have following format
```
8,true,false,true,0,1
remaining,hasPortal,hasMaster,canSkipExploration,futureTreasure,futureExploration
```
### Chest
Configurations are:
```AutoHotkey
OpenChest=yes ;set to yes to enable
MinOpenChestId=3
```
set *MinOpenChestId* to control the minimum type to collect from, 5 is Hero Equipment, 4 is Anima lense etc, 3 is 6* mote etc. This will spend keys.
The script open the chest based on the state file supplied by other proxy app e.g. RK Squared, in the format of CSV Representing the left, middle and right chest id:
```
5,3,1
left,center,right
``` 
### Party Selection
The configurations are:
```AutoHotkey
SelectParty=yes ;Select party based on combat state text file and rules in CombatRules
ConsiderFatigue=yes
FatigueThreshold := 35
CombatRules := {"Bahamut":[3,1,2], "Ramza": [3,2,1], "Ravus": [1,3,2], "Twintania": [1,2,3], "Vajra": [1,2,3], "Wendigo": [2,1,3]
,"Alexander": [2,3,1], "Behemoth": [3,1,2], "Brynhildr": [2,1,3], "Byblos": [2,1,3], "Chaos": [3,1,2], "Leviathan":[2,1,3]
,"Marilith": [3,1,2], "Nidhogg": [2,1,3], "Ultima Weapon":[1,2,3]
,"Adamanchelid": [2,1,3], "Atomos": [1,3,2], "Black Waltz No.2": [3,1,2], "Deathclaw": [1,2,3], "Green Dragon": [1,2,3]
,"Guard Scorpion": [2,1,3], "Iron Giant": [1,3], "Lunasaur": [2,1,3], "Red Giant & Catoblepas": [1,3]
,"Elvoret": [2,1,3]}
SelectPartyOffsetY=60 ;offset click to reach center for party selection before Battle 
```
The script also consider the party selection based on the state file supplied by other proxy app e.g. RK Squared, in the format of CSV
```
Bahamut,50,35,0
enemy,totalFatigue1,totalFatigue2,totalFatigue3
```
Representing enemy name, first party total fatigue, second party total fatigue, third party total fatigue

The script also defines the __CombatRules__ with format __"Enemy name":= \[order of party number\]__, 
```AutoHotkey
CombatRules := {"Bahamut":[3,1,2]}
```
This example configured that the 3rd party will be first preference followed by 1st and 2nd. Remove the party number from the \[\] if do not wish to be selected (e.g. Red Giant absorb lightning). If __ConsiderFatigue__ set to yes, then it would read party fatigue from the state file and compare with the __FatigueThreshold__.
It then select the next best party from the order, default to first party when all party fatigue check failed.

The existing rules used following parties, you can alter rules according to your party setup and enemy weakness:
1. Holy Mage
2. Lightning Physical
3. Earth Mixed


