;===============================================
/*
Error #12029 Testing
By Jean Lalonde (jeanlalonde@quickaccesspopup.com)
*/

#NoEnv
#SingleInstance force
ComObjError(False) ; we will do our own error handling

MsgBox, 1, , Your Clipboard will be replaced with the result of HTTP queries.`n`nOK to proceed?
IfMsgBox, Cancel
	ExitApp

Clipboard := "Windows: " . A_OSVersion
		. "`n" . "COM Object: MSXML2.XMLHTTP.6.0"
		. "`n`n--------"
		. "`n`n"

Loop, Parse, % "https://hostupon.ca/|https://www.quickaccesspopup.com/latest/latest-version-4.php|https://cs14.uhcloud.com/|http://cs14.uhcloud.com/|https://cs20.uhcloud.com/|http://cs20.uhcloud.com/", |
	Clipboard .= Url2Var(A_LoopField) . "`n`n"

MsgBox, 0, , Your Clipboard now contains the result of the query.

return


;------------------------------------------------------------
Url2Var(strUrl, blnBreakCache := true,  strReturn := "ResponseText", blnAsync := false)
; WinHttp.WinHttpRequest.5.1 and MSXML2.XMLHTTP.6.0 properties:
; 	.GetAllResponseHeaders()
; 	.ResponseText()
; 	.ResponseBody()
; 	.StatusText()
; 	.Status() ; numeric value 200 is success
; see https://docs.microsoft.com/en-us/windows/win32/winhttp/winhttprequest
; see https://www.autohotkey.com/boards/viewtopic.php?f=76&t=66685
;------------------------------------------------------------
{
	; if (blnBreakCache)
		; strUrl .= (InStr(strUrl, "?") ? "&" : "?") . "cache-breaker=" . A_NowUTC
	
	loop, parse, % "MSXML2.XMLHTTP.6.0|WinHttp.WinHttpRequest.5.1", | ; if MSXML2.XMLHTTP.6.0 don't work, try WinHttp.WinHttpRequest.5.1
; ### test new header
; ### test with 2 protocols
; oHttpRequest.SetRequestHeader("User-Agent","Mozilla/4.0 (compatible; Win32; HTTP.WinHttpRequest.5)") ; ###
	oHttpRequest := ComObjCreate("MSXML2.XMLHTTP.6.0")
	oHttpRequest.Open("GET", strUrl, blnAsync)
	oHttpRequest.SetRequestHeader("Pragma", "no-cache")
	oHttpRequest.SetRequestHeader("Cache-Control", "no-cache, no-store")
	oHttpRequest.SetRequestHeader("If-Modified-Since", "Sat, 1 Jan 2000 00:00:00 GMT")
	oHttpRequest.Send()
	
	strClipboard := "URL: " . strUrl
		. "`n" . "COM Error: " . A_LastError
		. "`n" . "Status: " . oHttpRequest.Status()
		. "`n" . "StatusText: " . oHttpRequest.StatusText()
		. "`n`n" . "RESPONSE HEADERS`n" . oHttpRequest.GetAllResponseHeaders()
		. "`n" . "RESPONSE TEXT (100 first chars)`n" . SubStr(oHttpRequest.ResponseText(), 1, 100) . " ..."
		. "`n`n--------"

	return strClipboard
}
;------------------------------------------------------------


