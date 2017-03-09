%include "linux64.inc"
global main
extern system
section .data
	regiszero db "$zero"
	regis db "$at,$v0,$v1,$a0,$a1,$a2,$a3,$t0,$t1,$t2,$t3,$t4,$t5,$t6,$t7,$s0,$s1,$s2,$s3,$s4,$s5,$s6,$s7,$t8,$t9,$k0,$k1,$gp,$sp,$fp,$ra"
	instruc db "add addi addu and andi beq bne j jal jr lw nor or ori slt slti sltiu sltu sll srl sub subu mult mflo sw "
	enteer db "",0xa
	coma db ","
	par1 db "("
	par2 db ")"	
	filename db "ROM.txt",0
	;filename2 db "gggg.txt",0
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
	msj1 db "Presione Enter para salir:",0xa
	lmsj1: equ $- msj1
	int1: db "Jorge Jimenez Mora       2014085036",0xa
	len1: equ $-int1
	int2: db "Jose Hernandez Castro    2014086307",0xa
	len2: equ $-int2
	int3: db "Gabino Venegas Rodriguez 2014013616",0xa,0xa
	len3: equ $-int3
	msjdirec db "direccion invalida ",0xa
	lmsjdirec equ $- msjdirec
	msjfun db "funcion invalido ",0xa
	lmsjfun equ $- msjfun
	msjopcode db "opcode invalido ",0xa
	lmsjopcode equ $- msjopcode
	msjdrinv db "direccion de memoria invalida",0xa
	lmsjdrinv: equ $-msjdrinv
	
	cadena:  db "lscpu | grep ID ; lscpu | grep name ; lscpu | grep Fam ; lscpu | grep Ar ; ps -C emulador -o %cpu,%mem,cmd",0xa 

section .bss
	text resb 4950 ;rom
	mem resb 600   ;memoria de programa
	data resb 800 ;memoria de datos y stack unidos 0-400 memoria 401-800 stack
	laweva resb 400 ; A JORGE LE DA MIEDO QUE SU CODIGO CAIGA xd
	reg resb 128    ;banco de registros
	tecla resb 16
	PC resb 4      ;registro para pc
	frs resb 8
	prueba resb 4 
section .text
main:
	mov dword [PC], 0
	mov dword [reg+0],0
	mov dword [reg+116],800d
	mov dword [reg+192],1d
	mov dword [reg+196],2d
	mov dword [reg+200],3d
	mov dword [reg+204],4d
	mov dword [reg+208],5d
	mov dword [reg+212],6d
	mov dword [reg+216],7d
	mov dword [reg+220],8d
	mov dword [reg+16],8d
	mov dword [reg+20],8d
	mov dword [reg+31],600d
;-----------------------------------------------INPRIMO EL MENSAJE DE BIENVENIDA-----------------------------------------------

;------------------------------se crea el resultado.txt para guardar los datos de pantalla	
	;mov rax, 2
	;mov rdi, filename2
	;mov rsi,64 + 1
	;mov rdx,0644o
	;syscall
;------------------------------------------------------------
;--------------imprime la bienvenida------------
	mov rdi, 1					; sys write
	mov rax, 1
	mov rsi, welcome				;Bienvanido al emulador MIPS
	mov rdx, lwelcome				;tamaño del mensaje
	syscall


	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, bienv2					;codigo del curso
	mov rdx, lbienv2				;tamaño del codigo del curso
	syscall

	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, bienv3					;semestre y año
	mov rdx, lbienv3				;tamaño del semestre
	syscall

	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, busqR					;buscando ROM.txt
	mov rdx, lbusqR					;tamaño de buscando ROM
	syscall


;-----------------------------------------------OBTENCION Y ESCRITURA DE LA ROM------------------------------------------------
;----------funcion para abrir el doc-------------------
	mov rax, 2 					;sys open
	mov rdi, filename				;nombre de la ROM
	mov rsi, 0 					;bandera de solo lectura
	mov rdx, 0
	syscall

;----------funcion para leer el doc--------------------
	push rax
	mov rdi, rax
	mov rax, 0 					; sys read
	mov rsi, text	
	mov rdx, 4950
	syscall
;----------si no se encuentra la rom se sale-----------
	mov r14,[text]
	cmp r14,0
	je salida
;----------imprime ROM encontrada----------------------
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, RFind
	mov rdx, lRFind
	syscall


