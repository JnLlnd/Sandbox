#NoEnv
#SingleInstance, force

#Include %A_ScriptDir%\Lib\WinClipAPI.ahk
#Include %A_ScriptDir%\Lib\WinClip.ahk
#Include %A_ScriptDir%\Lib\Class_RichEdit.ahk

Gui, +ReSize +MinSize +hwndGuiID
If !IsObject(objRichEdit := New RichEdit(1, "w400 r10 gMessageHandler")) {
   MsgBox, 16, Error, %ErrorLevel%
   ExitApp
}

for nFmt, params in % WinClip.GetFormats()
{
  list .= "`n" nFmt " : " params.name " : " params.size " : " params.GetCapacity( "buffer" )
}
###_D(list)
###_V("HasFormat", WinClip.HasFormat(49267)) ; 13 for "CF_UNICODETEXT, 49267 Rich Text Format, 49366 HTML Format

intSize := WinClip.Snap(objData)
###_V("Snap", intSize, objData)

###_V("GetHTML", WinClip.GetHtml())
; objRichEdit.SetText(WinClip.GetHtml())


###_V("Clipboard", Clipboard)
objRichEdit.Paste()


Gui, Add, Button, Default, Close
GuiControl, Focus, Close
Gui, Show

; ###_V("GetRTF", objRichEdit.GetRTF)

return

;-----------------------

ButtonClose:
Gui, Destroy
return


MessageHandler:
; ###_V("A_GuiEvent", A_GuiEvent)
return

