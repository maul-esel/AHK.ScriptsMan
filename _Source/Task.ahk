Task_Add() {

InputBox _Name,		AHK.ScriptsMan,	% XML_Translation("/UserInterface/Dialogs/CreateTask"),,,,,,,60
if (ErrorLevel || !_Name)
	return

Loop {
;	IniRead		_Var,	%A_ScriptDir%\#Data\AHK.ScriptsMan.ini,	tasks,	%_Task%.Description
	if (_Var != "ERROR")
		_Task := A_Index "_" _Task
	else
		break
	}

;IniWrite	%_Name%,	%A_ScriptDir%\#Data\AHK.ScriptsMan.ini,	tasks,	% SVS_Convert2Key(_Task) "[]"
;IniWrite	%_Text%,	%A_ScriptDir%\#Data\AHK.ScriptsMan.ini,	tasks,	% SVS_Convert2Key(_Task) ".Description"
;IniWrite	0,			%A_ScriptDir%\#Data\AHK.ScriptsMan.ini,	tasks,	% SVS_Convert2Key(_Task) ".Remember" ;==================================================================

Gui 1: Default
Gui 1: Listview, Tasks_LV
_Var := LV_Add("", _Name)
;Tasks_LV("Normal", _Var)
return
}