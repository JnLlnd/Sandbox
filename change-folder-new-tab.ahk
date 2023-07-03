#Requires AutoHotkey v1.1
#NoEnv
#SingleInstance force

return

^1::
    Explorer_Navigate_New_Tab("C:\Windows", WinExist("ahk_class CabinetWClass"))
Return

Explorer_Navigate_New_Tab(FullPath, hwnd="") {

    WinGet, ProcessName, ProcessName, % "ahk_id " hwnd
    if (ProcessName != "explorer.exe")  ; not Windows explorer
        return
	
	ControlSend, Windows.UI.Input.InputSite.WindowClass1, ^t, ahk_id %hwnd% ; add a new tab
	; Note 1: This ^t hotkey works in English and French, don't know for other localizations
	; Note 2: AFAIK, this hotkey does nothing in earlier versions of Windows Explorer but
	; it would be safer to check the version before sending it
	Sleep, 100 ; for safety
	
	; the new tab is the active tab
    Explorer_Navigate_Tab(FullPath, hwnd)
}

Explorer_Navigate_Tab(FullPath, hwnd="") {
; see https://www.autohotkey.com/boards/viewtopic.php?p=489575#p489575
    hwnd := (hwnd="") ? WinExist("A") : hwnd ; if omitted, use active window
    WinGet, ProcessName, ProcessName, % "ahk_id " hwnd
    if (ProcessName != "explorer.exe")  ; not Windows explorer
        return
    For pExp in ComObjCreate("Shell.Application").Windows
    {
        if (pExp.hwnd = hwnd) { ; matching window found
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
