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

	    	push byte ptr NULL
		    push sizeof WNDCLASSEX
				lea eax, wc
			push eax
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
			push WHITE_BRUSH
		call GetStockObject
	    mov wc.hbrBackground, eax
	    push hinst
	    pop wc.hInstance
	    mov wc.cbSize, SIZEOF WNDCLASSEX
	    mov wc.style, CS_HREDRAW or CS_VREDRAW or CS_DBLCLKS
	    	lea eax, WndProc
	    mov wc.lpfnWndProc, eax
	    mov wc.cbClsExtra, NULL
	    mov wc.cbWndExtra, NULL
	    mov wc.lpszMenuName, 1000
	    	lea eax, ClassName
	    mov wc.lpszClassName, eax
	    
	    		lea eax, wc
	    	push eax
	    call RegisterClassEx
	    
			push NULL
			push hinst
			push NULL
			push NULL
			push WND_HEIGHT
			push WND_WIDTH
			push CW_USEDEFAULT
			push CW_USEDEFAULT
			push WS_SYSMENU or WS_THICKFRAME or WS_MAXIMIZEBOX or WS_MINIMIZEBOX
				lea eax, AppName
			push eax
				lea eax, ClassName
			push eax
			push WS_EX_LAYERED
		call CreateWindowEx
		    
	ret
WinMain_wc endp
WinMain_msgLoop proc
	local pmsg:DWORD
		
		    push sizeof MSG
			push HEAP_ZERO_MEMORY
				call GetProcessHeap
			push eax
	    call HeapAlloc
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
			push pmsg
			push HEAP_ZERO_MEMORY
				call GetProcessHeap
			push eax
		call HeapFree
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
	
	cmp msg, WM_SIZE
	je case_WM_SIZE
	
	cmp msg, WM_LBUTTONDOWN
	je case_WM_LBUTTONDOWN
	cmp msg, WM_RBUTTONDOWN
	je case_WM_RBUTTONDOWN
	cmp msg, WM_MOUSEMOVE
	je case_WM_MOUSEMOVE
	
	cmp msg, WM_MOUSEWHEEL
	je case_WM_MOUSEWHEEL
	
	cmp msg, WM_LBUTTONDBLCLK
	je case_WM_LBUTTONDBLCLK
	
	cmp msg, WM_RBUTTONDBLCLK
	je case_WM_RBUTTONDBLCLK
	
	cmp msg, WM_GETMINMAXINFO
	je case_WM_GETMINMAXINFO
	
	cmp msg, WM_COMMAND
	je case_WM_COMMAND
	
	cmp msg, WM_ERASEBKGND
	je case_WM_ERASEBKGND
	
	jmp case_default

	case_WM_CREATE:
		call WM_CREATE_Init
			push hwnd
		call WM_CREATE_Size
			push hwnd
		call WM_CREATE_InitBackBuffer
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
    
    case_WM_SIZE:
    		push lp
    		push wp
    		push hwnd
    	call WM_SIZE_
    jmp case_end_msg
    
    case_WM_LBUTTONDOWN:
    case_WM_RBUTTONDOWN:
    case_WM_MOUSEMOVE:
    		push lp
    		push wp
    		push hwnd
    	call WM_MOUSEMOVE_
    jmp case_end_msg
    
    case_WM_MOUSEWHEEL:
    		push wp
    		push hwnd
    	call WM_MOUSEWHEEL_
    jmp case_end_msg
    
    case_WM_LBUTTONDBLCLK:
    jmp case_end_msg
    
    case_WM_RBUTTONDBLCLK:
    jmp case_end_msg
    
    case_WM_GETMINMAXINFO:
    		push lp
    	call WM_GETMINMAXINFO_
    jmp case_end_msg
    
    case_WM_COMMAND:
    		push lp
    		push wp
    		push hwnd
    	call WM_COMMAND_
    jmp case_end_msg
    
    case_WM_ERASEBKGND:
    	mov eax, 1
    jmp case_end_msg2

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
WM_CREATE_Init proc

		xor edx, edx
		mov eax, initWidth
		mov ecx, initHeight
		mov gridWidth, eax
		mov gridHeight, ecx
		mul ecx
		mov gridSize, eax
			push eax
			push HEAP_ZERO_MEMORY
				call GetProcessHeap
			push eax
		call HeapAlloc
		mov pGrid, eax

	ret
WM_CREATE_Init endp
WM_CREATE_Size proc hwnd:DWORD
	local wRect:RECT
	local cRect:RECT
	local addHeight:DWORD
	local addWidth:DWORD
			
			paddr cRect
			push hwnd
		call GetClientRect
			paddr wRect
			push hwnd
		call GetWindowRect
		
		mov eax, wRect.top
		mov edx, wRect.left
		sub wRect.bottom, eax
		sub wRect.right, edx
		
		mov eax, wRect.bottom
		mov edx, wRect.right
		sub eax, cRect.bottom
		sub edx, cRect.right
		
		mov addHeight, eax
		mov addWidth, edx
		
		xor edx, edx
		mov eax, initWidth
		mul gridCellSize
		add eax, gridPadding
		add eax, gridPadding
		add eax, addWidth
		mov WND_WIDTH, eax
		
		xor edx, edx
		mov eax, initHeight
		mul gridCellSize
		add eax, gridPadding
		add eax, gridPadding
		add eax, addHeight
		mov WND_HEIGHT, eax
		
	ret
WM_CREATE_Size endp
WM_CREATE_InitBackBuffer proc hwnd:DWORD
	local mWid:DWORD
	local mHei:DWORD
	local rect:RECT
	local hdc:DWORD
		
			push hwnd
		call GetDC
		mov hdc, eax
		
			paddr rect
			push hwnd
		call GetClientRect
			
			push hdc
		call CreateCompatibleDC
		mov hdcBack, eax
			
			push rect.bottom
			push rect.right
			push hdc
		call CreateCompatibleBitmap
			
			push eax
			push hdcBack
		call SelectObject
		mov hdcBitmap, eax
		
			push hdc
		call DeleteDC
			
			push NULL
			push hwnd
		call WM_PAINT_Draw
		
	ret
