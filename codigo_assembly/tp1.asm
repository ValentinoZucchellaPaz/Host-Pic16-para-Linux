;==========================
; Programa ejemplo PIC16F887
; Parpadeo de LED en RB0
;==========================

LIST P=16F887
    
#INCLUDE <p16f887.inc>
	
	CBLOCK 0x20
		COUNT1
		COUNT2
		COUNT3
	ENDC
	
        
        ORG 0x00               ; inicio
        GOTO MAIN
    
	ORG 0x05               ; Evito pasar por el vector de interrupcion
	
MAIN                           ;programa principal
        BANKSEL ANSELH         
	CLRF ANSELH            ;defino como digital el puerto B
	
	BANKSEL TRISB     
	CLRF TRISB             ;defino como salida el puerto B
	
	BANKSEL PORTB
	CLRF PORTB
	
LOOP	
	BSF PORTB, 0        ;comienzo entregando un 0 en RB0 para encender el led 
	
	CALL RETARDO           ;llamo a la subrutina de retardo de 1seg
	
	BCF PORTB, 0        ;entrego un 1 en RB0 para apagar el led
	
	CALL RETARDO           ;vuelvo a llamar a la subrutina de retardo de 1seg
	
	GOTO LOOP              ;vuelvo al loop de encendido/apagado
	
RETARDO
	MOVLW   0x05        ; COUNT3 = 5
        MOVWF   COUNT3

RET1
        MOVLW   0xFF
        MOVWF   COUNT1
        MOVWF   COUNT2

D1
        DECFSZ  COUNT1, f
        GOTO    D1

        DECFSZ  COUNT2, f
        GOTO    D1

        DECFSZ  COUNT3, f
        GOTO    RET1

        RETURN
	
	
	END