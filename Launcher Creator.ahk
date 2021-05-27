#SingleInstance force

;prevent user from running script in its zipped form.
;when ran inside an archive its placed in a temporary folder on its own isolated meaning that is the only file
fileCount := 0
Loop, %A_ScriptDir%\*.*
  fileCount++
if(fileCount == 1){
;One file count means its in temp and thus ran from an archive, or user is missing files.
    MsgBox "This script is running from the archived zip file, please extract the entire folder before running this program."
    ExitApp
}

;user set file name
FileName := NOT_SET
FileExt := .ahk

;user set file name+extension
FileNameFull := NOT_SET

;user set settings file to use
SettingsBase := "NOT_SET"
SETTINGS_BASE_IDENTIFIER := "SETTINGS_BASE_NAME := "

;user set client count
ClientCount = 0
;search string, to replace client count in pending file
CLIENT_COUNT_IDENTIFIER := "CLIENT_COUNT := "

;directory to create launcher in
LAUNCHER_DIRECTORY := % A_ScriptDir . "\Launchers\"

;path of .runelite (read from config file)
SETTINGS_PATH = "NULL"
IniRead, SETTINGS_PATH, %A_ScriptDir%\lib\PathData.ini, Settings, key
;user hasn't set a settings path, assume the default location.
if(SETTINGS_PATH = "NOT_SET"){
	SETTINGS_PATH = %userprofile%\.runelite\
}
;append settings to the path
SETTINGS_PATH := % SETTINGS_PATH . "\settings\"
 
;ask user for a file name until they select something valid.
While(fileName = NOT_SET){
    InputBox, UserInput, Setup, Choose your launcher name, , 250,130
    if ErrorLevel
    {
        ExitApp
    }else{
        if !FileExist(LAUNCHER_DIRECTORY . UserInput . FileExt){
            FileName = %UserInput%
        }else{
            MSGBox, 52, , File already exists, would you like to replace it?
            IfMsgBox, No 
            {
                ;for readability, the user decided not to replace the file, ask them again for a name
            }else{
                ;the user wants to overwrite, proceed as normal replacing will automatically occur
                FileName = %UserInput%
            }
        }
    }
}

;RuneLite has issues when properties file names contain spaces
FileName := % StrReplace(FileName, " ", "_")
FileNameFull = %FileName%%FileExt%

;ask user for number of clients until they choose a valid number between 1 and 10
While(ClientCount = 0){
    InputBox, UserInput, Setup, Choose your number of clients (1-10), , 250,130
    if ErrorLevel
    {
        ExitApp
    }else if UserInput is integer
    {
        if(UserInput >= 1 && UserInput <= 10){
            ;input is a number and its within range, set clientcount
            ClientCount := % UserInput
        }
    }
}

MSGBox, 36, , Are your settings currently synced to an email?(runelites-login feature)
IfMsgBox, No 
{
    ;for readability, user wants to select their offline settings file continue as normal.
}Else{
    ;inform user they need to select their settings file from their profile
    MsgBox, 64, , Logged-in settings are saved in .runelite/profiles, please select your desired settings file it will be called settings
    ;redirect user to their profile page and wait for them to select their settings file.
    FileSelectFile, SelectedFile, 3, %USERPROFILE%\.runelite\profiles, Locate Settings.properties in .runelite/profiles, (*.properties)
    if (SelectedFile = ""){
        ;no file selected terminate app, assume user made a mistake or decided to end the process.
        ExitApp
    }else{
        ;user selected file set it
        SettingsBase := % SelectedFile
    }
}

;settings have not yet been set meaning user wants to select an offline settings file.
if(SettingsBase = "NOT_SET"){
    ;ask user to select their desired settings file to use as a base
    ;the newly generated settings files will be copys of this file with different names but become their own entity subject to user change
    InputBox, UserInput, Setup, Choose your setting base file             (blank if default), , 250,150
    if ErrorLevel
        ;user cancelled, terminate app
        ExitApp
    else if UserInput =
        ;you would think you'd evaluate empty quotes, but ahk says otherwise.
        ;user input nothing, default to normal settings file.
        SettingsBase = settings
    else
        ;user input a file name, path is not required as the launcher will automatically find it.
        SettingsBase = %UserInput%
}

;check if the settings already exist, as the user confirmed prior, we're deleting the old settings.
delDir := % SETTINGS_PATH . FileName
IfExist, %delDir%
    FileRemoveDir, %delDir%, 1
;create new directory for the launcher we're creating
;this happens prior to launch so the user can delete the launcher prior to running if they chose to do so.
FileCreateDir, %delDir%

;surround settingsbase in quotes to pass the argument correctly.
SettingsBase := """" . SettingsBase . """"
    
;read data file of the launcher for copy.
FileRead, Var1, lib\Launcher.dat
;replace client count in the copy, to user set value
StringReplace, Var2, Var1, CLIENT_COUNT := -1,% CLIENT_COUNT_IDENTIFIER . ClientCount, All
;replace base settings file name in the copy, to user set value
StringReplace, Var3, Var2, SETTINGS_BASE_NAME := "settings",% SETTINGS_BASE_IDENTIFIER . SettingsBase, All
;delete launcher if it already exists, it shouldnt at this point in time but sanity check.
FileDelete, Launchers\%FileNameFull%
;create launcher with our copied/modifed version of the data file
FileAppend, %Var3%, Launchers\%FileNameFull%

;inform user the launcher has been created
MsgBox % "[" . FileNameFull . "]" . " - Created in /Launchers"
;open the folder holding the launcher if not already open otherwise focuses it.
Run, %LAUNCHER_DIRECTORY%

;run the buttons script(only initiates if its already running) with the paramater telling it to refresh as the directory has updated.
DIRECTORY := % A_ScriptDir . "\"
run %A_AhkPath% %DIRECTORY%\"Buttons.ahk" 1
