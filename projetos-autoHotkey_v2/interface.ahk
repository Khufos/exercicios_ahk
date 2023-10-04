main := Gui()
main.add("ListView","w300 r20",["name","last name"])
main.add("Button","w75","OK").OnEvent("click",ShowOKMessage)
main.add("Button","x+m w75","cancel")

main.show()

showOKMessage(*)
{
	MsgBox "Está tudo ok!"
}