.686
option casemap:none

include \masm32\include\masm32rt.inc

FSWnd   PROTO :HWND,:UINT,:WPARAM,:LPARAM

.data 
    icc INITCOMMONCONTROLSEX <sizeof INITCOMMONCONTROLSEX,0>
    wc  WNDCLASSEX <sizeof WNDCLASSEX,NULL,FSWnd,0,0,?,?,?,COLOR_SCROLLBAR+1,NULL,szClassName,?>
    about_caption   db  "About ProjectCQB...",0
    about_message   db  "In a world of conflict, few natural resources, and little energy, what's old is new again...",13,13,10,
                        "Version 1.0 Alpha",0
    szAppName       db 'ProjectCQB',0
    szClassName     db 'ProjectCQBClass',0

.data?
    msg             MSG     <>
    updateregion    RECT    <>          ; Left, Top, Right, Bottom    
    hwndMain        HWND    ?
    dwXpos          dd      ?
    dwYpos          dd      ?

.code
start:
    ; TODO build menu, for "about", "main", and "exit"
    call    about                       ; Show about screen
    call    main                        ; Main game loop
    invoke  ExitProcess,eax             ; Exit with code returned from game loop
    
about   PROC
    invoke  MessageBox, NULL, offset about_message, offset about_caption, MB_OK
    ret
about   ENDP

FSPaint PROC    hWnd:HWND
    local   ps      :PAINTSTRUCT
    invoke  BeginPaint,hWnd,addr ps
    invoke  SetPixel,ps.hdc,dwXpos,dwYpos,0
    invoke  EndPaint,hWnd,addr ps
    ret
FSPaint ENDP

FSWnd   PROC    hWnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
    mov     eax,uMsg
    .if eax==WM_PAINT
        invoke  FSPaint,hWnd
        xor     eax,eax
    .elseif eax==WM_CREATE
        invoke  GetSystemMetrics,SM_CYSCREEN
        mov     edx,eax
        push    eax
        shr     edx,1
        mov     dwYpos,edx
        invoke  GetSystemMetrics,SM_CXSCREEN
        mov     edx,eax
        shr     edx,1
        mov     dwXpos,edx
        pop     ecx
        mov     edx,hWnd
        mov     hwndMain,edx
        invoke  SetWindowPos,edx,HWND_TOPMOST,0,0,eax,ecx,0
        xor     eax,eax
    .elseif eax==WM_KEYDOWN
        .if     wParam==VK_ESCAPE
        invoke  PostMessage,hWnd,WM_SYSCOMMAND,SC_CLOSE,NULL    ; Close full screen window
        .elseif wParam==VK_UP
        dec     dwYpos        
        .elseif wParam==VK_DOWN
        inc     dwYpos
        .elseif wParam==VK_RIGHT
        inc     dwXpos
        .elseif wParam==VK_LEFT
        dec     dwXpos
        .endif   
        ;mov     eax, dwXpos     
        ;mov     updateregion.left, eax
        ;mov     updateregion.right, eax
        ;mov     eax, dwYpos
        ;mov     updateregion.top, eax
        ;mov     updateregion.bottom, eax
        ;invoke  InvalidateRect,hWndMain,offset updateregion,FALSE
        invoke  InvalidateRect,hWnd,NULL,FALSE
        invoke  UpdateWindow,hWnd
        xor     eax,eax        
    ;.elseif eax==WM_RBUTTONUP        
    ;    xor     eax,eax
    ;.elseif eax==WM_LBUTTONUP
    ;    xor     eax,eax
    .elseif eax==WM_CLOSE
        invoke  DestroyWindow,hWnd
        xor     eax,eax
    .elseif eax==WM_DESTROY
        invoke  PostQuitMessage,NULL
        xor     eax,eax
    .else
        invoke  DefWindowProc,hWnd,uMsg,wParam,lParam
    .endif
    ret
FSWnd   ENDP

main   PROC
        invoke  InitCommonControlsEx,offset icc         ;initialize common controls
                                                        ;register the window class
        xor     edi,edi                                 ;EDI = 0
        mov     esi,offset wc                           ;ESI = offset wc
        invoke  GetModuleHandle,edi
        mov     [esi].WNDCLASSEX.hInstance,eax
        xchg    eax,ebx                                 ;EBX = wc.hInstance
        invoke  LoadIcon,ebx,501
        mov     [esi].WNDCLASSEX.hIcon,eax
        mov     [esi].WNDCLASSEX.hIconSm,eax
        invoke  LoadCursor,edi,IDC_ARROW
        mov     [esi].WNDCLASSEX.hCursor,eax
        invoke  RegisterClassEx,esi
                                                        ;create the window
        invoke  CreateWindowEx,edi,offset szClassName,offset szAppName,
                WS_POPUP or WS_VISIBLE or WS_CLIPCHILDREN,
                CW_USEDEFAULT,SW_SHOWNORMAL,edi,edi,edi,edi,ebx,edi
        invoke  UpdateWindow,eax
                                                        ;message loop
        mov     esi,offset msg                          ;ESI = msg structure address
        jmp short mLoop1
mLoop0: invoke  TranslateMessage,esi
        invoke  DispatchMessage,esi
mLoop1: invoke  GetMessage,esi,edi,edi,edi
        inc     eax                                     ;exit only
        shr     eax,1                                   ;if 0 or -1
        jnz     mLoop0                                  ;otherwise, we loop
        mov     eax,[esi].MSG.wParam
        ret
main   ENDP

end start