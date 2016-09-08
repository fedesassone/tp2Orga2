
; Parámetros:
; 	rdi = src
; 	rsi = dst
; 	rdx = cols
; 	rcx = filas
; 	r8 = src_row_size
; 	r9 = dst_row_size


;			|			|
;	2do cuadrante	|	1er cuadrante	|
;________________________________________________
;			|			|
;	3er cuadrante	|	4to cuadrante	|

section .data
DEFAULT REL

section .text
global smalltiles_asm
smalltiles_asm:
;COMPLETAR
	push rbp
	mov rbp, rsp
	push rbx
	push r12

	mov rbx, rcx	;filas
	mov r12, rdx 	;cols
	mov rax, rbx
	mul r12
	shr rbx, 2  	;filas/2
	shr r12, 2		;cols/2
	mov rcx, rax 
	shr rcx, 3


ciclo_smalltiles:
	cmp rdx, 0
	jne misma_fila 					;se termino la fila del src
	mov rax, r8
	shr rax, 1	
	lea rsi, [rsi + rax]  				;[rsi + src_row_size/2] = principio proxima fila
misma_fila:
	movdqu xmm1, [rdi]
	movdqu xmm2, [rdi + 4*4]
	packusdw xmm1, xmm2
	movdqu [rsi], xmm1				;3er cuadrante
	movdqu [rsi + r12*4], xmm1			;4to cuadrante
	mov rax, rbx
	mul r8
	movdqu [rsi + rax*4], xmm1			;2do cuadrante
	lea r9, [rsi + r12*4]		
	lea r9, [r9 + rax*4] 
	movdqu [r9], xmm1				;1er cuadrante
	add rdi, 32
	sub rdx, 4
	add rsi, 16
	loop ciclo_smalltiles

	mov r9, r8
fin_smalltiles_asm:
	pop r12
	pop rbx
	pop rbp
	ret
