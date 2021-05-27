;recieve a parameter, if run from another script(used for refreshing the list upon changes)
wParam = %1%
;allow multiple instances, required for passi
#SingleInstance, OFF
;required for passing params, detect hidden ahk that loads params
DetectHiddenWindows, On
;set working dir incase script ran from outer loc
SetWorkingDir, %A_ScriptDir%

; get hWnd variables of all running instances
WinGet, Instance, List, %A_ScriptFullPath% 
; Force SingleInstance if Null Parameter 
IfGreater, Instance, 1, IfEqual, Wparam,, ExitApp

;Register a windows message with a string unique to this script to detect passed params
MsgNum := DllCall( "RegisterWindowMessage", Str,"ButtonParms" )
If ( wParam != "" )  {
	;Instance2 is actually the hWnd  of 1st instance as in ZORDER, send params
    PostMessage, MsgNum, wParam, 0, , ahk_id %Instance2%
	;close app as this was only open to pass params
    ExitApp
} Else {
    OnMessage( MsgNum, "GoSub" )
}

;setup gui defaults
Gui,1:default
{
;set font
Gui,1: Font, s10, FixedSys
;set background to black
TransColor = 000000
Gui, Color, %transColor%
;add resize event
Gui, +resize
}


;generate a list view
;LV0x00000001 bordered cells
;LV0x00000040 select cursor
;LV0x00000800 underline on hover
Gui, Add, ListView, vMyLV x7 y10 r20 w200 gMyListView LV0x00000040 LV0x00000001 LV0x00000800 altsubmit, Launcher

;fill the list view
GenerateList()

GenerateList(){
	;loop through all.ahk files in launchers folder
	Loop, %A_ScriptDir%\launchers\*.ahk*
	{
		;splitpath of ahk file to extract name
		SplitPath, A_LoopFileLongPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
		;add button with name of the ahk file without extension
		LV_Add("", outNameNoExt)
	}
	
	;set size of list-view buttons
	LV_SetImageList( DllCall( "ImageList_Create", Int,2, Int,40, Int,0x18, Int,1, Int,1 ), 1 )
	;Set text of column 1 to center
	LV_ModifyCol(1,"Center")
	;Auto-size each column to fit its contents.
	LV_ModifyCol()
}

ResizeList(){
	;activate GUI window
	GUI, +LastFound
	;initialize ListView width variable
	totalWidth := 0
	;get columns widths       
	Loop % LV_GetCount("Column")
	{
		;4125 is LVM_GETCOLUMNWIDTH, extract width
		SendMessage, 4125, A_Index - 1, 0, SysListView321
		;set width to extracted width
		totalWidth := totalWidth + ErrorLevel
	}
	;add 50 to width as a base value
	totalWidth := totalWidth+50
	;we want a minimum value of 240 for the width
	if(totalWidth < 200){
		totalWidth := 240
		;set size of coumn to 200
		LV_ModifyCol(1,200)
	}
	;make gui resize based on new width
	Gui, +resize MinSize%totalWidth%x0
	;refresh/show the gui
	Gui, Show,,Launchers
}

listView_autoSize:
	;on resize call our custom resize function
	ResizeList()
	return

GUISize:
	;on set size, set appropriate values
	width:=A_GuiWidth-15
	height:=A_GuiHeight-15
	;move to corrected spot
	guicontrol, move, MyLV, w%width% h%height%
return


MyListView:
;on left click select on a button
if (A_GuiEvent = "Normal")
{
	;deselect active button on click
	LV_Modify(0, "-Select")
	;location of the launcher file that will be active when running a launcher; to prevent multi-launching accidentally.
	loc := % A_ScriptDir . "\lib\LauncherBase.ahk"
	;get list of active launchers to ensure we dont proceed if launcher is active.
	WinGet, Instance, List, %loc%
	IfGreater, Instance, 0
	{
		return
	}
	;Get the text from the row's first field, which will be the name of the launcher
    LV_GetText(RowText, A_EventInfo)
	;location of launcher to run
	LauncherLoc := % A_ScriptDir . "\Launchers\" . RowText . ".ahk"
	;run desired launcher
	run %A_AhkPath% %LauncherLoc%
	;play feedback sound
	SoundPlay, %A_WinDir%\Media\Windows Navigation Start.wav

}
return

;Indicate that the script should exit automatically when the window is closed.
GuiClose:
ExitApp

;param handler
GoSub(wParam) {
 IfEqual, wParam, 1, SetTimer, ReGenerateList, -1
Return True
}

ReGenerateList:
	;delete all list view contents
	LV_Delete()
	;generate list of list view contents
	GenerateList()
	;resize list appropriately
	ResizeList()
Return