;------------muestra buscando archivo rom---------------
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, msj					;presione entre para continuar
	mov rdx, lmsj					;tamaño del mensaje
	syscall
;-----para reconocer el enter----
	mov rax,0
	mov rdi,0
	mov rsi,tecla					;resibe la entrada, no importa si se escribe basura
	mov rdx, 16					;permite 16 char de basura antes de presionar enter
	syscall


;funcion para cerrar el doc
	mov rax, 3 					; sys close
	pop rdi
	syscall

;--------------------------------------OBTENCION DE LAS FUNCIONES MIPS A PARTIR DE LA ROM---------------------------------------- 
;funcion para llenar mem

	mov r8, 0					;contador de chars
	mov r13, 33					;comparador 
	mov r10, 32					;comparador
	mov r11, 0ffffffffffffffffh			;registro llenos de 1 para copiar la instruccion

loop:	
	mov r9b, [text + r8]				;mover el primer char del txt a el registro r9
	cmp r9b, 31h					;49 (comparo si es un 1)
	jne enter					;sino es igual brinca al enter
	rol r11, 1					;rota el registro r9 para agregar un 1 
	add r8,1					;sumo al contador de chars
	cmp r8, r13					;compare si ya llego a 33(r13)
	jne loop					;sino es igual vuelva a realizar lo anterior
	jmp sigue					;si ya llego brinca a sigue
	
enter:	
	cmp r9b,10d					;compara si el char leido es un enter
	jne cero					;sino es un enter brinca a cero
	add r8, 1					;sumo al contador de chars
	cmp r8, r13 					;compare si ya llego a 33(r13)
	jne loop					;repita lo mismo
	jmp sigue					;brinque a sigue si ya termino

cero:
	shl r11,1					;haga un shift para agregar un cero
	add r8,1					;sumo al contador de chars
	cmp r8, r13					;compare si ya llego a 33(r13)
	jne loop					;repita lo mismo

sigue:
	mov r12, r10					;guarda un 32 en r12
	shr r12, 3					;multiplico 32*4
	add r12,-4					;resto 4 r12=(32*4)-4
	mov dword [mem+r12], r11d			;guarda la instruccion copiada en la memoria de programa
	add r10,32					;sumo un 32 para cambiar de linea en la memoria de rom
	add r13, 33					;sumo un 33 para cambiar de linea en la rom
	mov r11, 0ffffffffffffffffh			;reinicio de nuevo el registro base
	cmp r10, 3200					;compara si ya termine de leer la rom
	jne loop					;sino repita el proceso 

;------------------------------------------------IDENTIFICACION DE LA INSTRUCCION MIPS--------------------------------------------------------

;--------------------------------------------------------------loop principal del pc counter -------------------
lop:
	mov r8,[PC]					;Optengo el PC 
	mov r9d,[mem+r8]
	cmp r9d,0
	je sis
	call opcode					;llama la funcion de opcode para saber el tipo de instruccion MIPS (R,I,J)
	cmp r10d,0					;Compara si es cero de ser asi es una tipo R
	je Rformat					;brinca a las instrucciones tipo R
	cmp r10d,2h					;compara si el opcode es del J
	je j						;brinca a la instruccion jump
	cmp r10d,3h					;compara si el opcode es del 
	je jaal						;brinca a la funcion jump and link
	jmp Iformat					;brinca a las instrucciondes tipo I				
casi:							;Funcion de PC+4
	mov eax,[PC]					;Optengo el valor actual del PC					
	add eax,4					;sumo 4 a ese valor
	mov dword [PC],eax				;guardo el PC actualizado	
	cmp eax,600					;comparo si ya termino de recorrer la memoria del programa
	mov r8d ,[reg+8]
	jne lop						;brinco a lop para realizar la siguiente instruccion MIPS
	
;------------------------------------------------------------Imprecion del mensaje de salida---------------------------------------
salida:
	mov r8,[PC]					;muevo lo que hay en PC a r8				
	cmp r8,0
	jne sis
	
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, RNoFind
	mov rdx, lRNoFind
	syscall
	

