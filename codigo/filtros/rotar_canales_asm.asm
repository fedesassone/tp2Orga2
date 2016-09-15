section .data
DEFAULT REL

mask2:db 13,14,12,15, 9,10,8,12, 5,6,4,7, 1,2,0,3
section .text
global rotar_asm
; entran los parametros:
; void rotar_asm    (unsigned char *src, unsigned char *dst, int cols, int filas,
;                      int src_row_size, int dst_row_size);

; Se preservan RBX; R12, R13, R14 y R15
; Entran por, en orden: rdi, rsi, rdx, rcx, r8, r9, pila.

;rdi = 	*src
;rsi = 	*dst
;rdx = 	columnas (int)
;rcx = 	filas 	 (int)
;r8  = 	fila_tamaño_src (int)
;r9  = 	fila_ramaño_dst (int)
rotar_asm:
;COMPLETAR // por cada pixel que levanto, (levanto de a 16bytes -> 4 pixeles de 4 bytes c/u) mando:
; R->G 
; G->B
; B->R
	push rbp
	mov rbp, rsp
	push rbx
	push r12
		mov rax, rcx
		mul rdx
		mov rcx, rax
		shr rcx, 2 ; divido por 4; tengo la cantidad de veces a acceder a memoria
		.ciclo:
		movdqu xmm0, [rdi] ; src
		movdqu xmm1, [mask2]
		pshufb xmm0, xmm1
		pshufd xmm0, xmm0, 00011011b
		movdqu [rsi], xmm0
		add rdi, 16
		add rsi, 16
		loop .ciclo
		;movdqu xmm1, [rsi] ; dst 

	pop rbx	
	pop r12	
	pop rbp
	ret
