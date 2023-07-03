#SingleInstance force
#Warn All, StdOut 
DetectHiddenWindows, On
SetWorkingDir, %A_ScriptDir%

global showTooltip := True

MyFileSystem := new FileSystem ; create my instance of the class
MyNewContainer := new MyFileSystem.Directory( A_ScriptDir ) ; create a container for the specified folder and get files in this folder only
; MyNewContainer := new MyFileSystem.Directory( A_ScriptDir, 3 ) ; use to scan the 2nd and 3rd sub levels of the specified folder
; MyNewContainer := new MyFileSystem.Directory( A_ScriptDir, -1 ) ; use for full scan of the specified folder
; MyNewContainer := new MyFileSystem.Drive( "Z:\", 2 ) ; use to scan the root and 2nd level of the specified drive

if ( showTooltip )
	ToolTip ; hide last tooltip

; get content from the MyNewContainer object
str := MyNewContainer.listFiles() ; get the list of files and folders contained in the MyNewContainer object
; str := MyNewContainer.listFiles("w", 2) ; to get only files and folders with "w" in their name and stop at 3rd level

; show content in Gui
Gui, Add, Edit, w800 r25 ReadOnly, % SubStr( str, 1, 30000 ) . ( StrLen( str ) > 30000 ? "`n..." : "" ) ; limit because of 32k limit of Edit control
Gui, Add, Button, default, Close
GuiControl, Focus, Close
Gui, Show

return

ButtonClose:
ExitApp


; ------------------------------------------------
; Original class FileSystem from nnnik (https://autohotkey.com/boards/viewtopic.php?f=7&t=41332)
; Adapted by JnLlnd (Jean Lalonde)

class FileSystem {
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
			if ( !inStr( fileExist( path ), "D" ) ) ; if file is not a folder or a drive
				Throw exception( "Error creating File", "__New", "Path does not points to Folder" )
			this.name := path
			if ( SubStr( path, 0, 1 ) = "\" ) ; remove ending backslash for drive roots (like "C:\")
				path := SubStr( path, 1, StrLen( path ) - 1 )
			if !( this.getFilesInFolder( path, recurseLevels ) )
				Throw exception( "Error getting Items", "__New", "Could not get items from container" )
		}
		getFilesInFolder( thisPath, recurseLevels ) {
			; thisPath -> folder or drive root to scan
			; recurseLevels -> number of folder levels to scan including this one
			if ( showToolTip )
				ToolTip, Getting files from:`n%thisPath%
			; if recurseLevels > 0 continue with sub folder
			; if recurseLevels < 0 continue until the end of branch
			; if recurseLevels = 0 stop recursion
			if ( recurseLevels = 0 )
				return true
			this.Items := Object() ; create an object to contain items (files and folders)
			Loop, Files, % thisPath . "\*.*", FD ; do not use "R" here, the class does the recursion below
			{
				if A_LoopFileAttrib contains H,S ; skip hidden or system files
					continue
				if A_LoopFileAttrib contains D ; this is a folder, create Directory object and recurse to sub level
					objItem := new FileSystem.Directory( A_LoopFileFullPath, recurseLevels - 1 ) ; "- 1" to track the number of levels
				else ; this is a file, create File object
					objItem := new FileSystem.File( A_LoopFileFullPath )
				this.addItem(objItem) ; add Directory or File object to Items container
			}
			return true
		}
		listFiles( filter := "", recurseLevels := -1 ) {
			; filter -> exclude items with filter in their name, default empty (include all items)
			; recurseLevels -> number of folder levels to scan (default -1 to scan all, 0 to scan none)
			; if recurseLevels > 0 continue with sub folder
			; if recurseLevels < 0 continue until the end of branch
			; if recurseLevels = 0 stop recursion
			if (recurseLevels = 0)
				return
			thisList := ""
			for intKey, objItem in this.Items {
				if !StrLen(filter) or InStr(objItem.name, filter)
					thisList .= objItem.name . "`n"
				if ( objItem.HasKey( "Items" ) ) ; this is a container, recurse
					thisList .= objItem.listFiles( filter, recurseLevels - 1 ) ; "- 1" to track the number of levels
			}
			return thisList
		}
		addItem(objItem) {
			this.Items.InsertAt(this.Items.Length()+ 1, objItem) ; add Directory or File object to Items container
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