; ====== Подключение WinAPI функций ======
extrn ExitProcess: PROC
extrn MessageBoxA: PROC 
extrn GetUserNameA: PROC
extrn GetComputerNameA: PROC
extrn GetTempPathA: PROC
extrn GetVersionExA: PROC 
extrn wsprintfA: PROC 

; ====== Определённые переменные ======
.data
OSVERSIONINFO struct
    dwOSVersionInfoSize dword ?
    dwMajorVersion      dword ?
    dwMinorVersion      dword ?
    dwBuildNumber       dword ?
    dwPlatformId        dword ?
    szCSDVersion        byte 128 dup(?)
OSVERSIONINFO ends

cap db 'task 7', 0
fmt db 'Username: %s',0Ah,
       'Computer name: %s', 0Ah,
       'TMP Path: %s', 0Ah,
       'OS version: %d.%d.%d', 0

szMAX_COMP_NAME EQU 16
szUNLEN EQU 257
szMAX_PATH EQU 261

; ===== Сегмент кода =====

.code

; ===== Тело программы =====

Start PROC
local _msg[1024]                 :byte,
      _username[szUNLEN]         :byte,
      _compname[szMAX_COMP_NAME] :byte,
      _temppath[szMAX_PATH]      :byte,
      _v                         :OSVERSIONINFO,
      _size                      :dword
	
	sub RSP, 8*5
	and SPL, 0F0h

	MOV _size,  szUNLEN
	LEA RCX, _USERNAME
	LEA RDX, _size
	CALL GetUserNameA

	MOV _size, szMAX_COMP_NAME
	LEA RCX, _COMPNAME
	LEA RDX, _size
	CALL GetComputerNameA
	
	MOV _size, szMAX_PATH
	LEA RCX, _size
	LEA RDX, _TEMPPATH
	CALL GetTempPathA
	
	XOR AL, AL
	MOV RCX, SIZE _v
	LEA RDI, _v
	REP STOS BYTE PTR [RDI]
	MOV _v.dwOSVersionInfoSize, SIZE _v
	LEA RCX, _v
	CALL GetVersionExA
	
	LEA RCX, _msg
	LEA RDX, fmt
	LEA R8, _USERNAME
	LEA R9, _COMPNAME
	
	LEA RAX, _TEMPPATH
	MOV [RSP + 20H], RAX  
	MOV RAX, QWORD PTR _v.dwMajorVersion
	MOV [RSP + 28H], RAX
	MOV RAX, QWORD PTR _v.dwMinorVersion
	MOV [RSP + 30H], RAX
	MOV RAX, QWORD PTR _v.dwBuildNumber
	MOV [RSP + 38H], RAX
	CALL wsprintfA

	XOR RCX, RCX
	XOR R9, R9
	LEA RDX, _msg
	LEA R8, cap
	CALL MessageBoxA
	
	XOR RCX, RCX
	CALL ExitProcess
Start ENDP
End

BOOL WINAPI GetUserNameA(
  _Out_   LPTSTR  lpBuffer,
  _Inout_ LPDWORD lpnSize
);

BOOL WINAPI GetComputerNameA(
  _Out_   LPTSTR  lpBuffer,
  _Inout_ LPDWORD lpnSize
);

DWORD WINAPI GetTempPathA(
  _In_  DWORD  nBufferLength,
  _Out_ LPTSTR lpBuffer
);

BOOL WINAPI GetVersionExA(
  _Inout_ LPOSVERSIONINFO lpVersionInfo
);

int __cdecl wsprintfA(
  _Out_ LPTSTR  lpOut,
  _In_  LPCTSTR lpFmt,
  _In_          ...
);

int WINAPI MessageBoxA(
  _In_opt_ HWND    hWnd,
  _In_opt_ LPCTSTR lpText,
  _In_opt_ LPCTSTR lpCaption,
  _In_     UINT    uType
);

VOID WINAPI ExitProcess(
  _In_ UINT uExitCode
);