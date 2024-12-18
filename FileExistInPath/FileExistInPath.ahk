#requires AutoHotkey v1.1
#SingleInstance,Force
#NoEnv

;---------------------------------
; Prepare executable extensions list from PATHEXT env variable
global g_strExeExtensions
EnvGet, g_strExeExtensions, PathExt ; for example ".COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC"
if StrLen(GetRegistry("HKEY_LOCAL_MACHINE\SOFTWARE\AutoHotkey", InstallDir))
	g_strExeExtensions .= ";.AHK" ; add AutoHotkey scripts extension

;---------------------------------
; Test FileExistInPath

strFilename := "notepad"
if FileExistInPath(strFilename)
	MsgBox, File: %strFilename%
else
	MsgBox, File not found

return
;------------------------------------------------------------



;------------------------------------------------------------
FileExistInPath(ByRef strFile)
;------------------------------------------------------------
{
	strFile := EnvVars(strFile) ; expand environment variables like %APPDATA% or %USERPROFILE%, and user variables like {DropBox}
	
	if (!StrLen(strFile) or InStr(strFile, "://") or SubStr(strFile, 1, 1) = "{") ; this is not a file - caution some URLs in WhereIs cause an infinite loop
		return false
	
	if !InStr(strFile, "\") ; if no path in filename
		strFile := WhereIs(strFile) ; search if file exists in path env variable or registry app paths
	else
		strFile := PathCombine(A_WorkingDir, strFile) ; make relative path absolute
	
	if (SubStr(strFile, 1, 2) = "\\") ; this is an UNC path (option network drives always online enabled)
	; avoid FileExist on the root of a UNC path "\\something" or "\\something\"
	; check if it is the UNC root - if yes, return true without confirming if path exist because FileExist limitation with UNC root path
	{
		intPos := InStr(strFile, "\", false, 3) ; if there is no "\" after the initial "\\" (after the domain or IP address), this is the UNC root
		if !(intPos) ; there is no "\" after the domain or IP address, this is an UNC root (example: "\\something")
			or (SubStr(strFile, intPos) = "\") ; the 3rd \ the last char, this is also an UNC root (example: "\\something\")
			return true
	}
	
	return FileExist(strFile) ; returns the file's attributes if file exists or empty (false) is not
}
;------------------------------------------------------------


;------------------------------------------------------------
EnvVars(str)
; from Lexikos http://www.autohotkey.com/board/topic/40115-func-envvars-replace-environment-variables-in-text/#entry310601
; adapted from Lexikos http://www.autohotkey.com/board/topic/40115-func-envvars-replace-environment-variables-in-text/#entry310601
; in addition to environment variables, it expands QAP user variables like {Dropbox}
;------------------------------------------------------------
{
    if sz:=DllCall("ExpandEnvironmentStrings", "uint", &str, "uint", 0, "uint", 0)
    {
        VarSetCapacity(dst, A_IsUnicode ? sz*2:sz)
        if DllCall("ExpandEnvironmentStrings", "uint", &str, "str", dst, "uint", sz)
            return dst
    }
	
    return str
}
;------------------------------------------------------------


;------------------------------------------------------------
WhereIs(strThisFile)
; based on work from Skan in https://autohotkey.com/board/topic/20807-fileexist-in-path-environment/
;------------------------------------------------------------
{
	if !StrLen(GetFileExtension(strThisFile)) ; if file has no extension
	{
		; re-enter WhereIs with each extension until one returns an existing file
		Loop, Parse, g_strExeExtensions, `; ; for example ".COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC;.AHK"
		{
			strFoundFile := WhereIs(strThisFile . A_LoopField) ; recurse into WhereIs with a complete filename
		} until StrLen(strFoundFile)
		
		return %strFoundFile% ; exit if we find an existing file, or return empty if not
	}
	; from here, we have a filename with an extension
	
	; prepare locations list
	SplitPath, A_AhkPath, , strAhkDir
	EnvGet, strDosPath, Path
	strPaths := A_WorkingDir . ";" . A_ScriptDir . ";" . strAhkDir . ";" . strAhkDir . "\Lib;" . A_MyDocuments . "\AutoHotkey\Lib" . ";" . strDosPath
	
	; search in each location
	Loop, Parse, strPaths, `;
		If StrLen(A_LoopField)
			If FileExist(A_LoopField . "\" . strThisFile)
				Return, RegExReplace(A_LoopField . "\" . strThisFile, "\\\\", "\") ; RegExReplace to prevent results like C:\\Directory
	
	; if not found, check in registry paths for this filename
	RegRead, strAppPath, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%strThisFile%
	If FileExist(strAppPath)
		Return, strAppPath
	
	; else return empty
}
;------------------------------------------------------------


;------------------------------------------------------------
PathCombine(strAbsolutePath, strRelativePath)
; see http://www.autohotkey.com/board/topic/17922-func-relativepath-absolutepath/page-3#entry117355
; and http://stackoverflow.com/questions/29783202/combine-absolute-path-with-a-relative-path-with-ahk/
;------------------------------------------------------------
{
    VarSetCapacity(strCombined, (A_IsUnicode ? 2 : 1) * 260, 1) ; MAX_PATH
    DllCall("Shlwapi.dll\PathCombine", "UInt", &strCombined, "UInt", &strAbsolutePath, "UInt", &strRelativePath)
    Return, strCombined
}
;------------------------------------------------------------


;------------------------------------------------------------
GetFileExtension(strFile)
;------------------------------------------------------------
{
	SplitPath, strFile, , , strExtension
	return strExtension
}
;------------------------------------------------------------


;---------------------------------------------------------
GetRegistry(strKeyName, strValueName)
;---------------------------------------------------------
{
	RegRead, strValue, %strKeyName%, %strValueName%
	
	return strValue
}
;---------------------------------------------------------


