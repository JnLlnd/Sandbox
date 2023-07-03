;
; Recursion using custom function
;

#SingleInstance force

global strRoot := "N:\Recursivity_Simple" ; replace with your own root folder

str := ScanFilesIndent(strRoot) ; recursive function
; str := ScanFilesMsgBox(strRoot) ; recursive function
; str := ScanFiles(strRoot) ; recursive function
; str := ScanFilesHeader(strRoot) ; recursive function

ToolTip ; close ToolTip (used in ScanFilesIndent)

Gosub, ShowFiles ; build and show gui

return


;------------------------------------------------
ScanFilesIndent(strFolder, intLevel := 0)
;------------------------------------------------
{
	; MsgBox, Entering`n%strFolder%
	
	ToolTip, Scanning: %strFolder%
	loop, %intLevel%
		strIndent .= "--" ; add spaces according to number of sublevels
	
	Loop, Files, %strFolder%\*.*, F ; scan files only
		strResult .= strIndent . StrReplace(A_LoopFileFullPath, strRoot . "\") . "`n"
	
	; value of intLevel is increased for next sublevel
	intLevel++
	Loop, Files, %strFolder%\*.*, D ; scan folders only
	{
		strResult .= strIndent . Format("{:U}", StrReplace(A_LoopFileFullPath, strRoot . "\")) . "`n"
		strResult .= ScanFilesIndent(A_LoopFileFullPath, intLevel)
	}
	
	; MsgBox, , % StrReplace(A_LoopFileFullPath, strRoot, "."), %strResult%
	return strResult
}
;------------------------------------------------


;------------------------------------------------
ShowFiles:
;------------------------------------------------
Gui, Font, w700
Gui, Add, Text, , Files under %strRoot%
Gui, Font
Gui, Font, , Courier New
Gui, Add, Edit, vFiles w600 r25
GuiControl, , Files, %str%
Gui, Font
Gui, Add, Button, vCloseExit gCloseExit default, Close and Exit
GuiControl, Focus, CloseExit
Gui, Show
return
;------------------------------------------------


;------------------------------------------------
CloseExit:
;------------------------------------------------
Gui, Destroy
ExitApp
;------------------------------------------------


;------------------------------------------------
ScanFilesMsgBox(strFolder)
; strFolder and strResult are local variables
; when the function is called recursively, a new set (instance) of local variables is created
;------------------------------------------------
{
	MsgBox, Entering`n%strFolder%
	
	Loop, Files, %strFolder%\*.*, FD ; scan files and folders (in undertermined order)
		if InStr(FileExist(A_LoopFileFullPath), "D")
			strResult .= ScanFilesMsgBox(A_LoopFileFullPath) ; recursive call to the current function
		else
			strResult .= StrReplace(A_LoopFileFullPath, strRoot, ".") . "`n"
	
	MsgBox, , % StrReplace(A_LoopFileFullPath, strRoot, "."), %strResult%
	return strResult
}
;------------------------------------------------


;------------------------------------------------
ScanFiles(strFolder)
;------------------------------------------------
{
	Loop, Files, %strFolder%\*.*, F ; first scan files only
		strResult .= StrReplace(A_LoopFileFullPath, strRoot, ".") . "`n"
	Loop, Files, %strFolder%\*.*, D ; then scan folders only
		strResult .= %A_ThisFunc%(A_LoopFileFullPath)
	
	return strResult
}
;------------------------------------------------


;------------------------------------------------
ScanFilesHeader(strFolder)
;------------------------------------------------
{
	Loop, Files, %strFolder%\*.*, F
		strResult .= StrReplace(A_LoopFileFullPath, strFolder . "\") . "`n"
	Loop, Files, %strFolder%\*.*, D
	{
		strResult .= Format("{:U}", StrReplace(A_LoopFileFullPath, strRoot . "\")) . "`n" ; insert upper case folder name
		strResult .= %A_ThisFunc%(A_LoopFileFullPath)
	}
	
	return strResult
}
;------------------------------------------------


