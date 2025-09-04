        list p=16F887
        #include <p16f887.inc>


;---------------------------------
; VARIABLES
;---------------------------------
        cblock 0x20
            index
            R1
            R2
            R3
            prev	    ; guardo valor previo de boton
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

    clrf index
	clrf prev
	clrf kitt_sel	    ; comienza contador
	clrf counter

LOOP
	; Chequea cambio de flanco de boton, luego depende de kitt_sel si hace cuenta o si hace secuencia kitt
	CALL	CAMBIO_FLANCO
	BTFSC	kitt_sel, 0
	call	KITT
	call	INCREMENT_COUNTER
	GOTO	LOOP
	
CAMBIO_FLANCO
	; tengo un boton que si presiono 1 vez cambio entre contador y kitt
	MOVF	PORTA, w        ; Pongo portA en W, luego paso a var PREV
	MOVWF	prev
	BTFSS	prev, 4		; Si PREV es 0, no cambia nada, si es 1 entonces me interesa
	return
	CALL	RET_200MS	; Pongo retardo antes de chequear si cambio como llave antirebote 
	BTFSC	PORTA, 4        ; Si antes tenia un 1, y luego un 0, hubo un flanco bajo, cuento
	return
	; cambio kitt_sel (toggle) 
	call TOGGLE_KITT
	return
	
INCREMENT_COUNTER
	incf	counter, f
	movf	counter, w
	movwf	PORTB
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

        call RET_200MS

        incf index, f
        movlw d'19'       ; cantidad de patrones
        subwf index, w
        btfss STATUS, Z
        GOTO LOOP
        clrf index
        GOTO LOOP

;---------------------------------
; RETARDOS
;---------------------------------	
RET_200MS		    ; tarda ~200ms
        MOVLW   d'10'	    ; Repito 10 veces a RET_20MS
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
	retlw b'10000000'
	return
	
end
