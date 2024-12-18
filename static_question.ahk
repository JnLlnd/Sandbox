#SingleInstance force

instanceA1 := new A("Bob")
instanceA2 := new A("Joe")
A.strStatic := "out"

MsgBox, % "1) " . instanceA1.name
	. "`n2) " . instanceA1.strStatic
	. "`n3) " . instanceA2.name
	. "`n4) " . instanceA2.strStatic
	. "`n5) " . A.strStatic

return

class A {

	static strStatic := ""

	__New(name) {
		this.name := name
		this.strStatic := name . "!"
	}
}
