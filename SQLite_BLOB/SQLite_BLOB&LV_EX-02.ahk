#SingleInstance Force
#requires AutoHotkey v1.1

SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\Class_SQLiteDB.ahk ; SQLite wrapper from just_me (https://autohotkey.com/boards/viewtopic.php?t=1064)
#include %A_ScriptDir%\Gdip_all.ahk
pToken := Gdip_Startup()

; Create SQLite database and create table
strDBFileName := "TEST.DB"
If FileExist(strDBFileName)
{
	SB_SetText("Deleting " . strDBFileName)
	FileDelete, %strDBFileName%
}
; Use Class SQLiteDB : Create new instance
o_Db := new SQLiteDB
If !o_Db.OpenDB(strDBFileName)
{
	MsgBox, 16, SQLite Error, % "Msg:`t" . o_Db.ErrorMsg . "`nCode:`t" . o_Db.ErrorCode
	ExitApp
}
If !o_Db.Exec("CREATE TABLE Test (TextType, BlobType);")
	MsgBox, 16, SQLite Error, % "Msg:`t" . o_Db.ErrorMsg . "`nCode:`t" . o_Db.ErrorCode

; Insert two records with image blobs
Loop, 4
{
	; Download text bmp file
	strImagePath := "Img" . A_Index . ".bmp"
	FileDelete, %strImagePath%
	URLDownloadToFile, http://www.quickaccesspopup.com/temp/bmp/img%A_Index%.bmp, %strImagePath%
	hFileData := FileOpen(strImagePath, "r")
	intSizeData := hFileData.RawRead(oBlobData, hFileData.Length)
	hFileData.Close()
	oBlobArray := []
	oBlobArray.Insert({Addr: &oBlobData, Size: intSizeData}) ; will be inserted as element 1 and 2
	strDbSQL := "INSERT INTO Test VALUES('Text', ?);"
	If !o_Db.StoreBLOB(strDbSQL, oBlobArray)
		MsgBox, 16, SQLite Error, % "Msg:`t" . o_Db.ErrorMsg . "`nCode:`t" . o_Db.ErrorCode
}

; Retrieve images from database

; IL_Add Doc:
; [v1.1.23+]: A bitmap or icon handle can be used instead of a filename. For example, HBITMAP:%handle%.
; g_pBitmapEditor := Gdip_CreateBitmapFromData(g_aaLastHistoryClip.intImageAddr, g_aaLastHistoryClip.intImageSize) ; load bitmap in editor
; Gui, SeeImage:Add, Picture, +Border, % "HBITMAP:*" . GetPictureHBitmap(g_pBitmapEditor, g_intEditorDefaultWidth, 480, intActualW, intActualH)

strDbSQL := "SELECT * FROM Test;"
If !o_DB.Query(strDbSQL, oRecordSet)
	MsgBox, 16, SQLite Error, % "Msg:`t" . o_Db.ErrorMsg . "`nCode:`t" . o_Db.ErrorCode

; Create an image list with two item
intIlW := 48
intIlH := 48
hIl := ImageList_Create(intIlW, intIlH, ILC_COLOR32|ILC_ORIGINALSIZE, 10, 10)
Loop, 4
{
	oRecordSet.Next(oRow)
	pAddr := oRow[2].GetAddress("Blob") ; second field contains blob data and size
	intSize := oRow[2].Size
	pBitmap := Gdip_CreateBitmapFromData(pAddr, intSize)
	hBitmap := GetPictureHBitmap(pBitmap, intIlW, intIlH, intActualW, intActualH)
	intIndex := ImageList_Add(hIl, hBitmap) 
}
oRecordSet.Free()
/*
Loop, 2
{
	oRecordSet.Next(oRow)
	FileDelete, Blob%A_Index%.bmp
	oBlobFile := FileOpen("Blob" . A_Index . ".bmp", "w")
	pAddr := oRow[2].GetAddress("Blob") ; second field contains blob data and size
	intSize := oRow[2].Size
	VarSetCapacity(oBlobVar, intSize)
	DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", &oBlobVar, "Ptr", pAddr, "Ptr", intSize)
	oBlobFile.RawWrite(&oBLOBVar, intSize)
	oBlobFile.Close()
}
oRecordSet.Free()

; Create an image list with two item
intIlW := 48
intIlH := 48
hIl := ImageList_Create(intIlW, intIlH, ILC_COLOR32|ILC_ORIGINALSIZE, 10, 10)
Loop, 2
{
	Gdip_GetImageDimensionsFile(A_ScriptDir . "\Blob" . A_Index . ".bmp", intFileW, intFileH)
	fltResize := (intFileW < intFileH ? intIlH / intFileH : intIlW / intFileW)
	hIcon := API_LoadImage("Blob" . A_Index . ".bmp", "", Round(intFileW * fltResize), Round(intFileH * fltResize), 0x10) ; fit to isize
	intIndex := ImageList_Add(hIl, hIcon) 
}
*/

Gui, Add, ListView, w600 h600 HwndhLV Grid, Icon|Text
LV_SetImageList(hIl, 1) ; list mode (default)
Loop, 4
	LV_Add("Icon" . A_Index, "", "Test-" . A_Index)
LV_ModifyCol(1, intIlW + 12)
Gui, Show, Autosize 

return

GetPictureHBitmap(pBitmap, intMaxW := "", intMaxH := "", ByRef intWOut := "", ByRef intHOut := "")
; adapted from jeeswg (https://www.autohotkey.com/boards/viewtopic.php?p=172846#p172846)
{
	Gdip_GetImageDimensions(pBitmap, intImageW, intImageH)
	pBitmapEditor := (intImageW > intMaxW or intImageH > intMaxH ? Gdip_ResizeBitmap(pBitmap, intMaxW, intMaxH, true) : Gdip_CloneBitmap(pBitmap))
	Gdip_GetImageDimensions(pBitmapEditor, intWOut, intHOut)

	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmapEditor)
	Gdip_DisposeImage(pBitmapEditor)

	return hBitmap
}

Gdip_CreateBitmapFromData(DataPtr, DataSize)
; from just me (https://www.autohotkey.com/boards/viewtopic.php?p=552266#p552266)
{
	Local Bitmap := 0, Stream := 0, HR := 0
	If (Stream := DllCall("Shlwapi.dll\SHCreateMemStream", "Ptr", DataPtr, "UInt", DataSize, "UPtr"))
	{
		HR := DllCall("Gdiplus.dll\GdipCreateBitmapFromStream", "Ptr", Stream, "PtrP", Bitmap, "UInt")
		Stream.Release()
	}
	Return (HR ? 0 : Bitmap)
}

ImageList_Create(cx,cy,flags,cInitial,cGrow){
   return DllCall("comctl32.dll\ImageList_Create", "int", cx, "int", cy, "uint", flags, "int", cInitial, "int", cGrow) 
} 

Gdip_GetImageDimensionsFile(file, ByRef Width, ByRef Height){
	pBitmap  := Gdip_CreateBitmapFromFile(file)
	Gdip_GetImageDimensions(pBitmap,Width,Height)
	Gdip_DisposeImage(pBitmap)
}

API_LoadImage(pPath, uType, cxDesired, cyDesired, fuLoad) {
   return,  DllCall( "LoadImage", "uint", 0, "str", pPath, "uint", uType, "int", cxDesired, "int", cyDesired, "uint", fuLoad) 
}

ImageList_Add(hIml, hbmImage, hbmMask=""){ 
   return DllCall("comctl32.dll\ImageList_Add", "uint", hIml, "uint",hbmImage, "uint", hbmMask) 
} 

/*
loop,% dir "\*.*"
	{ 
		Gdip_GetImageDimensionsFile(A_LoopFileFullPath,w,h)
		m := (w<h ? isizeh/h : isizew/w)
		hIcon := API_LoadImage(A_LoopFileFullPath, 0, round(w*m), round(h*m), 0x10) ; fit to isize
		;hIcon := API_LoadImage(A_LoopFileFullPath, 0, w, h, 0x10) ; use oryginal size but crop image if larger than isize
		i := ImageList_Add( hIml, hIcon ) 
		;LV_Add("Icon" A_Index-1,A_Index,A_Index) 
		LV_Add("Icon" . i+1, A_Index,w,h)
		if (i==1)
			LV_ModifyCol()
		;msgbox,% i
	}

LV_Add("Icon" A_Index-1,A_Index,A_Index) 
		; LV_Add("Icon" . i+1, A_Index,w,h)
		; if (i==1)
			; LV_ModifyCol()
		;msgbox,% i
	}
; Create a gui with listview

return

/*
; Write GIF BLOB
HFILE := FileOpen("Original.gif", "r")
Size := HFILE.RawRead(BLOB, HFILE.Length)
HFILE.Close()
If !DB.Exec("CREATE TABLE Test (TextType, BlobType);")
   MsgBox, 16, SQLite Error, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
DB.Exec("BEGIN TRANSACTION;")
; ? stands for an automatically numbered parameter (here: 1) to use in BlobArray
SQL := "INSERT INTO Test VALUES('Text', ?);"
; Create the BLOB array
BlobArray := []
BlobArray.Insert({Addr: &BLOB, Size: Size}) ; will be inserted as element 1
If !DB.StoreBLOB(SQL, BlobArray)
   MsgBox, 16, SQLite Error, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
DB.Exec("COMMIT TRANSACTION;")

; Start of query using Query() : Get the BLOB from table Test
HFILE := FileOpen("Blob.gif", "w")
If !DB.Query("SELECT * FROM Test;", RecordSet)
   MsgBox, 16, SQLite Error: Query, % "Msg:`t" . RecordSet.ErrorMsg . "`nCode:`t" . RecordSet.ErrorCode
If (RecordSet.HasRows) {
   If (RecordSet.Next(Row) < 1) {
      MsgBox, 16, %A_ThisFunc%, % "Msg:`t" . RecordSet.ErrorMsg . "`nCode:`t" . RecordSet.ErrorCode
      Return
   }
   Loop, % RecordSet.ColumnCount {
      If IsObject(Row[A_Index]) {
         Size := Row[A_Index].Size
         Addr := Row[A_Index].GetAddress("Blob")
         If !(Addr) || !(Size) {
            MsgBox, 0, Error, BlobAddr = %Addr% - BlobSize = %Size%
         } Else {
            VarSetCapacity(MyBLOBVar, Size) ; added
            DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", &MyBLOBVar, "Ptr", Addr, "Ptr", Size) ; added
            HFILE.RawWrite(&MyBLOBVar, Size) ; changed
            ; HFILE.RawWrite(Addr + 0, Size) ; original
         }
      }
   }
}
RecordSet.Free()
HFILE.Close()
RecordSet.Free()

return
*/

; Write ClipboardAll BLOB
FileAppend, %ClipboardAll%, Test.clip

HFILE := FileOpen("Test.clip", "r")
Size := HFILE.RawRead(BLOB, HFILE.Length)
HFILE.Close()
If !DB.Exec("CREATE TABLE Test (TextType, BlobType);")
   MsgBox, 16, SQLite Error, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
DB.Exec("BEGIN TRANSACTION;")
; ? stands for an automatically numbered parameter (here: 1) to use in BlobArray
SQL := "INSERT INTO Test VALUES('Text', ?);"
; Create the BLOB array
BlobArray := []
BlobArray.Insert({Addr: &BLOB, Size: Size}) ; will be inserted as element 1
If !DB.StoreBLOB(SQL, BlobArray)
   MsgBox, 16, SQLite Error, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
DB.Exec("COMMIT TRANSACTION;")

; Start of query using Query() : Get the BLOB from table Test
HFILE := FileOpen("Blob.clip", "w")
If !DB.Query("SELECT * FROM Test;", RecordSet)
   MsgBox, 16, SQLite Error: Query, % "Msg:`t" . RecordSet.ErrorMsg . "`nCode:`t" . RecordSet.ErrorCode
If (RecordSet.HasRows) {
   If (RecordSet.Next(Row) < 1) {
      MsgBox, 16, %A_ThisFunc%, % "Msg:`t" . RecordSet.ErrorMsg . "`nCode:`t" . RecordSet.ErrorCode
      Return
   }
   Loop, % RecordSet.ColumnCount {
      If IsObject(Row[A_Index]) {
         Size := Row[A_Index].Size
         Addr := Row[A_Index].GetAddress("Blob")
         If !(Addr) || !(Size) {
            MsgBox, 0, Error, BlobAddr = %Addr% - BlobSize = %Size%
         } Else {
            VarSetCapacity(MyBLOBVar, Size) ; added
            DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", &MyBLOBVar, "Ptr", Addr, "Ptr", Size) ; added
            HFILE.RawWrite(&MyBLOBVar, Size) ; changed
            ; HFILE.RawWrite(Addr + 0, Size) ; original
         }
      }
   }
}
RecordSet.Free()
HFILE.Close()
RecordSet.Free()

return

^t::
Clipboard := ""
FileRead, Clipboard, *c Blob.clip
ClipWait, 1
Send, ^v
return
