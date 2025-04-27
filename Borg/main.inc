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

includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\comctl32.lib
includelib \masm32\lib\shell32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\advapi32.lib

.const
	IDI_ICON1 dd 1000

    ClassName db "Borg", NULL
    AppName db "Borg", NULL
    AppNameUp db "Borg Commander", NULL
    StaticClass db "static", NULL
    EditClass db "edit", NULL
    TheGame db "ACCESS DENIED!", NULL
    
    ;Control Ints
    TIMER_ID dw 100h
    STATIC_ID dw 101h
    EDIT_ID dw 102h
    ACCEL_ID1 dw 103h
    ACCEL_ID2 dw 104h
    ACCEL_ID3 dw 105h
    ACCEL_ID4 dw 106h
    STIMER_ID dw 107h
    ACCEL_ID5 dw 108h
    
    TIMER_MS dd 1500
    PTIMER_MS dd 1000
    BORG_MAX dd 25
    BORG_MAX_RT dd 5
    
    ;Message Strings
    borgTerminate db "borgTerminate", NULL
    borgQuery db "borgQuery", NULL
    borgPresent db "borgPresent", NULL
    borgMoved db "borgMoved", NULL
    borgGame db "borgGame", NULL
    borgCIsW db "borgCIsW", NULL
    borgCIsI db "borgCIsI", NULL
    
    pass db "aac80387c5d3aec0d2022195d053d7d4", NULL
    passCl db "Password?", NULL
	
.data
	WND_WIDTH dd 200
	WND_HEIGHT dd 150
	wc WNDCLASSEX <>
	stin STARTUPINFO <>
	prin PROCESS_INFORMATION <>
	
	pstin dd stin
	pprin dd prin
	moveWindowID dd NULL
	TIMER_RAN dd NULL
    BSM_REC dd BSM_APPLICATIONS
    PBSM dd BSM_REC
    gamed db FALSE
    editProc dd NULL
    passBuff db 20 dup (NULL)
    sTran db 0FFh
    
    ;Accel
    accel1 ACCEL <>
    accel2 ACCEL <>
    accel3 ACCEL <>
    accel4 ACCEL <>
    accel5 ACCEL <>
    accelFlags db NULL
    
    hAccelTable dd NULL
	
	;Borg Variables
	borgPresence dd NULL
	borgCommander db NULL
	borgMove db TRUE
	borgMoveAll db NULL
	borgMoveTemp db NULL
	
	;Message Ints
	BORG_TERM dd NULL
	BORG_QUER dd NULL
	BORG_PRES dd NULL
	BORG_MOVD dd NULL
	BORG_GAME dd NULL
	BORG_CISW dd NULL
	BORG_CISI dd NULL
	
	;Hash Variables
	bHashStr db 33 dup (NULL)
	
	;Memory Map
	hMapFile dd NULL
	szName db "BorgMap", NULL
	cbMap dd 20
	pbMap dd NULL