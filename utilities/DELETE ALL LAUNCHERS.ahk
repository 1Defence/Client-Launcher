#SingleInstance force

;prompt user of what they're about to delete and ask if they're sure they want to proceed
MsgBox, 52, Warning, Are you sure you wish to proceed?`nThis will delete all of your launchers and their assosciated settings files.`nThis cannot be undone and they will be unrecoveable.
IfMsgBox, No 
{
	;user changed their mind, terminate the app
	ExitApp
}


;priror directory
DIRECTORY := RegExReplace(A_ScriptDir,"[^\\]+\\?$")

;path of .runelite (read from config file)
IniRead, SETTINGS_PATH, %DIRECTORY%\lib\PathData.ini, Settings, key
;user hasn't set a settings path, assume the default location.
if(SETTINGS_PATH = "NOT_SET"){
	SETTINGS_PATH = %userprofile%\.runelite
}
;append settings to the path
SETTINGS_DIRECTORY := % SETTINGS_PATH . "\settings"

;directory to create launcher in
LAUNCHER_DIRECTORY := % DIRECTORY . "\Launchers"

If(!InStr( FileExist(SETTINGS_DIRECTORY), "D") ){
	MsgBox, 48, Warning, "No valid settings directory present"
	ExitApp
}

If(!InStr( FileExist(LAUNCHER_DIRECTORY), "D") ){
	MsgBox, 48, Warning, "No valid launchers directory present"
	ExitApp
}
	
;flush the directory of settings / launchers
FlushDirectory(SETTINGS_DIRECTORY)
FlushDirectory(LAUNCHER_DIRECTORY)

;flushes directory by deleting everything inside and recreating it.
FlushDirectory(dir){
	;MsgBox % dir
	FileRemoveDir, %dir%, 1
	FileCreateDir, %dir%
}

;inform user all launchers and settings were successfuly deleted.
MsgBox, 64, Information, All Launchers and settings deleted
;run the buttons script(only initiates if its already running) with the paramater telling it to refresh as the directory has updated.
run %A_AhkPath% %DIRECTORY%\"Buttons.ahk" 1