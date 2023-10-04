#SingleInstance
CoordMode "Pixel"

^q::
{
	ImageSearch(&FoundX, &FoundY,0, 0, 1366, 786, "C:\Users\bashy\Documents\projeto-hotkey_v1\img\mesa5.png")

	Click FoundX , FoundY
	MsgBox FoundX . "-" . FoundY
}





