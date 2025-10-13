list p=16F887
#include <p16f887.inc>
    
    ;TP5: teclado que ponga tecla en display
    ;teclado conectado a portb para que manejar interrupciones mejor
    ;display conectado a portD
    
    ;Defino variables a usar
    W_C0            EQU 0x21
    W_C1            EQU 0x22
    W_C2            EQU 0x23
    W_C3            EQU 0x24
    r1		    EQU 0X25
    r2		    EQU 0X26

    
    
    ORG	    0x00
    GOTO    MAIN
    
    ORG	    0x04
    GOTO    ISR
    
    ORG	    0x05

MAIN    
    BANKSEL ANSELH 
    CLRF    ANSELH		; PORTB digital
    
    BANKSEL TRISB
    
    MOVLW   B'11110000'
    MOVWF   TRISB		; PORTB: 0-3 SALIDAS Y 4-7 ENTRADAS
    
    CLRF    TRISD		; PORTD: SALIDAS
    
    MOVLW   B'11110000'
    MOVWF   IOCB                ; SOLO LOS BITS 4-7 PUEDEN GENERAR LA INTERRUPCION
    
    ; ---- Configurar WPUB (pull-ups individuales) ----
    ;BANKSEL WPUB
    ;movlw b'11110000'   ; activar weak-pullup en RB7..RB4
    ;movwf WPUB
    
    ; ---- Habilitar pull-ups globales: nRBPU = 0 en OPTION_REG ----
    ;BANKSEL OPTION_REG
    ;bcf OPTION_REG, 7   ; RBPU = 0 => pull-ups habilitadas por WPUB
    
    BANKSEL PORTB 
    MOVF    PORTB, W		; limpio latch
    MOVLW   B'00001111'		; debo poner RB0:RB3 en 0 para que funcione hardware
    MOVWF   PORTB
    CLRF    PORTD

    
    ;MOVLW   B'10001000'
    ;MOVWF   INTCON		; GIE = 1 (HABILITO INTERRUPCIONES), RBIE = 1 (HABILITO INTERRUPCION POR CAMBIO EN PORTB) 
    BSF	    INTCON, GIE
    BSF	    INTCON, RBIE
    
    
;--------- LOOP PRINCIPAL ------------------------------   
LOOP
    ;SLEEP
    ;NOP
    GOTO    LOOP
    
;--------- RETARDO ANTIREBOTE --------------------------
RETARDO_5MS	            ; tarda ~5ms = 5,372ms a Finstruccion = 1us
        MOVLW   0xFF	    ; COUNT1=255 COUNT2 = 7
        MOVWF   r1
        MOVLW	d'7'
        MOVWF   r2

    D1
        DECFSZ  r1, f
        GOTO    D1

        DECFSZ  r2, f
        GOTO    D1
        
	RETURN
 

;--------- RUTINA DE INTERRUPCION ----------------------
    
ISR
    ; SI NO HAY NINGUNA COL PRESIONADA ENTONCES VUELVE SIN HACER NADA
    CALL RETARDO_5MS		; ANTIREBOTE
    
    BCF	    PORTB,0
    BCF	    PORTB,1
    BCF	    PORTB,2
    BCF	    PORTB,3		;SETEO LAS 4 SALIDAS EN 0
    
;--------- TESTEO COLUMNA 3 (cuarta) ----------------------------
    BSF	    PORTB,0		;SALIDAS = 0001
    
    MOVF    PORTB, W
    ANDLW   b'11110000'
    BTFSS   STATUS, Z		;SI NO HUBO NINGUNA TECLA PRESIONADA EN LA COLUMNA 3 -> Z = 0
    GOTO    COLUMNA3		;VOY A COLUMNA3 PARA AVERIGUAR QUE TECLA DE ESA COLUMNA FUE LA PRESIONADA
    
;--------- TESTEO COLUMNA 2 (tercera) ----------------------------
    BCF	    PORTB,0		
    BSF	    PORTB,1		;SALIDAS = 0010
    
    MOVF    PORTB, W
    ANDLW   b'11110000'
    BTFSS   STATUS, Z		;SI NO HUBO NINGUNA TECLA PRESIONADA EN LA COLUMNA 2 -> Z = 0
    GOTO    COLUMNA2		;VOY A COLUMNA2 PARA AVERIGUAR QUE TECLA DE ESA COLUMNA FUE LA PRESIONADA
    
;--------- TESTEO COLUMNA 1 (segunda) ----------------------------    
    BCF	    PORTB, 1
    BSF	    PORTB, 2		;SALIDAS = 0100
    
    MOVF    PORTB, W
    ANDLW   b'11110000'
    BTFSS   STATUS, Z           ;SI NO HUBO NINGUNA TECLA PRESIONADA EN LA COLUMNA 1 -> Z = 0
    GOTO    COLUMNA1		;VOY A COLUMNA1 PARA AVERIGUAR QUE TECLA DE ESA COLUMNA FUE LA PRESIONADA
    
;--------- TESTEO COLUMNA 0 (primera) ----------------------------
    BCF	    PORTB, 2
    BSF	    PORTB, 3		;SALIDAS = 1000
    
    MOVF    PORTB, W
    ANDLW   b'11110000'
    BTFSS   STATUS, Z		;SI NO HUBO NINGUNA TECLA PRESIONADA EN LA COLUMNA 0 -> Z = 0
    GOTO    COLUMNA0		;VOY A COLUMNA0 PARA AVERIGUAR QUE TECLA DE ESA COLUMNA FUE LA PRESIONADA

 ;--------- RESTAURO EL ENTORNO ------------------------
