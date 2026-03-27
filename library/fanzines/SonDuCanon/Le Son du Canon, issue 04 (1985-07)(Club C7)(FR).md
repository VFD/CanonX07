# Son du Canon Le, issue 04 (198-)(Club C7)(FR)

___
## Introduction

Ce markdown à pour but de compiler les petits codes source de ce numéro.\
Une fois fait, il seront reportés après vérification.\
Pour des raisons de lisibilité, des espaces sont ajouté dans les programmes.


___
## Sommaire

<pre>
EDITORIAL ....................................... PAGE  1
LETTRE DE CANON FRANCE .......................... PAGE  3
LE SOLITAIRE .................................... PAGE  4
ESSAI D'AGENDA (LOGI'STICK) ..................... PAGE 10
LES BONNES ADRESSES DE C7 ....................... PAGE 14
LE COURRIER DES LECTEURS ........................ PAGE 16
LA PROGRAMMATHEQUE C7 ........................... PAGE 18
C7 INFORME ...................................... PAGE 20
LES PETITES ANNONCES ............................ PAGE 21
ESSAI DE CALC (POWER SOFT) ...................... PAGE 22
TRI ET CAMEMBERTS STATISTIQUES .................. PAGE 24
TRUCS EN VRAC.................................... PAGE 27
LES PENTOMINOS .................................. PAGE 28
LES INTERRUPTIONS DU X-07 ....................... PAGE 34
LA COOPERATIVE C7 ............................... PAGE 36
VOTRE AVIS VAUT DE L'OR ......................... PAGE 37
LA NAISSANCE D'OUTI ............................. PAGE 39
C7 ANNONCE ...................................... PAGE 42
</pre>

___
## Les listings


### page 7 - Le Solitaire

Même que dans "Application...", à vérifier.

Les Datas :

```
to do
```


### page 9 - Le Solitaire

Le MASTER

```basic
1 '*** PROGRAMME 2 ***
10 CLEAR 50,&H7FF
20 INIT#1,"CASI:"
30 INPUT#1,N$,D,F: MOTOR
50 PRINT"Trouv: ";N$
60 FOR I=D-1 TO F
70 POKE I,INP(#1): NEXT: MOTOR: END
100 CLEAR 50,&H7FF
110 D=&h822: F=&H11D5
120 N$="SOL": INIT#1,"CASO:": INPUT"Magneto OK";T$
140 PRINTT#1,N$,D,F: MOTOR
150 FOR J=1 TO 1800: NEXT
160 FOR I=D TO F: OUT#1,PEEK(I): NEXT: MOTOR: END
```

<p align="center">────────────────────</p>

Le CHARGEUR

```basic
1 '*** PROGRAMME 1 ***
10 CLEAR50,&H7FF:A=&H800
20 PRINTHEX$(A);" : ";:INPUTC$
30 V=VAL("&H"+C$):POKEA,V
49 A=A+1:IFA>&H11D5THENPRINT"TERMINE ...":BEEP2,3:END
50 GOTO20
```

### page 25 - Tri

Programme Basic :

```basic

```
<p align="center">────────────────────</p>

LM :

```asm

```


### page 26 - Camemberts

```basic

```

### page 31 - Pentomino

Même que dans "Applications...", à vérifier.


Les DATA :

```

```


### page 33 - Pentomino

Le MASTER

```basic
1 '*** PROGRAMME 2 ***
10 CLEAR 50,&H7FF
20 INIT#1,"CASI:"
30 INPUT#1,N$,D,F: MOTOR
50 PRINT"Trouv: ";N$
60 FOR I=D-1 TO F
70 POKE I,INP(#1): NEXT: MOTOR: END
100 CLEAR 50,&H7FF
110 D=&h800: F=&H159A
120 N$="PENTA": INIT#1,"CASO: "INPUT"Magneto OK";T$
140 PRINTT#1,N$,D,F: MOTOR
150 FOR J=1 TO 1800: NEXT
160 FOR I=D TO F: OUT#1,PEEK(I): NEXT: MOTOR: END
```

<p align="center">────────────────────</p>


Le CHARGEUR

```basic
1 '*** PROGRAMME 1 ***
10 CLEAR 50,&H7FF: A=&H800
20 PRINT HEX$(A);" : ";: INPUT C$
30 V=VAL("&H"+C$): POKE A,V
49 A=A+1: IF A>&H159A THEN PRINT"TERMINE ...": BEEP2,3: END
50 GOTO 20
```



### page 35 - Interdiction Break

Programme basic :

```basic
10 'INTERDICTION BREAK *** MISE EN PAGE
20 RESTORE 70: FOR I=7500 TO &H1D79: READ A$: POKE I,VAL("&H"+A$): NEXT: EXEC 7500: END
70 DATA 21,53,1D,22,3D,0,C9,D9,8,DB,F2,E6,1,CA,C1,C8,DB,F0,E6,C0,28,F,E6,80
80 DATA CA,35,C8,DB,F1,D6,5,C2,C,C8,C3,BD,C8,DB,F1,FE,3,28,F7,C3,84,C8
```

<p align="center">────────────────────</p>

Programme LM :

```asm
```

EOF
___
