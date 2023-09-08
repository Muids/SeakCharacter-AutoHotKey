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

; Wait for 4 seconds for your input ;and break out on any special key pressed
Input, SearchChar, L1 T3, {LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{CapsLock}{NumLock}{PrintScreen}{Pause}

; Verify good input was received
if (ErrorLevel = "Timeout")
{
    ;MsgBox, No input received within 4 seconds.
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

BackwardSearch:

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

if (StoreOriginalLine = "")
{
    ;MsgBox, wrote to StoreOriginalLine
    StoreOriginalLine := head tail
}


IsReverseSearch := -1 + HasWrapped ; -1 is base behaviour for backward search. neg so we find the last element -1 so we ignore the last character, has wrapped is 0 or 2

;debug
;MsgBox, Backward Search... HasWrapped: %HasWrapped% ... IsReverseSearch: %IsReverseSearch%
;if ( HasWrapped = 2)
;{
;    MsgBox, head %head%
;    MsgBox % InStr(head,SearchChar,,IsReverseSearch)
;}

;looking at documentaion starting pos of 0 does search in reverse (from last to first)
position := InStr(head,SearchChar,,IsReverseSearch)

;if (position)
;{
;    MsgBox, Character '%characterToSearchFor%' found at position %position% in 'head'.
;}
;else
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
	HasWrapped = 2
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

Send, {Home}
Sleep, 10

Send %head1%

;-----------------------------
;    Arrow Search Loop
;-----------------------------

ArrowLoop:

Input, CaughtInput, L1 T3,{LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{CapsLock}{NumLock}{PrintScreen}{Pause}

; Check if any input was received

if (ErrorLevel = "Timeout")
{
    ;MsgBox, No input received within 4 seconds.
    Goto, ManageClipboardAndReturn
}
if (ErrorLevel = "EndKey:Left")
{
    ;MsgBox, Error %ErrorLevel%
    Goto, BackwardSearch
}
if (ErrorLevel = "EndKey:Right")
{
    ;MsgBox, Error %ErrorLevel%
    Goto, ForwardSearch
}

; Debug Display
;MsgBox, No Match %Direction%

; Debug Display
;MsgBox, %head1%

; Debug Display
;MsgBox, head 2 %head2%


;Don't eat the input if it's not an arrow key ;note we don't get here if there is a timeout so there shouldn't be a risk of it being empty
Send, %CaughtInput%

Goto, ManageClipboardAndReturn


;-----------------------------
;    Forwards Search
;-----------------------------


ForwardSearch:

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

IsReverseSearch := 1 - HasWrapped ; 1 is base behaviour for forward search, finds the first element, has wrapped will flip to reverse search negative 1

;looking at documentaion starting pos of 0 does search in reverse (from last to first)
position := InStr(tail,SearchChar,,IsReverseSearch)

;if (position)
;{
;    MsgBox, Character '%characterToSearchFor%' found at position %position% in 'tail'.
;}
;else
if (!position)
{
    ;MsgBox, Character '%characterToSearchFor%' not found in 'tail'.

    ;return to normal state - get rid of blue, put back deleted head 
    Send, {Left}
    Sleep, 10
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

Goto, ArrowLoop

Goto, ManageClipboardAndReturn



;-----------------------------
;  Manage Clipboard and Exit
;-----------------------------

ManageClipboardAndReturn:

; Debug Display
MsgBox, StoreInitialClipboard %StoreInitialClipboard%
MsgBox, StoreOriginalLine %StoreOriginalLine%

;note deleting is safe even if file doesn't exist yet
FileDelete, C:\Users\Diarmuid.Osullivan\Documents\MyCoding\AHKScripts\Notes on developing SeakCharacter\StoreOriginalLine.txt
FileAppend, %StoreOriginalLine% , C:\Users\Diarmuid.Osullivan\Documents\MyCoding\AHKScripts\Notes on developing SeakCharacter\StoreOriginalLine.txt

clipboard = %StoreInitialClipboard%

return