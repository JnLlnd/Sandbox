#Requires AutoHotkey v1.1
#NoEnv
#SingleInstance force

Global strEnv := A_AhkVersion . " | " . A_OSVersion . " | " . A_Is64bitOS . " | " . A_Language
Global strLog := "Test_Name | Test_Result | A_AhkVersion | A_OSVersion | A_Is64bitOS | A_Language`r`n"
StringReplace, strLogFile, A_ScriptName, .ahk
strLogFile := A_Temp . "\" . strLogFile . ".log"

; --- INTRO

Info("The script will open ""Windows Explorer"".")
run, Explorer
Info("The script will now perform the same task (changing folders in Explorer) using five different methods.")

; --- METHOD 1 (WinXP ControlSend Method)

if (A_OSVersion = "WIN_XP")
{
	strFolder := "C:\Windows"
	Info("Method 1)`nIn the next step, the folder in Explorer should change to your """ . strFolder . """ folder.")
	if not ControlEdit1Exist()
	{
		PostMessage, 0x111, 41477, 0, , A ; Show Address Bar
		while not ControlEdit1Exist()
			Sleep 0
		PostMessage, 0x111, 41477, 0, , A ; Hide Address Bar
	}
	ControlFocus, Edit1, A
	ControlSetText, Edit1, %strFolder%, A
	ControlSend, Edit1, {Enter}, A
	CheckResult("1) Explorer_CtrlSendXP", "Is your Explorer folder changed to """ . strFolder . """?")
}
else
	Info("Method 1)`nThis method is reserved for Windows XP users. This test is skipped because you are running on Windows v" . A_OSVersion . ".")

; --- METHOD 2 (F4 Method)

SplitPath, A_AhkPath, , strFolder
Info("Method 2)`nIn the next step, the folder in Explorer should change to your """ . strFolder . """ folder.")
Send, {F4}{Esc}
Sleep, 500 ; long delay for safety
Send, %strFolder%{Enter}
CheckResult("2) Explorer_F4Esc", "Is your Explorer folder changed to """ . strFolder . """?")

; --- METHOD 3 (ControlSend Method)

strFolder := A_ScriptDir
Info("Method 3`nIn this step, the folder in Explorer should change to your """ . strFolder . """ folder.")
ControlSetText, Edit1, %strFolder%, A
ControlSend, Edit1, {Enter}, A
CheckResult("3) Explorer_CtrlSend", "Is your Explorer folder changed to """ . strFolder . """?")

; --- METHOD 4 (Explorer_Shell Method)

; ControlSend Method
strFolder := "C:\Windows"
Info("Method 4)`nIn this step, the folder in Explorer should change to your """ . strFolder . """ folder.")
Explorer_Navigate(strFolder)
CheckResult("4) Explorer_Shell", "Is your Explorer folder changed to """ . strFolder . """?")

; --- METHOD 5 (Explorer_Shell_Tab Method for Windows 11 with Explorer with Tabs)

strFolder := A_ProgramFiles
Info("Method 5`nIf you run Explorer with tabs (Windows 11 version 22H2 build 22621.675 or more recent), make sure there are more than one tab in Explorer and that the active tab is NOT """ . strFolder . """.`n`nAfter you press OK, this tab should change to your """ . strFolder . """ folder.")
Explorer_Navigate_Tab(strFolder)
CheckResult("5) Explorer_Shell_Tab", "Is the active tab of Explorer changed to """ . strFolder . """?")

Send, !{F4} ; close Explorer

; --- METHOD DIALOG BOX

Info("One last test? We will test if changing folder in Dialog box works well on your system.`n`nThe script will run Notepad and open the ""Open"" dialog box.")
run, Notepad, , , strPID
WinWaitActive, ahk_class Notepad
Sleep, 500 ; delay for safety
Send, ^o
strFolder := "C:\"
Info("In the next step, the file list in the dialog box should change to your """ . strFolder . """ folder.")
ControlFocus, Edit1, A
ControlGetText, strOldText, Edit1, A
ControlSetText, Edit1, %strFolder%, A
ControlSend, Edit1, {Enter}, A
ControlSetText, Edit1, %strOldText%, A
CheckResult("Notepad_ControlSend", "Is your file list now showing your """ . strFolder . """ folder?")
Info("Thank you. The script will now close Notepad.")
Send, !{F4}
Sleep, 500 ; long delay for safety
WinActivate, ahk_pid %strPID%
Sleep, 500 ; long delay for safety
Send, !{F4}

FileDelete, %strLogFile%
FileAppend, %strLog%, %strLogFile%
Info("Log saved to """ . strLogFile . """. This file will now be opened in Notepad and DELETED from your A_Temp folder.`n`nPlease post the content of this file to the forum thread. Thank you for your help!")
run, Notepad %strLogFile%, , , strPID
WinActivate, ahk_pid %strPID%
sleep, 1000
FileDelete, %strLogFile%
return

; ------------------

ControlEdit1Exist()
{
	ControlGet, strOut, Enabled,, Edit1, A
	return not ErrorLevel
}

Info(str)
{
	MsgBox, 4096, Diag, %str%`n`nPress OK to continue.
	IfMsgBox, Cancel
		ExitApp
}
	
CheckResult(strTestName, strQuestion)
{
	MsgBox, 4099, Diag, %strQuestion%
	IfMsgBox, Cancel
		ExitApp
	IfMsgBox, Yes
		strResult := 1
	IfMsgBox, No
		strResult := 0
	Log(strTestName, strResult)
}

Log(strTestName, strResult)
{
	strLog := strLog . strTestName . " | " . strResult . " | " . strEnv . "`r`n"
}

Explorer_Navigate(FullPath, hwnd="") {  ; by Learning one
    hwnd := (hwnd="") ? WinExist("A") : hwnd ; if omitted, use active window
    WinGet, ProcessName, ProcessName, % "ahk_id " hwnd
    if (ProcessName != "explorer.exe")  ; not Windows explorer
        return
    For pExp in ComObjCreate("Shell.Application").Windows
    {
        if (pExp.hwnd = hwnd) { ; matching window found
            pExp.Navigate("file:///" FullPath)
            return
        }
    }
}

Explorer_Navigate_Tab(FullPath, hwnd="") {
; originally from Learning one (https://www.autohotkey.com/boards/viewtopic.php?p=4480#p4480)
; adapted by JnLlnd for tabbed browsing new to Windows 11 version 22H2 (build 22621.675)
; with code from ntepa (https://www.autohotkey.com/boards/viewtopic.php?p=488735#p488735)
; also works with previous versions of Windows Explorer
    hwnd := (hwnd="") ? WinExist("A") : hwnd ; if omitted, use active window
    WinGet, ProcessName, ProcessName, % "ahk_id " hwnd
    if (ProcessName != "explorer.exe")  ; not Windows explorer
        return
    For pExp in ComObjCreate("Shell.Application").Windows
    {
        if (pExp.hwnd = hwnd) { ; matching window found
			; from 
			activeTab := 0
			try ControlGet, activeTab, Hwnd,, % "ShellTabWindowClass1", % "ahk_id" hwnd
			if activeTab {
				static IID_IShellBrowser := "{000214E2-0000-0000-C000-000000000046}"
				shellBrowser := ComObjQuery(pExp, IID_IShellBrowser, IID_IShellBrowser)
				DllCall(NumGet(numGet(shellBrowser+0)+3*A_PtrSize), "Ptr", shellBrowser, "UInt*", thisTab)
				if (thisTab != activeTab) ; matching active tab
					continue
				ObjRelease(shellBrowser)
			}
			pExp.Navigate("file:///" FullPath)
			return
		}
    }
}
