*-----------------------------------------------------------
* Program    :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
		
	
	ORG $64	; Autovektor-Interrupt 1
	DC.L AV1_HANDLER
	ORG $68 ; Autovektor-Interrupt 2
	DC.L AV2_HANDLER
	ORG $84 ; Siehe Vektor S.25 Interrupts, Softwareinterrupt 1
	DC.L TRAP_1_HANDLER
	
	
	ORG $800

PUNKTE
	DS.L 1
GAMEOVER
	DS.L 1
	
	ORG	$1000
START:				
	MOVEQ #1, D2
	;MOVE.W #$2000, SR ; Supervisor Mode on
	CLR.L PUNKTE ; Punkte clearen
	CLR.L GAMEOVER
LOOP:	
	; Gucken ob spiel vorbei
	CMPI.L #21, PUNKTE
	BGT VERLOREN
	BEQ GEWONNEN
	
	CMPI.L #1, GAMEOVER
	BEQ EXIT

	CMPI.L #6, D2
	BNE NEXT
	TRAP #1
	
	JMP LOOP
NEXT:
	ADD.L #1, D2
	JMP LOOP		
	
EXIT:	
	; MOVEM.L (A7)+, D0-D1/A0-A1
	LEA TXT_END, A1
    	MOVE.L #14, D0
    	TRAP #15

	MOVE.B	#9,D0
	TRAP	#15		; halt simulator

GEWONNEN:
	LEA TXT_WIN, A1    ; Adresse des Textes in A1 laden
    	MOVE.L #14, D0      ; Task 14: String ausgeben
    	TRAP #15
    	JMP EXIT
    	
VERLOREN:
	LEA TXT_LOSE, A1
	MOVE.L #14, D0
	TRAP #15
	JMP EXIT

TRAP_1_HANDLER:
	MOVE.L #1, D2
	RTE

AV1_HANDLER:
		
	; MOVE.L D1, -(A7) ; D1 retten
	MOVEM.L D0-D1/A1, -(SP)
	
	;LEA PUNKTE, A0
	;MOVE.L (A0), D1
	MOVE.L PUNKTE, D1
	ADD.L D2, D1
	MOVE.L D1, PUNKTE
	
	LEA TXT_PUNKTE, A1	; Adresse vom Text in A1 laden
	MOVE.L #14, D0		; Task 14: String ausgeben
	TRAP #15

	; Jetzt die Zahl in D1 ausgeben
	MOVE.L #20, D0		; Task 20: Zahl in D1 als Dezimalzahl ausgeben
	TRAP #15
	
	; Einen Zeilenumbruch machen (für die Optik)
	LEA NEWLINE, A1
	MOVE.L #14, D0
	TRAP #15
	
	; MOVE.L D1, (A0)
			
	; MOVE.L (A7)+, D1 ; D1 wieder holen
	MOVEM.L (A7)+, D0-D1/A1
	RTE
	
AV2_HANDLER

	MOVEM.L D0-D1/A1, -(SP)
	
	MOVE.L #1, GAMEOVER
	
	MOVE.L PUNKTE, D1
	
	LEA TXT_FINAL, A1	
	MOVE.L #14, D0		
	TRAP #15

	MOVE.L #20, D0		
	TRAP #15
	
	LEA NEWLINE, A1
	MOVE.L #14, D0
	TRAP #15
	
	MOVEM.L (A7)+, D0-D1/A1
	
	RTE

* Variables and Strings
TXT_END:	DC.B 'Spiel Beendet', 13, 10, 0
TXT_PUNKTE:	DC.B 'Aktuelle Punkte: ', 0
TXT_FINAL	DC.B 'Ausgestiegen, Endergebnis: ', 0
TXT_WIN:	DC.B 'Glueckwunsch! GEWONNEN!', 13, 10, 0
TXT_LOSE:	DC.B 'Schade! VERLOREN!', 13, 10, 0
NEWLINE:	DC.B 13, 10, 0	

	END	START		; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
