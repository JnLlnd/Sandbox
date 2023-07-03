;
; Recursion to build a menu and ist submenus
;

#SingleInstance force

strMenuSourceText =
; Syntax:	Type|Name|Action
; Type:		Menu or Item, Z to end a menu, (empty tor menu separator)
; Action:	Gosub command (foir named items only)
(
Menu|MAIN
Menu|Menu A
Item|Item A1|Action1
Item
Item|Item A2|Action2
Item|Say Hello|Action3
Z
Menu|Menu B
Menu|Menu BA
Item|Item BA1|Action1
Item|Item BA2|Action2
Z
Item|Item B1|Action1
Item|Item B2|Action2
Z
Item|Item 1|Action1
Z
)

global arrMenuSource := StrSplit(strMenuSourceText, "`n")

; loop, % arrMenuSource.Length()
	; strarrMenuSource .=  A_Index . " > " . arrMenuSource[A_Index] . "`n"
; MsgBox, %strarrMenuSource%

global intMenuLine := 1
BuildMenu("MAIN")

return

!m::
Menu, Main, Show
return

;------------------------------------------------
BuildMenu(strMenuName)
;------------------------------------------------
{
	Loop
	{
		intMenuLine++
		arrMenuLine := StrSplit(arrMenuSource[intMenuLine], "|")
		
		if (arrMenuLine[1] = "Z") or (intMenuLine > arrMenuSource.Length())
			break
		
		if (arrMenuLine[1] = "Menu")
		{
			strMenuPath := strMenuName . " > " . arrMenuLine[2]
			BuildMenu(strMenuPath)
			Menu, % strMenuName, Add, % arrMenuLine[2], % ":" . strMenuPath
		}
		else
		{
			strTemp := arrMenuLine[2] . " | " . arrMenuLine[3]
			Menu, % strMenuName, Add, % arrMenuLine[2], % arrMenuLine[3]
		}
	}
}
;------------------------------------------------


;------------------------------------------------
Action1:
Action2:
;------------------------------------------------

if (A_ThisLabel = "Action2")
	SoundBeep
MsgBox, Action:`n%A_ThisLabel%`n`nMenu name:`n%A_ThisMenu%`n`nItem name:`n%A_ThisMenuItem%

return
;------------------------------------------------


;------------------------------------------------
Action3:
;------------------------------------------------
MsgBox, Hello
return
;------------------------------------------------

