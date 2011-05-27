Menu Tray, NoStandard
Menu Tray, Add, % XML_Translation("/UserInterface/TrayMenu/Item", 1), OpenHelp
Menu Tray, Add
Menu Tray, Add, % XML_Translation("/UserInterface/TrayMenu/Item", 2), Restart
Menu Tray, Add, % XML_Translation("/UserInterface/TrayMenu/Item", 3), MainWinClose
Menu Tray, Tip, Scripts.View`n----------------------------------`nfree`, open-source`, multilingual`nand customizable software

Gui 1: +OwnDialogs +MaximizeBox +LabelMainWin
Gui 1: Font,	s10,	Calibri
Gui 1: Color,	white
Gui 1: +LastFound
Gui := { "WindowHandle" : WinExist()}

;Create_Menus()

ListOptions := "Backgroundwhite cblack Sort -LV0x10 -Multi gClickList altSubmit 0x4000000"
; ******************************************************************************************************************************************************************************************
; >>> TODO: detect screen width etc. --> relative Größen
Data_Manager.Window					:=	{}
Data_Manager.Window.Height			:=	1050
Data_Manager.Window.Width			:=	1550
Data_Manager.Window.ToolWidth		:=	Data_Manager.Window.Width / 20
Data_Manager.Window.ToolHeight		:=	Data_Manager.Window.Height / 12

Loop 8 {
	Gui["Panel" A_Index ]	:=	Panel_Add(Gui.WindowHandle
										, A_Index = 1 ? 0 : 350
										, 0
										, A_Index = 1 ? 350 : Data_Manager.Window.Width - 345
										, A_Index = 6 ? 600 : Data_Manager.Window.Height
										, A_Index = 3 ? "border static" : "")
	}
; ******************************************************************************************************************************************************************************************
Gui.Toolbar1		:=	Toolbar_Add(Gui.Panel1,	"_EventHandler",	"flat border tooltips",		SVS_IL(3,	0,	1, 1), "y0 x25 h50 w" 300) ; >>> adjust + realize
Gui.Toolbar2		:=	Toolbar_Add(Gui.Panel2,	"_EventHandler",	"flat border tooltips",		SVS_IL(3,	32, 1, 1), "y0 x0  h50 w" Data_Manager.Window.Width - 350) ; >>> adjust
Gui.Toolbar3		:=	Toolbar_Add(Gui.Panel3,	"_EventHandler",	"flat border tooltips",		SVS_IL(5,	20, 1, 1), "y0 x0  h50 w" Data_Manager.Window.Width - 350)
Gui.Toolbar4		:=	Toolbar_Add(Gui.Panel4,	"_EventHandler",	"flat border tooltips",		SVS_IL(3,	32, 1, 1), "y0 x0  h50 w" Data_Manager.Window.Width - 350) ; >>> adjust
Gui.Toolbar5		:=	Toolbar_Add(Gui.Panel5,	"_EventHandler",	"flat border tooltips",		SVS_IL(4,	16, 1, 1), "y0 x0  h50 w" Data_Manager.Window.Width - 350) ; >>> adjust
Gui.Toolbar6		:=	Toolbar_Add(Gui.Panel6, "_EventHandler",	"flat border tooltips",		SVS_IL(3,	32, 1, 1), "y0 x0  h50 w" Data_Manager.Window.Width - 350) ; >>> adjust
Gui.Toolbar7		:=	Toolbar_Add(Gui.Panel7, "_EventHandler",	"flat border tooltips",		SVS_IL(3,	32,	1, 1), "y0 x0  h50 w" Data_Manager.Window.Width - 350)
Gui.Toolbar8		:=	Toolbar_Add(Gui.Panel8, "_EventHandler",	"flat border tooltips",		SVS_IL(3,	32,	1, 1), "y0 x0  h50 w" Data_Manager.Window.Width - 350)
Loop 8 {
	Toolbar_Insert(			Gui["Toolbar" A_Index ],	SVS_Toolbuttons(A_Index))
	Toolbar_SetButtonSize(	Gui["Toolbar" A_Index ],	50)
	Toolbar_SetMaxTextRows(	Gui["Toolbar" A_Index ],	0)
	}
; ******************************************************************************************************************************************************************************************
Gui, Add, Tab2, vSCIEditTab hwndC_01 x0 y100 w1200 h900 altSubmit, %A_Space%
DllCall("SetParent", "UInt", Gui.Tab := C_01, "UInt", Gui.Panel3)
; ******************************************************************************************************************************************************************************************
Gui.SCI1			:=	SCI_Add(Gui.Tab,	0,	25,		1200,	875)
Gui.SCI2			:=	SCI_Add(Gui.Panel5,	0,	560,	600,	430)
Gui.SCI3			:=	SCI_Add(Gui.Panel6,	0,	100,	600,	430)
Documents.Active			:=	SCI_GetDocPointer(Gui.SCI1)
Documents[Documents.Active]	:=	{}
Tab_SetLParam(Gui.Tab, 1, Documents.Active)
;MsgBox % SCI_GetLexer(Gui.SCI1)
/*_Temp=
	(LTrim
	Text=0x000000
	Back=0xFFFFFF
	SelText=0x000000
	ActSelBack=0x5160FF
	InSelBack=0xD6D6D6
	LineNumber=0xFF0000
	SelBarBack=0x999999
	NonPrintableBack=0x000000
	Number=0x0000FF
	)
*/
Loop 3 {
	SCI_SetFont(				Gui["SCI" A_Index ], 		A_Index = 2 ? "Calibri" : "Courier New") ;!
	SCI_LineNumbersBarWidth(	Gui["SCI" A_Index ],		A_Index = 2 ? 0 : 25)
	SCI_SetIndentationGuides(	Gui["SCI" A_Index ],		2)
	SCI_SetWrapMode(			Gui["SCI" A_Index ],		1)
	SCI_SetWrapStartIndent(		Gui["SCI" A_Index ],		5)
	SCI_SetKeysUnicode(			Gui["SCI" A_Index ],		true)
;>>> HE_SetColors(Gui["HiEdit" A_Index ].Handle,		_Temp,	1)
	}
;>>> HE_SetKeyWordFile(A_ScriptDir "\#Data\KeywordsAHKB.hes")
; ******************************************************************************************************************************************************************************************
; controls on Panel1
_Temp := SVS_IL(5, 8, 0)
Gui 1: Add,	Treeview,	Backgroundwhite cblack -0x4 -0x1 0x20 altSubmit imagelist%_Temp% x25 y50 w300 h950 hwndC_01 vResourceTree gOnTreeAction
Gui.Treeview := {}
Gui.Treeview.Handle := C_01
Gui.Treeview.ImageList := _Temp
DllCall("SetParent",		"UInt", Gui.Treeview.Handle, "UInt", Gui.Panel1)
DllCall("SetClassLong",	"UInt", Gui.Treeview.Handle, "UInt", -12, "UInt", DllCall("LoadCursorW", "UInt", 0, "UInt", 32649))
TV_SetStateImageList(Gui.Treeview.Handle, Gui.Treeview.StateIL := SVS_IL(4, 4, 0))
; ******************************************************************************************************************************************************************************************
; controls on Panel2
Gui	Add,	Listview,	x0		y50	w1200	h950	%ListOptions% hwndC_01 vCommonTasks_LV,			% SVS_GetLVHeader("Tasks")
DllCall("SetParent", "UInt", C_01, "UInt", Gui.Panel2)
; ******************************************************************************************************************************************************************************************
; controls on Panel4
Gui 1: Add, Text,		x0 		y50		w1200	h150	0x1000		 	hwndC_01 vResourceInfo
Gui 1: Add,	ListView,	x0		y225	w1200	h175	%ListOptions%	hwndC_02 vResourceUserData_LV,	% SVS_GetLVHeader("Resources/UserData")
Gui 1: Add,	ListView,	x0		y425	w1200	h175	%ListOptions%	hwndC_03 vResourceProjects_LV,	% SVS_GetLVHeader("Resources/Projects")
Loop 3 {
	Nr := (A_Index < 10 ? 0 . A_Index : A_Index)
	DllCall("SetParent", "UInt", C_%Nr%, "UInt", Gui.Panel4)
	VarSetCapacity(C_%Nr%, 0)
	}
; ******************************************************************************************************************************************************************************************
; controls on Panel5
Gui 1: Add,	ListView,	x0		y50		w1200	h250	%ListOptions% hwndC_01 vProjectFiles_LV,		% SVS_GetLVHeader("Projects/Files")
Gui 1: Add,	ListView,	x0		y300	w600	h225	%ListOptions% hwndC_02 vProjectLibraries_LV,	% SVS_GetLVHeader("Projects/Libraries")
Gui 1: Add,	ListView,	x600	y300	w600	h225	%ListOptions% hwndC_03 vProjectUserData_LV,		% SVS_GetLVHeader("Projects/UserData")

Gui 1: Add,	Text,		x625	y560	w200			0x1000		hwndC_04,				% XML_Translation("/UserInterface/MainGui/Projects/properties/property", 1)
Gui 1: Add,	Combobox,	x675	y585	w525			sort		hwndC_05	vStatDDL,	% XML_Translation("/DefaultOptions/Status")

Gui 1: Add, Text,		x625	y630	w200			0x1000		hwndC_06,				% XML_Translation("/UserInterface/MainGui/Projects/properties/property", 2)
Gui 1: Add, Checkbox,	x675	y655	w125	h30		0x1000		hwndC_07	vAHKB,		AHK (Basic)
Gui 1: Add, Checkbox,	xp+125	yp		w125	h30		0x1000		hwndC_08	vAHKL,		AHK_L
Gui 1: Add, Checkbox,	xp+125	yp		w125	h30		0x1000		hwndC_09	vAHKI,		IronAHK
Gui 1: Add, Checkbox,	xp+125	yp		w125	h30		0x1000		hwndC_10	vAHK2,		AHK v2

Gui 1: Add, Text,		x625	y700	w200			0x1000		hwndC_11,				% XML_Translation("/UserInterface/MainGui/Projects/properties/property", 3)
Gui 1: Add, Combobox,	x675	y725	w525			sort		hwndC_12	vTypCombo,	% XML_Translation("/DefaultOptions/Type")

Gui 1: Add, Text,		x625	y770	w200			0x1000		hwndC_13,				% XML_Translation("/UserInterface/MainGui/Projects/properties/property", 4)
Gui 1: Add, Edit,		x675	y795	w525	r5					hwndC_14	vGoalEdit

Gui 1: Add, Text,		x625	y930	w200			0x1000		hwndC_15,				% XML_Translation("/UserInterface/MainGui/Projects/properties/property", 5)
Gui 1: Add, Edit,		x675	y955	w525	r1		ReadOnly	hwndC_16	vLModEdit

Loop 16 {
	Nr := (A_Index < 10 ? 0 . A_Index : A_Index)
	DllCall("SetParent", "UInt", C_%Nr%, "UInt", Gui.Panel5)
	VarSetCapacity(C_%Nr%, 0)
	}
; ******************************************************************************************************************************************************************************************
; controls auf Panel6
Gui 1:	Add,	ListView,	x0 y50 w1200 h950 %ListOptions% hwndC_01 vProjectTasks_LV, % SVS_GetLVHeader("Tasks")
DllCall("SetParent", "UInt", C_01, "UInt", Gui.Panel6)
; ******************************************************************************************************************************************************************************************
Gui 1: Add,	ListView,	x0 y50 w1200 h950 %ListOptions% hwndC_01 vResource_LV, % SVS_GetLVHeader("Resources")
Loop 1 {
	Nr := (A_Index < 10 ? 0 . A_Index : A_Index)
	DllCall("SetParent", "UInt", C_%Nr%, "UInt", Gui.Panel8)
	VarSetCapacity(C_%Nr%, 0)
	}
; ******************************************************************************************************************************************************************************************
Loop 6
	WinHide % "ahk_id " Gui["Panel" A_Index + 2]

	
	
	
/*
Gui 1: Listview, Projects_LV
	LV_SetImageList( SVS_IL(4, 2, 0), 1)
Gui 1: Listview, Files_LV
	LV_SetImageList( SVS_IL(3, 6, 0), 1)
Gui 1: Listview, ResourceFile_LV
	LV_SetImageList( SVS_IL(3, 6, 0), 1)
; **********************************************************************************************************************************************************************
Gui 1: Add,	Text,		x975	y560								hwndC_01,				% XML_Translation("Descriptions",	"Text.2.1")
Gui 1: Add,	Combobox,	x1000	y585	w550			sort		hwndC_02	vStatDDL,	% XML_Translation("Misc.",			"Standard.Status")

Gui 1: Add, Text,		x975	y630								hwndC_03,				% XML_Translation("Descriptions",	"Text.2.2")
Gui 1: Add, Checkbox,	x1000	y655	w150	h30		0x1000		hwndC_04	vAHKB,		AHK (Basic)
Gui 1: Add, Checkbox,	xp+200	yp		w150	h30		0x1000		hwndC_05	vAHKL,		AHK_L
Gui 1: Add, Checkbox,	xp+200	yp		w150	h30		0x1000		hwndC_06	vAHKI,		IronAHK

Gui 1: Add, Text,		x975	y700								hwndC_07,				% XML_Translation("Descriptions",	"Text.2.3")
Gui 1: Add, Combobox,	x1000	y725	w550			sort		hwndC_08	vTypCombo,	% XML_Translation("Misc.",			"Standard.Type")

Gui 1: Add, Text,		x975	y770								hwndC_09,				% XML_Translation("Descriptions",	"Text.2.4")
Gui 1: Add, Edit,		x1000	y795	w550	r5					hwndC_10	vGoalEdit

Gui 1: Add, Text,		x975	y930								hwndC_11,				% XML_Translation("Descriptions",	"Text.2.5")
Gui 1: Add, Edit,		x1000	y955	w550	r1		ReadOnly	hwndC_12	vLModEdit

; **********************************************************************************************************************************************************************
Gui 1: Add, Text,		x75		y125			w200	0x1000	hwndC_01,						% XML_Translation("Descriptions",	"Text.6.1")
Gui 1: Add, Edit,		x300	y125			w450	0x400	hwndC_02	vPath7zip,			% XML_Get("general",				"path.7zip")
Gui 1: Add, Button,		x750	y125			w150			hwndC_03	gBrowse7zip,		% XML_Translation("Misc.",			"Command.Browse")

Gui 1: Add, Text,		x75		y175			w200	0x1000	hwndC_04,						% XML_Translation("Descriptions",	"Text.6.2")
Gui 1: Add, Edit,		x300	y175			w450	0x400	hwndC_05	vPathAHK_B_EXE,		% XML_Get("general",				"path.AHK.B")
Gui 1: Add, Button,		x750	y175			w150			hwndC_06	gBrowseAHK_B_EXE,	% XML_Translation("Misc.",			"Command.Browse")

Gui 1: Add, Text,		x75		y225			w200	0x1000	hwndC_07,						% XML_Translation("Descriptions",	"Text.6.3")
Gui 1: Add, Edit,		x300	y225			w450	0x400	hwndC_08	vPathAHK_L_EXE,		% XML_Get("general",				"path.AHK.L")
Gui 1: Add, Button,		x750	y225			w150			hwndC_09	gBrowseAHK_L_EXE,	% XML_Translation("Misc.",			"Command.Browse")

Gui 1: Add, Text,		x75		y275			w200	0x1000	hwndC_10,						% XML_Translation("Descriptions",	"Text.6.4")
Gui 1: Add, Edit,		x300	y275			w450	0x400	hwndC_11	vPathAHK_I_EXE,		% XML_Get("general",				"path.AHK.I")
Gui 1: Add, Button,		x750	y275			w150			hwndC_12	gBrowseAHK_I_EXE,	% XML_Translation("Misc.",			"Command.Browse")

Gui 1: Add, Text,		x75		y325			w200	0x1000	hwndC_13,						% XML_Translation("Descriptions",	"Text.6.5")
Gui 1: Add, Edit,		x300	y325			w450	0x400	hwndC_14	vPathScripts,		% XML_Get("general",				"ScriptDir")
Gui 1: Add, Button,		x750	y325			w150			hwndC_15	gBrowseScriptDir,	% XML_Translation("Misc.",			"Command.Browse")

Gui 1: Add, Text,		x75		y425			w200	0x1000	hwndC_16,						% XML_Translation("Descriptions",	"Text.6.6")
Gui 1: Add, DDL,		x300	y425			w450	0x1000	hwndC_17	vUserLanguage,		% SVS_GetAvailableLanguages(false)

Gui 1: Add, Checkbox,	x75		y475	h30		w675	0x1000	hwndC_18	vEnableUpdates,		% XML_Translation("Descriptions",	"Text.6.7")
Gui 1: Add, Button,		x75		y525			w675			hwndC_19					,	% XML_Translation("Descriptions",	"Text.6.8")

Gui 1: Add, Text,		x1050	y175			w200	0x1000	hwndC_21,						% XML_Translation("Descriptions",	"Text.6.10")
Gui 1: Add, Edit,		x1275	y175			w200	number	hwndC_22	

GuiControl 1:	ChooseString,	UserLanguage,		% XML_Get("general",	"Language")
*/