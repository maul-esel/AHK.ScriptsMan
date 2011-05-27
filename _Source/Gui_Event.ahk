OnTreeAction:

if (A_GuiEvent = "RightClick") {
	
	On_TVContext(A_EventInfo)

} else if (A_GuiEvent = "S") {

	id := A_EventInfo
	if (Resources[Resources.ActiveID].type = "project")
		Resources[Resources.ActiveID].Save2Obj()
		
	Loop 7
		WinHide % "ahk_id " Gui["Panel" A_Index + 1]
		
	if (Resources[id].context = "resource")
		Resources[id].OpenResource()
	else
		Resources[_id].OpenProject()
	Resources.ActiveID	:=	id	
	
	panel :=  Resources[id].type = "project" ? Gui.Panel5 
			: (Resources[id].type = "file" || Resources[id].type = "library") && Resources[id].context = "resource" ?	Gui.Panel4
			: (Resources[id].type = "file" || Resources[id].type = "library") && Resources[id].context = "project"	?	Gui.Panel7
			: Resources[id].type = "resource_parent" ? Gui.Panel8
			: Resources[id].type = "task_parent" ? Gui.Panel2 : 0
	WinShow ahk_id %panel%
	
	}
return
; **********************************************************************************************************************************************************************
MainWinClose:
OnExit
	
if (Resources[Resources.ActiveID].type = "project")
	Resources[Resources.ActiveID].Save2Obj()

For id, resource in Resources
	{
	if (resource.type = "project")
		resource.Save2File(false)
		
	Resources.Remove(id, "")
	}
	
Gui 1: Destroy
SCI_Finish(hSCIModule)

ExitApp
return
; **********************************************************************************************************************************************************************
On_TVContext(sID) {
global Resources

if (Resources[sID].Type = "library"			&&	Resources[sID].context = "resource"){
	
} else if (Resources[sID].Type = "file"		&&	Resources[sID].context = "resource"){
	
} else if (Resources[sID].Type = "library"	&&	Resources[sID].context = "project"){
	
} else if (Resources[sID].Type = "file"		&&	Resources[sID].context = "project"){
	
} else if (Resources[sID].Type = "project"){
	
	}

return
}

_EventHandler(sHwnd, sEvent, sText, sPosition, sID){
global Data_Manager

if (sEvent != "click")
	return

Tooltip % sID

if (sID = 212) { ; treeview: about
	MsgBox 262208, Scripts.View - about, 
		(,
This little app called 'Scripts.View' was coded by maul.esel.
Copyright (c) maul.esel, 2011
For this purpose, I used lots of external software and code.
So credits go to:
	(1) Chris Mallett for creating AutoHotkey (AHK), the best scripting language ever.
	(2) Steve Gray (Lexikos) for going on developing AHK to AutoHotkey_L / AutoHotkey v2, which added many new features.
	(3) Again Chris for the excellent documentation which made learning AutoHotkey that easy.
	(4) majkinetor for coding lots of functions and modules and wrapping features to AutoHotkey, especially:
		a) Toolbar
		b) Panel
		c) HiEdit
		d) the entire Forms framework
	(5) Antonis Kyprianou for developing HiEdit-control
		--> HiEdit control is copyright of Antonis Kyprianou (aka akyprian).  See http://www.winasm.net.
	(6) polyethene / Titan for xpath() which is used to get & save xml content.
For more information see the documentation.

*****************************************************************************************************************************
*****************************************************************************************************************************	

'Scripts.View' wurde entwickelt von maul.esel.
Copyright (c) maul.esel, 2011
Dazu habe ich sehr viel externe Software und externen Code genutzt.
Darum danke ich:
	(1) Chris Mallett für AutoHotkey (AHK), die beste Skript-Sprache.
	(2) Steve Gray (Lexikos) für die Weiterentwicklung von AHK zu AutoHotkey_L / AutoHotkey v2 mit vielen neuen Funktionen.
	(3) Noch einmal Chris für die exzellente Doku, die das Lernen von AutoHotkey so einfach macht.
	(4) majkinetor für zahlreiche Module und das Wrappen von Funktionen für AHK, im Besonderen:
		a) Toolbar
		b) Panel
		c) HiEdit
		d) das gesamte Forms framework
	(5) Antonis Kyprianou für die Entwicklung der HiEdit-control
		--> HiEdit ist copyright von Antonis Kyprianou (aka akyprian).  Siehe http://www.winasm.net.
	(6) polyethene / Titan für xpath() zum Einlesen und Speichern der XML-Daten.
