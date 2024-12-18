class MyZooClass
{
	MyKey := "MyKeyValue"

	static MyStaticKey := "MyStaticKeyValue"

	MyMethod()
	{
		return "MyMethodValue"
	}

	MyProperty
	{
		get
		{
			return "MyPropertyValue"
		}
		set
		{
		}
	}

	__New()
	{
	}
	__Get()
	{
	}
	__Set()
	{
	}
	__Call()
	{
	}
	__Delete()
	{
	}
}

obj := new MyZooClass

vOutput := ""

vOutput .= "instance object:`r`n"
for vKey, vValue in obj
	vOutput .= vKey " " vValue "`r`n"
vOutput .= "`r`n"

vOutput .= "instance object base:`r`n"
for vKey, vValue in obj.base
	vOutput .= vKey " " vValue "`r`n"
vOutput .= "`r`n"

vOutput .= "class object:`r`n"
for vKey, vValue in MyZooClass
	vOutput .= vKey " " vValue "`r`n"
vOutput .= "`r`n"

vOutput .= "class object base:`r`n"
for vKey, vValue in MyZooClass.base
	vOutput .= vKey " " vValue "`r`n"
vOutput .= "`r`n"

Clipboard := vOutput
MsgBox, % vOutput

MsgBox, % IsObject(obj) " " IsObject(obj.base)
MsgBox, % IsObject(MyZooClass) " " IsObject(MyZooClass.base)

;some additional tests to retrieve types (Type is AHK v2-only)

MsgBox, % Type(MyZooClass.MyKey)) ;String
MsgBox(Type(MyZooClass.MyProperty)) ;String
MsgBox(Type(MyZooClass.MyMethod)) ;Func

oKey := ObjRawGet(MyZooClass, "MyKey")
oProp := ObjRawGet(MyZooClass, "MyProperty")
oMeth := ObjRawGet(MyZooClass, "MyMethod")
MsgBox(Type(oKey)) ;String
MsgBox(Type(oProp)) ;Property
MsgBox(Type(oMeth)) ;Func
