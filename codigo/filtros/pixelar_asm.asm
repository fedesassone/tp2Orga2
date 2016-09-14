; void pixelar_asm (
; 	unsigned char *src,
; 	unsigned char *dst,
; 	int cols,
; 	int filas,
; 	int src_row_size,
; 	int dst_row_size
; );

; Parámetros:
; 	rdi = src
; 	rsi = dst
; 	rdx = cols
; 	rcx = filas
; 	r8 = src_row_size
; 	r9 = dst_row_size

extern pixelar_c

global pixelar_asm

section .text
	
pixelar_asm:
	;; TODO: Implementar
	push rbp
	mov rbp, rsp
	sub rsp, 8
	push rbx
	pxor xmm7, xmm7
	mov rbx, rcx
ciclo_pixelar_alto:
	mov rcx, rdx
	shr rcx, 2
ciclo_pixelar_ancho:	
	movdqu xmm1, [rdi] 		;xmm1 = |a3|a2|a1|a0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |b3|b2|b1|b0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhdq xmm1, xmm7	;xmm1 = |0|a3|0|a2|
	punpckldq xmm2, xmm7	;xmm2 = |0|a1|0|a0|
	punpckhdq xmm3, xmm7	;xmm3 = |0|b3|0|b2|
	punpckldq xmm4, xmm7	;xmm4 = |0|b1|0|b0|

	addss xmm1, xmm3		;xmm1 = |?|a3+b3|?|a2+b2|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a3+b3|
	addss xmm1, xmm3		;xmm1 = |?|a3+b3|?|a3+b3+a2+b2|
	pslldq xmm1, 8			;xmm1 = |?|a3+b3+a2+b2|0|0|

	addss xmm2, xmm4		;xmm2 = |?|a1+b1|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a1+b1|
	addss xmm2, xmm4		;xmm1 = |?|a1+b1|?|a1+b1+a0+b0|
	pslldq xmm2, 8			;xmm2 = |?|a1+b1+a0+b0|0|0|
	psrldq xmm2, 8			;xmm2 = |0|0|?|a1+b1+a0+b0|

	addss xmm1, xmm2
	;xmm0 = |4|4|
	;divpd xmm1, xmm0
	;movdqu xmm2, xmm1
	;pshrldq xmm1, 8
	;movdqu xmm3, xmm1
	;pshlldq xmm3, 4
	;addss xmm1, xmm3

	;movdqu xmm4, xmm2
	;pshlldq xmm4, 4
	;addss xmm2, xmm4
	;movq [rsi], xmm1
	;movq [rsi + 8], xmm2
	;movq [rsi + r8], xmm1
	;movq [rsi + r8 + 8], xmm2
	add rsi, 16
	add rdi, 16
	loop ciclo_pixelar_ancho
	
	dec rbx
	cmp rbx, 0
	je fin_pixelar
	lea rdi, [rdi + r8]
	lea rsi, [rsi + r8]
fin_pixelar:
	pop rbp
	ret

