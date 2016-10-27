; void combinar_asm (
; 	unsigned char *src,
; 	unsigned char *dst,
; 	int cols,
; 	int filas,
; 	int src_row_size,
; 	int dst_row_size,
; 	float alpha
; );

; Parámetros:
; 	rdi = src
; 	rsi = dst
; 	rdx = cols
; 	rcx = filas
; 	r8 = dst_row_size
; 	r9 = dst_row_size
; 	xmm0 = alpha

global combinar_asm

section .rodata

dosCincuentaycinco: DD 255.0, 255.0, 255.0, 255.0


extern combinar_c

section .text

combinar_asm:
	;; TODO: Implementar

	push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14

    movdqu xmm8,[dosCincuentaycinco]      ; xmm8 <- todos los bytes en 255

    xor r12, r12
    mov r12, r8                 ; r12d = tamFilaBytes
    shr r12d, 1                 ; r12d = tamFilaBytes/2

    xor r13,r13
    mov r13d,ecx                ; r13d = filas
    ; Comienzo a iterar sobre las filas

    xor r11d, r11d              ; r11d = y = 0

    

ciclo_y:
    
    ; Comienzo a iterar sobre las columnas de la fila actual

    xor r10d, r10d              ; r10d = x = 0

ciclo_x:

    ; Termino el ciclo x sólo si terminamos de recorrer la fila actual

    mov eax, r12d               ; eax = tamFilaBytes/2
    sub eax, r10d               ; eax = tamFilaBytes/2 - x
    jle fin_ciclo_x              ; Salto al fin del ciclo si tamFilaBytes/2 - x = 0



    ;-----PRIMERA MITAD------
    ;Obtengo IsrcA

    mov eax, r11d               ; eax = y
    mov ebx, r8d                ; ebx = src_row_size
    mul ebx                     ; eax = src_row_size * y
    add eax, r10d               ; eax = src_row_size * y + x
    shl rax, 32                 ; Limpio parte alta de rax
    shr rax, 32
    movdqu xmm1, [rdi + rax]    ; xmm1 = [src + (src_row_size * y + x)]  IsrcA

    ;Obtengo IsrcB

    mov eax, r11d               ; eax = y
    mov ebx, r8d                ; ebx = src_row_size
    mul ebx                     ; eax = src_row_size * y 
    add eax, r8d                ; eax = src_row_size * y + src_row_size // estoy al final de la fila
    sub eax, 16                 ; eax = src_row_size * y + src_row_size - 16 //resto 16 asi ahora estaria agarrando los ultimos cuatro pixels de la fila 
    sub eax, r10d               ; eax = src_row_size * y + src_row_size - 16 - x // resto x para quedar en el simetrico
    shl rax, 32                 ; Limpio parte alta de rax
    shr rax, 32
    movdqu xmm2, [rdi + rax]    ; xmm2 = [src + (src_row_size * y + src_row_size - 16 - x)]  IsrcB =  |  S3  | S2  |  S1 |  S0 |
    pshufd xmm2, xmm2, 00011011b ; xmm2 = |  S0  |  S1  |  S3  |  S2 | los ordeno bien asi quedan los simetricos bien
    movdqu xmm3,xmm1               ; xmm3 = IsrcA
    ;psubusb xmm3,xmm2           ; xmm3 = IsrcA - IsrcB con saturacion
    pshufd xmm0, xmm0, 00000000b ; xmm0 = [alpha|alpha|alpha|alpha] //-----LO PONGO AFUERA DEL CICLO
    ;cvtdq2ps xmm0, xmm0         ; xmm0 = [float alpha|float alpha|float alpha|float alpha]
    pxor xmm6, xmm6             ; para desempaquetar
    
    movdqu xmm4,xmm3            ; xmm4 = [PIXEL 4|PIXEL 3|PIXEL 2|PIXEL 1] SOURCE A
    punpcklbw xmm3, xmm6        ; xmm3 = [0|B2|0|G2|0|R2|0|A2|0|B1|0|G1|0|R1|0|A1]
    punpckhbw xmm4, xmm6        ; xmm4 = [0|B4|0|G4|0|R4|0|A4|0|B3|0|G3|0|R3|0|A3]
    movdqu xmm5,xmm3            ; xmm5 = [0|B2|0|G2|0|R2|0|A2|0|B1|0|G1|0|R1|0|A1]
    punpcklwd xmm3, xmm6        ; xmm3 = [0|0|0|B1|0|0|0|G1|0|0|0|R1|0|0|0|A1] 
    punpckhwd xmm5, xmm6        ; xmm5 = [0|0|0|B2|0|0|0|G2|0|0|0|R2|0|0|0|A2]
    movdqu xmm7,xmm4            ; xmm7 = [0|B4|0|G4|0|R4|0|A4|0|B3|0|G3|0|R3|0|A3]
    punpcklwd xmm4, xmm6        ; xmm4 = [0|0|0|B3|0|0|0|G3|0|0|0|R3|0|0|0|A3]
    punpckhwd xmm7, xmm6        ; xmm7 = [0|0|0|B4|0|0|0|G4|0|0|0|R4|0|0|0|A4]
    
    movdqu xmm9,xmm2            ; xmm9 = [PIXEL 4|PIXEL 3|PIXEL 2|PIXEL 1] SOURCE B
    punpcklbw xmm2, xmm6        ; xmm2 = [0|B2|0|G2|0|R2|0|A2|0|B1|0|G1|0|R1|0|A1] B
    punpckhbw xmm9, xmm6        ; xmm9 = [0|B4|0|G4|0|R4|0|A4|0|B3|0|G3|0|R3|0|A3] B
    movdqu xmm10,xmm2           ; xmm10 = [0|B2|0|G2|0|R2|0|A2|0|B1|0|G1|0|R1|0|A1] B
    punpcklwd xmm2, xmm6        ; xmm2 = [0|0|0|B1|0|0|0|G1|0|0|0|R1|0|0|0|A1] B 
    punpckhwd xmm10, xmm6        ; xmm10 = [0|0|0|B2|0|0|0|G2|0|0|0|R2|0|0|0|A2] B
    movdqu xmm11,xmm9           ; xmm11 = [0|B4|0|G4|0|R4|0|A4|0|B3|0|G3|0|R3|0|A3]
    punpcklwd xmm9, xmm6        ; xmm9 = [0|0|0|B3|0|0|0|G3|0|0|0|R3|0|0|0|A3]
    punpckhwd xmm11, xmm6        ; xmm11 = [0|0|0|B4|0|0|0|G4|0|0|0|R4|0|0|0|A4]
    
    psubd xmm7,xmm11
    psubd xmm4,xmm9
    psubd xmm5,xmm10
    psubd xmm3,xmm2

    cvtdq2ps xmm3, xmm3         ; xmm3 = [B1 float|G1 float|R1 float|A1 float]
    cvtdq2ps xmm5, xmm5         ; xmm5 = [B2 float|G2 float|R2 float|A2 float]
    cvtdq2ps xmm4, xmm4         ; xmm4 = [B3 float|G3 float|R3 float|A3 float] 
    cvtdq2ps xmm7, xmm7         ; xmm7 = [B4 float|G4 float|R4 float|A4 float]  


 
    mulps xmm3, xmm0            ; xmm3 = [alpha * B1 float | alpha * G1 float | alpha * R1 float | alpha * A1 float] 
    mulps xmm5, xmm0            ; xmm5 = [alpha * B2 float | alpha * G2 float | alpha * R2 float | alpha * A2 float]
    mulps xmm4, xmm0            ; xmm4 = [alpha * B3 float | alpha * G3 float | alpha * R3 float | alpha * A3 float]
    mulps xmm7, xmm0            ; xmm7 = [alpha * B4 float | alpha * G4 float | alpha * R4 float | alpha * A4 float]
    divps xmm3, xmm8            ; xmm3 = [(alpha * B1 float) / 255.0 | (alpha * G1 float) / 255.0 | (alpha * R1 float) / 255.0 | (alpha * A1 float)/255.0]
    divps xmm5, xmm8            ; xmm4 = [(alpha * B2 float) / 255.0 | (alpha * G2 float) / 255.0 | (alpha * R2 float) / 255.0 | (alpha * A2 float)/255.0]
    divps xmm4, xmm8            ; xmm5 = [(alpha * B3 float) / 255.0 | (alpha * G3 float) / 255.0 | (alpha * R3 float) / 255.0 | (alpha * A3 float)/255.0]
    divps xmm7, xmm8            ; xmm7 = [(alpha * B4 float) / 255.0 | (alpha * G4 float) / 255.0 | (alpha * R4 float) / 255.0 | (alpha * A4 float)/255.0]
   
    cvtps2dq xmm3, xmm3
    cvtps2dq xmm4, xmm4
    cvtps2dq xmm5, xmm5
    cvtps2dq xmm7, xmm7          ; Convierto de float a entero

    paddd xmm7,xmm11
    paddd xmm4,xmm9
    paddd xmm5,xmm10
    paddd xmm3,xmm2


    packusdw xmm3, xmm6
    packuswb xmm3, xmm6         ;[ -           |             |            |  PIXEL 1 NUEVO]

    packusdw xmm4, xmm6
    packuswb xmm4, xmm6         ;[-|-|-|PIXEL 2 NUEVO]

    packusdw xmm5, xmm6         
    packuswb xmm5, xmm6         ;[-|-|-|PIXEL 3 NUEVO]

    packusdw xmm7, xmm6
    packuswb xmm7, xmm6         ;[-|-|-|PIXEL 4 NUEVO]  

    pslldq xmm4, 8              ; xmm4 = [ -           |             |PIXEL 2 NUEVO|              -]
    pslldq xmm5, 4              ; xmm5 = [ -           |PIXEL 3 NUEVO|             |              -]
    pslldq xmm7, 12             ; xmm7 = [PIXEL 4 NUEVO|             |             |              -]
    paddd xmm3,xmm4             ; xmm3 = [ -           |             |PIXEL 2 NUEVO|  PIXEL 1 NUEVO]
    paddd xmm3,xmm5             ; xmm3 = [ -           |PIXEL 3 NUEVO|PIXEL 2 NUEVO|  PIXEL 1 NUEVO]
    paddd xmm3,xmm7             ; xmm3 = [PIXEL 4 NUEVO|PIXEL 3 NUEVO|PIXEL 2 NUEVO|  PIXEL 1 NUEVO]
    ;paddusb xmm3,xmm2           ; xmm3 = xmm3 + IsrcB
    
    mov eax, r11d               ; eax = y
    mov ebx, r8d                ; ebx = src_row_size
    mul ebx                     ; eax = src_row_size * y
    add eax, r10d               ; eax = src_row_size * y + x
    shl rax, 32                 ; Limpio parte alta de rax
    shr rax, 32                 
    movdqu [rsi + rax], xmm3    ; [[dst + (src_row_size * y + x)] = xmm3

    ;-----SEGUNDA MITAD--------
    ;Obtengo IsrcA

    mov eax, r11d               ; eax = y
    mov ebx, r8d                ; ebx = src_row_size
    mul ebx                     ; eax = src_row_size * y 
    add eax, r8d                ; eax = src_row_size * y + src_row_size // estoy al final de la fila
    sub eax, 16                 ; eax = src_row_size * y + src_row_size - 16 //resto 16 asi ahora estaria agarrando los ultimos cuatro pixels de la fila 
    sub eax, r10d               ; eax = src_row_size * y + src_row_size - 16 - x // resto x para quedar en el que corresponda
    shl rax, 32                 ; Limpio parte alta de rax
    shr rax, 32
    movdqu xmm1, [rdi + rax]    ; xmm1 = [src + (src_row_size * y + src_row_size - 16 - x)] IsrcA

    ;Obtengo IsrcB

    mov eax, r11d               ; eax = y
    mov ebx, r8d                ; ebx = src_row_size
    mul ebx                     ; eax = src_row_size * y
    add eax, r10d               ; eax = src_row_size * y + x
    shl rax, 32                 ; Limpio parte alta de rax
    shr rax, 32
    movdqu xmm2, [rdi + rax]    ; xmm2 = [src + (src_row_size * y + x)]  IsrcB =  |  S3  | S2  |  S1 |  S0 |
    pshufd xmm2, xmm2, 00011011b ; xmm2 = |  S0  |  S1  |  S3  |  S2 | los ordeno bien asi quedan los simetricos bien
    movdqu xmm3,xmm1               ; xmm3 = IsrcA
    ;psubusb xmm3,xmm2           ; xmm3 = IsrcA - IsrcB con saturacion
    pshufd xmm0, xmm0, 00000000b ; xmm0 = [alpha|alpha|alpha|alpha]
    ;cvtdq2ps xmm0, xmm0         ; xmm0 = [float alpha|float alpha|float alpha|float alpha]
    pxor xmm6, xmm6             ; para desempaquetar
    movdqu xmm4,xmm3            ; xmm4 = [PIXEL 4|PIXEL 3|PIXEL 2|PIXEL 1] SOURCE A
    punpcklbw xmm3, xmm6        ; xmm3 = [0|B2|0|G2|0|R2|0|A2|0|B1|0|G1|0|R1|0|A1]
    punpckhbw xmm4, xmm6        ; xmm4 = [0|B4|0|G4|0|R4|0|A4|0|B3|0|G3|0|R3|0|A3]
    movdqu xmm5,xmm3            ; xmm5 = [0|B2|0|G2|0|R2|0|A2|0|B1|0|G1|0|R1|0|A1]
    punpcklwd xmm3, xmm6        ; xmm3 = [0|0|0|B1|0|0|0|G1|0|0|0|R1|0|0|0|A1] 
    punpckhwd xmm5, xmm6        ; xmm5 = [0|0|0|B2|0|0|0|G2|0|0|0|R2|0|0|0|A2]
    movdqu xmm7,xmm4            ; xmm7 = [0|B4|0|G4|0|R4|0|A4|0|B3|0|G3|0|R3|0|A3]
    punpcklwd xmm4, xmm6        ; xmm4 = [0|0|0|B3|0|0|0|G3|0|0|0|R3|0|0|0|A3]
    punpckhwd xmm7, xmm6        ; xmm7 = [0|0|0|B4|0|0|0|G4|0|0|0|R4|0|0|0|A4]
    
    movdqu xmm9,xmm2            ; xmm9 = [PIXEL 4|PIXEL 3|PIXEL 2|PIXEL 1] SOURCE B
    punpcklbw xmm2, xmm6        ; xmm2 = [0|B2|0|G2|0|R2|0|A2|0|B1|0|G1|0|R1|0|A1] B
    punpckhbw xmm9, xmm6        ; xmm9 = [0|B4|0|G4|0|R4|0|A4|0|B3|0|G3|0|R3|0|A3] B
    movdqu xmm10,xmm2           ; xmm10 = [0|B2|0|G2|0|R2|0|A2|0|B1|0|G1|0|R1|0|A1] B
    punpcklwd xmm2, xmm6        ; xmm2 = [0|0|0|B1|0|0|0|G1|0|0|0|R1|0|0|0|A1] B 
    punpckhwd xmm10, xmm6        ; xmm10 = [0|0|0|B2|0|0|0|G2|0|0|0|R2|0|0|0|A2] B
    movdqu xmm11,xmm9           ; xmm11 = [0|B4|0|G4|0|R4|0|A4|0|B3|0|G3|0|R3|0|A3]
    punpcklwd xmm9, xmm6        ; xmm9 = [0|0|0|B3|0|0|0|G3|0|0|0|R3|0|0|0|A3]
    punpckhwd xmm11, xmm6        ; xmm11 = [0|0|0|B4|0|0|0|G4|0|0|0|R4|0|0|0|A4]
    
    psubd xmm7,xmm11
    psubd xmm4,xmm9
    psubd xmm5,xmm10
    psubd xmm3,xmm2

    cvtdq2ps xmm3, xmm3         ; xmm3 = [B1 float|G1 float|R1 float|A1 float]
    cvtdq2ps xmm5, xmm5         ; xmm5 = [B2 float|G2 float|R2 float|A2 float]
    cvtdq2ps xmm4, xmm4         ; xmm4 = [B3 float|G3 float|R3 float|A3 float] 
    cvtdq2ps xmm7, xmm7         ; xmm7 = [B4 float|G4 float|R4 float|A4 float]   
    mulps xmm3, xmm0            ; xmm3 = [alpha * B1 float | alpha * G1 float | alpha * R1 float | alpha * A1 float] 
    mulps xmm5, xmm0            ; xmm5 = [alpha * B2 float | alpha * G2 float | alpha * R2 float | alpha * A2 float]
    mulps xmm4, xmm0            ; xmm4 = [alpha * B3 float | alpha * G3 float | alpha * R3 float | alpha * A3 float]
    mulps xmm7, xmm0            ; xmm7 = [alpha * B4 float | alpha * G4 float | alpha * R4 float | alpha * A4 float]
    divps xmm3, xmm8            ; xmm3 = [(alpha * B1 float) / 255.0 | (alpha * G1 float) / 255.0 | (alpha * R1 float) / 255.0 | (alpha * A1 float)/255.0]
    divps xmm5, xmm8            ; xmm4 = [(alpha * B2 float) / 255.0 | (alpha * G2 float) / 255.0 | (alpha * R2 float) / 255.0 | (alpha * A2 float)/255.0]
    divps xmm4, xmm8            ; xmm5 = [(alpha * B3 float) / 255.0 | (alpha * G3 float) / 255.0 | (alpha * R3 float) / 255.0 | (alpha * A3 float)/255.0]
    divps xmm7, xmm8            ; xmm7 = [(alpha * B4 float) / 255.0 | (alpha * G4 float) / 255.0 | (alpha * R4 float) / 255.0 | (alpha * A4 float)/255.0]
    cvtps2dq xmm3, xmm3
    cvtps2dq xmm4, xmm4
    cvtps2dq xmm5, xmm5
    cvtps2dq xmm7, xmm7 ; Convierto de float a entero

    paddd xmm7,xmm11
    paddd xmm4,xmm9
    paddd xmm5,xmm10
    paddd xmm3,xmm2

    packusdw xmm3, xmm6
    packuswb xmm3, xmm6         ;[ -           |             |            |  PIXEL 1 NUEVO]

    packusdw xmm4, xmm6
    packuswb xmm4, xmm6         ;[-|-|-|PIXEL 2 NUEVO]

    packusdw xmm5, xmm6         
    packuswb xmm5, xmm6         ;[-|-|-|PIXEL 3 NUEVO]

    packusdw xmm7, xmm6
    packuswb xmm7, xmm6         ;[-|-|-|PIXEL 4 NUEVO]  

    pslldq xmm4, 8              ; xmm4 = [ -           |             |PIXEL 2 NUEVO|              -]
    pslldq xmm5, 4              ; xmm5 = [ -           |PIXEL 3 NUEVO|             |              -]
    pslldq xmm7, 12             ; xmm7 = [PIXEL 4 NUEVO|             |             |              -]
    paddd xmm3,xmm4             ; xmm3 = [ -           |             |PIXEL 2 NUEVO|  PIXEL 1 NUEVO]
    paddd xmm3,xmm5             ; xmm3 = [ -           |PIXEL 3 NUEVO|PIXEL 2 NUEVO|  PIXEL 1 NUEVO]
    paddd xmm3,xmm7             ; xmm3 = [PIXEL 4 NUEVO|PIXEL 3 NUEVO|PIXEL 2 NUEVO|  PIXEL 1 NUEVO]
    ;paddusb xmm3,xmm2           ; xmm3 = xmm3 + IsrcB
    
    mov eax, r11d               ; eax = y
    mov ebx, r8d                ; ebx = src_row_size
    mul ebx                     ; eax = src_row_size * y 
    add eax, r8d                ; eax = src_row_size * y + src_row_size // estoy al final de la fila
    sub eax, 16                 ; eax = src_row_size * y + src_row_size - 16 //resto 16 asi ahora estaria agarrando los ultimos cuatro pixels de la fila 
    sub eax, r10d               ; eax = src_row_size * y + src_row_size - 16 - x // resto x para quedar en el que corresponda
    shl rax, 32                 ; Limpio parte alta de rax
    shr rax, 32
    movdqu [rsi + rax], xmm3    ; [[dst + (src_row_size * y + src_row_size - 16 - x)] = xmm3
    add r10d, 16                ; r10d = x = x + 16



    ;-----PRIMERA MITAD------
    ;Obtengo IsrcA

    mov eax, r11d               ; eax = y
    mov ebx, r8d                ; ebx = src_row_size
    mul ebx                     ; eax = src_row_size * y
    add eax, r10d               ; eax = src_row_size * y + x
    shl rax, 32                 ; Limpio parte alta de rax
    shr rax, 32
    movdqu xmm1, [rdi + rax]    ; xmm1 = [src + (src_row_size * y + x)]  IsrcA

    ;Obtengo IsrcB

    mov eax, r11d               ; eax = y
    mov ebx, r8d                ; ebx = src_row_size
    mul ebx                     ; eax = src_row_size * y 
    add eax, r8d                ; eax = src_row_size * y + src_row_size // estoy al final de la fila
    sub eax, 16                 ; eax = src_row_size * y + src_row_size - 16 //resto 16 asi ahora estaria agarrando los ultimos cuatro pixels de la fila 
    sub eax, r10d               ; eax = src_row_size * y + src_row_size - 16 - x // resto x para quedar en el simetrico
    shl rax, 32                 ; Limpio parte alta de rax
    shr rax, 32
    movdqu xmm2, [rdi + rax]    ; xmm2 = [src + (src_row_size * y + src_row_size - 16 - x)]  IsrcB =  |  S3  | S2  |  S1 |  S0 |
    pshufd xmm2, xmm2, 00011011b ; xmm2 = |  S0  |  S1  |  S3  |  S2 | los ordeno bien asi quedan los simetricos bien
    movdqu xmm3,xmm1               ; xmm3 = IsrcA
    ;psubusb xmm3,xmm2           ; xmm3 = IsrcA - IsrcB con saturacion
    pshufd xmm0, xmm0, 00000000b ; xmm0 = [alpha|alpha|alpha|alpha] //-----LO PONGO AFUERA DEL CICLO
    ;cvtdq2ps xmm0, xmm0         ; xmm0 = [float alpha|float alpha|float alpha|float alpha]
    pxor xmm6, xmm6             ; para desempaquetar
    
    movdqu xmm4,xmm3            ; xmm4 = [PIXEL 4|PIXEL 3|PIXEL 2|PIXEL 1] SOURCE A
    punpcklbw xmm3, xmm6        ; xmm3 = [0|B2|0|G2|0|R2|0|A2|0|B1|0|G1|0|R1|0|A1]
    punpckhbw xmm4, xmm6        ; xmm4 = [0|B4|0|G4|0|R4|0|A4|0|B3|0|G3|0|R3|0|A3]
    movdqu xmm5,xmm3            ; xmm5 = [0|B2|0|G2|0|R2|0|A2|0|B1|0|G1|0|R1|0|A1]
    punpcklwd xmm3, xmm6        ; xmm3 = [0|0|0|B1|0|0|0|G1|0|0|0|R1|0|0|0|A1] 
    punpckhwd xmm5, xmm6        ; xmm5 = [0|0|0|B2|0|0|0|G2|0|0|0|R2|0|0|0|A2]
    movdqu xmm7,xmm4            ; xmm7 = [0|B4|0|G4|0|R4|0|A4|0|B3|0|G3|0|R3|0|A3]
    punpcklwd xmm4, xmm6        ; xmm4 = [0|0|0|B3|0|0|0|G3|0|0|0|R3|0|0|0|A3]
    punpckhwd xmm7, xmm6        ; xmm7 = [0|0|0|B4|0|0|0|G4|0|0|0|R4|0|0|0|A4]
    
    movdqu xmm9,xmm2            ; xmm9 = [PIXEL 4|PIXEL 3|PIXEL 2|PIXEL 1] SOURCE B
    punpcklbw xmm2, xmm6        ; xmm2 = [0|B2|0|G2|0|R2|0|A2|0|B1|0|G1|0|R1|0|A1] B
    punpckhbw xmm9, xmm6        ; xmm9 = [0|B4|0|G4|0|R4|0|A4|0|B3|0|G3|0|R3|0|A3] B
    movdqu xmm10,xmm2           ; xmm10 = [0|B2|0|G2|0|R2|0|A2|0|B1|0|G1|0|R1|0|A1] B
    punpcklwd xmm2, xmm6        ; xmm2 = [0|0|0|B1|0|0|0|G1|0|0|0|R1|0|0|0|A1] B 
    punpckhwd xmm10, xmm6        ; xmm10 = [0|0|0|B2|0|0|0|G2|0|0|0|R2|0|0|0|A2] B
    movdqu xmm11,xmm9           ; xmm11 = [0|B4|0|G4|0|R4|0|A4|0|B3|0|G3|0|R3|0|A3]
    punpcklwd xmm9, xmm6        ; xmm9 = [0|0|0|B3|0|0|0|G3|0|0|0|R3|0|0|0|A3]
    punpckhwd xmm11, xmm6        ; xmm11 = [0|0|0|B4|0|0|0|G4|0|0|0|R4|0|0|0|A4]
    
    psubd xmm7,xmm11
    psubd xmm4,xmm9
    psubd xmm5,xmm10
    psubd xmm3,xmm2

    cvtdq2ps xmm3, xmm3         ; xmm3 = [B1 float|G1 float|R1 float|A1 float]
    cvtdq2ps xmm5, xmm5         ; xmm5 = [B2 float|G2 float|R2 float|A2 float]
    cvtdq2ps xmm4, xmm4         ; xmm4 = [B3 float|G3 float|R3 float|A3 float] 
    cvtdq2ps xmm7, xmm7         ; xmm7 = [B4 float|G4 float|R4 float|A4 float]  


 
    mulps xmm3, xmm0            ; xmm3 = [alpha * B1 float | alpha * G1 float | alpha * R1 float | alpha * A1 float] 
    mulps xmm5, xmm0            ; xmm5 = [alpha * B2 float | alpha * G2 float | alpha * R2 float | alpha * A2 float]
    mulps xmm4, xmm0            ; xmm4 = [alpha * B3 float | alpha * G3 float | alpha * R3 float | alpha * A3 float]
    mulps xmm7, xmm0            ; xmm7 = [alpha * B4 float | alpha * G4 float | alpha * R4 float | alpha * A4 float]
    divps xmm3, xmm8            ; xmm3 = [(alpha * B1 float) / 255.0 | (alpha * G1 float) / 255.0 | (alpha * R1 float) / 255.0 | (alpha * A1 float)/255.0]
    divps xmm5, xmm8            ; xmm4 = [(alpha * B2 float) / 255.0 | (alpha * G2 float) / 255.0 | (alpha * R2 float) / 255.0 | (alpha * A2 float)/255.0]
    divps xmm4, xmm8            ; xmm5 = [(alpha * B3 float) / 255.0 | (alpha * G3 float) / 255.0 | (alpha * R3 float) / 255.0 | (alpha * A3 float)/255.0]
    divps xmm7, xmm8            ; xmm7 = [(alpha * B4 float) / 255.0 | (alpha * G4 float) / 255.0 | (alpha * R4 float) / 255.0 | (alpha * A4 float)/255.0]
   
    cvtps2dq xmm3, xmm3
    cvtps2dq xmm4, xmm4
    cvtps2dq xmm5, xmm5
    cvtps2dq xmm7, xmm7          ; Convierto de float a entero

    paddd xmm7,xmm11
    paddd xmm4,xmm9
    paddd xmm5,xmm10
    paddd xmm3,xmm2


    packusdw xmm3, xmm6
    packuswb xmm3, xmm6         ;[ -           |             |            |  PIXEL 1 NUEVO]

    packusdw xmm4, xmm6
    packuswb xmm4, xmm6         ;[-|-|-|PIXEL 2 NUEVO]

    packusdw xmm5, xmm6         
    packuswb xmm5, xmm6         ;[-|-|-|PIXEL 3 NUEVO]

    packusdw xmm7, xmm6
    packuswb xmm7, xmm6         ;[-|-|-|PIXEL 4 NUEVO]  

    pslldq xmm4, 8              ; xmm4 = [ -           |             |PIXEL 2 NUEVO|              -]
    pslldq xmm5, 4              ; xmm5 = [ -           |PIXEL 3 NUEVO|             |              -]
    pslldq xmm7, 12             ; xmm7 = [PIXEL 4 NUEVO|             |             |              -]
    paddd xmm3,xmm4             ; xmm3 = [ -           |             |PIXEL 2 NUEVO|  PIXEL 1 NUEVO]
    paddd xmm3,xmm5             ; xmm3 = [ -           |PIXEL 3 NUEVO|PIXEL 2 NUEVO|  PIXEL 1 NUEVO]
    paddd xmm3,xmm7             ; xmm3 = [PIXEL 4 NUEVO|PIXEL 3 NUEVO|PIXEL 2 NUEVO|  PIXEL 1 NUEVO]
    ;paddusb xmm3,xmm2           ; xmm3 = xmm3 + IsrcB
    
    mov eax, r11d               ; eax = y
    mov ebx, r8d                ; ebx = src_row_size
    mul ebx                     ; eax = src_row_size * y
    add eax, r10d               ; eax = src_row_size * y + x
    shl rax, 32                 ; Limpio parte alta de rax
    shr rax, 32                 
    movdqu [rsi + rax], xmm3    ; [[dst + (src_row_size * y + x)] = xmm3

    ;-----SEGUNDA MITAD--------
    ;Obtengo IsrcA

    mov eax, r11d               ; eax = y
    mov ebx, r8d                ; ebx = src_row_size
    mul ebx                     ; eax = src_row_size * y 
    add eax, r8d                ; eax = src_row_size * y + src_row_size // estoy al final de la fila
    sub eax, 16                 ; eax = src_row_size * y + src_row_size - 16 //resto 16 asi ahora estaria agarrando los ultimos cuatro pixels de la fila 
    sub eax, r10d               ; eax = src_row_size * y + src_row_size - 16 - x // resto x para quedar en el que corresponda
    shl rax, 32                 ; Limpio parte alta de rax
    shr rax, 32
    movdqu xmm1, [rdi + rax]    ; xmm1 = [src + (src_row_size * y + src_row_size - 16 - x)] IsrcA

    ;Obtengo IsrcB

    mov eax, r11d               ; eax = y
    mov ebx, r8d                ; ebx = src_row_size
    mul ebx                     ; eax = src_row_size * y
    add eax, r10d               ; eax = src_row_size * y + x
    shl rax, 32                 ; Limpio parte alta de rax
    shr rax, 32
    movdqu xmm2, [rdi + rax]    ; xmm2 = [src + (src_row_size * y + x)]  IsrcB =  |  S3  | S2  |  S1 |  S0 |
    pshufd xmm2, xmm2, 00011011b ; xmm2 = |  S0  |  S1  |  S3  |  S2 | los ordeno bien asi quedan los simetricos bien
    movdqu xmm3,xmm1               ; xmm3 = IsrcA
    ;psubusb xmm3,xmm2           ; xmm3 = IsrcA - IsrcB con saturacion
    pshufd xmm0, xmm0, 00000000b ; xmm0 = [alpha|alpha|alpha|alpha]
    ;cvtdq2ps xmm0, xmm0         ; xmm0 = [float alpha|float alpha|float alpha|float alpha]
    pxor xmm6, xmm6             ; para desempaquetar
    movdqu xmm4,xmm3            ; xmm4 = [PIXEL 4|PIXEL 3|PIXEL 2|PIXEL 1] SOURCE A
    punpcklbw xmm3, xmm6        ; xmm3 = [0|B2|0|G2|0|R2|0|A2|0|B1|0|G1|0|R1|0|A1]
    punpckhbw xmm4, xmm6        ; xmm4 = [0|B4|0|G4|0|R4|0|A4|0|B3|0|G3|0|R3|0|A3]
    movdqu xmm5,xmm3            ; xmm5 = [0|B2|0|G2|0|R2|0|A2|0|B1|0|G1|0|R1|0|A1]
    punpcklwd xmm3, xmm6        ; xmm3 = [0|0|0|B1|0|0|0|G1|0|0|0|R1|0|0|0|A1] 
    punpckhwd xmm5, xmm6        ; xmm5 = [0|0|0|B2|0|0|0|G2|0|0|0|R2|0|0|0|A2]
    movdqu xmm7,xmm4            ; xmm7 = [0|B4|0|G4|0|R4|0|A4|0|B3|0|G3|0|R3|0|A3]
    punpcklwd xmm4, xmm6        ; xmm4 = [0|0|0|B3|0|0|0|G3|0|0|0|R3|0|0|0|A3]
    punpckhwd xmm7, xmm6        ; xmm7 = [0|0|0|B4|0|0|0|G4|0|0|0|R4|0|0|0|A4]
    
    movdqu xmm9,xmm2            ; xmm9 = [PIXEL 4|PIXEL 3|PIXEL 2|PIXEL 1] SOURCE B
    punpcklbw xmm2, xmm6        ; xmm2 = [0|B2|0|G2|0|R2|0|A2|0|B1|0|G1|0|R1|0|A1] B
    punpckhbw xmm9, xmm6        ; xmm9 = [0|B4|0|G4|0|R4|0|A4|0|B3|0|G3|0|R3|0|A3] B
    movdqu xmm10,xmm2           ; xmm10 = [0|B2|0|G2|0|R2|0|A2|0|B1|0|G1|0|R1|0|A1] B
    punpcklwd xmm2, xmm6        ; xmm2 = [0|0|0|B1|0|0|0|G1|0|0|0|R1|0|0|0|A1] B 
    punpckhwd xmm10, xmm6        ; xmm10 = [0|0|0|B2|0|0|0|G2|0|0|0|R2|0|0|0|A2] B
    movdqu xmm11,xmm9           ; xmm11 = [0|B4|0|G4|0|R4|0|A4|0|B3|0|G3|0|R3|0|A3]
    punpcklwd xmm9, xmm6        ; xmm9 = [0|0|0|B3|0|0|0|G3|0|0|0|R3|0|0|0|A3]
    punpckhwd xmm11, xmm6        ; xmm11 = [0|0|0|B4|0|0|0|G4|0|0|0|R4|0|0|0|A4]
    
    psubd xmm7,xmm11
    psubd xmm4,xmm9
    psubd xmm5,xmm10
    psubd xmm3,xmm2

    cvtdq2ps xmm3, xmm3         ; xmm3 = [B1 float|G1 float|R1 float|A1 float]
    cvtdq2ps xmm5, xmm5         ; xmm5 = [B2 float|G2 float|R2 float|A2 float]
    cvtdq2ps xmm4, xmm4         ; xmm4 = [B3 float|G3 float|R3 float|A3 float] 
    cvtdq2ps xmm7, xmm7         ; xmm7 = [B4 float|G4 float|R4 float|A4 float]   
    mulps xmm3, xmm0            ; xmm3 = [alpha * B1 float | alpha * G1 float | alpha * R1 float | alpha * A1 float] 
    mulps xmm5, xmm0            ; xmm5 = [alpha * B2 float | alpha * G2 float | alpha * R2 float | alpha * A2 float]
    mulps xmm4, xmm0            ; xmm4 = [alpha * B3 float | alpha * G3 float | alpha * R3 float | alpha * A3 float]
    mulps xmm7, xmm0            ; xmm7 = [alpha * B4 float | alpha * G4 float | alpha * R4 float | alpha * A4 float]
    divps xmm3, xmm8            ; xmm3 = [(alpha * B1 float) / 255.0 | (alpha * G1 float) / 255.0 | (alpha * R1 float) / 255.0 | (alpha * A1 float)/255.0]
    divps xmm5, xmm8            ; xmm4 = [(alpha * B2 float) / 255.0 | (alpha * G2 float) / 255.0 | (alpha * R2 float) / 255.0 | (alpha * A2 float)/255.0]
    divps xmm4, xmm8            ; xmm5 = [(alpha * B3 float) / 255.0 | (alpha * G3 float) / 255.0 | (alpha * R3 float) / 255.0 | (alpha * A3 float)/255.0]
    divps xmm7, xmm8            ; xmm7 = [(alpha * B4 float) / 255.0 | (alpha * G4 float) / 255.0 | (alpha * R4 float) / 255.0 | (alpha * A4 float)/255.0]
    cvtps2dq xmm3, xmm3
    cvtps2dq xmm4, xmm4
    cvtps2dq xmm5, xmm5
    cvtps2dq xmm7, xmm7 ; Convierto de float a entero

    paddd xmm7,xmm11
    paddd xmm4,xmm9
    paddd xmm5,xmm10
    paddd xmm3,xmm2

    packusdw xmm3, xmm6
    packuswb xmm3, xmm6         ;[ -           |             |            |  PIXEL 1 NUEVO]

    packusdw xmm4, xmm6
    packuswb xmm4, xmm6         ;[-|-|-|PIXEL 2 NUEVO]

    packusdw xmm5, xmm6         
    packuswb xmm5, xmm6         ;[-|-|-|PIXEL 3 NUEVO]

    packusdw xmm7, xmm6
    packuswb xmm7, xmm6         ;[-|-|-|PIXEL 4 NUEVO]  

    pslldq xmm4, 8              ; xmm4 = [ -           |             |PIXEL 2 NUEVO|              -]
    pslldq xmm5, 4              ; xmm5 = [ -           |PIXEL 3 NUEVO|             |              -]
    pslldq xmm7, 12             ; xmm7 = [PIXEL 4 NUEVO|             |             |              -]
    paddd xmm3,xmm4             ; xmm3 = [ -           |             |PIXEL 2 NUEVO|  PIXEL 1 NUEVO]
    paddd xmm3,xmm5             ; xmm3 = [ -           |PIXEL 3 NUEVO|PIXEL 2 NUEVO|  PIXEL 1 NUEVO]
    paddd xmm3,xmm7             ; xmm3 = [PIXEL 4 NUEVO|PIXEL 3 NUEVO|PIXEL 2 NUEVO|  PIXEL 1 NUEVO]
    ;paddusb xmm3,xmm2           ; xmm3 = xmm3 + IsrcB
    
    mov eax, r11d               ; eax = y
    mov ebx, r8d                ; ebx = src_row_size
    mul ebx                     ; eax = src_row_size * y 
    add eax, r8d                ; eax = src_row_size * y + src_row_size // estoy al final de la fila
    sub eax, 16                 ; eax = src_row_size * y + src_row_size - 16 //resto 16 asi ahora estaria agarrando los ultimos cuatro pixels de la fila 
    sub eax, r10d               ; eax = src_row_size * y + src_row_size - 16 - x // resto x para quedar en el que corresponda
    shl rax, 32                 ; Limpio parte alta de rax
    shr rax, 32
    movdqu [rsi + rax], xmm3    ; [[dst + (src_row_size * y + src_row_size - 16 - x)] = xmm3
    add r10d, 16                ; r10d = x = x + 16
    jmp ciclo_x
fin_ciclo_x:

    inc r11d                    ; r11d = y = y + 1
	mov eax, r13d               ; eax = filas
    mov ebx, r11d       
    cmp eax, ebx
    jne ciclo_y
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
	;sub rsp, 8

	;call combinar_c

	;add rsp, 8

	ret
