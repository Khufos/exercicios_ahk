;IB := InputBox("Please enter a phone number.", "Phone Number","w200 h100 X200 Y0")
;if IB.Result = "Cancel"
    ;MsgBox "You entered '" IB.Value "' but then cancelled."
;else
    ;MsgBox "You entered '" IB.Value "'."


^q::
{
name := InputBox("Digite seu nome","Tela de acesso","w200 h100 X200 Y0 T7")
if name.Result = "Cancel"
	MsgBox "Meu nome é " . name.Value
else
	MsgBox  "Você digitou '" name.Value  "'."
return
}