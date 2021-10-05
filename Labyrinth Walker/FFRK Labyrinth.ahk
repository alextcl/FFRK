#Include <FindText>
#NoEnv
#SingleInstance Force
#WinActivateForce
Menu, Tray, Icon, %A_ScriptDir%\images\FFRK.ico
SetWorkingDir %A_ScriptDir% ;Sets the working directory where the script is actually located.
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
SendMode Input ;More reliable sending mode

DebugScript:=false
TheAlarm=%A_WinDir%\Media\Alarm01.wav
SearchMethod:="FindText" ;use FindText or ImageSearch
EmulatorAppName:= "NoxPlayer" ;set this to the name of the emulator app
StateFileDir=C:\Users\Amanda\AppData\Roaming\RK Squared\state\ ;change the path to your local RK Squared installation
DefaultSleepTime=1500 ;reduce to increase response time
LongSleepTime=10000 ;set wait for n seconds x 1000 during battle before check again, to reduce CPU time
CrashScanWhenElapsedSec:=120 ;interval seconds before start scanning for crash 
ReturnMouse=yes ;Returns the mouse to the position it was at before clicking on the emulator

WinMove, %EmulatorAppName%, , 0, 0, ;
WinGetPos, , , TargetW, TargetH, %EmulatorAppName%
;Limit the search area for ImageSearch. Use %A_ScreenWidth% and %A_ScreenHeight% if you want to search the whole screen
SearchWidth:=TargetW
SearchHeight:=TargetH
ScreenSplit := {} ; split the screen to 3 section to speed up search, do not change this
ScreenSplit["Top"] := { X: 0, Y: 0, Width: SearchWidth, Height: Ceil(SearchHeight/3) }
ScreenSplit["Middle"] := { X: 0, Y: Ceil(SearchHeight/3), Width: SearchWidth, Height: Ceil(2 * (SearchHeight/3)) }
ScreenSplit["Bottom"] := { X: 0, Y: Ceil(2 * (SearchHeight/3)), Width: SearchWidth, Height: SearchHeight }

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
SkipExploreTreasureCount=2 ;skip explore depending on at min how many treasure behind, set 0 to not skip
SkipCombatExploreCount=0 ;skip combat and end floor early, depending at max how many explore to ignore (also check no treasure left), set -1 to not skip 
PaintingFile=%StateFileDir%painting.txt
BossCombat:=HasValue(PaintingPriority, "painting_boss")

OpenChest=yes ;Open chest based on chest state text file
MinOpenChestId=3
ChestFile=%StateFileDir%chest.txt
ChestTypes := ["leftchest", "centerchest", "rightchest"]

SelectParty=yes ;Select party based on combat state text file and rules in CombatRules
ConsiderFatigue=yes
FatigueThreshold := 35
CombatRules := {"Bahamut":[3,1,2], "Ramza": [3,2,1], "Ravus": [1,3,2], "Twintania": [1,2,3], "Vajra": [1,2,3], "Wendigo": [2,1,3]
,"Alexander": [2,3,1], "Behemoth": [3,1,2], "Brynhildr": [2,1,3], "Byblos": [2,1,3], "Chaos": [3,1,2], "Leviathan":[2,1,3]
,"Marilith": [3,1,2], "Nidhogg": [2,1,3], "Ultima Weapon":[1,2,3]
,"Adamanchelid": [2,1,3], "Atomos": [1,3,2], "Black Waltz No.2": [3,1,2], "Deathclaw": [1,2,3], "Green Dragon": [1,2,3]
,"Guard Scorpion": [2,1,3], "Iron Giant": [1,3], "Lunasaur": [2,1,3], "Red Giant & Catoblepas": [1,3]
,"Elvoret": [2,1,3], "Magic Pot": [2,3,1]}
SelectPartyOffsetY=60 ;offset click to reach center for party selection before Battle 
CombatFile=%StateFileDir%combat.txt 

