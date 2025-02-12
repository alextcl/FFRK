#NoEnv
#SingleInstance Force
#WinActivateForce
Menu, Tray, Icon, %A_ScriptDir%\images\FFRK.ico
SetWorkingDir %A_ScriptDir% ;Sets the working directory where the script is actually located.
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
SendMode Input ;More reliable sending mode



;Paitings Priority
;Change the numbers to change the order
;Remove "painting_boss" if you want to choose a different team for the boss battle
Priority1=painting_treasure
Priority2=painting_exploration
Priority3=painting_onslaught
Priority4=painting_restoration
Priority5=painting_combatred
Priority6=painting_combatorange
Priority7=painting_combatgreen
Priority8=painting_portal
Priority9=painting_boss

TheAlarm=%A_WinDir%\Media\Alarm01.wav

;Limit the search area for ImageSearch. Use %A_ScreenWidth% and %A_ScreenHeight% if you want to search the whole screen
SearchWidth=%A_ScreenWidth%
SearchHeight=%A_ScreenHeight%

ReturnMouse=yes ;Returns the mouse to the position it was at before clicking on the emulator
OpenSealedDoor=yes


Pause ;Script begins paused
Gosub, TheMainLoop

F1::
;Press F1 to start and stop your script
Pause, Toggle
;WinMove, BlueStacks, , 0, 0, 498 ;Automtically move and resize emulator window, uncomment to use
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

TheMainLoop:
Loop
	{
	Sleep 100
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\auto.png
	If (ErrorLevel = 0)
		{
		Gosub, ClickOnFoundImage
		Sleep 2000
		}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\ffrkapp.png
	If (ErrorLevel = 0)
		{
		Gosub, ClickOnFoundImage
		Sleep 2000
		}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\play.png
	If (ErrorLevel = 0)
		{
		Gosub, ClickOnFoundImage
		Sleep 2000
		}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\exploring.png
	If (ErrorLevel = 0)
		{
		Gosub, ClickOnFoundImage
		Sleep 2000
		}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\enter.png
	If (ErrorLevel = 0)
		{
		Gosub, ClickOnFoundImage
		Sleep 2000
		}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\go.png
	If (ErrorLevel = 0)
		{
		Gosub, ClickOnFoundImage
		Sleep 2000
		}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\ok.png
	If (ErrorLevel = 0)
		{
		Gosub, ClickOnFoundImage
		Sleep 2000
		}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\ok2.png
	If (ErrorLevel = 0)
		{
		Gosub, ClickOnFoundImage
		Sleep 2000
		}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\inside_explorationpainting.png
	If (ErrorLevel = 0)
		{
		;This "Move On" button is only clicked when inside an "Exploration Painting" to prevent the script from clicking on the "Move On" button while inside a "Treasure Painting"
		ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\moveon.png
		If (ErrorLevel = 0)
			{
			Gosub, ClickOnFoundImage
			Sleep 2000
			}
		ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\moveon2.png
		If (ErrorLevel = 0)
			{
			Gosub, ClickOnFoundImage
			Sleep 2000
			}
		}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\inside_restoration.png
	If (ErrorLevel = 0)
		{
		;This "Move On" button is only clicked when inside an "Restoration Painting" to prevent the script from clicking on the "Move On" button while inside a "Treasure Painting"
		ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\moveon.png
		If (ErrorLevel = 0)
			{
			Gosub, ClickOnFoundImage
			Sleep 2000
			}
		ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\moveon2.png
		If (ErrorLevel = 0)
			{
			Gosub, ClickOnFoundImage
			Sleep 2000
			}
		}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\inside_onslaught.png
	If (ErrorLevel = 0)
		{
		;This "Move On" button is only clicked when inside an "Onslaught Painting" to prevent the script from clicking on the "Move On" button while inside a "Treasure Painting"
		ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\moveon.png
		If (ErrorLevel = 0)
			{
			Gosub, ClickOnFoundImage
			Sleep 2000
			}
		ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\moveon2.png
		If (ErrorLevel = 0)
			{
			Gosub, ClickOnFoundImage
			Sleep 2000
			}
		}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\skip.png
	If (ErrorLevel = 0)
		{
		Gosub, ClickOnFoundImage
		Sleep 2000
		}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\next.png
	If (ErrorLevel = 0)
		{
		Gosub, ClickOnFoundImage
		Sleep 2000
		}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\sealeddoor.png
	If (ErrorLevel = 0)
		{
		If (OpenSealedDoor="yes")
			{
			ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\yes.png
			If (ErrorLevel = 0)
				{
				;Only click on "Yes" when presented with a Sealed Door.
				Gosub, ClickOnFoundImage
				Sleep 2000
				}
			}
		If (OpenSealedDoor="no")
			{
			ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\no.png
			If (ErrorLevel = 0)
				{
				;Only click on "no" when presented with a Sealed Door.
				Gosub, ClickOnFoundImage
				Sleep 2000
				}
			}
		}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\inside_treasurepainting.png
	If (ErrorLevel = 0)
		{
		SoundPlay, %TheAlarm%, 1
		}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\dungeoncomplete.png
	If (ErrorLevel = 0)
		{
		SoundPlay, %TheAlarm%, 1
		}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\labyrinth_blue.png
	If (ErrorLevel = 0)
		{
		;Only use the painting priority loop when inside main labyrinth to prevent the script from cycling too early and choosing the wrong painting.
		Sleep 2000
		Gosub, PaintingPriority
		}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\labyrinth_purple.png
	If (ErrorLevel = 0)
		{
		;Last floor is purple. Only use the painting priority loop when inside main labyrinth to prevent the script from cycling too early and choosing the wrong painting.
		Sleep 2000
		Gosub, PaintingPriority
		}
	}
