Data_List() {
; empty all lists && set -redraw for performance
Gui 1: Default
Gui 1: Treeview, ResourceTree
	TV_Delete()
	GuiControl -Redraw, ResourceTree

Gui 1: ListView, CommonTasks_LV
	LV_Delete()
	GuiControl -Redraw, CommonTasks_LV
	
Gui 1: Listview, Resource_LV
	LV_Delete()
	GuiControl -Redraw, Resource_LV

; create tasks tvitem && add public tasks to the list
Gui 1: Listview, CommonTasks_LV
Resources[ TV_Add("Tasks", 0, "Icon1") ] := {"Type" : "task_parent"}
tasks := (new XMLParser(A_ScriptDir "\Settings.xml")).GetNodes("/Settings/tasks/task")
Loop tasks.length {
	_Temp := tasks.item(A_Index - 1).text
	if not (_Temp)
		break
	LV_Add("", _Temp, XML_Translation("/UserInterface/MainGui/Tasks/Info"))
	}

; add resources tvitem
_ID := TV_Add("Resources", 0, "Icon2 Expand") ; icon: resource_parent
Resources[_ID]	:= {"Type"		:	"resource_parent"
								, "Files"		:	{}
								, "Libraries"	:	{}}

; loop all resources
Resources.List := {}
LoopFiles %A_ScriptDir%\#Data\*.xml
	{
	doc := new XMLParser(A_LoopFileFullPath)
	_ResType := doc.Get("/Resource/@DataType")
	;MsgBox, 4096, %A_ThisFunc%, % A_LoopFileFullPath "`n" A_Index "`n#" _ResType "#"

	
	if (_ResType = "project"){
	
		lid := List_Project(doc, "/Resource", 0, A_LoopFileFullPath)
		
	} else if (_ResType = "file"){

		Gui 1: Listview, Resource_LV
				
		_Name := doc.Get("/Resource/@Name")
		_RID := TV_Add(_Name, _ID, "Icon4") ; icon: resource-file
	
		Resources[_RID]	:=	{"Name"		:	_Name
								, "Type"		:	"file"
								, "context"		:	"resource"
								, "ParentID"	:	0
								, "XML"			:	doc
								, "Tree"		:	"/Resource"
								, "File"		:	A_LoopFileFullPath}
	
		Resources[_ID].Files.Count++
		Resources[_ID].Files["File" A_Index ] := _RID
		LV_Add("", _Name, "file", _RID)
		Resources.List[_Name] := _RID
		
	} else if (_ResType = "library"){
	
		Gui 1: Listview, Resource_LV

		_Name := doc.Get("/Resource/@Name")
		_RID := TV_Add(_Name, _ID, "Icon5") ; icon: resource-lib
	
		Resources[_RID]	:=	{"Name"		:	_Name
								, "Type"		:	"library"
								, "context"		:	"resource"
								, "ParentID"	:	0
								, "XML"			:	doc
								, "Tree"		:	"/Resource"
								, "File"		:	A_LoopFileFullPath}
	
		Resources[_ID].Libraries.Count++
		Resources[_ID].Libraries["Library" A_Index ] := _RID
		LV_Add("", _Name, "library", _RID)
		Resources.List[_Name] := _RID
		
		}
	if not _ResType
		{
		err := doc.doc.ParseError
		Error(A_ThisFunc "()", "-0x0002", "XML parsing error", "A parsing error was detected in `"" A_LoopFileFullPath "`"`nxml error code: " err.errorCode
									. "`nxml error reason: " err.Reason "`nxml error line: " err.Line "`nxml code: " err.srcText, "The file will be ignored.")
		}
	
	}

Gui 1: Listview, CommonTasks_LV
	Loop 2
		LV_ModifyCol(A_Index, "AutoHdr")
	
Gui 1: Listview, Resource_LV
	Loop 3
		LV_ModifyCol(A_Index, "AutoHdr")

TV_Modify(_ID, "Sort " lid)

GuiControl +Redraw, CommonTasks_LV
GuiControl +Redraw, Resource_LV
GuiControl +Redraw, ResourceTree

return
}
; **********************************************************************************************************************************************************************
List_Project(sDoc, sTree, sPID, sFile) {

Gui 1: Treeview, ResourceTree
Gui 1: ListView, Resource_LV

_Priority	:=	sDoc.Get(sTree . "/Properties/Priority")
_Name		:=	sDoc.Get(sTree . "/@Name")
_ID			:=	TV_Add(_Name, sPID, "Icon3 Expand") ; icon: project
TV_SetStateImage(Gui.Treeview.Handle, _ID, _Priority = 3 ? 3 : (_Priority = 2 ? 2 : 1))
Resources.List[_Name] := _ID

Resources[_ID]	:=	{"Name"				:	_Name
					, "Type"			:	"project"
					, "context"			:	sPID ? "project" : "toplevel"
					, "ParentID"		:	sPID
					, "ParentTree"		:	Resources[sPID].ParentTree (sPID != 0 ? " >> " : "") _Name
					, "XML"				:	sDoc
					, "Priority"		:	_Priority
					, "Tree"			:	sTree
					, "compatibility"	:	{"Basic"	:	sDoc.Get(sTree . "/Properties/compatibility/Basic")
											, "Lexikos"	:	sDoc.Get(sTree . "/Properties/compatibility/Lexikos")
											, "IronAHK"	:	sDoc.Get(sTree . "/Properties/compatibility/IronAHK")
											, "AHK2"	:	sDoc.Get(sTree . "/Properties/compatibility/AHK2")}
					, "File"			:	sFile}
LV_Add("", _Name, "project", _ID)

Gui 1: Listview, CommonTasks_LV
Resources[_ID].Tasks		:=	{}
Loop sDoc.GetNodes(sTree . "/Tasks/Task").length {
	LV_Add("", sDoc.Get(sTree . "/Tasks/Task[" A_Index-1 "]/@Name"), Resources[_ID].ParentTree)
	Resources[_ID].Tasks["Task" A_Index] := {"Name" : _Temp
											, "Description" : sDoc.Get(sTree . "/Tasks/Task[" A_Index-1 "]")}
	}

Resources[_ID].Files		:=	{}
Loop {
	_Temp := sDoc.Get(sTree . "/Files/File[" A_Index-1 "]/@Name")
	if (!_Temp)
		break
		
	_RID := TV_Add(_Temp, _ID, "Icon4") ; icon: file
	Resources[_RID]	:=	{"Name"			:	_Temp
							, "Type"		:	"file"
							, "context"		:	"project"
							, "ParentID"	:	_ID
							, "XML"			:	sDoc
							, "Tree"		:	sTree "/Files/File[" A_Index-1 "]"
							, "File"		:	sFile}
	Resources[_ID].Files["File" A_Index ] := _RID
	}

Resources[_ID].Libraries	:=	{}
Loop {
	_Temp := sDoc.Get(sTree . "/Libraries/Lib[" A_Index-1 "]/@Name")
	if (!_Temp)
		break
		
	_RID := TV_Add(_Temp, _ID, "Icon5") ; icon lib
	Resources[_RID]	:=	{"Name"			:	_Temp
							, "Type"		:	"library"
							, "context"		:	"project"
							, "ParentID"	:	_ID
							, "XML"			:	sDoc
							, "Tree"		:	sTree "/Libraries/Lib[" A_Index-1 "]"
							, "File"		:	sFile}
	Resources[_ID].Libraries["Library" A_Index ] := _RID
	}

Resources[_ID].Subs		:=	{}
Loop (sDoc.GetNodes(sTree "/Sub").length)
	Resources[_ID].Subs["Sub" A_Index ] := List_Project(sDoc, sTree . "/Sub[" A_Index-1 "]",  _ID, sFile)


return _ID
}
; **********************************************************************************************************************************************************************
Library_OpenResource(sID) {
return
}
; **********************************************************************************************************************************************************************
File_OpenResource(sID) {
; check for known data
; if necessary, add new data

; transfer data to hPanel3 + hPanel4

; check panel property and show corresponding panel
; if panel is 3, no check for binary
; else: maybe using FileIsBinary() or similar
; if path is unknown: only show 4

_Doc := Resources[sID].XML

Gui 1: Listview, ResourceUserData_LV
	LV_Delete()
	GuiControl 1: -Redraw, ResourceUserData_LV

nodes := _Doc.Node(Resources[sID].Tree . "/User_Data")
Loop nodes.childNodes.length
	{
	_Value := nodes.childNodes.item(A_Index - 1).text
	_Name := nodes.childNodes.item(A_Index - 1).nodeName
	
	for property, _keyword in Keyword.file
		{
		if (! Resources[sID].HasKey(property) && _Name = _keyword && _keyword != "Include" && _keyword != "Hide")
			Resources[sID][property] := _Value
		}
	LV_Add("", _Name, _Value)
	}
	
Loop 2
	LV_ModifyCol(A_Index, "AutoHdr")

_Text := XML_Translation("/KeyWords/Name", 1)	. ":`t`t"	. Resources[sID].Name			. "`n"
		. Keyword.file.FileType					. ":`t`t"	. Resources[sID].FileType		. "`n"
		. Keyword.file.Description				. ":`t"		. Resources[sID].Description	. "`n"
		. Keyword.file.Path						. ":`t`t"	. Resources[sID].Path

GuiControl 1: , ResourceInfo, %_Text%

GuiControl 1: +Redraw, ResourceUserData_LV

If (!FileIsBinary(Resources[sID].File)){
	FileRead _Temp, % Resources[sID].File
	SCI_SetText(Gui.SCI1, _Temp)
	}
return
}
; **********************************************************************************************************************************************************************
Library_OpenProject(sID) {
; check for known data
; if necessary, add new data

; transfer data to hPanel3 + hPanel4

; check panel property and show corresponding panel
; if path is unknown: only show 4
return
}
; **********************************************************************************************************************************************************************
File_OpenProject(sID) {
return
}
; **********************************************************************************************************************************************************************
Project_Open(sID) {

Gui 1: Default
If (Resources.ActiveID = sID || !sID)
	return -1

Project_Save()

Gui 1: Listview, ProjectFiles_LV
	LV_Delete()
	GuiControl -Redraw, ProjectFiles_LV

_Doc := Resources[sID].XML

For file, _ID in Resources[sID].Files {
	
	if (! Resources[_ID].ResourceXML)
		Resources[_ID].ResourceXML := SVS_GetResourceXML(_ID)
	
	if (Resources[_ID].ResourceXML)
		rDoc := new XMLParser(Resources[_ID].ResourceXML)
	
	for property, _keyword in Keyword.file
		{
		if (! Resources[_ID].HasKey(property) && Resources[_ID].ResourceXML){
			_Value	:=	rDoc.Get("/Resource/User_Data/" . _keyword)
			_Flag	:=	rDoc.Get("/Resource/User_Data/" . _keyword . "/@Flag")
			_Count	:=	rDoc.Count("/Resource/User_Data/" . _keyword)
			if (!InStr(_Flag, "#") && (!InStr(_Flag, "-") || property = "hide") && _Count)
				Resources[_ID][property]	:=	_Value
			}
		
		_Value		:=	_Doc.Get(Resources[_ID].Tree . "/User_Data/" . _keyword)
		, _Flag		:=	_Doc.Get(Resources[_ID].Tree . "/User_Data/" . _keyword . "/@Flag")
		, _Count	:=	_Doc.Count(Resources[_ID].Tree . "/User_Data/" . _keyword)
		if (!InStr(_Flag, "#") && (!InStr(_Flag, "-") || property = "hide") && _Count)
			Resources[_ID][property]	:=	_Value
		}

	if Resources[_ID].Hide
		continue
	
	if (Resources[_ID].Path && !FileExist(Resources[_ID].Path) && FileExist(Data_Manager.ScriptDir . Resources[_ID].Path))
		Resources[_ID].Path := Data_Manager.ScriptDir . Resources[_ID].Path
	
	if (Resources[_ID].Path && FileExist(Resources[_ID].Path)) {
		FileGetSize _Temp, % Resources[_ID].Path, K
		Resources[_ID].Size := _Temp
		}

	_IconNr := (_Type = "AHK (Basic) Script" || _Type = "compiled script (AHK Basic)" ? 1
				: (_Type = "AHK_L script" || _Type = "compiled script (AHK_L)" ? 2
				: (_Type = "IronAHK script" || _Type = "compiled script (IronAHK)" ? 3 : 4)))

	LV_Add("Icon" _IconNr,	Resources[_ID].Name
					,	SVS_Bool(Resources[_ID].Include)
					,	Resources[_ID].FileType
					,	Resources[_ID].Description
					,	Resources[_ID].Size ? Resources[_ID].Size " KB" : ""
					,	Resources[_ID].Path)

	}
Loop 6
	LV_ModifyCol(A_Index, "AutoHdr")

Gui 1: ListView, ProjectLibraries_LV
	LV_Delete()
	GuiControl -Redraw, ProjectLibraries_LV
For lib, _ID in Resources[sID].Libraries {
	
	if (! Resources[_ID].ResourceXML)
		Resources[_ID].ResourceXML := SVS_GetResourceXML(_ID)		
	
	if (Resources[_ID].ResourceXML)
		rDoc := new XMLParser(Resources[_ID].ResourceXML)

	For property, _keyword in Keyword.lib
		{
		if (! Resources[_ID].HasKey(property) && Resources[_ID].ResourceXML){
			_Value	:=	rDoc.Get("/Resource/User_Data/" . _keyword)
			_Flag	:=	rDoc.Get("/Resource/User_Data/" . _keyword . "/@Flag")
			_Count	:=	rDoc.Count("/Resource/User_Data/" . _keyword)
			if (!InStr(_Flag, "#") && (!InStr(_Flag, "-") || property = "hide") && _Count)
				Resources[_ID][property]	:=	_Value
			}
		
		_Value		:=	_Doc.Get(Resources[_ID].Tree . "/User_Data/" . _keyword)
		, _Flag		:=	_Doc.Get(Resources[_ID].Tree . "/User_Data/" . _keyword . "/@Flag")
		, _Count	:=	_Doc.Count(Resources[_ID].Tree . "/User_Data/" . _keyword)
		if (!InStr(_Flag, "#") && (!InStr(_Flag, "-") || property = "hide") && _Count)
			Resources[_ID][property]	:=	_Value	
		}
		
	if Resources[_ID].Hide
		continue
	
	LV_Add("",		Resources[_ID].Name
				,	Resources[_ID].Author
				,	Resources[_ID].License
				,	Resources[_ID].Version)
	}
Loop 4
	LV_ModifyCol(A_Index, "AutoHdr")

Gui 1: ListView, ProjectUserData_LV
	LV_Delete()
	GuiControl -Redraw, ProjectUserData_LV

nodes := _Doc.GetNodes(Resources[sID].Tree . "/User_Data", "childNodes")	
Loop nodes.length {
	node := nodes.item(A_Index - 1).text
	if not RegExMatch(node, "^\s*<([^\s=]*)(?:\s([^=\s]*)=([^=\s]*))*>([^<>]*)</([^\s=]*).*>\s*$", result)
		continue
	if (result1 != result5)
		continue
		
	if (result2 = "Flag" && InStr(result3, "-"))
		continue
	if (result2 = "Flag" && InStr(result3, "+")) {
		result1 := "[+] " result1
		Resources[sID].DefData := result1
		}
	
	LV_Add("", result1, result4)
	
	}
Loop 2
	LV_ModifyCol(A_Index, "AutoHdr")

if (! Resources[sID].HasKey("Status"))
	Resources[sID].Status					:=	_Doc.Get(Resources[sID].Tree . "/Properties/Status")
if (! Resources[sID].compatibility.HasKey("Basic"))
	Resources[sID].compatibility.Basic		:=	_Doc.Get(Resources[sID].Tree . "/Properties/compatibility/Basic")
if (! Resources[sID].compatibility.HasKey("Lexikos"))
	Resources[sID].compatibility.Lexikos	:=	_Doc.Get(Resources[sID].Tree . "/Properties/compatibility/Lexikos")
if (! Resources[sID].compatibility.HasKey("IronAHK"))
	Resources[sID].compatibility.IronAHK	:=	_Doc.Get(Resources[sID].Tree . "/Properties/compatibility/IronAHK")
if (! Resources[sID].compatibility.HasKey("AHK2"))
	Resources[sID].compatibility.AHK2		:=	_Doc.Get(Resources[sID].Tree . "/Properties/compatibility/AHK2")
if (! Resources[sID].HasKey("ProjectType"))
	Resources[sID].ProjectType				:=	_Doc.Get(Resources[sID].Tree . "/Properties/Type")
if (! Resources[sID].HasKey("Purpose"))
	Resources[sID].Purpose					:=	_Doc.Get(Resources[sID].Tree . "/Properties/Purpose")
if (! Resources[sID].HasKey("LastMod"))
	Resources[sID].LastMod					:=	_Doc.Get(Resources[sID].Tree . "/Properties/LastMod")
if (! Resources[sID].HasKey("Notes"))
	Resources[sID].Notes					:=	_Doc.Get(Resources[sID].Tree . "/Properties/Notes")


GuiControl 1:	Text, StatDDL,	% Resources[sID].Status
GuiControl 1:		, AHKB,		% Resources[sID].compatibility.Basic ? 1 : 0
GuiControl 1:		, AHKL,		% Resources[sID].compatibility.Lexikos ? 1 : 0
GuiControl 1:		, AHKI,		% Resources[sID].compatibility.IronAHK ? 1 : 0
GuiControl 1:		, AHK2,		% Resources[sID].compatibility.AHK2 ? 1 : 0
GuiControl 1:	Text, TypCombo,	% Resources[sID].ProjectType
GuiControl 1:		, GoalEdit,	% Resources[sID].Purpose
FormatTime _Temp, % Resources[sID].LastMod, LongDate
GuiControl 1:		, LModEdit,	% Resources[sID].LastMod := _Temp

GuiControl 1: +Redraw, ProjectFiles_LV
GuiControl 1: +Redraw, ProjectLibraries_LV
GuiControl 1: +Redraw, ProjectUserData_LV

SCI_SetText(Gui.SCI2, Resources[sID].Notes)

return
}