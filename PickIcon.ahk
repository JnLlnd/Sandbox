#SingleInstance Force

strIconResource := PickIconDialog(A_WinDir . "\system32\shell32.dll,1")

ParseIconResource(strIconResource, strIconFile, intIconIndex)

Gui, Add, Picture, x16 y16 w32 h32 vf_picIcon
GuiControl, , f_picIcon, *icon%intIconIndex% %strIconFile%
Gui, Show, w64 h64

return

;------------------------------------------------------------
PickIconDialog(strIconResource)
;------------------------------------------------------------
{
	; Source: http://ahkscript.org/boards/viewtopic.php?f=5&t=5108#p29970
	VarSetCapacity(strIconFile, 1024) ; must be placed before strIconFile is initialized because VarSetCapacity erase its content
	ParseIconResource(strIconResource, strIconFile, intIconIndex)

	; WinGet, hWnd, ID, A
	hWnd := 0
	
	if (intIconIndex >= 0) ; adjust index for positive index only (not for negative index)
		intIconIndex := intIconIndex - 1
	
	if !DllCall("shell32\PickIconDlg", "Uint", hWnd, "str", strIconFile, "Uint", 260, "intP", intIconIndex)
		return ; return empty if user cancelled
	; on some Windows 10 systems, when the path of strIconFile is longer than 74 chars, this DllCall returns the strIconFile truncated or it just hangs
	MsgBox, % strIconFile . "," . intIconIndex . " (" . StrLen(strIconFile) . ")"
	
	if (intIconIndex >= 0) ; adjust index for positive index only (not for negative index)
		intIconIndex := intIconIndex + 1

	return strIconFile . "," . intIconIndex
}
;------------------------------------------------------------

;------------------------------------------------------------
ParseIconResource(strIconResource, ByRef strIconFile, ByRef intIconIndex)
;------------------------------------------------------------
{
	If !InStr(strIconResource, ",")
		strIconResource := strIconResource . ",1" ; use its first icon
	
	; from here, strIconResource is always of icongroup files format ("file,index")
	intComaPos := InStr(strIconResource, ",", , 0) - 1 ; search from the end because filename could also include a coma (ex.: "file,name.ico,1")
	strIconFile := SubStr(strIconResource, 1, intComaPos)
	intIconIndex := StrReplace(strIconResource, strIconFile . ",")
}
;------------------------------------------------------------


