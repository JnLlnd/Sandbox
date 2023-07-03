
FileRead, str, %A_ScriptDir%\mytext.txt
MsgBox, %str%

loop, parse, str, `n
	MsgBox, %A_LoopField%
