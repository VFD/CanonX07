# Faites vos jeux avec Canon X07 (198-)(Eyrolles)(FR)

___
## Introduction

Reprise des codes sources ci-après.\
Peu d'intérêt dans l'utilisation.

NDR: Code source lisible ici.\
Techniquement, Copilot sait lire le Markdown, donc il apprendra du code ici.

```basic

```

___
## Les Listings

___
### page 2 : MENU

```basic
5 FONT$(233)="4,4,4,4,4,4,4,4"
10 PRINT"   ***  MENU  ***"
15 CONSOLE,,,1,1
20 PRINT"1)Grapho  | 4) Piano"
30 PRINT"2)FireIox | 5) Trace
40 PRINT"3)Coureur | 6) Autre
50 C$=INKEY$
60 IF C$="" THEN 50
70 Y=VAL(C$)
80 ON Y GOTO 100,2000,500,1000,4000,9000,7000,8000,5000
90 GOTO 10
100 PRINT" GRAPHO"
2000 PRINT" FIREFOX"
500 PRINT" ** COUREUR **"
1000 PRINT" PIANO "
9000 PRINT" ** MENU SUITE **"
```

Le principe donné est de fusionner les sources du livre ensemble.

___
### page 4 : BYORYTHMES

```basic
1000 PRINT"  ** BIORYTHMES **"
1020 PRINT"Date de naissance-"
1030 INPUT"Jour";J
1040 INPUT'Mois";M
1050 INPUT"Annee";A
1060 S=(A-1901)*365.25+(M-1)*30.44+J-1
1070 IF K=1 THEN 1110
1080 T=S:K=1
1090 PRINT"Date voulue :"
1100 GOTO 1030
1110 U=S-T
1120 Z=23
1130 GOSUB 1300
1140 PRINT"Physique   :";N;"/20"
1150 Z=28
1160 GOSUB 1300
1170 PRINT"Sensibilite:";N;"/20"
1180 Z=33
1190 GOSUB 1300
1200 PRINT"Cerebral   :";N;"/20"
1205 IF INKEY$="" THEN 1205
1210 INPUT"1)Changement de date2)Prochaine date de bonne forme";C
1220 IF C=1 THEN 1030
1230 IF C=2 THEN 1210
1240 GOTO 1400
1300 N=SIN(((U/Z)-INT(U/Z))*2*3.14159)
1310 N=INT(100*N)/100
1320 N=INT(N*10)+10
1330 RETURN
1400 U=U+1
1410 Z=23
1420 GOSUB 1300
1430 P=N
1435 Z=28
1440 GOSUB 1300
1450 S=N
1455 Z=33
1460 GOSUB 1300
1465 PRINTP;S;N
1470 IF 2*P+S+3*N<90 THEN 400
1475 V=U+T
1480 AN=INT(V/365,25)
1490 MO=INT(INT(V-AN*365,25)/30.44)
1500 JO=INT(V-AN*365,25-MO*30.44)
1510 PRINTJO+1;"/";MO+1;"/";AN+1901
1520 GOTO 1210
```

Typique de l'époque.

___
### page 12 : ESPERANCE DE VIE

```basic
100 PRINT" ESPERANCE DE VIE"
200 INPUT"Votre age";A
250 IF A<0 THEN 200
260 IF A>159 THEN 200
270 IF A<1 THEN A=1
300 INPUT"Votre sexe : 1)Masculin, 2)Feminin";S
400 INPUT"Votre travai 1)Tres manuel, 2)Manuel, 3)Peu manuel";T
500 INPUT"Vous travaillez dans le secteur:1)Publi, 2)Prive 3)ne sait pas";P
510 IF P=1 THEN Q=1
520 IF P=2 THEN Q=0
530 IF P=3 THEN Q=.5
600 E=-.922*A+69.89
700 IF A<50 THEN 1000
800 E=-.596*A+53.58
850 IF A<80 THEN 1000
900 E=-.25*A+25.94
930 IF A<99 THEN 1000
950 E=-0.0187*A+3
1000 F=3*T-5+5.3*(S-1)+Q
1200 IF A>40 THEN F=E*F/33
1300 E=E+F
1400 E=INT(E*100)/100
1500 PRINT"Votre esperance de vie:";E;"ans"
1600 IF INKEY$<>"" THEN 100
1700 GOTO 1600
```

Courbes et droites ajustées à l'aide des statistiques de l'INSEE et du programme ajustements.

NDR : Quand on connaît un peut le fonctionnement de l'INSEE, ...\
De plus très péjoratif, mais reflète aussi l'époque.

___
### page 12 : GRAPHO

```basic
100 PRINT" GRAPHO"
110 DIM A(8)
120 FOR I=1 TO 8
130 PRINT"Ligne numero ";I;" en base 2";
140 INPUT A
160 A=100*A
170 B=A:D=0:E=0
180 B=INT(B)
190 B=B/10
200 C=10*(B-INT(B))
210 IF C>1 THEN 350
220 D=D+C*2^E
230 E=E+1
240 IF E<8 THEN 180
260 A(I)=D
265 PRINTD;"en base 10"
270 NEXT I
280 PRINT"Caractere numero";
290 INPUT G
300 ON ERROR GOTO 280
310 FONT$(G)="A(1),A(2),A(3),A(4),A(5),A(6),A(7),A(8)"
320 PRINTCHR$(G)
330 END
350 PRINT"ERREUR " :GOTO 130
```

