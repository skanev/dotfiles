#NoEnv                      ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn                       ; Enable warnings to assist with detecting common errors.
#SingleInstance Force       ;
SendMode Input              ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

; Change between input langauges

ToggleInputLanguage()
{
    WinExist("A")

    ControlGetFocus, CtrlInFocus
    PostMessage, 0x50, 2,, %CtrlInFocus%
}

; Position windows in the locations I like them to be positioned

PositionWindow(where)
{
    WinExist("A")

    ; I don't understand why the magical constants here work exactly, but I
    ; tweaked them until they looked good
    height := (A_ScreenHeight-64)
    extra_width := 20
    half_width := (A_ScreenWidth/2)+extra_width
    full_width := A_ScreenWidth+extra_width

    leftmost := -10
    midway := half_width - 30

    if (where == "left")
    {
        WinMove,A,,leftmost,1,half_width,height
    }
    else if (where == "right")
    {
        WinMove,A,,midway,0,half_width,height
    }
    else if (where == "full")
    {
        WinMove,A,,leftmost,0,full_width,height
    }
    else if (where == "center")
    {
        WinMove,A,,leftmost + full_width * 0.1,height * 0.1,full_width * 0.8,height * 0.8
    }
}

; Define a few groups to refer to later

GroupAdd, browsers, ahk_exe msedge.exe
GroupAdd, browsers, ahk_exe firefox.exe
GroupAdd, browsers, ahk_exe chrome.exe

GroupAdd, untouched, ahk_exe WindowsTerminal.exe
GroupAdd, untouched, ahk_exe X410.exe
GroupAdd, untouched, ahk_exe FVim.exe
GroupAdd, untouched, ahk_exe neovide.exe

GroupAdd, chats, ahk_exe slack.exe
GroupAdd, chats, ahk_exe Discord.exe

!^+q::PositionWindow("left")
!^+w::PositionWindow("right")
!^+a::PositionWindow("full")
!^+s::PositionWindow("center")

Capslock::Control
!Space::ToggleInputLanguage()

#!.::Reload
#!,::Edit

:*:skgc::stefan.kanev@gmail.com

#If WinActive("ahk_group browsers")

!1::Send ^1
!2::Send ^2
!3::Send ^3
!4::Send ^4
!5::Send ^5
!6::Send ^6
!7::Send ^7
!8::Send ^8
!9::Send ^9

!w::Send ^w
!l::Send ^l
!f::Send ^f
!t::Send ^t
!r::Send ^r

#if

#If WinActive("ahk_group chats")

!k::Send ^k

#if

#If ! WinActive("ahk_group untouched")

!c::Send ^c
!v::Send ^v
!w::Send ^w
!z::Send ^z
!a::Send ^a

#if
