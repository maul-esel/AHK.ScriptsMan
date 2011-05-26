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
_list := (new XMLParser(A_ScriptDir "\Settings.xml")).GetNodes("/settings/tasks/task")
Loop _list.length
	LV_Add("", _list.item(A_Index - 1).attributes.getNamedItem("name").nodeValue, _list.item(A_Index - 1).text, XML_Translation("/UserInterface/MainGui/Tasks/Info"))

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
	
		_project := new cProject
		lid := _project.List(doc, "/resource", 0, A_LoopFileFullPath)
		
	} else if (_ResType = "file" || _ResType = "library"){

		if (_ResType = "file")
			_obj	:=	new cFile
		else
			_obj	:=	new cLibrary
		
		Gui 1: Listview, Resource_LV
				
		_obj.Name		:=	doc.Get("/resource/@name")
		_obj.ID			:=	TV_Add(_obj.Name, _ID, _ResType = "file" ? "icon4" : "icon5") ; icon: resource-file | resource-lib
		_obj.Type		:=	_ResType = "file" ? "file" : "library"
		_obj.context	:=	"resource"
		_obj.ParentID	:=	0
		_obj.XML		:=	doc
		_obj.Tree		:=	"/resource"
		_obj.File		:=	A_LoopFileFullPath
	
		LV_Add("", _obj.Name, _obj.Type, _obj.ID)
		
		Resources.List[_obj.Name]		:=	_obj.ID
		Resources[_ID][_ResType = "file" ? "Files" : "Libraries"][ A_Index ] :=	_obj.ID
		Resources[_obj.ID]				:=	_obj

	} else if !_ResType {
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