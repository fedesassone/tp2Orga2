
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
smalltiles_asm:
	push rbp
	mov rbp, rsp
	sub rsp, 8
	push rbx
	push r12
	push r13
	pxor xmm2, xmm2
	pxor xmm0, xmm0
	mov r12, r8		
	shr r12, 1				;la mitad del ancho en bytes
	mov r9, rcx
	shr r9,  1				;cantidad de filas/2
	mov rbx, rcx
	shr rbx, 1
	mov r13,rcx
ciclo_small_alto:
	mov rcx, r13
	shr rcx, 2
ciclo_small_ancho:
	movdqu xmm1, [rdi]		; muevo 4 pixeles
	movq [rsi], xmm1		;3er cuadrante
	movq [rsi + r12], xmm1	;4to cuadrante
	mov rax, r9	
	mul r8
	movq [rsi + rax], xmm1	;2do cuadrante
	
	add rax, r12	
	movq [rsi + rax],xmm1		;1er cuadrante
	add rdi, 16
	add rsi, 8
	loop ciclo_small_ancho
	
	dec rbx
	cmp rbx, 0
	je fin_smalltiles
	
	lea rsi, [rsi + r12]
	lea rdi, [rdi + r8]
	jmp ciclo_small_alto
	
fin_smalltiles:
	mov r9, r8
	
	pop r13
	pop r12
	pop rbx
	add rsp, 8
	pop rbp
	ret
