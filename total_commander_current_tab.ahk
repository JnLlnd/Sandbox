	SendMessage, 1074, 17, , , ahk_class TTOTAL_CMD ; WM_USER+50 = 1074, control 17=bottompanel
	strControlHandle1 := ErrorLevel
	WinGetText, strPathInTC, ahk_id %strControlHandle1% ; Get the current path in bottom panel
	strPathInTC := SubStr(strPathInTC, 1, -3) ; Cut off the trailing > and newline signs
	
	SendMessage, 1074, 15, , , ahk_class TTOTAL_CMD ; WM_USER+50 = 1074, control 26=lefttabs
	strControlHandle2 := ErrorLevel
	WinGetText, strLeftTabs, ahk_id %strControlHandle2% ; Get the current path in bottom panel

	SendMessage, 1074, 16, , , ahk_class TTOTAL_CMD ; WM_USER+50 = 1074, control 27=righttabs
	strControlHandle3 := ErrorLevel
	WinGetText, strRightTabs, ahk_id %strControlHandle3% ; Get the current path in bottom panel

	###_V("", strControlHandle1, strPathInTC, strControlHandle2, strLeftTabs, strControlHandle3, strRightTabs)

Return