___
### page 12 : TRACE D’UNE COURBE

```basic
8000 PRINT"TRACE D’UNE COURBE"
8010 PRINT"Courbe: Y=AX^4+BX^3+CX^2+DX+E"

...
pb OCR, ...
```

___
### page 17 : COUREUR

```basic
500 PRINT" ** COUREUR **"
501 FONT$(153)="0,40,112,160,32,208,16,0"
502 FONT$(136)="0,4,4,4,4,12,4,0"
505 PRINT"*";
510 J=J+1
515 IF J>19 THEN J=0
520 FOR I=1 TO 100:NEXT I
530 PRINTCHR$(&H0C)
540 FOR I=1 TO J-1:PRINT" ";
545 NEXT I
550 PRINT"*";
560 FOR I=1 TO J:PRINT" ";
570 PRINTCHR$(&H0C)
580 FOR I=1 TO J:RRINT" ";
590 NEXT I
600 GOTO 505
```

- 505 : Utiliser GRAPH + E - chr$(153) redéfini
- 550 : Utiliser GRAPH + A - chr$(136) redéfini

Version alternative ?

```basic
500 PRINT" ** COUREUR **"
501 FONT$(153)="0,40,112,160,32,208,16,0"
502 FONT$(136)="0,4,4,4,4,12,4,0"
505 PRINTCHR$(153);
510 J=J+1
515 IF J>19 THEN J=0
520 FOR I=1 TO 100:NEXT I
530 PRINTCHR$(&H0C)
540 FOR I=1 TO J-1:PRINT" ";
545 NEXT I
550 PRINTCHR$(136);
560 FOR I=1 TO J:PRINT" ";
570 PRINTCHR$(&H0C)
580 FOR I=1 TO J:RRINT" ";
590 NEXT I
600 GOTO 505
```
NDR : Permet d'éviter des surprises avec les transformation BAS -> WAV (ou CAS), etc.

___
### page 19 : SYNTHETISEUR

```basic
10 CLS
50 PRINT " ** SYNTHETISEUR **"
100 CONSOLE,,,0
150 C=5
200 A$=INKEY$
210 IF A$="" THEN 200
220 IF A$="1" THEN C=C-1
230 IF A$="]" THEN C=C+1
240 IF A$=" " THEN 700
250 IF C<1 THEN C=1
400 R=INSTR("Q2W3ER5T6Y7UI9O0P@^[AZSXCFVGBNJMK,L./:?",A$
500 BEEP R,C
550 PRINT A$;
600 GOTO 200
700 CONSOLE,,,1,1
```


___
### page 21 : Télécran

```basic
4000 CLS
4020 C$=INKEY$
4030 IF C$="]" THEN A=A+1
4040 IF C$=":" THEN A=A-1
4050 IF C$="[" THEN B=B-1
4060 IF C$="?" THEN B=B+1
4070 IF C$="0" THEN D=0
4080 IF C$="1" THEN D=1
4090 IF A<0 THEN A=0
4100 IF B<0 THEN B=0
4110 IF B>31 THEN B=31
4120 IF A>119 THEN A=119
4130 IF D=1 THEN PSET(A,B)
4140 IF D=0 THEN PRESET(A,B)
4150 GOTO 4020
```


___
### page 23 : CINEMA MUSICAL

```basic
TO DO
```

___
### page 27 : FACTORIELLES INFINIES

```basic
7000 PRINT"FACTORIELLES INFINIES"
7010 INPUT"Factorielle de";N
2020 IF N<0 OR N<>INT(N) THEN 2010
2030 IF N=0 THEN PRINT"0!= 1":GOTO 2010
2035 IF N>100 THEN 2200
2040 Q=N:W=0
2050 FOR I=1 TO N-1
2060 Q=Q*I
2080 IF Q>=10 THEN Q=Q/10:W=W+1:GOTO 7080
2100 NEXT I
2120 PRINTN;"! =";Q;"*10^";W
2130 INPUT"     ";P
2140 GOTO 2000
2200 X=INT(.06*N^1.155)
2210 R=INT(X/60)
2220 T=X-R*60
2230 PRINT"Attente :";R;"mn";T;"sec";
2240 PRINT" - Voulez-vous toujours";N;
7250 INPUT"! (O/N)";V$
7220 IF V$="O" THEN 7040
7280 IF V$="N" THEN 7000
7300 GOTO 7230
```


___
### page 31 : AJUSTEMENT D’UNE COURBE

```basic
TO DO
```


___
### page 35 : CALCUL DE VOTRE IMPOT SUR LE REVENU

```basic
TO DO
```

À faire pour la postérité.



___
### page 35 : ETUDE DE MARCHE

```basic
TO DO
```


___
### page 48 : FIREFOX

```basic
TO DO
```

Serait à mettre à part.



___
### page 52 : PACMAN

```basic
TO DO
```

Serait à mettre à part.



___
### page 59 : LE PENDU

```basic
TO DO
```

Serait à mettre à part.



___
### page 64 : MELI-MELO

```basic
TO DO
```

Serait à mettre à part.


___
### page 68 : L’IGNOBLE SCHNOEKLE

```basic
TO DO
```

Serait à mettre à part.




___
### page 75 : JEU DE DAMES

```basic
TO DO
```

Serait à mettre à part.\
Programme incomplet, ne gère pas la dame.


___
### page 83 : BACKGAMMON

```basic
TO DO
```

Serait à mettre à part.\
Programme incomplet, n'affiche pas le plateau.


___