WM_CREATE_InitBackBuffer endp
WM_CREATE_ShowUpdateWindow proc hwnd:DWORD
		
			push LWA_ALPHA
			push 255
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
			push SWP_NOMOVE
			push WND_HEIGHT
			push WND_WIDTH
			push NULL
			push NULL
			push HWND_TOP
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
		
		cmp timerOn, 1
		jne @F
	    		push timerID
	    		push hwnd
	    	call KillTimer
	    	mov timerOn, 0
	    @@:

		cmp pGrid, NULL
		je @F
				push pGrid
				push HEAP_ZERO_MEMORY
					call GetProcessHeap
				push eax
			call HeapFree
		@@:
			push hdcBitmap
			push hdcBack
		call SelectObject
			push eax
		call DeleteObject
			push hdcBack
		call DeleteDC
    		push NULL
    	call PostQuitMessage

	ret
WM_DESTROY_ endp
WM_PAINT_ proc hwnd:DWORD
	local ps:PAINTSTRUCT
	local hdc:DWORD
	local rect:RECT
			
			paddr rect
			push hwnd
		call GetClientRect
	
			paddr ps
			push hwnd
		call BeginPaint
		mov hdc, eax
			
			push SRCCOPY
			push NULL
			push NULL
			push hdcBack
			push rect.bottom
			push rect.right
			push NULL
			push NULL
			push hdc
		call BitBlt
		
			paddr ps
			push hwnd
		call EndPaint
		
		
	ret
WM_PAINT_ endp
WM_PAINT_Draw proc hwnd:DWORD, pGridOld:DWORD
	local rect:RECT
	local hbru:DWORD
	local hpen:DWORD
	local hdc:DWORD
	local hdcT:DWORD
	local hBiT:DWORD
	
		movm hdcT, hdcBack
		movm hBiT, hdcBitmap
			
			push hwnd
		call GetDC
		mov hdc, eax
			
			paddr rect
			push hwnd
		call GetClientRect
			
			push hdc
		call CreateCompatibleDC
		mov hdcBack, eax
		
			
			push rect.bottom
			push rect.right
			push hdc
		call CreateCompatibleBitmap
			
			push eax
			push hdcBack
		call SelectObject
		mov hdcBitmap, eax
		
			push hdc
		call DeleteDC
			
			push backColor
		call CreateSolidBrush
			push eax
				push eax
				paddr rect
				push hdcBack
			call FillRect
		call DeleteObject
		
		mov eax, pGridOld
		test eax, eax
		jz @F
				push SRCCOPY
				push NULL
				push NULL
				push hdcT
				push rect.bottom
				push rect.right
				push NULL
				push NULL
				push hdcBack
			call BitBlt
		@@:
		
			push hBiT
			push hdcT
		call SelectObject
			push eax
		call DeleteObject
			push hdcT
		call DeleteDC
			
			push gridColor
			push NULL
			push PS_SOLID
		call CreatePen
			
			push eax
			push hdcBack
		call SelectObject
		mov hpen, eax
		
		
			push deadColor
		call CreateSolidBrush
		
			push eax
			push hdcBack
		call SelectObject
		mov hbru, eax
		
		movm pGridThread, pGridOld
		
			push pGridOld
		call WM_PAINT_DrawAllDead
		
			push aliveColor
		call CreateSolidBrush
			push eax
			push hdcBack
		call SelectObject
			push eax
		call DeleteObject
		
		movm pGridThread, pGridOld
		
			push pGridOld
		call WM_PAINT_DrawAllAlive
		
			push hbru
			push hdcBack
		call SelectObject
			push eax
		call DeleteObject
			push hpen
			push hdcBack
		call SelectObject
			push eax
		call DeleteObject
		
	ret
WM_PAINT_Draw endp
WM_PAINT_DrawAllDead proc pGridOld:DWORD
	local hThread[numThreads]:DWORD
	
		xor ecx, ecx
		@@:
			cmp ecx, numThreads
			jge @F
				push ecx
					push NULL
					push NULL
					push ecx
					paddr WM_PAINT_DrawDeadThread
					push NULL
					push NULL
				call CreateThread
				pop ecx
				mov hThread[ecx*4], eax
				inc ecx
			jmp @B
		@@:
	
			push INFINITE
			push TRUE
			paddr hThread
			push numThreads
		call WaitForMultipleObjects
		
		xor ecx, ecx
		@@:
			cmp ecx, numThreads
			jge @F
				push ecx
						push hThread[ecx*4]
					call CloseHandle
				pop ecx
				inc ecx
			jmp @B
		@@:
	
	ret
WM_PAINT_DrawAllDead endp
WM_PAINT_DrawAllAlive proc pGridOld:DWORD
	local hThread[numThreads]:DWORD
	
		xor ecx, ecx
		@@:
			cmp ecx, numThreads
			jge @F
				push ecx
					push NULL
					push NULL
					push ecx
					paddr WM_PAINT_DrawAliveThread
					push NULL
					push NULL
				call CreateThread
				pop ecx
				mov hThread[ecx*4], eax
				inc ecx
			jmp @B
		@@:
		
			push INFINITE
			push TRUE
			paddr hThread
			push numThreads
		call WaitForMultipleObjects
		
		xor ecx, ecx
		@@:
			cmp ecx, numThreads
			jge @F
				push ecx
						push hThread[ecx*4]
					call CloseHandle
				pop ecx
				inc ecx
			jmp @B
		@@:
		
	ret
WM_PAINT_DrawAllAlive endp
WM_PAINT_DrawAliveThread proc index:DWORD
	local sDraw:DWORD
	local eDraw:DWORD
	local rem:DWORD
	local sizeDraw:DWORD
	
	mov eax, gridSize
	mov ebx, numThreads
	xor edx, edx
	div ebx
	mov sizeDraw, eax
	mov rem, edx
	
	xor edx, edx
	mul index
	mov sDraw, eax
	
	add eax, sizeDraw
	dec eax
	mov eDraw, eax
	
	mov eax, rem
	test eax, eax
	jz @F
		cmp index, eax
		jge @F
			mov eax, index
			inc eDraw
	@@:
	add sDraw, eax
	add eDraw, eax
	
			push eDraw
			push sDraw
			push pGridThread
		call WM_PAINT_DrawSegmentAlive
		
	ret
