#SingleInstance Force
#requires AutoHotkey v1.1
; #requires AutoHotkey v2

global g_intHwnd

#If, WinActiveMyGui() ; main Gui title
#If

Hotkey, If, WinActiveMyGui()
	Hotkey, Space, ShowHotkey, On
	Hotkey, Tab, ShowHotkey, On
	Hotkey, ^Tab, ShowHotkey, On
Hotkey, If

Gui, New, +Hwndg_intHwnd +Resize -MinimizeBox -0x10000, MyGui
Gui, Font, s12, Courier New
Gui, Add, Edit, w300 h200 ; +WantTab
Gui, Font
Gui, Add, Button, , Nothing
Gui, Add, Button, gGuiClose, Close
Gui, Show

return

ShowHotkey:
Send, %A_ThisHotkey%
MsgBox, % "Hotkey is " . A_ThisHotkey . " (" . Asc(A_ThisHotkey) . ")"
return

WinActiveMyGui()
{
	return WinActive("ahk_id " . g_intHwnd)
}

GuiClose:
ExitApp
