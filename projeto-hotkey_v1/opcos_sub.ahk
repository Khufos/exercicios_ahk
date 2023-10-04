#SingleInstance Force

; Adiciona o Menu Principal e seus Itens.
principal := Menu()
principal.Add("Calculadora", calculadora)
principal.Add("Bloco de notas", notepad)
principal.Add("Mais", plus)

; Adiciona o Menu Secundário e seus Itens.
secundario := Menu()
secundario.Add("Google", google)
secundario.Add("Paint", paint)

; Adiciona o Menu Secundário e seus Itens
principal.Add("Mais", secundario)

; Adiciona os Icones do Menu Principal.
principal.Icon("Calculadora", "Imagens\calculadora.ico")
;principal.Icon("Bloco de notas", "Imagens\notepad.ico")

; Adiciona os Icones do Menu Secundário.
principal.Icon("Mais", "Imagens\plus.ico")
secundario.Icon("Paint", "Imagens\paint.ico")
secundario.Icon("Google", "Imagens\google.ico")

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
} ; V1toV2: Added Bracket before label

paint(A_ThisMenuItem, A_ThisMenuItemPos, MyMenu)
{ ; V1toV2: Added bracket
Run("mspaint")
return
} ; V1toV2: Added bracket before function

google(A_ThisMenuItem, A_ThisMenuItemPos, MyMenu)
{ ; V1toV2: Added bracket
Run("chrome.exe")
return
} ; V1toV2: Added Bracket before hotkey or Hotstring

MButton::
{ ; V1toV2: Added bracket
principal.Show()
return
} ; V1toV2: Added bracket in the end

