#SingleInstance,Force

global blnSkip := false

aaAlbums := Object()
aaAlbumsByYear := Object()

; strFileInput := A_ScriptDir . "\TheBeatles-alpha.csv"
strFileInput := A_ScriptDir . "\TheBeatles-alpha.csv"
Loop, Read, %strFileInput%
{
	; line structure:
	; 1 Name ->  2 Album ->  3 Track ->  4 Duration ->  5 Year
	saSong := StrSplit(A_LoopReadLine, A_Tab)

	if !aaAlbums.HasKey(saSong[2]) ; if not part of the index
	{
		oAlbum := new Album(saSong[2], saSong[5])
		; oAlbum.ShowMe()
		aaAlbums[saSong[2]] := oAlbum
		aaAlbumsByYear[saSong[5] . "-" . saSong[2]] := oAlbum ; concatenate year and album name in case we ave 2 albums the same year
	}
	else
		oAlbum := aaAlbums[saSong[2]]
	
	oSong := new Album.Song(saSong[1], saSong[3], saSong[4])
	oAlbum.AddSong(oSong)
	; oSong.ShowMe()
	; oAlbum.ShowMe()
}
; ###_O("aaAlbums", aaAlbums)
MsgBox, % aaAlbums["Abbey Road"].saSongs[3].strTitle

; Looping the collection by year
strCollection := ""
for strYearKey, oOneAlbum in aaAlbumsByYear
{
	; oOneAlbum.ShowMe()
	strCollection .= "`n" . oOneAlbum.GetString() . "`n---`n"
	for intTrack, oOneSong in oOneAlbum.saSongs
		strCollection .= oOneSong.GetString() . "`n"
}

MsgBox, 4, , Copy the collection to the Clipboard?
IfMsgBox, Yes
	Clipboard := strCollection

ExitApp


