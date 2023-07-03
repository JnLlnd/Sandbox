#requires AutoHotkey v1.1
#SingleInstance,Force
#NoEnv

; Enable hotkeys only if CanDoIt() returns true
Hotkey, If, CanDoIt()
	Hotkey, !F1, DoIt
	Hotkey, !F2, DoIt
	Hotkey, !F3, DoIt
Hotkey, If

; Handle for the "Hotkey, If" condition
#If, CanDoIt()
#If

return


DoIt:
MsgBox, %A_ThisLabel% with: %A_ThisHotkey%
SendLevel 1
SendMode Event ; Input InputThenPlay  Play
if (A_ThisHotkey = "!F1")
	Send, !{F2}
if (A_ThisHotkey = "!F2")
	Send, !{F3}
return


CanDoIt() ; name of the function must match the #If handle above
{
	return true
	; return false
}


/*

#requires AutoHotkey v1.1
#SingleInstance,Force
#NoEnv

Hotkey, !F1, DoIt
Hotkey, !F2, DoIt

return

DoIt:
MsgBox, %A_ThisLabel% with: %A_ThisHotkey%
if (A_ThisHotkey = "!F1")
	Send, !{F2}
return
