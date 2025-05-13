#include <stdio.h>
#include <stdlib.h>






/*
this contains the code of a basic .text section that print "hello world" using
the write syscall
*/
unsigned char text[] = {
	0xb8,0x04,0x00,0x00,0x00,	// mov eax,4
	0xbb,0x01,0x00,0x00,0x00,	// mov ebx,1
	0xb9,0x76,0x80,0x04,0x08,	// mov ecx,0x08048076
	0xba,0x0c,0x00,0x00,0x00,	// mov edx,12
	0xcd,0x80,					// int 0x80
	0xb8,0x01,0x00,0x00,0x00,	// mov eax,1
	0xbb,0x00,0x00,0x00,0x00,	// mov ebx,0
	0xcd,0x80,					// int 0x80
	'h','e','l','l','o',' ','w','o','r','l','d','\n'
};





/*
this contains the ELF header of the executable. this is used to specify
to the system that the generated file is an executable one and to define
the used format. here :
ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), statically linked, no section header

check this link for more informations about ELF format :
https://en.wikipedia.org/wiki/Executable_and_Linkable_Format
*/
const unsigned char elf_header[52] = {
	0x7f, 'E', 'L', 'F',	// ELF magic number
	0x01,					// 1 for 32 bits
	0x01,					// endianness : 1 for LSB	
	0x01,					// ELF version (current is 1)
	0x00,					// target ABI : 0 for System V 
	0x00,					// OS ABI version : Linux kernel ignore this for statically linked executables

	// reserved padding bytes. currently unused
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,

	0x02, 0x00,				// executable file
	0x03, 0x00,				// x86 instruction set
	0x01, 0x00, 0x00, 0x00,	// 1 for original ELF version

	// entry point address : base program loading address (0x08048000) + offset of .text in file (0x54)
	0x54, 0x80, 0x04, 0x08,

	// header table address. Located directly after the ELF header
	0x34, 0x00, 0x00, 0x00,

	0x00, 0x00, 0x00, 0x00,	// no header table
	0x00, 0x00, 0x00, 0x00,	// no flags
	0x34, 0x00,				// size of this header : 52 bytes
	0x20, 0x00,				// size of the program header table
	0x01, 0x00,				// 1 entry in the header table

	// there is no section header tables
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00

};

/*
this contains the segment descriptor of the .text segment
check this link for more informations about ELF format :
https://en.wikipedia.org/wiki/Executable_and_Linkable_Format
*/
const unsigned char program_header[] = {
	0x01, 0x00, 0x00, 0x00,	// this is a loadable segment
	0x54, 0x00, 0x00, 0x00,	// offset of the .text segment in the file

	// address of the segment in virtual memory. this is the same that the entry address
	0x54, 0x80, 0x04, 0x08,

	// physical address of the segment for systems where this is relevant
	0x54, 0x80, 0x04, 0x08,

	0x2e, 0x00, 0x00, 0x00,	// segment size. this need to be adapted to each program
	0x2e, 0x00, 0x00, 0x00,	// segment size in memory. the difference with the precedent address is .bss size
	0x05, 0x00, 0x00, 0x00, // semgent flags : 4 (readable) + 1 (executable)
	0x00, 0x10, 0x00, 0x00	// alignment : 4kB
};



// write the ELF file.
int main(void) {
    FILE *f = fopen("hello", "wb");
    if (!f) { perror("fopen"); return 1; }
    fwrite(elf_header, sizeof(elf_header), 1, f);
    fwrite(program_header, sizeof(program_header), 1, f);
    fwrite(text, sizeof(text), 1, f);
    fclose(f);

    // do a chmod +x hello before execution
    return 0;
}
