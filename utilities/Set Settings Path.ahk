#SingleInstance force

;count of expected arguments(if present)
ARG_COUNT = 1
;args will be present if ran from a launcher
argsPresent := false
;name of the launcher to re-run
fileName := NOT_SET

;check if args exist
if(%0%){
	;args are present meaning we're running a launcher after this.
	argsPresent := true
	;grab args because otherwise they're taken by reference and increment into null.
	arg1 = %1%
	;set name to passed argument
	fileName := arg1
}

;priror directory
DIRECTORY := RegExReplace(A_ScriptDir,"[^\\]+\\?$")

;path of .runelite (read from config file)
IniRead, SETTINGS_PATH, %DIRECTORY%\lib\PathData.ini, Settings, key

;user hasn't set a settings path, assume the default location.
if(SETTINGS_PATH = "NOT_SET"){
	SETTINGS_PATH = %userprofile%\.runelite\
}

while(!SelectedFolder){
	;prompt user to select the .runelite folder
	FileSelectFolder, SelectedFolder, , 0, Locate .RuneLite (Currently : %SETTINGS_PATH%)
	if ErrorLevel
	{
		;user has decided to terminate the process
		ExitApp
	}
	;extract the folder name from the path
	Splitpath, SelectedFolder, fullName
	
	;reprompt the user if chosen folder isnt .runelite
	IfNotInString, fullName, .runelite
	{
		;inform user they've chosen an invalid folder
		MsgBox, 16, Error, "Please choose a valid .runelite folder"
		;nullify selected folder so loop can continue
		SelectedFolder =
		;continue the loop
		continue
	}
	
	;user selected a valid folder
	if (SelectedFolder != ""){
		;inform user of new .runelite folder to verify
		MsgBox, 64, Information, Now using settings directory :`n%SelectedFolder%
		;write .runelite path to config file
		IniWrite, %SelectedFolder%\, %DIRECTORY%\lib\PathData.ini, Settings, key
			;argument to run previous launcher was passed
		if(argsPresent){
			;run the previous launcher
			run %A_AhkPath% %DIRECTORY%\Launchers\%fileName%.ahk
		}
	}
}