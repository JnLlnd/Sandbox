#NoEnv
#SingleInstance, Force
SetWorkingDir %A_ScriptDir% 

; ClipboardAll may also be saved to a file (in this mode, FileAppend always overwrites any existing file):
; FileAppend, %ClipboardAll%, C:\Company Logo.clip ; The file extension does not matter.

; To later load the file back onto the clipboard (or into a variable), follow this example:
; FileRead, Clipboard, *c C:\Company Logo.clip ; Note the use of *c, which must precede the filename.

; CHECK IF CLIPBOARD CONTAINS BITMAP
CF_BITMAP := 2
if !DllCall("IsClipboardFormatAvailable", "UInt", CF_BITMAP)
      ###_D("There is no image in the Clipboard")
	  
; SAVE IMAGE IN CLIPBOARD TO PNG FILE
destPngFilePath := A_ScriptDir . "\ClipboardImage.png"
hBitmap := GetBitmapFromClipboard()
HBitmapToPng(hBitmap, destPngFilePath)
DllCall("DeleteObject", "Ptr", hBitmap)

; ENCODE PNG FILE TO BASE64
FileGetSize, intBytes, %destPngFilePath%
FileRead, oPngBin, *c %destPngFilePath%
strBase64 := Base64Enc(oPngBin, intBytes, 64, 0)

; DECODE BASE64 TO PNG FILE
destPngFilePathNew := A_ScriptDir . "\ClipboardImageNew.png"
intBytes := Base64Dec(strBase64, oNewBin)
oFile := FileOpen(destPngFilePathNew, "w")
oFile.RawWrite(oNewBin, intBytes)
oFile.Close()

; LOAD PNG FILE TO CLIPBOARD
Clipboard =
FileToClipboard(destPngFilePathNew)
ClipWait, 2
Gui, Add, Picture, w256 h256, %destPngFilePathNew%
Gui, Show

return