WM_PAINT_DrawAliveThread endp
WM_PAINT_DrawDeadThread proc index:DWORD
	local sDraw:DWORD
	local eDraw:DWORD
	local rem:DWORD
	local sizeDraw:DWORD
	
	mov eax, gridSize
	mov ebx, numThreads
	xor edx, edx
	div ebx
	mov sizeDraw, eax
	mov rem, edx
	
	xor edx, edx
	mul index
	mov sDraw, eax
	
	add eax, sizeDraw
	dec eax
	mov eDraw, eax
	
	mov eax, rem
	test eax, eax
	jz @F
		cmp index, eax
		jge @F
			mov eax, index
			inc eDraw
	@@:
	add sDraw, eax
	add eDraw, eax
	
			push eDraw
			push sDraw
			push pGridThread
		call WM_PAINT_DrawSegmentDead

	ret
WM_PAINT_DrawDeadThread endp
WM_PAINT_DrawSegmentDead proc pGridOld:DWORD, sDraw:DWORD, eDraw:DWORD
	local x1:DWORD
	local y1:DWORD
	local x2:DWORD
	local y2:DWORD


		mov ecx, sDraw
		@@:
		cmp ecx, eDraw
		jg @F
			mov eax, pGrid
			mov al, byte ptr [eax + ecx]
			and al, 1
			cmp al, 1
			je WM_PAINT_DrawContinue
			
			mov eax, pGridOld
			test eax, eax
			jz nullParam
				mov al, byte ptr [eax + ecx]
				and al, 1
				cmp al, 0
				je WM_PAINT_DrawContinue
			nullParam:
			
			push ecx
				mov eax, ecx
				xor edx, edx
				div gridWidth
				mov ebx, edx
				
				xor edx, edx
				mul gridCellSize
				add eax, gridPadding
				
				mov edx, eax
				mov eax, ebx
				mov ebx, edx
				
				xor edx, edx
				mul gridCellSize
				add eax, gridPadding
				
				mov y2, ebx
				mov x2, eax
				add ebx, gridCellSize
				add eax, gridCellSize
				mov y1, ebx
				mov x1, eax
				
				rectFail:
						
						push y2
						push x2
						push y1
						push x1
						push hdcBack
					call Rectangle
				test eax, eax
				jz rectFail
					
			pop ecx
			WM_PAINT_DrawContinue:
			inc ecx
		
		jmp @B
		@@:

	ret
WM_PAINT_DrawSegmentDead endp
WM_PAINT_DrawSegmentAlive proc pGridOld:DWORD, sDraw:DWORD, eDraw:DWORD
	local x1:DWORD
	local y1:DWORD
	local x2:DWORD
	local y2:DWORD

		mov ecx, sDraw
		@@:
		cmp ecx, eDraw
		jg @F
			mov eax, pGrid
			mov al, byte ptr [eax + ecx]
			and al, 1
			cmp al, 0
			je WM_PAINT_DrawContinue
			
			mov eax, pGridOld
			test eax, eax
			jz nullParam
				mov al, byte ptr [eax + ecx]
				and al, 1
				cmp al, 1
				je WM_PAINT_DrawContinue
			nullParam:
			
			push ecx
				mov eax, ecx
				xor edx, edx
				div gridWidth
				mov ebx, edx
				
				xor edx, edx
				mul gridCellSize
				add eax, gridPadding
				
				mov edx, eax
				mov eax, ebx
				mov ebx, edx
				
				xor edx, edx
				mul gridCellSize
				add eax, gridPadding
				
				mov y2, ebx
				mov x2, eax
				add ebx, gridCellSize
				add eax, gridCellSize
				mov y1, ebx
				mov x1, eax
				
				rectFail:
						
						push y2
						push x2
						push y1
						push x1
						push hdcBack
					call Rectangle
				test eax, eax
				jz rectFail
					
			pop ecx
			WM_PAINT_DrawContinue:
			inc ecx
		jmp @B
		@@:

	ret
WM_PAINT_DrawSegmentAlive endp
WM_SIZE_ proc hwnd:DWORD, wp:DWORD, lp:DWORD

		cmp wp, SIZE_MINIMIZED
    	je case_NOSIZE
    	
    	jmp case_RESIZE
    	
    	case_NOSIZE:
    	jmp case_end_size
    	
    	case_RESIZE:
	    		push lp
	    		push hwnd
    		call WM_SIZE_RESIZE
    		test eax, eax
    		jz @F
    				push NULL
					push hwnd
				call WM_PAINT_Draw
    		@@:
    	jmp case_end_size
    	case_end_size:

	ret
WM_SIZE_ endp
WM_SIZE_RESIZE proc hwnd:DWORD, lp:DWORD
	local gridWidthNew:DWORD
	local gridHeightNew:DWORD
	local gridSizeNew:DWORD
	local pGridNew:DWORD
	
		mov eax, lp
		and eax, 0FFFFh
		sub eax, gridPadding
		sub eax, gridPadding
		xor edx, edx
		div gridCellSize
		mov gridWidthNew, eax
		
		mov eax, lp
		shr eax, 10h
		sub eax, gridPadding
		sub eax, gridPadding
		xor edx, edx
		div gridCellSize
		mov gridHeightNew, eax
		
		mov eax, gridWidthNew
		cmp eax, gridWidth
		jne @F
		mov eax, gridHeightNew
		cmp eax, gridHeight
		jne @F
		jmp endResize
		
		@@:
			mov eax, gridHeightNew
			xor edx, edx
			mul gridWidthNew
			mov gridSizeNew, eax
			
				push eax
				push HEAP_ZERO_MEMORY
					call GetProcessHeap
				push eax
			call HeapAlloc
			mov pGridNew, eax
			
				push gridHeightNew
				push gridWidthNew
				push pGridNew
			call WM_SIZE_RESIZE_GridCopy
			
				push pGrid
				push HEAP_ZERO_MEMORY
					call GetProcessHeap
				push eax
			call HeapFree
			movm pGrid, pGridNew
			
			movm gridWidth, gridWidthNew
			movm gridHeight, gridHeightNew
			movm gridSize, gridSizeNew
			
			mov eax, 1
			jmp endResize2
		endResize:
		xor eax, eax
		endResize2:
		
	ret