;Script begins paused, comment out if not required
;Pause 
Gosub, SetupImageText
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
If (SearchMethod == "FindText"){
	FindText().Click(FoundX, FoundY, "L")
}
else
{
	MouseGetPos, ReturnX, ReturnY
	WinGet, Active_ID, ID, A
	Click, %FoundX%, %FoundY%, Left
	If (ReturnMouse="yes")
	{
		Click, %ReturnX%, %ReturnY%, 0
		WinActivate ahk_id %Active_ID%
	}
}
Return

ClickOnOK:
If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Middle.Y, SearchWidth, ScreenSplit.Bottom.Height, 0.2, 0.2, ImageText.ok))
{
	Gosub, ClickOnFoundImage
	Sleep DefaultSleepTime
	Return
}
else If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Middle.Y, SearchWidth, ScreenSplit.Bottom.Height,  0.2, 0.2, ImageText.ok2))
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
If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Bottom.Y, SearchWidth, ScreenSplit.Bottom.Height, 0.2, 0.3, ImageText.moveon))
{
	Gosub, ClickOnFoundImage
	Sleep DefaultSleepTime
}
Return

TheMainLoop:
LastCrashScan:=A_TickCount
ContinueCrashScan:=false
Loop
{
	Sleep 100
	If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Bottom.Y, SearchWidth, ScreenSplit.Bottom.Height, 0.2, 0.3, ImageText.cancelauto))
	{
		If ((AwaitingBattleComplete/15) <= AwaitingBattleComplete){
			Sleep LongSleepTime
			AwaitingBattleComplete := AwaitingBattleComplete + LongSleepTime
		}
		else 
		{
			Sleep (LongSleepTime/2)
			AwaitingBattleComplete := AwaitingBattleComplete + (LongSleepTime/2)
		}
		continue
	}
	else
	{
		AwaitingBattleComplete := 0
		Gosub, WaitForBattleComplete
	}

	If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Bottom.Y, SearchWidth, ScreenSplit.Bottom.Height, 0.1, 0.1, ImageText.enter))
	{
		Gosub, ClickOnFoundImage
		Sleep DefaultSleepTime
	}
	
	Gosub, ClickOnOk

	Gosub, ClickOnInsidePainting

	If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Top.Y, SearchWidth, ScreenSplit.Top.Height, 0.1, 0.1, ImageText.labyrinth_blue))
	{
		;Only use the painting priority loop when inside main labyrinth to prevent the script from cycling too early and choosing the wrong painting.
		Sleep DefaultSleepTime
		IsLastFloor := false
		Gosub, PaintingPriority
	}
	else If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Top.Y, SearchWidth, ScreenSplit.Top.Height, 0.1, 0.1, ImageText.labyrinth_purple))
	{
		;Last floor is purple. Only use the painting priority loop when inside main labyrinth to prevent the script from cycling too early and choosing the wrong painting.
		Sleep DefaultSleepTime
		IsLastFloor := true
		Gosub, PaintingPriority
	} 
	else If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Middle.Y, SearchWidth, ScreenSplit.Middle.Height, 0.1, 0.1, ImageText.dungeoncomplete))
	{
		SoundPlay, %TheAlarm%, 1
		KeyWait, LButton, D
	} 
	else {
		TimeSinceLastScan := (A_TickCount - LastCrashScan)/1000
		If (ContinueCrashScan==true or TimeSinceLastScan > CrashScanWhenElapsedSec)
		{
			Gosub, CheckCrashRecovery
			if(ContinueCrashScan==false)
				LastCrashScan := A_TickCount
		}
	}
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
		HasPortal := PaintingState[2]=="true"
		HasMaster := PaintingState[3]=="true"
		CanSkipExplore := PaintingState[4]=="true"
		FutureTreasure := PaintingState[5]
		FutureExplore := PaintingState[6]
		CanEndFloor := HasPortal==true or (HasMaster==true and BossCombat==true)
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
				If (CanSkipExplore==true and IsLastFloor==false)
				{
					OutputDebug, %A_Now%: Skip explore futureT: %FutureTreasure% skipT: %SkipExploreTreasureCount%
					If DebugScript
					{
						MsgBox, %A_Now%: Skip explore futureT: %FutureTreasure% skipT: %SkipExploreTreasureCount%
						Break
					}				
					else
						Continue
				}
			}
		} 
		else If (InStr(Painting, "combat"))
		{
			If (CanEndFloor==true and Remaining <= 9)
			{
				If (FutureTreasure = 0 and (FutureExplore <= SkipCombatExploreCount))
				{
					OutputDebug, %A_Now%: Skip combat futureT: %FutureTreasure% futureE: %FutureExplore% skipE:%SkipCombatExploreCount%
					If DebugScript
					{
						MsgBox, %A_Now%: Skip combat futureT: %FutureTreasure% futureE: %FutureExplore% skipE:%SkipCombatExploreCount%
						Break
					}
					else
						Continue
				}
			}
		}
	}

	If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Middle.Y, SearchWidth, ScreenSplit.Middle.Height, 0.2, 0.2, ImageText[Painting]))
	{
		OutputDebug, %A_Now%: Found %Painting% 
		Gosub, ClickOnFoundImage
		Sleep 600
		Gosub, ClickOnFoundImage
		Sleep DefaultSleepTime
		Break
	}
}
Return

