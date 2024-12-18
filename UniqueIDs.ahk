#SingleInstance Force

MsgBox, % A_IPAddress1 ; Get_MACAddress_Test()
MsgBox, % A_IPAddress2 ; Get_MACAddress_Test()
MsgBox, % A_IPAddress3 ; Get_MACAddress_Test()
MsgBox, % A_IPAddress4 ; Get_MACAddress_Test()
return

str := "`nProcessorId`t" . Get_ProcessorId()
str .= "`nSerialNumber`t" . Get_MotherboardSerialNumber()
str .= "`nMACAddress`t" . Get_MACAddress()

MsgBox, 4, , %str%`n`nCopy this to your Clipboard?

IfMsgBox, No
	return

Clipboard := str

ExitApp


;---------------------------------------------------------
Get_MACAddress_Test()
; source: https://www.autohotkey.com/boards/viewtopic.php?style=1&t=24346
; example: 30:85:A9:8E:F9:E2
;---------------------------------------------------------
{
	objCom := ComObjGet("winmgmts:{impersonationLevel = impersonate}!\\.\root\cimv2")
	colItems := objCom.ExecQuery("Select * from Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")._NewEnum
	str := "MAC Addresses"
	while colItems[objItem]
	{
		; if objItem.IPAddress[0] = A_IPAddress1
		str .= "`n" . objItem.MACAddress
	}
	return str
}
;---------------------------------------------------------


;---------------------------------------------------------
Get_ProcessorId()
; info: https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-processor
;---------------------------------------------------------
{
	strComputer := "."
	objWMIService := ComObjGet("winmgmts:\\" . strComputer . "\root\cimv2")
	WQLQuery := "Select * From Win32_Processor"
	colCPU := objWMIService.ExecQuery(WQLQuery)._NewEnum
	while colCPU[objCPU]
		return objCPU.ProcessorId
}
;---------------------------------------------------------


;---------------------------------------------------------
Get_MotherboardSerialNumber()
; source: https://www.autohotkey.com/boards/viewtopic.php?style=1&t=24346
; example: 120700577302842
;---------------------------------------------------------
{
	While (ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2")
		.ExecQuery("Select * From Win32_BaseBoard")._NewEnum)[objMBInfo]
		return objMBInfo["SerialNumber"]
}
;---------------------------------------------------------


;---------------------------------------------------------
Get_MACAddress()
; source: https://www.autohotkey.com/boards/viewtopic.php?style=1&t=24346
; example: 30:85:A9:8E:F9:E2
;---------------------------------------------------------
{
	colItems := ComObjGet("winmgmts:{impersonationLevel = impersonate}!\\.\root\cimv2")
		.ExecQuery("Select * from Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")._NewEnum
	while colItems[objItem]
		if objItem.IPAddress[0] = A_IPAddress1
			return objItem.MACAddress
}
;---------------------------------------------------------