Base64Dec( ByRef B64, ByRef Bin )
; By SKAN / 18-Aug-2017 (https://www.autohotkey.com/boards/viewtopic.php?t=35964)
{
	Local Rqd := 0
	
	BLen := StrLen(B64) ; CRYPT_STRING_BASE64 := 0x1
	DllCall("Crypt32.dll\CryptStringToBinary", "Str", B64, "UInt", BLen, "UInt", 0x1, "UInt", 0, "UIntP", Rqd, "Int", 0, "Int", 0)
	VarSetCapacity(Bin, 128)
	VarSetCapacity(Bin, 0)
	VarSetCapacity(Bin, Rqd, 0)
	DllCall("Crypt32.dll\CryptStringToBinary", "Str", B64, "UInt", BLen, "UInt", 0x1, "Ptr", &Bin, "UIntP", Rqd, "Int", 0, "Int", 0)
	
	return Rqd
}

Base64Enc(ByRef Bin, nBytes, LineLength := 64, LeadingSpaces := 0)
; By SKAN / 18-Aug-2017 (https://www.autohotkey.com/boards/viewtopic.php?t=35964)
{
	Local Rqd := 0, B64, B := "", N := 0 - LineLength + 1  ; CRYPT_STRING_BASE64 := 0x1

	DllCall("Crypt32.dll\CryptBinaryToString", "Ptr", &Bin ,"UInt", nBytes, "UInt", 0x1, "Ptr", 0, "UIntP", Rqd) ; replace 0x1 with 0x40000001 for no linefeed
	VarSetCapacity(B64, Rqd * (A_Isunicode ? 2 : 1), 0)
	DllCall("Crypt32.dll\CryptBinaryToString", "Ptr", &Bin, "UInt", nBytes, "UInt", 0x1, "Str", B64, "UIntP", Rqd)
	If (LineLength = 64 and ! LeadingSpaces)
		return B64
	
	B64 := StrReplace(B64, "`r`n")        
	Loop % Ceil(StrLen(B64) / LineLength)
		B .= Format("{1:" . LeadingSpaces . "s}", "") . SubStr(B64, N += LineLength, LineLength ) . "`n" 
	return RTrim(B , "`n")    
}


; https://www.autohotkey.com/boards/viewtopic.php?p=418993#p418993
GetBitmapFromClipboard() {
   static CF_BITMAP := 2, CF_DIB := 8, SRCCOPY := 0x00CC0020
   if !DllCall("IsClipboardFormatAvailable", "UInt", CF_BITMAP)
      throw "There is no image in the Clipboard"
   if !DllCall("OpenClipboard", "Ptr", 0)
      throw "OpenClipboard failed"
   hDIB := DllCall("GetClipboardData", "UInt", CF_DIB, "Ptr")
   hBM  := DllCall("GetClipboardData", "UInt", CF_BITMAP, "Ptr")
   DllCall("CloseClipboard")
   if !hDIB
      throw "GetClipboardData failed"
   pDIB := DllCall("GlobalLock", "Ptr", hDIB, "Ptr")
   width  := NumGet(pDIB +  4, "UInt")
   height := NumGet(pDIB +  8, "UInt")
   bpp    := NumGet(pDIB + 14, "UShort")
   DllCall("GlobalUnlock", "Ptr", pDIB)
   
   hDC := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
   oBM := DllCall("SelectObject", "Ptr", hDC, "Ptr", hBM, "Ptr")
   
   hMDC := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
   hNewBM := CreateDIBSection(width, -height,, bpp)
   oPrevBM := DllCall("SelectObject", "Ptr", hMDC, "Ptr", hNewBM, "Ptr")
   DllCall("BitBlt", "Ptr", hMDC, "Int", 0, "Int", 0, "Int", width, "Int", height
                   , "Ptr", hDC , "Int", 0, "Int", 0, "UInt", SRCCOPY)
   DllCall("SelectObject", "Ptr", hDC, "Ptr", oBM, "Ptr")
   DllCall("DeleteDC", "Ptr", hDC), DllCall("DeleteObject", "Ptr", hBM)
   DllCall("SelectObject", "Ptr", hMDC, "Ptr", oPrevBM, "Ptr")
   DllCall("DeleteDC", "Ptr", hMDC)
   Return hNewBM
}

CreateDIBSection(w, h, ByRef ppvBits := 0, bpp := 32) {
   hDC := DllCall("GetDC", "Ptr", 0, "Ptr")
   VarSetCapacity(BITMAPINFO, 40, 0)
   NumPut(40 , BITMAPINFO,  0)
   NumPut( w , BITMAPINFO,  4)
   NumPut( h , BITMAPINFO,  8)
   NumPut( 1 , BITMAPINFO, 12)
   NumPut(bpp, BITMAPINFO, 14)
   hBM := DllCall("CreateDIBSection", "Ptr", hDC, "Ptr", &BITMAPINFO, "UInt", 0
                                    , "PtrP", ppvBits, "Ptr", 0, "UInt", 0, "Ptr")
   DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)
   return hBM
}

HBitmapToPng(hBitmap, destPngFilePath) {
   static CLSID_WICImagingFactory  := "{CACAF262-9370-4615-A13B-9F5539DA4C0A}"
         , IID_IWICImagingFactory  := "{EC5EC8A9-C395-4314-9C77-54D7A935FF70}"
         , GUID_ContainerFormatPng := "{1B7CFAF4-713F-473C-BBCD-6137425FAEAF}"
         , WICBitmapUseAlpha := 0x00000000, GENERIC_WRITE := 0x40000000
         , WICBitmapEncoderNoCache := 0x00000002
         
   VarSetCapacity(GUID, 16, 0)
   DllCall("Ole32\CLSIDFromString", "WStr", GUID_ContainerFormatPng, "Ptr", &GUID)
   IWICImagingFactory := ComObjCreate(CLSID_WICImagingFactory, IID_IWICImagingFactory)
   Vtable( IWICImagingFactory    , CreateBitmapFromHBITMAP := 21 ).Call("Ptr", hBitmap, "Ptr", 0, "UInt", WICBitmapUseAlpha, "PtrP", IWICBitmap)
   Vtable( IWICImagingFactory    , CreateStream            := 14 ).Call("PtrP", IWICStream)
   Vtable( IWICStream            , InitializeFromFilename  := 15 ).Call("WStr", destPngFilePath, "UInt", GENERIC_WRITE)
   Vtable( IWICImagingFactory    , CreateEncoder           :=  8 ).Call("Ptr", &GUID, "Ptr", 0, "PtrP", IWICBitmapEncoder)
   Vtable( IWICBitmapEncoder     , Initialize              :=  3 ).Call("Ptr", IWICStream, "UInt", WICBitmapEncoderNoCache)
   Vtable( IWICBitmapEncoder     , CreateNewFrame          := 10 ).Call("PtrP", IWICBitmapFrameEncode, "Ptr", 0)
   Vtable( IWICBitmapFrameEncode , Initialize              :=  3 ).Call("Ptr", 0)
   Vtable( IWICBitmapFrameEncode , WriteSource             := 11 ).Call("Ptr", IWICBitmap, "Ptr", 0)
   Vtable( IWICBitmapFrameEncode , Commit                  := 12 ).Call()
   Vtable( IWICBitmapEncoder     , Commit                  := 11 ).Call()
   for k, v in [IWICBitmapFrameEncode, IWICBitmapEncoder, IWICStream, IWICBitmap, IWICImagingFactory]
      ObjRelease(v)
}

Vtable(ptr, n) {
   return Func("DllCall").Bind(NumGet(NumGet(ptr+0), A_PtrSize*n), "Ptr", ptr)
}


; https://www.autohotkey.com/boards/viewtopic.php?style=17&p=357796#p357796
FileToClipboard(PathToCopy, Method := "copy") {
 ; https://autohotkey.com/board/topic/23162-how-to-copy-a-file-to-the-clipboard/page-4
 FileCount := PathLength := 0
 Loop, Parse, PathToCopy, `n, `r ; Count files and total string length
  FileCount++, PathLength+=StrLen(A_LoopField)
 pid := DllCall("GetCurrentProcessId", "uint"), hwnd := WinExist("ahk_pid " . pid)
 ; 0x42 = GMEM_MOVEABLE(0x2) | GMEM_ZEROINIT(0x40)
 hPath := DllCall("GlobalAlloc", "uint", 0x42, "uint", 20 + (PathLength + FileCount + 1) * 2, "UPtr")
 pPath := DllCall("GlobalLock", "UPtr", hPath)
 NumPut(20, pPath+0), pPath += 16 ; DROPFILES.pFiles = offset of file list
 NumPut(1, pPath+0), pPath += 4 ; fWide = 0 -->ANSI, fWide = 1 -->Unicode
 Offset := 0
 Loop, Parse, PathToCopy, `n, `r ; Rows are delimited by linefeeds (`r`n)
  offset += StrPut(A_LoopField, pPath+offset, StrLen(A_LoopField)+1, "UTF-16") * 2
 DllCall("GlobalUnlock", "UPtr", hPath), DllCall("OpenClipboard", "UPtr", hwnd), DllCall("EmptyClipboard")
 DllCall("SetClipboardData", "uint", 0xF, "UPtr", hPath) ; 0xF = CF_HDROP
 ; Write Preferred DropEffect structure to clipboard to switch between copy/cut operations
 ; 0x42 = GMEM_MOVEABLE(0x2) | GMEM_ZEROINIT(0x40)
 mem := DllCall("GlobalAlloc", "uint", 0x42, "uint", 4, "UPtr"), str := DllCall("GlobalLock", "UPtr", mem)
 If !(Method ~= "copy|cut") {
  DllCall("CloseClipboard")
  Return
 } Else DllCall("RtlFillMemory", "UPtr", str, "uint", 1, "UChar", (Method = "copy" ? "0x05" : "0x02"))
 DllCall("GlobalUnlock", "UPtr", mem)
 cfFormat := DllCall("RegisterClipboardFormat", "Str", "Preferred DropEffect")
 DllCall("SetClipboardData", "uint", cfFormat, "UPtr", mem)
 DllCall("CloseClipboard")
}

/*

File := "ahkicon.png"
If ! FileExist( File )
	URLDownloadToFile, http://i.imgur.com/dS56Ewu.png, %File%

FileGetSize, nBytes, %File%
FileRead, Bin, *c %File%
B64Data := Base64Enc( Bin, nBytes, 100, 2 )
MsgBox % Clipboard := B64Data 


Base64ImageData := "
( LTrim Join
  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
)"

nBytes := Base64Dec( Base64ImageData, Bin )

File := FileOpen("ahkiconnew.png", "w")
File.RawWrite(Bin, nBytes)
File.Close()

Gui, Add, Picture, w256 h256, ahkiconnew.png
Gui, Show

Return ;    // end of auto-execcute section //





