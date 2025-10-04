list p=16F887
#include <p16f887.inc>
	
	; regs que llevan la cuenta de cada display
	CONT1	 EQU 0x20
	CONT2	 EQU 0x21
	CONT3	 EQU 0x22
	CONT4	 EQU 0x23
	 
	; contadores de retardo
	r1	 EQU 0x24 
	r2	 EQU 0x25
	 
	; contador de timer para interrupcion cada 1s
	SEC_COUNT EQU 0x26
 
	W_TEMP      EQU 0x27   ; backup de W
	STATUS_TEMP EQU 0x28   ; backup de STATUS
    
	ORG 0x00
	GOTO MAIN
    
	ORG 0x04
	GOTO ISR
	
	ORG 0X20
    MAIN
	BANKSEL ANSELH         
	CLRF ANSELH	    ;defino como digital el puerto B
	
	BANKSEL ANSEL         
	CLRF ANSEL	    ;defino como digital el puerto A
	
	BANKSEL TRISB     
	CLRF TRISB	    ;defino como salida el puerto B
	bsf TRISB, 0        ; RB0 como entrada
	
	BANKSEL TRISA 
	CLRF TRISA          ;defino como salida el puerto A
	
	BANKSEL PORTB
	CLRF PORTB
	
	BANKSEL PORTA
	CLRF PORTA
	
	
	; configuracion de interrupciones -- en un futuro se agrega interrupciones por rbo0 osea se cambia
	; del optn_reg INTEDG Y TOSE
	; del intcon INTE
	BANKSEL OPTION_REG
	movlw b'01000111' ; (6) INTEDG=1 → flanco ascendente
			  ; (5) T0CS=0 -> usa reloj interno
			  ; (3) PSA=0 -> prescaler asignado a TMR0
		          ; (2:0) PS2:PS0=111 -> prescaler 1:256
	movwf OPTION_REG
	
	BANKSEL INTCON
	bsf INTCON, T0IE   ; habilito interrupción por TMR0
	bsf INTCON, INTE   ; habilito interrupción externa con pin rb0
        bsf INTCON, GIE    ; habilito interrupción global

	CLRF	CONT1
	CLRF	CONT2
	CLRF	CONT3
	CLRF	CONT4
	
	; inicializo contador de isr
	movlw d'15'
	movwf SEC_COUNT

    LOOP
	; ---- Display 1 ----
	call ApagarDisplays

	movf CONT1, W        ; cargar valor (0–9), llama tabla y pone valor en portb
	call TABLA_7SEG      
	movwf PORTB          

	bsf PORTA, 0         ; habilitar display 1 (RA0=1)
	call RET1            ; retardo (~5ms)

	; ---- Display 2 ----
	call ApagarDisplaysj

	movf CONT2, W
	call TABLA_7SEG
	movwf PORTB

	bsf PORTA, 1         ; habilitar display 2 (RA1=1)
	call RET1

	; ---- Display 3 ----
	call ApagarDisplays

	movf CONT3, W
	call TABLA_7SEG
	movwf PORTB

	bsf PORTA, 2         ; habilitar display 3 (RA2=1)
	call RET1

	; ---- Display 4 ----
	call ApagarDisplays

	movf CONT4, W
	call TABLA_7SEG
	movwf PORTB

	bsf PORTA, 3         ; habilitar display 4 (RA3=1)
	call RET1

	goto LOOP    
    
    ApagarDisplays
	clrf PORTA
	return
	
    
    RET1			    ; tarda ~5ms = 5,372ms a Finstruccion = 1us
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
	RETURN
	
	
    ISR
	; ---- Guardar contexto ----
	movwf   W_TEMP
	swapf   STATUS, W    ; pasar STATUS a W (swapf para no perder flags)
	movwf   STATUS_TEMP

	; ==== Interrupción por TMR0 ====
	btfsc   INTCON, T0IF      ; ¿bandera TMR0?
	call    TMR0_ISR

	; ==== Interrupción por RB0/INT ====
	btfsc   INTCON, INTF      ; ¿bandera RB0?
	call    RB0_ISR
	
    ISR_FIN
	; ---- Restaurar contexto ----
	swapf   STATUS_TEMP, W
	movwf   STATUS
	swapf   W_TEMP, F ; cambios dos veces para no afectar a STATUS al pasar a W
	swapf   W_TEMP, W
	retfie
	
    TMR0_ISR
	bcf     INTCON, T0IF      ; limpio bandera

	decfsz  SEC_COUNT, f
	return

	movlw   d'5'		  ; 15 interrupciones = ~1seg ; pongo menos para ver cambio rapido
	movwf   SEC_COUNT

	; ---- Aumentar CONT1..CONT4 ----
	incf    CONT1, f
	movlw   d'10'
	subwf   CONT1, W
	btfss   STATUS, Z
	return

	clrf    CONT1
	incf    CONT2, f
	movlw   d'6'		  ; poner en 6 si se quiere contar minutos
	subwf   CONT2, W
	btfss   STATUS, Z
	return

	clrf    CONT2
	incf    CONT3, f
	movlw   d'10'
	subwf   CONT3, W
	btfss   STATUS, Z
	return

	clrf    CONT3
	incf    CONT4, f
	movlw   d'6'		   ; poner en 6 si se quieren contar horas
	subwf   CONT4, W
	btfss   STATUS, Z
	return

	clrf    CONT4
	return
	
    RB0_ISR
	bcf INTCON, INTF     ; limpio bandera RB0
	call RET1	     ; retardo de 5ms para evitar rebote

	; ---- toggle TMR0 ----
	btfsc INTCON, T0IE   ; ¿está habilitado TMR0?
	goto apagar_T0IE     ; si si -> lo apago y vuelvo
	goto prender_T0IE    ; si no -> lo prendo y vuelvo
	
	
	
	   
    apagar_T0IE
	bcf INTCON, T0IE
	return
	
    prender_T0IE
	bsf INTCON, T0IE
	return


	END