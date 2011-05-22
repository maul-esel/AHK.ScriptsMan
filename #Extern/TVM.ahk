/********************************************************************************************************************
 Treeview library: provides functions for common tree-view messages
	
	- TV_EditBegin() begins an edit operation on a "-ReadOnly" tree-view
	- TV_EditEnd() ends an edit operation
	
	- TV_GetHoveredItem() gets the id of the item currently hovered by the mouse
	- TV_GetItemFromPos() gets the id of an item at a specified position
	
	- TV_InitStateImage() prepares a tree-view for using state images
	
	- TV_SetImageList() changes the image list of a tree-view
	- TV_SetIndent() sets the indent between parent and child items
	- TV_SetLineColor() sets the color for the lines that connect items
	- TV_SetLPARAM() sets additional information of a item (used with TV_SortChildernCB())
	- TV_SetSelectedImage() associates an icon to an item which is shown when the item is selected
	- TV_SetStateImage() associates a state image (2nd icon) to an item
	- TV_SetTextColor() sets the color for the text in the listview
	
	- TV_SortChildernCB() sorts the items in a tree-view according to a user-defined function

*********************************************************************************************************************
*/
/********************************************************************************************************************
TV_EditBegin() - begins to edit a tree-view item. This works only if the tree-view has "-ReadOnly" style
			params:
				- sHwnd : handle (ahk_id) of the treeview
				- sID : the handle to the item returned by TV_Add()
			returns:
				- false on error, the edit handle otherwise.
					this handle could be used with ControlSetText etc.
*********************************************************************************************************************
*/
TV_EditBegin(sHwnd, sID) {
SendMessage 0x1100 + (A_IsUnicode ? 65 : 14), 0, sID,, ahk_id %sHwnd%
return ErrorLevel = "Fail" ? false : ErrorLevel
}


/********************************************************************************************************************
TV_EditEnd() - stops editing of a tree-view item.
			params: 
				- sHwnd : handle (ahk_id) of the treeview
				- sSave : true to save changes, false to delete them
			returns:
				- false on error, true otherwise
*********************************************************************************************************************
*/
TV_EndEdit(sHwnd, sSave) {
SendMessage 0x1100 + 22, sSave ? false : true, 0,, ahk_id %sHwnd%
return ErrorLevel = "Fail" ? false : ErrorLevel
}


/********************************************************************************************************************
TV_GetHoveredItem() - gets the id of the item currently hovered by the mouse.
			params:
				- sHwnd : handle (ahk_id) of the treeview
			returns:
				- false on error, the id otherwise
*********************************************************************************************************************
*/
TV_GetHoveredItem(sHwnd) {
MouseGetPos, _x, _y, _win
return TV_GetItemFromPos(_x, _y, _win, sHwnd)
}


/********************************************************************************************************************
TV_GetItemFromPos() - gets the id of an item, given the coordinates
			params:
				- sHwnd : handle (ahk_id) of the treeview
				- sX : the x-coordinate
				- sY : the y-coordinate
				- sRelative : the coordinates are relative to..
					- "Screen" : ...the screen
					- "TV" : ...the tree-view control
					- "Gn" : ...the gui number n
					- Hwnd : ...this window
			return:
				- the item id
*********************************************************************************************************************
*/
TV_GetItemFromPos(sHwnd, sX, sY, sRelative="TV") {

VarSetCapacity(POINT, 8, 0)
NumPut(sX, POINT, 0)
NumPut(sY, POINT, 4)

if RegExMatch(sRelative, "^G([1-99])$", Number) {				; if it is a gui,...
	Gui %Number1%: +LastFound
	_Hwnd := WinExist()											; ...get the handle
	}
else if sRelative is number										; if it is a hwnd, ...
	_Hwnd := sRelative											; ...save the handle

if (_Hwnd)														; if it is a gui or a hwnd,...
	DllCall("ClientToScreen", "UInt", _Hwnd, "UInt", &POINT)	; ...convert coordinates to screen
	
if (_Hwnd || sRelative = "Screen")								; if the coordinates were converted or are already relative to the screen,...
	DllCall("ScreenToClient", "UInt", sHwnd, "UInt", &POINT)	; ...convert them to tree-view client

VarSetCapacity(TVHITTEST, 16, 0)
NumPut(NumGet(POINT, 0), TVHITTEST, 0)							; if sRelative = TV : just put in and take out ;-)
NumPut(NumGet(POINT, 4), TVHITTEST, 4)

