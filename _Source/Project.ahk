class cProject
	{
	OpenResource(){
	return this.Open()	
	}
	; **********************************************************************************************************************************************************************
	OpenProject(){
	return this.Open()
	}
	; **********************************************************************************************************************************************************************
	Save2Obj() {

	this.Notes := SCI_GetText(Gui.SCI2)

	GuiControlGet _Var, 1:, StatDDL
	this.Status := _Var

	_Temp := "BLI2"
	LoopParse _Temp
		{
		GuiControlGet _Var, 1:, AHK%A_LoopField%
		this.compatibility["AHK" A_LoopField ] := _Var
		}
	
	GuiControlGet _Var, 1:, TypCombo
	this.projecttype	:= _Var

	GuiControlGet _Var, 1:, GoalEdit
	this.purpose		:= _Var

	this.lastmod		:=	A_Now

	if (XML_Get("/always_safe") = "1")
		return this.Save2File(false)

	return
	}
	; **********************************************************************************************************************************************************************
	Save2File(recurse = true){

	this.XML.SetText(this.Tree . "/properties/priority",				this.Priority)
	this.XML.SetText(this.Tree . "/properties/status",					this.Status)
	this.XML.SetText(this.Tree . "/properties/compatibility/basic",		this.compatibility.AHKB)
	this.XML.SetText(this.Tree . "/properties/compatibility/lexikos",	this.compatibility.AHKL)
	this.XML.SetText(this.Tree . "/properties/compatibility/iron-ahk",	this.compatibility.AHKI)
	this.XML.SetText(this.Tree . "/properties/compatibility/ahk-2",		this.compatibility.AHK2)
	this.XML.SetText(this.Tree . "/properties/type",					this.projecttype)
	this.XML.SetText(this.Tree . "/properties/purpose",					this.Purpose)
	this.XML.SetText(this.Tree . "/properties/last-mod",				this.lastmod)
	this.XML.SetText(this.Tree . "/properties/notes",					this.Notes)

	this.XML.Save(this.File)

	if (recurse)
		For i, id in this.Subs
			Resources[id].Save2File()
	return
	}
	; **********************************************************************************************************************************************************************
	SetPriority() {

	Inputbox _Priority, AHK.ScriptsMan, % XML_Translation("/UserInterface/Dialogs/SetPriority", 1),,,,,,,60
	if (ErrorLevel || !_Priority)
		return -1
	
	if (_Priority != 1 && _Priority != 2 && _Priority != 3) {
		Error(A_ThisFunc "()", "-0x0004", "invalid project priority (invalid user input)", XML_Translation("/UserInterface/Dialogs/SetPriority", 2), "the operation will be aborted")
		return -1
		}

	this.Priority := _Priority	
	TV_SetStateImage(Gui.Treeview.Handle, this.ID, _Priority)

	return
	}
	; **********************************************************************************************************************************************************************
	List(sDoc, sTree, sPID, sFile) {

	Gui 1: Default
	Gui 1: Treeview, ResourceTree
	Gui 1: ListView, Resource_LV

	this.Priority		:=	sDoc.Get(sTree . "/properties/priority")
	this.Name			:=	sDoc.Node(sTree).attributes.getNamedItem("name").nodeValue
	if Resources.List.HasKey(this.Name)
		return
	
	this.ID				:=	TV_Add(this.Name, sPID, "icon3 expand") ; icon: project
	this.Type			:=	"project"
	this.context		:=	sPID ? "project" : "resource"
	this.ParentID		:=	sPID
	this.ParentTree		:=	Resources[sPID].ParentTree "/" this.Name
	this.XML			:=	sDoc
	this.Tree			:=	sTree
	this.compatibility	:=	{"AHKB"		:	sDoc.Get(sTree . "/properties/compatibility/basic")
							, "AHKL"	:	sDoc.Get(sTree . "/properties/compatibility/lexikos")
							, "AHKI"	:	sDoc.Get(sTree . "/properties/compatibility/iron-ahk")
							, "AHK2"	:	sDoc.Get(sTree . "/properties/compatibility/ahk-2")}
	this.File			:=	sFile
	
	Resources.List[this.Name]	:=	this.ID
	Resources[this.ID]			:=	this
	
	TV_SetStateImage(Gui.Treeview.Handle, this.ID, this.Priority = 3 ? 3 : (this.Priority = 2 ? 2 : 1))
	LV_Add("", this.Name, "project", this.ID)

	Gui 1: Listview, CommonTasks_LV
	_list		:=	this.XML.GetNodes(this.Tree . "/tasks/task")
	Loop _list.length
		LV_Add("", _list.item(A_Index - 1).attributes.getNamedItem("name").nodeValue, _list.item(A_Index - 1).text, this.ParentTree)

	this.Files	:=	[]
	_list		:=	this.XML.GetNodes(this.Tree . "/files/file")
	Loop _list.length{
		
		_file			:=	new cFile
		_file.Name		:=	_list.item(A_Index - 1).attributes.getNamedItem("name").nodeValue
		_file.ID		:=	TV_Add(_file.Name, this.ID, "Icon4") ; icon: file
		_file.context	:=	"project"
		_file.ParentID	:=	this.ID
		_file.XML		:=	this.XML
		_file.Tree		:=	this.Tree . "/files/file[" A_Index-1 "]"
		_file.File		:=	this.File
		
		Resources[_file.ID]		:=	_file
		this.Files[ A_Index ]	:= _file.ID
		}

	this.Libraries	:=	[]
	_list			:=	this.XML.GetNodes(this.Tree . "/libraries/lib")
	Loop _list.length{
		
		_lib			:=	new cLibrary
		_lib.Name		:=	_list.item(A_Index - 1).attributes.getNamedItem("name").nodeValue
		_lib.ID			:=	TV_Add(_lib.Name, this.ID, "Icon5") ; icon lib
		_lib.Type		:=	"library"
		_lib.context	:=	"project"
		_lib.ParentID	:=	this.ID
		_lib.XML		:=	this.XML
		_lib.Tree		:=	this.Tree . "/libraries/lib[" A_Index-1 "]"
		_lib.File		:=	this.File
		
		Resources[_lib.ID]			:=	_lib
		this.Libraries[ A_Index ]	:=	_lib.ID
		}

	this.Subs	:=	{}
	_list		:=	this.XML.GetNodes(this.Tree . "/sub")	
	Loop _list.length {
		_sub			:=	new cProject
		_sub.List(this.XML, this.Tree . "/sub[" A_Index-1 "]",  this.ID, this.File)
		
		this.Subs[ A_Index ]	:=	_sub.ID
		}
	
	return this.ID
	}
	; **********************************************************************************************************************************************************************
	Open() {

	If (Resources.ActiveID = this.ID)
		return -1
	
	Gui 1: Default
	Gui 1: Listview, ProjectFiles_LV
		LV_Delete()
		GuiControl -Redraw, ProjectFiles_LV

	For i, _ID in this.Files {

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
		
			_Value		:=	this.XML.Get(Resources[_ID].Tree . "/metadata/metadata[@name='" . _keyword . "']").text
			_Flag		:=	this.XML.Get(Resources[_ID].Tree . "/metadata/metadata[@name='" . _keyword . "']").attributes.getNamedItem("flag").nodeValue
			_Count		:=	this.XML.Count(Resources[_ID].Tree . "/metadata/metadata[@name='" . _keyword . "']")
		
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

	For i, _ID in this.Libraries {
	
		if (! Resources[_ID].ResourceXML)
			Resources[_ID].ResourceXML := GetResourceXML(_ID)		
	
		if (Resources[_ID].ResourceXML)
			rDoc := new XMLParser(Resources[_ID].ResourceXML)

		For property, _keyword in Keyword.lib
			{
			if (! Resources[_ID].HasKey(property) && Resources[_ID].ResourceXML){
				_Value	:=	rDoc.Node("/resource/metadata/metadata[@name='" . _keyword . "']").text
				_Flag	:=	rDoc.Node("/resource/metadata/metadata[@name='" . _keyword . "']").attributes.getNamedItem("flag").nodeValue
				_Count	:=	rDoc.HasNode("/resource/metadata/metadata[@name='" . _keyword . "']")

				if (!InStr(_Flag, "#") && (!InStr(_Flag, "-") || property = "hide") && _Count)
					Resources[_ID][property]	:=	_Value
				}
		
			_Value		:=	this.XML.Get(Resources[_ID].Tree . "/metadata/metadata[@name='" . _keyword . "']").text
			_Flag		:=	this.XML.Get(Resources[_ID].Tree . "/metadata/metadata[@name='" . _keyword . "']").attributes.getNamedItem("flag").nodeValue
			_Count		:=	this.XML.Count(Resources[_ID].Tree . "/metadata/metadata[@name='" . _keyword . "']")
			if (!InStr(_Flag, "#") && (!InStr(_Flag, "-") || property = "hide") && _Count)
				Resources[_ID][property]	:=	_Value	
			}
		
		if Resources[_ID].Hide
			continue
	
		LV_Add("",	Resources[_ID].Name
				,	Resources[_ID].Author
				,	Resources[_ID].License
				,	Resources[_ID].Version)
		}
	Loop 4
		LV_ModifyCol(A_Index, "AutoHdr")

	Gui 1: ListView, ProjectUserData_LV
		LV_Delete()
		GuiControl -Redraw, ProjectUserData_LV

	_list	:=	this.XML.GetNodes(this.Tree . "/metadata/metadata")
	Loop _list.length {
	
		metadata	:=	_list.item(A_Index - 1).attributes.getNamedItem("name").nodeValue
		value		:=	_list.item(A_Index - 1).text
		flag		:=	_list.item(A_Index - 1).attributes.getNamedItem("flag").nodeValue
	
		if InStr(flag, "-")
			continue
		
		if InStr(flag, "+") {
			this.DefData	:=	metadata
			metadata		:=	"[+] " metadata
			}
	
		LV_Add("", metadata, value)
	
		}
	Loop 2
		LV_ModifyCol(A_Index, "AutoHdr")

	if (! this.HasKey("status"))
		this.status					:=	this.XML.Get(this.Tree . "/properties/status")
	if (! this.compatibility.HasKey("AHKB"))
		this.compatibility.AHKB		:=	this.XML.Get(this.Tree . "/properties/compatibility/basic")
	if (! this.compatibility.HasKey("AHKL"))
		this.compatibility.AHKL		:=	this.XML.Get(this.Tree . "/properties/compatibility/lexikos")
	if (! this.compatibility.HasKey("AHKI"))
		this.compatibility.AHKI		:=	this.XML.Get(this.Tree . "/properties/compatibility/iron-ahk")
	if (! this.compatibility.HasKey("AHK2"))
		this.compatibility.AHK2		:=	this.XML.Get(this.Tree . "/properties/compatibility/ahk-2")
	if (! this.HasKey("projecttype"))
		this.projecttype			:=	this.XML.Get(this.Tree . "/properties/type")
	if (! this.HasKey("purpose"))
		this.purpose				:=	this.XML.Get(this.Tree . "/properties/purpose")
	if (! this.HasKey("lastmod"))
		this.lastmod				:=	this.XML.Get(this.Tree . "/properties/last-mod")
	if (! this.HasKey("notes"))
		this.notes					:=	this.XML.Get(this.Tree . "/properties/notes")


	GuiControl 1:	Text, StatDDL,	% this.status
	GuiControl 1:		, AHKB,		% this.compatibility.AHKB ? 1 : 0
	GuiControl 1:		, AHKL,		% this.compatibility.AHKL ? 1 : 0
	GuiControl 1:		, AHKI,		% this.compatibility.AHKI ? 1 : 0
	GuiControl 1:		, AHK2,		% this.compatibility.AHK2 ? 1 : 0
	GuiControl 1:	Text, TypCombo,	% this.projecttype
	GuiControl 1:		, GoalEdit,	% this.purpose
	FormatTime _Temp, % this.lastmod, LongDate
	GuiControl 1:		, LModEdit,	% this.lastmod := _Temp

	GuiControl 1: +Redraw, ProjectFiles_LV
	GuiControl 1: +Redraw, ProjectLibraries_LV
	GuiControl 1: +Redraw, ProjectUserData_LV

	SCI_SetText(Gui.SCI2, this.notes)

	return
	}

	; **********************************************************************************************************************************************************************
	AddUserData() {
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
	
		Loop LV_GetCount(){
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
	; **********************************************************************************************************************************************************************
	Package(){
	time	:=	A_Now
	file	:=	this.file
	type	:=	this.type
	name	:=	this.Name
	
	_list	:=	this.XML.GetNodes(this.Tree "/files/file")
	Loop _list.length {
		_name	:=	_list.item(A_Index - 1).attributes.getNamedItem("name").nodeValue
		rid		:=	Resources.List[_name]
		
		_data_file	:=	Resources[rid].file
		SplitPath	_data_file, _file_name
		FileCopy	%_data_file%,	%A_ScriptDir%\#Temp\%time%_package\%_file_name%.package_index_1.%A_Index%.1, 1
		FileAppend	1.%A_Index%.1: added data file for file resource [%_name%]: %_file_name%.package_index_1.%A_Index%.1, %A_ScriptDir%\#Temp\%time%_package\package.logfile
		
		if !(Resources[rid].HasKey("path")){
			_Value	:=	Resources[rid].XML.Node(Resources[rid].Tree "/metadata/metadata[@name='path']").text
			_Flag	:=	Resources[rid].XML.Node(Resources[rid].Tree "/metadata/metadata[@name='path']").attributes.getNamedItem("flag").nodeValue
			if (_Value && !InStr(_Flag, "#"))
				Resources[rid].path	:=	_Value
			}
		if FileExist(path := AbsolutePath(Resources[rid].path)){
			SplitPath path, _file_name
			FileCopy %path%, %A_ScriptDir%\#Temp\%time%_package\%_file_name%.package_index_1.%A_Index%.2, 1
			FileAppend 1.%A_Index%.2: added file for file resource [%_name%]: %_file_name%.package_index_1.%A_Index%.2, %A_ScriptDir%\#Temp\%time%_package\package.logfile
		} else
			FileAppend 1.%A_Index%.2: error: file for file resource [%_name%]: not found (path = '%path%'), %A_ScriptDir%\#Temp\%time%_package\package.logfile
		}
	
	_list	:=	this.XML.GetNodes(this.Tree "/libraries/lib")
	Loop _list.length {
		_name	:=	_list.item(A_Index - 1).attributes.getNamedItem("name").nodeValue
		rid		:=	Resources.List[_name]
		
		_data_file	:=	Resources[rid].file
		SplitPath	_data_file, _file_name
		FileCopy	%_data_file%,	%A_ScriptDir%\#Temp\%time%_package\%_file_name%.package_index_2.%A_Index%.1, 1
		FileAppend	2.%A_Index%.1: added data file for library resource [%_name%]: %_file_name%.package_index_2.%A_Index%.1, %A_ScriptDir%\#Temp\%time%_package\package.logfile
		
		if !(Resources[rid].HasKey("path")){
			_Value	:=	Resources[rid].XML.Node(Resources[rid].Tree "/metadata/metadata[@name='path']").text
			_Flag	:=	Resources[rid].XML.Node(Resources[rid].Tree "/metadata/metadata[@name='path']").attributes.getNamedItem("flag").nodeValue
			if (_Value && !InStr(_Flag, "#"))
				Resources[rid].path	:=	_Value
			}	
		if FileExist(path := AbsolutePath(Resources[rid].path)){
			SplitPath path, _file_name
			FileCopy %path%, %A_ScriptDir%\#Temp\%time%_package\%_file_name%.package_index_2.%A_Index%.2, 1
			FileAppend 2.%A_Index%.2: added file for library resource [%name%]: %_file_name%.package_index_2.%A_Index%.2, %A_ScriptDir%\#Temp\%time%_package\package.logfile
		} else
			FileAppend 2.%A_Index%.2: error: file for library resource [%_name%]: not found (path = '%path%'), %A_ScriptDir%\#Temp\%time%_package\package.logfile
		}
		
	if FileExist(path := AbsolutePath(this.path)){
		SplitPath	path, _file_name
		FileCopy	%path%, %A_ScriptDir%\#Temp\%time%_package\%_file_name%.package_main_1.1.2, 1
		FileAppend	1.1.2: added file for %type% resource [%name%]: %_file_name%.package_main_1.1.2, %A_ScriptDir%\#Temp\%time%_package\package.logfile
	} else
		FileAppend	1.1.2: error: file for %type% resource [%name%]: not found (path = '%path%'), %A_ScriptDir%\#Temp\%time%_package\package.logfile
	
	RegisterCom(true)
	Zip := ComObjCreate("XStandard.Zip")

	LoopFiles %A_ScriptDir%\#Temp\%time%_package\*
		Zip.Pack(A_LoopFileFullPath, A_ScriptDir "\#Temp\" time "_package.zip", false, "", 9)
	
	ObjRelease(Zip)
	RegisterCom(false)
	}
}

; **********************************************************************************************************************************************************************
Project_Create() {

	InputBox _Project, AHK.ScriptsMan, % XML_Translation("/UserInterface/Dialogs/CreateProject", 1),,,,,,,60
	if (ErrorLevel || !_Project)
		return 0

	if (Resources.List.HasKey(_Project)){
		Error(A_ThisFunc "()", "-0x0003", "duplicate resource name (invalid user input)", XML_Translation("/UserInterface/Dialogs/CreateProject", 2), "The operation will be aborted.")
		return
		}
	
	InputBox _Parent, AHK.ScriptsMan, % XML_Translation("/UserInterface/Dialogs/CreateProject", 3),,,,,,,60
	if (ErrorLevel || !_Parent || Resources[_Parent].type != "project"){
		_Parent :=	null
		_Path	:=	_Project
		_Tree	:=	"/resource"
		
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
		xml := new XMLParser(xml, true)
	} else {
		_Path	:=	Resources[_Parent].File
		_Tree	:=	Resources[_Parent].Tree . "/sub[" . Resources[_Parent].XML.Count(Resources[_Parent].Tree . "/sub") "]"

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
		}
		
	xml.Save(_Path)

	_project := new cProject
	_project.List(xml, _Tree, _Parent, _Path)
	
	Loop 7
		WinHide % "ahk_id " Gui["Panel" A_Index + 1]
	_project.Open()
	WinShow % "ahk_id " Gui.Panel5
	
	return
	}