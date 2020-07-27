
; Map Ctrl+Shift+P to Play/Pause
^+P::
Send {Media_Play_Pause}
return

; Clipboard Auto-Typer
; Press Win+Ctrl+v to auto-type the contents of your clipboard
; https://softwarerecs.stackexchange.com/questions/46987/autotype-windows-clipboard-contents-password-into-webpage-that-blocks-paste/46988#46988

SendMode Input    
^#v::
    SendInput, {Raw}%ClipBoard%
Return