sis:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, enteer
	mov rdx, 1
	syscall

	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, msj1
	mov rdx, lmsj1
	syscall
	


	mov rdi, 0					; sys write	
	mov rax, 0	
	mov rsi, tecla
	mov rdx, 16
	syscall


	mov rdi, 1; sys write
	mov rax, 1
	mov rsi, int1
	mov rdx, len1
	syscall



	mov rdi, 1; sys write
	mov rax, 1
	mov rsi, int2
	mov rdx, len2
	syscall




	mov rdi, 1; sys write
	mov rax, 1
	mov rsi, int3
	mov rdx, len3
	syscall

	;mov rax, 3
	;pop rdi
	;syscall

	push rbp                                     
	mov rbp, rsp                                
	mov rdi, cadena                             
	call system                                                      
	 
	jmp _salir
;--------------------------------------------------------------salir del programa (el loop es muy raro XD)
invfun:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, msjfun
	mov rdx, lmsjfun
	syscall
	jmp _salir


invopcode:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, msjopcode
	mov rdx, lmsjopcode
	syscall
	jmp _salir

drinv: 
	mov rdi, 1				; sys write	
	mov rax, 1
	mov rsi, msjdrinv
	mov rdx, lmsjdrinv
	syscall
	nop
	jmp _salir
_salir:	
	                
	mov rax, 60					;sys_exit
	mov rdi, 0
	syscall
;-------------------------------------------------codigo para escribir las instrucciones ejecutadas--------------------------


_register:
	cmp r9d,0
	je zz
	mov r15d,r9d
	shl r15,2
	sub r15,4
	mov rcx,regis
	add rcx,r15
	mov rdi, 1					; sys write
	mov rax, 1
	mov rsi, rcx
	mov rdx, 3
	syscall
	ret
zz:
	mov rdi, 1					; sys write
	mov rax, 1
	mov rsi, regiszero
	mov rdx, 5
	syscall
	ret



;--------------------------------------------------------------funciones para la decodificacion de la instruccion

opcode:
	mov r8,[PC]					;Optengo el PC 
	mov r9d,[mem+r8]				;Me muevo en la memoria de programa con el offset del PC	
	shr r9d,26					;Realizo un corrimiento a la derecha para dejar unicamente el valor del OPCODE
	and r9d,63					;limpio el resto del registro por si acaso.
	mov r10d,r9d					;guardo el OPCODE en r10d
	ret						;regreso donde se llamó

rs:
	mov r8,[PC]					;Optengo el PC
	mov r9d,[mem+r8]				;Me muevo en la memoria de programa con el offset del PC	
	shr r9d,21					;corrimiento a la derecha para dejar el valor del RS en lo mas significativo
	and r9d,31					;limpio el resto del registro a partir del 5bit dejando solo rs
	call _register
	shl r9d,2					;multiplico RS por 4 para direccionar bytes en memoria				
	mov r12d,[reg+r9d]				;extraigo el valor continido en la direccion de memoria correspondiente a RS
	cmp r12d,7fffh
	jge extrs	
	ret						;regreso donde se llamó

extrs: 
	mov rax,0ffffffffffff0000h			;carga la extension de signo en r15
	or r12,rax					;aplica la extension
	ret
rt:
	mov r8,[PC]					;Optengo el PC 
	mov r9d,[mem+r8]				;Me muevo en la memoria de programa con el offset del PC	
	shr r9d,16					;corrimiento a la derecha para dejar el valor del RT en lo mas significativo
	and r9d,31					;limpio el resto del registro a partir del 5bit dejando solo RT	
	call _register	
	shl r9d,2					;multiplico RT por 4 para direccionar bytes en memoria				
	mov r13d,[reg+r9d]				;extraigo el valor contenido en la direccion de memoria correspondiente a RT
	cmp r13d,7fffh
	jge extrt	
	ret						;regreso donde se llamó
extrt: 
	mov rax,0ffffffffffff0000h			;carga la extension de signo en r15
	or r13,rax					;aplica la extension
	ret
rd:
	mov r8,[PC]					;Optengo el PC 
	mov r9d,[mem+r8]				;Me muevo en la memoria de programa con el offset del PC
	shr r9d,11					;corrimiento a la derecha para dejar el valor del RD en lo mas significativo
	and r9d,31					;limpio el resto del registro a partir del 5bit dejando solo RD
	call _register			
	shl r9d,2					;multiplico RT por 4 para direccionar bytes en memoria
	cmp r9d,0					;compara con $zero
	je casi						;brinca pc+4 xq $zero no se puede modificar 
	mov r11d,r9d					;guardo el valor obtenido en r11d
	ret						;regreso donde se llamó


