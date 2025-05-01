# Brainfuck Interpreter in Assembly

## Description

This is an assembly language implementation of a Brainfuck interpreter. Brainfuck is a minimalist esoteric programming language having only 8 commands.

## Features

- Implements all standard Brainfuck commands:
  - `>` Increment the pointer
  - `<` Decrement the pointer
  - `+` Increment the byte at the pointer
  - `-` Decrement the byte at the pointer
  - `.` Output the byte at the pointer
  - `,` Input a byte and store it at the pointer
  - `[` Jump forward if byte at pointer is zero
  - `]` Jump backward if byte at pointer is nonzero
- 30000 byte data buffer (standard Brainfuck size)
- 10000 byte source code limit

## Requirements

- Linux system (the code relies on Linux syscalls)
- nasm (Netwide Assembler) to assemble the program
- ld (GNU linker) to link the object file

## Installation

The repos contains a Makefile to build and run the program. It can be build using the following commands :
1. Assemble the program:
   ```
   nasm -f elf32 brainfuck.asm -o brainfuck.o
   ```
2. Link the object file:
   ```
   ld -m elf_i386 brainfuck.o -o brainfuck
   ```

## Usage

1. Prepare your Brainfuck program in a file
2. Give the program to the interpreter:
   ```
   ./brainfuck < program.bf
   ```

## Example

Create a file named `hello.bf` with the following content (classic "Hello World!" Brainfuck program):

```
++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.
```

Then run:
```
./brainfuck < hello.bf
```
