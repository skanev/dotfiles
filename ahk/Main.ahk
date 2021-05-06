#NoEnv                      ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn                       ; Enable warnings to assist with detecting common errors.
#SingleInstance Force       ;
SendMode Input              ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

; Define a few groups to refer to later

GroupAdd, browsers, ahk_exe msedge.exe
GroupAdd, browsers, ahk_exe firefox.exe
GroupAdd, browsers, ahk_exe chrome.exe

GroupAdd, untouched, ahk_exe WindowsTerminal.exe
GroupAdd, untouched, ahk_exe X410.exe
GroupAdd, untouched, ahk_exe FVim.exe
GroupAdd, untouched, ahk_exe neovide.exe

GroupAdd, slack, ahk_exe slack.exe

Capslock::Control
!Space::Send {Alt down}{Shift down}{Shift up}{Alt up}

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

#If WinActive("ahk_group slack")

!k::Send ^k

#if

#If ! WinActive("ahk_group untouched")

!c::Send ^c
!v::Send ^v
!w::Send ^w
!z::Send ^z
!a::Send ^a

#if
