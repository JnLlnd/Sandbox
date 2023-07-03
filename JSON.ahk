; Received from Jackie Sztuk (holyblackman@gmail.com) - Aug 2020

class JSON
{
parse(src, jsonize:=false) {
if ((src:=Trim(src, " `t`n`r")) == "")
throw Exception("Empty JSON source.")
first := SubStr(src, 1, 1), last := SubStr(src, 0)
if !InStr("{[""tfn0123456789-", first)
|| !InStr("}]""el0123456789", last)
|| (first == "{" && last != "}")
|| (first == "[" && last != "]")
|| (first == """" && last != """")
|| (first == "n" && last != "l")
|| (InStr("tf", first) && last != "e")
|| (InStr("-0123456789", first) && !InStr("0123456789", last))
throw Exception("Invalid JSON format.", -1)
esc_char := {
		(Join
			"""": """",
			"/": "/",
			"b": "`b",
			"f": "`f",
			"n": "`n",
			"r": "`r",
			"t": "`t"
)}
i := 0, strings := []
while (i:=InStr(src, """",, i+1)) {
j := i
while (j:=InStr(src, """",, j+1)) {
str := SubStr(src, i+1, j-i-1)
StringReplace, str, str, \\, \u005C, A
if (SubStr(str, 0) != "\")
break
}
if !j
throw Exception("Missing close quote(s).", -1)
src := SubStr(src, 1, i) . SubStr(src, j+1)
z := 0
while (z:=InStr(str, "\",, z+1)) {
ch := SubStr(str, z+1, 1)
if InStr("""btnfr/", ch)
str := SubStr(str, 1, z-1) . esc_char[ch] . SubStr(str, z+2)
else if (ch = "u") {
hex := "0x" . SubStr(str, z+2, 4)
if !(A_IsUnicode || (Abs(hex) < 0x100))
continue
str := SubStr(str, 1, z-1) . Chr(hex) . SubStr(str, z+6)
} else throw Exception("Bad string")
}
strings.Insert(str)
}
if InStr(src, "{") || InStr(src, "}") {
StringReplace, dummy, src, {, {, UseErrorLevel
c1 := ErrorLevel
StringReplace, dummy, src, }, }, UseErrorLevel
c2 := ErrorLevel
if (c1 != c2)
throw Exception("Missing " . Abs(c1-c2)
. (c1 > c2 ? "clos" : "open") . "ing brace(s)", -1)
}
if InStr(src, "[") || InStr(src, "]") {
StringReplace, dummy, src, [, [, UseErrorLevel
c1 := ErrorLevel
StringReplace, dummy, src, ], ], UseErrorLevel
c2 := ErrorLevel
if (c1 != c2)
throw Exception("Missing " . Abs(c1-c2)
. (c1 > c2 ? "clos" : "open") . "ing bracket(s)", -1)
}
if jsonize
_object := this.object, _array := this.array
else (_object := Object(), _array := Array())
pos := 0
, key := dummy := []
, stack := [result := []]
, assert := ""
, null := ""
while ((ch := SubStr(src, ++pos, 1)) != "") {
while (ch != "" && InStr(" `t`n`r", ch))
ch := SubStr(src, ++pos, 1)
if (assert != "") {
if !InStr(assert, ch)
throw Exception("Unexpected '" . ch . "'", -1)
assert := ""
}
if InStr(":,", ch) {
if (cont == result)
throw Exception("Unexpected '" . ch . "' -> there is no "
. "container object/array.")
assert := """"
if (ch == ":" || cont.base != _object)
assert .= "{[tfn0123456789-"
} else if InStr("{[", ch) {
cont := stack[1]
, sub := ch == "{" ? new _object : new _array
, stack.Insert(1, cont[key == dummy ? Round(ObjMaxIndex(cont))+1 : key] := sub)
, assert := (ch == "{" ? """}" : "]{[""tfn0123456789-")
if (key != dummy)
key := dummy
} else if InStr("}]", ch) {
cont := stack.Remove(1)
if !jsonize
cont.base := ""
cont := stack[1]
, assert := (cont.base == _object) ? "}," : "],"
} else if (ch == """") {
str := strings.Remove(1), cont := stack[1]
if (key == dummy) {
if (cont.base == _object) {
key := str, assert := ":"
continue
}
else key := Round(ObjMaxIndex(cont))+1
}
cont[key] := str
, assert := (cont.base == _object ? "}," : "],")
, key := dummy
} else if (ch >= 0 && ch <= 9) || (ch == "-") {
if !RegExMatch(src, "-?\d+(\.\d+)?((?i)E[-+]?\d+)?", num, pos)
throw Exception("Bad number", -1)
pos += StrLen(num)-1
, cont := stack[1]
, cont[key == dummy ? Round(ObjMaxIndex(cont))+1 : key] := num+0
, assert := (cont.base == _object ? "}," : "],")
if (key != dummy)
key := dummy
} else if InStr("tfn", ch, true) {
val := (ch == "t") ? "true" : (ch == "f") ? "false" : "null"
if !((tfn:=SubStr(src, pos, len:=StrLen(val))) == val)
throw Exception("Expected '" val "' instead of '" tfn "'")
pos += len-1
cont := stack[1]
, cont[key == dummy ? Round(ObjMaxIndex(cont))+1 : key] := %val%
, assert := (cont.base == _object ? "}," : "],")
if (key != dummy)
key := dummy
}
}
return result[1]
}
stringify(obj:="", indent:="", lvl:=1) {
if IsObject(obj) {
if (ComObjValue(x) != "")
|| IsFunc(obj)
throw Exception("Unsupported object type")
for k in obj
arr := (k == A_Index)
until !arr
n := indent ? "`n" : (i := indent := "")
Loop, % indent ? lvl : 0
i .= indent
lvl += 1, str := ""
for k, v in obj {
if IsObject(k) || (k == "")
throw Exception("Invalid key.", -1)
if !arr
key := k+0 == k ? """" . k . """" : JSON.stringify(k)
val := JSON.stringify(v, indent, lvl)
str .= (arr ? "" : key . ":" . (indent
? (IsObject(v) && InStr(val, "{") == 1 && val != "{}")
? n . i
: " "
: "")) . val . "," . (indent ? n . i : "")
}
if (str != "") {
str := Trim(str, ",`n`t ")
if indent
str := n . i . str . n . SubStr(i, StrLen(indent)+1)
}
return arr ? "[" str "]" : "{" str "}"
}
else if (obj == "")
return "null"
else if (obj == "0" || obj == "1")
return obj ? "true" : "false"
else if [obj].GetCapacity(1) {
if obj is float
return obj
esc_char := {
			(Join
			    """": "\""",
			    "/": "\/",
			    "`b": "\b",
			    "`f": "\f",
			    "`n": "\n",
			    "`r": "\r",
			    "`t": "\t"
)}
StringReplace, obj, obj, \, \\, A
for k, v in esc_char
StringReplace, obj, obj, % k, % v, A
while RegExMatch(obj, "[^\x20-\x7e]", ch) {
ustr := Asc(ch), esc_ch := "\u", n := 12
while (n >= 0)
esc_ch .= Chr((x:=(ustr>>n) & 15) + (x<10 ? 48 : 55))
, n -= 4
StringReplace, obj, obj, % ch, % esc_ch, A
}
return """" . obj . """"
}
if obj is xdigit
if obj is not digit
obj := """" . obj . """"
return obj
}
class object
{
__New(p*) {
ObjInsert(this, "_", [])
if Mod(p.MaxIndex(), 2)
p.Insert("")
Loop, % p.MaxIndex()//2
this[p[A_Index*2-1]] := p[A_Index*2]
}
__Set(k, v, p*) {
this._.Insert(k)
}
_NewEnum() {
return new JSON.object.Enum(this)
}
Insert(k, v) {
return this[k] := v
}
Remove(k*) {
ascs := A_StringCaseSense
StringCaseSense, Off
if (k.MaxIndex() > 1) {
k1 := k[1], k2 := k[2], is_int := false
if (Abs(k1) != "" && Abs(k2) != "")
k1 := Round(k1), k2 := Round(k2), is_int := true
while true {
for each, key in this._
i := each
until found:=(key >= k1 && key <= k2)
if !found
break
key := this._.Remove(i)
ObjRemove(this, (is_int ? [key, ""] : [key])*)
res := A_Index
}
} else for each, key in this._ {
if (key = (k.MaxIndex() ? k[1] : ObjMaxIndex(this))) {
key := this._.Remove(each)
res := ObjRemove(this, (Abs(key) != "" ? [key, ""] : [key])*)
break
}
}
StringCaseSense, % ascs
return res
}
len() {
return Round(this._.MaxIndex())
}
stringify(i:="") {
return JSON.stringify(this, i)
}
class Enum
{
__New(obj) {
this.obj := obj
this.enum := obj._._NewEnum()
}
Next(ByRef k, ByRef v:="") {
if (r:=this.enum.Next(i, k))
v := this.obj[k]
return r
}
}
}
class array
{
__New(p*) {
for k, v in p
this.Insert(v)
}
stringify(i:="") {
return JSON.stringify(this, i)
}
}
}