WM_SIZE_RESIZE endp
WM_SIZE_RESIZE_GridCopy proc pGridNew:DWORD, gridWidthNew:DWORD, gridHeightNew:DWORD
	local minHeight:DWORD
	local minWidth:DWORD
			
			push gridHeightNew
			push gridHeight
		call Min
		mov minHeight, eax
			
			push gridWidthNew
			push gridWidth
		call Min
		mov minWidth, eax
	
	
		mov edi, pGridNew
		mov esi, pGrid
		xor ecx, ecx
		@@:
				push minWidth
				push esi
				push edi
			call MemoryCopy
			add edi, gridWidthNew
			add esi, gridWidth
			inc ecx
		cmp ecx, minHeight
		jl @B
		
	ret
WM_SIZE_RESIZE_GridCopy endp
WM_MOUSEMOVE_ proc hwnd:DWORD, wp:DWORD, lp:DWORD
	local gridRow:DWORD
	local gridCol:DWORD
	local hbru:DWORD
	local hpen:DWORD
		
		mov eax, gridWidth
		xor edx, edx
		mul gridCellSize
		add eax, gridPadding
		
		mov ebx, lp
		and ebx, 0FFFFh
		cmp ebx, gridPadding
		jle case_end_mousemove
		cmp ebx, eax
		jge case_end_mousemove
		
		mov eax, gridHeight
		xor edx, edx
		mul gridCellSize
		add eax, gridPadding
		
		mov ebx, lp
		shr ebx, 10h
		cmp ebx, gridPadding
		jle case_end_mousemove
		cmp ebx, eax
		jge case_end_mousemove
		
			push lp
		call lpToColRow
		mov gridCol, eax
		mov gridRow, ebx

		cmp wp, MK_LBUTTON
		je case_L
		cmp wp, MK_RBUTTON
		je case_R
		jmp case_end_mousemove
		
		case_L:
			mov eax, gridCol
			xor edx, edx
			mul gridWidth
			add eax, gridRow
			
			mov ebx, pGrid
			mov cl, byte ptr [ebx + eax]
			and cl, 1
			cmp cl, 1
			je case_end_mousemove
			mov byte ptr [ebx + eax], 1
			
			mov eax, gridCol
			xor edx, edx
			mul gridCellSize
			add eax, gridPadding
			mov ebx, eax
			
			mov eax, gridRow
			xor edx, edx
			mul gridCellSize
			add eax, gridPadding
				
				
				push ebx
				push eax
					add ebx, gridCellSize
					add eax, gridCellSize
				push ebx
				push eax
						push gridColor
						push NULL
						push PS_SOLID
					call CreatePen
						push eax
						push hdcBack
					call SelectObject
					mov hpen, eax
						push aliveColor
					call CreateSolidBrush
						push eax
						push hdcBack
					call SelectObject
					mov hbru, eax
				push hdcBack
			call Rectangle
				push hbru
				push hdcBack
			call SelectObject
				push eax
			call DeleteObject
				push hpen
				push hdcBack
			call SelectObject
				push eax
			call DeleteObject
				push NULL
				push NULL
				push hwnd
			call InvalidateRect
			
		jmp case_end_mousemove
		case_R:
			mov eax, gridCol
			xor edx, edx
			mul gridWidth
			add eax, gridRow
			
			mov ebx, pGrid
			mov cl, byte ptr [ebx + eax]
			and cl, 1
			cmp cl, 0
			je case_end_mousemove
			mov byte ptr [ebx + eax], 0
			
			mov eax, gridCol
			xor edx, edx
			mul gridCellSize
			add eax, gridPadding
			mov ebx, eax
			
			mov eax, gridRow
			xor edx, edx
			mul gridCellSize
			add eax, gridPadding
				
				
				push ebx
				push eax
					add ebx, gridCellSize
					add eax, gridCellSize
				push ebx
				push eax
						push gridColor
						push NULL
						push PS_SOLID
					call CreatePen
						push eax
						push hdcBack
					call SelectObject
					mov hpen, eax
						push deadColor
					call CreateSolidBrush
						push eax
						push hdcBack
					call SelectObject
					mov hbru, eax
				push hdcBack
			call Rectangle
				push hbru
				push hdcBack
			call SelectObject
				push eax
			call DeleteObject
				push hpen
				push hdcBack
			call SelectObject
				push eax
			call DeleteObject
				push NULL
				push NULL
				push hwnd
			call InvalidateRect
		jmp case_end_mousemove
		case_end_mousemove:
		
			
	ret
WM_MOUSEMOVE_ endp
WM_MOUSEWHEEL_ proc hwnd:DWORD, wp:DWORD
	local rect:RECT

		
		mov eax, wp
		shr eax, 10h
		cmp ax, 0
		jg posi
		jl nega
		
		posi:
		cmp gridCellSize, 20
		jge @F
		inc gridCellSize
		jmp paint
		@@:
		jmp signend
		nega:
		cmp gridCellSize, 3
		jle @F
		dec gridCellSize
		jmp paint
		@@:
		signend:
		jmp @F
		paint:
			paddr rect
			push hwnd
		call GetClientRect
		
		
		mov edx, rect.right
		mov eax, rect.bottom
		ror eax, 10h
		mov ax, dx
			push eax
			push hwnd
		call WM_SIZE_RESIZE
			push NULL
			push hwnd
		call WM_PAINT_Draw
			push NULL
			push NULL
			push hwnd
		call InvalidateRect
		@@:
	ret
