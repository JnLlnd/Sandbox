#SingleInstance Force
#requires AutoHotkey v1.1
#NoEnv
#Include %A_ScriptDir%\Lib\LV_EX.ahk
#include %A_ScriptDir%\..\..\QuickClipboardEditor\Lib\Gdip_all.ahk
Gdip_Startup()
; ----------------------------------------------------------------------------------------------------------------------
   ; From the help file:
	dir := A_ScriptDir . "\Png"
   HIML := IL_Create(10)  ; Create an ImageList to hold 10 small icons.
   ; Loop 10  ; Load the ImageList with a series of icons from the DLL.
       ; IL_Add(HIML, "shell32.dll", A_Index)  ; Omits the DLL's path so that it works on Windows 9x too.
	; loop, Files, % dir . "\*.*"
		; IL_Add(HIML, A_LoopFileFullPath)  ; Omits the DLL's path so that it works on Windows 9x too.
	ILC_COLOR32 := 0x20 
	ILC_ORIGINALSIZE := 0x00010000
	dir := A_ScriptDir . "\Bmp"
	isizew := 35
	isizeh := 35
	hIml := ImageList_Create(isizew, isizeh, ILC_COLOR32|ILC_ORIGINALSIZE, 100, 100) 
	loop,% dir "\*.*"
	{ 
		Gdip_GetImageDimensionsFile(A_LoopFileFullPath,w,h)
		m := (w<h ? isizeh/h : isizew/w)
		hIcon := API_LoadImage(A_LoopFileFullPath, 0, round(w*m), round(h*m), 0x10) ; fit to isize
		;hIcon := API_LoadImage(A_LoopFileFullPath, 0, w, h, 0x10) ; use oryginal size but crop image if larger than isize
		i := ImageList_Add( hIml, hIcon ) 
		;LV_Add("Icon" A_Index-1,A_Index,A_Index) 
		; LV_Add("Icon" . i+1, A_Index,w,h)
		; if (i==1)
			; LV_ModifyCol()
		;msgbox,% i
	}
	
   ; BkgImages := []
   ; Loop, %A_WinDir%\Web\Wallpaper\*.jpg, 0, 1
      ; BkgImages.Insert(A_LoopFileFullPath)
   Rows := 20
   Gui, Margin, 20, 20
   Gui, Add, Button, ym gOrder123, Order 1, 2, 3, 4
   Gui, Add, Button, ym gOrder321, Order 3, 2, 1, 4
   Gui, Add, Button, ym gRemoveImage, Remove BkImage
   Gui, Add, Button, ym gNewImage, New BkImage
   Gui, Add, Text, xm Section h20, First visible row:
   Gui, Add, Text, hp y+0, Is row 20 visible?
   Gui, Add, Text, hp y+0, Number of visible rows:
   Gui, Add, Text, ys hp vFVR, 00
   Gui, Add, Text, hp y+0 vIRV, 00
   Gui, Add, Text, hp y+0 vNOVR, 00
   Gui, Add, Button, ys gCheck, New Check
   ; Gui, Add, Listview, xm w500 r10 Grid cWhite hwndHLV vVLV, Col 1|Col 2|Col 3|Icon ; add -LV0x20 on Win XP
   Gui, Add, Listview, xm w500 r10   hwndHLV vVLV, Col 1|Col 2|Col 3|Icon ; add -LV0x20 on Win XP
   ; LV_SetImageList(HIML)
	LV_SetImageList(hIml,1) ; list mode (default)
   Loop, %Rows% {
      Zeroes := SubStr("000", 1, 3 - StrLen(A_Index))
	  if Mod(A_Index, 2)
      LV_Add("Icon0", "A" . Zeroes . A_Index, "B" . Zeroes . A_Index, "C" . Zeroes . A_Index)
	  else
      LV_Add("Icon0", "A" . Zeroes . A_Index, "B" . Zeroes . A_Index, "C" . Zeroes . A_Index)
   }
   Loop, %Rows%   ; put a random icon into column 4
      ; LV_EX_SetSubitemImage(HLV, A_Index, 4, Mod(A_Index, 4) + 1)
	  if Mod(A_Index, 2)
		LV_EX_SetSubitemImage(HLV, A_Index, 1, Mod(A_Index, 4) + 1)
   Columns := LV_GetCount("Column")
   Loop, % Columns
      LV_ModifyCol(A_Index, "AutoHdr")
   ; Random, Index, 1, % BkgImages.MaxIndex()
   ; LV_EX_SetBkImage(HLV, BkgImages[Index])
   ; GoSub, Check
   Gui, Show, , LV_EX sample
