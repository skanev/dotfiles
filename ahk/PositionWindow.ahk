title := A_Args[1]
x := A_Args[2]
y := A_Args[3]
w := A_Args[4]
h := A_Args[5]

WinGet, windows, List, %title%
Loop, %windows%
{
  id := windows%A_Index%
  WinGetTitle wt, ahk_id %id%
  WinMove, ahk_id %id%, , %x%, %y%, %w%, %h%
}
