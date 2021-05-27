#SingleInstance force

;priror directory
DIRECTORY := RegExReplace(A_ScriptDir,"[^\\]+\\?$")

;path of .runelite (read from config file)
IniRead, SETTINGS_PATH, %DIRECTORY%\lib\PathData.ini, Settings, key
;user hasn't set a settings path, assume the default location.
if(SETTINGS_PATH = "NOT_SET"){
	SETTINGS_PATH = %userprofile%\.runelite\
}
;append settings to the path
SETTINGS_PATH := % SETTINGS_PATH . "settings\"

;used for continuously asking for a file until the user cancels the operation or confirms a deletion.
Running := true

;prompt user to select an .ahk file, until they accept one or cancel the operation.
While(Running){
	;user selects an .ahk file, must have settings folder assosciated to prevent mis-deleting.
	FileSelectFile, SelectedFile, 3, %DIRECTORY%Launchers, Locate the Launcher to delete, assosciated settings files will also be deleted., (*.ahk)
	if (SelectedFile = ""){
		;no file selected exit.
		ExitApp
	}else{
		;seperate name from path
		SplitPath, SelectedFile, , , , fileName
		;set directory to settings path of the file to delete.
		settingsDir := % SETTINGS_PATH . filename
		;ensure settings path assosciated exists before deleting the ahk.
		IfExist % settingsDir
		{
			
			;prompt user of what they're about to delete and ask if they're sure they want to proceed
			MsgBox, 52, Warning, Are you sure you wish to proceed?`nThis will delete the [%filename%] launcher and it's assosciated settings files.`nThis cannot be undone and the files will be unrecoveable.
			IfMsgBox, No 
			{
				;user changed their mind, let them choose again
			}else{
				;remove directory and contents.
				FileRemoveDir, %settingsDir%, 1
				;remove ahk file
				FileDelete, %SelectedFile%
				;inform user the file and settings were successfuly deleted.
				MsgBox, 64, , Launcher and settings deleted [%fileName%]
				;run the buttons script(only initiates if its already running) with the paramater telling it to refresh as the directory has updated.
				run %A_AhkPath% %DIRECTORY%\"Buttons.ahk" 1
				;Running := false
			}
		}else{
			;somehow the user has selected an .ahk not assosciated with a settings file, inform user to manually delete if somehow they lost their settings file.
			MsgBox, 16, , No settings are assosciated with this file, please navigate to the folder and delete it manually to verify this is a launcher file.
		}
		
	}
}