Return
; ----------------------------------------------------------------------------------------------------------------------
Order123:
   GuiControl, -ReDraw, %HLV%
   ColArr := []
   Loop, % LV_GetCount("Col")
      ColArr[A_Index] := A_Index
   LV_EX_SetColumnOrder(HLV, ColArr)
   ColArr := LV_EX_GetColumnOrder(HLV)
   For Each, C In ColArr
      LV_ModifyCol(C, "AutoHdr")
   GuiControl, +ReDraw, %HLV%
Return
; ----------------------------------------------------------------------------------------------------------------------
Order321:
   GuiControl, -ReDraw, %HLV%
   ColArr := [3, 2, 1]
   Loop, % LV_GetCount("Col")
      If (A_Index > 3)
         ColArr[A_Index] := A_Index
   LV_EX_SetColumnOrder(HLV, ColArr)
   ColArr := LV_EX_GetColumnOrder(HLV)
   For Each, C In ColArr
      LV_ModifyCol(C, "AutoHdr")
   GuiControl, +ReDraw, %HLV%
Return
; ----------------------------------------------------------------------------------------------------------------------
Check:
   GuiControl, , FVR,  % LV_EX_GetTopIndex(HLV)
   GuiControl, , IRV,  % LV_EX_IsRowVisible(HLV, 20)
   GuiControl, , NOVR, % LV_EX_GetRowsPerPage(HLV)
Return
; ----------------------------------------------------------------------------------------------------------------------
NewImage:
   GuiControl, -ReDraw, %HLV%
   Random, Index, 1, % BkgImages.MaxIndex()
   LV_EX_SetBkImage(HLV, BkgImages[Index])
   GuiControl, +ReDraw, %HLV%
   GuiControl, Focus, %HLV%
Return
; ----------------------------------------------------------------------------------------------------------------------
RemoveImage:
   GuiControl, -ReDraw, %HLV%
   LV_EX_SetBkImage(HLV, "")
   GuiControl, +ReDraw, %HLV%
   GuiControl, Focus, %HLV%
Return
; ----------------------------------------------------------------------------------------------------------------------
GuiClose:
ExitApp

/*
#include %A_ScriptDir%\..\..\QuickClipboardEditor\Lib\Gdip_all.ahk
; #Include Lib\LV_EX.ahk

Gdip_Startup()
#Singleinstance, force 

	ILC_COLOR32 := 0x20 
	ILC_ORIGINALSIZE := 0x00010000
	dir := A_ScriptDir . "\Bmp"
	isizew := 128
	isizeh := 128
	hIml := ImageList_Create(isizew, isizeh, ILC_COLOR32|ILC_ORIGINALSIZE, 100, 100) 
	;==============================================================
	Gui, Add, ListView, w600 h600 HWNDhLV grid, icon&A_Index|w|h
	LV_SetImageList(hIml,1) ; list mode (default)
	;==============================================================
	;Gui, Add, ListView, w600 h600 HWNDhLV icon, icon&A_Index|w|h
	;LV_SetImageList(hIml,0) ; icon mode
	;==============================================================
	Gui, Show, autosize 
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
return 
*/

ListView_SetImageList( hwnd, hIml, iImageList=0) { 
   SendMessage, 0x1000+3, iImageList, hIml, , ahk_id %hwnd% 
   return ErrorLevel 
} 

ImageList_Create(cx,cy,flags,cInitial,cGrow){
   return DllCall("comctl32.dll\ImageList_Create", "int", cx, "int", cy, "uint", flags, "int", cInitial, "int", cGrow) 
} 

ImageList_Add(hIml, hbmImage, hbmMask=""){ 
   return DllCall("comctl32.dll\ImageList_Add", "uint", hIml, "uint",hbmImage, "uint", hbmMask) 
} 

ImageList_AddIcon(hIml, hIcon) { 
   return DllCall("comctl32.dll\ImageList_ReplaceIcon", "uint", hIml, "int", -1, "uint", hIcon) 
} 

API_ExtractIcon(Icon, Idx=0){ 
   return DllCall("shell32\ExtractIconA", "UInt", 0, "Str", Icon, "UInt",Idx) 
} 


API_LoadImage(pPath, uType, cxDesired, cyDesired, fuLoad) {
   return,  DllCall( "LoadImage", "uint", 0, "str", pPath, "uint", uType, "int", cxDesired, "int", cyDesired, "uint", fuLoad) 
}

LoadIcon(Filename, IconNumber, IconSize) {
   DllCall("PrivateExtractIcons"
          ,"str",Filename,"int",IconNumber-1,"int",IconSize,"int",IconSize
            ,"uint*",h_icon,"uint*",0,"uint",1,"uint",0,"int")
   if !ErrorLevel
         return h_icon
}

Gdip_GetImageDimensionsFile(file, ByRef Width, ByRef Height){
	pBitmap  := Gdip_CreateBitmapFromFile(file)
	Gdip_GetImageDimensions(pBitmap,Width,Height)
	Gdip_DisposeImage(pBitmap)
}

map(x, in_min, in_max, out_min, out_max) {
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
}
