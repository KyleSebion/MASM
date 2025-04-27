include main.inc
	
.code
start:
    call InitCommonControls
		push NULL
    call GetModuleHandle
    	push eax
	call WinMain_wc
	call WinMain_msgLoop
    	push eax
    call ExitProcess
WinMain_wc proc hinst:DWORD
	local wc:WNDCLASSEX
	DEF ClassName, "NaviKSEB"
	DEF AppName, "Navi"

	    	push byte ptr NULL
		    push sizeof WNDCLASSEX
			paddr wc
		call MemoryFill
    		push IDC_ARROW
    		push NULL
    	call LoadCursor
	    mov wc.hCursor, eax
    		push IDI_ICON1
    		push hinst
    	call LoadIcon
	    mov wc.hIcon, eax
	    mov wc.hIconSm, eax
	    		push BLACK_BRUSH
	    	call GetStockObject
	    mov wc.hbrBackground, eax
	    movm wc.hInstance, hinst
	    mov wc.cbSize, SIZEOF WNDCLASSEX
	    mov wc.style, CS_HREDRAW or CS_VREDRAW or CS_DBLCLKS
	    maddr wc.lpfnWndProc, WndProc
	    mov wc.cbClsExtra, NULL
	    mov wc.cbWndExtra, NULL
	    mov wc.lpszMenuName, NULL
	    maddr wc.lpszClassName, ClassName
	    	paddr wc
	    call RegisterClassEx
			push NULL
			push hinst
			push NULL
			push NULL
			push WND_HEIGHT
			push WND_WIDTH
			push CW_USEDEFAULT
			push CW_USEDEFAULT
			push WS_POPUP
			paddr AppName
			paddr ClassName
			push WS_EX_LAYERED or WS_EX_TRANSPARENT or WS_EX_TOOLWINDOW or WS_EX_TOPMOST
		call CreateWindowEx

	ret
WinMain_wc endp
WinMain_msgLoop proc
	local pmsg:DWORD

	    new MSG
	    mov pmsg, eax
		@@:
				push NULL
				push NULL
				push NULL
				push pmsg
	        call GetMessage
	        
	        test eax, eax
	        jz @F
			
				push pmsg
	        call TranslateMessage
	        
				push pmsg
	        call DispatchMessage
	        	
	        jmp @B
	    @@:
	    mov eax, pmsg
	    push (MSG ptr [eax]).wParam
	    free pmsg
	    			push NULL
	    		call GetModuleHandle
	    	push eax
	    	paddr ClassName
	    call UnregisterClass
		pop eax
		
	ret
WinMain_msgLoop endp
WndProc proc hwnd:DWORD, msg:DWORD, wp:DWORD, lp:DWORD
	
	
		cmp msg, WM_CREATE
		je case_WM_CREATE
		
		cmp msg, WM_DESTROY
		je case_WM_DESTROY
		
		cmp msg, WM_PAINT
		je case_WM_PAINT
	
		cmp msg, WM_HOTKEY
		je case_WM_HOTKEY
		
		cmp msg, WM_QUERYENDSESSION
		je case_WM_QUERYENDSESSION
		
;		cmp msg, WM_
;		je case_WM_
		
		jmp case_default
	
		case_WM_CREATE:
				push hwnd
			call WM_CREATE_Hotkey
				push hwnd
			call WM_CREATE_Load
				push hwnd
			call WM_CREATE_Timer
			call WM_CREATE_Hook
				push hwnd
			call WM_CREATE_ShowUpdateWindow
		jmp case_end_msg
	    
	    case_WM_DESTROY:
	    		push hwnd
	    	call WM_DESTROY_
	    jmp case_end_msg
	    
	    case_WM_PAINT:
	    		push hwnd
	    	call WM_PAINT_
	    jmp case_end_msg
	    
	    case_WM_HOTKEY:
	    		push lp
	    		push wp
	    		push hwnd
	    	call WM_HOTKEY_
	    jmp case_end_msg
	    
	    case_WM_QUERYENDSESSION:
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
	    case_end_msg2:
	    
    ret
WndProc endp
WM_CREATE_Hotkey proc hwnd:DWORD
			
			push VK_C
			push MOD_ALT or MOD_CONTROL or MOD_SHIFT
			push CLOSE_HK
			push hwnd
		call RegisterHotKey
		
	ret
