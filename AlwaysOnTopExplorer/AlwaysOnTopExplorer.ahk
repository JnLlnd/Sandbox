#requires AutoHotkey v1.1
#SingleInstance,Force
#NoEnv

Menu, MyMenu, Add, WindowsAlwaysOnTop

return

MButton::
Menu, MyMenu, Show
return

#t::
Gosub, WindowsAlwaysOnTop
return


;------------------------------------------------------------
WindowsAlwaysOnTop:
;------------------------------------------------------------

WinGet, g_strTargetWinId, , A
WinGetTitle, strTitle, ahk_id %g_strTargetWinId%
WinGet, intExStyleBefore, ExStyle, ahk_id %g_strTargetWinId%

str := A_ThisLabel
	. "`n" . "A_ThisHotkey: " . A_ThisHotkey
	. "`n" . "Window ID: " . g_strTargetWinId
	. "`n" . "Title: " . strTitle
	. "`n" . "ExStyle Before: " . intExStyleBefore
	. "`n" . "ExStyle Before: " . (intExStyleBefore & 0x8 ? "ON TOP" : "not on top")

; WinSet, AlwaysOnTop, Toggle, ahk_id %g_strTargetWinId%
Sleep, 200
WinSet, AlwaysOnTop, % (intExStyleBefore & 0x8 ? "Off" : "On"), ahk_id %g_strTargetWinId%
WinGet, intExStyleAfter, ExStyle, ahk_id %g_strTargetWinId%

str .= "`n" . "ExStyle After: " . intExStyleAfter
	. "`n" . "ExStyle After: " . (intExStyleAfter & 0x8 ? "ON TOP" : "not on top")

MsgBox, %str%

return
;------------------------------------------------------------
