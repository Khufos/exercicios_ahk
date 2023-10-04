^q::{
Url := "https://the-internet.herokuapp.com/login"
ie := ComObject("InternetExplorer.Application")
ie.Visible := true  ; This is known to work incorrectly on IE7.
ie.Navigate(Url)
Username := "tomo"
Password := 1234123
while ie.busy
{
Sleep 500
}
Sleep(1000)
username_input := ie.document.getElementbyID("username")
password_input := ie.document.getElementbyID("password")
username_input.value := Username
password_input.value := Password
Sleep(1000)
botao_click := ie.document.getElementbyID("login").submit()

return
}