SendMessage 0x1100 + 17, 0, &TVHITTEST,, ahk_id %sHwnd%

return NumGet(TVHITTEST, 12)
}


/********************************************************************************************************************
TV_GetVisCount() - gets the count of FULL visible items.
			params:
				- sHwnd : handle (ahk_id) of the treeview
			returns:
				- the number nof items
*********************************************************************************************************************
*/
TV_GetVisCount(sHwnd) {
SendMessage 0x1100 + 16, 0, 0,, ahk_id %sHwnd%
return ErrorLevel
}


/********************************************************************************************************************
TV_SetStateImageList() - prepares a tree-view for usng state images by giving it an image list.
						This can also be used to change the image list later.
			params:
				- sHwnd : handle (ahk_id) of the treeview
				- sIL : handle to the image list that contains the state images
			returns:
				- "Fail" on error, otherwise previous state image list.
*********************************************************************************************************************
*/
TV_SetStateImageList(sHwnd, sIL) {
SendMessage 0x1100 + 09, 2, sIL,, ahk_id %sHwnd%
return ErrorLevel
}

/********************************************************************************************************************
TV_SetImageList() - changes the tree-view's image list.
			params:
				- sHwnd : handle (ahk_id) of the treeview
				- sIL : the handle to the image list.
			returns:
				- "Fail" on error, otherwise previous state image list.
*********************************************************************************************************************
*/
TV_SetImageList(sHwnd, sIL) {
SendMessage 0x1100 + 09, 1, sIL,, ahk_id %sHwnd%
return ErrorLevel
}


/********************************************************************************************************************
TV_SetIndent() - sets the indent between parent and child items
			params:
				- sHwnd : handle (ahk_id) of the treeview
				- sIndent : the indent in pixels
*********************************************************************************************************************
*/
TV_SetIndent(sHwnd, sIndent) {
SendMessage 0x1100 + 7, sIndent, 0,, ahk_id %sHwnd%
return ErrorLevel = "Fail" ? false : ErrorLevel
}


/********************************************************************************************************************
TV_SetItemHeight() - sets the height that each item uses
			params:
				- sHwnd : handle (ahk_id) of the treeview
				- sHeight : the height in pixels
			returns:
				- the previous height
			Remarks:
				- use height = -1 to reset the value
*********************************************************************************************************************
*/
TV_SetItemHeight(sHwnd, sHeight) {
SendMessage 0x1100 + 27, sHeight, 0,, ahk_id %sHwnd%
return ErrorLevel
}

/********************************************************************************************************************
TV_SetLineColor() - sets the color of the lines between items
			params:
				- sHwnd : handle (ahk_id) of the treeview
				- sColor : color (as BGR value)
			returns:
				- false on error, previous color otherwise
				; 0xFF000000 = def color?
*********************************************************************************************************************
*/
TV_SetLineColor(sHwnd, sColor) {
SendMessage 0x1100 + 40, 0, sColor,, ahk_id %sHwnd%
return ErrorLevel
}


/********************************************************************************************************************
TV_SetLPARAM() - associates information with an item.
				This information is mainly used with TV_SortChildernCB()
			params:
				- sHwnd : handle (ahk_id) of the treeview
				- sID : the handle to the item returned by TV_Add()
				- sLPARAM : the information. This must be a number.
			returns:
				- 
*********************************************************************************************************************
*/
TV_SetLPARAM(sHwnd, sID, sLPARAM) {
VarSetCapacity(TVITEM, 40, 0)
NumPut(0x0004|0x0010, TVITEM, 0)
NumPut(sLPARAM, TVITEM, 36)

SendMessage 0x1100 + (A_IsUnicode ? 63 : 13), 0, &TVITEM,, ahk_id %sHwnd%
return ErrorLevel = "Fail" ? false : ErrorLevel
}


