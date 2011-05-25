FileIsBinary(_filePath){

FileRead f, %_filePath%
if ErrorLevel
	return -1

Loop VarSetCapacity(f){
	If ((NumGet(f, (i := A_Index) - 1, "UChar")) = 0){
		isBinary := true
		Break
		}
	}
return isBinary
}