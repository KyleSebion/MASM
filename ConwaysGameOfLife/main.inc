.386
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

includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\comctl32.lib
includelib \masm32\lib\shell32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\advapi32.lib
includelib \masm32\lib\ws2_32.lib
includelib \masm32\lib\comdlg32.lib

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

errorBox macro
		push NULL
		push NULL
		push NULL
		push NULL
	call MessageBox
endm
errorBox2 macro
		push 2
		push NULL
		push NULL
		push NULL
	call MessageBox
endm

.const
	IDI_ICON1 equ 1000
    ClassName db "Life", NULL
    AppName db "Life", NULL
    Static db "static", NULL
    Edit db "edit", NULL
    Button db "button", NULL
    gridPadding dd 10
    initWidth equ 16
    initHeight equ 16
    
	;text
	    sStart db "Start", NULL
	    sStop db "Stop", NULL
	    sSettings db "Settings", NULL
		    
	;IDs
		timerID equ 101
		menuID equ 1000
			fileID equ 1001
				exitID equ 1002
			startID equ 1003
			stopID equ 1004
			nextID equ 1005
		toolsID equ 1006
			clearID equ 1007
			fillID equ 1008
			settingsID equ 1009
    
.data
	WND_WIDTH dd 1000
	WND_HEIGHT dd 1000
	
	numThreads equ 2
	pGridThread dd NULL
	
	pGrid dd NULL
	gridWidth dd NULL
	gridHeight dd NULL
	gridSize dd NULL
    gridCellSize dd 10
    hdcBack dd NULL
    hdcBitmap dd NULL
    timerDelay dd 100
    timerOn db NULL
    
    aliveColor dd 00FF0000h
    deadColor dd 00000000h
    gridColor dd 00000000h
    backColor dd 00800000h
    
    s db 3, 4, 0, 0, 0, 0, 0, 0, 0, 0
    b db 4, 0, 0, 0, 0, 0, 0, 0, 0, 0