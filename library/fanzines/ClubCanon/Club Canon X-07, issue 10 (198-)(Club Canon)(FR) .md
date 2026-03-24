# Club Canon X-07, issue 10 (198-)(Club Canon)(FR)

___
## Introduction



___
## Sommaire

Absent. Oubli de scan ?
À faire et ajouter.

___
## Les Listings

Ajout d'espace pour lisibilité et corrections.

<p align="center">────────────────────</p>

### Page 4

DAO.

```basic

```

<p align="center">────────────────────</p>

### Page 6

DAO ?

```basic

```

<p align="center">────────────────────</p>

### Page 9

ROOTS.

```basic

```

<p align="center">────────────────────</p>

### Page 11

ROBOT D'APPEL.

```basic

```


<p align="center">────────────────────</p>


### Page 12

Au vieux Canon.

Attente d'une touche. Plusieurs solutions.

```basic
1000 IF INKEY$="" THEN 1000
```

```basic
1000 POKE 43,4
```

```asm
#DE		CALL $C8C5
		LD(#AD).A
		RET
#AD		DEFB $FF
```

Validité d'une date :

```basic
10 INPUT "Date à tester JJ/MM/AA";A$
20 B$=DATE$
30 C$="19"+ RIGHT$(A$,2) + "/" + MID$(A$,4,3) + LEFT$(A$,2)
40 ON ERROR GOTO 70
50 DATE$=C$: PRINT"Ok, date valide"
60 DATE$="19"+LEFT$(B$,8): END
70 PRINT"Date invalide": END
```

<p align="center">────────────────────</p>

### page 13

```asm
#CO		PUSH BC
		PUSH DE
		PUSH HL
#B1		LD A,B
		OR C
		JR Z,#B2
		DEC BC
		LD A,(BC)
		CP (HL)
		JR NZ,#B2
		INC HL
		INC DE
		JR #B1
#B2		POP HL
		POP DE
		POP BC
		RET
```

```asm
#FI		PUSH HL
		SBC HL,DE
		POP HL
		JR Z,#EG
		CALL #CO
		RET Z
#EG		INC HL
		RET C
		PUSH HL
		RXX
		POP HL
		SBC HL,DE
		RET NC
		JE FI
```


<p align="center">────────────────────</p>

### Page 15

Un peu de musique.

NDR :
- ligne 35 sur ligne 30
- ligne 35 incomplète

```basic
10 DEFSNG A-Z: OUT243,0: OUT242,0: OUT244,0: O=1
15 Z$=INKEY$: IF Z$="" THEN CLS ELSE Z=INSTR("ZSXDCVGBHNJM.;/?]",Z$)
20 IF ASC(Z$)=31 THEN IF O<8 THEN O=O*2
25 IF ASC(Z$)=30 THEN IF O>.125 THEN O=O/2
30 IFZ=0 THEN 15 ELSE GOSUB 200: X=19200/FR*O
35 OUT242,XMOD256: OUT243,X\256: OUT 244,78: IF TKEY...
200 IF Z>9 THEN 202 ELSE ON Z GOTO 205,210, 215,220,225,230,2 35,240, 245
202 ONZ-9QJID250,2 55,260, 265,270,275,280,285, 290,295
205 FR=523.25: RETURN
210 FR=554.37: RETURN
215 FR=587.33: RETURN
220 FR=622.25: RETURN
225 FR=659.26: RETURN
230 FR=698.46: RETURN
235 FR=739.99: RETURN
240 FR=783.99: RETURN
245 FR=830.61: RETURN
250 FR=880: RETURN
255 FR=932.33: RETURN
260 FR=987.77: RETURN
265 FR=1046.50: RETURN
270 FR=1108.73: RETURN
275 FR=1174.66: RETURN
280 FR=1244.51: RETURN
285 FR=1318.51: RETURN
290 FR=1396.91: RETURN
295 FR=1479.98: RETURN
```

Calcul des FR.

```basic
200 FR=440*2-((Z+2)/12): RETURN
```

<p align="center">────────────────────</p>

### Page 16

Saisie des programmes sur Minitel.

```basic
5 CLEAR256: INIT#2,"COM:",1263,"G": PRINT#2,CHR$(27)":iC"
6 'X=INP(#2): PRINT X;: GOTO 6
10 FOR A=1 TO 4: X=INP(#2): NEXT A: OUT#2,12: PRINT#2
15 PRINT#2,CHR$(31)"@A";"   SAISIE DES PRGRAMMES SUR MINITEL"
20 PRINT#2,"Taille en octets du programme ?": OUT#2,17: GOSUB 40: TF=VAL(X$): X$=""
25 OUT#2,12: OUT#2,27: OUT#2,67: PRINT#2
30 INIT#5,"PROG",TF,"D"
35 GOSUB 40: X$="": CL=0: GOTO 35
40 Y=0: X=INP(#2)
45 IF X=19 THEN Y=INP(#2)
50 IFY <>6S THEN 60 ELSE OUT#2,10: OUT#2,13: IF X$="FIN" THEN 100
53 IF TF THEN PRINT#5,X$
55 RETURN
60 IF Y=71 THEN OUT#2,8: OUT#2,32: OUT#2,8: X$=LEFT$(X$,CL-1): CL=CL-1: GOTO 40
70 IF Y<>0 THEN OUT#2,7: GOTO 40
80 X$=X$+CHR$(X): CL=CL+1: IF CL>79 THEN OUT#2,7
90 GOTO 40
100 OUT#2,7: OUT#2,12: EXEC &HEE1F
```

___
