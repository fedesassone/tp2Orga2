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
; 	r12 = dst_row_size
;   xmm0 = alpha


section .text


;;;; | B | G | R | A | ;;;;;
;;;; Struct -> b, g, r, a;
;;;; => memoria -> | B | G | R | A |
;;;; => registros -> de más a menos significativo -> | A | R | G | B |
;;;; GDT -> {Menos significativo ..... Más significativo}

global colorizar_asm
colorizar_asm:

	 push rbp
	 mov rbp, rsp
	 push rbx
	 push r13
	 push r12
	 push r14
	 push r15
	 sub rsp, 8
	 							; LOS REGISTROS DE LOS COMENTARIOS ESTAN INVERTIDOS PARA 
	 							; FACILITAR SEGUIMIENTO EN GDT 
	 							; => xreg = | menos significativo | ... | mas significativo | 


	 	movdqu xmm4, xmm0		; guardo alpha 
		pshufd xmm4, xmm4, 0b 	; xmm4 = alpha | alpha | alpha | alpha
		xor eax, eax			; eax = 0 
		pinsrd xmm4, eax, 3 	; xmm4 =  0 | alpha | alpha | aplha 
	 	mov r12, rsi 			; r12 = dst_0_0 
	 	mov r13, rdi			; r13 = src_0_0 	 	
;busco cantidad de ciclos	 	
	 	sub rcx, 2 				; rcx = filas -2
	 	mov r11, rdx 
	 	shr r11, 1				; cols / 2   			
	 	dec r11  				; r8 = cols/2 - 1

	 	;mov r11, r8				; r11 = r8 
	 	lea r14, [r13 + r8]		; r14 = src fila i+1
	 	lea r15, [r14 + r8] 	; r15 = src fila i+2
	 	lea r12, [r12 + r8]		; r12 = dst fila 1 -> comienzo en la segunda linea de pixeles 
	 	
	 	mov r8, r11 
	 	.ciclo_vertical:
	 	mov r11, r8 				; r11 -> veces ciclar 
	 	add r12, 4 
	 	
	 	.ciclo_horizontal:
	 		
			;punteros
			movdqu xmm0, [r13]	; xmm0 = src_fila_i_4pixeles
			movdqu xmm1, [r14]	; xmm1 = src_fila_i+1_4pixeles
			movdqu xmm2, [r15]	; xmm2 = src_fila_i+2_4pixeles
			movdqu xmm3, xmm1	; xmm3 = | pix0 | pix1 | pix2 | pix3 | -> pixel's actuales a procesar 
			;maximosAlrededor 
			pmaxub xmm0, xmm1	; xmm0 = max(xmm0, xmm1) => xmm0 = maximos parciales 
			pmaxub xmm0, xmm2 	; xmm0 = max(xmm0, xmm2) => xmm0 = | maxAlrededorPix1 | maxAlrededorPix2 | 
			;maximosTotales
			movdqu xmm1, xmm0	; xmm1 = xmm0 = | parcialp0 | parcialp1 | parcialp2 | parcialp3 |
			pslldq xmm0, 4		; xmm0 = 		|  	  -		| parcialp0 | parcialp1 | parcialp2 |	
			pmaxub xmm1, xmm0	; max parcial
			pslldq xmm0, 4		; xmm0 = 		| 	  - 	| 	  - 	| parcialp0 | parcialp1 |
			pmaxub xmm1, xmm0	; xmm1 = 		|     - 	|     - 	|   maxP0	|   maxp1   | 
			
			; gdb checked0
			
			;fi'es
			movdqu xmm2, xmm1 		; xmm2 = xmm1
			psrldq xmm1, 12 		; xmm1 = | maximosp1 |...| 0 | 
			pslldq xmm2, 4
			psrldq xmm2, 12			; xmm2 = | maximosp0 |...| 0 |  
			pxor xmm0, xmm0
			punpcklbw xmm1, xmm0	 
			punpcklwd xmm1, xmm0	; xmm1 = | maxb | maxg | maxr | tr | PIXEL 1
			punpcklbw xmm2, xmm0 	
			punpcklwd xmm2, xmm0	; xmm2 = | maxb | maxg | maxr | tr | PIXEL 0 
			
			;gdb checked1 

			;seteos previos a comparaciones
			
			mov eax, -1 ;	rax = -1
			mov ebx,  1	;	rbx =  1

			;---- Pixel 2
			; comparaciones 
			pextrd edi, xmm1, 2 ; maxred 
			pextrd esi, xmm1, 1 ; maxgreen
			pextrd edx, xmm1, 0 ; maxblue 

