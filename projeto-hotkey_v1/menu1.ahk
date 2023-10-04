#SingleInstance

menu_principal := Menu()
menu_principal.Add("Calculadora", calculadora)
menu_principal.Add("Bloco de notas", notepad)
menu_principal.add("mais", plus)
menu_principal.add("Cores", plus)


; Adiciona os Icones do Menu Principal.
;menu_principal.Icon("Calculadora", "img\cal.icon")
menu_principal.SetIcon("Calculadora","Imagens\cal.ico")
menu_principal.SetIcon("Bloco de notas", "img\calculadora.png",1,32)



;-----------------------
Submenu1 := Menu()
Submenu1.Add("Google", google)
Submenu1.Add("Paint", paint)
;-------------------
menu_principal.add("mais",submenu1)
menu_principal.add("mais",submenu1)
;-----------------------
Submenu2 := Menu()
submenu2.add("Red",red)
submenu2.add("Blue",blue)
menu_principal.add("Cores",submenu2)
menu_principal.add("Cores",submenu2)





return

red(A_ThisMenuItem, A_ThisMenuItemPos, menu_principal)
{
	Run("calc.exe")
	return
}
blue(A_ThisMenuItem, A_ThisMenuItemPos, menu_principal)
{
	Run("calc.exe")
	return
}
calculadora(A_ThisMenuItem, A_ThisMenuItemPos, menu_principal )
{
Run("calc.exe")
return
}
paint(A_ThisMenuItem, A_ThisMenuItemPos, menu_principal )
{
	Run("mspaint.exe")
	return
}

notepad(A_ThisMenuItem, A_ThisMenuItemPos, menu_principal )
{
Run("notepad.exe")
return
}
google(A_ThisMenuItem, A_ThisMenuItemPos, menu_principal)
{
	Run("calc.exe")
	return
}

plus(A_ThisMenuItem, A_ThisMenuItemPos, menu_principal){
	return
}


^q::
{
menu_principal.Show()
return
}


