#SingleInstance


^q::
{
letra:=1
	if(letra =1)
	{
	 Send("a")
	 letra++
	}

else if(letra = 2)
{
	Send("b")
	letra++
}

else
{
 Send("c")
 letra++
}
return
}