;			pshufd xmm4, xmm4, 0b 	; xmm4 = alpha | alpha | alpha | alpha
;			pinsrd xmm4, ebx, 0b 	; xmm4 =  alpha | alpha | alpha | 0
;			xor rax, rax
;			not rax ; eax = -1 
			; ebx = alpha
			pxor xmm5, xmm5  		; XMM5 = 0's  
			;cvtdq2ps xmm5, xmm5 
			.fiR2:
			;float fiR = ( (maxR >= maxG && maxR >= maxB) ? 1.0 + al: 1.0 - al )
			cmp edi, esi
			jl .elseFiR2
			cmp edi, edx
			jl .elseFiR2
			pinsrd xmm5, ebx, 2 ; xmm5 = | 1  | 0's..
			jmp .fiG2
			.elseFiR2:
			pinsrd xmm5, eax, 2 ; xmm5 = | -1 | 0's.. 
			.fiG2: 
			;float fiG = ( (maxR <  maxG && maxG >= maxB) ? 1.0 + al: 1.0 - al )
			cmp esi, edi
			jle .elseFiG2
			cmp esi, edx
			jl .elseFiG2
			pinsrd xmm5, ebx, 1; xmm5 = ? | 1 | 0's.. 
			jmp .fiB2
			.elseFiG2:
			pinsrd xmm5, eax, 1; xmm5 = ? | -1 | 0's 
			.fiB2:
 			;float fiB = ( (maxR <  maxB && maxG <  maxB) ? 1.0 + al: 1.0 - al )			
 			cmp edx, edi
 			jle .elseFiB2
 			cmp edx, esi
 			jle .elseFiB2
 			pinsrd xmm5, ebx, 0  ; xmm5 = ? | ? | 1 | 0	
 			jmp .sigo2
 			.elseFiB2:
 			pinsrd xmm5, eax, 0 ; xmm5 = ? | ? | -1 | 0 
 			.sigo2:
 			cvtdq2ps xmm5, xmm5 ; xmm5 = valores a sumar en floats 
 			addps xmm5, xmm4  	; xmm5 = fiB | fiG | fiR | 0  			DEL PIXEL 2

			;---- Pixel 1
			; comparaciones 
			pextrd edi, xmm2, 2 ; maxred 
			pextrd esi, xmm2, 1 ; maxgreen
			pextrd edx, xmm2, 0 ; maxblue 
			pxor xmm6, xmm6
			;cvtdq2ps xmm6, xmm6
			
			.fiR1:
			;float fiR = ( (maxR >= maxG && maxR >= maxB) ? 1.0 + al: 1.0 - al )
			cmp edi, esi
			jl .elseFiR1
			cmp edi, edx
			jl .elseFiR1
			pinsrd xmm6, ebx, 2 ; 
			jmp .fiG1
			.elseFiR1:
			pinsrd xmm6, eax, 2 ; 
			.fiG1: 
			;float fiG = ( (maxR <  maxG && maxG >= maxB) ? 1.0 + al: 1.0 - al )
			cmp esi, edi
			jle .elseFiG1
			cmp esi, edx
			jl .elseFiG1
			pinsrd xmm6, ebx, 1; xmm5 = ? | 1 | 0's.. 
			jmp .fiB1
			.elseFiG1:
			pinsrd xmm6, eax, 1; xmm5 = ? | -1 | 0's 
			.fiB1:
 			;float fiB = ( (maxR <  maxB && maxG <  maxB) ? 1.0 + al: 1.0 - al )			
 			cmp edx, edi
 			jle .elseFiB1
 			cmp edx, esi
 			jle .elseFiB1
 			pinsrd xmm6, ebx, 0  ; xmm5 = ? | ? | 1 | 0	
 			jmp .sigo1
 			.elseFiB1:
 			pinsrd xmm6, eax, 0 ; xmm5 = ? | ? | -1 | 0 
 			.sigo1:
 			cvtdq2ps xmm6, xmm6 ; xmm6 = valores a sumar en floats 
 			addps xmm6, xmm4  	; xmm6 = fiB | fiG | fiR | 0  			DEL PIXEL 1

 			;xmm5 = pixel 2
 			;xmm6 = pixel 1 

 			pxor xmm7, xmm7
 			pxor xmm1, xmm1
 			pxor xmm2, xmm2
 			punpcklbw xmm3, xmm7 ; xmm3 = |blue2 | green2 | red2 | trasp2 | blue1 | green1 | red1 | trasp1 | 	 
 			movdqu xmm1, xmm3
 			movdqu xmm2, xmm3
 			punpcklwd xmm1, xmm7 	
 			punpckhwd xmm2, xmm7 
 			cvtdq2ps xmm1, xmm1
 			cvtdq2ps xmm2, xmm2 	
 		; 							; xmm1 = | blue1 | green1 | red1 | transp1 	EN FLOAT 
 		; 							; xmm2 = | blue2 | green2 | red2 | transp2  EN FLOAT 
			; 		 				; xmm6 = fiB1 | fiG1 | fiR1 | 0  			DEL PIXEL 1
			; 						; xmm5 = fiB2 | fiG2 | fiR2 | 0  			DEL PIXEL 2



 			mulps xmm1, xmm6 		; xmm1 = |blue1*fiB1 | ..... | 0
 			mulps xmm2, xmm5 		; xmm2 = |blue2*fiB2 | ..... | 0
 			mov eax, 255
 			pxor xmm0, xmm0
 			pinsrd xmm0, eax, 1
 			pinsrd xmm0, eax, 2
 			pinsrd xmm0, eax, 3
 			;pinsrd xmm0, eax, 1
 			;pshufd xmm0, xmm0, 1010100b    
 			cvtdq2ps xmm0, xmm0 	; xmm0 = 255 en float 3 veces y 0
 			movdqu xmm8, xmm0		; xmm8 = xmm0
 			movdqu xmm9, xmm0

 			cmpps xmm0, xmm1, 1 	; compara si es menor 
 			cmpps xmm9, xmm2, 1 	; same, pixel 2
 			;pandn xmm0, xmm1		; xmm1 = (fiC * C) < 255? 255 ; 0)
 			;pcmpeqw xmm0, xmm0 		; xmm0 = 255 en entero donde hay que poner 0.5 + sat
 									; xmm9 = FF donde hay que poner 0.5 + sat en pixel 2
 			movdqu xmm7, xmm0		;xmm7 = mascara ed menor o no a 255 edl pix 1
 			movdqu xmm10, xmm9 		;xmm10 = mascara ed menor o no a 255 edl pix 2
 			pandn xmm10, xmm10 	; xmm10 = FF donde hay que poner 255 en float pixel 2 
 			pandn xmm7, xmm7 		; xmm7  = FF en entero donde hay que poner 255 en float  
 			pand xmm1, xmm0 		; xmm1 = fiC * c donde tiene que haberlo
 			pand xmm2, xmm9 		; xmm2 = fiC * C donde tiene que haberlo pixel 2  

