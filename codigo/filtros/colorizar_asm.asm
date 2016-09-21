section .data
DEFAULT REL

; void colorizar_asm (
; 	unsigned char *src,
; 	unsigned char *dst,
; 	int cols,
; 	int filas,
; 	int src_row_size,
; 	int dst_row_size,
;   float alpha
; );

; Parámetros:
; 	rdi = src
; 	rsi = dst
; 	rdx = cols
; 	rcx = filas
; 	r8 = src_row_size
; 	r9 = dst_row_size
;   xmm0 = alpha


section .text

global colorizar_asm
colorizar_asm:
	; ;; TODO: Implementar
	; ;; iDEAS:
	; ;; tener tres punteros,
	; ;; recorrer desde segunda y hasta anteultima fila y columna
	; ;; sacar maximo de componentes 1 a 1
	; ;; asignar valores de Fi_comp
	; ;; setear destino

	 push rbp
	 mov rbp, rsp
	 push rbx
	 push r12

	 	;busco cantidad de ciclos
	 	sub rcx, 2 				; rcx = filas -2
	 	mov rax, rcx			; rax = filas a recorrer 
	 	mul rdx 				; rax = (filas -2) * cols 
	 	mov rcx, rax
	 	shr rcx, 2 				; rcx = cantidad de veces a ciclar 
	 	;armo punteros 
	 	mov rax, r8 	  		; rax = tam fila 
	 	shl rax, 2 				; rax = tam fila en bytes
	 	lea rbx, [rdi + rax]	; rbx = fila i+1
	 	lea r12, [rbx + rax] 	; r12 = fila i+2
	 	lea r9,  [r9 + rax]
	 	add r9, 4				; r9  = dst_inic 
		.ciclo:
			movdqu xmm0, [rdi]	; xmm0 = src_fila_i_4pixeles
			movdqu xmm1, [rbx]	; xmm1 = src_fila_i+1_4pixeles
			movdqu xmm2, [r12]	; xmm2 = src_fila_i+2_4pixeles

			pmaxub xmm0, xmm1	; xmm0 = max(xmm0, xmm1)
			pmaxub xmm0, xmm2 	; xmm0 = max(xmm0, xmm2) => xmm0 = | MAX_B_P1 | MAX_G_P1 | MAX_R_P1 | - | .... | MAX_B_P4 | ... | - |

			movdqu xmm2, xmm0 		; xmm2 = xmm0
			movdqu xmm1, xmm0 		; xmm1 = xmm0 
			pslldq xmm0, 4		; shifteo xmm0 a la izquierda 4 bytes
			pmaxub xmm1, xmm0	; max parcial
			pslldq xmm0, 4		; de nuevo 
			pmaxub xmm1, xmm0	; maximos del primer PIXEL en primer word de xmm1 => xmm1 = | MAXIMOS | basura | basura | basura |
			
			movdqu xmm0, xmm2
			psrldq xmm0, 4
			pmaxub xmm2, xmm0
			psrldq xmm0, 4 
			pmaxub xmm2, xmm0	; maximos del SEGUNDo PIXEL en ultimo xord de xmm2 => xmm2 = | basura | basura | basura | MAXIMOS |



			movdqu xmm2, xmm1		; xmm2 = xmm1
			pslldq xmm0, 4
			pmaxub xmm1, xmm0 	; maximos del segundo pixel 



			loop .ciclo



	 pop r12
	 pop rbx
	 pop rbp
	ret

