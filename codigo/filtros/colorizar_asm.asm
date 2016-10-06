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

	 push rbp
	 mov rbp, rsp
	 push rbx
	 push r12
	 push r13
	 push r14
	 push r15
	 sub rsp, 8

	 	movdqu xmm4, xmm0		; guardo alpha 
	 	mov r12, rdi			; src 
	 	mov r9, rsi 			; dst 
	 	;busco cantidad de ciclos
	 	sub rcx, 2 				; rcx = filas -2
	 	;mov rax, rcx			; rax = filas a recorrer 
	 	;mul rdx 				; rax = (filas -2) * cols 
	 	;mov rcx, rax
	 	;shr rcx, 2 				; rcx = cantidad de veces a ciclar 
	 	;armo punteros 
	 	mov rax, r8 	  		; rax = tam fila 
	 	shl rax, 2 				; rax = tam fila en bytes
	 	lea r10, [r12 + rax]	; rbx = fila i+1
	 	lea r11, [r10 + rax] 	; r12 = fila i+2
	 	lea r9,  [rsi + rax]
	 	add r9, 4

	 	 
	 	.ciclo_vertical:

	 	mov r14, rdx
	 	shl r14, 1 				; r14 = cols*2
	 	dec r14  
	 	.ciclo_horizontal:
	 		mov qword [r9], 0
			dec r14
			cmp r14, 0b
			je .continuacion
			jmp .ciclo_horizontal 	

		.continuacion:
	 	dec rcx
	 	cmp rcx, 0b
	 	je .fin

	 	; r9  = dst_inic 
		; .ciclo:
		; 	;punteros
		; 	movdqu xmm0, [r12]	; xmm0 = src_fila_i_4pixeles
		; 	movdqu xmm1, [r10]	; xmm1 = src_fila_i+1_4pixeles
		; 	movdqu xmm2, [r11]	; xmm2 = src_fila_i+2_4pixeles
		; 	movdqu xmm3, xmm1	; me guardo el actual ; xmm3 = |pix4 | pix3| pix2| pix1| 
		; 	;maximos 
		; 	pmaxub xmm0, xmm1	; xmm0 = max(xmm0, xmm1)
		; 	pmaxub xmm0, xmm2 	; xmm0 = max(xmm0, xmm2) => xmm0 = | MAX_B_P1 | MAX_G_P1 | MAX_R_P1 | - | .... | MAX_B_P4 | ... | - |
		; 	;pixel1
		; 	movdqu xmm1, xmm0 		; xmm1 = xmm0 
		; 	pslldq xmm0, 4		; shifteo xmm0 a la izquierda 4 bytes
		; 	pmaxub xmm1, xmm0	; max parcial
		; 	pslldq xmm0, 4		; de nuevo 
		; 	pmaxub xmm1, xmm0	; maximos del primer y seg PIXEL en primer y seg word de xmm1 => xmm1 = | MAXIMOSp2 | maximosp1 | basura | basura |
		; 	;fi'es
		; 	movdqu xmm2, xmm1 		; xmm2 = xmm1
		; 	psrldq xmm1, 12 		; xmm1 = | 0 |...| 0 | maximosp2 |
		; 	pslldq xmm2, 4
		; 	psrldq xmm2, 12			; xmm2 = | 0 |...| 0 | maximosp1 | 
		; 	pxor xmm0, xmm0
		; 	punpcklbw xmm1, xmm0	 
		; 	punpcklwd xmm1, xmm0	; xmm1 = |maxb | maxg | maxr | tr | PIXEL 2
		; 	punpcklbw xmm2, xmm0 	
		; 	punpcklwd xmm2, xmm0	; xmm2 = |maxb | maxg | maxr | tr | PIXEL 1 
			
		; 	;---- Pixel 2
		; 	; comparaciones 
		; 	pextrd edi, xmm1, 1 ; maxred 
		; 	pextrd esi, xmm1, 2 ; maxgreen
		; 	pextrd edx, xmm1, 3 ; maxblue 

		; 	mov rbx, 1b ;	rbx = 1
		; 	pshufd xmm4, xmm4, 0b 	; xmm4 = alpha | alpha | alpha | alpha
		; 	pinsrd xmm4, ebx, 0b 	; xmm4 =  alpha | alpha | alpha | 0
		; 	xor rax, rax
		; 	not rax ; eax = -1 
		; 	; ebx = alpha
		; 	pxor xmm5, xmm5  		; XMM5 = 0's  
		; 	cvtdq2ps xmm5, xmm5 
		; 	.fiR:
		; 	;float fiR = ( (maxR >= maxG && maxR >= maxB) ? 1.0 + al: 1.0 - al )
		; 	cmp edi, esi
		; 	jl .elseFiR
		; 	cmp edi, edx
		; 	jl .elseFiR
		; 	pinsrd xmm5, ebx, 1b ; xmm5 = | 1  | 0's..
		; 	jmp .fiG
		; 	.elseFiR:
		; 	pinsrd xmm5, eax, 1b ; xmm5 = | -1 | 0's.. 
		; 	.fiG: 
		; 	;float fiG = ( (maxR <  maxG && maxG >= maxB) ? 1.0 + al: 1.0 - al )
		; 	cmp edi, edx
		; 	jge .elseFiG
		; 	cmp esi, edx
		; 	jge .elseFiG
		; 	pinsrd xmm5, ebx, 10b; xmm5 = ? | 1 | 0's.. 
		; 	jmp .fiB
		; 	.elseFiG:
		; 	pinsrd xmm5, eax, 10b; xmm5 = ? | -1 | 0's 
		; 	.fiB:
 	; 		;float fiB = ( (maxR <  maxB && maxG <  maxB) ? 1.0 + al: 1.0 - al )			
 	; 		cmp edi, edx
 	; 		jge .elseFiB
 	; 		cmp esi, edx
 	; 		jge .elseFiB
 	; 		pinsrd xmm5, ebx, 11b  ; xmm5 = ? | ? | 1 | 0	
 	; 		jmp .sigo
 	; 		.elseFiB:
 	; 		pinsrd xmm5, eax, 11b ; xmm5 = ? | ? | -1 | 0 
 	; 		.sigo:
 	; 		cvtdq2ps xmm5, xmm5 ; xmm5 = valores a sumar en floats 
 	; 		addps xmm5, xmm4  	; xmm5 = fiB | fiG | fiR | 0  			DEL PIXEL 2


		; 	;---- Pixel 1
		; 	; comparaciones 
		; 	pextrd edi, xmm2, 1 ; maxred 
		; 	pextrd esi, xmm2, 2 ; maxgreen
		; 	pextrd edx, xmm2, 3 ; maxblue 
		; 	pxor xmm6, xmm6
		; 	cvtdq2ps xmm6, xmm6
			
		; 	.fiR1:
		; 	;float fiR = ( (maxR >= maxG && maxR >= maxB) ? 1.0 + al: 1.0 - al )
		; 	cmp edi, esi
		; 	jl .elseFiR1
		; 	cmp edi, edx
		; 	jl .elseFiR1
		; 	pinsrd xmm6, ebx, 1b ; xmm5 = | 1  | 0's..
		; 	jmp .fiG
		; 	.elseFiR1:
		; 	pinsrd xmm6, eax, 1b ; xmm5 = | -1 | 0's.. 
		; 	.fiG1: 
		; 	;float fiG = ( (maxR <  maxG && maxG >= maxB) ? 1.0 + al: 1.0 - al )
		; 	cmp edi, edx
		; 	jge .elseFiG1
		; 	cmp esi, edx
		; 	jge .elseFiG1
		; 	pinsrd xmm6, ebx, 10b; xmm5 = ? | 1 | 0's.. 
		; 	jmp .fiB1
		; 	.elseFiG1:
		; 	pinsrd xmm6, eax, 10b; xmm5 = ? | -1 | 0's 
		; 	.fiB1:
 	; 		;float fiB = ( (maxR <  maxB && maxG <  maxB) ? 1.0 + al: 1.0 - al )			
 	; 		cmp edi, edx
 	; 		jge .elseFiB1
 	; 		cmp esi, edx
 	; 		jge .elseFiB1
 	; 		pinsrd xmm6, ebx, 11b  ; xmm5 = ? | ? | 1 | 0	
 	; 		jmp .sigo3
 	; 		.elseFiB1:
 	; 		pinsrd xmm6, eax, 11b ; xmm5 = ? | ? | -1 | 0 
 	; 		.sigo3:
 	; 		cvtdq2ps xmm6, xmm6 ; xmm6 = valores a sumar en floats 
 	; 		addps xmm6, xmm4  	; xmm6 = fiB | fiG | fiR | 0  			DEL PIXEL 1


 	; 		pxor xmm7, xmm7
 	; 		pxor xmm1, xmm1
 	; 		pxor xmm2, xmm2
 	; 		punpcklbw xmm3, xmm7 ; xmm3 = |blue2 | green2 | red2 | trasp2 | blue1 | green1 | red1 | trasp1 | 	 
 	; 		movdqu xmm1, xmm3
 	; 		movdqu xmm2, xmm3
 	; 		punpcklwd xmm1, xmm7 	
 	; 		punpckhwd xmm2, xmm7 
 	; 		cvtdq2ps xmm1, xmm1
 	; 		cvtdq2ps xmm2, xmm2 	
 	; 								; xmm1 = | blue1 | green1 | red1 | transp1 	EN FLOAT 
 	; 								; xmm2 = | blue2 | green2 | red2 | transp2  EN FLOAT 
		; 			 				; xmm6 = fiB1 | fiG1 | fiR1 | 0  			DEL PIXEL 1
		; 							; xmm5 = fiB2 | fiG2 | fiR2 | 0  			DEL PIXEL 2
 	; 		mulps xmm1, xmm6 		; xmm1 = |blue1*fiB1 | ..... | 0
 	; 		mulps xmm2, xmm5 		; xmm2 = |blue2*fiB2 | ..... | 0
 	; 		mov eax, 255
 	; 		pxor xmm0, xmm0
 	; 		pinsrd xmm0, eax, 1b
 	; 		pshufd xmm0, xmm0, 1010100b    
 	; 		cvtdq2ps xmm0, xmm0 	; xmm0 = 255 en float 4 veces
 	; 		movdqu xmm8, xmm0		; xmm8 = xmm0
 	; 		movdqu xmm9, xmm0

 	; 		cmpps xmm0, xmm1, 1 	; compara si es menor 
 	; 		cmpps xmm9, xmm2, 1 	; same, pixel 2
 	; 		;pcmpeqd xmm0, xmm1		; xmm1 = (fiC * C) < 255? 255 ; 0)
 	; 		;pandn xmm0, xmm0 		; xmm0 = 255 en entero donde hay que poner 0.5 + sat
 	; 								; xmm9 = FF donde hay que poner 0.5 + sat en pixel 2
 	; 		movdqu xmm7, xmm0
 	; 		movdqu xmm10, xmm9 		
 	; 		pandn xmm10, xmm10 		; xmm10 = FF donde hay que poner 255 en float pixel 2 
 	; 		pandn xmm7, xmm7 		; xmm7 = 255 en entero donde hay que poner 255 en float  
 	; 		pand xmm1, xmm0 		; xmm1 = fiC * c donde tiene que haberlo
 	; 		pand xmm2, xmm9 		; xmm2 = fiC * C donde tiene que haberlo pixel 2  

 	; 		pinsrd xmm5, ebx, 1b
 	; 		pshufd xmm5, xmm5, 01010100b 	; xmm5 = 1 | 1 | 1 | 0
 	; 		mov eax, 10b
 	; 		pinsrd xmm6, eax, 1b 
 	; 		pshufd xmm6, xmm6, 01010100b 	; xmm5 = 2 | 2 | 2 | 0
 	; 		cvtdq2ps xmm5, xmm5 			
 	; 		cvtdq2ps xmm6, xmm6				;ambos en float
 	; 		divps xmm5, xmm6 				; xmm5= 1/2 | 1/2 | 1/2 | basura 
 	; 		mov eax, 0b
 	; 		pinsrd xmm5, eax, 0b 			;  xmm5= 1/2 | 1/2 | 1/2 | 0
 	; 		movdqu xmm6, xmm5 
 	; 		pand xmm5, xmm0 				; xmm5 = 0,5 donde tiene que haberlo 
 	; 		pand xmm6, xmm9					; pixel 2
 	; 		addps xmm5, xmm1 				; 0,5 + fi*c donde tiene que haberlo 
 	; 		addps xmm6, xmm2 				; pixel 2 

 	; 		pand xmm10, xmm8 				; 255 en float donde tiene que haber pix2
 	; 		por xmm6, xmm10 				;255 donde debe y o,5 + fi*c donde debe pixel2 
 	; 		;pxor xmm0, xmm0
 	; 		pand xmm7, xmm8 				; 255 en float donde tiene que haber 
 	; 		por xmm5, xmm7 					; 255 donde debe, y 0,5 +fi*c donde debe
 	; 		; hasta acá esta todo en float 
 	; 		;convierto a INT 
 	; 		cvtps2dq xmm5, xmm5
 	; 		cvtps2dq xmm6, xmm6
 	; 		;pack => destino es la parte BAJA
 	; 		; HAGO PACK(PIXEL2,PIXEL1) => |pixel2|pixel1| ->cada componente ocupa 2 bytes  
 	; 		packusdw xmm5, xmm6 ; double -> word 
 	; 		pxor xmm0, xmm0 
 	; 		packuswb xmm6, xmm0 ;word -> byte => cada componente ocupa un byte 
 	; 		; xmm6 = |0 | 0 | pixel2 | pixel1 

 	; 		pextrq r15, xmm6, 0b
 	; 		mov [r9], r15


		; ;	p_d->r = ((fiR * p_sActAct->r) < 255 ?  0.5+(p_sActAct->r * fiR  ) : 255);
		; ;	p_d->g = ((fiG * p_sActAct->g) < 255 ?  0.5+(p_sActAct->g * fiG  ) : 255);
		; ;	p_d->b = ((fiB * p_sActAct->b) < 255 ?  0.5+(p_sActAct->b * fiB  ) : 255);
			

 			add r9 , 8
 			add r10, 8
 			add r11, 8 ; proceso dos pixeles cada ciclo; salto 8 bytes en cada ciclo 
 			add r12, 8
;loop .ciclo_vertical
			jmp .ciclo_vertical 
			
			.fin:

	 add rsp, 8
	 pop r15
	 pop r14
	 pop r13
	 pop r12
	 pop rbx
	 pop rbp
	ret

