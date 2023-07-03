#SingleInstance,Force

; ------------------------------
; DEFINITION
; Using objects in AHK allows us to group values in sequences (lists)
; or to group values by subject (for example, properties of an item.)
; ------------------------------

; ------------------------------
; VARIABLE NAMING CONVENTION
; strVariableName : Strings
; intVariableName : Integer
; saVariableName  : Simple array objects (sequence)
; aaVariableName  : Associative array objects (properties)
; ------------------------------

; Declaring and initializing an object
saSongs := Object() ; not required if the object is created with Array() or [] (see below)

; === Simple arrays ===

; Create a Simple array object 
saSongs := ["A Hard Day's Night", "I Should Have Known Better"]
Show("Simple array using ""[""", saSongs[1] . "`n" . saSongs[2])

; Using "Array()" another method for the same result
saSongs := Array("A Hard Day's Night", "I Should Have Known Better")
Show("Simple array using ""Array()""", saSongs[1] . "`n" . saSongs[2])

; Adding items to a Simple array with "Push"
saSongs.Push("Two Of Us", "Come Together", "Something", "Maxwell's Silver Hammer", "Help!")

; .MaxIndex() returns the number of items in a Simple array if the array is sequential
Show("Nb of items in a simple array", saSongs.MaxIndex())

; Simple array can be non-sequential and have jumps between items
saSongs[12] := "Extra Song 12"
saSongs[15] := "Extra Song 15"

; or .MaxIndex() returns the highest index number if the array is non-sequential
Show("Highest index number in a simple array", saSongs.MaxIndex() . " / " . saSongs.Count())

; Looping in a Simple array with "Loop"
strSongs := ""
Loop, % saSongs.MaxIndex()
	strSongs .= A_Index . ": " . saSongs[A_Index] . "`n"
Show("Songs with for ""Loop""", strSongs)

; Looping in a Simple array with "for"
strSongs := ""
for intIndex, strThisSong in saSongs
	strSongs .= intIndex . ": " . strThisSong . "`n"
Show("Songs with for ""For""", strSongs)

; Remove item with RemoveAt
strRemovedSong := saSongs.RemoveAt(3)
ShowSimpleArray("Removed: """ . strRemovedSong . """ with ""RemoveAt""", saSongs)

; Remove last item with Pop
strRemovedSong := saSongs.Pop()
ShowSimpleArray("Removed: """ . strRemovedSong . """ with ""Pop""", saSongs)
strRemovedSong := saSongs.Pop()
ShowSimpleArray("Removed: """ . strRemovedSong . """ with ""Pop""", saSongs)
*/

; === Associative arrays ===

; Declaring and initializing an object
aaSongA := Object() ; not required if object created with Object() or {} (see below)

; Create an associative array object
aaSongA := {strName: "Come Together", strAlbum: "Abbey Road", intTrack: 1}

; Using "Object()" another method for the same result
aaSongB := Object("strName", "Something", "strAlbum", "Abbey Road", "intTrack", 2)

; Access an associative array item
strKey := "strName"
Show("Accessing an associativer array item"
	, "With dot: " . aaSongB.strName 
	. "`nWith brackets: " . aaSongB["strName"] 
	. "`nWith bracket and variable name: " . aaSongB[strKey])

; Looping in an associative array
strSong := ""
for strKey, strValue in aaSongA
	strSong .= strKey . ": " . strValue . "`n"
Show("Song A", strSong)

; Adding or updating an associative array with brackets
aaSongB := Object()
aaSongB["strName"] := "Something"
aaSongB["strAlbum"] := "Abbey Road"
aaSongB["intTrack"] := 2
ShowAssociativeArray("Song B", aaSongB)

; Adding or updating an associative array with dots
aaSongC := Object()
aaSongC.strName := "Maxwell's Silver Hammer"
aaSongC.strAlbum := "Abbey Road"
aaSongC.intTrack := 3
ShowAssociativeArray("Song C", aaSongC)

; === Combining Simple and Associative arrays ===

; Joinig items in a Simple array
saTracks := Object()
saTracks.Push(aaSongA)
saTracks.Push(aaSongB)
saTracks.Push(aaSongC)

strTracks := ""
for intIndex, aaOneSong in saTracks
	strTracks .= intIndex . ": " . aaOneSong.strName . " - " . aaOneSong.intTrack . "`n"
Show("Tracks", strTracks)

; Including a Simple array in an Associative array
aaAlbum := Object()
aaAlbum.strName := "Abbey Road"
aaAlbum.intYear := "1969"
aaAlbum.saTracks := saTracks

strTracks := ""
for intIndex, aaOneSong in aaAlbum["saTracks"]
	strTracks .= aaAlbum.strName . " - Track #" . intIndex . ": " . aaOneSong.strName . " (" . aaAlbum.intYear . ")`n"
Show("Albums, Tracks and Year", strTracks)

; Sorting items by name
aaTracksByName := Object()
for intIndex, aaOneSong in aaAlbum.saTracks
	aaTracksByName[aaOneSong.strName] := aaOneSong ; items in aaTracksByName are automatically sorted by their index aaOneSong.strName
aaAlbum.aaIndex := aaTracksByName

strTracks := ""
for intIndex, aaOneSong in aaAlbum.aaIndex
	strTracks .= aaOneSong.strName . "`n"
Show(aaAlbum.strName . " Tracks Sorted", strTracks)

; === Tips ===

; Check if a key exists in an associative array
strTitle := """strName"" exists? " . (aaAlbum.HasKey("strName") ? "Yes" : "No")
	. "`n" . """saTracks"" exists? " . (aaAlbum.HasKey("saTracks") ? "Yes" : "No")
	. "`n" . """strFormat"" exists? " . (aaAlbum.HasKey("strFormat") ? "Yes" : "No")
ShowAssociativeArray(strTitle, aaAlbum)

; StrSplit create a simple array from a delimited string
saList := StrSplit("Abbey Road|White Album|Let it be", "|")
ShowSimpleArray("Create a Simple array from a string", saList)

ExitApp


; === FUNCTIONS ===

;------------------------------------------------------------
ShowSimpleArray(strTitle, saObject)
;------------------------------------------------------------
{
	for intIndex, strValue in saObject
		strItems .= intIndex . ": " . strValue . "`n"
	Show(strTitle, strItems)
}
;------------------------------------------------------------

;------------------------------------------------------------
ShowAssociativeArray(strTitle, aaObject)
;------------------------------------------------------------
{
	for strKey, strValue in aaObject
		strFields .= strKey . ": " . strValue . "`n"
	Show(strTitle, strFields)
}
;------------------------------------------------------------

;------------------------------------------------------------
Show(strTitle, strMessage)
;------------------------------------------------------------
{
	strGuiTitle := "Objects Tutorial"
	Gui, New, , %strGuiTitle%
	Gui, Font, w700 s14, Arial
	Gui, Add, Text, , %strTitle%
	Gui, Font, w400
	Gui, Add, Text, , %strMessage%
	Gui, Font, w400 s8, Arial
	Gui, Add, Button, Default y+20 w80, Next
	Gui, Show, x1200 y 250
	WinSet, AlwaysOnTop,On, %strGuiTitle%
	WinWaitClose, %strGuiTitle%
}
;------------------------------------------------------------

;------------------------------------------------------------
ButtonNext:
;------------------------------------------------------------
Gui, Destroy
return
;------------------------------------------------------------

;------------------------------------------------------------
GuiClose:
GuiEscape:
;------------------------------------------------------------
ExitApp
;------------------------------------------------------------
