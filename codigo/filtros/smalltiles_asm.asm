; Parámetros:
; 	rdi = src
; 	rsi = dst
; 	rdx = cols
; 	rcx = filas
; 	r8 = src_row_size
; 	r9 = dst_row_size
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
	shr rbx, 2  	;filas/2
	shr r12, 2		;cols/2
	mov rax, rbx
	mul r12
	mov rcx, rax 
	shr rcx, 3
ciclo_smalltiles:
	movdqu xmm1, [rdi]
	movdqu xmm2, [rdi + 4*4]
	packusdw xmm1, xmm2
	movdqu [rsi], xmm1					;3er cuadrante
	movdqu [rsi + r12*4], xmm1				;4to cuadrante
	mov rax, rbx
	mul r8
	movdqu [rsi + rax], xmm1				;2do cuadrante
	mov r9, rsi
	lea r9, [r9 + r12*4]		
	lea r9, [r9 + rax] 
	movdqu [r9], xmm1					;1er cuadrante
	add rdi, 32
	loop ciclo_smalltiles
	mov r9, r8
fin_smalltiles_asm:
	pop r12
	pop rbx
	pop rbp
	ret
