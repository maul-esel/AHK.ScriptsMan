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
	
		lid := Project_List(doc, "/resource", 0, A_LoopFileFullPath)
		
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