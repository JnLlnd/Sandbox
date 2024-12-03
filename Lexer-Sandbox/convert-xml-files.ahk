#SingleInstance,Force
#Persistent

; strColor := "0x767676"
; ###_V(strColor, invertColor(strColor))

; strTest := "0xFF0000"
; ###_V(strTest, invertColor(strTest))

Loop, Files, C:\Dropbox\AutoHotkey\SandBox\Lexer-Sandbox\Themes\Specifics-ORI\*.xml
{
	strNewFilename := StrReplace(A_LoopFileFullPath, "Specifics-ORI", "Specifics") ; StrReplace(A_LoopFileFullPath, "Specifics\", "Specifics\zzz_")
	FileRead, strFile, %A_LoopFileFullPath%
	intStartTheme := InStr(strFile, "<theme name=""Default"">") - 5
	strBeforeTheme := SubStr(strFile, 1, intStartTheme)
	intEndTheme :=  InStr(strFile, "</theme>") + StrLen("</theme>")
	strAfterTheme := SubStr(strFile, intEndTheme + 2)
	strTheme := SubStr(strFile, intStartTheme + 1, intEndTheme - intStartTheme)
	strTheme := StrReplace(strTheme, "Default", "Light")
	strNewTheme := StrReplace(strTheme, "theme name=""Light""", "theme name=""Dark""")
	; strNewTheme := RevertColors(strNewTheme) . "`n    </theme>`n"
	; ###_V(A_LoopFileFullPath, strNewFilename, strBeforeTheme, strTheme, strNewTheme, strAfterTheme)
	; intStartFc := InStr(strFile, "fc=")
	; strNewFile := SubStr(strFile, 1, intStartFc + 3)
	; strFile := SubStr(strFile, intStartFc + 3 + 1)
	; ###_V("", intStartFc, strNewFile, strFile)
	; intColorLength := InStr(strFile, """")
	; strOldColor := SubStr(strFile, 1, intColorLength - 1)
	; ###_V("", intColorLength, strOldColor)
	FileDelete %strNewFilename%
	FileAppend, %strBeforeTheme%%strTheme%%strNewTheme%%strAfterTheme%, %strNewFilename%, UTF-8
}
###_V("","Finish")
return

RevertColors(strTheme)
{
	intStartFrom := 1
	Loop
	{
		intColorStart := InStr(strTheme, "fc=", false, intStartFrom)
		if !(intColorStart)
		{
			strNewTheme .= SubStr(strTheme, intStartFrom)
			break
		}
		strNewTheme .= SubStr(strTheme, intStartFrom, intColorStart - intStartFrom + 4)
		intStartFrom := intColorStart + 4
		intColorEnd := InStr(strTheme, """", false, intStartFrom)
		strColor := SubStr(strTheme, intStartFrom, intColorEnd - intStartFrom)
		; ###_V(StrLen(strColor), strTheme, intStartFrom, intColorStart, strNewTheme, strColor)
		strNewColor := (StrLen(strColor) ? "0x" . invertColor(strColor) : "")
		; ###_V("" . strColor, strNewColor)
		strNewTheme .= strNewColor
		intStartFrom := intColorEnd
		; ###_V("", strTheme, intStartFrom, intColorEnd, strColor, strNewColor)
	}
	
	return strNewTheme
}

invertColor(color)
{
 c1 := color >> 16
 c2 := 255 & color >> 8
 c3 := 255 & color
 c1 := 255 - c1 << 16
 c2 := 255 - c2 << 8
 c3 := 255 - c3
 new := Format("{:06x}", c1 + c2 + c3)
 new := Format("{:U}", new)
 Return new
}