WM_MOUSEWHEEL_ endp
WM_GETMINMAXINFO_ proc lp:DWORD
		mov eax, lp
		movm dword ptr [eax + 24], WND_WIDTH
		movm dword ptr [eax + 28], WND_HEIGHT
	ret
WM_GETMINMAXINFO_ endp
WM_COMMAND_ proc hwnd:DWORD, wp:DWORD, lp:DWORD
		
		mov eax, wp
		
		cmp ax, exitID
		je c_exit
		
		cmp ax, startID
		je c_start
		
		cmp ax, stopID
		je c_stop
		
		cmp ax, nextID
		je c_next
		
		cmp ax, clearID
		je c_clear
		
		cmp ax, fillID
		je c_fill
		
		cmp ax, settingsID
		je c_settings
		
		jmp c_end
		
		c_exit:
				push NULL
				push NULL
				push WM_CLOSE
				push hwnd
			call PostMessage
		jmp c_end
		
		c_start:
	    		paddr sStop
	    		push stopID
	    		push MF_BYCOMMAND or MF_STRING
	    		push startID
			    		push hwnd
			    	call GetMenu
	    		push eax
	    	call ModifyMenu
	    		push MF_DISABLED
	    		push nextID
			    		push hwnd
			    	call GetMenu
	    		push eax
	    	call EnableMenuItem
	    		push hwnd
	    	call DrawMenuBar
	    		paddr WM_TIMER_
	    		push timerDelay
	    		push timerID
	    		push hwnd
	    	call SetTimer
	    	mov timerOn, 1
		jmp c_end
		
		c_stop:
			cmp timerOn, 1
			jne @F
		    		push timerID
		    		push hwnd
		    	call KillTimer
		    	mov timerOn, 0
		    @@:
	    		paddr sStart
	    		push startID
	    		push MF_BYCOMMAND or MF_STRING
	    		push stopID
			    		push hwnd
			    	call GetMenu
	    		push eax
	    	call ModifyMenu
	    		push MF_ENABLED
	    		push nextID
			    		push hwnd
			    	call GetMenu
	    		push eax
	    	call EnableMenuItem
	    		push hwnd
	    	call DrawMenuBar
		jmp c_end
		
		c_next:
			call WM_TIMER_ZeroAll
			
				push gridSize
				push HEAP_ZERO_MEMORY
					call GetProcessHeap
				push eax
			call HeapAlloc
			push eax
			push eax
			
				push gridSize
				push pGrid
				push eax
			call MemoryCopy
			
			call WM_TIMER_NeighborsAll
			call WM_TIMER_NextAll
				push hwnd
			call WM_PAINT_Draw
			
				push HEAP_ZERO_MEMORY
					call GetProcessHeap
				push eax
			call HeapFree
			
				push NULL
				push NULL
				push hwnd
			call InvalidateRect
		jmp c_end
		
		c_clear:
				push byte ptr 0
				push gridSize
				push pGrid
			call MemoryFill
				push NULL
				push hwnd
			call WM_PAINT_Draw
				push NULL
				push NULL
				push hwnd
			call InvalidateRect
		jmp c_end
		
		c_fill:
				push byte ptr 1
				push gridSize
				push pGrid
			call MemoryFill
				push NULL
				push hwnd
			call WM_PAINT_Draw
				push NULL
				push NULL
				push hwnd
			call InvalidateRect
		jmp c_end
		
		c_settings:
				push NULL
				paddr SettingsProc
				push hwnd
				push 1001
						push NULL
					call GetModuleHandle
				push eax
			call DialogBoxParam
		jmp c_end
		
		c_end:
		
	ret
WM_COMMAND_ endp
WM_TIMER_ proc hwnd:DWORD, msg:DWORD, id:DWORD, time:DWORD
		
		call WM_TIMER_ZeroAll
		
			push gridSize
			push HEAP_ZERO_MEMORY
				call GetProcessHeap
			push eax
		call HeapAlloc
		push eax
		push eax
		
			push gridSize
			push pGrid
			push eax
		call MemoryCopy
		
		call WM_TIMER_NeighborsAll
		call WM_TIMER_NextAll
			push hwnd
		call WM_PAINT_Draw
		
			push HEAP_ZERO_MEMORY
				call GetProcessHeap
			push eax
		call HeapFree
			push NULL
			push NULL
			push hwnd
		call InvalidateRect

	ret
WM_TIMER_ endp
WM_TIMER_ZeroAll proc
		
		mov edi, pGrid
		xor ecx, ecx
		@@:
			and byte ptr [edi], 1
			inc edi
			inc ecx
			cmp ecx, gridSize
			jl @B
		
		
	ret
WM_TIMER_ZeroAll endp
WM_TIMER_NeighborsAll proc

		mov edi, pGrid
		xor ecx, ecx
		@@:
				push ecx
				push edi
			call WM_TIMER_NeighborsSingle
			inc ecx
			cmp ecx, gridSize
		jl @B

	ret
WM_TIMER_NeighborsAll endp
WM_TIMER_NeighborsSingle proc uses ecx edi cell:DWORD, index:DWORD
	local flags:BYTE
	
		mov edi, cell
		add edi, index
		
		mov al, byte ptr [edi]
		and al, 1
		test al, al
		jz notAlive
			mov flags, 0FFh
			mov eax, index
			xor edx, edx
			div gridWidth
			
			cmp eax, NULL
			jne @F
				and flags, 00011111b
			@@:
			mov ebx, gridHeight
			dec ebx
			cmp eax, ebx
			jne @F
				and flags, 11111000b
			@@:
			
			cmp edx, NULL
			jne @F
				and flags, 01101011b
			@@:
			mov ebx, gridWidth
			dec ebx
			cmp edx, ebx
			jne @F
				and flags, 11010110b
			@@:
			
			xor eax, eax
			mov al, flags
			mov edx, gridWidth
			
		;Top 3
			;0,0
			mov esi, edi
			sub esi, edx
			dec esi
			
			shl ax, 1
			test ah, ah
			jz @F
				add byte ptr [esi], 2
			@@:
			;0,1
			xor ah, ah
			inc esi
			shl ax, 1
			test ah, ah
			jz @F
				add byte ptr [esi], 2
			@@:
			;0,2
			xor ah, ah
			inc esi
			shl ax, 1
			test ah, ah
			jz @F
				add byte ptr [esi], 2
			@@:
		;Middle 2
			;1,0
			xor ah, ah
			add esi, edx
			sub esi, 2
			shl ax, 1
			test ah, ah
			jz @F
				add byte ptr [esi], 2
			@@:
			;1,2
			xor ah, ah
			add esi, 2
			shl ax, 1
			test ah, ah
			jz @F
				add byte ptr [esi], 2
			@@:
		;Bottom 3
			;2,0
			xor ah, ah
			add esi, edx
			sub esi, 2
			shl ax, 1
			test ah, ah
			jz @F
				add byte ptr [esi], 2
			@@:
			;2,1
			xor ah, ah
			inc esi
			shl ax, 1
			test ah, ah
			jz @F
				add byte ptr [esi], 2
			@@:
			;2,2
			xor ah, ah
			inc esi
			shl ax, 1
			test ah, ah
			jz @F
				add byte ptr [esi], 2
			@@:
			
		notAlive:

	ret