sham:
	mov r8,[PC]					;Optengo el PC 
	mov r9d,[mem+r8]				;Me muevo en la memoria de programa con el offset del PC
	shr r9d,6					;corrimiento a la derecha para dejar el valor del RD en lo mas significativo
	and r9d,31					;limpio el resto del registro a partir del 5bit dejando solo SHAM
	mov r14d,r9d					;guardo el valor obtenido en r14d
	ret						;regreso dende me llamo

func:
	mov r8,[PC]					;Optengo el PC 
	mov r9d,[mem+r8]				;Me muevo en la memoria de programa con el offset del PC
	and r9d,63					;limpio el resto del registro a partir del 6bit dejando solo SHAM
	mov r15d,r9d					;guardo el valor obtenido en r15d
	ret						;regreso dende me llamo
imm:
	mov r8, [PC]					;Optengo el PC 
	mov r9d,[mem+r8]				;Me muevo en la memoria de programa con el offset del PC
	and r9d,65535					;enmascaro unicamente los 16 bits del IMMEDITE
	cmp r9d,07fffh					; compararacion para saber si es negativo
	jge ext						;si es negativo aplica extension de signo
volver:
	mov r13, r9					;guardo el immedite en r13d
	ret						;regreso donde me llamo
ext: 
	mov r11,0ffffffffffff0000h			;carga la extension de signo en r15
	or r9,r11					;aplica la extension
	jmp volver
	
address:
	mov r8, [PC]					;optengo el PC
	mov r9d,[mem+r8]				;Me muevo en la memoria de programa con el offset del PC
	and r9d,03ffffffh				;enmascaro unicamente los 26 bits del address
	mov r13d, r9d					;guardo el address en r13d
	ret						;regreso donde se llamo
	
	
;------------------------------------------------------- define cual funcion r se ejecuta
Rformat:
	call func
	cmp r15d, 20h					;funcion del add
	je add						;brinca al add
	cmp r15d, 0h					;funcion del sll
	je sll						;brinca al sll
	cmp r15d, 25h					;funcion del or
	je or						;brinca al or
	cmp r15d, 27h					;funcion del nor
	je nor						;brinca al nor
	cmp r15d, 02h					;funcion del srl
	je srl						;brinca al srl
	cmp r15d, 22h					;funcion del sub
	je sub						;brinca al sub
	cmp r15d, 18h					;funcion del mult
	je mult						;brinca al mult
	cmp r15d, 08h					;funcion del jr
	je jr						;brinca jr
	cmp r15d, 2ah					;funcion del slt
	je slt						;brinca a slt
	cmp r15d, 12h					;funcion del mflo
	je mflo						;brinca a mflo	
	cmp r15d,21h
	je addu
	cmp r15d,23h
	je subu
	cmp r15d,2bh
	je sltu
	jmp invfun					;inidica function invalido


;--------------------------------------------------------define cual funcion i se ejecuta
Iformat:
	call opcode
	cmp r10d, 8h					;opcode del addi
	je addi						;brinque al addi
	cmp r10d, 0ch					;opcode del andi
	je andi						;brinca al andi
	cmp r10d, 0dh					;opcode del ori
	je ori						;brinca al ori
	cmp r10d, 4h					;opcode del beq
	je beq						;brinca al beq
	cmp r10d, 5h					;opcode del bne
	je bne						;brinca al bne
	cmp r10d, 23h					;opcode del lw
	je lw						;brinca al lw
	cmp r10d, 0ah					;opcode del slti
	je slti						;brinca al slti
	cmp r10d, 02bh					;opcode del sw
	je sw						;brinca al sw
	cmp r10d, 0bh
	je sltiu
	jmp invopcode					;indica qeu el opcode es invalido


;------------------------------------------------------- funciones emulades de mips
add:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, instruc
	mov rdx, 4
	syscall
	
	call rd						;Llamo a RT
	mov r14,r11
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall	

	call rs						;Llamo a rd	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall
	call rt						;llamo a RS
	add r12,r13					;sumo los datos optenidos en RS y RT

	mov dword [reg+r14],r12d			;guard la operacion de suma en el registro RD
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, enteer
	mov rdx, 1
	syscall
	
	jmp casi					;Voy a la parte de codigo donde hago PC+4

