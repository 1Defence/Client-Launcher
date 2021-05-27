#SingleInstance force

;set background to black
TransColor = 000000
Gui, Color, %transColor%

;add relevant buttons
Gui, Add, Button, x12 y9 w160 h60 gSETTINGS_PATH, Settings Path
Gui, Add, Button, x172 y9 w160 h60 gCLIENT_PATH, Client Path
Gui, Add, Button, x332 y9 w160 h60 gCLIENT_TITLE, Client Title
Gui, Add, Button, x12 y69 w480 h60 gRESET_CONFIGS, Reset all of the above
Gui, Add, Button, x12 y139 w160 h60 gRENAME_LAUNCHER, Rename Launcher
Gui, Add, Button, x172 y139 w160 h60 gDELETE_LAUNCHER, Delete Launcher
Gui, Add, Button, x332 y139 w160 h60 gDELETE_LAUNCHERS_ALL, Delete All Launchers
Gui, Add, Button, x12 y209 w480 h60 gTERMINATE_RUNNING_CLIENTS, Terminate All Running Clients
;show gui
Gui, Show, w507 h284, Launcher Utilities
return


;the below functions, will call the runahk function with the relevant ahk script name
SETTINGS_PATH:
	RunAHK("Set Settings Path")
return

CLIENT_PATH:
	RunAHK("Set Client Path")
return

CLIENT_TITLE:
	RunAHK("Set Client Title")
return

RESET_CONFIGS:
	RunAHK("Reset Configs")
return

RENAME_LAUNCHER:
	RunAHK("Rename Launcher")
return

DELETE_LAUNCHER:
	RunAHK("Delete Launcher")
return

DELETE_LAUNCHERS_ALL:
	RunAHK("DELETE ALL LAUNCHERS")
return

TERMINATE_RUNNING_CLIENTS:
	RunAHK("Kill All Active Clients")
return
;end of utility calls


RunAHK(ahkName){
	;play notifcation feed back sound.
	SoundPlay, %A_WinDir%\Media\notify.wav
	;run the desired utility script
	path := % """" . A_ScriptDir . "\utilities\" . ahkName . ".ahk" . """"
	run %A_AhkPath% %path%
}

;Indicate that the script should exit automatically when the window is closed.
GuiClose:
	ExitApp
return