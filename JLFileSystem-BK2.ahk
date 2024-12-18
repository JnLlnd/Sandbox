#SingleInstance force
#Warn All, StdOut 
DetectHiddenWindows, On

SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\JLFileSystem.ahk

global showTooltip := False

MyFileSystem := new FileSystem
MyNewFolder := new MyFileSystem.FileContainer( A_ScriptDir, -1 )
if (showTooltip)
	ToolTip

str := MyNewFolder.listFiles()
Gui, Add, Edit, w800 r25 ReadOnly, % SubStr(str, 1, 25000) . (StrLen(str) > 25000 ? "`n..." : "")
Gui, Add, Button, default, Close
GuiControl, Focus, Close
Gui, Show

return

ButtonClose:
ExitApp


; ------------------------------------------------

class FileSystem {
; adapted from nnnik (https://autohotkey.com/boards/viewtopic.php?f=7&t=41332)

	class FileSystemElement {
	
		getAttributes() { ;flag string see AutoHotkey Help: FileExist for more infos
			return FileExist( this.name )
		}
		changeAttributes( changeAttributeString ) { ;see FileSetAttrib for more infos
			FileSetAttrib, % changeAttributeString, % this.name
		}
		getPath() {
			return this.name
		}
		getPathName() {
			SplitPath, % this.name, fileName
			return fileName
		}
		getPathDir() { ;same as getDirectory
			return This.getPathDirectory()
		}
		getPathDirectory() {
			SplitPath, % this.name, , fileDirectory
			return fileDirectory
		}
		getPathExtension() {
			SplitPath, % this.name , , , fileExtension
			return fileExtension
		}
		getPathNameNoExtension() {
			SplitPath, % this.name, , , , fileNameNoExtension
			return fileNameNoExtension
		}
		getPathDrive() {
			SplitPath, % this.name, , , , , fileDrive
			return fileDrive
		}
		getTimeAccessed() { ;in YYYYMMDDHH24MISS see AutoHotkey help for more infos
			FileGetTime, timeCreated, % this.name, A
			return timeCreated
		}
		setTimeAccessed( timeAccessed ) {
			FileSetTime, % timeAccessed, % this.name, A
		}
		getTimeModified() {
			FileGetTime, timeModified, % this.name, M
			return timeModified
		}
		setTimeModified( timeModified ) {
			FileSetTime, % timeModified, % this.name, M
		}
		getTimeCreated() {
			FileGetTime, timeCreated, % this.name, C
			return timeCreated
		}
		setTimeCreated( timeCreated ) {
			FileSetTime, % timeCreated, % this.name, C
		}
	}
	class File extends FileSystem.FileSystemElement {
		__New( fileName ) {
			if ( !fileExist( fileName ) )
				Throw exception( "File """ . fileName . """ doesn't exist", "__New", "Exist test returned false" )
			if ( inStr( fileExist( fileName ), "D" ) ) ;if file is a folder or a drive
				Throw exception( "Error creating File", "__New", "Path points to Folder" )
			Loop, Files, % strReplace(fileName,"/","\"), F ;since the fileName refers to a single file this loop will only execute once
				this.name := A_LoopFileLongPath ;and there it will set the path to the value we need
		}
		open( p* ) {
			return FileOpen( this.name, p* )
		}
		getSize( unit := "" ) {
			FileGetSize, fileSize, % this.name, % unit
			return fileSize
		}
		move( newFilePath, overwrite := 0 ) {
			FileMove, % this.name, % newFilePath, % overwrite
		}
		copy( newFilePath, overwrite := 0 ) {
			FileCopy, % this.name, % newFilePath, % overwrite
		}
		delete() {
			FileDelete, % this.name
		}
	}
	class FileContainer extends FileSystem.FileSystemElement {
		__New( path, recurseLevels := 1 ) {
			; path -> folder or drive root to scan
			; recurseLevels -> number of folder levels to scan (default 1 this path only, -1 to scan all, 0 to scan none)
			if ( !fileExist( path ) )
				Throw exception( "Path """ . path . """ doesn't exist", "__New", "Exist test returned false" )
			if ( !inStr( fileExist( path ), "D" ) ) ;if file is not a folder or a drive
				Throw exception( "Error creating File", "__New", "Path does not points to Folder" )
			this.name := path
			if ( SubStr( path, 0, 1 ) = "\" ) ; remove ending backslash for drive roots
				path := SubStr( path, 1, StrLen( path ) - 1 )
			if !( this.getFilesInFolder( path, recurseLevels ) )
				Throw exception( "Error getting Files", "__New", "Could not get files from folder" )
		}
		getFilesInFolder( thisPath, recurseLevels ) {
			; thisPath -> folder or drive root to scan
			; recurseLevels -> number of folder levels to scan including this one
			if ( showToolTip )
				ToolTip, Getting files from:`n%thisPath%
			; if recurseLevels > 0 continue with subfolder
			; if recurseLevels < 0 continue until the end of branch
			; if recurseLevels = 0 stop recursion
			if ( recurseLevels = 0 )
				return true
			this.Files := Object()
			Loop, Files, % thisPath . "\*.*", FD ; do not recurse here because the class does the recursion
			{
				if InStr( FileExist( A_LoopFileFullPath ), "D")
					objItem := new FileSystem.FileContainer( A_LoopFileFullPath, recurseLevels - 1 )
				else
					objItem := new FileSystem.File( A_LoopFileFullPath )
				this.addItem(objItem)
			}
			return true
		}
		listFiles( filter := "", recurseLevels := -1 ) {
			thisList := ""
			for intKey, objItem in this.Files {
				if !StrLen(filter) or InStr(objItem.name, filter)
					thisList .= objItem.name . "`n"
				; if recurseLevels > 0 continue with subfolder
				; if recurseLevels < 0 continue until the end of branch
				; if recurseLevels = 0 stop recursion
				if (objItem.HasKey("Files") and recurseLevels <> 0) ; this is a container, recurse
					thisList .= objItem.listFiles( filter, recurseLevels - 1)
			}
			return thisList
		}
		addItem(objItem) {
			this.Files.InsertAt(this.Files.Length()+ 1, objItem)
		}
		getPathName() {
			Throw exception( "Couldn't find method" , A_ThisFunc, "Method: " . A_ThisFunc . " is not available for objects of Class: " . this.__class )
		}
		getPathExtension() {
			Throw exception( "Couldn't find method" , A_ThisFunc, "Method: " . A_ThisFunc . " is not available for objects of Class: " . this.__class )
		}
		getPathNameNoExtension() {
			Throw exception( "Couldn't find method" , A_ThisFunc, "Method: " . A_ThisFunc . " is not available for objects of Class: " . this.__class )
		}
	}
	class Directory extends FileSystem.FileContainer {
	}
	class Drive extends FileSystem.FileContainer {
		changeAttributes( changeAttributeString ) {
			Throw exception( "Couldn't find method" , A_ThisFunc, "Method: " . A_ThisFunc . " is not available for objects of Class: " . this.__class )
		}
		getPathDir() {
			Throw exception( "Couldn't find method" , A_ThisFunc, "Method: " . A_ThisFunc . " is not available for objects of Class: " . this.__class )
		}
		getPathDirectory() {
			Throw exception( "Couldn't find method" , A_ThisFunc, "Method: " . A_ThisFunc . " is not available for objects of Class: " . this.__class )
		}
		getTimeAccessed() {
			Throw exception( "Couldn't find method" , A_ThisFunc, "Method: " . A_ThisFunc . " is not available for objects of Class: " . this.__class )
		}
		setTimeAccessed( timeStamp ) {
			Throw exception( "Couldn't find method" , A_ThisFunc, "Method: " . A_ThisFunc . " is not available for objects of Class: " . this.__class )
		}
		getTimeModified() {
			Throw exception( "Couldn't find method" , A_ThisFunc, "Method: " . A_ThisFunc . " is not available for objects of Class: " . this.__class )
		}
		setTimeModified( timeStamp ) {
			Throw exception( "Couldn't find method" , A_ThisFunc, "Method: " . A_ThisFunc . " is not available for objects of Class: " . this.__class )
		}
		getTimeCreated() {
			Throw exception( "Couldn't find method" , A_ThisFunc, "Method: " . A_ThisFunc . " is not available for objects of Class: " . this.__class )
		}
		setTimeCreated( timeStamp ) {
			Throw exception( "Couldn't find method" , A_ThisFunc, "Method: " . A_ThisFunc . " is not available for objects of Class: " . this.__class )
		}
	}
}