#SingleInstance force

;user set value
CLIENT_TITLE := NOT_SET

;priror directory
DIRECTORY := RegExReplace(A_ScriptDir,"[^\\]+\\?$")

;path of runelite client
global CONFIG_TITLE := ""
;grab user set client path
IniRead, CONFIG_TITLE, %DIRECTORY%\lib\PathData.ini, ClientTitle, key


;ask user for a file name until they select something valid.
While(CLIENT_TITLE = NOT_SET){
    InputBox, UserInput, Setup, Enter the name of your client (Currently : %CONFIG_TITLE%), , 250,140
    if ErrorLevel
    {
        ExitApp
    }else{
		CLIENT_TITLE = %UserInput%
		;ensure user has selected a title before prompt
		if(CLIENT_TITLE != NOT_SET){
			;inform user of new client title to verify
			MsgBox, 64, Information, Kill script will now kill all instances of :`n[%UserInput%]
			;write client title to config file
			IniWrite, %UserInput%, %DIRECTORY%\lib\PathData.ini, ClientTitle, key
		}
    }
}
