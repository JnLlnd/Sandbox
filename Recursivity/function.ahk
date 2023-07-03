;
; Simple function
;

#SingleInstance force

str := "Hi!"
strResult := Obfuscate(str)

MsgBox, %str%`n%strResult% ; str has not been changed by the function

return


;------------------------------------------------
Obfuscate(str)
; str and intLength are local variables
;------------------------------------------------
{
	intLength := StrLen(str)
	str := ""
	Loop, %intLength%
		str .= "X"
	
	return str
}
;------------------------------------------------
