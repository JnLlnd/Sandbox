#SingleInstance force

instanceA := new A("Bob")
instanceB := new B("Joe")

MsgBox, % "1) " . instanceA.name
	. "`n2) " . instanceA.NameUpper()
	. "`n3) " . instanceB .name
	. "`n4) " . instanceB .NameUpper()

return

class A {
	__New(name) {
		this.name := name
		###_V("This.base.__Class", This.base.__Class)
	}
	
	NameUpper() {
		StringUpper, upperName, % this.name
		return upperName
	}
}

class B {
	__New(name) {
		; singleton design pattern for a single use class
		; (from nnik https://www.autohotkey.com/boards/viewtopic.php?f=74&t=38151#p175344)
		static init ;t his is where the instance will be stored
		if init ; this will return true if the class has already been created
			return init ; and it will return this instance rather than creating a new one
		init := This ; this will overwrite the init var with this instance

		this.name := name
	}
	
	NameUpper() {
		StringUpper, upperName, % this.name
		return upperName
	}
}