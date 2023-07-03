#SingleInstance Force
#requires AutoHotkey v1.1

!l:: ; lock the Clipboard
DllCall("OpenClipboard", Ptr, A_ScriptHwnd)
ToolTip, Locked
Sleep, 500
Tooltip
return

!u:: ; unlock the Clipboard
DllCall("CloseClipboard", Ptr, A_ScriptHwnd)
ToolTip, Unlocked
Sleep, 500
Tooltip
return


!b:: ; show Clipboard length
MsgBox, % StrLen(Clipboard)
return

