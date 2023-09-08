# SeakCharacter-AutoHotKey
Go to specified character in a line of editable text, with line wrapping and directional search


**Author:** Diarmuid O'Sullivan
**Date:** 8th Sept 2023
**Description:** Place text caret on a given character in editable text, similar to vim's go to character 'f' key.
**Main Use Case:** There is one typo, and you want to teleport directly to that mistake to fix it.

---

### Usage Guide

- Pressing and releasing Ctrl gives you a few seconds to type the character you want to search for.
- It will go to the previous instance of this character (since usually a typo is behind your caret as you just typed it).
- After that, you have a few seconds in search mode where the arrow keys will navigate you to instances of the given letter forwards or backwards.

---

**Test string** - search on 'f' - the string has no 'h's.

Now I have to test this with some refal text 'f' so I can be sure it's not messing things up.
