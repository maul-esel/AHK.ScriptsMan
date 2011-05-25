OnTreeAction:

if (A_GuiEvent = "RightClick") {
	On_TVContext(A_EventInfo)
	}

else if (A_GuiEvent = "S") {

	_id := A_EventInfo
	if (Resources[_id].type = "project") {
	
		Loop 7
			SPanel_FadeOut(A_Index + 1)

		Project_Save2Obj()
		Project_Open(_id) ;																																			[panel 5]
		SPanel_FadeIn(5)
		Resources.ActiveID := _id
		
	} else if (Resources[_id].type = "file"		&&	Resources[_id].context = "resource") {
		
		Loop 7
			SPanel_FadeOut(A_Index + 1)

		File_OpenResource(_id) 	; zeigt panel mit info zu datei an (userdata, projects, default properties)	Möglichkeit: switch-to editing							[panel 4]
		SPanel_FadeIn(4)
		Resources.ActiveID := _id
		
	} else if (Resources[_id].type = "library"	&&	Resources[_id].context = "resource") { ; ähnlich wie oben, inkl. editing-Möglichkeit	[panel 4]
	
		Loop 7
			SPanel_FadeOut(A_Index + 1)

		Library_OpenResource(_id)
		SPanel_FadeIn(4)
		Resources.ActiveID := _id
		
	} else if (Resources[_id].type = "file"		&&	Resources[_id].context = "project") { ; ähnlich zu file/resource, aber:			[panel 7]
																								; + inkl. projects
																								; + inkl. private user data
																								; + inkl. button: switch to file/resource
																								; - ohne editing-Möglichkeit
		Loop 7
			SPanel_FadeOut(A_Index + 1)

		File_OpenProject(_id)
		SPanel_FadeIn(7)
		Resources.ActiveID := _id
		
	} else if (Resources[_id].type = "library"	&&	Resources[_id].context = "project"){ ; ähnlich wie oben								[panel 7]
	
		Loop 7
			SPanel_FadeOut(A_Index + 1)

		Library_OpenProject(_id)
		SPanel_FadeIn(7)
		Resources.ActiveID := _id
		
	} else if (Resources[_id].type = "resource_parent") {	;																							[panel 8]
	
		Loop 7
			SPanel_FadeOut(A_Index + 1)

		SPanel_FadeIn(8)
		Resources.ActiveID := _id
		
	} else if (Resources[_id].type = "task_parent"){ ; all tasks																						[panel 2]
	
		Loop 7
			SPanel_FadeOut(A_Index + 1)

		SPanel_FadeIn(2)
		Resources.ActiveID := _id
		
		}
	;													Treeview																									[panel 1]
	;													project > tasks																								[panel 6]
	;													editing																										[panel 3]
	}
return
; **********************************************************************************************************************************************************************
MainWinClose:
if A_IsCompiled
	DllCall("AnimateWindow", "UInt", Gui.WindowHandle, "Int", 500, "UInt", 0x00010000|0x00080000)
Project_Save2Obj()

For id, resource in Resources
	{
	if (resource.type = "project")
		Project_Save2File(id)	
	}
	
SVS_SaveSettings()
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
Copyright ?maul.esel, 2011
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
	SPanel_MoveUp(3)
} else if (sID = 281){ ; resources: copy id
	Gui 1: Listview, Resource_LV
	if !_Temp := LV_GetNext(0)
		_Temp := 1
	LV_GetText(_Temp, _Temp, 3)
	, Clipboard := _Temp
	}
return
}

SwitchPanel43:
if (!Data_Manager.Panel3.visible){
	SPanel_MoveUp(3)
	SPanel_FadeOut(4)
} else {
	SPanel_FadeIn(4)
	SPanel_MoveDown(3)
	}
DllCall("SetParent", "UInt", Data_Manager.Switcher1, "UInt", Data_Manager.Panel3.visible ? Data_Manager.Panel4.visible : Data_Manager.Panel3.visible)
, Data_Manager.Panel3.visible := !Data_Manager.Panel3.visible
return

WM_Notify(wparam, lparam, msg, hwnd){
global Data_Manager

sender := NumGet(lparam + 0, 0, "UInt")
Loop 3
	if (sender = Data_Manager["SCI" A_Index ].Handle)
		return SCI_onNotify(wparam, lparam, msg, hwnd)
Loop 8
	if (sender = Data_Manager["Toolbar" A_Index ].Handle)
		return Toolbar_onNotify(wparam, lparam, msg, hwnd)
return
}

SCI_onNotify(wparam, lparam, msg, hwnd){
global Data_Manager
static SCN_STYLENEEDED := 2000, SCN_CHARADDED := 2001, SCN_SAVEPOINTREACHED := 2002, SCN_SAVEPOINTLEFT := 2003, SCN_MODIFYATTEMPTRO := 2004, SCN_KEY := 2005
, SCN_DOUBLECLICK := 2006, SCN_UPDATEUI := 2007, SCN_MODIFIED := 2008, SCN_MACRORECORD := 2009, SCN_MARGINCLICK := 2010, SCN_NEEDSHOWN := 2011, SCN_PAINTED := 2013
, SCN_USERLISTSELECTION := 2014, SCN_URIDROPPED := 2015, SCN_DWELLSTART := 2016, SCN_DWELLEND := 2017, SCN_ZOOM := 2018, SCN_HOTSPOTCLICK := 2019
, SCN_HOTSPOTDOUBLECLICK := 2020, SCN_CALLTIPCLICK := 2021, SCN_AUTOCSELECTION := 2022, SCN_INDICATORCLICK := 2023, SCN_INDICATORRELEASE := 2024
, SCN_AUTOCCANCELLED := 2025, SCN_AUTOCCHARDELETED := 2026, SCN_HOTSPOTRELEASECLICK := 2027

if (NumGet(lparam + 0, 0, "UInt") != Data_Manager.SCI1.Handle)
	return
	
sender := NumGet(lparam + 0, 0, "UInt")
code := NumGet(lparam + 0, 8, "UInt")
_lang := Data_Manager.Documents[Data_Manager.Documents.Active].SyntaxLanguage := "Ini"
if (code = SCN_STYLENEEDED) {
	If IsFunc(fn := _lang "_ScnStyleNeeded")
		return %fn%(sender, lparam)
} else if (code = SCN_CHARADDED) {
	If IsFunc(fn := _lang "_ScnCharAdded")
		return %fn%(sender, lparam)
} else if (code = SCN_SAVEPOINTREACHED) {
	Toolbar_SetButton(Data_Manager.Toolbar3.Handle, "." _ID, "disabled") ; TODO: define button id and enter
	if IsFunc(fn := _lang "_ScnSavePointReached")
		return %fn%(sender)
	}

return
}