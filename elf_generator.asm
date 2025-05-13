global _start


section .data

	; elf header : used to specify the executable format
elf_header:
	db 0x7f, 'E', 'L', 'F'	; ELF magic number
	db 0x01					; 1 for 32 bits
	db 0x01					; endianness : 1 for LSB	
	db 0x01					; ELF version (current is 1)
	db 0x00					; target ABI : 0 for System V 
	db 0x00					; OS ABI version : Linux kernel ignore this for statically linked executables

	; reserved padding bytes. currently unused
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

	db 0x02, 0x00				; executable file
	db 0x03, 0x00				; x86 instruction set
	db 0x01, 0x00, 0x00, 0x00	; 1 for original ELF version

	; entry point address : base program loading address (0x08048000) + offset of .text in file (0x54)
	db 0x54, 0x80, 0x04, 0x08

	; header table address. Located directly after the ELF header
	db 0x34, 0x00, 0x00, 0x00

	db 0x00, 0x00, 0x00, 0x00	; no header table
	db 0x00, 0x00, 0x00, 0x00	; no flags
	db 0x34, 0x00				; size of this header : 52 bytes
	db 0x20, 0x00				; size of the program header table
	db 0x01, 0x00				; 1 entry in the header table

	; there is no section header tables
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00


	; .text section header : used to describe the code section and bss size
text_header:
	db 0x01, 0x00, 0x00, 0x00	; this is a loadable segment
	db 0x54, 0x00, 0x00, 0x00	; offset of the .text segment in the file

	; address of the segment in virtual memory. this is the same that the entry address
	db 0x54, 0x80, 0x04, 0x08

	; physical address of the segment for systems where this is relevant
	db 0x54, 0x80, 0x04, 0x08

	db 0x2e, 0x00, 0x00, 0x00	; segment size. this need to be adapted to each program
	db 0x2e, 0x00, 0x00, 0x00	; segment size in memory. the difference with the precedent address is .bss size
	db 0x05, 0x00, 0x00, 0x00	; semgent flags : 4 (readable) + 1 (executable)
	db 0x00, 0x10, 0x00, 0x00	; alignment : 4kB


; lengths of the headers
%define elf_header_len 52
%define text_header_len 32





test_code:
	db 0xb8,0x04,0x00,0x00,0x00	; mov eax,4
	db 0xbb,0x01,0x00,0x00,0x00	; mov ebx,1
	db 0xb9,0x76,0x80,0x04,0x08	; mov ecx,0x08048076
	db 0xba,0x0c,0x00,0x00,0x00	; mov edx,12
	db 0xcd,0x80				; int 0x80
	db 0xb8,0x01,0x00,0x00,0x00	; mov eax,1
	db 0xbb,0x00,0x00,0x00,0x00	; mov ebx,0
	db 0xcd,0x80				; int 0x80
	db 'h','e','l','l','o',' ','w','o','r','l','d',10
%define test_code_len 46




section .text
_start:
	mov eax, 4		; sys_write
	mov ebx, 1		; stdout
	mov ecx, elf_header
	mov edx, elf_header_len
	int 0x80

	mov eax, 4		; sys_write
	mov ebx, 1		; stdout
	mov ecx, text_header
	mov edx, text_header_len
	int 0x80

	mov eax, 4		; sys_write
	mov ebx, 1		; stdout
	mov ecx, test_code
	mov edx, test_code_len
	int 0x80

	mov eax, 1		; exit 
	xor ebx, ebx	; 0
	int 0x80
