#requires AutoHotkey v1.1
#SingleInstance,Force
DetectHiddenWindows, On

; A_ScreenDPI 144 /96 = 150%

Gui, New, +HwndstrGuiHwnd +Resize ; -DPIScale
Gui, Add, Picture, vintPictureId, %A_ScriptDir%\100x100.png
Gui, Add, Button, x10 y150 Default gButton vintButton1Id, Short
Gui, Add, Button, x20 yp gButton vintButton2Id, Long label
Gui, Add, Button, x30 yp gButton vintButton3Id, Very very very very very long label

Gui, Show, w800 h400 x500 y500 
GuiCenterButtons(strGuiHwnd, , , , "intButton1Id", "intButton2Id", "intButton3Id")

intNormalDPI := 96

GuiControlGet, arrButton, Pos, intButton1Id
intButtonWidth := arrButtonW
intButtonHeight := arrButtonH

GuiControlGet, arrPicture, Pos, intPicture1Id
intPictureWidth := arrPictureW
intPictureHeight := arrPictureH

str := ""
str .= "`n" . "A_ScreenDPI: " . A_ScreenDPI
str .= "`n" . "intNormalDPI: " . intNormalDPI
str .= "`n" . "Scaling (A_ScreenDPI / intNormalDPI): " . Format("{1:i}", A_ScreenDPI / intNormalDPI * 100) . "%"
str .= "`n" . "Button (width x height): " . intButtonWidth . " x " . intButtonHeight
str .= "`n" . "Picture (width x height): " . intPictureWidth . " x " . intPictureHeight
; MsgBox, %str%

return

GuiSize:
; A_GuiWidth
; A_GuiHeight
GuiCenterButtons(strGuiHwnd, , , , "intButton1Id", "intButton2Id", "intButton3Id")

return

Button:
return



;------------------------------------------------------------
GuiCenterButtons(strWindowHandle, intInsideHorizontalMargin := 10, intInsideVerticalMargin := 0, intDistanceBetweenButtons := 20, arrControls*)
; This is a variadic function. See: http://ahkscript.org/docs/Functions.htm#Variadic
;------------------------------------------------------------
{
	; A_DetectHiddenWindows must be on (app's default); Gui, Show acts on current default gui (1: or 2: , etc)
	; Gui, Show, Hide ; hides the window and activates the one beneath it, allows a hidden window to be moved, resized, or given a new title without showing it
	WinGetPos, , , intWidth, , ahk_id %strWindowHandle%
	fltScaling := (A_ScreenDPI / 96)
	intWidth := intWidth // fltScaling

	; find largest control height and width
	intMaxControlWidth := 0
	intMaxControlHeight := 0
	intNbControls := 0
	for intIndex, strControl in arrControls
		if StrLen(strControl) ; avoid emtpy control names
		{
			intNbControls++ ; use instead of arrControls.MaxIndex() in case we get empty control names
			GuiControlGet, arrControlPos, Pos, %strControl%
			if (arrControlPosW > intMaxControlWidth)
				intMaxControlWidth := arrControlPosW
			if (arrControlPosH > intMaxControlHeight)
				intMaxControlHeight := arrControlPosH
		}
	
	intMaxControlWidth := intMaxControlWidth + intInsideHorizontalMargin
	intButtonsWidth := (intNbControls * intMaxControlWidth) + ((intNbControls  - 1) * intDistanceBetweenButtons)
	intLeftMargin := (intWidth - intButtonsWidth) // 2

	for intIndex, strControl in arrControls
		if StrLen(strControl) ; avoid emtpy control names
		{
			; MsgBox, % "x" . intLeftMargin + ((intIndex - 1) * intMaxControlWidth) + ((intIndex - 1) * intDistanceBetweenButtons)
				; . " w" . intMaxControlWidth
				; . " h" . intMaxControlHeight + intInsideVerticalMargin
			GuiControl, Move, %strControl%
				, % "x" . intLeftMargin + ((intIndex - 1) * intMaxControlWidth) + ((intIndex - 1) * intDistanceBetweenButtons)
				. " w" . intMaxControlWidth
				. " h" . intMaxControlHeight + intInsideVerticalMargin
		}
}
;------------------------------------------------------------


