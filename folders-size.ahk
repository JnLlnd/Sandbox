#SingleInstance,Force

global strX

strPaths := ""
	. "J:"
	; . "E:\"

Loop, Parse, strPaths, |
{
	ToolTip, %A_LoopField%
	str .= SizeOf(A_LoopField)
}
str := SubStr(str, 1, -1)
ToolTip

###_V("", str)
ClipBoard := str

ExitApp


SizeOf(strPath)
{
	Loop, Files, %strPath%\*.*, D
	{
		; ###_V("", A_LoopFileFullPath)
		intTotalSize := 0
		strX := ""
		strLoopFileFullPath := A_LoopFileFullPath
		Loop, Files, %strLoopFileFullPath%\*.*, FR
		{
			; ###_V(strLoopFileFullPath, strLoopFileFullPath)
			; if InStr(strLoopFileFullPath, "J:\! Mes Documents\wp-jeanlalonde.ca-BK-20121225")
				; strX .= A_LoopFileFullPath . "`t" . A_LoopFileSize . "`n"
			intTotalSize += A_LoopFileSize
		}
		; if InStr(strLoopFileFullPath, "J:\! Mes Documents\wp-jeanlalonde.ca-BK-20121225")
		; {
			; ###_V("strX", strX)
			; Clipboard := strX
		; }
		str .= A_LoopFileFullPath . "`t" . intTotalSize . "`n"
	}
	return str
}