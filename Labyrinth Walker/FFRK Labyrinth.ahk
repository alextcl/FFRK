#NoEnv
#SingleInstance Force
#WinActivateForce
Menu, Tray, Icon, %A_ScriptDir%\images\FFRK.ico
SetWorkingDir %A_ScriptDir% ;Sets the working directory where the script is actually located.
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
SendMode Input ;More reliable sending mode

DebugScript:=false
StateFileDir=C:\Users\Amanda\AppData\Roaming\RK Squared\state\
TheAlarm=%A_WinDir%\Media\Alarm01.wav
EmulatorAppName=NoxPlayer

WinMove, %EmulatorAppName%, , 0, 0, ;
WinGetPos, , , TargetW, TargetH,%EmulatorAppName%
;Limit the search area for ImageSearch. Use %A_ScreenWidth% and %A_ScreenHeight% if you want to search the whole screen
SearchWidth=%TargetW%
SearchHeight=%TargetH%
DefaultSleepTime=1500 ;reduce to increase response time 
ReturnMouse=yes ;Returns the mouse to the position it was at before clicking on the emulator

;Paitings Priority
;Change the order to adjust priority
;Remove "painting_boss" if you want to choose a different team for the boss battle
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
SkipExploreTreasureCount=1 ;skip explore depending on how many treasure behind, set to 9 to not skip
EndFloorWhenExplore=0 ;skip combat if depending of how many explore behind current row and no treasure left
PaintingFile=%StateFileDir%painting.txt
BossCombat:=HasValue(PaintingPriority, "painting_boss")

OpenChest=yes ;Open chest based on chest state text file
MinOpenChestId=3
ChestFile=%StateFileDir%chest.txt ;change the path to your local RK Squared installation
ChestTypes := ["leftchest", "centerchest", "rightchest"]

SelectParty=yes ;Select party based on combat state text file and rules in CombatRules
SelectPartyOffsetY=60 ;offset click to reach center for party selection before Battle 
ConsiderFatigue=yes
FatigueThreshold := 35
CombatFile=%StateFileDir%combat.txt ;change the path to your local RK Squared installation
CombatRules := {"Bahamut":[3,1,2], "Ramza": [3,2,1], "Ravus": [1,3,2], "Twintania": [1,2,3], "Vajra": [1,2,3], "Wendigo": [2,1,3]
,"Alexander": [2,3,1], "Behemoth": [3,1,2], "Brynhildr": [2,1,3], "Byblos": [2,1,3], "Chaos": [3,1,2], "Leviathan":[2,1,3]
,"Marilith": [3,1,2], "Nidhogg": [2,1,3], "Ultima Weapon":[1,2,3]
,"Adamanchelid": [2,1,3], "Atomos": [1,3,2], "Black Waltz No.2": [3,1,2], "Deathclaw": [1,2,3], "Green Dragon": [1,2,3]
,"Guard Scorpion": [2,1,3], "Iron Giant": [1,3], "Lunasaur": [2,1,3], "Red Giant & Catoblepas": [1,3]
,"Elvoret": [2,1,3]}
CombatSleepTime=10000 ;set wait for n seconds x 1000 during battle before check again, to reduce CPU time

;Script begins paused, comment out if not required
;Pause 
Gosub, TheMainLoop

F1::
;Press F1 to start and stop your script
Pause, Toggle
;WinMove, %EmulatorAppName%, , 0, 0, ;Automtically move and resize emulator window, uncomment to use
Gosub, TheMainLoop

Return

F2::
;Press F2 to force close script at anytime.
ExitApp
Return

ClickOnFoundImage:
MouseGetPos, ReturnX, ReturnY
WinGet, Active_ID, ID, A
Click, %FoundX%, %FoundY%, Left
If (ReturnMouse="yes")
{
	Click, %ReturnX%, %ReturnY%, 0
	WinActivate ahk_id %Active_ID%
}
Return

ClickOnOK:
ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *90 %A_ScriptDir%\images\ok.png
If (ErrorLevel = 0)
{
	Gosub, ClickOnFoundImage
	Sleep DefaultSleepTime
}
ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *90 %A_ScriptDir%\images\ok2.png
If (ErrorLevel = 0)
{
	Gosub, ClickOnFoundImage
	Sleep DefaultSleepTime
}
Return

ClickOnMoveOn:
if DebugScript
{
	MsgBox, Debug stop on move on
	Return
}
ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\moveon.png
If (ErrorLevel = 0)
{
	Gosub, ClickOnFoundImage
	Sleep DefaultSleepTime
}
ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\moveon2.png
If (ErrorLevel = 0)
{
	Gosub, ClickOnFoundImage
	Sleep DefaultSleepTime
}
Return

