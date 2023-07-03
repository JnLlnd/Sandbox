GroupAdd, TestGroup, ahk_exe notepad.exe
GroupAdd, TestGroup, ahk_exe chrome.exe

Hotkey, IfWinActive, ahk_group TestGroup
Hotkey, !f1, DoIt
Hotkey, !f2, DoIt
Hotkey, IfWinActive
return

DoIt:
msgbox %A_thisLabel% - %A_ThisHotkey%
if (A_ThisHotkey = "!F1")
	Send !{F2}
return