SALIR_ISR
 
    MOVLW   B'00001111'		; vuelvo a poner salidas en 1 para prox deteccion de teclas
    MOVWF   PORTB
    
    BCF	    INTCON, RBIF	;LIMPIO BANDERA DE INT EN PORTB -- SI NO LO HAGO ACA SE LO COME 1 VEZ Y APAGA LA 2DA (ENTRA DOBLE A LA INTERRUPCION)
    RETFIE			;TERMINO LA INTERRUPCION
    
    
;---------- VEO TECLAS DE LA COLUMNA 0 -----------------
COLUMNA0
    MOVWF   W_C0
    BTFSC   W_C0,4
    GOTO    TECLA_3_0
    BTFSC   W_C0,5
    GOTO    TECLA_2_0
    BTFSC   W_C0,6
    GOTO    TECLA_1_0
    BTFSC   W_C0,7
    GOTO    TECLA_0_0
    GOTO    SALIR_ISR
    
;---------- VEO TECLAS DE LA COLUMNA 1 -----------------
COLUMNA1
    MOVWF   W_C1
    BTFSC   W_C1,4
    GOTO    TECLA_3_1
    BTFSC   W_C1,5
    GOTO    TECLA_2_1
    BTFSC   W_C1,6
    GOTO    TECLA_1_1
    BTFSC   W_C1,7
    GOTO    TECLA_0_1
    GOTO    SALIR_ISR

;---------- VEO TECLAS DE LA COLUMNA 2 -----------------
COLUMNA2
    MOVWF   W_C2
    BTFSC   W_C2,4
    GOTO    TECLA_3_2
    BTFSC   W_C2,5
    GOTO    TECLA_2_2
    BTFSC   W_C2,6
    GOTO    TECLA_1_2
    BTFSC   W_C2,7
    GOTO    TECLA_0_2
    GOTO    SALIR_ISR
    
COLUMNA3
    MOVWF   W_C3
    BTFSC   W_C3,4
    GOTO    TECLA_3_3
    BTFSC   W_C3,5
    GOTO    TECLA_2_3
    BTFSC   W_C3,6
    GOTO    TECLA_1_3
    BTFSC   W_C3,7
    GOTO    TECLA_0_3
    GOTO    SALIR_ISR
    
;------ PARA CADA TECLA LLAMO CORRESPONDIENTE NUM DE TABLA  Y RETORNO A SALIDA, EN SALIDA SE CARGA A PORTD---------
;------ TECLA_FILA_COL ---------
    
TECLA_0_0
    MOVLW   d'1'
    CALL    GUARDAR
    GOTO    SALIR_ISR
    
TECLA_0_1
    MOVLW   d'2'
    CALL    GUARDAR
    GOTO    SALIR_ISR
    
TECLA_0_2
    MOVLW   d'3'
    CALL    GUARDAR
    GOTO    SALIR_ISR
    
TECLA_0_3
    MOVLW   0x0A
    CALL    GUARDAR
    GOTO    SALIR_ISR
    
TECLA_1_0
    MOVLW   d'4'
    CALL    GUARDAR
    GOTO    SALIR_ISR
    
TECLA_1_1
    MOVLW   d'5'
    CALL    GUARDAR
    GOTO    SALIR_ISR
    
TECLA_1_2
    MOVLW   d'6'
    CALL    GUARDAR
    GOTO    SALIR_ISR
    
TECLA_1_3
    MOVLW   0x0B
    CALL    GUARDAR
    GOTO    SALIR_ISR
    
TECLA_2_0
    MOVLW   d'7'
    CALL    GUARDAR
    GOTO    SALIR_ISR

TECLA_2_1
    MOVLW   d'8'
    CALL    GUARDAR
    GOTO    SALIR_ISR

TECLA_2_2
    MOVLW   d'9'
    CALL    GUARDAR
    GOTO    SALIR_ISR
   
TECLA_2_3
    MOVLW   0x0C
    CALL    GUARDAR
    GOTO    SALIR_ISR
   
TECLA_3_0
    MOVLW   0x0E
    CALL    GUARDAR
    GOTO    SALIR_ISR
    
TECLA_3_1
    MOVLW   0x00
    CALL    GUARDAR
    GOTO    SALIR_ISR
    
TECLA_3_2
    MOVLW   0x0F
    CALL    GUARDAR
    GOTO    SALIR_ISR
    
TECLA_3_3
    MOVLW   0x0D
    CALL    GUARDAR
    GOTO    SALIR_ISR
    
GUARDAR
    CALL    TABLA_7SEG
    MOVWF   PORTD	; pasar numero a portd
    RETURN
    
TABLA_7SEG		; rb0 se deja siempre en 0
	ADDWF PCL, F
	RETLW   b'01111110' ; 0
	RETLW   b'00001100' ; 1
	RETLW   b'10110110' ; 2
	RETLW   b'10011110' ; 3
	RETLW   b'11001100' ; 4
	RETLW   b'11011010' ; 5
	RETLW   b'11111010' ; 6
	RETLW   b'00001110' ; 7
	RETLW   b'11111110' ; 8
	RETLW   b'11011110' ; 9
	RETLW   b'10111110' ; A
	RETLW   b'11111000' ; B
	RETLW   b'01110010' ; C
	RETLW   b'10111100' ; D
	RETLW   b'00000010' ; * -> GUION EN EL TECHO
	RETLW   b'00010000' ; # -> GUION EN EL SUELO
	RETURN
    END