ClickOnInsidePainting:
If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Bottom.Y, SearchWidth, ScreenSplit.Bottom.Height, 0.1, 0.2, ImageText.go))
{
	Gosub, ClickOnSelectParty
}
else If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Middle.Y, SearchWidth, ScreenSplit.Bottom.Height, 0.2, 0.2, ImageText.sealeddoor))
{
	If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Bottom.Y, SearchWidth, ScreenSplit.Bottom.Height, 0.2, 0.2, ImageText[OpenSealedDoor]))
	{
		;Click on "Yes" or "no" when presented with a Sealed Door.
		Gosub, ClickOnFoundImage
		Sleep DefaultSleepTime
	}
}
else If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Top.Y, SearchWidth, ScreenSplit.Top.Height, 0.2, 0.2, ImageText.inside_explorationpainting))
{
	;This "Move On" button is only clicked when inside an "Exploration Painting" to prevent the script from clicking on the "Move On" button while inside a "Treasure Painting"
	Gosub, ClickOnMoveOn
}
else If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Middle.Y, SearchWidth, ScreenSplit.Bottom.Height, 0.2, 0.2, ImageText.inside_restoration))
{
	;This "Move On" button is only clicked when inside an "Restoration Painting" to prevent the script from clicking on the "Move On" button while inside a "Treasure Painting"
	Gosub, ClickOnMoveOn
}
else If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Middle.Y, SearchWidth, ScreenSplit.Bottom.Height, 0.2, 0.2, ImageText.inside_onslaught))
{
	;This "Move On" button is only clicked when inside an "Onslaught Painting" to prevent the script from clicking on the "Move On" button while inside a "Treasure Painting"
	Gosub, ClickOnMoveOn
}
else If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Top.Y, SearchWidth, ScreenSplit.Top.Height, 0.2, 0.2, ImageText.inside_treasurepainting))
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
else {
	return 
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
		If (ChestId >= MinOpenChestId){
			TotalChest++
		}
	}
	Loop 
	{
		for innerIndex, ChestType in ChestTypes
		{
			If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Middle.Y, SearchWidth, ScreenSplit.Middle.Height, 0.1, 0.2, ImageText[ChestType . "open"]))
			{
				OutputDebug, Found opened %ChestType%
				OpenedChests[ChestType] := 1
			}
			If (ChestNums[innerIndex] >= MinOpenChestId)
			{
				If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Middle.Y, SearchWidth, ScreenSplit.Middle.Height, 0.2, 0.2, ImageText[ChestType]))
				{
					OutputDebug, Click on found %ChestType%
					Gosub, ClickOnFoundImage
					Sleep DefaultSleepTime
				}
			}
		}
		If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Middle.Y, SearchWidth, ScreenSplit.Middle.Height, 0.2, 0.2, ImageText.open))
		{
			If DebugScript
				MsgBox, Stop On Open chest
			else
				Gosub, ClickOnFoundImage
			Sleep DefaultSleepTime
		}
		If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Middle.Y, SearchWidth, ScreenSplit.Middle.Height, 0.2, 0.2, ImageText.usekey))
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
If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Top.Y, SearchWidth, ScreenSplit.Bottom.Height, 0.2, 0.1, ImageText["party" . SelectedPartyNo]))
{
	FoundY := FoundY + SelectPartyOffsetY
	Gosub, ClickOnFoundImage
	Sleep 200

	If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Bottom.Y, SearchWidth, ScreenSplit.Bottom.Height, 0.1, 0.2, ImageText.go))
	{
		If DebugScript
			MsgBox, Debug stop on Go
		else
		{
			Gosub, ClickOnFoundImage
			Sleep 100
			Gosub, ClickOnOK
			Sleep DefaultSleepTime
		}
	}
}
Return

