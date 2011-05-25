File_OpenResource(sID) {

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
	LV_Add("", nodes.item(A_Index - 1).attributes.getNamedItem("name").nodeValue)

GuiControl 1: +Redraw, ResourceUserData_LV
GuiControl 1: +Redraw, ResourceProjects_LV

If (FileExist(Resources[sID].Path) && Resources[sID].Path && !FileIsBinary(Resources[sID].Path)){
	FileRead _Temp, % Resources[sID].Path
	SCI_SetText(Gui.SCI1, _Temp)
	}
return
}
; **********************************************************************************************************************************************************************
File_OpenProject(sID) {
return
}
; **********************************************************************************************************************************************************************
File_Create() {

InputBox	_Name,	AHK.ScriptsMan,	% XML_Translation("/UserInterface/Dialogs/AddFile", 1),,,,,,,60
if (ErrorLevel || !_Name)
	return

_Path := _Name
Loop {
	if FileExist(A_ScriptDir "\#Data\" _Path ".xml")
		break
	_Path := A_Index "-" _Name
	}

;IniWrite	%_Name%,	%A_ScriptDir%\#Data\%_File%.svfile,	general,	Name
;IniWrite	File,		%A_ScriptDir%\#Data\%_File%.svfile,	general,	Res.Type

MsgBox 4, AHK.ScriptsMan,	% XML_Translation("/UserInterface/Dialogs/AddFile", 2), 60
IfMsgBox, Yes
	{
	FileSelectFile	_Path,	3,	%_ScriptDir%, % XML_Translation("/UserInterface/Dialogs/AddFile", 3)
	if _Path
		{
;		IniWrite	%_Path%,	%A_ScriptDir%\#Data\%_File%.svfile, User.Data,	Path[]
		FileGetSize _Size, %_Path%, K
		}
	}

return
}