/********************************************************************************************************************
TV_SetSelectedImage() - assigns a second icon to a tree-view item.
						This icon is displayed when the item is selected.
			params:
				- sHwnd : handle (ahk_id) of the treeview
				- sID : the handle to the item returned by TV_Add()
				- sIndex : the index of the image to use in the image list.
						NOTE: there are some problems with using the first image!
			returns:
				- false on error, true on success
*********************************************************************************************************************
*/
TV_SetSelectedImage(sHwnd, sID, sIndex){
VarSetCapacity(TVITEM, 32, 0)
NumPut(0x0020|0x0010, TVITEM, 0)
NumPut(sID, TVITEM, 4)
NumPut(sIndex, TVITEM, 28)
SendMessage 0x1100 + (A_IsUnicode ? 63 : 13), 0, &TVITEM,, ahk_id %sHwnd%
return ErrorLevel = "Fail" ? false : ErrorLevel
}


/********************************************************************************************************************
TV_SetStateImage() - sets a state image, which is a 2nd icon, for a treeview item
			params:
				- sID : the handle to the item returned by TV_Add()
				- sIndex : the index of the image to use in the image list.
						NOTE: there are some problems with using the first image!
				- sHwnd : handle (ahk_id) of the treeview
			returns:
				- false on error, true on success
*********************************************************************************************************************
*/
TV_SetStateImage(sHwnd, sID, sIndex) {
VarSetCapacity(TVITEM, 16, 0)
NumPut(0x0008|0x0010, TVITEM, 0)
NumPut(sID, TVITEM, 4)
NumPut(0xF000 & (sIndex << 12), TVITEM, 8)
NumPut(0xF000, TVITEM, 12)
SendMessage 0x1100 + (A_IsUnicode ? 63 : 13), 0, &TVITEM,, ahk_id %sHwnd%
return ErrorLevel = "Fail" ? false : ErrorLevel
}


/********************************************************************************************************************
TV_SetTextColor() - sets the color for ALL text in the tree-view.
			params:
				- sColor : color (as BGR value), -1 to restore default
				- sHwnd : handle (ahk_id) of the treeview
			returns:
				- false on error, previous color otherwise
*********************************************************************************************************************
*/
TV_SetTextColor(sHwnd, sColor) { ; -1 is default color
SendMessage 0x1100 + 30, 0, sColor,, ahk_id %sHwnd%
return ErrorLevel = "Fail" ? false : ErrorLevel
}


/********************************************************************************************************************
TV_SortChildernCB() - sorts children items using a custom function.
			params:
				- sParent : the id of the childrens parent item
				- sFunction : the name of the functions used to sort, or its address returned by RegisterCallback()
				- sHwnd : handle (ahk_id) of the treeview
				- [opt] sLPARAM : an additional value the function receives.
			returns:
				- false on error, true on success
	
	sFunction:
			params: sFunction must have 3 not-optional parameters.
					the first one will get the lparam value of the first item,
					the second will get the lparam value of the 2nd item
					and the third will get the value specified in sLPARAM (by default "TV_Sort")
			returns: sFunction should return a negative value if the first item should precede the second,
					a positive value if the first item should follow the second,
					or zero if the two items are equivalent.
			related:
				TV_SetLPARAM()
*********************************************************************************************************************
*/
TV_SortChildernCB(sHwnd, sParent, sFunction, sLPARAM="TV_Sort") {
if sFunction is not digit
	if IsFunc(sFunction)
		sFunction := RegisterCallback(sFunction)

VarSetCapacity(TVSORTCB, 12, 0)
NumPut(sParent, TVSORTCB, 0)
NumPut(sFunction, TVSORTCB, 4)
NumPut(sLPARAM, TVSORTCB, 8)

SendMessage 0x1100 + 21, 0, &TVSORTCB,, ahk_id %sHwnd%
return ErrorLevel = "Fail" ? false : ErrorLevel
}