class cFile extends cResource {
	OpenProject() {
	return
	}
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