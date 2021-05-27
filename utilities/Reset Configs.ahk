#SingleInstance force

;priror directory
DIRECTORY := RegExReplace(A_ScriptDir,"[^\\]+\\?$")

;defaults to reset to
DEFAULT_CLIENT_TITLE_PATH := "RuneLite"
DEFAULT_CLIENT_PATH := "NOT_SET"
DEFAULT_SETTINGS_PATH := "NOT_SET"

;init current configs
CurrentTitle = ""
CurrentClient = ""
CurrentSettings = ""

;grab client title config
IniRead, CurrentTitle, %DIRECTORY%\lib\PathData.ini, ClientTitle, key
;grab client path config
IniRead, CurrentClient, %DIRECTORY%\lib\PathData.ini, Client, key
;grab settings path config
IniRead, CurrentSettings, %DIRECTORY%\lib\PathData.ini, Settings, key

if(CurrentTitle = DEFAULT_CLIENT_TITLE_PATH && CurrentClient == DEFAULT_CLIENT_PATH && CurrentSettings == DEFAULT_SETTINGS_PATH){
	;inform user all configs are already defaulted.
	MsgBox, 64, , All configs are already in their default states.`n[Configs]`n1. Client Title`n2. Client Path`n3. Settings Path
}else{

	;prompt user of what they're about to reset and ask if they wish to continue.
	MsgBox, 52, Warning, Are you sure you wish to reset your configs to their default state ?`nTitle : [%CurrentTitle%] -> [%DEFAULT_CLIENT_TITLE_PATH%]`nClient : [%CurrentClient%] -> [%DEFAULT_CLIENT_PATH%]`nSettings : [%CurrentSettings%] -> [%DEFAULT_SETTINGS_PATH%]
	IfMsgBox, No 
	{
		;for readability, user wants to select their offline settings file continue as normal.
	}Else{
		;write default client title to config file
		IniWrite, "RuneLite", %DIRECTORY%\lib\PathData.ini, ClientTitle, key
		;write default client path to config file
		IniWrite, "NOT_SET", %DIRECTORY%\lib\PathData.ini, Client, key
		;write default settings path to config file
		IniWrite, "NOT_SET", %DIRECTORY%\lib\PathData.ini, Settings, key
		;inform user configs were reset
		MsgBox, 64, Information, All configs successfuly reset.
	}
}
