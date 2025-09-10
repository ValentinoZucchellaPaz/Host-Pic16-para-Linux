list p=16F887
#include <p16f887.inc>


;---------------------------------
; VARIABLES
;---------------------------------
	cblock 0x20
		R1
		R2
	    R3
	    
	    prev_btn	    ; valor previo de boton
	    tmp		    ; var temp para poner valor btn mientras uso W
	    
        index	    ; indice que mueve tabla kitt
	    
	    kitt_sel	    ; 0 contador, 1 secuencia kitt
	    counter	    ; var donde guardo contador
	endc

;---------------------------------
; RESET VECTOR
;---------------------------------
        org 0x00
        goto main
	org 0x05


;---------------------------------
; PROGRAMA PRINCIPAL
;---------------------------------
main
	banksel TRISB
	clrf TRISB	    ; Puerto B como salida
	banksel TRISA
	movlw 0xFF	    ; Puerto A como entrada
	movwf TRISA
	banksel ANSEL	    ; Puerto A digital
	clrf ANSEL
	banksel ANSELH	    ; Puerto B digital
	clrf ANSELH
	banksel PORTB	    ; Leds comienzan apagados
	clrf PORTB

	clrf prev_btn
	clrf tmp
	clrf index
	clrf kitt_sel	    ; comienza contador
	clrf counter

LOOP
	; Chequea cambio de flanco de boton, luego depende de kitt_sel si hace cuenta o si hace secuencia kitt
	CALL	CAMBIO_FLANCO
	BTFSC	kitt_sel, 0
	call	KITT
	call	INCREMENT_COUNTER
	GOTO	LOOP

	
; La nueva forma es que no es necesario un antirebote porque la exe del programa en si es uno
; no se leen los rebotes, se lee una vez el boton y luego exe contador/kitt (200ms implicitos), luego vuelve a leer
CAMBIO_FLANCO		     
; Leer botón (RA4)
    MOVF    PORTA, W
    ANDLW   b'00010000'      ; aislar bit 4
    MOVWF   tmp

    ; Comparar con valor previo
    MOVF    prev_btn, W
    XORWF   tmp, W
    BTFSC   STATUS,Z         ; ¿son iguales?
    RETURN                   ; nada cambió → salir

    ; Hubo un cambio → guardar nuevo estado
    MOVF    tmp, W
    MOVWF   prev_btn

    ; Chequear si fue flanco descendente (prev=1, actual=0)
    ; Nota: en este punto W=tmp (actual)
    BTFSS   STATUS,Z         ; si actual=0 (Z=1) → flanco descendente
    RETURN

    ; Toggle de kitt_sel
    CALL TOGGLE_KITT
    RETURN
	
INCREMENT_COUNTER
	incf	counter, f
	movf	counter, w
	movwf	PORTB
	call RET_100MS
	goto LOOP
	
TOGGLE_KITT
	; reset de contador y secuencia kitt
	movlw	0x00
	movwf	counter
	movwf	index
	incf	kitt_sel
	movlw	0x01
	andwf	kitt_sel, f	; mascara para mantener valor entre 0 y 1 siempre
	return

KITT
	movf	index, w
	call	PATRONES_KITT
	movwf	PORTB

	call RET_100MS

	incf index, f
	movlw d'18'       ; cantidad de patrones
	subwf index, w
	btfss STATUS, Z
	GOTO LOOP
	clrf index
	GOTO LOOP

;---------------------------------
; RETARDOS
;---------------------------------	
RET_100MS		    ; tarda ~100ms
	MOVLW   d'5'	    ; Repito 5 veces a RET_20MS
	MOVWF   R3
D2	CALL	RET_20MS
	DECFSZ	R3,f
	GOTO	D2
	RETURN
	

RET_20MS		    ; tarda ~20ms
	MOVLW   0xFF	    ; R1=255 R2= 26
	MOVWF   R1
	MOVLW   d'26'
	MOVWF   R2

D1
	DECFSZ  R1, f
	GOTO    D1

	DECFSZ  R2, f
	GOTO    D1
	RETURN
;---------------------------------
; TABLA DE PATRONES
;---------------------------------
PATRONES_KITT 
	addwf PCL, f
	retlw b'10000000'
	retlw b'11000000'
	retlw b'11100000'
	retlw b'01110000'
	retlw b'00111000'
	retlw b'00011100'
	retlw b'00001110'
	retlw b'00000111'
	retlw b'00000011'
	retlw b'00000001'
	retlw b'00000011'
	retlw b'00000111'
	retlw b'00001110'
	retlw b'00011100'
	retlw b'00111000'
	retlw b'01110000'
	retlw b'11100000'
	retlw b'11000000'
	return
	
end
