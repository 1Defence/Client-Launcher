#SingleInstance force

;priror directory
DIRECTORY := RegExReplace(A_ScriptDir,"[^\\]+\\?$")

;file extension of the ahk
FileExt := .ahk

;directory to create launcher in
LAUNCHER_DIRECTORY := % DIRECTORY . "Launchers\"

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
		settingsDir := % SETTINGS_PATH . fileName
		;ensure settings path assosciated exists before deleting the ahk.
		IfExist % settingsDir
		{
			;prompt user of what they're about to delete and ask if they're sure they want to proceed
			MsgBox, 52, Warning, Are you sure you wish to proceed?`nThis will rename the [%fileName%] launcher and it's assosciated settings files.
			IfMsgBox, No 
			{
				;user changed their mind, let them choose again
			}else{
				
				while(Running){
					InputBox, UserInput, Rename %fileName%, Choose your launcher name, , 250,140
					if ErrorLevel
					{
						ExitApp
					}else{
						;replace spaces with underscores, runelite issue.
						StringReplace, UserInput, UserInput, %A_Space%, _, All
						if(!UserInput){
							;user input nothing, continue and prompt them again
						}else if(SelectedFile == (LAUNCHER_DIRECTORY . UserInput . FileExt)){
							;you're trying to rename to the exact same file... ?
							MsgBox "?"
						}else if !FileExist(LAUNCHER_DIRECTORY . UserInput . FileExt){
							MSGBox, 52, , Confirmation, [%fileName%] -> [%UserInput%]
							IfMsgBox, No 
							{
								;for readability, the user decided not to replace the file, ask them again for a name
							}else{
								;the user wants to overwrite, proceed as normal replacing will automatically occur
								Running := false
							}
						}else{
							MsgBox % LAUNCHER_DIRECTORY . UserInput . FileExt
							MsgBox % SelectedFile
							MSGBox, 52, , File already exists, would you like to replace it?
							IfMsgBox, No 
							{
								;for readability, the user decided not to replace the file, ask them again for a name
							}else{
								;the user wants to overwrite, proceed as normal replacing will automatically occur
								Running := false
							}
						}
					}
				}
				
				;prefix of settings file names
				SettingsPrefix := "Settings_"
				;prefix of settings files
				SettingsSuffix := ".properties"
				;full name excludin suffix
				fullNameNew := % SettingsPrefix . userinput
				
				;rename old launcher ahk, to the new name
				FileMove, % LAUNCHER_DIRECTORY . fileName . FileExt, % LAUNCHER_DIRECTORY . userInput . FileExt
				
				;old directory of settings file to move
				settingsDir := % SETTINGS_PATH . fileName
				;new directory of settings file
				settingsDirNew := % SETTINGS_PATH . userInput
				
				;move old directory to new
				FileMoveDir, %settingsDir%, %settingsDirNew%
				
				;initialize blank list of files, we need to generate them prior to modification
				fileList := ""
				
				;look through all files in the new settings directory
				Loop, Files, %settingsDirNew%\*.properties
				{
					;Already exists, add new line prior.
					if(fileList){
						FileList .=  "`n"
					}
					;add file path to parse
					FileList .= A_LoopFilePath
				}
				
				;loop through all files in the list that was generated.
				Loop, parse, FileList, `n
				{
					;fullpath of the new properties file
					newPropPath := % settingsDirNew . "\" . fullNameNew . A_Index . SettingsSuffix
					;rename current properties file to new properties file
					FileMove, %A_LoopField%, %newPropPath%
				}
				
				;inform user the file and settings were successfuly updated.
				MsgBox, 64, , Launcher and settings successfuly updated`n [%fileName%] -> [%UserInput%]
				;run the buttons script(only initiates if its already running) with the paramater telling it to refresh as the directory has updated.
				run %A_AhkPath% %DIRECTORY%\"Buttons.ahk" 1
				;Running := false
			}
		}else{
			;somehow the user has selected an .ahk not assosciated with a settings file, inform user to manually delete if somehow they lost their settings file.
			MsgBox, 16, , No settings are assosciated with this file [%fileName%], please navigate to the folder and delete if you believe it's corrupt
		}
		
	}
}