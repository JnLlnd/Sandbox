#requires AutoHotkey v1.1
#SingleInstance force

#include %A_ScriptDir%\Lib\Scintilla.ahk
#Include %A_ScriptDir%\Lib\ControlColor.ahk

Gosub, InitScintilla

Gui 1:New, hWndMyGui
global o_Sci := New Scintilla(MyGui, 10, 10, 900, 700)
Gui Show, w920 h720

Gosub, OkStuff
Gosub, SetTestText

; Testing stuff

; Multiple selection
o_Sci.SETMULTIPLESELECTION(true) ; SCI_SETMULTIPLESELECTION(bool multipleSelection)
o_Sci.SETADDITIONALSELECTIONTYPING(true) ; SCI_SETADDITIONALSELECTIONTYPING(bool additionalSelectionTyping)
o_Sci.SETMULTIPASTE(1) ; SCI_SETMULTIPASTE(int multiPaste); SC_MULTIPASTE_EACH=1
o_Sci.SETVIRTUALSPACEOPTIONS(1) ; SCI_SETVIRTUALSPACEOPTIONS(int virtualSpaceOptions); SCVS_RECTANGULARSELECTION=1

o_Sci.SETSEL(0, 0)

global g_oXMLFileTypes := Object()
global g_oFileExts := Object()
global g_oLexTypes := Object()
global g_oColors := Object()
global g_oKeywords := Object()
global g_SyntaxHighlighting

; Scintilla theme
; g_ThemeNameEx := "Shenanigans"
g_ThemeNameEx := "Monokai"
; If (!LoadTheme(g_ThemeFile, g_ThemeName)) {
    LoadTheme(g_ThemeFile := A_ScriptDir . "\Themes\Themes.xml", "Shenanigans")
; }

LoadFileTypes() ; From FileTypes.xml
o_Sci.Type := g_oFileExts["ahk"].Type
o_Sci.SetLexer(GetLexerByLexType(o_Sci.Type))
LoadLexerData(o_Sci.Type, g_ThemeNameEx)
SetKeywords(n, o_Sci.Type)
g_SyntaxHighlighting := 1
ApplyTheme(n, o_Sci.Type)

return

LoadFileTypes() {
    Local oFileExts, oFileExt, Ext, Type, Desc, oFileTypes, Id, Name, Lexer, DN

    If (!LoadXMLEx(g_oXMLFileTypes, A_ScriptDir . "\Settings\FileTypes.xml")) {
        Return
    }

    oFileExts := g_oXMLFileTypes.selectNodes("/ftypes/extensions/ext")
    For oFileExt in oFileExts {
        Ext  := oFileExt.getAttribute("id")
        Type := oFileExt.getAttribute("type")
        Desc := oFileExt.getAttribute("desc")

        g_oFileExts[Ext] := {}
        g_oFileExts[Ext].Type := Type
        g_oFileExts[Ext].Desc := Desc
    }

    oFileTypes := g_oXMLFileTypes.selectNodes("/ftypes/types/type")
    For oFileType in oFileTypes {
        Id    := oFileType.getAttribute("id")
        Name  := oFileType.getAttribute("name")
        DN    := oFileType.getAttribute("dn")
        Lexer := oFileType.getAttribute("lexer")
        Ext   := oFileType.getAttribute("ext")

        ; Lexer subtype
        g_oLexTypes[Id] := {}
        g_oLexTypes[Id].Name := Name ; Base filename
        g_oLexTypes[Id].DN := DN
        g_oLexTypes[Id].Lexer := Lexer
        g_oLexTypes[Id].Ext := Ext

        g_oColors[Id] := {}
        ;g_oColors[Id].Lexer := Lexer
        g_oColors[Id].Loaded := False ; Set in LoadLexerData
    }
}

