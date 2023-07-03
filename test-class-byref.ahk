#SingleInstance force

oneThing := new Thing("Bob", 33)

MsgBox, % oneThing.name

TestByRef(foo)
MsgBox, %foo%

TestByRef(oneThing.name)
MsgBox, % oneThing.name

return

TestByRef(ByRef str)
{
	str := "!!!"
}

class Thing
{
	; age := ""
	
	__New(newname, newage)
	{
		this.name := newname
		this.age := newage
	}
	
}