WaitForBattleComplete:
If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Bottom.Y, SearchWidth, ScreenSplit.Bottom.Height, 0.1, 0.3, ImageText.auto))
{
	Gosub, ClickOnFoundImage
	Sleep DefaultSleepTime
	Return
}
If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Bottom.Y, SearchWidth, ScreenSplit.Bottom.Height, 0.2, 0.1, ImageText.skip))
{
	Gosub, ClickOnFoundImage
	Sleep DefaultSleepTime
}
If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Bottom.Y, SearchWidth, ScreenSplit.Bottom.Height, 0.1, 0.2, ImageText.next))
{
	Gosub, ClickOnFoundImage
	Sleep DefaultSleepTime
}
Return

CheckCrashRecovery:
CrashDetected := true
If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Middle.Y, SearchWidth, ScreenSplit.Middle.Height, 0.1, 0.2, ImageText.crashopen))
{
	Gosub, ClickOnFoundImage
	Sleep LongSleepTime
}
else If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Middle.Y, SearchWidth, ScreenSplit.Middle.Height, 0.1, 0.2, ImageText.ffrkapp))
{
	Gosub, ClickOnFoundImage
	Sleep LongSleepTime
}
else If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Bottom.Y, SearchWidth, ScreenSplit.Bottom.Height, 0.1, 0.2, ImageText.play))
{
	Gosub, ClickOnFoundImage
	Sleep LongSleepTime
}
else If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Middle.Y, SearchWidth, ScreenSplit.Middle.Height, 0.1, 0.2, ImageText.exploring))
{
	Gosub, ClickOnFoundImage
	Sleep DefaultSleepTime
	ContinueCrashScan := false
}
else If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Middle.Y, SearchWidth, ScreenSplit.Middle.Height, 0.1, 0.2, ImageText.backtitle))
{
	Gosub, ClickOnFoundImage
	Sleep DefaultSleepTime
}
else If (ok:=FindText(FoundX, FoundY, 0, ScreenSplit.Middle.Y, SearchWidth, ScreenSplit.Middle.Height, 0.1, 0.2, ImageText.crashok))
{
	Gosub, ClickOnFoundImage
	Sleep DefaultSleepTime
} 
else {
	CrashDetected := false
}

