# Le Son du Canon, issue 06 (1985-11)(Club C7)(FR)

___
## Introduction

Ce markdown à pour but de compiler les petits codes source de ce numéro.


___
### Sommaire

<pre>
EDITORIAL ............................... PAGE  1
LETTRE DE CANON ......................... PAGE  3
C7 INFORME .............................. PAGE  5
POKER ................................... PAGE  6
PETITES ANNONCES ........................ PAGE  9
MICROBOX ................................ PAGE 10
40 PROORAMMES POUR X-07 ................. PAGE 14
SAUTE MOUTONS ........................... PAGE 16
LES "3 SOFTS" DE POWER SOFT ............. PAGE 17
LES BONNES ADRESSES DE C7 ............... PAGE 19
LES "SOFTS" DE LOGI'SIICK ............... PAGE 21
PROGRAMMES DIVERS ....................... PAGE 22
LABYRINTHE 3D ........................... PAGE 25
INVERSE VIDEO RAPIDE .................... PAGE 27
PUBLICATIONS C7 ......................... PAGE 30
L'EVENEMENT DE L'ANNEE .................. PAGE 31
DOSSIERS TOUS AZIMUTS ................... PAGE 33
JEUX 2 DE LOGI'STICK .................... PAGE 34
PROGRAMMATHEQUE ......................... PAGE 36
R.D.I. DE LOGI'STICK .................... PAGE 38
COOPERATIVE C7 .......................... PAGE 40
VOTRE AVIS VAUT DE L'OR ................. PAGE 41
C7 ANNONCE .............................. PAGE 42
</pre>

___
## La K7

___
## Les listings


### page 26 - Labyrinthe

Le Master :


```basic
2 ' *** PROGRAMME 2 ***
5 ' *** ENTREUR DE CODES ***
10 CLEAR 50,&H7F0 : A=&H800
20 PRINT HEX$(A);" ";: INPUT C$
30 V=VAL("&H"+C$): POKE A,V
49 A=A+1: IF A>&H1012 THEN PRINT"TERMINE...": BEEP 2,3: END
50 GOTO 20
```

<p align="center">────────────────────</p>

Le Chargeur :


```basic
2 '*** PROGRAMME 1 ***
5 '*** CHARGEUR BASIC ***
10 CLEAR 50,&H7F0
20 INIT#1,"CASI:"
30 INPUT#1,N$,D,F
40 MOTOR
50 PRINT"Trouv: ";N$
60 FOR I=D-1 TO F
70 POKE I,INP(#1)
80 NEXT: MOTOR
90 END
100 CLEAR 50,&H7F0
110 D=&h800: F=&H1012
120 N$="PLABIR": INIT#1,"CASO:"
130 INPUT"Magneto OK";T$
140 PRINTT#1,N$,D,F: MOTOR
150 FOR I=1 TO 1800: NEXT
160 FOR I=D TO F: OUT#1,PEEK(I)
170 NEXT: MOTOR
180 END
```


<p align="center">────────────────────</p>

Les Datas.

```

```

___