sll:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, instruc+74
	mov rdx, 4
	syscall
	
	call rd						;llamo RD
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall		
	
	call rt						;Llamo a RT
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall

	call sham					;Llamo a SHAM
	mov cl, r14b					;muevo la cantidad de corrimientos a CL
	shl r13d,cl					;realizo el corrimiento

	mov dword [reg+r11d],r13d			;Guardo el dato operado en la direccion del RD
	printVal r14

	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, enteer
	mov rdx, 1
	syscall

	jmp casi					;Voy a la parte de codigo donde hago PC+4

or:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, instruc+47
	mov rdx, 3
	syscall
	
	call rd						;llamo a RD
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall	

	call rs						;llamo a RS
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall	

	call rt						;llamo a RT
	
	mov dword [reg+r11d],r12d			;guard la operacion de suma en el registro RD
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, enteer
	mov rdx, 1
	syscall
	
	or r12,r13					;realizo la or con los dos registros
	mov dword [reg+r11d],r12d			;Guardo el dato operado en la direccion del RD
	jmp casi					;Voy a la parte de codigo donde hago PC+4

nor:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, instruc+43
	mov rdx, 4
	syscall

	call rd						;llamo RD	
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall	

	call rs						;Llamo a RS
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall

	call rt						;Llamo a RT
	or r12,r13					;realizo la or con los datos obtenidos por RS y RT
	not r12						;niego la operacion or

	mov dword [reg+r11d],r12d			;Guardo el dato operado en la direccion del RD
	
	mov dword [reg+r11d],r12d			;guard la operacion de suma en el registro RD
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, enteer
	mov rdx, 1
	syscall
	
	
	jmp casi					;Voy a la parte de codigo donde hago PC+4

srl:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, instruc+78
	mov rdx, 4
	syscall

	call rd						;llamo RD

	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall

	call rs						;Llamo a RS

	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall

	call rt						;Llamo a RT
	mov dword [reg+r11d],r12d			;guard la operacion de suma en el registro RD
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, enteer
	mov rdx, 1
	syscall

	mov cl, r13b					;muevo el dato a correr a cl
	shr r12d, cl					;realizo el corrimiento

	mov dword [reg+r11d],r12d			;Guardo el dato operado en la direccion del RD
	jmp casi					;Voy a la parte de codigo donde hago PC+4

sub:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, instruc+82
	mov rdx, 4
	syscall
	
	call rd

	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall

	call rs						;Llamo a RS
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall

	call rt						;Llamo a RT
	
	mov dword [reg+r11d],r12d			;guard la operacion de suma en el registro RD
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, enteer
	mov rdx, 1
	syscall

	sub r12,r13

	mov dword [reg+r11d],r12d
	jmp casi					;Voy a la parte de codigo donde hago PC+4

addi:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, instruc+4
	mov rdx, 5
	syscall

	call rt						;llamo a RT

	mov r14,r9
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall

	call rs						;Llamo a RS
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall

	call imm					;Llamo a IMMEDITE

	add r12, r13					;sumo el registro con el valor ingresado
	mov dword [reg+r14d],r12d			;guard la operacion de suma en el registro RD

	printVal r13
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, enteer
	mov rdx, 1
	syscall

	jmp casi					;Voy a la parte de codigo donde hago PC+4

andi:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, instruc+18
	mov rdx, 5
	syscall

	call rt						;llamo a RT
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall
	
	call rs						;Llamo a RS

	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall
	
	call imm					;Llamo a IMMEDITE
	and r12, r13					;realizo la and con el dato ingresado
	mov dword [reg+r9d], r12d			;rt=rs + imm
	
	printVal  r13	
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, enteer
	mov rdx, 1
	syscall

	jmp casi					;Voy a la parte de codigo donde hago PC+4

ori:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, instruc+50
	mov rdx, 5
	syscall

	call rt						;llamo a RD

	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall

	call rs						;Llamo a RS
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall
	
	call imm					;Llamo a IMMEDITE
	or r12,r13					;aplico el or con el dato ingresado

	mov dword [reg+r9d],r12d 			;rt=rs or imm			

	printVal r13

	mov rax, 1
	mov rsi, enteer
	mov rdx, 1
	syscall	
	
	jmp casi					;Voy a la parte de codigo donde hago PC+4

