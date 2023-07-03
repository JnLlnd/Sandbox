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
				Throw exception( "File """ . path . """ doesn't exist", "__New", "Exist test returned false" )
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