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