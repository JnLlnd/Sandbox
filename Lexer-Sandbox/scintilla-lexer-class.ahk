#requires AutoHotkey v1.1
#SingleInstance force

#include %A_ScriptDir%\Lib\Scintilla.ahk
#Include %A_ScriptDir%\Lib\ControlColor.ahk
SetWorkingDir, %A_ScriptDir%

Gosub, InitScintilla

Gui 1:New, hWndMyGui
global o_Sci := New Scintilla(MyGui, 10, 10, 900, 700)
Gui Show, w920 h720 x-1000

Gosub, OkStuff

; Testing stuff

; make option with these global variables
global g_blnSyntaxHighlighting := 1
global g_blnHighlightActiveLine := 1
global g_strThemeName := "Light" ; or "Dark"
global g_strSyntaxTypeName := "TXT"

if (g_blnSyntaxHighlighting)
	o_Lex := new Lexer()

Gosub, SetTestTextTXT
; o_Lex.SetLexerType(g_strSyntaxTypeName)
Sleep, 2000

Gosub, SetTestTextAHK
g_strSyntaxTypeName := "AHK" ; make it an option
o_Lex.SetLexerType(g_strSyntaxTypeName)
Sleep, 2000

Gosub, SetTestTextHTML
g_strSyntaxTypeName := "HTML" ; make it an option
o_Lex.SetLexerType(g_strSyntaxTypeName)
Sleep, 2000

return


