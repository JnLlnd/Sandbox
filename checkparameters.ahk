#SingleInstance force
; repo test2

OneClass := new MyClass()

result := OneClass.MyFunction("1", "2", "3") ; too many parameters
result := OneClass.MyFunction("1") ; too few parameters
result := OneClass.MyFunction("1", "2") ; no error message
result := OneClass.MyFunction() ; too few parameters
result := OneClass.NotAFunction() ; does not exist

ExitApp

class MyClass
{
	__New() ; missing parameter would not be detected
	{
	}
	
	MyFunction(one, two)
	{
		MsgBox, %A_ThisFunc% called with parameters: %one%, %two%
	}
	
	;-- Insert in each class ---------------------------------
	__Call(function, parameters*)
	; based on code from LinearSpoon https://www.autohotkey.com/boards/viewtopic.php?t=1435#p9133
	{
		funcRef := Func(funcName := this.__class "." function)
		if CheckParameters(funcRef, function, parameters*) ; if everything is good call the function, else return false
			return funcRef.(this, parameters*) ; everything is good
		else
			return
	}
	;-- Insert in each class ---------------------------------
}

CheckParameters(funcRef, funcName, parameters*)
; based on code from LinearSpoon https://www.autohotkey.com/boards/viewtopic.php?t=1435#p9133
{
	if !IsObject(funcRef) ; check if function exists
		return CheckParametersMsg(funcName, "")
	
	maxIndexFixed := (parameters.MaxIndex() = "" ? 0 : parameters.MaxIndex()) ; if no parameter, MaxIndex() returns "" instead of 0
	
	if (maxIndexFixed < funcRef.MinParams-1) ; check if there are enough parameters
		return CheckParametersMsg(funcRef.Name, "few", parameters[1], maxIndexFixed, funcRef.MinParams-1, funcRef.MaxParams-1)
	
	if (maxIndexFixed > funcRef.MaxParams-1 && !funcRef.IsVariadic) ; check that there aren't too many parameters
		return CheckParametersMsg(funcRef.Name, "many", parameters[1], maxIndexFixed, funcRef.MinParams-1, funcRef.MaxParams-1)
	
	return true
}

CheckParametersMsg(funcName, fewOrMany, firstParam := "", nbPassed := "", minExpected := "", maxExpected := "")
; based on code from LinearSpoon https://www.autohotkey.com/boards/viewtopic.php?t=1435#p9133
{
	if StrLen(fewOrMany)
		Msgbox, 4, Error, % "Function: " . funcName
			. "`nError: too " . fewOrMany . " parameters"
			. (StrLen(firstParam) ? "`nFirst parameter: " . firstParam : "")
			. "`n`nNumber Passed: " . nbPassed
			. "`nExpected Min: " . minExpected
			. "`nExpected Max: " . maxExpected
			. "`n`nContinue?"
	else
		Msgbox, 4, Error, % "Function: " . funcName
			. "`nError: function does not exist"
			. "`n`nContinue?"
	
	IfMsgBox Yes
		return false
	else
		ExitApp
}