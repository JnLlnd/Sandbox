;*****************************************************************************************
#Include %A_ScriptDir%\..\Lib\gdip.ahk
#Include %A_ScriptDir%\..\Lib\WinClipAPI.ahk ; include this first
#Include %A_ScriptDir%\..\Lib\WinClip.ahk
;*****************************************************************************************
#SingleInstance, Force
SetBatchLines, -1
Gdip_Startup()

; small image converted from a PNG file to Base64
strBase64 = 
(
iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAIAAAAC64paAAAAAXNSR0IArs4c6QAA
AARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAGJSURBVDhPhVS7
UgJRDN2fcUHbfdm5D2zRVnxUipZS0tJpCxU28gM0FFpYWNjsDI78kZ6TxPU6c1nO
ZCDkcW5yk0vQSQpINyk7cRFGuf6E/idJ2U3L/bTCJyPTCjolq4K96CiMcwkihbHE
uRpDEaP7DUA+w5IyCJtkydE4MqKKuCj7g6u70XjyMJsv3t4/6s/Nt0C4yqCjhyTF
6fnN5e1oOn9erl7q9ReMGueFnSxfhdkctCejYSk7znETZnMAn2k+4CLQOcpmq2Zz
gIpM84F3hmS9GLM5gM80H/TmtyfvKhtZ7Jnj0RnKGlBkvGpppqqlcmEyLgnLhgNx
RuigvWwlDUjmq7D9ti1Z6zSbA6+xAY/kbWPDIs+o2pOt520nw22aD2hKNizibpvN
wc6ywc4NUzk5u74Y3k/ni+XqtV5v4LZAH6xnnCDzxKLLhGXIagF31R/gqY0nj7On
f0+SPfNJSrIWzwGgGXmrpODfRU/X4yDrIUFzVNiz+Kgpi7o1oRFNAxEEP43u8PgH
TY7KPhYw7IMAAAAASUVORK5CYII=
)

intBytes := Base64Dec( strBase64, oBin )
oFile := FileOpen(A_ScriptDir . "\icon.png", "w")
oFile.RawWrite(oBin, intBytes)
oFile.Close()
WinClip.Clear()
WinClip.SetBitmap(A_ScriptDir . "\icon.png")
return

; pBitmap := B64ToPBitmap( strBase64 )
; WinClip.Clear()
; WinClip.SetBitmap(pBitmap)
; return

width := Gdip_GetImageWidth( pBitmap )
height := Gdip_GetImageHeight( pBitmap )
hBitmap := Gdip_CreateHBITMAPFromBitmap( pBitmap )
Gdip_DisposeImage( pBitmap )
DeleteObject( hBitmap )
return

B64ToPBitmap( Input ){
	local ptr , uptr , pBitmap , pStream , hData , pData , Dec , DecLen , B64
	VarSetCapacity( B64 , strlen( Input ) << !!A_IsUnicode )
	B64 := Input
	If !DllCall("Crypt32.dll\CryptStringToBinary" ( ( A_IsUnicode ) ? ( "W" ) : ( "A" ) ), Ptr := A_PtrSize ? "Ptr" : "UInt" , &B64, "UInt", 0, "UInt", 0x01, Ptr, 0, "UIntP", DecLen, Ptr, 0, Ptr, 0)
		Return False
	VarSetCapacity( Dec , DecLen , 0 )
	If !DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &B64, "UInt", 0, "UInt", 0x01, Ptr, &Dec, "UIntP", DecLen, Ptr, 0, Ptr, 0)
		Return False
	DllCall("Kernel32.dll\RtlMoveMemory", Ptr, pData := DllCall("Kernel32.dll\GlobalLock", Ptr, hData := DllCall( "Kernel32.dll\GlobalAlloc", "UInt", 2,  UPtr := A_PtrSize ? "UPtr" : "UInt" , DecLen, UPtr), UPtr) , Ptr, &Dec, UPtr, DecLen)
	DllCall("Kernel32.dll\GlobalUnlock", Ptr, hData)
	DllCall("Ole32.dll\CreateStreamOnHGlobal", Ptr, hData, "Int", True, Ptr "P", pStream)
	DllCall("Gdiplus.dll\GdipCreateBitmapFromStream",  Ptr, pStream, Ptr "P", pBitmap)
	return pBitmap
}

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
