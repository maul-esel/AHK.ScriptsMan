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
FilesAreMissing() {
return !(FileExist(A_ScriptDir "\AHK.ScriptsMan.dll") 
		&& FileExist(A_ScriptDir "\Settings.xml")
		&& FileExist(A_ScriptDir "\Keywords_AHK_B.hes")
		&& FileExist(A_ScriptDir "\Keywords_AHK_L.hes")
		&& FileExist(A_ScriptDir "\Keywords_AHK_I.hes")
		&& FileExist(A_ScriptDir "\Keywords_AHK_2.hes"))
}
; **********************************************************************************************************************************************************************
SVS_GetLVHeader(sSubTree) {

nodes := (c := new XMLParser(Data_Manager.LanguageXML)).GetNodes("/Translation/UserInterface/MainGui/" sSubTree "/Header")
Loop nodes.length
	_Hdr .= nodes.item(A_Index - 1).text "|"

return SubStr(_Hdr, 1, StrLen(_Hdr) - 1)
}
; **********************************************************************************************************************************************************************
GetResourceXML(sID) {

LoopFiles %A_ScriptDir%\#Data\*.xml
	{
	_Name := XML_Get("/resource/@name", 1, A_LoopFileFullPath)
	_Type := XML_Get("/resource/@data-type", 1, A_LoopFileFullPath)
		
	if (_Name = Resources[sID].Name && _Type = Resources[sID].Type && _Name && _Type)
		return A_LoopFileFullPath
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
SVS_SetSetting(sTree, sValue, sFile=0) {

if (sFile = 0) {
	sFile := A_ScriptDir "\Settings.xml"
	sTree := "/settings" sTree
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

AbsolutePath(path){

if (!path || RegExMatch(path, "^\s*$"))
	return path

if ! DllCall("Shlwapi\PathIsRelative", "str", path)
	return path
	
if (InStr(path, "\") = 1)
	path := SubStr(path, 2, StrLen(path) -1)

if FileExist( Data_Manager.ScriptDir . path)
	return Data_Manager.ScriptDir . path

else
	return "...\" path
}

IsType(val, type){

if val is %type%
	return true
if (type = "object" && IsObject(val))
	return true
return false
}