;-------------------------------------------------------------
class Lexer
; based on Adventure IDE 3.0.4 developed by Alguimist (Gilberto Barbosa Babiretzki)
; Source: https://sourceforge.net/projects/autogui/
; Forum: https://www.autohotkey.com/boards/viewforum.php?f=64
;-------------------------------------------------------------
{
	aaXMLFileTypes := Object() ; file types
	aaLexTypes := Object() ; lexer types
	aaColors := Object()
	
	;---------------------------------------------------------
	__New()
	;---------------------------------------------------------
	{
		this.LoadFileTypes()
		this.LoadTheme()
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	SetLexerType(strType)
	;---------------------------------------------------------
	{
		o_Sci.Type := strType
		o_Sci.SetLexer(this.GetLexerByLexType(strType))
		this.LoadLexerData(strType, g_strThemeName)
		this.SetKeywords(strType)
		this.ApplyTheme(strType)
	}
	;---------------------------------------------------------
	
	;---------------------------------------------------------
	LoadFileTypes()
	;---------------------------------------------------------
	{
		If (!LoadXMLEx(oXMLFileTypes, A_ScriptDir . "\Settings\FileTypes.xml"))
			Return

		oFileExts := oXMLFileTypes.selectNodes("/ftypes/extensions/ext")
		For oFileExt in oFileExts
		{
			Ext  := oFileExt.getAttribute("id")
			Type := oFileExt.getAttribute("type")
			Desc := oFileExt.getAttribute("desc")

			this.aaXMLFileTypes[Ext] := {}
			this.aaXMLFileTypes[Ext].Type := Type
			this.aaXMLFileTypes[Ext].Desc := Desc
		}

		oFileTypes := oXMLFileTypes.selectNodes("/ftypes/types/type")
		For oFileType in oFileTypes
		{
			Id    := oFileType.getAttribute("id")
			Name  := oFileType.getAttribute("name")
			DN    := oFileType.getAttribute("dn")
			Lexer := oFileType.getAttribute("lexer")
			Ext   := oFileType.getAttribute("ext")

			; Lexer subtype
			this.aaLexTypes[Id] := {}
			this.aaLexTypes[Id].Name := Name ; Base filename
			this.aaLexTypes[Id].DN := DN
			this.aaLexTypes[Id].Lexer := Lexer
			this.aaLexTypes[Id].Ext := Ext

			this.aaColors[Id] := {}
			;this.aaColors[Id].Lexer := Lexer
			this.aaColors[Id].Loaded := False ; Set in LoadLexerData
		}
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	LoadTheme()
	;---------------------------------------------------------
	{
		If (!LoadXMLEx(oXML, A_WorkingDir . "\Themes\Themes-QCE.xml"))
			Return 0

		Node := oXML.selectSingleNode("/themes/theme[@name='" . g_strThemeName . "']")

		this.aaColors["Default"] := {}
		this.aaColors["Default"].FC := this.GetThemeColor(Node, "default", "fc")
		this.aaColors["Default"].BC := this.GetThemeColor(Node, "default", "bc")

		this.aaColors["Caret"] := {}
		this.aaColors["Caret"].FC := this.GetThemeColor(Node, "caret", "fc")

		this.aaColors["Selection"] := {}
		this.aaColors["Selection"].FC := this.GetThemeColor(Node, "selection", "fc")
		this.aaColors["Selection"].BC := this.GetThemeColor(Node, "selection", "bc")
		this.aaColors["Selection"].Alpha := this.GetThemeValue(Node, "selection", "a")

		this.aaColors["NumbersMargin"] := {}
		this.aaColors["NumbersMargin"].FC := this.GetThemeColor(Node, "numbersmargin", "fc")
		this.aaColors["NumbersMargin"].BC := this.GetThemeColor(Node, "numbersmargin", "bc")

		this.aaColors["SymbolMargin"] := {}
		this.aaColors["SymbolMargin"].BC := this.GetThemeColor(Node, "symbolmargin", "bc")

		this.aaColors["Divider"] := {}
		this.aaColors["Divider"].BC := this.GetThemeColor(Node, "divider", "bc")
		this.aaColors["Divider"].Width := this.GetThemeValue(Node, "divider", "w")

		this.aaColors["FoldMargin"] := {}
		this.aaColors["FoldMargin"].DLC := this.GetThemeColor(Node, "foldmargin", "dlc") ; Drawing lines
		this.aaColors["FoldMargin"].BBC := this.GetThemeColor(Node, "foldmargin", "bbc") ; Button background
		this.aaColors["FoldMargin"].MBC := this.GetThemeColor(Node, "foldmargin", "mbc") ; Margin background

		this.aaColors["ActiveLine"] := {}
		this.aaColors["ActiveLine"].BC := this.GetThemeColor(Node, "activeline", "bc")

		this.aaColors["BraceMatch"] := {}
		this.aaColors["BraceMatch"].FC := this.GetThemeColor(Node, "bracematch", "fc")
		this.aaColors["BraceMatch"].Bold := this.GetThemeValue(Node, "bracematch", "b")
		this.aaColors["BraceMatch"].Italic := this.GetThemeValue(Node, "bracematch", "i")

		this.aaColors["MarkedText"] := {}
		this.aaColors["MarkedText"].Type := this.GetThemeValue(Node, "markers", "t")
		this.aaColors["MarkedText"].Color := this.GetThemeColor(Node, "markers", "c")
		this.aaColors["MarkedText"].Alpha := this.GetThemeValue(Node, "markers", "a")
		this.aaColors["MarkedText"].OutlineAlpha := this.GetThemeValue(Node, "markers", "oa")

		this.aaColors["IdenticalText"] := {}
		this.aaColors["IdenticalText"].Type := this.GetThemeValue(Node, "highlights", "t")
		this.aaColors["IdenticalText"].Color := this.GetThemeColor(Node, "highlights", "c")
		this.aaColors["IdenticalText"].Alpha := this.GetThemeValue(Node, "highlights", "a")
		this.aaColors["IdenticalText"].OutlineAlpha := this.GetThemeValue(Node, "highlights", "oa")

		this.aaColors["Calltip"] := {}
		this.aaColors["Calltip"].FC := this.GetThemeColor(Node, "calltip", "fc")
		this.aaColors["Calltip"].BC := this.GetThemeColor(Node, "calltip", "bc")

		this.aaColors["IndentGuide"] := {}
		this.aaColors["IndentGuide"].FC := this.GetThemeColor(Node, "indentguide", "fc")
		this.aaColors["IndentGuide"].BC := this.GetThemeColor(Node, "indentguide", "bc")

		this.aaColors["WhiteSpace"] := {}
		this.aaColors["WhiteSpace"].FC := this.GetThemeColor(Node, "whitespace", "fc")
		this.aaColors["WhiteSpace"].BC := this.GetThemeColor(Node, "whitespace", "bc")
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	GetThemeColor(BaseNode, Node, Attrib)
	;---------------------------------------------------------
	{
		Local Value := BaseNode.selectSingleNode(Node).getAttribute(Attrib)
		Return Value ? CvtClr(Value) : Value
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	GetThemeValue(BaseNode, Node, Attrib)
	;---------------------------------------------------------
	{
		Return BaseNode.selectSingleNode(Node).getAttribute(Attrib)
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	LoadLexerData(Type, ThemeNameEx := "Default")
	; Load specific language styles, keywords and properties
	;---------------------------------------------------------
	{
		BaseName := this.GetNameByLexType(Type)
		If (this.aaColors[Type].Loaded || BaseName == "")
			Return 0

		ThemeFile := A_ScriptDir . "\Themes\Specifics\" . BaseName . ".xml"
		LoadXMLEx(oXML, ThemeFile)
		If !IsObject(oXML)
			Return 0

		; Styles
		oStyles := oXML.selectNodes("/scheme/theme[@name='" . ThemeNameEx . "']/style")
		If (oStyles.length())
		{
			this.aaColors[Type].Values := []

			For oStyle in oStyles
				this.LoadThemeStyles(Type, oStyle)
		}

		this.aaColors[Type].Loaded := True

		; Keywords
		oKWGroups := oXML.selectNodes("/scheme/keywords/language[@id='" . Type . "']/group")
		If (oKWGroups.length())
		{
			this.aaKeywords[Type] := {}
			For oKWGroup in oKWGroups
			{
				nGroup := oKWGroup.getAttribute("id")
				this.aaKeywords[Type][nGroup] := oKWGroup.getAttribute("keywords")
			}
		}

		; Properties
		oProps := oXML.selectNodes("/scheme/properties/property")
		If (oProps.length())
		{
			g_oProps[Type] := {}
			For oProp in oProps
			{
				Name := oProp.getAttribute("name")
				Value := oProp.getAttribute("value")
				g_oProps[Type][Name] := Value
			}
		}

		return 1
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	LoadThemeStyles(Type, Node)
	;---------------------------------------------------------
	{
		Local v, fc, bc

		v := Node.getAttribute("v")
		If (!v)
			Return

		this.aaColors[Type][v] := {}
		this.aaColors[Type].Values.Push(v)

		fc := Node.getAttribute("fc")
		If (fc != "")
		{
			fc := CvtClr(fc)
			this.aaColors[Type][v].FC := fc
		}

		bc := Node.getAttribute("bc")
		If (bc != "")
		{
			bc := CvtClr(bc)
			this.aaColors[Type][v].BC := bc
		}

		this.aaColors[Type][v].Bold := Node.getAttribute("b")
		this.aaColors[Type][v].Italic := Node.getAttribute("i")
		this.aaColors[Type][v].Under := Node.getAttribute("u")
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	GetNameByLexType(Type)
	;---------------------------------------------------------
	{
		Return this.aaLexTypes[Type].Name ; Base filename
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	GetLexerByLexType(Type)
	; return the number associated to this type
	;---------------------------------------------------------
	{
		Local Lexer := this.aaLexTypes[Type].Lexer
		Return Lexer != "" ? Lexer : 1
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	SetKeywords(Type)
	;---------------------------------------------------------
	{
		If (this.aaKeywords.HasKey(Type))
			For GrpType, Keywords in this.aaKeywords[Type]
				o_Sci.SetKeywords(GrpType, Keywords, 1)
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	ApplyTheme(Type := "")
	;---------------------------------------------------------
	{
		Local v, fc, bc, Italic, Bold, Under, SelAlpha

		; Default color for text and background
		o_Sci.StyleSetFore(STYLE_DEFAULT, this.aaColors["Default"].FC)
		o_Sci.StyleSetBack(STYLE_DEFAULT, this.aaColors["Default"].BC)
		o_Sci.StyleClearAll() ; This message sets all styles to have the same attributes as STYLE_DEFAULT.

		; Caret
		o_Sci.SetCaretFore(this.aaColors["Caret"].FC)

		; Selection
		o_Sci.SetSelFore(1, this.aaColors["Selection"].FC)
		o_Sci.SetSelBack(1, this.aaColors["Selection"].BC)
		SelAlpha := this.aaColors["Selection"].Alpha
		If (SelAlpha != "")
			o_Sci.SetSelAlpha(SelAlpha)

		; Margins
		; Line numbers
		o_Sci.StyleSetFore(33, this.aaColors["NumbersMargin"].FC)
		o_Sci.StyleSetBack(33, this.aaColors["NumbersMargin"].BC)
		; Symbol margin and divider
		o_Sci.SetMarginBackN(g_MarginSymbols, this.aaColors["SymbolMargin"].BC)
		o_Sci.SetMarginBackN(g_MarginDivider, this.aaColors["Divider"].BC)
		o_Sci.SetMarginWidthN(g_MarginDivider, this.aaColors["Divider"].Width)

		; Active line background color
		o_Sci.SetCaretLineBack(this.aaColors["ActiveLine"].BC)
		o_Sci.SetCaretLineVisible(g_blnHighlightActiveLine)
		o_Sci.SetCaretLineVisibleAlways(g_blnHighlightActiveLine)

		; Matching braces
		o_Sci.StyleSetBack(STYLE_BRACELIGHT, this.aaColors["ActiveLine"].BC)
		o_Sci.StyleSetFore(STYLE_BRACELIGHT, this.aaColors["BraceMatch"].FC)
		If (this.aaColors["BraceMatch"].Bold)
			o_Sci.StyleSetBold(STYLE_BRACELIGHT, True)
		If (this.aaColors["BraceMatch"].Italic)
			o_Sci.StyleSetItalic(STYLE_BRACELIGHT, True)

		; Calltips
		o_Sci.CalltipSetFore(this.aaColors["Calltip"].FC)
		o_Sci.CalltipSetBack(this.aaColors["Calltip"].BC)

		; Indentation guides
		o_Sci.StyleSetFore(37, this.aaColors["IndentGuide"].FC)
		o_Sci.StyleSetBack(37, this.aaColors["IndentGuide"].BC)

		; Language specifics
		Loop % (g_blnSyntaxHighlighting * this.aaColors[Type].Values.Length())
		{
			v := this.aaColors[Type].Values[A_Index]

			fc := this.aaColors[Type][v].FC
			If (fc != "")
				o_Sci.StyleSetFore(v, fc)

			bc := this.aaColors[Type][v].BC
			If (bc != "")
				o_Sci.StyleSetBack(v, bc)

			If (Italic := this.aaColors[Type][v].Italic)
				o_Sci.StyleSetItalic(v, Italic)

			If (Bold := this.aaColors[Type][v].Bold)
				o_Sci.StyleSetBold(v, Bold)

			If (Under := this.aaColors[Type][v].Under)
				o_Sci.StyleSetUnderline(v, Under)
		}
	}
	;---------------------------------------------------------

}
;-------------------------------------------------------------

;-------------------------------------------------------------
LoadXMLEx(ByRef oXML, Fullpath)
;-------------------------------------------------------------
{
    oXML := ComObjCreate("MSXML2.DOMDocument.6.0")
    oXML.async := False

    If (!oXML.load(Fullpath))
	{
        MsgBox 0x10, Error, % "Failed to load XML file!"
        . "`n`nFilename: """ . Fullpath . """"
        . "`n`nError: " . Format("0x{:X}", oXML.parseError.errorCode & 0xFFFFFFFF)
        . "`n`nReason: " . oXML.parseError.reason
        Return 0
    }

    Return 1
}
;-------------------------------------------------------------



/*
UNUSED FROM EDITOR.AHK

; Specific properties of Scintilla lexers
; SetLexerProperties
SetProperties(n, Type) {
    Local Name, Value
    For Name, Value in g_oProps[Type] {
        o_Sci.SetProperty(Name, Value, 1, 1)
    }
}

SetLineNumberWidth(n) {
    Local LineCount, LineCountLen, String, PixelWidth

    If (g_LineNumbers) {
        LineCount := o_Sci.GetLineCount()
        LineCountLen := StrLen(LineCount)
        If (LineCountLen < 2) {
            LineCountLen := 2
        }

        If (LineCountLen != o_Sci.MarginLen) {
            o_Sci.MarginLen := LineCountLen

            If (LineCount < 100) {
                String := "99"
            } Else {
                String := ""
                LineCountLen := StrLen(LineCount)
                Loop %LineCountLen% {
                    String .= "9"
                }
            }

            PixelWidth := o_Sci.TextWidth(STYLE_LINENUMBER, "" . String, 1) + 8
            o_Sci.SetMarginWidthN(g_MarginNumbers, PixelWidth)
        }
    } Else {
        o_Sci.SetMarginWidthN(g_MarginNumbers, 0)
        o_Sci.MarginLen := 0
    }
}

DefineMarkers(n) {
    Static XPMLoaded := 0, PixmapBreakpoint, PixmapBookmark, PixmapError

    If (!XPMLoaded) {
        FileRead PixmapBreakpoint, %A_ScriptDir%\Icons\Breakpoint.xpm
        FileRead PixmapBookmark, %A_ScriptDir%\Icons\Handpoint3.xpm
        FileRead PixmapError, %A_ScriptDir%\Icons\Error.xpm
        XPMLoaded := 1
    }

    ; Bookmark marker
    o_Sci.MarkerDefine(g_MarkerBookmark, 25) ; 25 = SC_MARK_PIXMAP
    o_Sci.MarkerDefinePixmap(g_MarkerBookmark, "" . PixmapBookmark, 1)

    ; Breakpoint marker
    o_Sci.MarkerDefine(g_MarkerBreakpoint, 25)
    o_Sci.MarkerDefinePixmap(g_MarkerBreakpoint, "" . PixmapBreakpoint, 1)

    ; Debug step marker
    o_Sci.MarkerDefine(g_MarkerDebugStep, SC_MARK_SHORTARROW)
    o_Sci.MarkerSetBack(g_MarkerDebugStep, CvtClr(0xA2C93E))

    ; Error marker
    o_Sci.MarkerDefine(g_MarkerError, 25)
    o_Sci.MarkerDefinePixmap(g_MarkerError, "" . PixmapError, 1)
}

ShowSymbolMargin(bShow) {
    Loop % Sci.Length() {
        Sci[A_Index].SetMarginWidthN(g_MarginSymbols, bShow ? 16 : 0)
    }
}

ShowDivider(bShow) {
    Local W := this.aaColors["Divider"].Width
    Loop % Sci.Length() {
        If (bShow) {
            Sci[A_Index].SetMarginWidthN(g_MarginDivider, W)
            Sci[A_Index].SetMarginLeft(g_MarginDivider, 3) ; Left padding
        } Else {
            Sci[A_Index].SetMarginWidthN(g_MarginDivider, 0)
            Sci[A_Index].SetMarginLeft(g_MarginDivider, 2)
        }
    }
}

SetAutoComplete(n) {
    o_Sci.AutoCSetIgnoreCase(True)
    o_Sci.AutoCSetMaxHeight(g_AutoCMaxItems)
    o_Sci.AutoCSetOrder(1) ; SC_ORDER_PERFORMSORT
    o_Sci.AutoCSetSeparator(124) ; '|', so that items may contain spaces.
}

; Load autocomplete data
LoadAutoComplete(Type) {
    Local Keys, Key, Name, BaseName, oXML, List := ""

    BaseName := this.aaLexTypes[Type].Name
    If (BaseName == "") {
        Return 0
    }

    oXML := LoadXML(g_AutoCDir . "\" . BaseName . ".ac")
    If (!IsObject(oXML)) {
        Return 0
    }

    Keys := oXML.selectNodes("/AutoComplete/language[@id=""" . Type . """]/key")
    For Key in Keys {
        List .= Key.getAttribute("name") . "|"
    }

    g_oAutoC[Type] := {}
    g_oAutoC[Type].List := List
    g_oAutoC[Type].oXML := oXML
    g_oAutoC[Type].bLoaded := True

    Return (List != "")
}
*/


;-----------------------------------------
InitScintilla:
;-----------------------------------------

SciLexer := A_ScriptDir . "\Lib\" . (A_PtrSize == 8 ? "SciLexer64.dll" : "SciLexer32.dll")
If (!LoadSciLexer(SciLexer)) {
    MsgBox 0x10, %AppName% - Error
    , % "Failed to load library """ . SciLexer . """.`n`nThe program will exit."
    ExitApp
}

return
;-----------------------------------------

;-----------------------------------------
OkStuff:
;-----------------------------------------
o_Sci.SETCODEPAGE(65001)

; STYLE_DEFAULT := 32 set in Scintilla.ahk
o_Sci.STYLESETBACK(STYLE_DEFAULT, CvtClr(0xFFFFFF)) ; SCI_STYLESETBACK(int style, colour back) ; back white
o_Sci.STYLESETFORE(STYLE_DEFAULT, CvtClr(0x0000FF)) ; SCI_STYLESETFORE(int style, colour fore) ; text blue
o_Sci.STYLESETFONT(STYLE_DEFAULT, "Courier New", 1) ; SCI_STYLESETFONT(int style, const char *fontName) ; *** must be followed by third parameter 1 (why?)
o_Sci.STYLESETSIZE(STYLE_DEFAULT, 12) ; SCI_STYLESETSIZE(int style, int sizePoints)
o_Sci.STYLECLEARALL()

; STYLE_LINENUMBER:=33 ; line number margin style
o_Sci.SETMARGINWIDTHN(0, 20) ; set width of line number margin (adjust width vs number of lines in editor)
o_Sci.SETMARGINWIDTHN(1, 2) ; SCI_SETMARGINWIDTHN(int margin, int pixelWidth) ; Margin 1 (non-folding symbols), set width to 2 pixels for padding after line number (default is 16)
o_Sci.STYLESETFORE(STYLE_LINENUMBER, CvtClr(0x666666)) ; SCI_STYLESETFORE(int style, colour fore) ; text gray
o_Sci.STYLESETFONT(STYLE_LINENUMBER, "Courier New", 1) ; SCI_STYLESETFONT(int style, const char *fontName) ; *** must be followed by third parameter 1 (why?)
o_Sci.STYLESETSIZE(STYLE_LINENUMBER, 8) ; SCI_STYLESETSIZE(int style, int sizePoints) ; *** must be preceded by StyleSetFont command to work

o_Sci.SETWRAPMODE(0)
SCWS_INVISIBLE := 0
SCWS_VISIBLEALWAYS := 1
SCWS_VISIBLEAFTERINDENT := 2
SCWS_VISIBLEONLYININDENT := 3
o_Sci.SETVIEWWS(SCWS_INVISIBLE)
o_Sci.SETVIEWEOL(SCWS_INVISIBLE)
o_Sci.SETUSETABS(1)

o_Sci.CLEARTABSTOPS(0) ; SCI_CLEARTABSTOPS(line line)
o_Sci.SETTABWIDTH(4)
o_Sci.SETINDENTATIONGUIDES(1) ; SC_IV_NONE* = 0, SC_IV_REAL* = 1, SC_IV_LOOKFORWARD* = 2, SC_IV_LOOKBOTH* = 3
o_Sci.SETTABINDENTS(true) ; default true
o_Sci.SETBACKSPACEUNINDENTS(false) ; defaut false

; Multiple selection
o_Sci.SETMULTIPLESELECTION(true) ; SCI_SETMULTIPLESELECTION(bool multipleSelection)
o_Sci.SETADDITIONALSELECTIONTYPING(true) ; SCI_SETADDITIONALSELECTIONTYPING(bool additionalSelectionTyping)
o_Sci.SETMULTIPASTE(1) ; SCI_SETMULTIPASTE(int multiPaste); SC_MULTIPASTE_EACH=1
o_Sci.SETVIRTUALSPACEOPTIONS(1) ; SCI_SETVIRTUALSPACEOPTIONS(int virtualSpaceOptions); SCVS_RECTANGULARSELECTION=1

return
;-----------------------------------------

;-----------------------------------------
SetTestTextTXT:
;-----------------------------------------

str =
(
Selected
Not selected
)

o_Sci.SETTEXT("", str, 1)

o_Sci.SETSEL(0, 8)

str := ""

return
;-----------------------------------------

;-----------------------------------------
SetTestTextAHK:
;-----------------------------------------

str =
(
Selected
1 hotkey
2 enable
3 break
4 winactive
5 true
6 wheeldown
for int, item in obj
; This is a comment
	if (a = b)
		ExitApp
)

o_Sci.SETTEXT("", str, 1)

o_Sci.SETSEL(0, 8)

str := ""

return
;-----------------------------------------

;-----------------------------------------
SetTestTextHTML:
;-----------------------------------------

str =
(
Selected
<HTML>
<HEAD>
<TITLE>Title</TITLE>
</HEAD>
<BODY>
<H1>Title</H1>
Text<BR>
Test2<BR />
<P>Paragraph</P>
</BODY>
</HTML>
)

o_Sci.SETTEXT("", str, 1)

o_Sci.SETSEL(0, 8)

str := ""

return
;-----------------------------------------

;-----------------------------------------
CvtClr(Color)
; convert RGB to BGR
;-----------------------------------------
{
    Return (Color & 0xFF) << 16 | (Color & 0xFF00) | (Color >>16)
}
;-----------------------------------------

;-----------------------------------------
GuiClose:
;-----------------------------------------
ExitApp
;-----------------------------------------

