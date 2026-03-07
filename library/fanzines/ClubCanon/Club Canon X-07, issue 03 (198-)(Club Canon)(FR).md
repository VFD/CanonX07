# Club Canon X-07, issue 03 (198-)(Club Canon)(FR)

___
## Introduction

Gazette numéro 3 du Club Canon X-07.\
Le sommaire est repris ci-après.\
Les listings sont aussi listés ici.

___
## Sommaire

- Editorial .............................. Page 1
- Des extensions pour votre X-07 .............. 2
- Des logiciels pour votre CANON X-07 ......... 3
- Nouveau et intéressant ...................... 4
- De la lecture pour votre X-07 ............... 5
- Le coin du bidouil1eur :
	- Inversion de l'écran .................... 6
	- Connection directe de deux X-07 ......... 7
	- Intégration numérique .................. 10
	- Bévues et matrice de clavier ........... 11
	- Utilitaire de mise en datas ............ 12
- Petites annonces ........................... 13
- Tribune libre .............................. 14
- Essai logiciel ............................. 15
- Nouvelles brèves ........................... 17

___
## Les listings

Ci après les listings du bulettin.


<p align="center">────────────────────</p>

### page 6

Inversion écran.

En basic :

```basic
10 FOR J=0 TO 31 FOR I=0 TO 119
20 IF POINT(I,J) THEN PRESET(I,J) ELSE PSET(I,J)
30 NEXT I,J
```

Version asembleur (Micro Systèmes No 49) :

```asm
10 ' [
20 'ORG $1B50
30 'PUSH AF								F5
40 'PUSH BC								C5
50 'PUSH DE								D5
60 'PUSH HL								E5
ïO 'LD IX,#DD							DD 21 8D 1B
80 'LD (IX+$0).$0						DD 36 00 00
90 'LD (IX+$1).$0 						DD 36 01 00
100 '#BB	LD A.$13					JE 13
110 '	LD B.$2							06 02
120 '	LD C.$0							0E 00
130 '	LD HL.#DD						DD 21 BD 1B
140 '	CALL $C92F						CD 2F C9
150 '	LD IX.#DD						DD 21 8D 1B
160 '	INC (IX+$0)						DD 34 00
170 '	LD A.$78						3E 78
180 '	CP (IX+$0)						DD BE 00
190 '	JR NZ.#BB						20 E6
200 '	LD (IX+$0).$0					DD 36 00 00
210 '	INC (IX+f􀀓1)					DD 34 01
220 '	LD A.&32						3E 20
230 '	CP (IX+$1)						DD BE 01
240 '	JR NZ,#BB						20 D8
250 'POP HL:POP DE:POP BC:POP AF		B1 D1 C1 F1
260 'RET								C9
270 '*DD DEFW $0
280 ']
```

<p align="center">────────────────────</p>

### page 7

La version BASIC DATA : 

```basic
10 FOR I=&H1B50 TO &H1B8C
20 READ A$: POKE I,VAL("&H"+A$)
30 NEXT
40 DATA F5,C5,D5,E5,DD,21,8D,1B
50 DATA 
60 DATA 
70 DATA 20,D8,B1,D1,C1,F1,C9
```

NDR : à compléter.


<p align="center">────────────────────</p>

### page 10


```basic

TO DO

```


<p align="center">────────────────────</p>

### page 11

2 lignes de BASIC pour démontrer les bugs du CANON X-07.

```basic
1 DEFSGN A: FOR A=999992760 TO 999992766: PRINT A;: NEXT A
```

```basic
1 DEFINT A: FOR A=32760 TO 32767: PRINT A;: NEXT A
```

<p align="center">────────────────────</p>

### page 12

```basic
5 CLEAR 2000: CLS: ON ERROR GOTO 100
10 INIT#1,"DT",100,"D": INPUT#1,IN,PA,DEB,FIN,F: GOTO 60
20 INPUT"NUMERO,PAS,DEBUT,FIN";IN,PA,DEB,FIN: PRINT#1,IN,PA,DE,FI,DEB
25 KEY$(5)="run RUN"+CHR$(34)+"CDATA"+CHR$(13)
30 GOTO 10
60 D=F: IF (D+26<FIN) THEN F=D+25 ELSE F=FIN
70 FOR I=0 TO F: F$=f$+STRING$(2-LEN(HEX$(PEEK(I))),"0")+HEX$(PEEK(I)): NEXT
90 KEY$(6)="dat"+RIGHT$(STR$(IN),LEN(STR$(IN))-1)+" DATA"+F$+CHR$(13)
92 IF F=FI THEN PRINT"TERMINE"
93 KEY$(12)="DELETE"+CHR$(34)+"DT"+CHR$(34)+"   DELETE"+CHR$(34)+"DT"+CHR$(34)+":CONSOLE@0"+CHR$(13)
95 IN=IN+PA: INIT#1,"DT": PRINT#1,IN,PA,DEB,FIN,F+1: ENO
100 IF ERR<>22 THEN PRINT"ERREUR EN LIGNE ";ERL;"CODE";ERR: END
110 RESUME 20
```

```basic
120 'ROUTINE D'IMPLANTATION DES OCTETS A INTEGRER AU PROGRAMME"
122 CLEAR 100,2000: 'ZONE CHAINE, LIMITE SUPERIEUR DE LA ZONE UTILISATEUR
125 INPUT"ADRESSE DEBUT";AD: INPUT"NB DE LIGNES DE DATA";N
130 FOR I=1 TO N: READ F$
135 FOR J=1 TO LEN(F$) STEP 2: POKE AD,VAL("&H"+MID$(F$,J,2)): AD=AD+1: NEXT J,I
```


___
