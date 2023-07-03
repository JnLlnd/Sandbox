#SingleInstance,Force

aaAlbums := Object()
aaAlbumsByYear := Object()

Loop, Read, %A_ScriptDir%\TheBeatles-alpha.csv
{
	; line structure:
	; Name ->  Album ->  Track ->  Genre ->  Duration ->  Size
	saSong := StrSplit(A_LoopReadLine, A_Tab)
	; ShowSimpleArray(A_LoopReadLine, saSong)
	
	aaSong := Object()
	aaSong.Name := saSong[1]
	aaSong.Album := saSong[2]
	aaSong.Track := saSong[3]
	aaSong.Duration := saSong[4]
	aaSong.Year := saSong[5]
	; ShowAssociativeArray("Song", aaSong)

	if !aaAlbums.HasKey(aaSong.Album) ; if not part of the index
	{
		saAlbum := Object()
		aaAlbums[aaSong.Album] := saAlbum
		; ShowAssociativeArray("Albums", aaAlbums)
		aaAlbumsByYear[aaSong.Year . "-" . aaSong.Album] := saAlbum ; concatenate year and album name in case we ave 2 albums the same year
	}
	aaAlbums[aaSong.Album][aaSong.Track] := aaSong
	; ShowAlbumTracksTitles(aaSong.Album, aaAlbums[aaSong.Album])
}

ShowAssociativeArray("Albums by year", aaAlbumsByYear)

; Looping the collection by year

strCollection := ""
for strYearKey, aaOneAlbum in aaAlbumsByYear
{
	strCollection .= "`n" . aaOneAlbum[1].Album . " (" . aaOneAlbum[1].Year . ")" . "`n---`n"
	for intTrack, aaOneSong in aaOneAlbum
		strCollection .= intTrack . ": " . aaOneSong.Name . " (" . (aaOneSong.Duration // 60) . ":" . Mod(aaOneSong.Duration, 60) . ")`n"
}

MsgBox, 4, , Copy the collection to the Clipboard?
IfMsgBox, Yes
	Clipboard := strCollection

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
	for strKey, oValue in aaObject
		strFields .= strKey . ": " . oValue.Name . "`n"
	Show(strTitle, strFields)
}
;------------------------------------------------------------

;------------------------------------------------------------
ShowAlbumTracksTitles(strTitle, saAlbum)
;------------------------------------------------------------
{
	for intIndex, aaTrack in saAlbum
		strItems .= intIndex . ": " . aaTrack.Name . "`n"
	Show(strTitle, strItems)
}
;------------------------------------------------------------

;------------------------------------------------------------
Show(strTitle, strMessage)
;------------------------------------------------------------
{
	strGuiTitle := "Objects Tutorial"
	Gui, New, , %strGuiTitle%
	Gui, Font, w700 s12, Arial
	Gui, Add, Text, , %strTitle%
	Gui, Font, w400
	Gui, Add, Text, , %strMessage%
	Gui, Font, w400 s8, Arial
	Gui, Add, Button, Default y+20 w80, Next
	Gui, Show
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
