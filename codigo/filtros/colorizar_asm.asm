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
	 push r13
	 push r14

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
			;punteros
			movdqu xmm0, [rdi]	; xmm0 = src_fila_i_4pixeles
			movdqu xmm1, [rbx]	; xmm1 = src_fila_i+1_4pixeles
			movdqu xmm2, [r12]	; xmm2 = src_fila_i+2_4pixeles
			;maximos 
			pmaxub xmm0, xmm1	; xmm0 = max(xmm0, xmm1)
			pmaxub xmm0, xmm2 	; xmm0 = max(xmm0, xmm2) => xmm0 = | MAX_B_P1 | MAX_G_P1 | MAX_R_P1 | - | .... | MAX_B_P4 | ... | - |
			;pixel1
			movdqu xmm1, xmm0 		; xmm1 = xmm0 
			pslldq xmm0, 4		; shifteo xmm0 a la izquierda 4 bytes
			pmaxub xmm1, xmm0	; max parcial
			pslldq xmm0, 4		; de nuevo 
			pmaxub xmm1, xmm0	; maximos del primer y seg PIXEL en primer y seg word de xmm1 => xmm1 = | MAXIMOSp1 | maximosp2 | basura | basura |
			;fi'es
			movdqu xmm2, xmm1 
			psrldq xmm1, 12 		; xmm1 = | 0 |...| 0 | maximosp1 |
			pslldq xmm2, 4
			psrldq xmm2, 12			; xmm2 = | 0 |...| 0 | maximosp2 | 
			pxor xmm0, xmm0
			punpcklbw xmm1, xmm0	
			punpcklwd xmm1, xmm0	; xmm1 = |maxb | maxg | maxr | tr |
			punpcklbw xmm2, xmm0 	
			punpcklwd xmm2, xmm0	; xmm2 = |maxb | maxg | maxr | tr |
			;float fiR = ( (maxR >= maxG && maxR >= maxB) ? 1.0 + al: 1.0 - al )
			.fiR:
			movdqu xmm0, xmm1
			psrldq xmm0, 4
			;pmaxuw

			; psrldq xmm0, 1 		;comparo red con green
			; pmaxub xmm0, xmm1	
			; psrldq xmm0, 1
			; pmaxub xmm0, xmm1 	; comparo blue con max(red,green)
			; pcmpeqb xmm0, xmm1	; si red cumple, seteo byte13 en 1's 
			; pextrb r13, xmm0, 1101b;extraigo en r13
			; cmp r13, 1111b
			; je .sumoAlphaRed
			; jmp .restoAlphaRed
			; .fiG:

			; .sumoAlphaRed:
			; .restoAlphaRed:
			;float fiG = ( (maxR <  maxG && maxG >= maxB) ? 1.0 + al: 1.0 - al )
 			;float fiB = ( (maxR <  maxB && maxG <  maxB) ? 1.0 + al: 1.0 - al )			


			loop .ciclo


	 pop r14
	 pop r13
	 pop r12
	 pop rbx
	 pop rbp
	ret

