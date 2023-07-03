#SingleInstance Force

strFiles := "abc.docx|abc.xlsx|def.docx|docx.txt"
strWildcards := "*.docx|abc.*|*b*.*|*.*x*|???.*|?b?.*o*|*c.*|????.*"

loop, parse, strWildcards, |
{
	strWildCard := A_LoopField
	strResult .= strWildCard . "`n"
	loop, parse, strFiles, |
		strResult .= A_LoopField . " -> " . (RegExMatch(A_LoopField, Wildcards2RegEx(strWildcard)) ? "yes" : "no") . "`n"
	strResult .= "`n`n"
}
MsgBox, % strResult

return


;---------------------------------------------------------
Wildcards2RegEx(strDosWildcards)
;---------------------------------------------------------
{
	return "i)^\Q" . StrReplace(StrReplace(StrReplace(strDosWildcards, "\E", "\E\\E\Q"), "?", "\E.?\Q"), "*", "\E.*\Q") . "\E$"
}
;---------------------------------------------------------


/*
De moi à tout le monde:  04:24 PM
I'll have a question on Regular Expressions when we have time.


De Dimitri Geerts à tout le monde:  04:28 PM
You can use \Q and \E to search for literal text
A question mark matches zero or one of the preceding character, class, or subpattern. Think of this as "the preceding item is optional". For example, colou?r matches both color and colour because the "u" is optional.
again, use use \Q and \E

De Jesús Prieto à tout le monde:  04:28 PM
Sorry ^.+\.docx$

De Dimitri Geerts à tout le monde:  04:31 PM
and in the rest of the strings, add \Q before and \E
.* also finds emptys

De Jesús Prieto à tout le monde:  04:32 PM
^.*\.docx$ to match empty file names

De Dimitri Geerts à tout le monde:  04:35 PM
the Q and E are needed to skip other regex code 

De Geek Dude à tout le monde:  04:43 PM
"\Q" StrReplace(StrReplace(StrReplace(input, "\E", "\E\\E\Q"), "?", "\E.\Q"), "*", "\E.*\Q") "\E"
I did just write it on my phone lol

