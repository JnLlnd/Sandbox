#NoEnv
#SingleInstance off
#KeyHistory 0
#MaxHotkeysPerInterval 200
ListLines, Off
DetectHiddenWindows, On ; apps default
SendMode, Input
StringCaseSense, Off
FileEncoding ; ANSI with default codepage when empty

global o_CommandLineParameters := new CommandLineParameters()

; OnExit("ExitFunc")

###_V(1, (IsReceiver() ? "Receiver" : "Normal"))

if !IsReceiver()
	run, %A_ScriptFullPath% /Receiver

if IsReceiver()
	SetTimer, ExitReceiver, 5000

if !IsReceiver() and IsPrimaryRunning()
{
	###_V("", "Closing existing Primary")
	WinClose, MyPrimary
}

if !IsReceiver()
	Gui, New, , MyPrimary

###_V(2, (IsReceiver() ? "Receiver" : "Normal"), IsPrimaryRunning())

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

ExitReceiver:
	###_V(A_ThisLabel, (IsReceiver() ? "Receiver" : "Normal"), (IsPrimaryRunning ? "Primary Running" : "Not Running, Closing"))
	if !IsPrimaryRunning()
		ExitApp
return

AltA:
AltB:
###_V(A_ThisLabel, "Hotkey: " . (!IsReceiver() ? "Normal" : "receiver"))
return

AltX:
###_V(A_ThisLabel, "Hotkey: " . (!IsReceiver() ? "Normal" : "receiver"))
ExitApp
return

IsPrimaryRunning()
{
	; Process, Exist, %A_ScriptName%
	; return ErrorLevel
	return WinExist("MyPrimary")
}

IsReceiverRunning()
{
	Process, Exist, %A_ScriptName%
	; return ErrorLevel
	return WinExist("MyPrimary")
}

IsReceiver()
{
	return o_CommandLineParameters.AA.HasKey("Receiver")
}

ExitFunc(ExitReason, ExitCode)
{
	oPile := Object()
	Loop
	{
		Process, Exist, %A_ScriptName%
		if !(ErrorLevel)
			Break
		else
			oPile.Push(ErrorLevel)
	}
	###_O("oPile", oPile)
/*
	Loop
	{
		Process, Exist, %A_ScriptName%
		blnRunning := ErrorLevel
		###_V(A_ThisFunc, A_ScriptName, (blnRunning ? "Closing" : "Not Running"))
		if (blnRunning)
			Process, Close, %A_ScriptName%
		else
			Break
	}
*/
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
