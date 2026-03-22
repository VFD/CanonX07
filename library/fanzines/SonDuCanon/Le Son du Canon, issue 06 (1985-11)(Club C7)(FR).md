# Le Son du Canon, issue 06 (1985-11)(Club C7)(FR)

___
## Introduction

Ce markdown à pour but de compiler les petits codes source de ce numéro.

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
