#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;testing, turn off F5 when finished testing

;KeyHistory

^F5::Reload
return

;LControl & Ralt::
;MsgBox, LControl & Ralt

;RControl & Ralt::
;MsgBox, RControl & Ralt

;^!+:: MsgBox, Hellos
;Ralt & LShift:: MsgBox, Ralt & LShift
;return

;Ralt & RShift:: MsgBox, Ralt & RShift
;return


;Ralt:: MsgBox, Ralt
;return

;-----------------------------
;    Backwards Search
;-----------------------------


;LControl & Ralt is alt gr ... this hideous thing <^>! doesn't work for me

+Home:: 
; Define a variable to store the input
SearchChar := ""

; Wait for 4 seconds for your input
Input, UserInput, L1 T4

; Check if any input was received

if (ErrorLevel = "Timeout")
{
    ;MsgBox, No input received within 4 seconds.
    return
}

; Store the input in the variable
SearchChar := UserInput

;don't include the current character (so we can use the command iteratively)
Send, {Left}
Sleep, 10

Send, +{Home}
Sleep, 33

Send, ^c
Sleep, 33

head := Clipboard

;looking at documentaion starting pos of 0 does search in reverse (from last to first)
position := InStr(head,SearchChar,,0)

;if (position)
;{
;    MsgBox, Character '%characterToSearchFor%' found at position %position% in 'head'.
;}
;else
if (!position)
{
    ;MsgBox, Character '%characterToSearchFor%' not found in 'head'.

    ;return to normal state - get rid of blue and move cursor back
    Send, {Right 2}
    return
}

head1 := SubStr(head, 1, position)
head2 := SubStr(head, position + 1)

Send, {Del}
Sleep, 10

Send %head2%

Send, {Home}
Sleep, 10

Send %head1%

; Debug Display
;MsgBox, %head1%

; Debug Display
;MsgBox, head 2 %head2%

return


;-----------------------------
;    Forwards Search
;-----------------------------


;shift and alt gr  -- 

+End::
; Define a variable to store the input
SearchChar := ""

; Wait for 4 seconds for your input
Input, UserInput, L1 T4

; Check if any input was received

if (ErrorLevel = "Timeout")
{
    ;MsgBox, No input received within 4 seconds.
    return
}

; Store the input in the variable
SearchChar := UserInput

;don't include the current character (so we can use the command iteratively)
Send, {Right}
Sleep, 10

Send, +{Home}
Sleep, 33

Send, ^x
Sleep, 33

head := Clipboard

Send, +{End}
Sleep, 33

Send, ^c
Sleep, 33

tail := Clipboard

;looking at documentaion starting pos of 0 does search in reverse (from last to first)
position := InStr(tail,SearchChar)

;if (position)
;{
;    MsgBox, Character '%characterToSearchFor%' found at position %position% in 'tail'.
;}
;else
if (!position)
{
    ;MsgBox, Character '%characterToSearchFor%' not found in 'tail'.

    ;return to normal state - get rid of blue and move cursor back
    Send, {Left}
    Sleep, 10
    Send, %head%
    Sleep, 50
    Send, {Left}
    return
}

tail1 := SubStr(tail, 1, position)
tail2 := SubStr(tail, position + 1)

Send, {Del}
Sleep, 10

Send %tail2%

Send, {Home}
Sleep, 10

Send %head%
Send %tail1%

; Debug Display
;MsgBox, head %head%

; Debug Display
;MsgBox, tail 1 %tail1%

; Debug Display
;MsgBox, tail 2 %tail2%

return