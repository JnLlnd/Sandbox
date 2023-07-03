#SingleInstance force
#Warn All, StdOut 
DetectHiddenWindows, On

SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\JLFileSystem.ahk

objNewFolder := new FileSystem.FileContainer("J:\Temp\FileSystemTest", True, 2)
###_O("objNewFolder.Files", objNewFolder.Files, "name")

###_V("", objNewFolder.Files[3].name, objNewFolder.Files[3].Files[1].name)
for intKey, objItem in objNewFolder.Files {
	###_O("objItem", objItem, "name")
	if objItem.HasKey("Files")
		for intKey2, objItem2 in objItem.Files
			###_O("objItem2", objItem2, "name")
}

ExitApp

/*
AddItems(strFolder)
{
	Loop, Files, % objNewFolder.name . "\*.*", D
	{
		strResult := AddItems(A_LoopFileFullPath) ; resursive
	}
	Loop, Files, % objNewFolder.name . "\*.*", F
	{
		objNewFile := new FileSystem.File(A_LoopFileFullPath)
		###_V("", A_LoopFileFullPath, objNewFile.name, objNewFile.getPathExtension(), objNewFolder.name)
		objNewFolder.addItem(objNewFile)
	}
	objList := objNewFolder.Files
	###_O("", objList, "name")
	return "OK"
}



/*
; ###_V(A_ScriptDir, FileExist(A_ScriptDir . "\FileSystem.ahk"))
strFile := "test.txt"
fileObj := new File( strFile )
fileObj.Open( "w" ).write( fileObj.getPath() "`n" fileObj.getPathName() "`n" fileObj.getPathDirectory() "`n" fileObj.getPathExtension() "`n" fileObj.getPathNameNoExtension() "`n" fileObj.getPathDrive() )

File := "test.txt"
LongFilePath := A_ScriptDir . "\" . File
SplitPath, LongFilePath, Name, Directory, Extension, NameNoExtension, Drive
FileOpen( File, "w" ).write( Name "`n" Directory "`n" Extension "`n" NameNoExtension "`n" Drive )

file1 := new FileSystem.File( A_ScriptFullPath ) ;a file object of our test.ahk
file2 := new FileSystem.File( "FileSystem.ahk" ) ;a file object of our "File.ahk" containing our file class
; file3 := new FileSystem.Drive( "c:\" )
Msgbox % file1.getPathDir() ;get containing folder
Msgbox % file1.getAttributes() ;get containing folder
Msgbox % file1.getPathName() ;get containing folder
Msgbox % file2.getPathDir() ;get containing folder
Msgbox % file3.getPathDrive()

