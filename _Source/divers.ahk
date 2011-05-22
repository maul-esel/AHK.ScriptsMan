SVS_Bool(sContent) {
if sContent
	return XML_Translation("/UserInterface/Common/True")
else
	return XML_Translation("/UserInterface/Common/False")
}
; **********************************************************************************************************************************************************************
SVS_BrowseAHK_Exe(sAHK) {
FileSelectFile _Path, 3, %A_ProgramFiles%, % XML_Translation("/UserInterface/Dialogs/BrowseAHK_" sAHK "_EXE"), (*.exe)
if not _Path
	return
SplitPath _Path, , , _Ext
if (_Ext != "EXE")
	return
_Name := "PathAHK_" (sAHK = "B" ? "B" : (sAHK = "L" ? "L" : "I")) "_EXE"
GuiControl 1: , %_Name%, %_Path%
SVS_SetSetting("general", "path.AHK." (sAHK = "B" ? "B" : (sAHK = "L" ? "L" : "I")), _Path)
return
}
; **********************************************************************************************************************************************************************
SVS_CheckFiles() {
return (FileExist(A_ScriptDir "\AHK.ScriptsMan.dll") 
		&& FileExist(A_ScriptDir "\Settings.xml")
		&& FileExist(A_ScriptDir "\Keywords_AHK_B.hes")
		&& FileExist(A_ScriptDir "\Keywords_AHK_L.hes")
		&& FileExist(A_ScriptDir "\Keywords_AHK_I.hes")
		&& FileExist(A_ScriptDir "\Keywords_AHK_2.hes"))
}
; *********************************************************************************************************************************************************************
SVS_GetAvailableLanguages(sSource) {

_Query := sQuery
sQuery := ""

if (sSource) {
	Loop % XML_Get("/source_languages/available")
		{
		_Name := XML_Get("/source_languages/language", A_Index)
		if (_Query && _Query = _Name)
			sQuery := XML_Get("/source_languages/file", A_Index)
		_Languages .= _Name "|"
		}
} else {
	LoopFiles %A_ScriptDir%\#Data\Languages\*.xml
		{
		_Name := XML_Get("/Translation/Language", 1, A_LoopFileLongPath)
		if (_Query && _Query = _Name)
			sQuery := A_LoopFileLongPath
		_Languages .= _Name "|"
		}
	}

return SubStr(_Languages, 1, StrLen(_Languages) - 1)
}
; **********************************************************************************************************************************************************************
SVS_GetKeyName(sIni, sSection, sValue, sRemoveFlags) { ; REWRITE!!!

FileRead sIni, %sIni%
_BeginSection	:=	RegExMatch(sIni, "`aim)^[\s\t]*\Q[" sSection "]\E[\s\t]*$")
if (!_BeginSection)
	return
_S := RegExMatch(sIni, "`aim)^[\s\t]*\[.*\][\s\t]*$", "", _BeginSection + StrLen(sSection) + 1)
_EndSection		:=	( _S ? _S+1 : StrLen(sIni))

_Found := RegExMatch(sIni, "`aim)^(.*)=\Q" sValue "\E\s*$", _Match, _BeginSection)
_Name := _Found < _EndSection && _Found ? _Match1 : ""
;MsgBox % "[" sSection "] > " sValue " < " _Name "==> " _Found " < " _EndSection " && " _Found " ? " _Match1 " : """"" "`n`n in `n`n " sIni

if sRemoveFlags
	_Name := RegExReplace(_Name, "`aim)^(.*)\[([-\+#\*]*)\]\s*$", "$1", "", 1)

return _Name
}
; **********************************************************************************************************************************************************************
SVS_GetLVHeader(sSubTree) {

nodes := (c := new XMLParser(Data_Manager.LanguageXML)).GetNodes("/Translation/UserInterface/MainGui/" sSubTree "/Header")
Loop nodes.length
	_Hdr .= nodes.item(A_Index - 1).text "|"

return SubStr(_Hdr, 1, StrLen(_Hdr) - 1)
}
; **********************************************************************************************************************************************************************
SVS_GetFilePath(sID) {
return false ; for old code, new reads it from Data_Manager
}
; **********************************************************************************************************************************************************************
SVS_GetResourceXML(sID) {

LoopFiles %A_ScriptDir%\#Data\*.xml
	{
	_Name := XML_Get("/Resource/@Name", 1, A_LoopFileFullPath)
	_Type := XML_Get("/Resource/@DataType", 1, A_LoopFileFullPath)
		
	if (_Name = Resources[sID].Name && _Type = Resources[sID].Type && _Name && _Type) {
		;MsgBox % _Name "=" Data_Manager[sID].Name "&&" _Type "=" Data_Manager[sID].Type ">>" A_LoopFileLongPath
		return A_LoopFileFullPath
		}
	}
return false
}
; **********************************************************************************************************************************************************************
SVS_IL(sCount, sMin, sLarge, sDef=0) {

IL := IL_Create(sCount, 1, sLarge)
Loop sCount
	IL_Add(IL, A_ScriptDir "\AHK.ScriptsMan.dll", A_Index + sMin)
if sDef
	Loop 6
		IL_Add(IL, A_ScriptDir "\AHK.ScriptsMan.dll", A_Index + 9)
return IL
}
; **********************************************************************************************************************************************************************
SVS_SaveSettings() {
global Path7zip, PathAHK_B_EXE, PathAHK_L_EXE, PathAHK_I_EXE, PathScripts, EnableUpdates, UserLanguage
Gui 1: Submit, NoHide
return ; wrong variables

SVS_SetSetting("paths/7zip",		Path7zip)
SVS_SetSetting("path/AHK/Basic",	PathAHK_B_EXE)
SVS_SetSetting("path/AHK/Lexikos",	PathAHK_L_EXE)
SVS_SetSetting("path/AHK/IronAHK",	PathAHK_I_EXE)
SVS_SetSetting("path/ScriptDir",	PathScripts)
SVS_SetSetting("language",			UserLanguage)
return

}
; **********************************************************************************************************************************************************************
SVS_SetSetting(sTree, sValue, sFile=0) {

if (sFile = 0) {
	sFile := A_ScriptDir "\Settings.xml"
	sTree := "/Settings" sTree
	}
doc := new XMLParser(sFile)
return doc.SetText(sTree, sValue)
}
; **********************************************************************************************************************************************************************
SVS_Toolbuttons(sIndex) {
static CONST_1 := "Treeview", CONST_2 := "Tasks", CONST_3 := "QuickEdit", CONST_4 := "Resources"
, CONST_5 := "Projects", CONST_6 := "Projects/Tasks", CONST_7 := "Resources/FilesLibs", CONST_8 := "Resources/Overview"

buttons := (new XMLParser(Data_Manager.LanguageXML)).GetNodes("/Translation/UserInterface/MainGui/" CONST_%sIndex% "/ToolButton")
Loop buttons.length {
	_Var := buttons.item(A_Index - 1).text
	_Hdr .= _Var ", " A_Index
	}
;MsgBox, 4096,,% _Hdr
return _Hdr
}
