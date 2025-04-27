.486p
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\comctl32.inc
include \masm32\include\shell32.inc
include \masm32\include\gdi32.inc
include \masm32\include\advapi32.inc
include \masm32\include\ws2_32.inc
include \masm32\include\comdlg32.inc
include \masm32\include\msimg32.inc
include \masm32\include\winmm.inc

includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\comctl32.lib
includelib \masm32\lib\shell32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\advapi32.lib
includelib \masm32\lib\ws2_32.lib
includelib \masm32\lib\comdlg32.lib
includelib \masm32\lib\msimg32.lib
includelib \masm32\lib\winmm.lib

;Start Dynamic Memory Macros
new macro type:req
		push sizeof type
		push HEAP_ZERO_MEMORY
			call GetProcessHeap
		push eax
    call HeapAlloc
endm
malloc macro size:req
		push size
		push HEAP_ZERO_MEMORY
			call GetProcessHeap
		push eax
    call HeapAlloc
endm
salloc macro size:req, retreg
	local retr
	ifndef retreg
		retr equ eax
	else
		retr equ retreg
	endif
	sub esp, size
	mov retr, esp
endm
free macro address:req
		push address
		push HEAP_ZERO_MEMORY
			call GetProcessHeap
		push eax
	call HeapFree
	mov address, NULL
endm
delete macro address:req
	free address
endm
sfree macro size:req
	add esp, size
endm
;End Dynamic Memory Macros

paddr macro item:req, reg
	local regi
	ifndef reg
		regi equ eax
	else
		regi equ reg
	endif
	lea regi, item
	push regi
endm
maddr macro item1:req, item2:req, reg
	local regi
	ifndef reg
		regi equ eax
	else
		regi equ reg
	endif
	lea regi, item2
	mov item1, regi
endm

movm macro dest:req, src:req
	push src
	pop dest
endm

DEF_WC_TREEVIEW macro
	ifndef WC_TREEVIEW
		.const
		WC_TREEVIEW db "SysTreeView32", NULL
		.code
	endif
endm
DEF_WC_LISTVIEW macro
	ifndef WC_LISTVIEW
		.const
		WC_LISTVIEW db "SysListView32", NULL
		.code
	endif
endm
DEF_WC_STATIC macro
	ifndef WC_STATIC
		.const
		WC_STATIC db "static", NULL
		.code
	endif
endm
DEF_WC_EDIT macro
	ifndef WC_EDIT
		.const
		WC_EDIT db "edit", NULL
		.code
	endif
endm
DEF_WC_BUTTON macro
	ifndef WC_BUTTON
		.const
		WC_BUTTON db "button", NULL
		.code
	endif
endm
DEF macro var:req, string:vararg
	ifndef var
		.const
				var db string, NULL
		.code
	endif
endm

errorBox macro
		push MB_OK
		push NULL
		push NULL
		push NULL
	call MessageBox
endm

.const
	IDI_ICON1 equ 1000
	WND_WIDTH equ 80
	WND_HEIGHT equ 80
	nl equ 0dh, 0ah
	padding equ 5
	timerID equ 101
    timerDelay dd 20
		    
	;IDs
		;Bitmaps
			NAVI_FRAME_0 equ 2000
		;Sounds
			HEY_LISTEN_SOUND equ 3000
		;Hotkeys
			CLOSE_HK equ 4000

.data
	hhookm dd NULL
	hhookk dd NULL
	hbitmap dd NULL
	point POINT <>
	hotkeyFlags db NULL
	