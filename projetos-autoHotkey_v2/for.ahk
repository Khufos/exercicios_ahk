

^q::
{

	arr:=[]

	Loop read "C:\Users\bashy\Documents\projetos-autoHotkey\data.txt"
	arr.Push(A_LoopReadLine)

	for index, element in arr
		MsgBox index . "-" . element
	return
}