jr:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, instruc+37
	mov rdx, 3
	syscall

	call rs						;Llamo a RS
	
	mov dword [PC],r12d 				;rt=rs or imm----muevo la direccion contenida en $ra al PC
	mov rax, 1
	mov rsi, enteer
	mov rdx, 1
	syscall	
	
	jmp lop;						;a lop sin hacer PC+4

slt:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, instruc+54
	mov rdx, 4
	syscall

	call rd						;Llamo a RD

	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall

	call rs						;Llamo a RS
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall


	call rt						;Llamo a RT

	cmp r12,r13					;comparo lo contenido en RD y RT
	jl poneuno					;si se cumple voy a agregar un 1
	mov dword [reg+r11d], 0					;pongo 0 si la condicion no se cumple
	
	mov rdi,1		
	mov rax, 1
	mov rsi, enteer
	mov rdx, 1
	syscall
	
	jmp casi					;Voy a la parte de codigo donde hago PC+4
poneuno:
	mov dword [reg+r11d],1					;pongo 1 si la condicion se cumple
	mov rdi,1	
	mov rax, 1
	mov rsi, enteer
	mov rdx, 1
	syscall	
	jmp casi					;Voy a la parte de codigo donde hago PC+4

mult:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, instruc+91
	mov rdx, 5
	syscall

	call rs						;Llamo a RS

	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall

	call rt						;Llamo a RT
	imul r12,r13					;realizo la multiplicacion
	mov [prueba], r12d

	mov rdi,1	
	mov rax, 1
	mov rsi, enteer
	mov rdx, 1
	syscall
	
	jmp casi					;Voy a la parte de codigo donde hago PC+4

mflo:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, instruc + 96
	mov rdx, 5
	syscall

	call rd						;Llamo a RD
	mov r11d,[prueba]				;muevo el registro LOW de la multiplicacion  a RD
	
	mov rdi,1	
	mov rax, 1
	mov rsi, enteer
	mov rdx, 1
	syscall
	
	jmp casi					;Voy a la parte de codigo donde hago PC+4

j:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, instruc + 31
	mov rdx, 2
	syscall

	call address					;llamo al address
	
	shl r13d,2					;hago un corrimiento al address
	cmp r13, 600d					;compara con la mayor direccion 
	jge drinv					;inidca que la direccion no es valida
	mov dword [PC],r13d				;guardo la direccion optenida en el PC

	printVal r13
	
	mov rdi,1	
	mov rax, 1
	mov rsi, enteer
	mov rdx, 1
	syscall
		
	jmp lop						;ejecuta la instruccion 

beq:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, instruc+23
	mov rdx,4
	syscall

	call rs						;llamo a RS
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall	
	
	call rt						;Llamo a RT
	
	mov r10,r13
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall

	cmp r12,r10					;comparo r12d con r13d
	
	call imm					;optengo el immediate o direccion
	printVal r13	
	mov rdi,1	
	mov rax, 1
	mov rsi, enteer
	mov rdx, 1
	syscall
	jne casi					;brinque a casi si no se cumple la condicion 

	shl r13d, 2					;multiplico por 4 para moverme en memoria
	mov eax, [PC]					;cargo la direccion en PC
	add rax, r13					;sumo el immediate al PC
	mov dword [PC], eax				;guardo el nuevo PC
	jmp casi					;realizo un PC+4					

bne:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, instruc+27
	mov rdx,4
	syscall

	call rs
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall
	
	call rt

	mov r10,r13
	mov rdi, 1					; sys write	
	mov rsi, coma
	mov rax, 1
	mov rdx, 1
	syscall
	call imm
	printVal r13
	mov rax, 1
	mov rsi, enteer
	mov rdx, 1
	syscall

	cmp r12,r10
	je casi
	
	shl r13d, 2
	mov eax, [PC]
	add rax, r13
	mov dword [PC], eax
	jmp casi
lw:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, instruc+40
	mov rdx,3
	syscall

	call rt						;llama rt
	mov r14,r9
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall

	call imm					;llama el immediate
	printVal r13	
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, par1
	mov rdx, 1
	syscall
	
	call rs						;llama rs
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, par2
	mov rdx, 1
	syscall

	add r12, r13					;los suma
	cmp r12,797
	jge drinv

	mov r11, [data+r12d]				;muev el dato a un registro

	mov dword [reg+r14d],r11d ;			;guarda en rt

	mov rdi,1	
	mov rax, 1
	mov rsi, enteer
	mov rdx, 1
	syscall	
	jmp casi
