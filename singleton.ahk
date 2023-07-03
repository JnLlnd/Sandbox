#SingleInstance force

class superGlobalAutoSingleton
{
	__New()
	{
		;These 5 lines are the important part
		static init := new superGlobalAutoSingleton()
		if init
			return init
		classPath := StrSplit( This.base.__Class, "." )
		className := classPath.removeAt(1)
		; ###_V(A_ThisFunc, This.base.__Class, className, classPath.Length())
		if ( classPath.Length() > 0 )
			%className%[classPath*] := This
		else
			%className% := This
		
		;...add the rest of the constructor here
		This.text := "Abc"
		This.text2 := "def"
		This.name := className . " Instance"
	}
	
	getText()
	{
		return This.text . This.text2
	}
	
	__Delete()
	{
		Msgbox % "deleting " . This.name ;To show that __delete still works
	}
	
}
; Msgbox % superGlobalAutoSingleton.getText()
Msgbox % superGlobalAutoSingleton.toto