Weitere Informationen sind in der Dokumentation enthalten.
	)
} else if (sID = 231) { ; quickedit: openressource
	Gui 1: +OwnDialogs
	InputBox _ID, Scripts.View, % XML_Translation("UserInterface/Dialogs/EditRessource")
} else if (sID = 241) {
	WinShow % "ahk_id " Gui["Panel" 3]
} else if (sID = 281){ ; resources: copy id
	Gui 1: Listview, Resource_LV
	if !_Temp := LV_GetNext(0)
		_Temp := 1
	LV_GetText(_Temp, _Temp, 3)
	, Clipboard := _Temp
	}
return
}

Restart:
Reload
return
; **********************************************************************************************************************************************************************
ClickList:
;if (A_GuiEvent = "RightClick" && A_GuiControl != "ResourceData_LV" && A_GuiControl != "Resource_Projects_LV")
;	Menu, Context_%A_GuiControl%, Show
if IsFunc(A_GuiControl)
	%A_GuiControl%(A_GuiEvent, A_EventInfo)
return
; **********************************************************************************************************************************************************************
SelectLanguage:
return
; **********************************************************************************************************************************************************************
OpenHelp:
If FileExist(A_ScriptDir . "\AHK.ScriptsMan.chm")
	run AHK.ScriptsMan.chm
return
; **********************************************************************************************************************************************************************
BrowseAHK_B_EXE:
SVS_BrowseAHK_Exe("B")
return
; **********************************************************************************************************************************************************************
BrowseAHK_L_EXE:
SVS_BrowseAHK_Exe("L")
return
; **********************************************************************************************************************************************************************
BrowseAHK_I_EXE:
SVS_BrowseAHK_Exe("I")
return
; **********************************************************************************************************************************************************************
BrowseScriptDir:
FileSelectFolder ScriptDir, *%A_ProgramFiles%, 3, % XML_Translation("/UserInterface/Dialogs/BrowseScriptDir")
if not ScriptDir
	return
GuiControl 1:, PathScripts, %ScriptDir%
SVS_SetSetting("paths/ScriptDir", ScriptDir)
return
; **********************************************************************************************************************************************************************
RememberTasks:
return

WM_Notify(wparam, lparam, msg, hwnd){

sender := NumGet(lparam + 0)
Loop 3
	if (sender = Gui["SCI" A_Index ])
		return SCI_onNotify(wparam, lparam, msg, hwnd)
Loop 8
	if (sender = Gui["Toolbar" A_Index ])
		return Toolbar_onNotify(wparam, lparam, msg, hwnd)
Loop 8
	if (sender = Gui["Panel" A_Index])
		return Panel_wndProc(hwnd, msg, wparam, lparam)

return
}

SCI_onNotify(wparam, lparam, msg, hwnd){
static SCN_STYLENEEDED := 2000, SCN_CHARADDED := 2001, SCN_SAVEPOINTREACHED := 2002, SCN_SAVEPOINTLEFT := 2003, SCN_MODIFYATTEMPTRO := 2004, SCN_KEY := 2005
, SCN_DOUBLECLICK := 2006, SCN_UPDATEUI := 2007, SCN_MODIFIED := 2008, SCN_MACRORECORD := 2009, SCN_MARGINCLICK := 2010, SCN_NEEDSHOWN := 2011, SCN_PAINTED := 2013
, SCN_USERLISTSELECTION := 2014, SCN_URIDROPPED := 2015, SCN_DWELLSTART := 2016, SCN_DWELLEND := 2017, SCN_ZOOM := 2018, SCN_HOTSPOTCLICK := 2019
, SCN_HOTSPOTDOUBLECLICK := 2020, SCN_CALLTIPCLICK := 2021, SCN_AUTOCSELECTION := 2022, SCN_INDICATORCLICK := 2023, SCN_INDICATORRELEASE := 2024
, SCN_AUTOCCANCELLED := 2025, SCN_AUTOCCHARDELETED := 2026, SCN_HOTSPOTRELEASECLICK := 2027
	
sender	:= NumGet(lparam + 0, 0, "UInt")
if (sender != Gui.SCI1)
	return
	
code	:= NumGet(lparam + 0, 8, "UInt")
_lang	:= Documents[Documents.Active].SyntaxLanguage := "Ini"

if (code = SCN_STYLENEEDED) {
	If IsFunc(fn := _lang "_ScnStyleNeeded")
		return %fn%(sender, lparam)
} else if (code = SCN_CHARADDED) {
	If IsFunc(fn := _lang "_ScnCharAdded")
		return %fn%(sender, lparam)
} else if (code = SCN_SAVEPOINTREACHED) {
	Toolbar_SetButton(Gui.Toolbar3, "." _ID, "disabled") ; TODO: define button id and enter
	if IsFunc(fn := _lang "_ScnSavePointReached")
		return %fn%(sender)
	}

return
}