sw:
	mov r8,[reg+116]
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, instruc+101
	mov rdx,3
	syscall

	call rt						;llama rt
	mov r10,r13
_lol:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx, 1
	syscall
	
	call imm					;llama el immediate
_wow:	
	printVal r13

	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, par1
	mov rdx, 1
	syscall

	call rs					;llama rs
	add r12, r13					;los suma		
_dota:	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, par2
	mov rdx, 1
	syscall


	cmp r12,797
	jge drinv
	
	mov dword [data+r12d],r10d;			;guarda rt en memoria
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, enteer
	mov rdx, 1
	syscall	
	jmp casi

jaal:	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, instruc+33
	mov rdx,4
	syscall
	
	call address					;llamo al address
	printVal r13	
	shl r13d,2					;hago un corrimiento al address
	cmp r13d, 600					;compara con la mayor direccion 
	jge drinv					;inidca que la direccion no es valida
	mov r9d,[PC]					;optengo el pc
	mov [reg+124],r9d				;guardo el pc actual en el $ra registro 31 
	mov dword [PC],r13d				;guardo la direccion optenida en el PC
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, enteer
	mov rdx,1
	syscall	

	jmp lop						;va a la direccion 

slti:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, instruc+58
	mov rdx,5
	syscall

	call rt
	mov r15,r13				;Llamo a RD
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx,1
	syscall

	call rs						;Llamo a RS
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx,1
	syscall

	call imm					;Llamo a immediate

	printVal r13

	cmp r12,r13					;comparo lo contenido en RS y RT
	jl pone1					;si se cumple voy a agregar un 1
	mov r15d,0					;pongo 0 si la condicion no se cumple
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, enteer
	mov rdx,1	
	jmp casi					;Voy a la parte de codigo donde hago PC+4
pone1:
	
	mov r15d,1				 	;pongo 1 si la condicion se cumple
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, enteer
	mov rdx,1
	syscall	
	jmp casi					;Voy a la parte de codigo donde hago PC+4

sltu:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, instruc+69
	mov rdx,5
	syscall	

	call rd

	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx,1
	syscall	
	
	call rs
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx,1
	syscall

	call rt
	
	cmp r12,r13
	jl pone11
	mov dword [reg+r11d],0
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, enteer
	mov rdx,1
	syscall	
		
	jmp casi
pone11:
	mov dword [reg+r11d],0
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, enteer
	mov rdx,1
	syscall
	jmp casi
sltiu:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, instruc+63
	mov rdx,6
	syscall

	call rt
	
	mov r10,r9
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx,1
	syscall
	
	call rs
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx,1
	syscall
	
	call imm
	
	printVal r13
	
	cmp r12,r13
	jl pone1
	mov dword [reg+r10d],0
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, enteer
	mov rdx,1
	syscall
	jmp casi
subu:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, instruc+86
	mov rdx,5
	syscall

	call rd
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx,1
	syscall
	
	call rs
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx,1
	syscall
	
	call rt
	
	mov dword [reg+r11d],r12d
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, enteer
	mov rdx,1
	jmp casi
	syscall
addu:
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, instruc+9
	mov rdx,1
	syscall
	
	call rt
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, coma
	mov rdx,1
	
	call rs
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi,coma
	mov rdx,1
	
	call rd
	
	add r12,r13
	mov dword [reg+r11d],r12d
	
	mov rdi, 1					; sys write	
	mov rax, 1
	mov rsi, enteer
	mov rdx,1
	syscall
	jmp casi

	
;00001000000000000000000000001100

;00100011101111011111111111111000
;00100000100010001111111111111111
;10101111101010000000000000000000
;10101111101111110000000000000100
;00010100100000000000000000000011
;00000000000000000001000000100000
;00100011101111010000000000001000
;00000011111000000000000000001000
;00000000000010000010100000100000
;00001100000000000000000000000000
;10001111101010000000000000000000
;00000000000010000100100100000000
;00000000100010010100100000100000
;10001101001010100000000000000000
;00000000010010100001000000100000
;10001111101111110000000000000100
;00100011101111010000000000001000
;00000011111000000000000000001000
	
;00000000010010100001000000100000