WM_CREATE_Hotkey endp
WM_CREATE_Load proc hwnd:DWORD
				
			push NAVI_FRAME_0
				push NULL
			call GetModuleHandle
			push eax
		call LoadBitmap
		mov hbitmap, eax

	ret
WM_CREATE_Load endp
WM_CREATE_Timer proc hwnd:DWORD

    		paddr WM_TIMER_
    		push timerDelay
    		push timerID
    		push hwnd
    	call SetTimer
    	
	ret
WM_CREATE_Timer endp
WM_CREATE_Hook proc
		
			push NULL
					push NULL
				call GetModuleHandle
			push eax
			paddr MouseHook
			push WH_MOUSE_LL
		call SetWindowsHookEx
		mov hhookm, eax
		
			push NULL
					push NULL
				call GetModuleHandle
			push eax
			paddr KeyboardHook
			push WH_KEYBOARD_LL
		call SetWindowsHookEx
		mov hhookk, eax
		
	ret
WM_CREATE_Hook endp
WM_CREATE_ShowUpdateWindow proc hwnd:DWORD
	local pt:POINT
	
			push LWA_ALPHA or LWA_COLORKEY
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
			paddr pt
		call GetCursorPos
		
		movm point.x, pt.x
		movm point.y, pt.y
		
			push SWP_NOSIZE
			push NULL
			push NULL
			push pt.y
				add dword ptr [esp], 10
			push pt.x
				add dword ptr [esp], 10
			push HWND_TOPMOST
			push hwnd
		call SetWindowPos
			push SW_SHOWNORMAL
			push hwnd
	    call ShowWindow
	    	push hwnd
	    call UpdateWindow
	    
   	
	ret
WM_CREATE_ShowUpdateWindow endp
WM_DESTROY_ proc hwnd:DWORD
		
			push CLOSE_HK
			push hwnd
		call UnregisterHotKey
    		push timerID
    		push hwnd
    	call KillTimer
			push hbitmap
		call DeleteObject
			push hhookk
		call UnhookWindowsHookEx
			push hhookm
		call UnhookWindowsHookEx
    		push NULL
    	call PostQuitMessage

	ret
WM_DESTROY_ endp
WM_PAINT_ proc hwnd:DWORD
	local ps:PAINTSTRUCT
	local hdc:DWORD, hdcm:DWORD, hbit:DWORD
	local rect:RECT
			
			paddr rect
			push hwnd
		call GetClientRect
	
			paddr ps
			push hwnd
		call BeginPaint
		mov hdc, eax
			
			push hdc
		call CreateCompatibleDC
		mov hdcm, eax
		
			push hbitmap
			push hdcm
		call SelectObject
		mov hbit, eax
			
			push SRCCOPY
			push 160
			push 160
			push NULL
			push NULL
			push hdcm
			push rect.bottom
			push rect.right
			push NULL
			push NULL
			push hdc
		call StretchBlt
		
			paddr ps
			push hwnd
		call EndPaint
			
			push hbit
			push hdcm
		call SelectObject
		
			push hdcm
		call DeleteDC
		
	ret
WM_PAINT_ endp
WM_HOTKEY_ proc hwnd:DWORD, wp:DWORD, lp:DWORD

			push NULL
			push NULL
			push WM_CLOSE
			push hwnd
		call SendMessage
		
	ret
WM_HOTKEY_ endp
KeyboardHook proc code:DWORD, wp:DWORD, lp:DWORD

		mov eax, wp
		
		cmp eax, WM_SYSKEYDOWN
		je case_WM_SYSKEYDOWN
		
		cmp eax, WM_SYSKEYUP
		je case_WM_SYSKEYUP
		
		cmp eax, WM_KEYDOWN
		je case_WM_KEYDOWN
		
		cmp eax, WM_KEYUP
		je case_WM_KEYUP
		
		jmp case_default
		
		case_WM_SYSKEYDOWN:
