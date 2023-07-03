#SingleInstance force

oneThing := new Thing("Bob", 33)
oneThing.age := 34
otherThing := new Thing("Joe", 55)
###_V("", oneThing.name, oneThing.age, otherThing.name, otherThing.age)
###_O("oneThing", oneThing)
###_O("otherThing", otherThing)
; oneThing.name := "Joe"
; ###_O("oneThing", oneThing)
; MsgBox, % oneThing.Action()

; MsgBox, % new Thing("Bob").ConvertUpper()

; loop, 1000
; {
	; str := new Thing("Bob").ConvertUpper()
	; ToolTip, %A_Index%
; }

return

class Thing
{
	; age := ""
	
	__New(newname, newage)
	{
		this.name := newname
		this.name := this.ConvertUpper()
		this.age := newage
	}
	
	ConvertUpper()
	{
		StringUpper, upperName, % this.name

		return upperName . "!"
	}

	ConvertLower()
	{
		StringLower, upperName, % this.name

		return upperName . "!"
	}
	
	age[]
	{
		get
		{
			soundbeep, 800
			return this._age
		}
		set
		{
			soundbeep, 400
			###_V("value", value)
			return this._age := value
		}
	}
}

