#SingleInstance Force
#requires AutoHotkey v1.1

#Include %A_ScriptDir%\Class_SQLiteDB.ahk ; SQLite wrapper from just_me (https://autohotkey.com/boards/viewtopic.php?t=1064)
#Include %A_ScriptDir%\Gdip_All.ahk ; https://github.com/marius-sucan/AHK-GDIp-Library-Compilation/blob/master/ahk-v1-1/Gdip_All.ahk
SetWorkingDir, %A_ScriptDir%

; ======================================================================================================================
; Get the Google logo or store a picture named Original.gif in the script's folder and comment this out
FileDelete, Original.gif
URLDownloadToFile, http://www.google.de/intl/de_ALL/images/logos/images_logo_lg.gif, Original.gif

Gui, 1:Add, Picture, +Border, Original.gif
Gui, 1:Show, AutoSize x50 y50, Original

; Start
FileDelete, Blob.gif
DBFileName := A_ScriptDir . "\TEST_B.DB"
If FileExist(DBFileName) {
   SB_SetText("Deleting " . DBFileName)
   FileDelete, %DBFileName%
}

; Use Class SQLiteDB : Create new instance
DB := new SQLiteDB

; Use Class SQLiteDB : Open/create database and table, insert a BLOB from a GIF file
If !DB.OpenDB(DBFileName) {
   MsgBox, 16, SQLite Error, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
   ExitApp
}

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

; Get the BLOB from the database

If !DB.Query("SELECT * FROM Test;", RecordSet)
   MsgBox, 16, SQLite Error: Query, % "Msg:`t" . RecordSet.ErrorMsg . "`nCode:`t" . RecordSet.ErrorCode
RecordSet.Next(Row) ; get first (and only) row in the Test table

/*
; write the blob to a file (THIS IS WHAT I'D PREFER TO AVOID)
; second field in the row is the blob
Size := Row[2].Size 
Addr := Row[2].GetAddress("Blob")
VarSetCapacity(MyBLOBVar, Size)
DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", &MyBLOBVar, "Ptr", Addr, "Ptr", Size)
HFILE := FileOpen("MyBlob.gif", "w")
HFILE.RawWrite(&MyBLOBVar, Size) ; changed
RecordSet.Free()
HFILE.Close()
*/

pToken := Gdip_Startup()
; write the blob to hBitmap
; second field in the row is the blob
Size := Row[2].Size 
Addr := Row[2].GetAddress("Blob")
hBitmap := Gdip_CreateHBitmapFomData(Addr, Size)
Gui, 2:Add, Picture, +Border, % "HBITMAP:*" . hBitmap
Gui, 2:Show, AutoSize x100 y100, Blob!

RecordSet.Free()
return

2GuiClose:
ExitApp

Gdip_CreateHBitmapFomData(DataPtr, DataSize) {
   Local Bitmap := 0, HBitMap := 0
   If (Bitmap := Gdip_CreateBitmapFromData(DataPtr, DataSize)) {
      HBitMap := Gdip_CreateHBITMAPFromBitmap(Bitmap)
      Gdip_DisposeImage(Bitmap)
   }
   Return HBitmap
}

Gdip_CreateBitmapFromData(DataPtr, DataSize) {
   Local Bitmap := 0, Stream := 0, HR := 0
   If (Stream := DllCall("Shlwapi.dll\SHCreateMemStream", "Ptr", DataPtr, "UInt", DataSize, "UPtr")) {
      HR := DllCall("Gdiplus.dll\GdipCreateBitmapFromStream", "Ptr", Stream, "PtrP", Bitmap, "UInt")
      Stream.Release()
   }
   Return (HR ? 0 : Bitmap)
}

/*

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



Gui, SeeImage:Add, Picture, +Border, % "HBITMAP:*" . Gdip_CreateHBITMAPFromBitmap(Addr)
Gui, SeeImage:Show, AutoSize
RecordSet.Free()
HFILE.Close()
RecordSet.Free()

return
/*

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
