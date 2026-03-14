# Son du Canon - Club C7 - Numéro 4

Juillet Août 1985

___
## Introduction

TO DO

___
## Les Listings

TO DO


### page 7

Solitaire.

Data et 2 listings.

Le master :

```basic
1 '*** PROGRAMME 2 ***
10 CLEAR 50,&H7FF
20 INIT#1,"CASI:"
30 INPUT#1,N$,D,F: MOTOR
50 PRINT"Trouv :";N$
60 FOR I=D-1 TO F
70 POKE I,INP(#1): NEXT: MOTOR: END
100 CLEAR 50,&H7FF
110 D=&H800 : F=&H11D5
120 N$="SOL": INIT#1,"CASO:": INPUT"Magnto OK";T$
140 PRINT#1,N$,D,F: MOTOR
150 FOR I=1 TO 1800: NEXT
160 FOR I=D TO F: OUT#1,PEEK(I): NEXT: MOTOR: END
```

Le chargeur :

```basic
1 ' *** PROGRAMME 1 ***
10 CLEAR 50,&H7FF: A=&H800
20 PRINT HEX$(A);" : ";: INPUT C$
30 V=VAL("&H"+C$): POKE A,V
49 A=A+1: IF A>&H11D5 THEN PRINT "TERMINE ...": BEEP 2,3: END
50 GOTO 20
```


### page 25

Tri en LM.


### page 26

Camemberts.


### page 27


Routines BEEP

```asm
DEBUT		LD HL,RETOUR			; adresse de retour du 1er appel
			PUSH HL					; empilage
			LD IX,20H				; fréquence de la 1ère note
			LD HL,200H				; L doit être nul
			CALL C2DFH				; début de l'émission du son

RETOUR		LD HL,(OEH)				; 
			LD A,H					; boucle d'attente de fin
			OR L					; d'émission de la 1ère note
			JR NZ, RETOUR			; 
			LD HL,RET1				; 
			PUSH HL					; 
			LD IY,10H				; 
			LD HL,500H				; 
			CALL C2DFH				; émission de la 2ème note

RET1		suite du programme			
```

### page 31

Pentomino

Data et 2 listings.

Le master :

```basic
1 '*** PROGRAMME 2 ***
10 CLEAR 50,&H7FF
20 INIT#1,"CASI:"
30 INPUT#1,N$,D,F: MOTOR
50 PRINT"Trouv :";N$
60 FOR I=D-1 TO F
70 POKE I,INP(#1): NEXT: MOTOR: END
100 CLEAR 50,&H7FF
110 D=&H800 : F=&H159A
120 N$="SOL": INIT#1,"CASO:": INPUT"Magnto OK";T$
140 PRINT#1,N$,D,F: MOTOR
150 FOR I=1 TO 1800: NEXT
160 FOR I=D TO F: OUT#1,PEEK(I): NEXT: MOTOR: END
```

Le chargeur :

```basic
1 ' *** PROGRAMME 1 ***
10 CLEAR 50,&H7FF: A=&H800
20 PRINT HEX$(A);" : ";: INPUT C$
30 V=VAL("&H"+C$): POKE A,V
49 A=A+1: IF A>&H159A THEN PRINT "TERMINE ...": BEEP 2,3: END
50 GOTO 20
```

### page 35

Interruptions - interdiction break



___