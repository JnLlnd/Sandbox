#SingleInstance Force
#requires AutoHotkey v1.1
#Include %A_ScriptDir%\Lib\Edit.ahk ; from jballi (https://www.autohotkey.com/boards/viewtopic.php?f=6&t=5063)

Gui, Add, Edit, w200 h150 -Wrap +hwndMyEdit, % "12345678`nABCDEFGH`nabcdefgh`n12345678`nABCDEFGH`nabcdefgh`n"
Gui, Show
Edit_SetSel(MyEdit, -1)
return

^Up::Gosub, MoveLineUp
^Down::Gosub, MoveLineDown

;---------------------
MoveLineUp:
MoveLineDown:

if Edit_IsWordWrap(MyEdit) ; works only if word wrap is turned off
	return

intSelStart := Edit_GetSel(MyEdit)
intSelLine := Edit_LineFromChar(MyEdit, intSelStart) ; line of selection start, zero-based
; check if move is out of bound
if (A_ThisLabel = "MoveLineUp" and intSelLine < 1
	or (A_ThisLabel = "MoveLineDown" and intSelLine + 3 > Edit_GetLineCount(MyEdit)))
	return
	
Critical, On
GuiControl, -Redraw, %MyEdit%

intLineStart := Edit_LineIndex(MyEdit)
intLineEnd := Edit_LineIndex(MyEdit, intSelLine + 1) ; includes inding CRLF
Edit_SetSel(MyEdit, intLineStart, intLineEnd)
strMovedLine := Edit_GetSelText(MyEdit)
Edit_Clear(MyEdit) ; clear selected moved text

intDestInsert := Edit_LineIndex(MyEdit, intSelLine + (A_ThisLabel = "MoveLineUp" ? -1 : 1))
Edit_SetSel(MyEdit, intDestInsert, intDestInsert) ; insertion point for moved text
Edit_ReplaceSel(MyEdit, strMovedLine) ; insert moved text
Edit_SetSel(MyEdit, intDestInsert, intDestInsert + StrLen(strMovedLine) - 1) ; select moved text (excluding CRLF)

GuiControl, +Redraw, %MyEdit%
Critical, Off
Edit_ScrollCaret(MyEdit) ; make sure the leftmost position of the selection is visible

return
;---------------------


;---------------------
GuiClose:
ExitApp
;---------------------