pxor xmm5, xmm5 
 			pinsrd xmm5, ebx, 1
 			pinsrd xmm5, ebx, 2
 			pinsrd xmm5, ebx, 3

 			;pshufd xmm5, xmm5, 01010100b 	; xmm5 = 1 | 1 | 1 | 0
pxor xmm6, xmm6 
 			mov eax, 2
 			pinsrd xmm6, eax, 1
 			pinsrd xmm6, eax, 2
 			pinsrd xmm6, eax, 3

 			;pshufd xmm6, xmm6, 01010100b 	; xmm5 = 2 | 2 | 2 | 0
 			cvtdq2ps xmm5, xmm5 			
 			cvtdq2ps xmm6, xmm6				;ambos en float
 			divps xmm5, xmm6 				; xmm5= 1/2 | 1/2 | 1/2 | basura 
 			mov eax, 0
 			pinsrd xmm5, eax, 0 			;  xmm5= 1/2 | 1/2 | 1/2 | 0
 			movdqu xmm6, xmm5 
 			
 			pand xmm5, xmm0 				; xmm5 = 0,5 donde tiene que haberlo 
 			pand xmm6, xmm9					; pixel 2
 			addps xmm5, xmm1 				; 0,5 + fi*c donde tiene que haberlo 
 			addps xmm6, xmm2 				; pixel 2 

;///chequear esto 
			pand xmm10, xmm8 				; 255 en float donde tiene que haber pix2
 			por xmm6, xmm10 				;255 donde debe y o,5 + fi*c donde debe pixel2 
 			pxor xmm0, xmm0
 			addps xmm7, xmm8 				; 255 en float donde tiene que haber 
 			por xmm5, xmm7 					; 255 donde debe, y 0,5 +fi*c donde debe
 			; hasta acá esta todo en float 
 			;convierto a INT

 			cvtps2dq xmm5, xmm5
 			cvtps2dq xmm6, xmm6
 			;pack => destino es la parte BAJA
 			; HAGO PACK(PIXEL2,PIXEL1) => |pixel2|pixel1| ->cada componente ocupa 2 bytes  



 		; //// HASTA ACA FUNCA 



 			packusdw xmm5, xmm6 ; double -> word 
 			pxor xmm0, xmm0 
 			packuswb xmm5, xmm0 ;word -> byte => cada componente ocupa un byte 
 			
 			;xmm5 = |0 | 0 | pixel2 | pixel1 

		;	p_d->r = ((fiR * p_sActAct->r) < 255 ?  0.5+(p_sActAct->r * fiR  ) : 255);
		;	p_d->g = ((fiG * p_sActAct->g) < 255 ?  0.5+(p_sActAct->g * fiG  ) : 255);
		;	p_d->b = ((fiB * p_sActAct->b) < 255 ?  0.5+(p_sActAct->b * fiB  ) : 255);

			;pandn xmm5, xmm5 
	
			pextrq rax, xmm5, 0
			mov [r12], rax 
			
			dec r11 
			cmp r11, 0
			je .continuacion

			add r12, 8	;dst 
			add r13, 8	;src_fila_i
			add r14, 8	;src_fila_i+1
			add r15, 8	;src_fila_i+2
			
			jmp .ciclo_horizontal

		.continuacion: 
		 	dec rcx
		 	cmp rcx, 0
		 	je .fin
		 	;add r12, 2
			
			add r12, 12	;dst 
			add r13, 16	;src_fila_i
			add r14, 16	;src_fila_i+1
			add r15, 16	;src_fila_i+2
		 	jmp .ciclo_vertical
	.fin:

	 add rsp, 8
	 pop r15
	 pop r14
	 pop r12
	 pop r13
	 pop rbx
	 pop rbp
	ret

