#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;Author: Diarmuid OSullivan
;Date: 8th Sept 2023
;Description: Place text caret on a given character in editable text, similar to vim's go to charcter f key
;main use case: There is one typo and you want to teleport directly to that mistake to fix it

;-----------------------------
;   use guide
;-----------------------------

;Pressing and releasing Ctrl gives you a few seconds to type the character you want to search on
;It will go to the previous instance of this character (since usually a typo is behind your caret as you just typed it)
;After that you have a few seconds in search mode where the arrow keys will naviagate you to instances of the given letter forwards or backwards

;Test string - search on f - string has no h's
;Now I have to test this with some refal text f so I can be sure it's not fmessing things up

;-----------------------------
;   debugging stuff
;-----------------------------

;turn off F5 when finished testing

;KeyHistory

;ctrl and F5 to update to latest code changes
;^F5::Reload
;return

;Debug Message
;^q:: MsgBox % InStr("tet trings", "s",,-1)
;return

;Debug Message
;Ctrl:: MsgBox, Ctrl
;return

;-----------------------------
;    Backwards Search
;-----------------------------


Ctrl:: 

; Wait for 3 seconds for your input ;and break out on any special key pressed
Input, SearchChar, L1 T3, {LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{CapsLock}{NumLock}{PrintScreen}{Pause}

; Verify good input was received
if (ErrorLevel = "Timeout")
{
    ;MsgBox, No input received within 3 seconds.
    return
}
If InStr(ErrorLevel, "EndKey:")
{
    ;MsgBox, You entered "%SearchChar%" and terminated the input with %ErrorLevel%.
    ;it would be nice to not eat this input but preventing that seems hard and risky
    return
}


;keep users clipboard for safety
StoreInitialClipboard = %Clipboard%

; Define variables
HasWrapped := 0 ;can take values 0 or 2; 2 so we can reverse search direction (skiping the first character), or 0 so we presever base search behaviour
StoreOriginalLine := ""

;start the timer just once, we can restart it more later 
SetTimer, ManageClipboardAndReturn, -1500
SetTimer, ManageClipboardAndReturn, off

BackwardSearch:
;disable arrow keys briefly
Hotkey, Left, Disable
Hotkey, Right, Disable

Hotkey, Left, On
Hotkey, Right, On

;just do this once to preserve the line for safety
if (StoreOriginalLine = "")
{
    Send, +{End}
    Sleep, 10

    Send, ^c
    Sleep, 75

    tail := Clipboard
}

Send, +{Home}
Sleep, 10

Send, ^c
Sleep, 75

head := Clipboard

;this avoids the failure case when we are the start of a line, so the clipboard doesn't upadte
;but it adds a failure case when we are in the middle of two idential strings (but I will sacrifice this case as I don't know an easy way of checking if we are the start of a line)
if (head = tail)
{
   head := ""
}

if (StoreOriginalLine = "")
{
    ;MsgBox, wrote to StoreOriginalLine
    StoreOriginalLine := head tail
}


IsReverseSearch := -1 + HasWrapped ; -1 is base behaviour for backward search. neg so we find the last element -1 so we ignore the last character, has wrapped is 0 or 2

;looking at documentaion starting pos of 0 does search in reverse (from last to first)
position := InStr(head,SearchChar,,IsReverseSearch)


if (!position)
{
    ;MsgBox, Character '%characterToSearchFor%' not found in 'head'.

    ;return to normal state - get rid of blue
    Send, {Right}

    ;---
    ;- try to wrap - do reversed forward search
    ;---

    ;only try to wrap once, otherwise break (only if wrap succeeds we can reset HasWrapped to 0)
    if (HasWrapped = 0)
    {
	HasWrapped = 1 ;we want to reverse the search but not skip the final character of the tail
	Goto, ForwardSearch
    }

    Goto, ManageClipboardAndReturn
}

;succesfully found a character - can reset HasWrapped, doesn't matter if we did wrap or not
HasWrapped = 0

head1 := SubStr(head, 1, position)
head2 := SubStr(head, position + 1)

Send, {Del}
Sleep, 10

Send %head2%
Sleep, 50

Send, {Home}
Sleep, 10

Send %head1%
Sleep, 50

;-----------------------------
;    Arrow Search Loop
;-----------------------------

ArrowLoop:

;Debug Display
;MsgBox, Got to this point

;reenable arrow keys
Hotkey, Left, LeftAsSearch
Hotkey, Right, RightAsSearch

Hotkey, Left, On
Hotkey, Right, On

SetTimer, ManageClipboardAndReturn, on

;the Timer will deal with safetly ending the program so we can simply return now
return


;-----------------------------
;    Forwards Search
;-----------------------------


ForwardSearch:

;disable arrow keys briefly
Hotkey, Left, Disable
Hotkey, Right, Disable

Hotkey, Left, On
Hotkey, Right, On

Send, +{Home}
Sleep, 10

Send, ^x
Sleep, 75

head := Clipboard

Send, +{End}
Sleep, 10

Send, ^c
Sleep, 75

tail := Clipboard

;this avoids the failure case when we are the end of a line, so the clipboard doesn't upadte
if (head = tail)
{
   tail := ""
}

IsReverseSearch := 1 - HasWrapped ; 1 is base behaviour for forward search, finds the first element, has wrapped will flip to reverse search to 0 (not neg 1 as we don't want to skip the final character)

;looking at documentaion starting pos of 0 does search in reverse (from last to first)
position := InStr(tail,SearchChar,,IsReverseSearch)

if (!position)
{
    ;MsgBox, Character '%characterToSearchFor%' not found in 'tail'.

    ;return to normal state - get rid of blue, put back deleted head 
    if (tail != "") ;there is no blue as the head was everything so we deleted everything 
    {
       Send, {Left}
       Sleep, 10
    }
    Send, %head%

    ;---
    ;- try to wrap - do reversed backward search
    ;---

    ;only try to wrap once, otherwise break (only if wrap succeeds we can reset HasWrapped to 0)
    if (HasWrapped = 0)
    {
	HasWrapped = 2
	Goto, BackwardSearch
    }

    Goto, ManageClipboardAndReturn
}

;succesfully found a character - can reset HasWrapped, doesn't matter if we did wrap or not
HasWrapped = 0

tail1 := SubStr(tail, 1, position)
tail2 := SubStr(tail, position + 1)

Send, {Del}
Sleep, 10

Send %tail2%
Sleep, 50

Send, {Home}
Sleep, 10

Send %head%
Send %tail1%
Sleep, 50

Goto, ArrowLoop


;-----------------------------
;  Manage Clipboard and Exit
;-----------------------------

ManageClipboardAndReturn:

; Debug Display
;MsgBox, StoreInitialClipboard %StoreInitialClipboard%
;MsgBox, StoreOriginalLine %StoreOriginalLine%

;reenable arrow keys (just for safety)
Hotkey, Left, Off
Hotkey, Right, Off

;note deleting is safe even if file doesn't exist yet
FileDelete, C:\Users\Diarmuid.Osullivan\Documents\MyCoding\AHKScripts\Notes on developing SeakCharacter\StoreOriginalLine.txt
FileAppend, %StoreOriginalLine%, C:\Users\Diarmuid.Osullivan\Documents\MyCoding\AHKScripts\Notes on developing SeakCharacter\StoreOriginalLine.txt

clipboard = %StoreInitialClipboard%

return

;--------------------------
;labels for setting hotkeys
;--------------------------

Disable:
return

LeftAsSearch:
;This will restart the timer so we get another 3 seconds to act again
SetTimer, ManageClipboardAndReturn, On
Goto, BackwardSearch
return

RightAsSearch:
SetTimer, ManageClipboardAndReturn, On
Goto, ForwardSearch
return