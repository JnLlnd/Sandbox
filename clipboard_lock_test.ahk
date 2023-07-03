#SingleInstance Force
#requires AutoHotkey v1.1

; !m:: ; show Clipboard length
; MsgBox, % StrLen(Clipboard)
; return

!m:: ; show Clipboard length
While, DllCall("GetOpenClipboardWindow")
	Sleep, 10
MsgBox, % StrLen(Clipboard)
return

