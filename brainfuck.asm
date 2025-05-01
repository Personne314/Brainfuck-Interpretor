global _start

	; this segment contains uninitialized data
	; this is set to 0 at the start of the program
segment .bss
	print_buffer resb 30000

	buffer resb 30000
	source resb 10000
	source_len resd 1
	index resd 1

	; this segment contains initialized data
segment .data
	source_error_str db "unable to read source file", 10
	source_error_str_len equ $-source_error_str
	bracket_error_str db "unmatched bracket error", 10
	bracket_error_str_len equ $-bracket_error_str

	; this segment contains the code
segment .text
_start:

	; reads source file
	mov eax, 3
	xor ebx, ebx
	mov ecx, source 
	mov edx, 1000
	int 0x80
	cmp eax, 0
	jl source_error
	mov [source_len], eax

	; process each character
	xor ecx, ecx
	mov edi, source
main_loop:
	cmp ecx, [source_len]
	jge end_main_loop
	mov al, [edi]

	; parse the current character
	cmp al, '>'
	je instr_inc_index
	cmp al, '<'
	je instr_dec_index
	cmp al, '+'
	je instr_inc_val
	cmp al, '-'
	je instr_dec_val
	cmp al, '.'
	je instr_out
	cmp al, ','
	je instr_in
	cmp al, '['
	je instr_jmp_open
	cmp al, ']'
	je instr_jmp_close

	; jump to the next iteration
instr_done:
	inc ecx
	inc edi
	jmp main_loop
end_main_loop:

	; exit
	mov eax, 1
	xor ebx, ebx
	int 0x80



	; execute >
instr_inc_index:
	inc dword [index]
	cmp dword [index], 30000
	jne instr_done
	mov dword [index], 0
	jmp instr_done



	; execute <
instr_dec_index:
	dec dword [index]
	cmp dword [index], 0
	jge instr_done
	mov dword [index], 29999
	jmp instr_done



	; execute +
instr_inc_val:
	mov ebx, buffer
	add ebx, [index]
	inc byte [ebx]
	jmp instr_done



	; execute -
instr_dec_val:
	mov ebx, buffer
	add ebx, [index]
	dec byte [ebx]
	jmp instr_done



	; execute .
instr_out:
	push ecx
	mov eax, 4
	mov ebx, 1
	mov ecx, buffer
	add ecx, [index]
	mov edx, 1
	int 0x80
	pop ecx
	jmp instr_done



	; execute ,
instr_in:
	push ecx
	mov eax, 3
	mov ebx, 0
	mov ecx, buffer
	add ecx, [index]
	mov edx, 1
	int 0x80
	pop ecx
	jmp instr_done



	; execute [
instr_jmp_open:
	mov ebx, buffer
	add ebx, [index]
	cmp byte [ebx], 0
	jne instr_done

	; search the matching ]
	mov eax, 1
	inc ecx
instr_jmp_open_loop:
	cmp ecx, [source_len]
	je bracket_error

	; gets the current character
	mov ebx, source
	add ebx, ecx
	mov al, [ebx]

	; increments the counter if [, derements it if ]
	cmp al, '['
	jne instr_jmp_open_not_open
	inc eax
instr_jmp_open_not_open:
	cmp al, ']'
	jne instr_jmp_open_not_close
	dec eax
instr_jmp_open_not_close:

	; detects the matching ], move edi and ecx to the next character
	cmp eax, 0
	jne instr_jmp_open_not_match
	mov edi, source
	add edi, ecx
	jmp instr_done
instr_jmp_open_not_match:
	inc ecx
	jmp instr_jmp_open_loop



	; execute ]
instr_jmp_close:
	mov ebx, buffer
	add ebx, [index]
	cmp byte [ebx], 0
	je instr_done

	; search the matching ]
	mov eax, 1
	dec ecx
instr_jmp_close_loop:
	cmp ecx, 0
	jl bracket_error

	; gets the current character
	mov ebx, source
	add ebx, ecx
	mov edx, [ebx]

	; increments the counter if ], derements it if [
	cmp dl, ']'
	jne instr_jmp_close_not_open
	inc eax
instr_jmp_close_not_open:
	cmp dl, '['
	jne instr_jmp_close_not_close
	dec eax
instr_jmp_close_not_close:

	; detects the matching [, move edi and ecx to the next character
	cmp eax, 0
	jne instr_jmp_close_not_match
	mov edi, source
	add edi, ecx
	jmp instr_done
instr_jmp_close_not_match:
	dec ecx
	jmp instr_jmp_close_loop

	; source file reading error
bracket_error:
	mov ecx, bracket_error_str
	mov edx, bracket_error_str_len
	jmp error
source_error:
	mov ecx, source_error_str
	mov edx, source_error_str_len
	jmp error
error:
	mov eax, 4
	mov ebx, 2
	int 0x80
	mov eax, 1
	mov ebx, 1
	int 0x80
