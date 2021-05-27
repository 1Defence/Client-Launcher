#SingleInstance force

;priror directory
DIRECTORY := RegExReplace(A_ScriptDir,"[^\\]+\\?$")

;path of runelite client
global CLIENT_TITLE := ""
;grab user set client path
IniRead, CLIENT_TITLE, %DIRECTORY%\lib\PathData.ini, ClientTitle, key

;while applications with client title exist, kill them
while(WinExist(CLIENT_TITLE)){
	WinClose
	Sleep,50
}

;inform user clients have finished terminating
MsgBox, 64, Information, "Clients killed."