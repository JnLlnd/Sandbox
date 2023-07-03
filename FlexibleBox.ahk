#requires AutoHotkey v1.1
#SingleInstance,Force
#NoEnv

Gui, -SysMenu -Border -Caption ToolWindow
Gui, Color, EEAA99    
Gui +LastFound
WinSet, TransColor, EEAA99
WinSet, AlwaysOnTop, On

Gui, Add, Edit, x0 y0 vf_SearchAString vMyEdit
Gui, Add, Button, gGuiEscape x+0 yp h20 w20 vMyButton, X
Gui, Add, ListView, x0 r11 yp+20 Count10 NoSortHdr LV0x10 -Hdr -Multi vMyLV, Col1

Loop, 9
	LV_Add("", "Item " . A_Index)
Random, intLastWidth, 1, 30
Loop, % intLastWidth + 20
	str .= A_Index . " "
LV_Add("", str)
LV_ModifyCol()

intListViewWidth := f_get_pixel_size_of_text(str)

GuiControl, Move, MyLV, % "w" . intListViewWidth + 15
GuiControl, Move, MyEdit, % "w" . intListViewWidth - 5
GuiControl, Move, MyButton, % "x" . intListViewWidth - 5
Gui, Show, AutoSize
return

GuiEscape:
ExitApp
return

; from https://www.autohotkey.com/boards/viewtopic.php?p=374665#p374665
f_get_pixel_size_of_text(text)
{
	; A_GuiFont     := Control_GetFont( hwnd ) ; provide control's HWND if necessary
	; A_GuiFontSize := A_LastError
	A_GuiFont := "MS Shell Dlg"
	A_GuiFontSize := 8
	T := GetTextExtentPoint(text, A_GuiFont, A_GuiFontSize, 0)
	a1 := T.W
	return T.W
}


;https://autohotkey.com/board/topic/16414-hexview-31-for-stdlib/#entry107363   By Sean
GetTextExtentPoint(sString, sFaceName, nHeight = 9, bBold = False, bItalic = False, bUnderline = False, bStrikeOut = False, nCharSet = 0)
{
	hDC := DllCall("GetDC", "Uint", 0)
	nHeight := -DllCall("MulDiv", "int", nHeight, "int", DllCall("GetDeviceCaps", "Uint", hDC, "int", 90), "int", 72)

	hFont := DllCall("CreateFont", "int", nHeight, "int", 0, "int", 0, "int", 0, "int", 400 + 300 * bBold, "Uint", bItalic, "Uint", bUnderline, "Uint", bStrikeOut, "Uint", nCharSet, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "str", sFaceName)
	hFold := DllCall("SelectObject", "Uint", hDC, "Uint", hFont)

	DllCall("GetTextExtentPoint32", "Uint", hDC, "str", sString, "int", StrLen(sString), "int64P", nSize)

	DllCall("SelectObject", "Uint", hDC, "Uint", hFold)
	DllCall("DeleteObject", "Uint", hFont)
	DllCall("ReleaseDC", "Uint", 0, "Uint", hDC)

	nWidth  := nSize & 0xFFFFFFFF
	nHeight := nSize >> 32 & 0xFFFFFFFF
	;Return "Width: " . nWidth . "`n" . "Height: " . nHeight
	Size := {}
	Size.W := nWidth
	Size.H := nHeight
	return Size

}
;www.autohotkey.com/forum/viewtopic.php?p=465438#465438   By SKAN
Control_GetFont( hwnd )
{
	 SendMessage 0x31, 0, 0, , ahk_id %hwnd%       ; WM_GETFONT
	 IfEqual,ErrorLevel,FAIL, Return
	 hFont := Errorlevel, VarSetCapacity( LF, szLF := 60*( A_IsUnicode ? 2:1 ) )
	 DllCall("GetObject", UInt,hFont, Int,szLF, UInt,&LF )
	 hDC := DllCall( "GetDC", UInt,hwnd ), DPI := DllCall( "GetDeviceCaps", UInt,hDC, Int,90 )
	 DllCall( "ReleaseDC", Int,0, UInt,hDC ), S := Round( ( -NumGet( LF,0,"Int" )*72 ) / DPI )
	Return DllCall( "MulDiv",Int,&LF+28, Int,1,Int,1, Str ), DllCall( "SetLastError", UInt,S )
}
