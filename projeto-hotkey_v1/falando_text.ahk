#SingleInstance
^q::
{
MsgBox Path := EnvGet("PATH")
SoundPlay("C:\Users\iago.abreu\Documents\project_ahk\projeto-hotkey_v1\Media\rock.mp3")
return
}
^e::
{

oVoice := ComObject("SAPI.SpVoice")	; or use TTS_CreateVoice()
oVoice.Speak("Testando",0x0)	; or use TTS()
oVoice := ""
return

}
