*-----------------------------------------------------------
* Titel:   Zufallszahlen (4 Stk) & Bubble Sort (FIXED)
* Autor:   Gemini
*-----------------------------------------------------------

*--- Konstanten ---
MAX_COUNT   EQU 16           ; Array Länge (Test auf 4)
CR          EQU 13	    ; CR steht für 13 (ASCII Zeilenumbruch Anfang)
LF          EQU 10          ; LF ASCII für Line Feed / Neue Zeile

*--- Vektoren ---
    ORG    $64              ; AV1 -> Würfeln
    DC.L   ISR_WURFELN
    ORG    $68              ; AV2 -> Abbruch
    DC.L   ISR_STOP

*--- Variablen ---
    ORG    $1000
ARRAY_START: DS.B    MAX_COUNT   ; Platz für n (hier 4) Bytes im Array
ANZAHL:      DC.W    0           ; Anzahl Elemente direkt dahinter speichern
FLAG_FERTIG: DC.W    0           
TXT_START:   DC.B    'Druecke I1 (16x).',CR,LF,'Eingabe: ',0
TXT_SORT:    DC.B    CR,LF,'Sortiert: ',0
TXT_KOMMA:   DC.B    ', ',0

*--- Programmstart ---
    ORG    $2000
START:
    CLR.L   D0              ; Zufalls-Zähler

    LEA     TXT_START,A1
    MOVE.B  #14,D0
    TRAP    #15
    
* Random generator, Bubble sort execute, wenn Array voll
W_LOOP:
    ADDQ.L  #1,D0           ; Zufall
    TST.W   FLAG_FERTIG
    BEQ     W_LOOP
    
    * Sortieren (Nur wenn Elemente da sind)
    MOVE.W  ANZAHL,D1
    EXT.L   D1
    CMPI.L   #1,D1
    BLE     SKIP_SORT       ; Bei 0 oder 1 Element nicht sortieren

    MOVE.L  D1,-(A7)        ; Param 2: Länge
    PEA     ARRAY_START     ; Param 1: Adresse
    BSR     BUBBLE_SORT
    ADDA.L  #8,A7

* Sort fertig
SKIP_SORT:
    * Ausgabe Header "Sortiert:"
    LEA     TXT_SORT,A1
    MOVE.B  #14,D0
    TRAP    #15

    * Ausgabe Array
    MOVE.W  ANZAHL,D1
    EXT.L   D1		    ; D1 auf 32Bit erweitern		
    CMP.L   #0,D1           ; Leer?
    BEQ     ENDE

    MOVE.L  D1,-(A7)        ; Param 2: Länge
    PEA     ARRAY_START     ; Param 1: Adresse
    BSR     PRINT_ARRAY
    ADDA.L  #8,A7

* Programmende
ENDE:
    MOVE.L  #9,D0
    TRAP    #15

*-----------------------------------------------------------
* ISR_WURFELN (AV1)
*-----------------------------------------------------------
ISR_WURFELN:
    MOVEM.L D0-D2/A0-A1,-(A7) ; Register retten 

    * Wenn größer/gleich Exit (0 abfangen)
    MOVE.W  ANZAHL,D1
    CMPI.W  #MAX_COUNT,D1
    BGE     AV1_SKIP
	
    * Array Adresse holen	
    LEA     ARRAY_START,A0
    MOVE.B  D0,0(A0,D1.W)   ; Speichern
    
    * Ausgabe Gewürfelte Zahl
    MOVE.L  D0,D1
    ANDI.L  #$FF,D1
    MOVE.B  #3,D0
    TRAP    #15
    LEA     TXT_KOMMA,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    
    * Anzahl Zahlen in Variable speichern
    MOVE.W  ANZAHL,D1
    ADDQ.W  #1,D1
    MOVE.W  D1,ANZAHL
    
    * Gucken ob fertig
    CMPI.W  #MAX_COUNT,D1
    BNE     AV1_SKIP
    MOVE.W  #1,FLAG_FERTIG

* Wenn Würfeln fertig, Register freigeben und RTE
AV1_SKIP:
    MOVEM.L (A7)+,D0-D2/A0-A1
    RTE

*-----------------------------------------------------------
* ISR_STOP (AV2)
*-----------------------------------------------------------
ISR_STOP:
    MOVE.W  #1,FLAG_FERTIG
    RTE

*-----------------------------------------------------------
* BUBBLE_SORT
*-----------------------------------------------------------
BUBBLE_SORT:
    LINK    A6,#0
    MOVEM.L D0-D4/A0-A1,-(A7)
    
    MOVE.L  8(A6),A0        ; Adresse
    MOVE.L  12(A6),D0       ; Länge N
    
    SUBQ.L  #2,D0           
    BMI     SORT_DONE       ; Wenn N < 2 war, fertig

BS_OUTER:
    MOVE.L  A0,A1           ; Reset Pointer auf Start
    MOVE.L  D0,D1           ; Inner loop counter = Outer counter
    
BS_INNER:
    MOVE.B  (A1),D2         ; Wert A
    MOVE.B  1(A1),D3        ; Wert B (Nachbar)
    
    CMP.B   D3,D2
    BLS     BS_NEXT         ; Wenn A <= B, alles gut
    
    * Swap
    MOVE.B  D3,(A1)
    MOVE.B  D2,1(A1)

BS_NEXT:
    ADDQ.L  #1,A1           ; Pointer eins weiter
    DBRA    D1,BS_INNER     ; Springe in inner mit dec
    DBRA    D0,BS_OUTER     ; Springe outer mit dec

* Register freigeben, stack clr, und rts, fertig
SORT_DONE:
    MOVEM.L (A7)+,D0-D4/A0-A1
    UNLK    A6
    RTS

*-----------------------------------------------------------
* PRINT_ARRAY
*-----------------------------------------------------------
PRINT_ARRAY:
    LINK    A6,#0
    MOVEM.L D0-D1/D7/A0-A1,-(A7) 

    MOVE.L  8(A6),A0        ; Adresse
    MOVE.L  12(A6),D7       ; Länge
    SUBQ.L  #1,D7
    BMI     PR_EXIT

PR_LOOP:
    CLR.L   D1
    MOVE.B  (A0)+,D1        ; Zahl laden, A0 zeigt danach aufs nächste Byte.
    MOVE.B  #3,D0           ; Print Number
    TRAP    #15
    
    LEA     TXT_KOMMA,A1
    MOVE.B  #14,D0          ; Print Komma
    TRAP    #15
    
    DBRA    D7,PR_LOOP

* Register freigeben, stack clr, fertig rts
PR_EXIT:
    MOVEM.L (A7)+,D0-D1/D7/A0-A1
    UNLK    A6
    RTS

    END     START
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
