
section .data
	filename db "ROM.txt",0
	msg1 db "bienvenido a ensamblador mips ",10
section .bss
	text resb 3200
	mem resb 400
	$zero resb 8
	$at resb 8
	$v0 resb 8
	$v1 resb 8
	$a0 resb 8
	$a1 resb 8
	$a2 resb 8
	$a3 resb 8
	$t0 resb 8
	$t1 resb 8
	$t2 resb 8
	$t3 resb 8
	$t4 resb 8
	$t5 resb 8
	$t6 resb 8
	$t7 resb 8
	$s0 resb 8
	$s1 resb 8
	$s2 resb 8
	$s3 resb 8
	$s4 resb 8
	$s5 resb 8
	$s6 resb 8
	$s7 resb 8
	$t8 resb 8
	$t9 resb 8
	$k0 resb 8
	$k1 resb 8
	$gp resb 8
	$sp resb 8
	$fp resb 8
	$ra resb 8

	
section .text
	global _start
_start:
	mov rdi, rax; sys write
	mov rax, 1
	mov rsi, msg1
	mov rdx, 576
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
	mov rdx, 576
	syscall

	;funcion para cerrar el doc
	mov rax, 3 ; sys close
	pop rdi
	syscall
 
	;funcion de escritura en pantalla 
	mov rdi, rax; sys write	
	mov rax, 1
	mov rsi, text
	mov rdx, 576
	syscall
	
	;funcion para llenar mem

	mov r8, 0
	mov r13, 66
	mov r10, 64
	mov r11, 0ffffffffffffffffh

loop:	
	mov r9b, [text + r8]
	cmp r9b, 31h ;49	
	jne enter
	rol r11, 1
prueba:
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
prueba2:
	add r8,1
	cmp r8, r13
	jne loop

sigue:
	mov r12, r10
	shr r12, 3
	add r12,-8
	mov [mem+r12], r11
	add r10,64
	add r13, 66
	mov r11, 0ffffffffffffffffh
	add r8,1
	cmp r10, 3200
	jne loop
	

	;funcion de escritura en pantalla 
	mov rdi, rax; sys write	
	mov rax, 1
	mov rsi, mem
	mov rdx, 64
	syscall

	mov rax, 60; sysexit
	mov rdi, 0
	syscall


