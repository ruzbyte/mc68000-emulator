; Variablen
	ORG $0800
N:	DC.L 2
RESULT:	DS.L 1 		

	ORG $1000
; pow2(n)
Pow2
	MOVE.L D0,-(A7) 	; D0 (Ergebnis) auf Stack retten 
	MOVE.L D1,-(A7) 	; D1 (n) auf Stack retten 
	; LINK A5,#-4 		; Speicherbereich für lokale Variable 'n' anlegen

	MOVE.L 12(A7),D0 	; lade n von Stack
	; MOVE.L D0,-4(A5) 	; lokale Variable anlegen, S.Folie
	
	; IF N == 0 RET 1 (Basisfall)
	TST.L D0
	BEQ .Ret_Base

	; IF N > 0 
	SUBI.L #1,D0 		; n = n-1
	MOVE.L D0,-(A7) 	; n-1 auf stack
	BSR Pow2 		; Rekursiver Aufruf pow2(n-1)

	MOVE.L (A7)+,D1 	; Ergebnis in D1 schreiben
	MOVE.L #2,D0 		; Move 2 in D0
	MULU.W D0,D1 		; 2*2^n-1
	
	MOVE.L D1,12(A7) 	; Ergebnis auf Stack schieben
	JMP .Ret

; RETURN_BASE() => 1
.Ret_Base
	MOVE.L #1,12(A7) 	; 1 auf Stack schieben

; RETURN() 
.Ret
	; UNLK A5 		; free(*A5)
	MOVE.L (A7)+,D1 	; Stack Ergebnis auf D1 schieben
	MOVE.L (A7)+,D0 	; 
	RTS 			; Return

; int(void) main
START:
	; MOVE.L N,D1 		; Exponent n aus Hauptspeicher laden
	MOVE.L N,-(A7) 	; Parameter 'n' auf den Stack pushen 
	BSR Pow2 		; Subroutine Pow2(n) aufrufen

	MOVE.L (A7)+,D0 	; Ergebnis 2^n vom Stack holen 
	MOVE.L D0,RESULT 	; Ergebnis in Hauptspeicher schreiben
	
	MOVE.L #9,D1 		; Programmende
	TRAP #15
	
	END START

	
; a) 4Bytes N, 4 Bytes RESULT = 8 Bytes
; b) 1188 Zyklen
; c) recursion_pow2(2,4) -> recursion_pow2(2,3) -> recursion_pow2(2,2) -> recursion_pow2(2,1) -> recursion_pow2(2,0)
; d) Der Wert der Rechnung geht verloren, 
; weshalb ich eine Extra Variable VALUE zum zwischenspeichern nehme, 
;alternativ auf Stack schieben statt in VALUE zu schreiben 

;(SP ->) | Lokale Var. n=0 (-4,A5) | <- Stack Frame für Pow2(0)
;        |-------------------------|
;        | Gespeichertes A5        |
;        |-------------------------|
;        | Gespeichertes D1        |
;        |-------------------------|
;        | Gespeichertes D0        |
;        |-------------------------|
;        | Rücksprung-Adresse      | (zu Pow2(1))
;        |-------------------------|
;        | Parameter n=0           | (20(A7))
;        |-------------------------|
;        | Lokale Var. n=1 (-4,A5) | <- Stack Frame für Pow2(1)
;        |-------------------------|
;        | Gespeichertes A5        |
;        |-------------------------|
;        | Gespeichertes D1        |
;        |-------------------------|
;        | Gespeichertes D0        |
;        |-------------------------|
;        | Rücksprung-Adresse      | (zu Pow2(2))
;        |-------------------------|
;        | Parameter n=1           |
;        |-------------------------|
;        | ... (Frames für Pow2(2) |
;        |      und Pow2(3)) ...   |
;        |-------------------------|
;        | Gespeichertes D1        |
;        |-------------------------|
;        | Gespeichertes D0        |
;        |-------------------------|
;        | Rücksprung-Adresse      | (zu START)
;        |-------------------------|
;(Hoch)  | Parameter n=4           | (von START gepusht)


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
