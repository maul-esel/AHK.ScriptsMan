class XMLParser
	{
	__New(data, isread = false){
		this.doc := ComObjCreate("MSXML2.DOMDocument")
		if (isread)
			this.LoadXML(data)
		else
			this.Load(data)
		}
		
/*	__Get(property){
		return this.doc[property]
		}
		
	__Set(property, value){
		return this.doc[property] := value
		}
*/		
	Load(_file){
		return this.doc.Load(_file)
		}
		
	LoadXML(data){
		return this.doc.LoadXML(data)
		}
		
	Get(xpath, i=1, type="text"){
		return XML_Decode(this.GetNodes(xpath).item(i-1)[type])
		}
		
	Node(xpath){
		return this.doc.selectSingleNode(xpath)
		}
		
	GetNodes(xpath){
		return this.doc.selectNodes(xpath)
		}

	Count(xpath){
		return this.GetNodes(xpath).length
		}
	
	Save(location){
		FileDelete %location%
		FileAppend % this.doc.documentElement.xml, %location%
		return ErrorLevel
		}
		
	HasNode(xpath){
		return IsObject(this.Node(xpath))
		}
		
	SetText(xpath, value, index=1){
		if !this.HasNode(xpath, index)
			LoopParse xpath, /
				{
				if (A_Index = 1)
					continue
				if !this.HasNode(curr_path "/" A_LoopField)
					this.Node(curr_path).appendChild(this.doc.createElement(A_LoopField))
				curr_path .= "/" A_LoopField
				}

		return this.doc.selectNodes(xpath).item(index-1).text := XML_Encode(value)
		}
	}

XML_Get(sTree, sIndex = 1, sFile = 0, sProperty = "text") {

if (sFile = 0){
	sFile := A_ScriptDir "\Settings.xml"
	sTree := "/settings" sTree
	}

doc := new XMLParser(sFile)
return XML_Decode(doc.GetNodes(sTree).item(sIndex - 1)[sProperty])
}

XML_Translation(sTree, sIndex = 1) {
return XML_Get("/Translation" sTree, sIndex, Data_Manager.LanguageXML)
}

XML_Encode(sText) {
StrReplace sText, sText, <,			&lt;,	1
StrReplace sText, sText, >,			&gt;,	1
StrReplace sText, sText, &,			&amp;,	1
StrReplace sText, sText, ",			&quot;,	1
StrReplace sText, sText, ',			&apos;,	1
StrReplace sText, sText, %A_Space%,	&#160;,	1
return sText
}

XML_Decode(sXML) {
StrReplace sXML, sXML, &lt;,		<,	1
StrReplace sXML, sXML, &gt;,		>,	1
StrReplace sXML, sXML, &amp;,		&,	1
StrReplace sXML, sXML, &quot;,		",	1
StrReplace sXML, sXML, &apos;,		',	1
StrReplace sXML, sXML, &#160,		%A_Space%,	1
return sXML
}