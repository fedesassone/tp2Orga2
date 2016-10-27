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
section .data
mask: dd 0x04, 0x04, 0x04, 0x04

section .text
	
pixelar_asm:
	;; TODO: Implementar
	push rbp
	mov rbp, rsp
	push rbx
	push r12

	pxor xmm7, xmm7
	mov r12, rdx
	mov rbx, rcx
	shr rbx, 1
ciclo_pixelar_alto:
	mov rcx, r12
	shr rcx, 2
ciclo_pixelar_ancho:	
	movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx

		movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx
	
	movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx

		movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx
	
	movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx

		movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx
	
	movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx

		movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx
	
	movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx

		movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx
	
	movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx

		movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx
	
	movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx

		movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx
	
	movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx

		movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx
	
	movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx

		movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx
	
	movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx

		movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx
	
	movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx

		movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx
	
	movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx

		movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx
	
	movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx

		movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx
	
	movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx

		movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx
	
	movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx

		movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx
	
	movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx

		movdqu xmm1, [rdi] 		;xmm1 = |pa3|pa2|pa1|pa0|
	movdqu xmm3, [rdi + r8]	;xmm3 = |pb3|pb2|pb1|pb0|
	movdqu xmm2, xmm1		;xmm2 = xmm1
	movdqu xmm4, xmm3		;xmm4 = xmm3
	punpckhbw xmm1, xmm7	;xmm1 = |0|a127|..|0|a64|
	punpcklbw xmm2, xmm7	;xmm2 = |0|a63|..|0|a0|
	punpckhbw xmm3, xmm7	;xmm3 = |0|b127|..|0|b64|
	punpcklbw xmm4, xmm7	;xmm4 = |0|b63|..|0|b0|

	paddw xmm1, xmm3		;xmm1 = |?|a127+b127|..|?|a64+b64|
	movdqu xmm3, xmm1		;xmm3 = xmm1
	psrldq xmm1, 8			;xmm1 = |0|0|?|a127+b127..|
	paddw xmm1, xmm3		;xmm1 = |?|a127+b127..|?|a127+b127+..+a64+b64|
	
	paddw xmm2, xmm4		;xmm2 = |?|a63+b63|..|?|a0+b0|
	movdqu xmm4, xmm2		;xmm4 = xmm2
	psrldq xmm2, 8			;xmm2 = |0|0|?|a63+b63..|
	paddw xmm2, xmm4		;xmm1 = |?|a63+b63..|?|a63+b63+..+a0+b0|
	
	movdqu xmm0, [mask]
	punpcklwd xmm1, xmm7
	punpcklwd xmm2, xmm7
	cvtdq2ps xmm3, xmm1
	cvtdq2ps xmm4, xmm2
	cvtdq2ps xmm0, xmm0
	divps xmm3, xmm0		;xmm1 = |r/4|g/4|b/4|a/4|
	divps xmm4, xmm0		;xmm2 = |r/4|g/4|b/4|a/4|
	CVTPS2DQ xmm1, xmm3
	CVTPS2DQ xmm2, xmm4
	packusdw xmm1, xmm1
	packusdw xmm2, xmm2
	;pshufd xmm1,xmm1,44h
	;pshufd xmm2,xmm2,44h
	packuswb xmm2, xmm1 
	movdqu [rsi], xmm2
	movdqu [rsi + r8], xmm2
	add rsi, 16
	add rdi, 16
	dec rcx
	
	
	cmp rcx, 0
	jne ciclo_pixelar_ancho
	
	dec rbx
	cmp rbx, 0
	je fin_pixelar
	lea rdi, [rdi + r8]
	lea rsi, [rsi + r8]
	jmp ciclo_pixelar_alto
fin_pixelar:
	pop r12
	pop rbx
	pop rbp
	ret
