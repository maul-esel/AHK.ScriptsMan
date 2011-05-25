Project_Save2Obj() {

id := Resources.ActiveID
Resources[id].Notes := SCI_GetText(Gui.SCI2)

GuiControlGet _Var, 1:, StatDDL
Resources[id].Status := _Var

_Temp := "BLI2"
LoopParse _Temp
	{
	GuiControlGet _Var, 1:, AHK%A_LoopField%
	Resources[id]["AHK" A_LoopField ] := _Var
	MsgBox %A_LoopField% -> %_Var%
	}
	
GuiControlGet _Var, 1:, TypCombo
Resources[id].projecttype	:= _Var

GuiControlGet _Var, 1:, GoalEdit
Resources[id].purpose		:= _Var

Resources[id].lastmode		:=	A_Now

if (XML_Get("/always_safe[1]") = "1")
	return Project_Save2File(id)

return
}
; **********************************************************************************************************************************************************************
Project_Save2File(id){


For index, id in Resources[id].Subs
	{
	Project_Save2File(id)	
	}
}
; **********************************************************************************************************************************************************************
Project_SetPriority() {

if (Resources[Resources.ActiveID].Type != "project")
	return -1

Inputbox _Priority, AHK.ScriptsMan, % XML_Translation("/UserInterface/Dialogs/SetPriority", 1),,,,,,,60
if (ErrorLevel || !_Priority)
	return -1
	
if (_Priority != 1 && _Priority != 2 && _Priority != 3) {
	Error(A_ThisFunc "()", "-0x0004", "invalid project priority (invalid user input)", XML_Translation("/UserInterface/Dialogs/SetPriority", 2), "the operation will be aborted")
	return -1
	}

Resources[Resources.ActiveID].Priority := _Priority	
TV_SetStateImage(Gui.Treeview.Handle, Resources.ActiveID, _Priority)

return
}
; **********************************************************************************************************************************************************************
Project_List(sDoc, sTree, sPID, sFile) {

Gui 1: Treeview, ResourceTree
Gui 1: ListView, Resource_LV

_Priority	:=	sDoc.Get(sTree . "/properties/priority")
_Name		:=	sDoc.Get(sTree . "/@name")
_ID			:=	TV_Add(_Name, sPID, "icon3 expand") ; icon: project
TV_SetStateImage(Gui.Treeview.Handle, _ID, _Priority = 3 ? 3 : (_Priority = 2 ? 2 : 1))
Resources.List[_Name] := _ID

Resources[_ID]	:=	{"Name"				:	_Name
					, "Type"			:	"project"
					, "context"			:	sPID ? "project" : "toplevel"
					, "ParentID"		:	sPID
					, "ParentTree"		:	Resources[sPID].ParentTree "/" _Name
					, "XML"				:	sDoc
					, "Priority"		:	_Priority
					, "Tree"			:	sTree
					, "compatibility"	:	{"Basic"	:	sDoc.Get(sTree . "/properties/compatibility/basic")
											, "Lexikos"	:	sDoc.Get(sTree . "/properties/compatibility/lexikos")
											, "IronAHK"	:	sDoc.Get(sTree . "/properties/compatibility/iron-ahk")
											, "AHK2"	:	sDoc.Get(sTree . "/properties/compatibility/ahk-2")}
					, "File"			:	sFile}
LV_Add("", _Name, "project", _ID)

Gui 1: Listview, CommonTasks_LV
Resources[_ID].Tasks		:=	{}
Loop sDoc.GetNodes(sTree . "/tasks/task").length {
	LV_Add("", sDoc.Get(sTree . "/tasks/task[" A_Index-1 "]/@name"), Resources[_ID].ParentTree)
	Resources[_ID].Tasks["task" A_Index] := {"Name" : _Temp
											, "Description" : sDoc.Get(sTree . "/tasks/task[" A_Index-1 "]")}
	}

Resources[_ID].Files		:=	{}
Loop {
	_Temp := sDoc.Get(sTree . "/files/file[" A_Index-1 "]/@name")
	if (!_Temp)
		break
		
	_RID := TV_Add(_Temp, _ID, "Icon4") ; icon: file
	Resources[_RID]	:=	{"Name"			:	_Temp
							, "Type"		:	"file"
							, "context"		:	"project"
							, "ParentID"	:	_ID
							, "XML"			:	sDoc
							, "Tree"		:	sTree "/files/file[" A_Index-1 "]"
							, "File"		:	sFile}
	Resources[_ID].Files["file" A_Index ] := _RID
	}

Resources[_ID].Libraries	:=	{}
Loop {
	_Temp := sDoc.Get(sTree . "/libraries/lib[" A_Index-1 "]/@name")
	if (!_Temp)
		break
		
	_RID := TV_Add(_Temp, _ID, "Icon5") ; icon lib
	Resources[_RID]	:=	{"Name"			:	_Temp
							, "Type"		:	"library"
							, "context"		:	"project"
							, "ParentID"	:	_ID
							, "XML"			:	sDoc
							, "Tree"		:	sTree "/libraries/lib[" A_Index-1 "]"
							, "File"		:	sFile}
	Resources[_ID].Libraries["library" A_Index ] := _RID
	}

Resources[_ID].Subs		:=	{}
Loop (sDoc.GetNodes(sTree "/sub").length)
	Resources[_ID].Subs["sub" A_Index ] := Project_List(sDoc, sTree . "/sub[" A_Index-1 "]",  _ID, sFile)

return _ID
}
; **********************************************************************************************************************************************************************
Project_Open(sID) {

Gui 1: Default
If (Resources.ActiveID = sID || !sID)
	return -1

Gui 1: Listview, ProjectFiles_LV
	LV_Delete()
	GuiControl -Redraw, ProjectFiles_LV

_Doc := Resources[sID].XML

For file, _ID in Resources[sID].Files {

	if (! Resources[_ID].ResourceXML)
		Resources[_ID].ResourceXML := GetResourceXML(_ID)
	
	if (Resources[_ID].ResourceXML)
		rDoc := new XMLParser(Resources[_ID].ResourceXML)
	
	for property, _keyword in Keyword.file
		{
		if (! Resources[_ID].HasKey(property) && Resources[_ID].ResourceXML){
			_Value	:=	rDoc.Node("/resource/metadata/metadata[@name='" . _keyword . "']").text
			_Flag	:=	rDoc.Node("/resource/metadata/metadata[@name='" . _keyword . "']").attributes.getNamedItem("flag").nodeValue
			_Count	:=	rDoc.Count("/resource/metadata/metadata[@name='" . _keyword . "']")
			
			if (!InStr(_Flag, "#") && (!InStr(_Flag, "-") || property = "hide") && _Count)
				Resources[_ID][property]	:=	_Value
			}
		
		_Value		:=	_Doc.Get(Resources[_ID].Tree . "/metadata/" . _keyword)
		_Flag		:=	_Doc.Get(Resources[_ID].Tree . "/metadata/" . _keyword . "/@Flag")
		_Count	:=	_Doc.Count(Resources[_ID].Tree . "/metadata/" . _keyword)
		
		if (!InStr(_Flag, "#") && (!InStr(_Flag, "-") || property = "hide") && _Count)
			Resources[_ID][property]	:=	_Value
		}

	if Resources[_ID].Hide
		continue
	
	Resources[_ID].Path := AbsolutePath(Resources[_ID].Path)
	
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
		Resources[_ID].ResourceXML := GetResourceXML(_ID)		
	
	if (Resources[_ID].ResourceXML)
		rDoc := new XMLParser(Resources[_ID].ResourceXML)

	For property, _keyword in Keyword.lib
		{
		if (! Resources[_ID].HasKey(property) && Resources[_ID].ResourceXML){
			_Value	:=	rDoc.Node("/resource/metadata/metadata[@name='" . _keyword . "']").text
			_Flag	:=	rDoc.Node("/resource/metadata/metadata[@name='" . _keyword . "']").attributes.getNamedItem("flag").nodeValue
			_Count	:=	rDoc.HasNode("/resource/metadata/metadata[@name='" . _keyword "']")

			if (!InStr(_Flag, "#") && (!InStr(_Flag, "-") || property = "hide") && _Count)
				Resources[_ID][property]	:=	_Value
			}
		
		_Value		:=	_Doc.Get(Resources[_ID].Tree . "/metadata/" . _keyword)
		_Flag		:=	_Doc.Get(Resources[_ID].Tree . "/metadata/" . _keyword . "/@Flag")
		_Count	:=	_Doc.Count(Resources[_ID].Tree . "/metadata/" . _keyword)
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

nodes := _Doc.Node(Resources[sID].Tree . "/metadata").childNodes	
Loop nodes.length {
	
	metadata	:=	nodes.item(A_Index - 1).attributes.getNamedItem("name").nodeValue
	value		:=	nodes.item(A_Index - 1).text
	flag		:=	nodes.item(A_Index - 1).attributes.getNamedItem("flag").nodeValue
	
	if InStr(flag, "-")
		continue
		
	if InStr(flag, "+") {
		Resources[sID].DefData := metadata
		metadata := "[+] " metadata
		}
	
	LV_Add("", metadata, value)
	
	}
Loop 2
	LV_ModifyCol(A_Index, "AutoHdr")

if (! Resources[sID].HasKey("status"))
	Resources[sID].status					:=	_Doc.Get(Resources[sID].Tree . "/properties/status")
if (! Resources[sID].compatibility.HasKey("AHKB"))
	Resources[sID].compatibility.AHKB		:=	_Doc.Get(Resources[sID].Tree . "/properties/compatibility/basic")
if (! Resources[sID].compatibility.HasKey("AHKL"))
	Resources[sID].compatibility.AHKL		:=	_Doc.Get(Resources[sID].Tree . "/properties/compatibility/lexikos")
if (! Resources[sID].compatibility.HasKey("AHKI"))
	Resources[sID].compatibility.AHKI		:=	_Doc.Get(Resources[sID].Tree . "/properties/compatibility/iron-ahk")
if (! Resources[sID].compatibility.HasKey("AHK2"))
	Resources[sID].compatibility.AHK2		:=	_Doc.Get(Resources[sID].Tree . "/properties/compatibility/ahk-2")
if (! Resources[sID].HasKey("projecttype"))
	Resources[sID].projecttype				:=	_Doc.Get(Resources[sID].Tree . "/properties/type")
if (! Resources[sID].HasKey("purpose"))
	Resources[sID].purpose					:=	_Doc.Get(Resources[sID].Tree . "/properties/purpose")
if (! Resources[sID].HasKey("lastmod"))
	Resources[sID].lastmod					:=	_Doc.Get(Resources[sID].Tree . "/properties/last-mod")
if (! Resources[sID].HasKey("notes"))
	Resources[sID].notes					:=	_Doc.Get(Resources[sID].Tree . "/properties/notes")


GuiControl 1:	Text, StatDDL,	% Resources[sID].status
GuiControl 1:		, AHKB,		% Resources[sID].compatibility.AHKB ? 1 : 0
GuiControl 1:		, AHKL,		% Resources[sID].compatibility.AHKL ? 1 : 0
GuiControl 1:		, AHKI,		% Resources[sID].compatibility.AHKI ? 1 : 0
GuiControl 1:		, AHK2,		% Resources[sID].compatibility.AHK2 ? 1 : 0
GuiControl 1:	Text, TypCombo,	% Resources[sID].projecttype
GuiControl 1:		, GoalEdit,	% Resources[sID].purpose
FormatTime _Temp, % Resources[sID].lastmod, LongDate
GuiControl 1:		, LModEdit,	% Resources[sID].lastmod := _Temp

GuiControl 1: +Redraw, ProjectFiles_LV
GuiControl 1: +Redraw, ProjectLibraries_LV
GuiControl 1: +Redraw, ProjectUserData_LV

SCI_SetText(Gui.SCI2, Resources[sID].notes)

return
}
; **********************************************************************************************************************************************************************
Project_Create() {

InputBox _Project, AHK.ScriptsMan, % XML_Translation("/UserInterface/Dialogs/CreateProject", 1),,,,,,,60
if (ErrorLevel || !_Project)
	return 0

if (Resources.List.HasKey(_Project) && Resources[Resources.List[_Project]].type = "project"){
	Error(A_ThisFunc "()", "-0x0003", "duplicate resource name (invalid user input)", XML_Translation("/UserInterface/Dialogs/CreateProject", 2), "The operation will be aborted.")
	return
	}

InputBox _Parent, AHK.ScriptsMan, % XML_Translation("/UserInterface/Dialogs/CreateProject", 3),,,,,,,60
if (ErrorLevel || !_Parent){
	_Parent := null
	_Path := _Project
	Loop {
		if FileExist(A_ScriptDir "\#Data\" _Path ".xml")
			_Path := A_Index "-" _Project
		else
			break
		}
	_Path := A_ScriptDir "\#Data\" _Path ".xml"

	xml := "<resource name=`"" _Project "`" data-type=`"project`">`r`n"
		. "`t<properties>`r`n"
		. "`t`t<compatibility>`r`n"
		. "`t`t</compatibility>`r`n"
		. "`t</properties>`r`n"
		. "`t<files>`r`n"
		. "`t</files>`r`n"
		. "`t<libraries>`r`n"
		. "`t</libraries>`r`n"
		. "`t<metadata>`r`n"
		. "`t</metadata>`r`n"
		. "`t<tasks>`r`n"
		. "`t</tasks>`r`n"
		. "</resource>"
	FileAppend %xml%, %_Path%
	xml := new XMLParser(xml, true)
} else {
	if (!IsType(_Parent, "integer") || !Resources[_Parent].Type = "project")
		{
		MsgBox 16, AHK.ScriptsMan, % XML_Translation("/UserInterface/Dialogs/CreateProject", 4)
		return
		}
	_Path := Resources[_Parent].File
	xml := "<sub name`"" _Project "`">"
		. "`t<properties>`r`n"
		. "`t`t<compatibility>`r`n"
		. "`t`t</compatibility>`r`n"
		. "`t</properties>`r`n"
		. "`t<files>`r`n"
		. "`t</files>`r`n"
		. "`t<libraries>`r`n"
		. "`t</libraries>`r`n"
		. "`t<metadata>`r`n"
		. "`t</metadata>`r`n"
		. "`t<tasks>`r`n"
		. "`t</tasks>`r`n"
		. "</sub>"
	xml := new XMLParser(xml, true)
	Resources[_Parent].XML.doc.documentElement.appendChild(xml)
	xml := Resources[_Parent].XML
	xml.Save(Resources[_Parent].File)
	}

_ID := TV_Add(_Project, _Parent, "Icon3")
TV_SetStateImage(Gui.Treeview.Handle, _ID, 1)
Resources[_ID]	:=	{"Name"			:	_Project
					, "Type"			:	"project"
					, "context" 		:	_Parent ? "project" : "toplevel"
					, "ParentID"		:	_Parent
					, "ParentTree"		:	Resources[_Parent].ParentTree (_Parent != 0 ? " >> " : "") _Name
					, "XML"				:	xml
					, "Priority"		:	1
					, "Tree"			:	_Parent ? (Resources[_Parent].Tree . "/sub[" . Resources[_Parent].XML.Count(Resources[_Parent].Tree . "/sub") - 1 "]") : "/resource"
					, "compatibility"	:	{}
					, "File"			:	_Path}
return Project_Open(_ID)
}
; **********************************************************************************************************************************************************************
Project_AddUserData() {
_doc := Resources[Resources.ActiveID].XML

InputBox _Name, AHK.ScriptsMan, % XML_Translation("/UserInterface/Dialogs/CreateUserData", 1)
if (ErrorLevel || !_Name)
	return
InputBox _Value, AHK.ScriptsMan, % XML_Translation("/UserInterface/Dialogs/CreateUserData", 2)
if (ErrorLevel)
	return
MsgBox 260, AHK.ScriptsMan, % XML_Translation("/UserInterface/Dialogs/CreateUserData", 3)
IfMsgBox, Yes
	_Flags := "#"
MsgBox 260, AHK.ScriptsMan, % XML_Translation("/UserInterface/Dialogs/CreateUserData", 4)
IfMsgBox, Yes
	_Flags .= "+"

;_Name := SVS_Convert2XML(_Name)
;IniWrite %_Value%, %_Project%, User.Data, %_Name%[%_Flags%]

Gui 1: Default
Gui 1: Listview, UserData_LV
LV_Add("", (InStr(_Flags, "+") ? "[+] " : "") _Name, _Value)

Loop 2
	LV_ModifyCol(A_Index, "AutoHdr")
	
if InStr(_Flags, "+") {
	Gui 1: Listview, Projects_LV
	
	Loop % LV_GetCount()
		{
		LV_GetText(_Project, A_Index, 1)
		if (_Project = A_LastProject) {
			_Row := A_Index
			break
			}		
		}
	if (!_Row)
		return -1
	Loop 4
		LV_GetText(_Col%A_Index%, _Row, A_Index)
	LV_Modify(_Row, "", _Col1, _Col2, _Col3, _Col4, _Name ": " _Value)
	}
	
return
}