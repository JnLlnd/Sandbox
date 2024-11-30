#NoEnv
#SingleInstance force
#KeyHistory 0
#MaxHotkeysPerInterval 200
ListLines, Off
DetectHiddenWindows, On ; apps default
SendMode, Input
StringCaseSense, Off
FileEncoding ; ANSI with default codepage when empty

/*
global o_CommandLineParameters := new CommandLineParameters()
MsgBox, % "Launch: " . (o_CommandLineParameters.AA.HasKey("Background") ? "Background" : "Normal")
if !o_CommandLineParameters.AA.HasKey("Background")
	Run, %A_ScriptFullPath% /background
return
!a::
MsgBox, % "Hotkey: " . (o_CommandLineParameters.AA.HasKey("Background") ? "Background" : "Normal")
return
!x::
ExitApp
*/

OnExit("ExitFunc")

###_V("Launch", (NotBackground() ? "Normal" : "Background"), A_ScriptFullPath)
if InStr(A_ScriptName, ".exe") and NotBackground()
	Run, % """" . StrReplace(A_ScriptFullPath, ".exe", "background.exe") . """"

Hotkey, If, NotBackground()
	Hotkey, !a, AltA, On UseErrorLevel
	Hotkey, !x, AltX, On UseErrorLevel
Hotkey, If

return

AltA:
###_V(A_ThisLabel, "Hotkey: " . (NotBackground() ? "Normal" : "Background"))
return

AltX:
###_V(A_ThisLabel, "Hotkey: " . (NotBackground() ? "Normal" : "Background"))
ExitApp
return

NotBackground()
{
	return !InStr(A_ScriptName, "background.exe")
}

ExitFunc(ExitReason, ExitCode)
{
	Process, Close, % StrReplace(A_ScriptName, ".exe", "background.exe")
}

;------------------------------------------------------------
;------------------------------------------------------------
#If, NotBackground()
#If
;------------------------------------------------------------
;------------------------------------------------------------


;-------------------------------------------------------------
class CommandLineParameters
;-------------------------------------------------------------
/*
class CommandLineParameters
	Methods
	- CommandLineParameters.__New(): collect the command line parameters in an internal object and concat strParams
	  - each param must begin with "/" and be separated by a space
	  - supported parameters: "/Settings:[file_path]" (must end with ".ini"), "/AdminSilent" and "/Working:[working_dir_path]"
	- CommandLineParameters.ConcatParams(I): returns a concatenated string of each parameter ready to be used when reloading
	- CommandLineParameters.SetParam(strKey, strValue): set the param strkey to the value strValue
	Instance variables
	- AA: simple array for each item (parameter) from the A_Args object (for internal usage)
	- strParams: list of command line parameters collected when launching this instance, separated by space, with quotes if required
*/
;-------------------------------------------------------------
{
	; Instance variables
	AA := Object() ; associative array
	strParams := ""
	
	;---------------------------------------------------------
	__New()
	;---------------------------------------------------------
	{
		for intArg, strOneArg in A_Args ; A_Args requires v1.1.27+
		{
			if !StrLen(strOneArg)
				continue
			
			intColon := InStr(strOneArg, ":")
			if (intColon)
			{
				strParamKey := SubStr(strOneArg, 2, intColon - 2) ; excluding the starting slash and ending colon
				strParamValue := SubStr(strOneArg, intColon + 1)
				this.AA[strParamKey] := strParamValue
			}
			else
			{
				strParamKey := SubStr(strOneArg, 2)
				if (strParamKey = "Settings")
					continue
				this.AA[strParamKey] := "" ; keep it empty, check param with this.AA.HasKey(strOneArg)
			}
		}
		
		this.strParams := this.ConcatParams()
	}
	;---------------------------------------------------------
	
	;---------------------------------------------------------
	ConcatParams()
	;---------------------------------------------------------
	{
		strConcat := ""
		
		for strParamKey, strParamValue in this.AA
		{
			strQuotes := (InStr(strParamKey . strParamValue, " ") ? """" : "") ; enclose param with double-quotes only if it includes space
			strConcat .= strQuotes . "/" . strParamKey
			strConcat .= (StrLen(strParamValue) ? ":" . strParamValue : "") ; if value, separate with :
			strConcat .= strQuotes . " " ; ending quote and separate with next params with space
		}
		
		return SubStr(strConcat, 1, -1) ; remove last space
	}
	;---------------------------------------------------------
	
	;---------------------------------------------------------
	SetParam(strKey, strValue)
	;---------------------------------------------------------
	{
		this.AA[strKey] := strValue
		this.strParams := this.ConcatParams()
	}
	;---------------------------------------------------------
}
;-------------------------------------------------------------