Return


PaintingPriority:
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\%Priority1%.png
	If (ErrorLevel = 0)
		{
		Gosub, ClickOnFoundImage
		Sleep 500
		Gosub, ClickOnFoundImage
		Sleep 2000
		}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\%Priority2%.png
	If (ErrorLevel = 0)
		{
		Gosub, ClickOnFoundImage
		Sleep 500
		Gosub, ClickOnFoundImage
		Sleep 2000
		}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\%Priority3%.png
	If (ErrorLevel = 0)
		{
		Gosub, ClickOnFoundImage
		Sleep 500
		Gosub, ClickOnFoundImage
		Sleep 2000
		}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\%Priority4%.png
	If (ErrorLevel = 0)
		{
		Gosub, ClickOnFoundImage
		Sleep 500
		Gosub, ClickOnFoundImage
		Sleep 2000
		}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\%Priority5%.png
	If (ErrorLevel = 0)
		{
		Gosub, ClickOnFoundImage
		Sleep 500
		Gosub, ClickOnFoundImage
		Sleep 2000
		}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\%Priority6%.png
	If (ErrorLevel = 0)
		{
		Gosub, ClickOnFoundImage
		Sleep 500
		Gosub, ClickOnFoundImage
		Sleep 2000
		}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\%Priority7%.png
	If (ErrorLevel = 0)
		{
		Gosub, ClickOnFoundImage
		Sleep 500
		Gosub, ClickOnFoundImage
		Sleep 2000
		}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\%Priority8%.png
	If (ErrorLevel = 0)
		{
		Gosub, ClickOnFoundImage
		Sleep 500
		Gosub, ClickOnFoundImage
		Sleep 2000
		}
	ImageSearch, FoundX, FoundY, 0, 0, %SearchWidth%, %SearchHeight%, *80 %A_ScriptDir%\images\%Priority9%.png
	If (ErrorLevel = 0)
		{
		Gosub, ClickOnFoundImage
		Sleep 500
		Gosub, ClickOnFoundImage
		Sleep 2000
		}
Return
