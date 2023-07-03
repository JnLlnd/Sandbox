#Requires AutoHotkey v1.1
#NoEnv
#SingleInstance force

return

^1::
    Explorer_Navigate_Tab("C:\Windows")
Return

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
