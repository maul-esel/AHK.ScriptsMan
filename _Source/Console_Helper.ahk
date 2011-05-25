Console_Helper(){
option := [], value := []

For i, param in Args{
	if (A_Index = 1)
		command := param
	else if RegExMatch(param, "`aiU)^\s*([\w\s]*)='([\w\s]*)'\s*$", match)
		option[A_Index] := match1, value[A_Index] := match2		
	}
	
if command not in --help,--pack,--unpack,--priority,--add,--startgui,--
	return Console_Output("error: invalid command specified: " command "`n", true)
}

Console_Output(msg, isError){
if !Console.Init
	Console.TakeExisting(GetCurrentParentProcessID())
	Console.Init := true

if isError
	MsgBox % Console.SetWritingColor()
return Console.Write(msg)
}