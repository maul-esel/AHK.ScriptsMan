SPanel_MoveUp(sNr) {
return DllCall("AnimateWindow", "UInt", Gui["Panel" sNr], "Int", 500, "UInt", 0x00020000|0x00000004) ;|0x00040000)
}

SPanel_MoveDown(sNr) {
return DllCall("AnimateWindow", "UInt", Gui["Panel" sNr], "Int", 500, "UInt", 0x00010000|0x00000004) ;|0x00040000)
}

sPanel_FadeIn(sNr) {
return DllCall("AnimateWindow", "UInt", Gui["Panel" sNr], "Int", 500, "UInt", 0x00020000|0x00000010)
}

sPanel_FadeOut(sNr) {
return DllCall("AnimateWindow", "UInt", Gui["Panel" sNr], "Int", 500, "UInt", 0x00010000|0x00000010)
}

Tab_GetLParam(hTab, index){
VarSetCapacity(TCITEM, 7*4, 0)
NumPut(0x0008, TCITEM, 0)
SendMessage 0x1300 + (A_IsUnicode ? 60 : 5), index, &TCITEM,, ahk_id %hTab%
return NumGet(&TCITEM+0, 24)
}

Tab_SetLParam(hTab, index, info){
VarSetCapacity(TCITEM, 7*4, 0)
NumPut(0x0008, TCITEM, 0)
NumPut(info, TCITEM, 24)
SendMessage 0x1300 + (A_IsUnicode ? 61 : 6), index, &TCITEM,, ahk_id %hTab%
return ErrorLevel
}