WM_TIMER_NeighborsSingle endp
WM_TIMER_NextAll proc

		mov edi, pGrid
		xor ecx, ecx
		@@:
				push ecx
				push edi
			call WM_TIMER_NextSingle
			inc ecx
			cmp ecx, gridSize
		jl @B
	ret
WM_TIMER_NextAll endp
WM_TIMER_NextSingle proc uses ecx edi cell:DWORD, index:DWORD

		mov edi, cell
		add edi, index
		
		xor ebx, ebx
		mov bh, byte ptr [edi]
		shr bx, 1
		shr bl, 7
		test bl, bl
		jz Dead
		Alive:
			
			lea esi, s
			
				push esi
			call StringLength
			dec eax
			
			xor ecx, ecx
			@@:
				mov dl, byte ptr [esi + ecx]
				dec dl
				cmp bh, dl
				jne skipA
					mov byte ptr [edi], 1
				jmp EndNext
				skipA:
			inc ecx
			cmp ecx, eax
			jl @B
			@@:
				mov byte ptr [edi], 0
				jmp EndNext
		Dead:
			lea esi, b
			
				push esi
			call StringLength
			dec eax
			
			xor ecx, ecx
			@@:
				
				mov dl, byte ptr [esi + ecx]
				dec dl
				cmp bh, dl
				jne skipD
					mov byte ptr [edi], 1
				jmp EndNext
				skipD:
			inc ecx
			cmp ecx, eax
			jl @B
			@@:
				mov byte ptr [edi], 0
				jmp EndNext
		EndNext:
		
	ret
WM_TIMER_NextSingle endp

SettingsProc proc hwnd:DWORD, msg:DWORD, wp:DWORD, lp:DWORD

		cmp msg, WM_COMMAND
		je case_WM_COMMAND
		
		cmp msg, WM_INITDIALOG
		je case_WM_INITDIALOG
		
		cmp msg, WM_DESTROY
		je case_WM_DESTROY
		
		cmp msg, WM_CTLCOLORSTATIC
		je case_WM_CTLCOLORSTATIC
		
		jmp case_default
		
		case_WM_COMMAND:
				push lp
				push wp
				push hwnd
			call s_WM_COMMAND_
		jmp case_end_msg
		
		case_WM_INITDIALOG:
				push lp
				push wp
				push hwnd
			call s_WM_INITDIALOG_
		jmp case_end_msg
		
		case_WM_DESTROY:
				push hwnd
			call s_WM_DESTROY_
		jmp case_end_msg
		
		case_WM_CTLCOLORSTATIC:
				push lp
				push wp
				push hwnd
			call s_WM_CTLCOLORSTATIC_
		jmp case_end_msg2
		
		case_default:
		xor eax, eax
	ret
		
		case_end_msg:
		mov eax, 1
		case_end_msg2:
	ret
SettingsProc endp
s_WM_COMMAND_ proc hwnd:DWORD, wp:DWORD, lp:DWORD
		
		mov eax, wp
		
		cmp ax, 2
		je case_CANCEL
		
		cmp ax, 1024
		je case_OK
		
		cmp ax, 1025
		je case_ColorChoose
		cmp ax, 1026
		je case_ColorChoose
		cmp ax, 1027
		je case_ColorChoose
		cmp ax, 1028
		je case_ColorChoose
		cmp ax, 1030
		je case_ColorChoose
		cmp ax, 1031
		je case_ColorChoose
		cmp ax, 1032
		je case_ColorChoose
		cmp ax, 1033
		je case_ColorChoose
		
		jmp case_end_comm
		
		case_CANCEL:
				push NULL
				push hwnd
			call EndDialog
		jmp case_end_comm
		
		case_OK:
				push hwnd
			call s_OK
				push NULL
				push hwnd
			call EndDialog
		jmp case_end_comm
		
		case_ColorChoose:
				push lp
				push wp
				push hwnd
			call s_ColorChoose
		jmp case_end_comm
		
		case_end_comm:

	ret
s_WM_COMMAND_ endp
s_OK proc hwnd:DWORD

			push DWL_USER
			push hwnd
		call GetWindowLong
		
		movm aliveColor, [eax]
		movm deadColor, [eax + 4]
		movm gridColor, [eax + 8]
		movm backColor, [eax + 12]
			
			push byte ptr NULL
			push 9
			paddr s
		call MemoryFill
			push byte ptr NULL
			push 9
			paddr b
		call MemoryFill
			push NULL
			paddr s_OK_Enum
			push hwnd
		call EnumChildWindows
		
			push GW_OWNER
			push hwnd
		call GetWindow
		push eax
				push NULL
				push eax
			call WM_PAINT_Draw
		pop eax
			
			push NULL
			push NULL
			push eax
		call InvalidateRect

	ret