TheMainLoop:
Loop
{
	Sleep 100
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\cancelauto.png
	If (ErrorLevel = 0)
	{
		Sleep CombatSleepTime
		continue
	}
	else
	{
		Gosub, WaitForBattleComplete
	}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\enter.png
	If (ErrorLevel = 0)
	{
		Gosub, ClickOnFoundImage
		Sleep DefaultSleepTime
	}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\go.png
	If (ErrorLevel = 0)
	{
		Gosub, ClickOnSelectParty
		Continue
	}

	Gosub, ClickOnOk

	Gosub, ClickOnInsidePainting
	
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\labyrinth_blue.png
	If (ErrorLevel = 0)
	{
		;Only use the painting priority loop when inside main labyrinth to prevent the script from cycling too early and choosing the wrong painting.
		Sleep DefaultSleepTime
		IsLastFloor := false
		Gosub, PaintingPriority
	}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\labyrinth_purple.png
	If (ErrorLevel = 0)
	{
		;Last floor is purple. Only use the painting priority loop when inside main labyrinth to prevent the script from cycling too early and choosing the wrong painting.
		Sleep DefaultSleepTime
		IsLastFloor := true
		Gosub, PaintingPriority
	}

	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\dungeoncomplete.png
	If (ErrorLevel = 0)
	{
		SoundPlay, %TheAlarm%, 1
		KeyWait, LButton, D
	}

	Gosub, CheckCrashRecovery
}
Return

PaintingPriority:
PaintingState := 
If (SkipPainting="yes")
{
	FileReadLine, Contents, %PaintingFile%, 1
	If (ErrorLevel = 0)
	{
		PaintingState := StrSplit(Contents, ",")
		Remaining :=  PaintingState[1]
		HasPortal := PaintingState[2]
		HasMaster := PaintingState[3]
		CanSkipExplore := PaintingState[4]
		FutureTreasure := PaintingState[5]
		FutureExplore := PaintingState[6]
		CanEndFloor := HasPortal or (HasMaster and BossCombat)
	}
}
for index, Painting in PaintingPriority
{
	If (IsObject(PaintingState))
	{
		If (Painting == "painting_exploration")
		{
			If (SkipExploreTreasureCount > 0 and FutureTreasure >= SkipExploreTreasureCount)
			{ 
				If (!IsLastFloor and CanSkipExplore)
				{
					OutputDebug, %A_Now%: Skip explore futureT: %FutureTreasure% skipT: %SkipExploreTreasureCount%
					If DebugScript
					{
						MsgBox, %A_Now%: Skip explore futureT: %FutureTreasure% skipT: %SkipExploreTreasureCount%
						Return
					}				
					else
						Continue
				}

				MsgBox, %A_Now%: Configure to skip exploration but reach here, error in logic
			}
		} 
		else If (InStr(Painting, "combat") and CanEndFloor and Remaining <= 9)
		{
			If (FutureTreasure = 0 and (FutureExplore <= EndFloorWhenExplore)){
				OutputDebug, %A_Now%: Skip combat futureT: %FutureTreasure% futureE: %FutureExplore% skipE:%EndFloorWhenExplore%
				If DebugScript
					MsgBox, %A_Now%: Skip combat futureT: %FutureTreasure% futureE: %FutureExplore% skipE:%EndFloorWhenExplore%
				else
					Continue
			}
		}
	}
	OutputDebug, %A_Now%: Searching %Painting% 
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\%Painting%.png
	If (ErrorLevel = 0)
	{
		OutputDebug, %A_Now%: Found %Painting% 
		Gosub, ClickOnFoundImage
		Sleep 600
		Gosub, ClickOnFoundImage
		Sleep DefaultSleepTime
		Break ;Back to main loop since remaining paintings irrelevant 
	}
}
Return

ClickOnInsidePainting:
ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\sealeddoor.png
If (ErrorLevel = 0)
{
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\%OpenSealedDoor%.png
	If (ErrorLevel = 0)
	{
		;Click on "Yes" or "no" when presented with a Sealed Door.
		Gosub, ClickOnFoundImage
		Sleep DefaultSleepTime
		Return
	}
}
ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\inside_explorationpainting.png
If (ErrorLevel = 0)
{
	;This "Move On" button is only clicked when inside an "Exploration Painting" to prevent the script from clicking on the "Move On" button while inside a "Treasure Painting"
	Gosub, ClickOnMoveOn
	Return
}
ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\inside_restoration.png
If (ErrorLevel = 0)
{
	;This "Move On" button is only clicked when inside an "Restoration Painting" to prevent the script from clicking on the "Move On" button while inside a "Treasure Painting"
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\moveon.png
	Gosub, ClickOnMoveOn
	Return
}
ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\inside_onslaught.png
If (ErrorLevel = 0)
{
	;This "Move On" button is only clicked when inside an "Onslaught Painting" to prevent the script from clicking on the "Move On" button while inside a "Treasure Painting"
	Gosub, ClickOnMoveOn
	Return
}
ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\inside_treasurepainting.png
If (ErrorLevel = 0)
{
	If (OpenChest="yes")
		Gosub, ClickOnTreasureChest
	else
	{
		Loop {
			SoundPlay, %TheAlarm%, 1
			KeyWait, LButton, D, T30 ;wait 30 sec for left click button
			If(ErrorLevel = 0)
			{
				Break
			} 
		}
	}
}
Return

