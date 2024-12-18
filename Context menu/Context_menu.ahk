#requires AutoHotkey v1.1
#SingleInstance,Force
#NoEnv

global strEditorControlHwnd ; editor control ID

Gui, New, , Test
Gui, Font, s14, Courier New
Gui, Add, Edit, vf_strEditor w400 h400 +hwndstrEditorControlHwnd
Gui, Show

Gosub, BuildEditorContextMenu

return

;------------------------------------------------------------
BuildEditorContextMenu:
;------------------------------------------------------------

; OnMessage to intercept Context menu in Edit control
; from Malcev (https://www.autohotkey.com/board/topic/116431-trying-to-replace-edit-box-context-menu/#entry732693)
OnMessage(0x204, "WM_RBUTTONDOWN")
OnMessage(0x205, "WM_RBUTTONUP")

Menu, menuEditorContextMenu, Add, Undo, EditorContextMenuActions
Menu, menuEditorContextMenu, Add
Menu, menuEditorContextMenu, Add, Cut, EditorContextMenuActions
Menu, menuEditorContextMenu, Add, Copy, EditorContextMenuActions
Menu, menuEditorContextMenu, Add, Paste, EditorContextMenuActions
Menu, menuEditorContextMenu, Add, Delete, EditorContextMenuActions
Menu, menuEditorContextMenu, Add
Menu, menuEditorContextMenu, Add, SelectAll, EditorContextMenuActions


return
;------------------------------------------------------------


;------------------------------------------------------------
WM_RBUTTONDOWN()
; see OnMessage(0x204, "WM_RBUTTONDOWN")
;------------------------------------------------------------
{
    if (A_GuiControl = "f_strEditor")
       return 0
}
;------------------------------------------------------------


;------------------------------------------------------------
WM_RBUTTONUP()
; see OnMessage(0x205, "WM_RBUTTONUP")
;------------------------------------------------------------
{
    if (A_GuiControl = "f_strEditor")
	{
		GuiControl, Focus, f_strEditor ; give focus to control for EditorContextMenuActions
		
		; GuiControlGet, blnEnable, Enabled, f_btnGuiSaveEditor ; enable Undo item if Save button is enabled
		; Menu, menuEditorContextMenu, % (blnEnable ? "Enable" : "Disable"), Undo
		
		blnEnable := GetSelectedTextLenght(strEditorControlHwnd) ; enable Cut, Copy, Delete if text is selected in the control
		Menu, menuEditorContextMenu, % (blnEnable ? "Enable" : "Disable"), Cut
		Menu, menuEditorContextMenu, % (blnEnable ? "Enable" : "Disable"), Copy
		Menu, menuEditorContextMenu, % (blnEnable ? "Enable" : "Disable"), Delete
		
		Menu, menuEditorContextMenu, % (StrLen(Clipboard) ? "Enable" : "Disable"), Paste
        Menu, menuEditorContextMenu, Show
	}
}
;------------------------------------------------------------


;------------------------------------------------------------
GetSelectedTextLenght(strHwnd)
; from just me (https://www.autohotkey.com/boards/viewtopic.php?p=27857#p27857)
;------------------------------------------------------------
{
	intStart := 0
	intEnd := 0
	; EM_GETSEL = 0x00B0 -> msdn.microsoft.com/en-us/library/bb761598(v=vs.85).aspx
	DllCall("User32.dll\SendMessage", "Ptr", strHwnd, "UInt", 0x00B0, "UIntP", intStart, "UIntP", intEnd, "Ptr")
	return (intEnd - intStart)
}
;------------------------------------------------------------


;------------------------------------------------------------
EditorContextMenuActions:
;------------------------------------------------------------

if (A_ThisMenuItem = "Undo")
	Send, ^z
else if (A_ThisMenuItem = "Cut")
	Send, ^x
else if (A_ThisMenuItem = "Copy")
	Send, ^c
else if (A_ThisMenuItem = "Paste")
	Send, ^v
else if (A_ThisMenuItem = "Delete")
	Send, {Del}
else if (A_ThisMenuItem = "SelectAll")
	Send, ^a

return
;------------------------------------------------------------