;			mov eax, lp
;			mov eax, dword ptr [eax]
;			cmp eax, VK_F4
;			je case_process
		jmp case_default
		
		case_WM_SYSKEYUP:
		jmp case_default
		
		case_WM_KEYDOWN:
			mov eax, lp
			mov eax, dword ptr [eax]
			cmp eax, VK_RCONTROL
			je case_process
			cmp eax, VK_RMENU
			je case_process
			cmp eax, VK_LSHIFT
			je case_process
			cmp eax, VK_C
			je case_process
		jmp case_default
		
		case_WM_KEYUP:
			mov eax, lp
			mov eax, dword ptr [eax]
			cmp eax, VK_RCONTROL
			je case_process
			cmp eax, VK_RMENU
			je case_process
			cmp eax, VK_LSHIFT
			je case_process
			cmp eax, VK_C
			je case_process
		jmp case_default
		
		case_default:
			mov eax, -1
			jmp @F
		case_process:
				push lp
				push wp
				push code
				push hhookk
			call CallNextHookEx
		@@:
	ret
KeyboardHook endp
MouseHook proc code:DWORD, wp:DWORD, lp:DWORD

		mov eax, wp
		
		cmp eax, WM_LBUTTONDOWN
		je case_WM_LBUTTONDOWN
		
		cmp eax, WM_LBUTTONUP
		je case_WM_LBUTTONUP
		
		cmp eax, WM_RBUTTONDOWN
		je case_WM_RBUTTONDOWN
		
		cmp eax, WM_RBUTTONUP
		je case_WM_RBUTTONUP
		
		cmp eax, WM_MOUSEMOVE
		je case_WM_MOUSEMOVE
		
		jmp case_default
		
		case_WM_LBUTTONDOWN:
				push SND_RESOURCE or SND_ASYNC; or SND_NOSTOP
						push NULL
					call GetModuleHandle
				push eax
				push HEY_LISTEN_SOUND
			call PlaySound
		jmp case_default
		
		case_WM_LBUTTONUP:
		jmp case_default
		
		case_WM_RBUTTONDOWN:
		jmp case_default
		
		case_WM_RBUTTONUP:
		jmp case_default
		
		case_WM_MOUSEMOVE:
			mov eax, lp
			movm point.x, (MOUSEHOOKSTRUCT ptr [eax]).pt.x
			movm point.y, (MOUSEHOOKSTRUCT ptr [eax]).pt.y
		jmp case_process
		
		case_default:
		mov eax, -1
		jmp @F
		case_process:
		
				push lp
				push wp
				push code
				push hhookm
			call CallNextHookEx
		@@:
		
	ret
MouseHook endp
WM_TIMER_ proc hwnd:DWORD, msg:DWORD, id:DWORD, time:DWORD
	local rect:RECT, pt:POINT
		
			paddr rect
			push hwnd
		call GetWindowRect
		
		mov eax, rect.left
		mov ebx, rect.top
		add eax, WND_WIDTH/2
		add ebx, WND_HEIGHT/2
		mov pt.x, eax
		mov pt.y, ebx
		
		mov cx, 20
		mov eax, point.x
		sub eax, pt.x
		mov edx, eax
		shr edx, 16
		idiv cx
		movsx eax, ax
		add pt.x, eax
		
		mov eax, point.y
		sub eax, pt.y
		mov edx, eax
		shr edx, 16
		idiv cx
		movsx eax, ax
		add pt.y, eax
		
		sub pt.x, WND_WIDTH/2
		sub pt.y, WND_HEIGHT/2
		
		cmp pt.x, NULL
		cmp pt.y, NULL
		
			push SWP_NOSIZE or SWP_NOSENDCHANGING
			push NULL
			push NULL
			push pt.y
			push pt.x
			push HWND_TOPMOST
			push hwnd
		call SetWindowPos
		
;		mov ecx, 100
;		add pt.x, WND_WIDTH/2
;		add pt.y, WND_HEIGHT/2
;		mov eax, pt.x
;		mov ebx, pt.x
;		sub eax, ecx
;		add ebx, ecx
;		mov rect.left, eax
;		mov rect.right, ebx
;		
;		mov eax, pt.y
;		mov ebx, pt.y
;		sub eax, ecx
;		add ebx, ecx
;		mov rect.top, eax
;		mov rect.bottom, ebx
;		
;			paddr rect
;		call ClipCursor
		
	ret
WM_TIMER_ endp

;Utils
	;Memory
MemoryFill proc uses edi pMem:DWORD, cbSize:DWORD, fill:BYTE

		cld
		mov ecx, cbSize
	    mov ah, fill
	    mov al, fill
	    shl eax, 16
	    mov ah, fill
	    mov al, fill
	    mov edi, pMem
	    shr ecx, 2
	    jz @F
	    rep stosd
	    @@:
	    mov ecx, cbSize
	    and ecx, 3
	    jz @F
	    rep stosb
	    @@:
	    
	ret
