Console_Helper(){
option := [], value := []

For i, param in Args{
	if A_Index = 1
		command := param
	else if RegExMatch(param, "àiU)^\s*([\w\s]*)='([\w\s]*)'\s*$", match)
		option[A_Index] := match1, value[A_Index] := match2		
	}
	
if command not in --help,--pack,--unpack,--priority,--add,--startgui,--
}