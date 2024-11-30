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

###_V("Launch", (!IsReceiver() ? "Normal" : "receiver"), A_ScriptFullPath)
if InStr(A_ScriptName, ".exe") and !IsReceiver()
	Run, % """" . StrReplace(A_ScriptFullPath, ".exe", "receiver.exe") . """"

Hotkey, If, IsReceiver()
	; Set Global hotkeys
	Hotkey, !a, AltA, On UseErrorLevel
	Hotkey, !x, AltX, On UseErrorLevel
Hotkey, If

Hotkey, If, !IsReceiver()
	; Set Local hotkeys
	Hotkey, !b, AltB, On UseErrorLevel
	Hotkey, !x, AltX, On UseErrorLevel
Hotkey, If

return

AltA:
AltB:
###_V(A_ThisLabel, "Hotkey: " . (!IsReceiver() ? "Normal" : "receiver"))
return

AltX:
###_V(A_ThisLabel, "Hotkey: " . (!IsReceiver() ? "Normal" : "receiver"))
ExitApp
return

IsReceiver()
{
	return InStr(A_ScriptName, "receiver.exe")
}

ExitFunc(ExitReason, ExitCode)
{
	Process, Close, % StrReplace(A_ScriptName, ".exe", "background.exe")
}

;------------------------------------------------------------
;------------------------------------------------------------
#If, IsReceiver()
#If
#If, !IsReceiver()
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


;------------------------------------------------------------
RECEIVER(wParam, lParam) 
; Adapted from AHK documentation (https://autohotkey.com/docs/commands/OnMessage.htm)
; Commands: ShowMenuLaunch, ShowMenuNavigate, ShowMenuAlternative, ShowMenuDynamic, LaunchFavorite, AddFolder, AddFolderXpress, AddFile and AddFileXpress
;------------------------------------------------------------
{
	intStringAddress := NumGet(lParam + 2*A_PtrSize) ; Retrieves the CopyDataStruct's lpData member.
	strCopyOfData := StrGet(intStringAddress) ; Copy the string out of the structure.
	
	saData := StrSplit(strCopyOfData, "|")
	
	if InStr(saData[1], "AddFolder") and (SubStr(saData[2], -1, 2) = ":""") ; -1 extracts the 2 last characters
		; exception for drive paths
		saData[2] := SubStr(saData[2], 1, StrLen(saData[2]) - 1) . "\"

	if (saData[1] = "Exec")
	{
		g_strExecTitle := saData[2]
		###_V(saData[1], saData[2])
	}
	else
		return 0

	return 1
}
;------------------------------------------------------------
