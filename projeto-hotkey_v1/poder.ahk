#SingleInstance

menu_principal := Menu()
menu_principal.Add("Calculadora", calculadora)
menu_principal.Add("Bloco de notas", notepad)
menu_principal.Add("mais", plus)

menu_secundario := Menu()
menu_secundario.Add("Google", google)
menu_principal.Add("Mais", menu_secundario)

return

google(A_ThisMenuItem, A_ThisMenuItemPos, MyMenu)
{ ; V1toV2: Added bracket
Run("chrome.exe")
return
} ; V1toV2: Added Bracket before label

paint:
Run("mspaint.exe")
return

plus(A_ThisMenuItem, A_ThisMenuItemPos, MyMenu)
{ ; V1toV2: Added bracket
return
} ; V1toV2: Added bracket before function

calculadora(A_ThisMenuItem, A_ThisMenuItemPos, MyMenu)
{ ; V1toV2: Added bracket
Run("calc.exe")
return
} ; V1toV2: Added Bracket before label

notepad(A_ThisMenuItem, A_ThisMenuItemPos, MyMenu)
{ ; V1toV2: Added bracket
Run("notepad.exe")
return
} ; V1toV2: Added Bracket before hotkey or Hotstring

^q::
{ ; V1toV2: Added bracket
menu_principal.Show()
return
} ; V1toV2: Added bracket in the end