If (CrashDetected==true){
	ContinueCrashScan := true
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

TryFindImage(imageName, targetY, searchH, err1, err2, n) {
	global FoundX, FoundY, SearchWidth, ImageText, SearchMethod
	If (SearchMethod == "FindText")
	{
		If (ok:=FindText(FoundX, FoundY, 0, targetY, SearchWidth, searchH, err1, err2, ImageText[imageName]))
			return true
	}
	else
	{
		ImageSearch, FoundX, FoundY, 0, %targetY%, %SearchWidth%, %searchH%, %n% %A_ScriptDir%\images\%imageName%.png
		If (ErrorLevel = 0)
			return true
	}
	return false
}

SetupImageText:
ImageText := {}
ImageText.painting_treasure:="|<>*135$71.0QTU0000001y1sy00000003w3ns0000S007s3bU0001y003k3i00007y0k3U3w0000QC1k300k0001kD10300030070DU02000600A0zU00000C01U3z0000008020DxVk002000A0TLU000Ds00M3y7zznzzk00kDzzzzzzzU0NUzbzzzzzz01nVyDzzzzzy03bzszzzzzzy037zXyzzzzzwEA1y3nzxzzzlyU0M03y3zzzay00007k7zzz6w000060Dzzy0E000000Tzzw6U000000zzzs4U000401"
ImageText.painting_exploration:="|<>*183$31.yyQ00T3y00/sz0077bU03Uvk01zTk00ryM01vzg01zwq01tyP03ujwU1tqTE1szDs0w3Tw0w8Dy0S7bz0S0vzUD00zM70U887UTU43k0021s0010s3E0UQ0w0EC0808708043UA023k0031s300Uw100ES0j08D0E"
ImageText.painting_restoration:="|<>*165$31.81bks41jsQ20rwA0Ery608Lz320HzV12vzk1Vzzs0kPzw0s0zy0Q0Tz0C0TzUD0Bzk7U7zk3w3vU1w3PU0w1cU0T1wU0DUoE06UME03E8000kA000Ty000C3000730001U0000k0000Q00004U00020000100000k"
ImageText.painting_onslaught:="|<>*120$31.0Tz000DzU007zU003zo001zy020zzc70Tzk0UDzs0Q3zw060zy0207y0001z0007zU003zk0007k007vs000zw300Ty7UQDzbvT7znwDnzsTDzzw7zzzz1xzzzkCTzzw01zzyE0Dzzs87zzM43zz011zz80lzzgXE"
ImageText.painting_combatred:="|<>*148$31.00003U0001m0000MU000AM000240000200000U0060E00TUs00DU400AE2006CM0027x0011yU000rE000Tu0007s0003t0000H1s3U3Vzzs3szzy3lzzxlsTy1QwDzUHzzzk5zzzs0zzzw0Dzzy0Dzzz03zzzU0k"
ImageText.painting_combatorange:="|<>0xE29C35@0.91$31.000000000000000000QD400Tzq0Dzzz0bzzzVzzzzkzzzzsTzzzUDzzz07zzz03zzw01zzy00zzy00zzy00zzz00Tzy00Dly007ky003kA001s2000yE200TC1007bCU01zzU00zzU00zzk00Dz0003zU001zs00E"
ImageText.painting_combatgreen:="|<>0xB9D26A@0.91$31.0000000000000000000000021k037sT01zqDU1zzzkDzzzU3zzzU1zzz00zzy00zzw00Tzy00Tzy00Tzs00Txw00DUw00DUQ003UC001U0000k0010Q0010C000U700001k0U00s8000y7000D00003s0001zs00E"
ImageText.painting_portal:="|<>*160$31.03zzVk3zzsQ3zzy73zzznXzzzznzzzyzzzzzTzzzzDzxzz7k0zzXk0Tzns0Dzzs07zzs03zzwA0zzyS0TzyDk3zy7k1zz0M0zzVy0Dzkz07zszk1z0zs0Q1zy000zzUM0TzsA0Dzw007zz03Xzzk3zzzw7zzzy7zk"
ImageText.painting_boss:="|<>*115$31.DzzzzXzzzrkzy00MDw01w7zzzy0Dzzz07zzz03zzzU1zzzk0y0DkES0Du8B3rx26VziUXEzbEFcDnc0c7tw4o1wpYO0SuyB0DTS6UsDj3wk7n3mNDP1xxzj1zyzr1zzTzVzzjzlzbn1tj1tnxj0ytyD0TwzD0DwTk"

ImageText.labyrinth_blue:="|<>0x134087@0.75$31.zzzzzzzzzzzzzzzzzzzzrzzTzvzznzxzzQzyzzrjzTzU8zjz00brz00Bvz003RzU00yzU20CTUDk3jsDs0rsDw0Xw7y0Rw7z0Cy3zY7T3zq3j1zv1rUzxUvUTykRkDzMCk7zY7M7zm3c3zt1o0TwUu1byER0Qz8Ck"
ImageText.labyrinth_purple:="|<>0x8838A6@0.75$31.zz60CTzkU3DzU007zU003zU041zU01YzU00MTk006Dk3k0bs7w03s3y0Fw3z0Ay1zU2T1zk1DUzs0bUTw0HkDy08EDz0407zU2M3zk101zs0Y0Dw0G03y0800704040020OU010R800USV00ETK008zflU4zpw82E"
ImageText.dungeoncomplete:="|<>*94$50.000000001w3000301zkk000k0sCA00000A1n0A00020Ar7nknQU3DtxyAv80H3A1XAO0Akn0Mn6U3AAkSAlg1n3ABXAPUslX68n6TwDszaAlVw1w7CnAM00000000U"

ImageText.inside_explorationpainting:="|<>*137$61.U0zzzzztzzk0Tzzzzszzs0DzzzzwDzwTzzzzzy7zyDzzzzzz3zz7zzzzzzlzzXzzzzzzlzzlzszXUDszUMzwDVk1wTU4073Vs0SDU203lVwS77Vx01w1yTXXVzXzz1z7kllzlzzUzXwMszszzkTlyAQTwTzk7sy6CDyDzsXwT773z7zssyD3XkyU0sSD03lw0E0MT3U3sz0808Tkk7yTkA"
ImageText.sealeddoor:="|<>*111$41.zzzzzzzzzzzbzzzzzzDzzzzzyTzzzzzwzzky7VtsT0k61nUQDbBnaCGDDDbAwaA0MCM1CAzWQlySMzAtXw0s20nUB3sC9bUzzzzzzzw"
ImageText.yes:="|<>*142$25.zzzzblzzllzzwNzzy0zzzUy3Vsy0UQTCFyDbAT7k77XtzllwR8sz0Uyztwzzzzw"
ImageText.no:="|<>*127$21.zzzzzzzzzzzzzzTtztzDz7tzsTDzFtk/7A0QNbXnAwS1bXsAwTVX3yC1Tvwzzzzzzzzzzzzzzw"
ImageText.inside_onslaught:="|<>*102$31.zzzjzzzzXzzzzzzzzzzzzUEQM7U06A1bBX6QlblXCA3Ulb73aMnX3XANlbk2AsUA1CQHXzzzttzzzwszzzy0Tzzz"
ImageText.inside_restoration:="|<>*108$61.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzznzzzzzzwXVk9tYM7kS1UM4wk41k77XaSSMyQtnbnnDDAzC8tns1bbaTb40twTnnnDnWDwyDNslbtlbyTUA60nwsk7DsD3UNyQS7zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
ImageText.moveon:="|<>*143$61.zzzzzzzzzzjlzzzzzy0znkzzzzzy07tkTzzzzy7VwMDzzzzyDsy070nX1z7yMkX08n0zbz4QtbaNbDnzWTwXn1U7tznDyHtkk3wTtbzAwsQzz7snzaASSAzkUtznUTDUzw0wk"

ImageText.inside_treasurepainting:="|<>*136$61.003zzzzzzzU01zzzzzzzzlzzzzzzzzzszzzzzzzzzwTzzzzzzzzyDzzzzzzzzz7z77s7sDwTXzW1s1s1wDlzk0s0M0w7szsCsyAwSDwTwDwTbz73yDy7w01z3Uz7z7y00y1sTXzXz7zw0zDlzlzVzwQTrszszszwSDzwTwTwDaD7DyDyDz0331Uz7z7zk1k0kTXznzw3wQyDzzzzzzzzzw"
ImageText.leftchest:="|<>*101$41.sVztzzy17yDznzy01zyDs0KPzkw00yTy7U01zTsM002RzXU000byA0002Tsk0001zb00003yA00E0Tsk0000zX00201yA00A07sk00E0DnU01U0zD00601wS00M07lw00k0Dbk0300yDk0601szU0M07lj00U0T7y0300yAQ0A03sk80M07l001U0T6U0300yB0040Vsy20M17lw80U2D7zk30AyDz060NwTs080rxhU0k3jjH01U7zC6020Dz8s0A0zuFk0M1zaXU0U3z4D030Dk"
ImageText.centerchest:="|<>*112$61.002007zC1zU00003zr0zk00001zvkzs0001UzxUzw0081UTwETy00000Dy0Tz000007z0DzU00003zUDzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk0zzzzzzs0E0Tzzzzzw000T00000z000Q000001k00A000000M00A000000400600000030060000000U030000000M4"
ImageText.rightchest:="|<>*100$41.zs00003zw0000Azw00004Dw0000C7w0000C7w000073y000033y00003Xy000E1Xy000E1Xw00001Xw0A301Xw08201Xw08401bw0E803bs0Xk03bs2Y0077sAN00DDskk00TDlVw00yDU7w01yTUwc03wTXvM07wTsQM0Dsz1kk0MMy10k0UFy01U10lwM1U20XwE3045Xs0208D7s060Mz7s040TyDs0A0TyDU0M0TwT00E0BNz60k0ORzy1U0ony0301dbw0301mPs0603YbyE"
ImageText.leftchestopen:="|<>*115$31.zzzzzzzzzzzzzzzs3zzzzxzzzzzzzzzzUzzzg07zzrk1zzvk0Tzw007zy000zz000DzU001zk000Ds0003w0000y0000D0000zb000Tw000zw003k4000s+000Dz0007z0001zk001zs001z4000s60003z0000TU0003U0000E000080000z0000k0003UQ00C07U0400A0400NwQ01"
ImageText.centerchestopen:="|<>*78$61.0C0100U1v003U0E0008620000013020010000Uc00000EaDn61sz0UBzzk43yzs60zz3sDXTzU0sks0TsDzy1Vy7Uzzrzxj1z1zjzzzwG0DU0Xzzzy007U03zzzzU87s03zzzzgG3w0azzzzzwk01wTzzzzyM0DzTzzzzzDUTzzzzzzzzlzzzzzzzzzszzzzzzzzzyTzzzzzzzzzzzzzzw"
ImageText.rightchestopen:="|<>*70$41.zzzzzU1zzzzz03zzzzs07zzzz00Dzzzw00TzzzU00zzzy001zzzs003zzz0007zzw000DzzU000Tzy0000zzs0001zz00003zw00007zk0000Dz00000Ts00000zU00001w000003k000007000000C000000TU00000zU00001zk00003zs00007zw0000Dzw0000Tzy1U00zzz2001zzzU003zzzc00Dzzzk00Tzzzw00zzzzy06zzzzy01zzyzy03zzzDz27zzzbzwDzzznzsE"
ImageText.usekey:="|<>*125$31.zzzzzjlzztnkzzwtsTzzwMDzzyUY70bEm30nAtQaN7wsFAXyMA6Fz9aD8zYXDaTm10nzzzaDzzzrbzzzsXzzzy3zzzzzzU"
ImageText.open:="|<>*145$41.zzzzzzzzzzzzzzzzzzzzz0Tzzzzw0TzzzzlsTzzzz7wTzzzyDskD1UQztUA30NznCNmAnzaQXYxXyAs09tbwtnDnn3Vn6Tbb07US1jDUz1yDSzzyTzzzzzwzzzzzztzzzzzznzzzzzzzzzzw"

ImageText.enter:="|<>*152$41.zzzzzzzk3zzzzzUDzzzzz7zzzzzyTzyTzzwzUQ630s30E821k6QnnaTbwtbbBzDtnD0PyTnaSTrwzbAwzjs1CQA3Ts6QwwCzzzzzzzw"
ImageText.party1:="||<>*146$51.0000000000000000000000000U0000000A00000001U0000000A00040001UkAFxUE0ATVjTy701bwDNwkk0A1lkA7C01UCA1UNU0A7lUA3w01XiA1UD00AtlUA1s01aCA1k700AzlU7kk01XyA0SC00A00001U0000000Q000000030004"
ImageText.party2:="|<>*143$10.0001kTnzAC0s1UC0k30M3UA1UC1zrz00000U"
ImageText.party3:="|<>*143$11.000000y3y0S0Q0s3UT0S0S0Q0M0k3Xy7s100004"
Imagetext.go:="|<>*145$31.zzzzzy1z0zQ0S0D40C03WDz7skDz7wMDzXzA7knzXHsNzndzATtoTbDsv7nXszk1s0wQ1z0zDzzzzw"
ImageText.cancelauto:="|<>*111$61.TzzzzzzzzzjkzbnyzVk4rU7XsyD0M2PV3lwT724TBXzsS7X7yTanzsD1l7zDnFzwXUMXzbtczwNn4Hzk4oTy8Nm9zs6PDz0As4TwzBXz06S3DyTaswblDVVtDlS0Hwbss0U8DUnz3yz1k47zzzzzzzzzvzzzzzzzzzxzzzzzzzzzyzzzzzzzzzzTztwT80S1zjzsyDa0C0DrzwD7ntyD7vzy7XtwyDlxzy1lwyT7wyzzAsyTDbyDTz6ATDbnz7jzU6Dbntzbrzk3bntwTnvzlsnlwz7nxztyM1yTk1yzwzC1zDw3zTzzzzzzzzzk"
ImageText.auto:="|<>*107$51.zzzzDbzzrzzzwSDzzzzzzlszzzzzzzzzzzzbtzA0DVzszDl01k1z3tyDXwA7sTDlwTXsy1tyDXMzbkDDlwTAwyNtyDXtbrX7DlwTAyw0tyDm9jb037lyH7wtyQyTnwT7DlV3wSkVnzC1zn70TzzzzblzzzzzzlwzzzzzzwTzzzzzzyD7zzY"
ImageText.skip:="|<>*138$41.zzzzzzy0wT1sw00sw7ls01lsTXkXnXVz7Vbz67yD37y0TwS67w0zswA7s3zls43k7zXkA3U7z7UQ707yD3yCA7wS7wQQ7swBssw7lsMVlw7Xkk3Xw77VUT7wCD3zzzzzzz"
ImageText.next:="|<>*164$51.zzzzzzzztzwTzzzzz7zXzzzzzsTwTzzzzz3zXzzzzzsDwTzzzzv0zXzzzzyN3wTUyDlUADXs3kwM1kwSCD77nD3XntwFyNwAQ07kTnDlXU0z3yNz4QTzsTnDw3Xzy1yNzkSDzWDnDz3ksssy9zwT0CDXsTzny7nyDbzzzzzzzzU"

ImageText.ok:="|<>*142$31.zzzzzzUTbbzU7XVzU1lVzXwMVzXzAFzlzW1ztzl1zwzskTyDwN7zbyQlzkwCQTw0DD7zUTblzzzzzw"
ImageText.ok2:="|<>*156$31.zzzzzy1znyQ0DsyA01wSADkyCCDyD6DDzXW7bzkk7rzsM7vzwA3xzy60yTz76DDz3XXXzXlssT3syC03wzXk7yTtzzzzzU"

ImageText.ffrkapp:="|<>*161$31.0000000000000000000000000000000000009i0AU6PkDs1aQM65wmSl0yP6skPjWzs/rXLw3rssy0rwQS0zv7PUzz3zsTylxwzzszyLzsbjdzsDzkDy3jw7zVzyTzlzyDzlzy3xsTC0OM320000000000000000E"
ImageText.play:="|<>*146$31.zzzzzs37zzw0XzzyC1zzz70zzzX4ENlk284Ns77nAwTblYyDnUsT7taQDnymDDtzM3bzzzzbzzzznzzzzny"
ImageText.exploring:="|<>*67$21.DwD3zXkzyQ3zX87wN4zXynwTqTXkzw07zk0y7zzkjzy407zU0Tw03TU0Pw03TU9Pw1vTVsPwC4"
ImageText.backtitle:="|<>*134$35.zzzzzz01Dwzy02TtzzlzznzzXznbzz7n1D3yDY2Q3wTCQlnsyQtbbtwtn0DntnaTzbnbCTzDb0Q1yTD4w7zzzzzw"
;emulator specific image, may adjust for other app
ImageText.crashopen:="|<>*187$18.0000z23zq7VyC0SA0yQ1yM3yM00M00M00Q0CA0AC0Q7Vs3zk0z0000U"
ImageText.crashok:="|<>0x029789@0.91$15.003UUn4A8W1YUAw1bUAmV4QMVS4000U"
Return