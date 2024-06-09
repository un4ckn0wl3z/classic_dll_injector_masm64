.code

include \masm64\include64\masm64rt.inc

InjectDll proc
	; save DLL path
	mov r12, rdx	
	; open process
	mov eax, ecx
	sub rsp, 32
	invoke OpenProcess, PROCESS_CREATE_THREAD or PROCESS_VM_OPERATION or PROCESS_VM_WRITE, 0, eax
	add rsp, 32
	test rax, rax
	jz exit
	; save process handle
	mov r13, rax

	; allocate memory in target process
	sub rsp, 32
	invoke VirtualAllocEx, r13, 0, 4096, MEM_COMMIT or MEM_RESERVE, PAGE_READWRITE
	add rsp, 32
	test rax, rax
	jz exit

	; write dll
	mov r14, rax
	sub rsp, 32
	invoke WriteProcessMemory, r13, r14, r12, rv(StringLen, r12), NULL
	add rsp, 32
	test eax, eax
	jz exit

	; get proc address
	sub rsp, 32
	invoke GetProcAddress, rv(GetModuleHandleA, "kernel32"), "LoadLibraryA"
	add rsp, 32
	test rax, rax
	jz exit

	; spawn thread
	sub rsp, 32
	invoke CreateRemoteThread, r13, NULL, 0, rax, r14, 0, NULL
	add rsp, 32
	test rax, rax
	jz exit

	; close handle
	invoke CloseHandle, rax
	invoke CloseHandle, r13

	mov eax, 1
	ret			

exit:
	ret	
InjectDll endp

StringLen proc
	xor rax, rax			; prepare return value
cointerloop:				; start loop
	cmp byte ptr [rcx], 0	; compare current byte (index n) input string with 0 (null terminator)
	jz exit					; if zero then means in reach last character
	inc rax					; increase return value by 1
	inc rcx					; increase point
	jmp cointerloop			; jump to current loop
exit:						; exit
	ret						; return

StringLen endp


end