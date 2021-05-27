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

;path of runelite client
global CLIENT_PATH := ""
;grab user set client path
IniRead, CLIENT_PATH, %DIRECTORY%\lib\PathData.ini, Client, key

;user hasn't set a client path, assume the default location.
if(CLIENT_PATH = "NOT_SET"){
	CLIENT_PATH = %localappdata%\RuneLite\RuneLite.exe
}

;prompt user to select a client showing all available jar/exe files, starting in the assumed directory of their client.
FileSelectFile, SelectedFile, 3, %localappdata%\RuneLite, Locate RuneLite.jar/.exe (Currently : %CLIENT_PATH%), (*.jar;*.exe)
;user selected a valid file
if (SelectedFile != ""){
	;inform user of new client location to verify
	MsgBox, 64, Information, Client launchers will now run client from :`n[%SelectedFile%]
	;write client path to config file
	IniWrite, %SelectedFile%, %DIRECTORY%\lib\PathData.ini, Client, key
	;argument to run previous launcher was passed
	if(argsPresent){
		;run the previous launcher
		run %A_AhkPath% %DIRECTORY%\Launchers\%fileName%.ahk
	}
}