#SingleInstance force

;Number of arguments that should be present upon running script.
ARG_COUNT = 3

;prevents running the base AHK, this requires arguments to be passed from a launcher script.
if 0 < %ARG_COUNT%
{
    MsgBox, 16, ERROR, Do not run the Base file....
    ExitApp
}

;grab args because otherwise they're taken by reference and increment into null.
arg1 = %1%
arg2 = %2%
arg3 = %3%


;desired amount of clients (passed via args)
global CLIENT_COUNT := arg1

;launcher name (passed via args)
global FILE_NAME = arg2

;path of your client, extension will be either .jar or .exe (read from config file)
global CLIENT_PATH := ""
IniRead, CLIENT_PATH, %A_ScriptDir%\PathData.ini, Client, key
;user hasn't set a client path, assume the default location.
if(CLIENT_PATH = "NOT_SET"){
	CLIENT_PATH = %localappdata%\RuneLite\RuneLite.exe
}

if !FileExist(CLIENT_PATH){
	MsgBox, 16, File Not Found, Somehow`, the base runelite jar was not found`, locate your client and try again.
	;priror directory
	DIRECTORY := RegExReplace(A_ScriptDir,"[^\\]+\\?$")
	;Run the Set Client Path script and pass the name of this file to reopen after.
	run %A_AhkPath% %DIRECTORY%\"\utilities\Set Client Path.ahk" %FILE_NAME%
	ExitApp
}

;surround path in quotes, otherwise program with spaces in name E.G RuneLite (2) won't run
CLIENT_PATH := """" . CLIENT_PATH . """"

;prevent user from self-corrupting files.
IfInString, FILE_NAME, %A_Space%
{
	;name with spaces replaced with underscores
	FILE_NAME_FIXED := % StrReplace(FILE_NAME, " ", "_")
	;priror directory
	DIRECTORY := RegExReplace(A_ScriptDir,"[^\\]+\\?$")
	;path of launcher folder
	launcherPath := % DIRECTORY . "Launchers\"
	;path of corrupt file
	originPath := % launcherPath . FILE_NAME . ".ahk"
	;path of fixed file
	fixedPath := % launcherPath . FILE_NAME_FIXED . ".ahk"
	;rename the corrupted file via a move.
	FileMove, %originPath%, %fixedPath%
	;fix name of the file within the script to seemlessly run as if nothing happened.
	FILE_NAME := FILE_NAME_FIXED
}

;base name of the settings file (passed via args)
global SETTINGS_BASE_NAME = arg3

;saved settings are a full path, this occurs when the user is choosing their profile-selected settings.
SettingsIsFullPath := false
IfInString, SETTINGS_BASE_NAME,.properties
{
	SettingsIsFullPath := true
}

;settings files are always Settings_NAME, we dont want to always pass Settings_ when choosing our file, this is a failsafe
if(SETTINGS_BASE_NAME != "settings" && !SettingsIsFullPath){

	IfNotInString,SETTINGS_BASE_NAME,Settings_
	{
		SETTINGS_BASE_NAME := "Settings_" . SETTINGS_BASE_NAME
	}

}

;path of .runelite (read from config file)
IniRead, TO_PATH, %A_ScriptDir%\PathData.ini, Settings, key
;user hasn't set a settings path, assume the default location.
if(TO_PATH = "NOT_SET"){
	TO_PATH = %userprofile%\.runelite\
}

IfNotExist, %TO_PATH%
{
	MsgBox, 16, Path Not Found, Somehow`, the .runelite folder was not found`, locate your .runelite folder and try again.
	;priror directory
	DIRECTORY := RegExReplace(A_ScriptDir,"[^\\]+\\?$")
	;Run the Set Client Path script and pass the name of this file to reopen after.
	run %A_AhkPath% %DIRECTORY%\"\utilities\Set Settings Path.ahk" %FILE_NAME%
	ExitApp
}


;base path used to save/load settings files
global BASE_SETTINGS_DIR := TO_PATH . "settings\"
;current path used to save/load the active scripts settings files
global CURRENT_SETTINGS_DIR := TO_PATH . "settings\" . FILE_NAME . "\"
;create the directory(s) if not currently present.
IfNotExist, %CURRENT_SETTINGS_DIR%
  FileCreateDir, %CURRENT_SETTINGS_DIR%

;prefix of the settings file names.
global SETTINGS_FILE_PREFIX := "Settings_"

;suffix of settings file names.
global SETTING_FILE_SUFFIX := ".properties"

;process ids of the current script, used to prevent cpu issues of loading all files instantly.
process_Array := []
;last process id, used to prevent double-tracking of processes
lastPID := -1
;waiting for prior process to finish loading
waiting := false
;actively running, loading new clients
running := true


;found the desired settings file.
foundFile := false
;Once found this is the path of the user-selected base file
COPY_PATH := ""


;time in seconds new client has to spawn before termination.
CLIENT_RUN_TIMEOUT := 10

;time scheduled to terminate
scheduledTimeout := (a_sec+60)


