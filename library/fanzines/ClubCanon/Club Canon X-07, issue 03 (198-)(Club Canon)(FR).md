# Club Canon X-07, issue 03 (198-)(Club Canon)(FR)

___
## Introduction

Gazette numéro 3 du Club Canon X-07.\
Le sommaire est repris ci-après.\
Les listings sont aussi listés ici.

___
## Sommaire

<pre>
Editorial ..................................  1
Des extensions pour votre X-07 .............  2
Des logiciels pour votre CANON X-07 ........  3
Nouveau et intéressant .....................  4
De la lecture pour votre X-07 ..............  5
Le coin du bidouil1eur :
	Inversion de l'écran ...................  6
	Connection directe de deux X-07 ........  7
	Intégration numérique .................. 10
	Bévues et matrice de clavier ........... 11
	Utilitaire de mise en datas ............ 12
Petites annonces ........................... 13
Tribune libre .............................. 14
Essai logiciel ............................. 15
Nouvelles brèves ........................... 17
</pre>
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
100 '#BB	LD A.$13					3E 13
110 '	LD B.$2							06 02
120 '	LD C.$0							0E 00
130 '	LD HL.#DD						DD 21 8D 1B
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
50 DATA DD,36,00,00,DD,36,01,00
60 DATA 3E,13,06,02,0E,00,DD,21
70 DATA 8D,1B,CD,2F,C9,DD,21,8D
80 DATA 1B,DD,34,00,3E,78,DD,BE
90 DATA 00,20,E6,DD,36,00,00,DD
100 DATA 34,01,3E,20,DD,BE,01,20
110 DATA D8,B1,D1,C1,F1,C9
```

NDR : Version complétée car non complète dans le fanzine.


<p align="center">────────────────────</p>

### page 10 - Calcul d'intgrale


```basic
10 CLEAR 300: INIT #1,"KBD:"
15 FONT$(128)="0,0,0,36,116,36,0,0": FONT$(129)="0,0,216,36,36,36,216,0"
20 CLS
35 I$=CHR$(128)+CHRS(129)
40 PRINT"Intégrale de f(x)"
41 PRINT"1. sur [a,b]"
42 PRINT"2. sur [a,"I$"["
50 PRINT"3. autre fonction";
60 R=INP(#1)-48: D=0
70 IF R=J THEN 200
80 CLS: INPUT "a";A: RESTORE 150: FOR I=0 TO 5: READ Z(I),W(I): NEXT: IF R=2 TREN 110
90 INPUT "b";B: C=(B-A)/2: B$=STR$(B)+" ]": FOR I=0 TO 5
100 D=D+W(I)*(FNF(C*Z(I)+C+A)+FNF(C+A-C*Z(I))): NEXT: D=D*C: GOTO 130
110 B$=I$+" [": FOR I=0 TO 5: D=D+W(I)/(1+Z(I))^2*FNF(2/(1+Z(I))+A-1)
120 D=D+W(I)/(1-Z(I))^2*FNF(2/(1-Z(I))+A-1): NEXT: D=2*D
130 PRINT" Intégrale de f(x)","sur ["A","B$: PRINT
140 PRINT D;: R=INP(#1): GOTO 20
150 DATA .9815606342, .04717533639, .9041172564, .106939326, .7699026742, .1600783285
160 DATA .5873179543, .2031674267, .367831499, .2334925365, .1252334085, .2491470458
200 CLS: INIT #1,"KBD:": LINE INPUT "f(x) = ";F$
210 IF LEN(F$))>66 THEN CLS: PRINT" Définition trop longue": R=INP(#1): GOTO 200
220 KEY$(6)="fnx 30 DEFFNF(X)="+F$+CHR$(13)+"GOTO 30"+CHR$(13)
230 PRINT"Pressez la touche F6": R=INP(#1)
```

NDR : Ligne 40 splitée en 40, 41 et 42

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

### page 12 - Utilitaire de mise en Data

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
