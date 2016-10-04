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
	 push r15
	 sub rsp, 8

	 	movdqu xmm4, xmm0		; guardo alpha 
	 	mov r12, rdi				;src 
	 	mov r9, rsi 			;dst 
	 	;busco cantidad de ciclos
	 	sub rcx, 2 				; rcx = filas -2
	 	mov rax, rcx			; rax = filas a recorrer 
	 	mul rdx 				; rax = (filas -2) * cols 
	 	mov rcx, rax
	 	shr rcx, 3 				; rcx = cantidad de veces a ciclar 
	 	;armo punteros 
	 	mov rax, r8 	  		; rax = tam fila 
	 	shl rax, 2 				; rax = tam fila en bytes
	 	lea r10, [r12 + rax]		; rbx = fila i+1
	 	lea r11, [r10 + rax] 	; r12 = fila i+2
	 	lea r9,  [r9 + rax]
	 	add r9, 4				; r9  = dst_inic 
		.ciclo:
			;punteros
			movdqu xmm0, [r8]	; xmm0 = src_fila_i_4pixeles
			movdqu xmm1, [r10]	; xmm1 = src_fila_i+1_4pixeles
			movdqu xmm2, [r11]	; xmm2 = src_fila_i+2_4pixeles
			movdqu xmm3, xmm1	; me guardo el actual ; xmm3 = |pix4 | pix3| pix2| pix1| 
			;maximos 
			pmaxub xmm0, xmm1	; xmm0 = max(xmm0, xmm1)
			pmaxub xmm0, xmm2 	; xmm0 = max(xmm0, xmm2) => xmm0 = | MAX_B_P1 | MAX_G_P1 | MAX_R_P1 | - | .... | MAX_B_P4 | ... | - |
			;pixel1
			movdqu xmm1, xmm0 		; xmm1 = xmm0 
			pslldq xmm0, 4		; shifteo xmm0 a la izquierda 4 bytes
			pmaxub xmm1, xmm0	; max parcial
			pslldq xmm0, 4		; de nuevo 
			pmaxub xmm1, xmm0	; maximos del primer y seg PIXEL en primer y seg word de xmm1 => xmm1 = | MAXIMOSp2 | maximosp1 | basura | basura |
			;fi'es
			movdqu xmm2, xmm1 		; xmm2 = xmm1
			psrldq xmm1, 12 		; xmm1 = | 0 |...| 0 | maximosp2 |
			pslldq xmm2, 4
			psrldq xmm2, 12			; xmm2 = | 0 |...| 0 | maximosp1 | 
			pxor xmm0, xmm0
			punpcklbw xmm1, xmm0	 
			punpcklwd xmm1, xmm0	; xmm1 = |maxb | maxg | maxr | tr | PIXEL 2
			punpcklbw xmm2, xmm0 	
			punpcklwd xmm2, xmm0	; xmm2 = |maxb | maxg | maxr | tr | PIXEL 1 
			
			;---- Pixel 2
			; comparaciones 
			pextrd edi, xmm1, 1 ; maxred 
			pextrd esi, xmm1, 2 ; maxgreen
			pextrd edx, xmm1, 3 ; maxblue 

			mov rbx, 1b ;	rbx = 1
			pshufd xmm4, xmm4, 0b 	; xmm4 = alpha | alpha | alpha | alpha
			pinsrd xmm4, ebx, 0b 	; xmm4 =  alpha | alpha | alpha | 0
			xor rax, rax
			not rax ; eax = -1 
			; ebx = alpha
			pxor xmm5, xmm5  		; XMM5 = 0's  
	
			.fiR:
			;float fiR = ( (maxR >= maxG && maxR >= maxB) ? 1.0 + al: 1.0 - al )
			cmp edi, esi
			jl .elseFiR
			cmp edi, edx
			jl .elseFiR
			pinsrd xmm5, ebx, 1b ; xmm5 = | 1  | 0's..
			jmp .fiG
			.elseFiR:
			pinsrd xmm5, eax, 1b ; xmm5 = | -1 | 0's.. 
			.fiG: 
			;float fiG = ( (maxR <  maxG && maxG >= maxB) ? 1.0 + al: 1.0 - al )
			cmp edi, edx
			jge .elseFiG
			cmp esi, edx
			jge .elseFiG
			pinsrd xmm5, ebx, 10b; xmm5 = ? | 1 | 0's.. 
			jmp .fiB
			.elseFiG:
			pinsrd xmm5, eax, 10b; xmm5 = ? | -1 | 0's 
			.fiB:
 			;float fiB = ( (maxR <  maxB && maxG <  maxB) ? 1.0 + al: 1.0 - al )			
 			cmp edi, edx
 			jge .elseFiB
 			cmp esi, edx
 			jge .elseFiB
 			pinsrd xmm5, ebx, 11b  ; xmm5 = ? | ? | 1 | 0	
 			jmp .sigo
 			.elseFiB:
 			pinsrd xmm5, eax, 11b ; xmm5 = ? | ? | -1 | 0 
 			.sigo:
 			cvtdq2ps xmm5, xmm5 ; xmm5 = valores a sumar en floats 
 			addps xmm5, xmm4  	; xmm5 = fiB | fiG | fiR | 0  			DEL PIXEL 2


			;---- Pixel 1
			; comparaciones 
			pextrd edi, xmm2, 1 ; maxred 
			pextrd esi, xmm2, 2 ; maxgreen
			pextrd edx, xmm2, 3 ; maxblue 
			pxor xmm6, xmm6
			
			.fiR1:
			;float fiR = ( (maxR >= maxG && maxR >= maxB) ? 1.0 + al: 1.0 - al )
			cmp edi, esi
			jl .elseFiR1
			cmp edi, edx
			jl .elseFiR1
			pinsrd xmm6, ebx, 1b ; xmm5 = | 1  | 0's..
			jmp .fiG
			.elseFiR1:
			pinsrd xmm6, eax, 1b ; xmm5 = | -1 | 0's.. 
			.fiG1: 
			;float fiG = ( (maxR <  maxG && maxG >= maxB) ? 1.0 + al: 1.0 - al )
			cmp edi, edx
			jge .elseFiG1
			cmp esi, edx
			jge .elseFiG1
			pinsrd xmm6, ebx, 10b; xmm5 = ? | 1 | 0's.. 
			jmp .fiB1
			.elseFiG1:
			pinsrd xmm6, eax, 10b; xmm5 = ? | -1 | 0's 
			.fiB1:
 			;float fiB = ( (maxR <  maxB && maxG <  maxB) ? 1.0 + al: 1.0 - al )			
 			cmp edi, edx
 			jge .elseFiB1
 			cmp esi, edx
 			jge .elseFiB1
 			pinsrd xmm6, ebx, 11b  ; xmm5 = ? | ? | 1 | 0	
 			jmp .sigo3
 			.elseFiB1:
 			pinsrd xmm6, eax, 11b ; xmm5 = ? | ? | -1 | 0 
 			.sigo3:
 			cvtdq2ps xmm6, xmm6 ; xmm6 = valores a sumar en floats 
 			addps xmm4, xmm6  	; xmm6 = fiB | fiG | fiR | 0  			DEL PIXEL 1

 			; xmm6 = fiR | fiG | fiB | 0  			DEL PIXEL 1
 			; ; xmm5 = fiR | fiG | fiB | 0  			DEL PIXEL 2

 			pxor xmm7, xmm7
 			pxor xmm1, xmm1
 			pxor xmm2, xmm2
 			punpcklbw xmm3, xmm7 ; xmm3 = |blue2 | green2 | red2 | trasp2 | blue1 | green1 | red1 | trasp1 | 	 
 			movdqu xmm1, xmm3
 			movdqu xmm2, xmm3
 			punpcklwd xmm1, xmm7 ; xmm1 = | blue1 | green1 | red1 | transp1
 			punpckhwd xmm2, xmm7 ; xmm2 = | blue2 | green2 | red2 | transp2
 			
		;	p_d->r = ((fiR * p_sActAct->r) < 255 ?  0.5+(p_sActAct->r * fiR  ) : 255);
		;	p_d->g = ((fiG * p_sActAct->g) < 255 ?  0.5+(p_sActAct->g * fiG  ) : 255);
		;	p_d->b = ((fiB * p_sActAct->b) < 255 ?  0.5+(p_sActAct->b * fiB  ) : 255);
			

 			add r9 , 8
 			add r10, 8
 			add r11, 8 ; proceso dos pixeles cada ciclo; salto 8 bytes en cada ciclo 
 			add r12, 8

 			xor rax, rax
 			dec rcx
 			cmp rcx, rax 
 			jne .fin
			jmp .ciclo
			
			.fin:

	 add rsp, 8
	 pop r15
	 pop r14
	 pop r13
	 pop r12
	 pop rbx
	 pop rbp
	ret

