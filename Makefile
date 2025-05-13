.PHONY: all
all: brainfuck.asm
	nasm -f elf brainfuck.asm -o brainfuck.o
	ld -m elf_i386 brainfuck.o -o brainfuck

.PHONY: run
run: all
	./brainfuck

.PHONY: clean
clean:
	rm -f brainfuck
	rm -f *.o


elf_builder: elf_builder.c
	gcc elf_builder.c -o elf_builder

readchar: readchar.asm
	nasm -f elf readchar.asm -o readchar.o
	ld -m elf_i386 readchar.o -o readchar
