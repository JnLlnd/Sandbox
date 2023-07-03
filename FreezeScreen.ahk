#SingleInstance Force
SetBatchLines, -1

Gui, Add, Text, vAllo w100 h60, Allo
Gui, Add, Button, gGo1, Go1
Gui, Add, Button, gGo2, Go2
Gui, Show

return

Go1:
Go2:
if (A_ThisLabel = "Go2")
{
	id := WinExist("A")
	WinGetTitle, title, ahk_id %id%
	MsgBox, %title%
	if not DllCall("LockWindowUpdate", Uint, id)
		MsgBox, An error occured while locking window display
}
	
loop, 10
{
	GuiControl, , Allo, Allo%A_index%
	SoundBeep
	Sleep, 100
}

if (A_ThisLabel = "Go2")
	DllCall("LockWindowUpdate", Uint, 0)  ; Pass 0 to unlock the currently locked window.

return