ClickOnTreasureChest:
FileReadLine, Contents, %ChestFile%, 1
If (ErrorLevel = 0)
{
	ChestNums := StrSplit(Contents, ",")
	TotalChest := 0
	OpenedChests := {}
	for index, ChestId in ChestNums
	{
		if(ChestId >= MinOpenChestId){
			TotalChest++
		}
	}
	Loop 
	{
		for innerIndex, ChestType in ChestTypes
		{
			ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\%ChestType%open.png
			If (ErrorLevel = 0)
			{
				OutputDebug, Found opened %ChestType%
				OpenedChests[ChestType] := 1
			}
			ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\%ChestType%.png
			If (ErrorLevel = 0 and ChestNums[innerIndex] >= MinOpenChestId)
			{
				OutputDebug, Click on found %ChestType%
				Gosub, ClickOnFoundImage
				Sleep DefaultSleepTime
			}
		}
		ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\open.png
		If (ErrorLevel = 0)
		{
			If DebugScript
				MsgBox, Stop On Open chest
			else
				Gosub, ClickOnFoundImage
			Sleep DefaultSleepTime
		}
		ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\usekey.png
		If (ErrorLevel = 0)
		{
			Gosub, ClickOnFoundImage
			Sleep DefaultSleepTime
		}
		
		OpenChestCount := 0
		for key, Value in OpenedChests
		{
			OpenChestCount++
		}
		If (OpenChestCount >= TotalChest)
		{
			OutputDebug, Open Chest state Open %OpenChestCount% Total %TotalChest%
			Gosub, ClickOnMoveOn
			Gosub, ClickOnOK
			Break
		}
	}
}
Return

ClickOnSelectParty:
SelectedPartyNo := 1 ;always default to 1st party
If(SelectParty="yes")
{
	FileReadLine, Contents, %CombatFile%, 1
	If (ErrorLevel = 0)
	{
		CombatRow := StrSplit(Contents, ",")
		Enemy := CombatRow[1]
		If (CombatRules.HasKey(Enemy))
		{
			PartyOrder := CombatRules[Enemy]
			for index, PartyNo in PartyOrder
			{
				If (index = 1){
					SelectedPartyNo := PartyNo ;default to 1st in order incase all failed condition
				}
				PartyFatigue := CombatRow[PartyNo+1]
				If (ConsiderFatigue <> "yes" OR PartyFatigue <= FatigueThreshold)
				{
					SelectedPartyNo := PartyNo
					OutputDebug Party selection: %SelectedPartyNo% Enemy: %Enemy% RuleIndex: %index% Fatigue: %PartyFatigue%
					Break
				}
			}
		}
	}
}
ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\party%SelectedPartyNo%.png
If (ErrorLevel = 0)
{
	FoundY := FoundY + SelectPartyOffsetY
	Gosub, ClickOnFoundImage
	Sleep DefaultSleepTime
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\go.png
	If (ErrorLevel = 0)
	{
		If DebugScript
			MsgBox, Debug stop on Go
		else
		{
			Gosub, ClickOnFoundImage
			Gosub, ClickOnOK
			Sleep (CombatSleepTime x 6)
		}
	}
}
Return

WaitForBattleComplete:
ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\auto.png
If (ErrorLevel = 0)
{
	Gosub, ClickOnFoundImage
	Sleep DefaultSleepTime
}
ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\skip.png
If (ErrorLevel = 0)
{
	Gosub, ClickOnFoundImage
	Sleep DefaultSleepTime
}
ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\next.png
If (ErrorLevel = 0)
{
	Gosub, ClickOnFoundImage
	Sleep DefaultSleepTime
}
Return

CheckCrashRecovery:
ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\crashopen.png
If (ErrorLevel = 0)
{
	Gosub, ClickOnFoundImage
	Sleep DefaultSleepTime
}
ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\ffrkapp.png
If (ErrorLevel = 0)
{
	Gosub, ClickOnFoundImage
	Sleep DefaultSleepTime
}
ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\play.png
If (ErrorLevel = 0)
{
	Gosub, ClickOnFoundImage
	Sleep DefaultSleepTime
}
ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\exploring.png
If (ErrorLevel = 0)
{
	Gosub, ClickOnFoundImage
	Sleep DefaultSleepTime
}
Return

HasValue(haystack, needle) {
    if(!isObject(haystack))
        return false
    if(haystack.Length()==0)
        return false
    for k,v in haystack
        if(v==needle)
            return true
    return false
}
