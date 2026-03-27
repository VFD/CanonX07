# Son du Canon Le, issue 01 (198-)(Club C7)(FR)

___
## Introduction

Ce markdown à pour but de compiler les petits codes source de ce numéro.

NDR : 2 page sont manquantes.

___
## Sommaire

<pre>
EDITORIAL .....................................................  1
MAGIC CIRCUS (programme) ......................................  3
REVUE DE PRESSE ...............................................  5
LA LETTRE DE CANON ............................................  7
ENTREE DES CODES L.M. (Initiation) ............................  8
DACTYLO-FOLIE (Programme) ..................................... 11
INTERFACE X-720 (Banc d'Essai) ................................ 14
NOMBRES ALEATOIRES ET LANGAGE MACHINE (Initiation) ............ 16
BEEP SPECIAUX (Perfectionnement) .............................. 19
FONCTIONS GRAPHIQUES (initiation) ............................. 21
INFORMATION C7 ................................................ 25
L'INTERVIEW DE C7 ............................................. 26
PROGRAMMATHEQUE ............................................... 28
GEOMETRIE (Programme) ......................................... 30
KIT'APPEL (Banc d'Essai) ...................................... 32
ASTRO (Banc d'Essai) .......................................... 34
MATHS1 (Banc d'Essai) ......................................... 36
COOP. C7 ...................................................... 38
QUESTIONNAIRE ................................................. 39
TRUCS EN VRAC ................................................. 40
COURRIER ...................................................... 41
</pre>

___
## Les listings

___
### Page 4

Magic Circus :

Le programme est dans le répertoire [programs](/library/programs)


___
### Page 10 et 11

Dactylo Folie :

Les programmes sont dans le répertoire [programs](../../../programs)

___
### Page 16

Nombre Aléatoire

```basic
5 REM "GENERATEUR ALEATOIRE"
10 DATA 16,0,1E,0,ED,5F,6F,3A,6A,1F,AD,17,6F,ED,5F,AD,32,6A,1F,CD,48,1F,7C,3C
20 DATA 0,C3,56,1F,21,0,0,29,CB,27,D2,52,1F,19,C2,4B,1F,C9,32,26,1F,C9
30 RESTORE 10:FOR I=7980 TO 8025:READ A$:POKE I,VAL("&H"+A$):NEXT:CLEAR 50,7970
40 CLS:BEEP 5,2:INPUT "Nombre Maximal ";N:IF N<0 OR N>255 THEN 40
50 POKE 7983,N:EXEC 7980:CLS:PRINT "Nombre Aleatoire......";PEEK(7974)
60 FOR I=1 TO 4096:BEEP I,1:G$=INKEY$:IF G$="" THEN NEXT:GOTO 60
70 IF G$=" " THEN 40
80 IF G$=CHR$(13) THEN 50
90 CLS:BEEP 9,5:END
```

Le programme est aussi dans le répertoire [programs](../../../programs)

<p align="center">────────────────────</p>

```asm

org 1F2C

	LD D,00
	LD E,00
	LD A,R
	LD L,A
	LD A,(1F6A)
	XOR L
	RLA
	LD L,A
	LD A,R
	XOR L
	LD(1F6A),A
	CALL 1F48
	LD A,H
	INC A
	NOP
	JP 1F56
	LD HL,0000
	ADD HL,HL
	SLA A
	JPNC 1F52
	ADD HL,DE
	JPNZ 1F48
	RET
	LD (1F26),A
	RET
```




___
### Page 17

Tirage Loto

```basic
1 DATA 1,7,1F,AF,2,D,C2,1C,1F,1,7,1F,C3,2C,1F,D,C2,24,1F,C9,16,0,1E,31,ED,5F,6F
2 DATA 3A,6A,1F,AD,17,6F,ED,5F,AD,32,6A,1F,CD,48,1F,7C,3C,0,C2,56,1F,21,0,0,29
3 DATA CB,27,D2,52,1F,19,C2,4B,1F,C9,21,7,1F,BE,CA,2C,1F,2D,C2,59,1F,2,C3,27,1F
4 RESTORE 1:FOR I=7960 TO 8036:READ A$:POKE I,VAL("&H"+A$):NEXT:CLEAR 50,7900
8 BEEP 5,2:EXEC 7960:CLS:PRINT "******* LOTO *******"
10 LOCATE 0,1:FOR I=7938 TO 7943:PRINT STR$(PEEK(I));:NEXT:BEEP 9,2
15 LOCATE 0,2:PRINT "COMPLEMENTAIRE:";PEEK(7937)
20 G$=INKEY$:IF G$="" THEN 20
25 IF G$=CHR$(13) THEN 8 ELSE CLS:END
```

Le programme est aussi dans le répertoire [programs](../../../programs)

___
### Page 20

Programme No1 :

```basic
10 DEFINT A-Z:S=1:N=242
20 FORI=1TO48
30 BEEPI,S
40 NEXT
50 BEEP1,0
60 OUT243,0
70 OUT244,0
80 FORL=255TO0STEP-1
90 OUTN,L
100 NEXT
```

<p align="center">────────────────────</p>

Programme No2 :

```basic
10 DEFINT A-Z:S=1:N=242
20 OUT243,0:OUT244,78
30 FORL=0TO255
40 OUTN,L:OUTN,255-L
50 NEXT
```

<p align="center">────────────────────</p>

Programme surprise :
```basic
TO DO
```


___
### Page 21


Hypocycloïde :

```basic
```

<p align="center">────────────────────</p>

Hypocycloïde (inversion vidéo) :

```basic
```

<p align="center">────────────────────</p>

___
### Page 22


Utilitaire Graphique :

```basic
```

<p align="center">────────────────────</p>


```basic
```

<p align="center">────────────────────</p>


___
### Page 23

Télécran :

Le programme est dans le répertoire [programs](../../../programs)


___
### Page 30

Géométrie :

Le programme est dans le répertoire [programs](../../../programs)


___
### Page 42

Logiciel de jaquette K7 en plus sur la cassette.

Vérifier car on la peut-être.


EOF
___
