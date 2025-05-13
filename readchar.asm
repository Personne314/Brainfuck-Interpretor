section .data
	buffer db 12 dup(0)
	newline db 10
	minus db '-'

section .bss
	pollfd resb 8



section .text
global _start
_start:
read_loop:  
	call readchar
	cmp eax, 0
	je exit
	jmp read_loop




	; 1. Configurer poll
	mov dword [pollfd],  0
	mov word [pollfd+4], 1
	mov word [pollfd+6], 0

	; 2. Appel poll
	mov eax, 168       ; sys_poll
	mov ebx, pollfd
	mov ecx, 1         ; nfds
	xor edx, edx       ; timeout=0
	int 0x80

	test eax, eax
	jz read_loop       ; Pas de données
	js exit            ; Erreur

	; 3. Lire caractère
	mov eax, 3         ; sys_read
	mov ebx, 0
	mov ecx, buffer
	mov edx, 1
	int 0x80

	call print_signed_int
	test eax, eax      ; Vérifier EOF
	jz exit            ; Fin si 0 octets lus

	; 4. Afficher
	movzx eax, byte [buffer]
	call print_signed_int
	jmp read_loop

exit:
	mov eax, 0
	call print_signed_int
	mov eax, 1
	xor ebx, ebx
	int 0x80





readchar:
	; push the used registers
	push ebx
	push ecx
	push edx

	; setup pollfd for poll syscall
	mov dword [pollfd],  0
	mov word [pollfd+4], 1
	mov word [pollfd+6], 0

	; syscall to sys_poll
	mov eax, 168		; sys_poll id
	mov ebx, pollfd		; pollfd to use
	mov ecx, 1			; nfds
	mov edx, -1			; no timeout
	int 0x80

	; test poll return value
	cmp eax, 0
	jle no_data

	; syscall to read
	mov eax, 3		; read id
	mov ebx, 0		; stdin
	mov ecx, buffer	; output buffer
	mov edx, 1		; read one byte
	int 0x80
	jmp readchar_done

	; return value and register pop
no_data:
	xor eax, eax
readchar_done:
	pop edx
	pop ecx
	pop ebx
	ret




print_signed_int:
	; Sauvegarde des registres
	pusha
	
	; Vérifier si le nombre est négatif
	test eax, eax
	jns .positive
	
	; Si négatif, afficher le signe '-' et prendre la valeur absolue
	push eax                  ; Sauvegarder eax
	mov eax, 4                ; sys_write
	mov ebx, 1                ; stdout
	mov ecx, minus            ; adresse du signe '-'
	mov edx, 1                ; longueur 1
	int 0x80
	pop eax                   ; Restaurer eax
	neg eax                   ; Valeur absolue
	
.positive:
	; Conversion de l'entier en chaîne de caractères
	mov ecx, 10              ; Diviseur
	mov esi, buffer + 11     ; Pointeur à la fin du buffer
	mov byte [esi], 0        ; Terminateur null
	
.convert_loop:
	dec esi                  ; Avancer le pointeur
	xor edx, edx             ; Clear edx pour la division
	div ecx                  ; eax = eax/10, edx = eax%10
	add dl, '0'              ; Convertir le reste en caractère
	mov [esi], dl            ; Stocker le caractère
	test eax, eax            ; Vérifier si eax == 0
	jnz .convert_loop        ; Continuer si non nul
	
	; Calculer la longueur de la chaîne
	mov ecx, esi             ; Début de la chaîne
	mov edx, buffer + 12     ; Fin du buffer
	sub edx, ecx             ; edx = longueur
	
	; Appel système pour afficher la chaîne
	mov eax, 4               ; sys_write
	mov ebx, 1               ; stdout
	int 0x80
	
	; Afficher un retour à la ligne (optionnel)
	mov eax, 4               ; sys_write
	mov ebx, 1               ; stdout
	mov ecx, newline         ; adresse du retour à la ligne
	mov edx, 1               ; longueur 1
	int 0x80
	
	; Restaurer les registres
	popa
	ret