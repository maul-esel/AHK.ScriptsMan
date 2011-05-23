Error(caller, code, reason, details, reaction){
MsgBox 4112, AHK.ScriptsMan - ERROR, An error occured during execution: `n`nerror %code% ("%reason%")`noccured in %caller%`n`ndetails:`n%details%`n`nreaction:`t%reaction%, 60
return
}

v(a){
MsgBox %a%
return a
}

A_LastError(error="t") ; by Bentschi: http://de.autohotkey.com/forum/viewtopic.php?t=8010
{
  buffer_size := VarSetCapacity(buffer, 1024, 0)
  Loop, % DllCall("FormatMessageA", "uint", 0x1200, ptr := (A_PtrSize) ? "ptr" : "uint", 0, "uint", error != "t" ? error : A_LastError, "uint", 0x10000, ptr, &buffer, "uint", buffer_size, ptr, 0)
    error_msg .= Chr(NumGet(buffer, A_Index-1, "uchar"))
  return (error != "t" ? error : A_LastError) " - " error_msg
}