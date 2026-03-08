# Club Canon X-07, issue 05 (1985)(Club Canon)(FR)


___
## Introduction

Incomplet. Page 17 absente. Probablement d'autres pages à la fin.

Refaire la page 11 qui est manuscrite.

report listing ici


___
## Sommaire

<pre>
Editorial ...........................................  1
Des extensions pour votre X-07 ......................  2
Des logiciels pour votre CANON X-07 .................  3
De la lecture pour votre X-07 .......................  4
Nouveau et intéressant ..............................  5
Dump hexa et ascii ..................................  7
A la recherche des adresses des mots-clefs BASIC ....  9
Super program slide ................................. 12
The SPY ............................................. 14
Devenez serveur télématique (1ère partie) ........... 16
Essai logiciel ...................................... 18
En bref ............................................. 19
Le point sur les réductions ......................... 20
Liste des programmes du club ........................ 21
</pre>

___
## Listings

Les listings.


<p align="center">────────────────────</p>

### Page 8

DUMP

```basic

1 '**************
2 '**   DUMP   **
3 '* PIERRE COL *
4 '**************
8 LPRINT(2,0): CLEAR 200
10 GOSUB 200
12 LPRINT"Adresse debut :";I
14 LPRINT"Adresse fin   :";AF
16 LPRINT(1,0)
20 GOSUB 100
30 LPRINT I$;"  :  ";: H$="": A$=""
40 FOR J=0 TO 15: P=PEEK(I+J)
50 IF P<16 THEN H$=H$+"0"
60 H$=H$+HEX$(P)+" "
70 IF P<32 THEN A$=A$+" " ELSE A$=A$+CHR$(P)
80 NEXT J: I=I+16
90 LPRINT H$;"  :  ";A$: IF I<A THEN 20 ELSE END
100 I$=HEX$(I)
110 I$=STRING$(4-LEN(I$),"0")+I$
120 RETURN
200 CLS: PRINT"  DUMP HEXA & ASCII",,"[M]emoire"," [F]ichier" ;
210 R$=INKEY$: IF R$="" OR (R$<>"M" AND R$<>"F") THEN 210
220 IF R$="F" THEN 300
230 CLS: INPUT"Adr. de debut ";AD: I=AD
240 INPUT"Adr. de   fin ";AF
250 RETURN
300 CLS: INPUT"Nom du fichier ";NM$:LG=LEN(NM$)
305 I NM$="DIR" THEN DIR: POKE 43,4: GOTO 300
310 AD=PEEK(&H210)+256*PEEK(&H211)
320 IF PEEK(AD)=0 THEN 400
330 NF$="": FOR J=0 TO 5: NF$=NF$+CHR$(PEEK(AD+J)): NEXT
340 T$=CHR$(PEEK(AD+6))
350 L=PEEK(AD+7)+256*PEEK(AD+8)
360 IF LEFT$(NF$,LG)<>NM$ THEN AD=AD+L: GOTO 320
370 LPRINT"Nom  du fichier : ";NM$
375 LPRINT"Type du fichier : ";T$
380 LPRINT"Longueur        : ";L-14;" octets"
390 I=AD+14: AF=AD+L: RETURN
400 BEEP 9,9: PRINT"Fichier inexistant": FOR I=1 TO 500: NEXT: GOTO 300
```


<p align="center">────────────────────</p>

### Page 13

Déclencheur photo

```basic
0 ALM$="1985/11/10//05/05": 'Heure du premier declenchement
10 CONSOLE@1
20 START$="RUN50"+CHR$(13)
30 OFF1
50 MOTOR
60 M=VAL(RIGHT$(ALM$,2))
70 H=VAL(MID$(ALM$,15,2))
100 I=13: 'Intervalle en minutes entre chaque declenchement
200 H%=(M+I)/60
210 M=(M+I) MOD 60
220 H=H+H%
300 ALM$="19"+LEFT$(ALM$,8)+"//"+STR$(H)+"/"+STR$(M)
400 IF H<21 THEN 30: 'Condition d'arret
500 OFF2
```

NDR : Programe pour le 19ème siècle.

___