;-------------------------------------------------------------
class Album
;-------------------------------------------------------------
{
	; Instance variables
		; Instance variables are declared like normal assignments, but the this. prefix is omitted (only directly within the class body).
		; To access an instance variable (even within a method), always specify the target object; for example, this.InstanceVar
		
	; Static/Class Variables
		; Static/class variables belong to the class itself, but can be inherited by derived objects (including sub-classes).
		; They are declared like instance variables, but using the static keyword. Static declarations are evaluated only once, before the auto-execute section, in the order they appear in the script.
		; Each declaration stores a value in the class object. Any variable references in Expression are assumed to be global.
		; To assign to a class variable, always specify the class object; for example, ClassName.ClassVar := Value.
		; If an object x is derived from ClassName and x itself does not contain the key "ClassVar", x.ClassVar may also be used to dynamically retrieve the value of ClassName.ClassVar.
		
	;---------------------------------------------------------
	__New(strTitle, intYear)
	;---------------------------------------------------------
	{
		this.strTitle := strTitle
		this.intYear := intYear
		this.saSongs := Object()
	}
	;---------------------------------------------------------
	
	;---------------------------------------------------------
	AddSong(oSong)
	; Each method has a hidden parameter named this, which typically contains a reference to an object derived from the class.
	; Inside a method, the pseudo-keyword base can be used to access the super-class versions of methods or properties which are overridden in a derived class.
	;---------------------------------------------------------
	{
		this.saSongs[oSong.intTrack] := oSong
		oSong.oAlbum := this
	}
	;---------------------------------------------------------
	
	;---------------------------------------------------------
	GetString()
	; Each method has a hidden parameter named this, which typically contains a reference to an object derived from the class.
	; Inside a method, the pseudo-keyword base can be used to access the super-class versions of methods or properties which are overridden in a derived class.
	;---------------------------------------------------------
	{
		return this.strTitle . " (" . this.intYear . ")"
	}
	;---------------------------------------------------------
	
	;---------------------------------------------------------
	ShowMe()
	; Each method has a hidden parameter named this, which typically contains a reference to an object derived from the class.
	; Inside a method, the pseudo-keyword base can be used to access the super-class versions of methods or properties which are overridden in a derived class.
	;---------------------------------------------------------
	{
		if (blnSkip)
			return
		str := "Class: " . this.base.__Class
		for strKey, varValue in this
			if IsObject(varValue)
			{
				str .= "`nsaSongs:"
				for intKey, oSong in varValue
					str .= "`n#" . intKey . " = " . oSong.strTitle
			}
			else
				str .= "`n" . strKey . " = " . varValue
		MsgBox, 4, , %str%
		IfMsgBox, No
			ExitApp
	}
	;---------------------------------------------------------
	
	;---------------------------------------------------------
	Property[]
	; obj.Property would call get while obj.Property := value would call set. Within get or set, this refers to the object being invoked. Within set, value contains the value being assigned.
	; https://autohotkey.com/docs/Objects.htm#Custom_Classes_property
	; Lexikos: "The "property" doesn't have a value - a "property" is a set of methods which are called when you get or set the property. Not all properties will store a value - some will compute it,
	; such as from a different property. For instance, a Colour object might have R, G, B and RBG properties, but the first three would be derived from the last one.
	; https://www.autohotkey.com/boards/viewtopic.php?t=9792#p54480
	;---------------------------------------------------------
	{
		get
		{
			return this._propertyname ; Lexikos: "One common convention is to use a single underscore for internal members, as in _propertyname. But it's just a convention."
		}
		set
		{
			return this._propertyname := value
		}
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	class Song
	; Nested class definitions allow a class object to be stored inside another class object rather than a separate global variable.
	; In the example above, class NestedClass constructs an object and stores it in ClassName.NestedClass.
	;---------------------------------------------------------
	{
		;-----------------------------------------------------
		__New(strTitle, intTrack, intDuration)
		;-----------------------------------------------------
		{
			this.strTitle := strTitle
			this.intTrack := intTrack
			this.intDuration := intDuration
		}
		;-----------------------------------------------------
		
		;-----------------------------------------------------
		GetString()
		; Each method has a hidden parameter named this, which typically contains a reference to an object derived from the class.
		; Inside a method, the pseudo-keyword base can be used to access the super-class versions of methods or properties which are overridden in a derived class.
		;-----------------------------------------------------
		{
			return this.intTrack . ": " . this.strTitle . " (" . (this.intDuration // 60) . ":" . Mod(this.intDuration, 60) . ")"
		}
		;-----------------------------------------------------
		
		;-----------------------------------------------------
		ShowMe()
		; Each method has a hidden parameter named this, which typically contains a reference to an object derived from the class.
		; Inside a method, the pseudo-keyword base can be used to access the super-class versions of methods or properties which are overridden in a derived class.
		;-----------------------------------------------------
		{
			if (blnSkip)
				return
			str := "Class: " . this.base.__Class
			for strKey, varValue in this
				if IsObject(varValue)
					str .= "`n" . strKey . ": " . varValue.strTitle
				else
				str .= "`n" . strKey . " = " . varValue
			MsgBox, 4, , %str%
			IfMsgBox, No
				ExitApp
		}
		;-----------------------------------------------------
		
	}
	;---------------------------------------------------------
}
;-------------------------------------------------------------



;-------------------------------------------------------------
class Model
/*
TODO
*/

/*
class ClassName
	Methods
		- __New(): 
	Properties
		- :
	Instance variables
		- :
*/
;-------------------------------------------------------------
{
	; Instance variables
		; Instance variables are declared like normal assignments, but the this. prefix is omitted (only directly within the class body).
		; To access an instance variable (even within a method), always specify the target object; for example, this.InstanceVar
		
	; Static/Class Variables
		; Static/class variables belong to the class itself, but can be inherited by derived objects (including sub-classes).
		; They are declared like instance variables, but using the static keyword. Static declarations are evaluated only once, before the auto-execute section, in the order they appear in the script.
		; Each declaration stores a value in the class object. Any variable references in Expression are assumed to be global.
		; To assign to a class variable, always specify the class object; for example, ClassName.ClassVar := Value.
		; If an object x is derived from ClassName and x itself does not contain the key "ClassVar", x.ClassVar may also be used to dynamically retrieve the value of ClassName.ClassVar.
		
	;---------------------------------------------------------
	__New()
	;---------------------------------------------------------
	{
	}
	;---------------------------------------------------------
	
	;---------------------------------------------------------
	Method()
	; Each method has a hidden parameter named this, which typically contains a reference to an object derived from the class.
	; Inside a method, the pseudo-keyword base can be used to access the super-class versions of methods or properties which are overridden in a derived class.
	;---------------------------------------------------------
	{
		
	}
	;---------------------------------------------------------
	
	;---------------------------------------------------------
	Property[]
	; obj.Property would call get while obj.Property := value would call set. Within get or set, this refers to the object being invoked. Within set, value contains the value being assigned.
	; https://autohotkey.com/docs/Objects.htm#Custom_Classes_property
	; Lexikos: "The "property" doesn't have a value - a "property" is a set of methods which are called when you get or set the property. Not all properties will store a value - some will compute it,
	; such as from a different property. For instance, a Colour object might have R, G, B and RBG properties, but the first three would be derived from the last one.
	; https://www.autohotkey.com/boards/viewtopic.php?t=9792#p54480
	;---------------------------------------------------------
	{
		get
		{
			return this._propertyname ; Lexikos: "One common convention is to use a single underscore for internal members, as in _propertyname. But it's just a convention."
		}
		set
		{
			return this._propertyname := value
		}
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	class NestedClass
	; Nested class definitions allow a class object to be stored inside another class object rather than a separate global variable.
	; In the example above, class NestedClass constructs an object and stores it in ClassName.NestedClass.
	;---------------------------------------------------------
	{
		;-----------------------------------------------------
		__New()
		;-----------------------------------------------------
		{
		}
		;-----------------------------------------------------
		
	}
	;---------------------------------------------------------
}
;-------------------------------------------------------------

