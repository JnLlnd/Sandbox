#SingleInstance,Force

; Run, Explorer.exe, , , intPID
Run, Notepad.exe, , , intPID
; Run, E:\Program Files (x86)\Microsoft Office\Office16\WINWORD.EXE, , , intPID

; WinGet, OutputVar, List , ahk_pid %intPID%
; MsgBox, %OutputVar%
; return

sleep, 500
strPID := "ahk_pid " . intPID
strHID := "ahk_id " . WinExist("Explorateur")
MsgBox, PID: %strPID% / HID: %strHID% 

; return

sleep, 500
; WinRestore, Explorateur
; WinRestore, Notepad
; WinRestore, ahk_exe WINWORD.EXE
WinRestore, %strPID%

sleep, 500
; WinMove, Explorateur, , 100, 100
; WinMove, Notepad, , 100, 100
; WinMove, ahk_exe WINWORD.EXE, , 100, 100
WinMove, %strPID%, , 100, 100
