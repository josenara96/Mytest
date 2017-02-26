section .data
	filename db "ROM.txt",0
	welcome db 'Bienvenido al Emulador MIPS', 0xa
	lwelcome equ $- welcome
	bienv2 db 'EL-4313-Lab. Estructura de Microprocesadores', 0xa
	lbienv2 equ $- bienv2
	bienv3 db 'Semestre 1S-2017', 0xa
	lbienv3 equ $- bienv3
	busqR: db 'Buscando ROM.txt', 0xa
	lbusqR equ $- busqR
	RNoFind: db 'Archivo ROM.txt no encontrado', 0xa
	lRNoFind: equ $- RNoFind
	RFind: db 'Archivo ROM.txt encontrado', 0xa
	lRFind: equ $- RFind
	msj db "Presione Enter para continuar:",0xa
	lmsj: equ $- msj
	int1: db "Jorge Jimenez Mora       2014085036",0xa
	len1: equ $-int1
	int2: db "Jose Hernandez Castro    2014086307",0xa
	len2: equ $-int2
	int3: db "Gabino Venegas Rodriguez 2014013616",0xa
	len3: equ $-int3

section .bss
	text resb 4950 ;rom
	mem resb 600   ;memoria de programa
	data resb 400 ;memoria de datos
	stack resb 400 ; capacidad de cien palabras
	reg resb 128    ;banco de registros
	PC resb 4      ;registro para pc
	
section .text
	global _start
_start:
	mov dword [PC], 0
	
	mov rdi, rax; sys write
	mov rax, 1
	mov rsi, welcome
	mov rdx, lwelcome
	syscall
	
;funcion para abrir el doc	
	mov rax, 2 ;sys open
	mov rdi, filename
	mov rsi, 0 ;bandera de solo lectura
	mov rdx, 0
	syscall

;funcion para leer el doc
	push rax
	mov rdi, rax
	mov rax, 0 ; sys read
	mov rsi, text
	mov rdx, 609
	syscall

;funcion para cerrar el doc
	mov rax, 3 ; sys close
	pop rdi
	syscall
 
;funcion de escritura en pantalla 
	mov rdi, rax; sys write	
	mov rax, 1
	mov rsi, text
	mov rdx, 609
	syscall
	
;funcion para llenar mem

	mov r8, 0
	mov r13, 33
	mov r10, 32
	mov r11, 0ffffffffffffffffh

loop:	
	mov r9b, [text + r8]
	cmp r9b, 31h ;49	
	jne enter
	rol r11, 1
	add r8,1
	cmp r8, r13
	jne loop
	jmp sigue
	
enter:	
	cmp r9b,10d
	jne cero
	add r8, 1
	cmp r8, r13 
	jne loop
	jmp sigue

cero:
	shl r11,1
	add r8,1
	cmp r8, r13
	jne loop

sigue:
	mov r12, r10
	shr r12, 3
	add r12,-4
	mov dword [mem+r12], r11d
	add r10,32
	add r13, 33
	mov r11, 0ffffffffffffffffh
	cmp r10, 3200
	jne loop


;loop principal del pc counter 
lop:	
	call opcode
	cmp r10d,0
	je Rformat
	jmp Iformat
casi:
	mov eax,[PC]
casii:
	add eax,4
	mov dword [PC],eax
	cmp eax,600
	jne lop

;salir del programa (el loop es muy raro XD)
	mov rax, 60; sysexit
	mov rdi, 0
	syscall

;funciones para la decodificacion de la instruccion
opcode:
	mov r8,[PC]
	mov r9d,[mem+r8]
	shr r9d,26
	and r9d,63
	mov r10d,r9d
	ret
rs:
	mov r8,[PC]
	mov r9d,[mem+r8]
	shr r9d,21
	and r9d,31
	shl r9d,2
	mov dword [reg+r9d],8
	mov r12d,[reg+r9d]
	ret
rt:
	mov r8,[PC]
	mov r9d,[mem+r8]
	shr r9d,16
	and r9d,31
	shl r9d,2
	mov dword [reg+r9d],8
	mov r13d,[reg+r9d]
	ret
rd:
	mov r8,[PC]
	mov r9d,[mem+r8]
	shr r9d,11
	and r9d,31
	shl r9d,2
	mov r11d,r9d
	ret


sham:
	mov r8,[PC]
	mov r9d,[mem+r8]
	shr r9d,6
	and r9d,31
	mov r14d,r9d
	ret
func:
	mov r8,[PC]
	mov r9d,[mem+r8]
	and r9d,63
	mov r15d,r9d
	ret
imm:
	mov r8, [PC]
	mov r9d,[mem+r8]
	and r9d,65535
	mov r13d, r9d
	ret
	
; define cual funcion r se ejecuta
Rformat:
	call func
	cmp r15d,20h
	je add
	cmp r15d, 0h
	je sll
	call func
	cmp r15d,25h
	je or
	cmp r15d, 27h
	je sll
	cmp r15d,02h
	je srl
	cmp r15d, 22h
	je sub
	jmp casi


; define cual funcion i se ejecuta
Iformat:
	cmp r10d, 8h
	je addi
	cmp r10d, 0ch
	je andi
	cmp r10d, 0dh
	je ori
	cmp r10d, 4h
	je beq
	cmp r10d, 5h
	je bne
	cmp r10d, 23d
	je lw

; funciones emulades de mips
add:
	call rs
	call rt
	add r12d,r13d
	call rd
	mov dword [reg+r11d],r12d
	jmp casi

sll:
	call rt
	call sham
	mov cl, r14b
	shl r13d,cl
	call rd
	mov dword [reg+r11d],r13d
	jmp casi

or:
	call rs
	call rt
	or r12d,r13d
	call rd
	mov dword [reg+r11d],r12d
	jmp casi

nor:
	call rs
	call rt
	or r12d,r13d
	not r12d
	call rd
	mov dword [reg+r11d],r12d
	jmp casi

srl:
	call rs
	call rt
	mov cl, r13b
	shr r12d, cl
	call rd
	mov dword [reg+r11d],r12d
	jmp casi

sub:
	call rs
	call rt
	sub r12d,r13d
	call rd
	mov dword [reg+r11d],r12d
	jmp casi

addi:
	call rs
	call imm
	add r12d, r13d
	call rt
	mov dword [reg+r9d], r12d ; rt=rs + imm
	jmp casi

andi:
	call rs
	call imm
	and r12d, r13d
	call rt
	mov dword [reg+r9d], r12d ; rt=rs + imm
	jmp casi

ori:
	call rs
	call imm
	or r12d,r13d
	call rd
	mov dword [reg+r11d],r12d ; rt=rs or imm
	jmp casi

beq:
	call rs
	call rt
	cmp r12d,r13d
	jne casi
	call imm
	shl r13d, 2
	mov eax, [PC]
	add eax, r13d
	mov dword [PC], eax
	jmp casi

bne:
	call rs
	call rt
	cmp r12d,r13d
	je casi
	call imm
	shl r13d, 2
	mov eax, [PC]
	add eax, r13d
	mov dword [PC], eax
	jmp casi
lw:
	call rs
	call imm
	add r12d,r13d
	mov r9d, [data + r12d]
	mov dword [data+r12d],5
	call rt
	mov dword [reg+r13d],r9d ;
	mov r11d, [reg + r13d]
pruebita:
	jmp casi




	











