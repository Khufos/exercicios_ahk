#SingleInstance Force
Browser_Forward::Reload()
Browser_Back::
^q::
{ ; V1toV2: Added bracket
try XL := ComObjActive("Excel.Application") ;handle to running application
Catch {
    MsgBox("no existing Excl ojbect:  Need to create one")
XL := ComObject("Excel.Application")
XL.Visible := 1 ;1=Visible/Default 0=hidden
}
XL.Visible := 1 ;1=Visible/Default 0=hidden
MsgBox("is an object? " IsObject(XL))
} ; V1toV2: Added bracket in the end
