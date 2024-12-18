﻿#Include %A_ScriptDir%\QueryString_Builder.ahk
#Include %A_ScriptDir%\JSON.ahk
;**************************************
;~ https://docs.easydigitaldownloads.com/article/1423-free-downloads-advanced-usage
;~ https://docs.easydigitaldownloads.com/article/1138-edd-rest-api---customers
;~ https://docs.easydigitaldownloads.com/article/1131-edd-rest-api-introduction ;  The secret key is used for internal authentication and should never be used directly to access the API.
; https://docs.easydigitaldownloads.com/article/1151-recurring-payments---rest-api-endpoint

;~ go to: Downloads->Tools->API Keys
strPublic_Key:="7e75fa5347558d46cb0f76718417190b"
strToken:="26b47345369dec44d6d8d5a006f113c1"

; Endpoint:="https://shop.quickaccesspopup.com/mn/edd-api/customers/"
strEndpoint:="https://shop.quickaccesspopup.com/mn/edd-api/subscriptions/"
strQuery:=QueryString_Builder({"key": strPublic_Key,"number":"500","token":strToken,"page":"-1"})
strData:=API_Call(strEndpoint,strQuery)
FileAppend, %strData%, %A_ScriptDir%\EDD_Subscriptions.csv
Run, %A_ScriptDir%\EDD_Subscriptions.csv

return
;******************************
API_Call(strEndpoint, strQuery)
{
	oHTTP := ComObjCreate("WinHttp.WinHttpRequest.5.1") ;Create COM Object
	oHTTP.Open("GET",strEndpoint . strQuery) ;GET & POST are most frequent, Make sure you UPPERCASE
	oHTTP.Send() ;If POST request put data in "Payload" variable
	;***********Response fields*******************
	; MsgBox %   Status_Text:=HTTP.StatusText
	ToolTip, % HTTP.StatusText
	oJSON:=JSON.parse(oHTTP.ResponseText) ;Make sure the ParseJSON function is in your library
	; ###_O("oAHK", oAHK)
	; for a,b in oAHK.customers
	for strKey, oItem in oJSON.subscriptions
	{
		ToolTip, % strKey . ": " . oItem.info.customer.name
		; ###_O("strKey oItem.info", oItem.info)
		str .= strKey
			. "`t" . oItem.info.gateway
			. "`t" . oItem.info.recurring_amount
			. "`t" . oItem.info.period
			. "`t" . oItem.info.expiration
			. "`t" . oItem.info.status
			. "`t" . oItem.info.customer.email
			. "`t" . oItem.info.customer.name
			. "`n"
		; ###_V("str", str)
			
	}
	ToolTip
	; MsgBox % HTTP.ResponseText
	return str
}
