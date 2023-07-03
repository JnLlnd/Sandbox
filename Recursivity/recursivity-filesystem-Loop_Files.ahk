;
; Recursion using built-in option of the "Loop, Files" command
;

#SingleInstance force

strFolder := "N:\Recursivity_Simple"

Loop, Files, %strFolder%\*.*, R
	str .= StrReplace(A_LoopFileFullPath, strFolder, ".") . "`n"

Gosub, ShowFiles
return

;------------------------------------------------
ShowFiles:
;------------------------------------------------
Gui, Font, w700
Gui, Add, Text, , Files under %strFolder%
Gui, Font
Gui, Font, , Courier New
Gui, Add, Edit, w800 r25, %str%
Gui, Font
Gui, Add, Button, vCloseExit gCloseExit default, Close and Exit
GuiControl, Focus, CloseExit
Gui, Show
return
;------------------------------------------------

CloseExit:
Gui, Destroy
ExitApp
