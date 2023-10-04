#SingleInstance


; Create the popup menu by adding some items to it.
MyMenu := Menu()
MyMenu.Add("Text",, "Calculadora")
MyMenu.Add("Text",, "Bloco de notas")
MyMenu.Ad




calculadora(*) {
	Run "ahk_exe ApplicationFrameHost.exe"
	return
}
notepad(*)
{
	Run "notepad.exe"
	return
}


^q::MyMenu.Show  ; i.e. press the Win-Z hotkey to show the menu.