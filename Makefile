.PHONY: all
all: brainfuck.asm
	nasm -f elf  brainfuck.asm -o brainfuck.o
	ld -m elf_i386 brainfuck.o -o brainfuck

.PHONY: run
run: all
	./brainfuck

.PHONY: clean
clean:
	rm -f brainfuck
	rm -f *.o