MemoryFill endp
;MemoryCopy proc uses ecx edi esi pDest:DWORD, pSrc:DWORD, cbSize:DWORD
;
;		cld
;	    mov edi, pDest
;	    mov esi, pSrc
;		mov ecx, cbSize
;		shr ecx, 2
;		jz @F
;	    rep movsd
;	    @@:
;	    mov ecx, cbSize
;	    and ecx, 3
;	    jz @F
;	    rep movsb
;	    @@:
;
;	ret
;MemoryCopy endp
;	;Other
;WriteConsoleIntA proc uses ebx ecx edx esi edi num:DWORD, radix:DWORD
;	local pString:DWORD, cWritten:DWORD
;			push radix
;			push num
;		call IntToString
;		mov pString, eax
;		call AllocConsole
;			push STD_OUTPUT_HANDLE
;		call GetStdHandle
;			push NULL
;			paddr cWritten, ecx
;				push eax
;						push pString
;					call StringLength
;					dec eax
;				pop ebx
;			push eax
;			push pString
;			push ebx
;		call WriteConsole
;		free pString
;	ret
;WriteConsoleIntA endp
;WriteConsoleStringA proc uses ebx ecx edx esi edi pString:DWORD
;	local cWritten:DWORD
;	
;		call AllocConsole
;			push STD_OUTPUT_HANDLE
;		call GetStdHandle
;			push NULL
;			paddr cWritten, ecx
;				push eax
;						push pString
;					call StringLength
;					dec eax
;				pop ebx
;			push eax
;			push pString
;			push ebx
;		call WriteConsole
;		
;	ret
;WriteConsoleStringA endp
;WriteConsoleNlA proc uses ebx ecx edx esi edi
;	local cWritten:DWORD
;		
;		call AllocConsole
;			push STD_OUTPUT_HANDLE
;		call GetStdHandle
;		push 0A0Dh
;		mov ebx, esp
;			push NULL
;			paddr cWritten, ecx
;			push 2
;			push ebx
;			push eax
;		call WriteConsole
;		pop ebx
;		
;	ret
;WriteConsoleNlA endp
;GetWindowIntA proc hwnd:DWORD
;	local pString:DWORD
;
;			push NULL
;			push NULL
;			push WM_GETTEXTLENGTH
;			push hwnd
;		call SendMessage
;		inc eax
;		push eax
;		malloc eax
;		mov pString, eax
;		pop eax
;			push pString
;			push eax
;			push WM_GETTEXT
;			push hwnd
;		call SendMessage
;			push pString
;		call StringToInt
;		push eax
;		free pString
;		pop eax
;	ret
;GetWindowIntA endp
;StringToInt proc uses esi ebx edx pString:DWORD
;		
;		xor eax, eax
;		mov esi, pString
;		@@:
;			cmp byte ptr [esi], 30h
;			jl @F
;			cmp byte ptr [esi], 39h
;			jg @F
;			
;			xor ebx, ebx
;			mov bl, byte ptr [esi]
;			sub ebx, 30h
;			add eax, ebx
;			xor edx, edx
;			mov ebx, 10
;			mul ebx
;			inc esi
;			jmp @B
;		@@:
;		xor edx, edx
;		mov ebx, 10
;		div ebx
;		
;	ret
;StringToInt endp
;SetWindowIntA proc hwnd:DWORD, num:DWORD, radix:DWORD
;
;			push radix
;			push num
;		call IntToString
;		push eax
;			push eax
;			push NULL
;			push WM_SETTEXT
;			push hwnd
;		call SendMessage
;		pop eax
;		free eax
;	ret
;SetWindowIntA endp
;IntToString proc num:DWORD, radix:DWORD
;	local pString:DWORD
;		
;		mov eax, radix
;		test eax, eax
;		jnz @F
;			xor eax, eax
;			ret
;		@@:
;		cmp eax, 36
;		jle @F
;			xor eax, eax
;			ret
;		@@:
;			push radix
;			push num
;		call IntLength
;		push eax
;		inc eax
;		malloc eax
;		mov pString, eax
;		mov edi, eax
;		pop eax
;		add edi, eax
;		mov eax, num
;		@@:
;			cmp edi, pString
;			je @F
;			dec edi
;			xor edx, edx
;			div radix
;			cmp edx, 10
;			jae charLetter
;			jb charNumber
;			charBegin:
;				charLetter:
;					add edx, 37h
;				jmp charEnd
;				charNumber:
;					add edx, 30h
;				jmp charEnd
;			charEnd:
;			mov byte ptr [edi], dl
;			jmp @B
;		@@:
;		mov eax, pString
;
;	ret
;IntToString endp
;IntToPaddedString proc num:DWORD, radix:DWORD, _length:DWORD, pad:BYTE
;	local pString:DWORD
;		
;		mov eax, radix
;		test eax, eax
;		jnz @F
;			xor eax, eax
;			ret
;		@@:
;		cmp eax, 36
;		jle @F
;			xor eax, eax
;			ret
;		@@:
;			push radix
;			push num
;		call IntLength
;		cmp eax, _length
;		jae @F
;			mov eax, _length
;		@@:
;		push eax
;		inc eax
;		malloc eax
;		mov pString, eax
;		mov edi, eax
;		pop eax
;		add edi, eax
;		mov eax, num
;		@@:
;			cmp edi, pString
;			je @F
;			dec edi
;			xor edx, edx
;			div radix
;			cmp edx, 10
;			jae charLetter
;			jb charNumber
;			charBegin:
;				charLetter:
;					add edx, 37h
;				jmp charEnd
;				charNumber:
;					add edx, 30h
;				jmp charEnd
;			charEnd:
;			mov byte ptr [edi], dl
;			test eax, eax
;			jz @F
;			jmp @B
;		@@:
;		mov dl, pad
;		@@:
;			cmp edi, pString
;			je @F
;			dec edi
;			mov byte ptr [edi], dl
;			test eax, eax
;			jmp @B
;		@@:
;		mov eax, pString
;
;	ret
;IntToPaddedString endp
;IntLength proc uses ebx ecx edx num:DWORD, radix:DWORD
;		
;		mov eax, num
;		mov ecx, radix
;		xor ebx, ebx
;		test ecx, ecx
;		jnz @F
;			xor eax, eax
;			ret
;		@@:
;			test eax, eax
;			jz @F
;			xor edx, edx
;			div ecx
;			inc ebx
;			jmp @B
;		@@:
;		test ebx, ebx
;		jnz @F
;			inc ebx
;		@@:
;		mov eax, ebx
;	ret
;IntLength endp
;Min proc num1:DWORD, num2:DWORD
;		
;		mov eax, num2
;		cmp eax, num1
;		jg @F
;			ret
;		@@:
;			mov eax, num1
;		
;	ret
;Min endp
;Max proc num1:DWORD, num2:DWORD
;		
;		mov eax, num2
;		cmp eax, num1
;		jl @F
;			ret
;		@@:
;			mov eax, num1
;		
;	ret
;Max endp
;StringConcatenate proc str1:DWORD, str2:DWORD
;	local cbStr1:DWORD, cbStr2:DWORD, cbStr3:DWORD, pString:DWORD
;			push str1
;		call StringLength
;		dec eax
;		mov cbStr1, eax
;			push str2
;		call StringLength
;		mov cbStr2, eax
;		add eax, cbStr1
;		mov cbStr3, eax
;		
;		malloc cbStr3
;		mov pString, eax
;			
;			push cbStr1
;			push str1
;			push pString
;		call MemoryCopy
;		mov edi, pString
;		add edi, cbStr1
;			push cbStr2
;			push str2
;			push edi
;		call MemoryCopy
;		mov eax, pString
;
;	ret
;StringConcatenate endp
;StringEqual proc str1:DWORD, str2:DWORD
;
;		cld
;			push str1
;		call StringLength
;		mov ecx, eax
;		mov edi,str1
;		mov esi,str2
;		repe cmpsb
;		pushfd
;		pop eax
;		shr eax, 6
;		and eax, 1
;		
;	ret
;StringEqual endp
;StringLength proc uses edi ecx str1:DWORD
;
;		cld
;		mov ecx, 0FFFFFFFFh
;		mov al, NULL
;		mov edi,str1
;		repne scasb
;		mov eax, 0FFFFFFFFh
;		sub eax, ecx
;		
;	ret
;StringLength endp
end start