;searches folder/sub folders of .runelite to find user-selected base file (By default this is just your normal Settings.properties file)
loop %CLIENT_COUNT%{
	checkPath := GenerateSettingsFile(A_Index,true)
	;if current properties file index not present, search for desired base settings file to copy over.
	if !FileExist(checkPath){
	
		if(!foundFile){
			if(SETTINGS_BASE_NAME = "settings"){
				;this is the default settings file, we don't need to search as we know where it's located.
				COPY_PATH := TO_PATH . SETTINGS_BASE_NAME . SETTING_FILE_SUFFIX
			}else if(SettingsIsFullPath){
				;user has chose a specific path likely due to being logged in, as before no search needed.
				COPY_PATH := % SETTINGS_BASE_NAME
			}else{
				;recursive loop into sub folders
				Loop, % BASE_SETTINGS_DIR . SETTINGS_BASE_NAME . SETTING_FILE_SUFFIX, , 1
				COPY_PATH := A_LoopFileFullPath
			}
			if(COPY_PATH != ""){
				;base file was found, don't search on future iterations
				foundFile := true
			}else{
				;the user-selected base file does not exist, exit app to prevent catasrophic failure.
				MsgBox, 16, ERROR, FATAL ERROR : "%SETTINGS_BASE_NAME%" properties file not found`, perhaps you made a typo?
				ExitApp
			}
		}
	
	;copy the base file, with the current file name & index as a new properties file.
	FileCopy, %COPY_PATH%, % GenerateSettingsFile(A_Index,true)
	;inform user that a new settings file was created, this only occurs on creation, not on subsequent runs.
	MsgBox, 0, , % "Setting new properties for client : " . A_Index, 1
	}
}
;sleep after initial creation to give write time, then check if written succesfully
Sleep, 500

;check and ensure each property file for the given launcher exists prior to proceeding.
loop %CLIENT_COUNT%{
	checkPath := GenerateSettingsFile(A_Index,true)
	if !FileExist(checkPath){
	MsgBox, 16, ERROR, FATAL ERROR : settings werent generated in time
	ExitApp
	}
}

;relevant for generating the appropriate arguments as jars and exes handle them differently.
global IsExe := false
IfInString, CLIENT_PATH,.exe
{
	IsExe := true
}

;argument passing differs based on exe vs jar, this handles that, effectively theres a prefix+suffix if its an executable otherwise there isnt.
GenerateArgs(fileNumber){
	pref := IsExe ? "--clientargs """ : ""
	arg = % "--config=" . CURRENT_SETTINGS_DIR . GenerateSettingsFile(fileNumber) . " --sessionfile=" . CURRENT_SETTINGS_DIR . "session" . fileNumber
	suf := IsExe ? """" : ""
	return pref . arg . suf
}

;convinience function for creating the settings file url, by default it won't include directory unless true is passed.
GenerateSettingsFile(fileNumber, includeDir = false){
	return % (includeDir ? CURRENT_SETTINGS_DIR : "") . SETTINGS_FILE_PREFIX . FILE_NAME . fileNumber . SETTING_FILE_SUFFIX
}

;all settings files created or already present, proceed to the program.
while(running) {

	if(a_sec >= scheduledTimeout){
		MsgBox, 262160, Error Client Timeout, "Launcher timed out`, progam will exit now no new client has started in 10 seconds`nSet a different client path in utilities/Set Client Path"
		ExitApp
	}
	;current script associated clients running
	currentClientCount := ObjCount(process_Array)
	;the next client # to run
	pendingClientNumber := currentClientCount+1
	
	;argument passing differs based on exe vs jar, this handles that, effectively theres a prefix+suffix if its an executable otherwise there isnt.
	ARGS_PATH := GenerateArgs(pendingClientNumber)
		
	if(!waiting && currentClientCount < CLIENT_COUNT){
	;initial start, or RuneLite Launcher has finished, start a new client
	;create a temporary batfile which runs runelite with the arguments of our property file and session number
	;the property file uses the AHK scripts name and appends the client number, eg bandos1.properties,bandos2.properties etc
	;start %CLIENT_PATH% %ARGS_PATH%
		RunClientBat=
		(
		@echo off
		start "" %CLIENT_PATH% %ARGS_PATH%
		)
		FileAppend,%RunClientBat%, temp.bat
		FileSetAttrib, +h, temp.bat
		RunWait,temp.bat,,Hide
		FileDelete, temp.bat
		waiting := true
		scheduledTimeout := (a_sec+CLIENT_RUN_TIMEOUT)
	}else{
	
		WinGet, pid, PID, RuneLite Launcher
		if(pid != lastPID && pid > 0){
		;in waiting stage of launcher to appear, launcher is present and not tracked
		;add process ID of client to array
			process_Array.Push(pid)
			lastPID := pid
			waiting:= false
		}
		
	}
		
	if(currentClientCount >= CLIENT_COUNT){
		;all clients have attempted an open terminate app
			Sleep, 2000
			ExitApp
	}

	Sleep, 50
}