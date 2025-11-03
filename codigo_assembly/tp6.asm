list p=16F887
#include <p16f887.inc>
    
    ;TP6: ADC con potenciometro
    ; conectamos un potenciometro como divisor resistivo al ADC
    ; convertimos la señal anlogica
    ; representamos en display 7 segmentos (de 255 -> 15)
    
    ;Defino variables a usar
    r1		    EQU 0X20	; CONTADOR

    
    
    ORG	    0x00
    GOTO    MAIN
    
    ORG	    0x04
    GOTO    ISR
    
    ORG	    0x05

MAIN
    ; PORT A YA COMIENZA COMO ENTRADA ANALOGICA
    BANKSEL TRISD
    CLRF    TRISD		; PORTD: SALIDAS
    
    BSF	    PIE1, ADIE		; HABILITO INTERRUPCION ADC
    MOVLW   B'00000000'
    MOVWF   ADCON1		; RES JUSTIFICADO A IZQ (MSB EN ADRESH), Vref+=VCC, Vref-=VSS
    
    BANKSEL PORTD
    CLRF    PORTD

    ; GIE = 1 (HABILITO INTERRUPCIONES), PEIE = 1 (HABILITO INTERRUPCION POR PERIFERICOS OSEA ADC) 
    BSF	    INTCON, GIE
    BSF	    INTCON, PEIE
    BCF	    PIR1, ADIF		; LIMPIO FLAG ADC
    
    MOVLW   B'10000001'		; SELECCIONO CANAL 0 (AN0), PONGO Fosc/32 = 4MHz/32 -> Tad = 8us, GO/*DONE=0, ADON=1
    MOVWF   ADCON0
    
; INICIO_ADC
    CALL    RETARDO_25us    ; RETARDO DE S/H
    BSF	    ADCON0, 1	    ; GO=1
    
;--------- LOOP PRINCIPAL ------------------------------   
LOOP
    nop
    GOTO    LOOP
    
;--------- RETARDO PARA CARGA SAMPLE & HOLD ------------
RETARDO_25us	            ; tarda 23us a Finstruccion = 1us + 2 del CALL = 25us
        ;MOVLW   0x06	    ; 1us
        ;MOVWF   r1	    ; 1us
	;NOP		    ; 1us
	;NOP		    ; 1us

    ;D1
        ;DECFSZ  r1, f	    ; (5+2) x 1us = 7us
        ;GOTO    D1	    ; 5 x 2us = 10us

	nop
	nop
	nop
	RETURN		    ; 2us
 

;--------- RUTINA DE INTERRUPCION ----------------------
    
ISR
    ; PASO ADRESH -> W -> (255 -> 15) -> 7SEGMENTOS
    ; PARA PASAR DE 255->8 ME QUIERO QUEDAR CON LOS 4 BITS MSB
    ; cada nivel es de 5V/15 = 0,33V
    SWAPF   ADRESH, W
    ANDLW   B'00001111'
    CALL    TABLA_7SEG
    MOVWF   PORTD

 ;--------- RESTAURO EL ENTORNO ------------------------
SALIR_ISR
    BCF	    PIR1, ADIF	    ; LIMPIO FLAG INTERRUPCION ADC
    
;INICIO ADC
    CALL    RETARDO_25us    ; RETARDO DE S/H
    BSF	    ADCON0, 1	    ; GO=1
    
    RETFIE		    ;TERMINO LA INTERRUPCION

    
TABLA_7SEG		; rd0 se deja siempre en 0
	ADDWF   PCL, F
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
	RETLW   b'11101110' ; A
	RETLW   b'11111000' ; b
	RETLW   b'01110010' ; C
	RETLW   b'10111100' ; d
	RETLW   b'11110010' ; E
	RETLW   b'11100010' ; F
	RETURN
    END