s_OK endp
s_OK_Enum proc hwnd:DWORD, lp:DWORD
	local bres:DWORD
	
			push hwnd
		call GetDlgCtrlID
		
		cmp eax, 1039
		jne @F
				paddr bres
				push NULL
				push UDM_GETPOS32
				push hwnd
			call SendMessage		
			cmp bres, NULL
			jne invalid
				mov timerDelay, eax
					push hwnd
				call GetParent
					push GW_OWNER
					push eax
				call GetWindow
				cmp timerOn, 1
				jne invalid
					push eax
			    		push timerID
			    		push eax
			    	call KillTimer
			    	pop ebx
			    		paddr WM_TIMER_
			    		push timerDelay
			    		push timerID
			    		push ebx
			    	call SetTimer
			invalid:
			jmp endOK
		@@:
		
		cmp eax, 1002
		jl @F
		
		cmp eax, 1019
		jg @F
				push eax
				push hwnd
			call s_OK_Enum_Check
		@@:
		endOK:
		mov eax, 1
	ret
s_OK_Enum endp
s_OK_Enum_Check proc hwnd:DWORD, id:DWORD
	local num:BYTE

			push NULL
			push NULL
			push BM_GETCHECK
			push hwnd
		call SendMessage
		cmp eax, BST_CHECKED
		jne notChecked
		
		mov eax, id
		sub eax, 1002
		xor edx, edx
		mov ecx, 9
		div ecx
		mov num, dl
		
		test eax, eax
		jz born
		jnz surv
		
		born:
			paddr b, ecx
		jmp end_
		surv:
			paddr s, ecx
		jmp end_
		end_:
			
		call StringLength
		dec eax
		inc dl
		mov byte ptr [eax + ecx], dl
		notChecked:
	ret
s_OK_Enum_Check endp
s_ColorChoose proc hwnd:DWORD, wp:DWORD, lp:DWORD
	local cc:CHOOSECOLOR
	local cr[16]:DWORD
	local DWL_USER_pmem:DWORD
	local colorID:DWORD
	local hbrushID:DWORD
	local ID:DWORD
	
		mov eax, wp
		xor edx, edx
		and eax, 0FFFFh
		mov ID, eax
		sub eax, 1025
		
		cmp eax, 5
		jl @F
			sub eax, 5
		@@:
		mov ecx, 4
		mul ecx
		mov colorID, eax
		add eax, 16
		mov hbrushID, eax
		

			push DWL_USER
			push hwnd
		call GetWindowLong
		mov DWL_USER_pmem, eax

    		push byte ptr 0
    		push sizeof cc
    		paddr cc
    	call MemoryFill
    		push byte ptr 0
    		push 64
    		paddr cr
    	call MemoryFill
    	
    	mov eax, colorID
    	mov ebx, DWL_USER_pmem
    	movm cc.rgbResult, [ebx + eax]
    	mov cc.lStructSize, sizeof CHOOSECOLOR
    	mov cc.Flags, CC_ANYCOLOR or CC_FULLOPEN or CC_RGBINIT
    	movm cc.hwndOwner, hwnd
    	maddr cc.lpCustColors, cr
    
    		paddr cc
    	call ChooseColor
    	test eax, eax
    	jz @F
    		mov eax, colorID
    		mov ebx, DWL_USER_pmem
			movm [ebx + eax], cc.rgbResult
    		
    			push cc.rgbResult
    		call CreateSolidBrush
    		push eax
			push ebx
			mov eax, hbrushID
			
				push [ebx + eax]
			call DeleteObject
			
			pop ebx
			mov eax, hbrushID
			pop [ebx + eax]
						
						push ID
						push hwnd
					call GetDlgItem
				push eax
						push eax
					call GetDC
				push eax
				push WM_CTLCOLORSTATIC
				push hwnd
			call SendMessage
				push NULL
				push NULL
				push hwnd
			call InvalidateRect
    	@@:
	ret
s_ColorChoose endp
s_WM_INITDIALOG_ proc hwnd:DWORD, wp:DWORD, lp:DWORD
	local DWL_USER_pmem:DWORD
			
			push NULL
			paddr s_WM_INITDIALOG_Enum
			push hwnd
		call EnumChildWindows
			
			push 32
			push HEAP_ZERO_MEMORY
				call GetProcessHeap
			push eax
	    call HeapAlloc
	    mov DWL_USER_pmem, eax
	    
	    movm [eax], aliveColor
	    movm [eax + 4], deadColor
	    movm [eax + 8], gridColor
	    movm [eax + 12], backColor
	    	
	    	push aliveColor
	    call CreateSolidBrush
	    push eax
	    	push deadColor
	    call CreateSolidBrush
	    push eax
	    	push gridColor
	    call CreateSolidBrush
	    push eax
	    	push backColor
	    call CreateSolidBrush
	    push eax
	    
	    mov eax, DWL_USER_pmem
	    pop [eax + 28]
	    pop [eax + 24]
	    pop [eax + 20]
	    pop [eax + 16]
		
			push DWL_USER_pmem
			push DWL_USER
			push hwnd
		call SetWindowLong
			
			push NULL
			push timerDelay
			push 1038
			push hwnd
		call SetDlgItemInt
		
	ret
s_WM_INITDIALOG_ endp
s_WM_INITDIALOG_Enum proc hwnd:DWORD, lp:DWORD
			
			push hwnd
		call GetDlgCtrlID
		
		cmp eax, 1039
		jne @F
				push hwnd
			call s_WM_INITDIALOG_Enum_UpDown
			jmp endInit
		@@:
		
		cmp eax, 1038
		jne @F
				push NULL
				push 4
				push EM_SETLIMITTEXT
				push hwnd
			call SendMessage
			jmp endInit
		@@:
		
		cmp eax, 1002
		jl @F
		
		cmp eax, 1019
		jg @F
				push eax
				push hwnd
			call s_WM_INITDIALOG_Enum_Checkbox
		@@:
		endInit:
		mov eax, 1
		
	ret
