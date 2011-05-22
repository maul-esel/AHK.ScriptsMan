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
Resources[ TV_Add("tasks", 0, "Icon1") ] := {"type" : "task_parent"}
tasks := (new XMLParser(A_ScriptDir "\Settings.xml")).GetNodes("/settings/tasks/task")
Loop tasks.length {
	_Temp := tasks.item(A_Index - 1).text
	if not (_Temp)
		break
	LV_Add("", _Temp, XML_Translation("/UserInterface/MainGui/Tasks/Info"))
	}

; add resources tvitem
_ID := TV_Add("resources", 0, "icon2 expand") ; icon: resource_parent
Resources[_ID]	:= {"type"		:	"resource_parent"
								, "files"		:	{}
								, "libraries"	:	{}}

; loop all resources
Resources.List := {}
LoopFiles %A_ScriptDir%\#Data\*.xml
	{
	doc := new XMLParser(A_LoopFileFullPath)
	_ResType := doc.Get("/resource/@data-type")
	
	if (_ResType = "project"){
	
		lid := List_Project(doc, "/resource", 0, A_LoopFileFullPath)
		
	} else if (_ResType = "file"){

		Gui 1: Listview, Resource_LV
				
		_Name := doc.Get("/resource/@name")
		_RID := TV_Add(_Name, _ID, "icon4") ; icon: resource-file
	
		Resources[_RID]	:=	{"name"		:	_Name
								, "type"		:	"file"
								, "context"		:	"resource"
								, "parentID"	:	0
								, "XML"			:	doc
								, "tree"		:	"/resource"
								, "file"		:	A_LoopFileFullPath}
	
		Resources[_ID].Files["file" A_Index ] := _RID
		LV_Add("", _Name, "file", _RID)
		Resources.List[_Name] := _RID
		
	} else if (_ResType = "library"){
	
		Gui 1: Listview, Resource_LV

		_Name := doc.Get("/resource/@name")
		_RID := TV_Add(_Name, _ID, "icon5") ; icon: resource-lib
	
		Resources[_RID]	:=	{"name"		:	_Name
								, "type"		:	"library"
								, "context"		:	"resource"
								, "parentID"	:	0
								, "XML"			:	doc
								, "tree"		:	"/resource"
								, "file"		:	A_LoopFileFullPath}
	
		Resources[_ID].Libraries["library" A_Index ] := _RID
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
	Resources[_ID].Subs["sub" A_Index ] := List_Project(sDoc, sTree . "/sub[" A_Index-1 "]",  _ID, sFile)


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

nodes := _Doc.Node(Resources[sID].Tree . "/metadata").childNodes
Loop nodes.length
	{
	_Name	:=	nodes.item(A_Index - 1).attributes.getNamedItem("name").nodeValue
	_Value	:=	nodes.item(A_Index - 1).text
	_Flag	:=	nodes.item(A_Index - 1).attributes.getNamedItem("flag").nodeValue
	
	if InStr(_Flag, "-")
		continue
	
	for property, _keyword in Keyword.file
		{
		if (! Resources[sID].HasKey(property) && _Name = _keyword && _keyword != "Include" && _keyword != "Hide" && !InStr(_Flag, "#"))
			Resources[sID][property] := _Value
		}
	LV_Add("", _Name, _Value)
	}
	
Loop 2
	LV_ModifyCol(A_Index, "AutoHdr")

_Text := XML_Translation("/KeyWords/Name", 1)	. ":`t`t"	. Resources[sID].Name			. "`n"
		. Keyword.file.FileType					. ":`t`t"	. Resources[sID].FileType		. "`n"
		. Keyword.file.Description				. ":`t"		. Resources[sID].Description	. "`n"
		. Keyword.file.Path						. ":`t`t"	. AbsolutePath(Resources[sID].Path)

GuiControl 1: , ResourceInfo, %_Text%

Gui 1: ListView, ResourceProjects_LV
	LV_Delete()
	GuiControl 1: -Redraw, ResourceProjects_LV

nodes := _Doc.Node(Resources[sID].Tree . "/projects").childNodes
Loop nodes.length
	{
	LV_Add("", nodes.item(A_Index - 1).attributes.getNamedItem("name").nodeValue)
	
	}

GuiControl 1: +Redraw, ResourceUserData_LV
GuiControl 1: +Redraw, ResourceProjects_LV

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
if (! Resources[sID].compatibility.HasKey("basic"))
	Resources[sID].compatibility.basic		:=	_Doc.Get(Resources[sID].Tree . "/properties/compatibility/basic")
if (! Resources[sID].compatibility.HasKey("lexikos"))
	Resources[sID].compatibility.lexikos	:=	_Doc.Get(Resources[sID].Tree . "/properties/compatibility/lexikos")
if (! Resources[sID].compatibility.HasKey("ironahk"))
	Resources[sID].compatibility.ironahk	:=	_Doc.Get(Resources[sID].Tree . "/properties/compatibility/iron-ahk")
if (! Resources[sID].compatibility.HasKey("ahk2"))
	Resources[sID].compatibility.ahk2		:=	_Doc.Get(Resources[sID].Tree . "/properties/compatibility/ahk-2")
if (! Resources[sID].HasKey("projecttype"))
	Resources[sID].projecttype				:=	_Doc.Get(Resources[sID].Tree . "/properties/type")
if (! Resources[sID].HasKey("purpose"))
	Resources[sID].purpose					:=	_Doc.Get(Resources[sID].Tree . "/properties/purpose")
if (! Resources[sID].HasKey("lastmod"))
	Resources[sID].lastmod					:=	_Doc.Get(Resources[sID].Tree . "/properties/last-mod")
if (! Resources[sID].HasKey("notes"))
	Resources[sID].notes					:=	_Doc.Get(Resources[sID].Tree . "/properties/notes")


GuiControl 1:	Text, StatDDL,	% Resources[sID].status
GuiControl 1:		, AHKB,		% Resources[sID].compatibility.basic ? 1 : 0
GuiControl 1:		, AHKL,		% Resources[sID].compatibility.lexikos ? 1 : 0
GuiControl 1:		, AHKI,		% Resources[sID].compatibility.ironahk ? 1 : 0
GuiControl 1:		, AHK2,		% Resources[sID].compatibility.ahk2 ? 1 : 0
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