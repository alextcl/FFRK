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
EmulatorAppName:= "NoxPlayer" ;set this to the name of the emulator app
ScreenshotShorcut:= "{Control}7" ;shortcut to take a screenshot when encounter shimmering painting
WidthOffset:=40 ;offset to exclude emulator right sidebar 
StateFileDir=C:\Users\Amanda\AppData\Roaming\RK Squared\state\ ;change the path to your local RK Squared installation

SearchMethod:="ImageSearch" ;use FindText or ImageSearch
DefaultVariation:="*80" ; variation for ImageSearch

DefaultSleepTime=1500 ;reduce to increase response time
LongSleepTime=10000 ;set wait for n seconds x 1000 during battle before check again, to reduce CPU time
CrashScanWhenElapsedSec:=120 ;interval seconds before startSection scanning for crash
ReturnMouse=yes ;Returns the mouse to the position it was at before clicking on the emulator
```
Specify your emulator name according to the TaskManager process to allow script to move it to the top left and calculate the position to scan.
You can configure the sleep time to improve the responsiveness or increase it when you expect slower nextwork.
Customise the crash scan interval **CrashScanWhenElapsedSec** if you experience crash frequently. 
Setup the **StateFileDir** if you used RK Squared proxy to identify treasure chest content, select party, or skip painting.

Depending if you used **FindText** or **ImageSearch** to search for FFRK click area:
### ImageSearch
To get this script to work you need to replace the snips in the "images" folder with your own. Take screenshots with Windows Snipping Tool while going through the dungeon manually. Remember to take as small as possible and as unique colour/text as possible to speed up match. Tweak the *n* value in **DefaultVariation** or in each **TryFindImage** to higher if there are failure before retry image capture.
### FindText
While AHK image search is fast and work most of the time, it is inconsistent after some times. If your PC resolution or colour rendering changes or after minor update, it will fail to find the image. Hence the alternative search method is **FindText**, thanks to the AHK community developer feiyue. 
You can start with using the existing image texts in script and customise the **err1** and **err2** value in each **TryFindImage**. It may works without any changes if you used Nox player(540x960) with desktop display resolution 1920*1080.
Otherwise, Locate the line started with "SetupImageText" and you will find a lot text value for each image. Launch the [FindText.ahk](./Labyrinth%20Walker/Lib/FindText.ahk) to capture your own image text. I would suggest following https://www.youtube.com/watch?v=aWRAtvJq9ZE to capture the image text for each type of image (check [images](./Labyrinth%20Walker/images) folder for reference image if you dont know what to capture). Also see the [Troubleshooting FindText](##troubleshooting-findtext).

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
SkipPainting=yes ;skip painting toggle
SkipExploreTreasureCount=0 ;skip explore depending on at min how many treasure behind, set 0 to not skip, should not skip in season 2
EndFloorWhenRemaining=3 ;end floor early depending on remaining painting count, also check no explore and treasure in behind, set 1 to not skip 
TryAvoidEnemy=yes ; try to avoid certain enemy in painting selection (not possible in exploration or when all row same enemy)
```
Configure the **SkipPainting** to whether skip to Exploration Painting (if there are treasure behind) or Combat Painting (go to portal early if no more treasure or exploration). **SkipExploreTreasureCount** is the minimum number of treasure painting behind before start skipping exploration, set 0 not skip exploration and take chance. **EndFloorWhenRemaining** is depending on remaining painting countbefore it go to portal/boss early, set 1 if you dont want skip painting.

**TryAvoidEnemy** when configured will try to avoid enemy according to the rules **SetupAvoidEnemy** near the end of the file. Add another line for the enemy you want the script to avoid when selecting combatant painting.

```AutoHotkey
SetupAvoidEnemy:
AvoidEnemyRules := []
AvoidEnemyRules.Push("Diablos")
AvoidEnemyRules.Push("Atomos")
AvoidEnemyRules.Push("Lunasaurs")
AvoidEnemyRules.Push("Unidentified MA")
; add another line for another enemy name
```
The script also automatically
- prioritise restoration painting over onslaught when Total Party Fatigue hit 75 (means each party member fatigue at average 5)
- prioritise Shimmering Painting (Exploration and Combat only) over other painting except Treasure 

The state file wil have following format
```
7,true,false,true,0,2
6_false,12_false_Alexander,12_false_Ogopogo
remaining,hasPortal,hasMaster,canSkipExploration,futureTreasure,futureExploration
left,center,right
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
DefaultPartyNo := 1 ;default party number when everything else failed
FatigueThreshold := 35
SelectPartyOffsetY=60 ;offset click to reach center for party selection before Battle 
```
If you want to switch party depending on encountered enemy, locate line start with **SetupCombatRules** and notice a list of pre-configured rules. The script defines the __CombatRules__ with the format __CombatRules["Enemy name"]:= \[order of party number\]__, 
```AutoHotkey
CombatRules["Bahamut"] := [3,1,2]
```
This example configured that the 3rd party will be first preference followed by 1st and 2nd. You can change each enemy rules by changing the order of the party number.
Remove the party number from the \[\] if do not wish to be selected (e.g. Red Giant absorb lightning). 

The existing rules used following parties, you can alter rules according to your party setup and enemy weakness:
1. Holy Mage
2. Lightning Physical
3. Earth Mixed

If __ConsiderFatigue__ set to yes, then it would read party fatigue from the state file and compare with the __FatigueThreshold__. It then select the next best party from the order, default to first party when all party fatigue check failed.

The state file supplied by other proxy app e.g. RK Squared, will have the format of CSV
```
Bahamut,50,35,0
enemy,totalFatigue1,totalFatigue2,totalFatigue3
```
Representing enemy name, first party total fatigue, second party total fatigue, third party total fatigue
## Troubleshooting the script
Download one of the debugger http://fincs.ahk4.net/scite4ahk/. 

Debug the script in the debugger and press run. 

It should print some description about what the script is doing. For e.g. which images it couldnt find.

If there is mouse movement but not able to click on the emulator, consider running the script as administrator.

Some emulator (Memu) does not allow the click to occur too frequent, locate the failing ClickOnFoundImage and see if you need to increase the **Sleep** delay before or after it.
## Troubleshooting FindText
Since the script used a set of error rate and image text targeted to the developer machine (1920*1080), you may have issue finding the image or finding more image than you need with FindText. The script also splits the emulator into 3 vertical sections (Top, Middle, Bottom) to limit the search area and speed up the search. Sometimes the button could be at the edge of the section and get ignored because of the search area.

Launch [FindText.ahk](./Labyrinth%20Walker/Lib/FindText.ahk) and patse the imagetext that the script failed to find to the lower part of the window and run a test. If it was found in FindText window and been highlighted correctly but failed in the script, observe the screen section in the TryFindImage line.
```AutoHotkey
If (TryFindImage("moveon", ScreenSplit.Bottom, ScreenSplit.Bottom, 0.2, 0.3, DefaultVariation))
```
For example, the line above shown it only search in the bottom section of the emulator but the button could be at the edge of the middle section. Change the line to 
```AutoHotkey
If (TryFindImage("moveon", ScreenSplit.Middle, ScreenSplit.Bottom, 0.2, 0.3, DefaultVariation))
```
to increase the search area from Middle to Bottom.