LoadXMLEx(ByRef oXML, Fullpath) {
    oXML := ComObjCreate("MSXML2.DOMDocument.6.0")
    oXML.async := False

    If (!oXML.load(Fullpath)) {
        MsgBox 0x10, Error, % "Failed to load XML file."
        . "`n`nFilename: """ . Fullpath . """"
        . "`n`nError: " . Format("0x{:X}", oXML.parseError.errorCode & 0xFFFFFFFF)
        . "`n`nReason: " . oXML.parseError.reason
        Return 0
    }

    Return 1
}

; Load specific language styles, keywords and properties
LoadLexerData(Type, ThemeNameEx := "Default") {
    Local BaseName, ThemeFile, oXML, oStyles, oStyle, oKWGroups, oKWGroup, nGroup, oProps, oProp, Name, Value

    BaseName := GetNameByLexType(Type)
    If (g_oColors[Type].Loaded || BaseName == "") {
        Return 0
    }

    ThemeFile := A_ScriptDir . "\Themes\Specifics\" . BaseName . ".xml"
    If (!IsObject(oXML := LoadXML(ThemeFile))) {
        Return 0
    }

    ; Styles
    oStyles := oXML.selectNodes("/scheme/theme[@name='" . ThemeNameEx . "']/style")
    If (oStyles.length()) {
        g_oColors[Type].Values := []

        For oStyle in oStyles {
            LoadThemeStyles(Type, oStyle)
        }
    }

    g_oColors[Type].Loaded := True

    ; Keywords
    oKWGroups := oXML.selectNodes("/scheme/keywords/language[@id='" . Type . "']/group")
    If (oKWGroups.length()) {
        g_oKeywords[Type] := {}
        For oKWGroup in oKWGroups {
            nGroup := oKWGroup.getAttribute("id")
            g_oKeywords[Type][nGroup] := oKWGroup.getAttribute("keywords")
        }
    }

    ; Properties
    oProps := oXML.selectNodes("/scheme/properties/property")
    If (oProps.length()) {
        g_oProps[Type] := {}
        For oProp in oProps {
            Name := oProp.getAttribute("name")
            Value := oProp.getAttribute("value")
            g_oProps[Type][Name] := Value
        }
    }

    Return 1
}


LoadXML(Fullpath) {
    Local x := ComObjCreate("MSXML2.DOMDocument.6.0")
    x.async := False
    x.load(Fullpath)
    Return x
}


GetNameByLexType(Type) {
    Return g_oLexTypes[Type].Name
}

GetLexerByLexType(Type) {
    Local Lexer := g_oLexTypes[Type].Lexer
    Return Lexer != "" ? Lexer : 1
}

SetKeywords(n, Type) {
    If (g_oKeywords.HasKey(Type)) {
        For GrpType, Keywords in g_oKeywords[Type] {
            o_Sci.SetKeywords(GrpType, Keywords, 1)
        }
    }
}

LoadThemeStyles(Type, Node) {
    Local v, fc, bc

    v := Node.getAttribute("v")
    If (!v) {
        Return
    }

    g_oColors[Type][v] := {}
    g_oColors[Type].Values.Push(v)

    fc := Node.getAttribute("fc")
    If (fc != "") {
        fc := CvtClr(fc)
        g_oColors[Type][v].FC := fc
    }

    bc := Node.getAttribute("bc")
    If (bc != "") {
        bc := CvtClr(bc)
        g_oColors[Type][v].BC := bc
    }

    g_oColors[Type][v].Bold := Node.getAttribute("b")
    g_oColors[Type][v].Italic := Node.getAttribute("i")
    g_oColors[Type][v].Under := Node.getAttribute("u")
}

; Global styles
LoadTheme(ThemeFile, ThemeName) {
    Local oXML, Node

    If (!LoadXMLEx(oXML, ThemeFile)) {
        Return 0
    }

    Node := oXML.selectSingleNode("/themes/theme[@name='" . ThemeName . "']")

    g_oColors["Default"] := {}
    g_oColors["Default"].FC := GetThemeColor(Node, "default", "fc")
    g_oColors["Default"].BC := GetThemeColor(Node, "default", "bc")

    If (g_oColors["Default"].FC == g_oColors["Default"].BC) {
        g_ThemeNameEx := "Default"
        Return 0 ; LoadTheme will be called again with "Shenanigans" as theme.
    }

    g_oColors["Caret"] := {}
    g_oColors["Caret"].FC := GetThemeColor(Node, "caret", "fc")

    g_oColors["Selection"] := {}
    g_oColors["Selection"].FC := GetThemeColor(Node, "selection", "fc")
    g_oColors["Selection"].BC := GetThemeColor(Node, "selection", "bc")
    g_oColors["Selection"].Alpha := GetThemeValue(Node, "selection", "a")

    g_oColors["NumbersMargin"] := {}
    g_oColors["NumbersMargin"].FC := GetThemeColor(Node, "numbersmargin", "fc")
    g_oColors["NumbersMargin"].BC := GetThemeColor(Node, "numbersmargin", "bc")

    g_oColors["SymbolMargin"] := {}
    g_oColors["SymbolMargin"].BC := GetThemeColor(Node, "symbolmargin", "bc")

    g_oColors["Divider"] := {}
    g_oColors["Divider"].BC := GetThemeColor(Node, "divider", "bc")
    g_oColors["Divider"].Width := GetThemeValue(Node, "divider", "w")

    g_oColors["FoldMargin"] := {}
    g_oColors["FoldMargin"].DLC := GetThemeColor(Node, "foldmargin", "dlc") ; Drawing lines
    g_oColors["FoldMargin"].BBC := GetThemeColor(Node, "foldmargin", "bbc") ; Button background
    g_oColors["FoldMargin"].MBC := GetThemeColor(Node, "foldmargin", "mbc") ; Margin background

    g_oColors["ActiveLine"] := {}
    g_oColors["ActiveLine"].BC := GetThemeColor(Node, "activeline", "bc")

    g_oColors["BraceMatch"] := {}
    g_oColors["BraceMatch"].FC := GetThemeColor(Node, "bracematch", "fc")
    g_oColors["BraceMatch"].Bold := GetThemeValue(Node, "bracematch", "b")
    g_oColors["BraceMatch"].Italic := GetThemeValue(Node, "bracematch", "i")

    g_oColors["MarkedText"] := {}
    g_oColors["MarkedText"].Type := GetThemeValue(Node, "markers", "t")
    g_oColors["MarkedText"].Color := GetThemeColor(Node, "markers", "c")
    g_oColors["MarkedText"].Alpha := GetThemeValue(Node, "markers", "a")
    g_oColors["MarkedText"].OutlineAlpha := GetThemeValue(Node, "markers", "oa")

    g_oColors["IdenticalText"] := {}
    g_oColors["IdenticalText"].Type := GetThemeValue(Node, "highlights", "t")
    g_oColors["IdenticalText"].Color := GetThemeColor(Node, "highlights", "c")
    g_oColors["IdenticalText"].Alpha := GetThemeValue(Node, "highlights", "a")
    g_oColors["IdenticalText"].OutlineAlpha := GetThemeValue(Node, "highlights", "oa")

    g_oColors["Calltip"] := {}
    g_oColors["Calltip"].FC := GetThemeColor(Node, "calltip", "fc")
    g_oColors["Calltip"].BC := GetThemeColor(Node, "calltip", "bc")

    g_oColors["IndentGuide"] := {}
    g_oColors["IndentGuide"].FC := GetThemeColor(Node, "indentguide", "fc")
    g_oColors["IndentGuide"].BC := GetThemeColor(Node, "indentguide", "bc")

    g_oColors["WhiteSpace"] := {}
    g_oColors["WhiteSpace"].FC := GetThemeColor(Node, "whitespace", "fc")
    g_oColors["WhiteSpace"].BC := GetThemeColor(Node, "whitespace", "bc")

    Return 1
}

GetThemeColor(BaseNode, Node, Attrib) {
    Local Value := BaseNode.selectSingleNode(Node).getAttribute(Attrib)
    Return Value ? CvtClr(Value) : Value
}

GetThemeValue(BaseNode, Node, Attrib) {
    Return BaseNode.selectSingleNode(Node).getAttribute(Attrib)
}

ApplyTheme(n, Type := "") {
    Local v, fc, bc, Italic, Bold, Under, SelAlpha

    ; Default color for text and background
    o_Sci.StyleSetFore(STYLE_DEFAULT, g_oColors["Default"].FC)
    o_Sci.StyleSetBack(STYLE_DEFAULT, g_oColors["Default"].BC)
    o_Sci.StyleClearAll() ; This message sets all styles to have the same attributes as STYLE_DEFAULT.

    ; Caret
    o_Sci.SetCaretFore(g_oColors["Caret"].FC)

    ; Selection
    o_Sci.SetSelFore(1, g_oColors["Selection"].FC)
    o_Sci.SetSelBack(1, g_oColors["Selection"].BC)
    SelAlpha := g_oColors["Selection"].Alpha
    If (SelAlpha != "") {
        o_Sci.SetSelAlpha(SelAlpha)
    }

    ; Margins
    ; Line numbers
    o_Sci.StyleSetFore(33, g_oColors["NumbersMargin"].FC)
    o_Sci.StyleSetBack(33, g_oColors["NumbersMargin"].BC)
    ; Symbol margin and divider
    o_Sci.SetMarginBackN(g_MarginSymbols, g_oColors["SymbolMargin"].BC)
    o_Sci.SetMarginBackN(g_MarginDivider, g_oColors["Divider"].BC)
    o_Sci.SetMarginWidthN(g_MarginDivider, g_oColors["Divider"].Width)

    ; Active line background color
    o_Sci.SetCaretLineBack(g_oColors["ActiveLine"].BC)
    o_Sci.SetCaretLineVisible(g_HighlightActiveLine)
    o_Sci.SetCaretLineVisibleAlways(g_HighlightActiveLine)

    ; Matching braces
    o_Sci.StyleSetBack(STYLE_BRACELIGHT, g_oColors["ActiveLine"].BC)
    o_Sci.StyleSetFore(STYLE_BRACELIGHT, g_oColors["BraceMatch"].FC)
    If (g_oColors["BraceMatch"].Bold) {
        o_Sci.StyleSetBold(STYLE_BRACELIGHT, True)
    }
    If (g_oColors["BraceMatch"].Italic) {
        o_Sci.StyleSetItalic(STYLE_BRACELIGHT, True)
    }

    ; Calltips
    o_Sci.CalltipSetFore(g_oColors["Calltip"].FC)
    o_Sci.CalltipSetBack(g_oColors["Calltip"].BC)

    ; Indentation guides
    o_Sci.StyleSetFore(37, g_oColors["IndentGuide"].FC)
    o_Sci.StyleSetBack(37, g_oColors["IndentGuide"].BC)

    ; Language specifics
    Loop % (g_SyntaxHighlighting * g_oColors[Type].Values.Length()) {
        v := g_oColors[Type].Values[A_Index]

        fc := g_oColors[Type][v].FC
        If (fc != "") {
            o_Sci.StyleSetFore(v, fc)
        }

        bc := g_oColors[Type][v].BC
        If (bc != "") {
            o_Sci.StyleSetBack(v, bc)
        }

        If (Italic := g_oColors[Type][v].Italic) {
            o_Sci.StyleSetItalic(v, Italic)
        }

        If (Bold := g_oColors[Type][v].Bold) {
            o_Sci.StyleSetBold(v, Bold)
        }

        If (Under := g_oColors[Type][v].Under) {
            o_Sci.StyleSetUnderline(v, Under)
        }
    }
}

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
    Local W := g_oColors["Divider"].Width
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

    BaseName := g_oLexTypes[Type].Name
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

return
;-----------------------------------------

;-----------------------------------------
SetTestText:
;-----------------------------------------

str =
(
for int, item in obj
	if (a = b)
		ExitApp
)

o_Sci.SETTEXT("", str, 1)

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