s_WM_INITDIALOG_Enum endp
s_WM_INITDIALOG_Enum_UpDown proc hwnd:DWORD
	local aAccel5:UDACCEL
	local aAccel4:UDACCEL
	local aAccel3:UDACCEL
	local aAccel2:UDACCEL
	local aAccel1:UDACCEL
	
		mov aAccel1.nSec, 1
		mov aAccel1.nInc, 25
		mov aAccel2.nSec, 2
		mov aAccel2.nInc, 50
		mov aAccel3.nSec, 3
		mov aAccel3.nInc, 100
		mov aAccel4.nSec, 4
		mov aAccel4.nInc, 250
		mov aAccel5.nSec, 5
		mov aAccel5.nInc, 500
		
			push 9999
			push 25
			push UDM_SETRANGE32
			push hwnd
		call SendMessage
			
			paddr aAccel1
			push 5
			push UDM_SETACCEL
			push hwnd
		call SendMessage
		
	ret
s_WM_INITDIALOG_Enum_UpDown endp
s_WM_INITDIALOG_Enum_Checkbox proc hwnd:DWORD, id:DWORD

		mov eax, id
		sub eax, 1002
		xor edx, edx
		mov ecx, 9
		div ecx
		push edx
		
		test eax, eax
		jz born
		jnz surv
		
		born:
			paddr b
		jmp end_
		surv:
			paddr s
		jmp end_
		end_:
		
		call s_WM_INITDIALOG_Enum_Check
		test eax, eax
		jz @F
				push hwnd
			call s_WM_INITDIALOG_Enum_Checkbox_check
		@@:
		
	ret
s_WM_INITDIALOG_Enum_Checkbox endp
s_WM_INITDIALOG_Enum_Check proc uses esi pMem:DWORD, check:DWORD

		mov esi, pMem
		xor eax, eax
		@@:
			mov al, byte ptr [esi]
			test eax, eax
			jz @F
			
			dec eax
			inc esi
			cmp eax, check
			jne @B
			
			mov eax, 1
		ret
			
		@@:
		xor eax, eax
		
	ret
s_WM_INITDIALOG_Enum_Check endp
s_WM_INITDIALOG_Enum_Checkbox_check proc hwnd:DWORD

			push NULL
			push BST_CHECKED
			push BM_SETCHECK
			push hwnd
		call SendMessage

	ret
s_WM_INITDIALOG_Enum_Checkbox_check endp
s_WM_DESTROY_ proc hwnd:DWORD
	local DWL_USER_pmem:DWORD

			push DWL_USER
			push hwnd
		call GetWindowLong
		mov DWL_USER_pmem, eax
			
				mov eax, DWL_USER_pmem
			push [eax + 16]
		call DeleteObject
				mov eax, DWL_USER_pmem
			push [eax + 20]
		call DeleteObject
				mov eax, DWL_USER_pmem
			push [eax + 24]
		call DeleteObject
				mov eax, DWL_USER_pmem
			push [eax + 28]
		call DeleteObject
		
			push DWL_USER_pmem
			push HEAP_ZERO_MEMORY
				call GetProcessHeap
			push eax
		call HeapFree
		
	ret
s_WM_DESTROY_ endp
s_WM_CTLCOLORSTATIC_ proc hwnd:DWORD, wp:DWORD, lp:DWORD
	local DWL_USER_pmem:DWORD
	
			push DWL_USER
			push hwnd
		call GetWindowLong
		mov DWL_USER_pmem, eax
		
			push lp
		call GetDlgCtrlID
		
		mov ebx, DWL_USER_pmem
		
		cmp eax, 1025
		je case_Alive
		cmp eax, 1026
		je case_Dead
		cmp eax, 1027
		je case_Grid
		cmp eax, 1028
		je case_Padding
		jmp case_default
		
		case_Alive:
			mov eax, [ebx + 16]
		jmp case_end
		case_Dead:
			mov eax, [ebx + 20]
		jmp case_end
		case_Grid:
			mov eax, [ebx + 24]
		jmp case_end
		case_Padding:
			mov eax, [ebx + 28]
		jmp case_end

		case_default:
		mov eax, 0
		case_end:
		
	ret
s_WM_CTLCOLORSTATIC_ endp
;ThisUtils
lpToColRow proc lp:DWORD

		mov eax, lp
		and eax, 0FFFFh
		sub eax, gridPadding
		xor edx, edx
		div gridCellSize
		mov ebx, eax
		
		mov eax, lp
		shr eax, 10h
		sub eax, gridPadding
		xor edx, edx
		div gridCellSize

	ret
lpToColRow endp
;Utils
Min proc num1:DWORD, num2:DWORD
		
		mov eax, num2
		cmp eax, num1
		jg @F
			ret
		@@:
			mov eax, num1
		
	ret
Min endp
Max proc num1:DWORD, num2:DWORD
		
		mov eax, num2
		cmp eax, num1
		jl @F
			ret
		@@:
			mov eax, num1
		
	ret
Max endp
StringEqual proc str1:DWORD, str2:DWORD

		cld
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
StringEqual endp
StringLength proc uses edi ecx str1:DWORD

		cld
		mov ecx, 0FFFFFFFFh
		mov al, NULL
		mov edi,str1
		repne scas byte ptr [edi]
		mov eax, 0FFFFFFFFh
		sub eax, ecx
		
	ret
StringLength endp
MemoryFill proc uses edi pMem:DWORD, cbSize:DWORD, fill:BYTE

		cld
		mov ecx, cbSize
	    mov ah, fill
	    mov al, fill
	    shl eax, 16
	    mov ah, fill
	    mov al, fill
	    shr ecx, 2
	    jz @F
	    mov edi, pMem
	    rep stosd dword ptr [edi]
	    @@:
	    mov ecx, cbSize
	    and ecx, 3
	    jz @F
	    rep stosb byte ptr [edi]
	    @@:
	    
	ret
MemoryFill endp
MemoryCopy proc uses ecx edi esi pDest:DWORD, pSrc:DWORD, cbSize:DWORD

		cld
		mov ecx, cbSize
		shr ecx, 2
		jz @F
	    mov edi, pDest
	    mov esi, pSrc
	    rep movsd
	    @@:
	    mov ecx, cbSize
	    and ecx, 3
	    jz @F
	    rep movsb
	    @@:

	ret
MemoryCopy endp
end start