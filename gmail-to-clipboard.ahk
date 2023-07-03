#SingleInstance force

!q::
; ###_V("Convertir", Clipboard)
SoundBeep
Send, ^a^c
strDebut := "Ce courriel confirme que vous avez reçu un don de"
strDe := " de "
strParenthese1 := " ("
strParenthese2 := ")"
strWindowTitle := "! donors-betatesters.xlsm - Excel"
strExcelFile := "E:\Dropbox\AutoHotkey\! donors-betatesters.xlsm"
strMessage := "Message"

s := Clipboard
s := Trim(SubStr(s, InStr(s, strDebut) + StrLen(strDebut)))
if !StrLen(s)
{
	MsgBox, Clipboard vide
	return
}
	
strMontant := Trim(SubStr(s, 1, InStr(s, strDe)))
strDevise := Trim(SubStr(strMontant, InStr(strMontant, " ")))
strMontant := Trim(SubStr(strMontant, 1, InStr(s, " ")))
s := Trim(SubStr(s, InStr(s, strDe) + StrLen(strDe)))
strNom := Trim(SubStr(s, 1, InStr(s, strParenthese1)))
strNom := StrReplace(strNom, "la part de ", "")
s := Trim(SubStr(s, InStr(s, strParenthese1) + StrLen(strParenthese1)))
strCourriel := Trim(SubStr(s, 1, InStr(s, strParenthese2) - StrLen(strParenthese2)))
if InStr(s, strMessage)
{
	strMessage := Trim(SubStr(s, InStr(s, strMessage) + StrLen(strMessage) + 3))
	if InStr(strMessage, "`n")
		strMessage := Trim(SubStr(strMessage, 1, InStr(strMessage, "`n") - 2))
}
else
	strMessage := ""
###_V(strMontant, strDevise, strNom, strCourriel, strMessage)

return
