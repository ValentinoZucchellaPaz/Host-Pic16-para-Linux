list p=16F887
#include <p16f887.inc>
	
	CONTADOR EQU 0x20
	PREV     EQU 0x21
	COUNT1	 EQU 0x22
	COUNT2   EQU 0x23
    
	ORG 0x00
	GOTO MAIN
    
	ORG 0x05
	
MAIN
	BANKSEL ANSELH         
	CLRF ANSELH	    ;defino como digital el puerto B
	
	BANKSEL ANSEL         
	CLRF ANSEL	    ;defino como digital el puerto A
	
	BANKSEL TRISB     
	CLRF TRISB	    ;defino como salida el puerto B
	
	BANKSEL TRISA 
	MOVLW 0xFF
	MOVWF TRISA         ;defino como entrada el puerto A
	
	BANKSEL PORTB
	CLRF PORTB
	
	BANKSEL PORTA
	CLRF PORTA
	
	CLRF CONTADOR
	CALL MOSTRAR
	
CAMBIO_FLANCO		    ; como si fuera loop
	MOVF PORTA, W	    ; Pongo portA en W, luego paso a var PREV
	MOVWF PREV
	BTFSS PREV, 4	    ; Si PREV es 0, no cambia nada, si es 1 entonces me interesa
	GOTO CAMBIO_FLANCO
	CALL RET1           ; Pongo retardo antes de chequear si cambio como llave antirebote 
	BTFSC PORTA, 4	    ; Si antes tenia un 1, y luego un 0, hubo un flanco bajo, cuento
	GOTO CAMBIO_FLANCO
	CALL COUNT
	GOTO CAMBIO_FLANCO
	
RET1			    ; tarda ~50ms
        MOVLW   0xFF	    ; COUNT1=255 COUNT2 = 60
        MOVWF   COUNT1
        MOVLW    d'60'
        MOVWF   COUNT2

D1
        DECFSZ  COUNT1, f
        GOTO    D1

        DECFSZ  COUNT2, f
        GOTO    D1
        
	RETURN
	
COUNT
    INCF CONTADOR, F        ; incremento contador
    MOVF CONTADOR, W
    SUBLW d'10'             ; ¿ya llegó a 10?
    BTFSS STATUS, Z         ; si = 10, reseteo a 0
    GOTO MOSTRAR

    CLRF CONTADOR           ; vuelvo a 0 si llegué a 10

MOSTRAR
    MOVF CONTADOR, W        ; W = número actual
    CALL TABLA_7SEG         ; buscar patrón en tabla
    MOVWF PORTB             ; mandar al display
    RETURN
    
TABLA_7SEG		; Ultimo bit es el que enciende display
    ADDWF PCL, F
    RETLW   b'10111111' ; 0
    RETLW   b'10000110' ; 1
    RETLW   b'11011011' ; 2
    RETLW   b'11001111' ; 3
    RETLW   b'11100110' ; 4
    RETLW   b'11101101' ; 5
    RETLW   b'11111101' ; 6
    RETLW   b'10000111' ; 7
    RETLW   b'11111111' ; 8
    RETLW   b'11101111' ; 9
    RETURN
    
    END