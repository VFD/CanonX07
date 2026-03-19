# Faites vos jeux avec Canon X07 (1984)(Eyrolles)(FR)

Eyrolles
Philippe IFRAH
1984


___
## Introduction

Un résumé par IA :\
Cet ouvrage publié par Eyrolles en 1984 est un guide complet de programmation ludique sur l'ordinateur Canon X07.
À travers une collection variée de jeux pratiques, graphiques, musicaux, mathématiques, économiques, d'adresse,
de réflexion et de société, vous découvrirez des techniques de programmation innovantes et des astuces pratiques.
Les programmes, de complexité croissante, sont amplement expliqués pour permettre une progression à votre rythme,
du débutant au programmeur confirmé.

___
## Les Listings

___
### page 2 : MENU


```basic
5 FONT$(233)="4,4,4,4,4,4,4,4"
10 PRINT"   ***  MENU  ***"
15 CONSOLE,,,1,1
20 PRINT"1)Grapho  | 4) Piano"
30 PRINT"2)FireFox | 5) Trace"
40 PRINT"3)Coureur | 6) Autre"
50 C$=INKEY$
60 IF C$="" THEN 50
70 Y=VAL(C$)
80 ON Y GOTO 100,2000,500,1000,4000,9000,7000,8000,5000
90 GOTO 10
100 PRINT" GRAPHO"
2000 PRINT"       FIREFOX"
500 PRINT" ** COUREUR **"
1000 PRINT" PIANO "
9000 PRINT" ** MENU SUITE **"
```

NDR :
- Le principe donné est de fusionner les sources du livre ensemble.
- Le programme ci-dessus est très mauvais, exemple à ne pas suivre.
- Sans compter l'ordre des lignes incorrect.
- La barre | est en principe le caractère 233 redéfini.


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

Programme typique de l'époque.

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

NDR :
- Quand on connaît un peut le fonctionnement de l'INSEE, ...
- De plus très péjoratif, mais reflète aussi l'époque.

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
8000 PRINT"TRACE D'UNE COURBE"
8010 PRINT"Courbe: Y=AX^4+BX^3+CX^2+DX+E"
8020 INPUT"A=";A
8030 INPUT"B=";B
8040 INPUT"C=";C
8050 INPUT"D=";D
8060 INPUT"E=";E
8061 INPUT"Echelle Y:Nombre de points/unite";U
8062 INPUT"Echelle X:Nombre de points/unite";V
8063 IF U*V=0 THEN 8061
8064 CLS
8066 U=1/U
8067 V=1/V
8068 LINE(0,24)-(120,24)
8069 LINE(40,0)-(40,32)
8070 FOR X=0 TO 119
8075 Z=(X-40)/V
8080 Y=A*Z^4+B*Z^3+C*Z^2+D*Z+E
8085 Y=Y/U
8090 Y=23-INT(Y)
8110 IF Y>31 THEN 8160
8120 IF Y<0 THEN 8160
8125 IF X=0 THEN 8150
8130 IF ABS(S-Y)<2 THEN 8150
8135 ON ERRO GOTO 8150
8137 IF ABS(S-Y)>9 THEN S=Y
8140 LINE(X-1,S)-(X,Y)
8150 PSET(X,Y)
8155 S=Y
8160 NEXT X
8200 IF INKEY$="" THEN 8200
8250 INPUT"Changement d'echelle (O/N)";C$
8260 IF C$="O" THEN 8060
8270 IF C$="N" THEN 8000
8280 GOTO 8250
8300 8000
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

505 : Utiliser GRAPH + E - chr$(153) redéfini
550 : Utiliser GRAPH + A - chr$(136) redéfini

Version alternative avec CHR$:

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
100 PRINT" * CINEMA MUSICAL *"
110 FOR I=0 TO 500:NEXT I
130 CONSOLE,,,0
140 FONT$(224)="0,16,28,16,16,16,40,72"
150 FONT$(225)="0,40,240,32,32,32,88,64"
160 FONT$(228)="0,84,56,16,16,16,104,8"
170 FONT$(229)="0,160,112,40,32,32,80,72"
180 FONT$(231)="4,8,4,4,4,4,8,8"
190 FONT$(233)="128,104,48,160,32,32,144,80"
195 C=5:A=0:D=1:E=1
200 Z$=INKEY$
205 IF Z$="^"THEND=-D
210 IF Z$="1"THENC=C+1
215 IF Z$="-"THEN E=-E
220 IF Z$="2" THEN C=C-1
225 IF C<1 THEN C=1
230 B=B+1
240 IF B=3 THEN A=5
250 IF B=5 THEN A=0
260 IF B=7 THEN A=7
270 IF B=8 THEN A=5
280 IF B=9 THEN B=1:A=0
290 CLS
295 IF D<0 THEN A=A+12
300 LOCATE 8,1
320 PRINT" **  ** ";
330 IF E>0 THEN BEEP 1+A,C+2:BEEP A+5,C+4:BEEP A+8,C+2
340 IF E<0 THEN BEEP1+A,C:BEEPA+5,C+4:BEEPA+8,C:BEEP1+A,C+3
350 CLS
360 LOCATE 8,1
380 PRINT" ** ** "
390 IF E<0 THEN BEEPA+5,C+1:BEEPA+8,C+1
400 IF E>0 THEN BEEPA+10,C+2:BEEPA+11,C+2
410 CLS
420 LOCATE 8,1
440 PRINT" ** ** "
450 IF E>0 THEN BEEPA+10,C+2:BEEPA+8,C+2
460 IF E<0 THEN BEEP1+A,C:BEEPA+5,C+1:BEEP0,2:BEEPA+8,C+5
500 CLS
510 LOCATE 8,1
530 PRINT" ** ** "
540 IF E>0 THEN BEEPA+5,C+3
550 IF E<0 THEN BEEP1+A,C:BEEPA+5,C+1:BEEP0,2:BEEPA+8,C+8
600 GOTO 200
```

Faire une version [a] à cause des caractères graphiques.\
Ou mettre les bons caractères avant transformation.

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
10 PR INT"AJUSTEMENT D’UNE COURBE"
20 INPUT "Nombre de points" ;N
30 FOR 1=1 TO N
40 INPUT "Abscisse";A
50 INPUT "Ordonnée";O
55 Z=LOGC103
60 B=B+A
70 C=C+0
80 D=D+A-2
80 E=E+0's2
100 F=F+A*O
120 H=H+0*A~2
130 K=K+AZ'3
150 ri=ri+A''4
160 IF O<=0 THEN 200
165 XA=XA+LOGCA3z?
170 U=U+LOGCO3/Z
175 XC=XC+CLOGCA3/Z3,"2
180 S=S+AXLOGCO3/?
180 XY=XY + LOGCA3XLOGCO3/Z-/S2
200 frIEXTI
210 PRINT "Type de courbe-"
220 PRINT" - Droite C13, Courbe hyperbol i que C23," ;
225 INPUT" Parabolique C33 ou exponentie lie C43";P
230 ON P GOTO 235,400,600,800
232 GOTO 210
235 IF D-B^2=0 THEN 622
240 U=CF-BXC/N3/CD-B*B/N3
250 IaJ=C/N~U*B/N
260 PRINT"Y=" ;ü;"*X+" ; LJ
265 IF INKEY$="” THEN 265
270 PRINT "Prevision C13, changement de courbe C23, " 1
280 INPUT" ou fin C33" ;X

ON X GOTO 310,210,1000
GOTO 270
ON P GOTO 315,500,750,900
INPUT"Absc i s se :X=" ',8
O=AXU + 14
PRINT"Oi'donnee :Y=" ;□ IF INKEY$="" THEN 340 GOTO 270 IF D-B~2=0 THEN 622 XN=X8/N '■ TT1=U/N u=cxY-xn*u3/cxc-xn*XAi 14=U/N-U*XA/N 14= 1 0-14
PRINT"Y=" ;ui; '*X-" ;U IF INKEY$="': THEN 460 GOTO 270
INPUT "Absc i sse :X=" ;X
Y=14*X-U
PRINT "Ordonnes Y=";Y IF INKEY$="" THEN 525 GOTO 270
U=I1* C DYN-B^ >-K* C K*N-D*B 3+D* ( KXB-D^
IF UO0 THEN 630
PRINT "Pas de solution IF INKEY$="” THEN 624 GOTO 210
U=K*CB*C-F*N3-D*CD*C-F*B3+H*CD*N-B/'2
14=14/0
X=DXCFXD-K*C3-HXCBXD-KXN3 +!1*CB*C-F*N
X=-X/U
Y=HXCK*B-Dz'2 3-ri*CFXB-DXC]+KX(FXD-KXC
Y=Y/U
PRINT"Y="
PRINT 14 , *X-2+‘ ,X ; XX + " ; Y


210
IF INKEY$=""
THEN
710
720
GOTO 270
750
INPUT "Ab s ci s
se X:
= " ;l
760
L=bJXL-2 + XXL + Y
770
PRINT i;0rdonn
e e Y:
= " JL
775
IF INKEY$=""
THEN
775
780
GOTO 270
800
EX--C S-BXU/N 3 /
CD-BXB/N3
810
EB=(U-EX*B3/N
820
AX=10^EX
830
BX=10Z'EB
840
PRINT"Y=" ;BX ;
;
AX ~
850
IF INKEY$="”
THEN
850
860
GOTO 270
900
INPUT" Ab s c iss
e X =
" ;A
910
Y=BX*AX~A
920
PR INT'Or donne
e Y =
" ; Y
950
IF INKEY$=""
THEN
950
980
GOTO 270
1000 END

```

OCR KO, faut refaire.

___
### page 35 : CALCUL DE VOTRE IMPOT SUR LE REVENU

```basic
100 PRINT"* CALCUL DE UOTRE * IMPOT SUR LE REVENU"
150 IF INKEY$="" THEN 150
200 INPUT"Nombre de personnes dans votre foyer fiscal";P
300 IF P<=0 OR P<>INT(P) THEN 200
400 IF P>2 THEN P=P/2+1
450 PRINT"Cela fait";P;"parts"
500 INPUT"Quel est votre revenu annuel ne global en Francs";R
600 R=10*INT(R/10)
650 Q=R/P
700 IF Q<=12620 THEN I=0  GOTO 3000
800 IF Q<=13190 THEN I=(R*.05)-(631*P) GOTO 3000
900 IF Q<=15640 THEN I=(R*.1)-(1290*P) GOTO 3000
1000 IF Q<=24740 THEN I=(R*.15)-(2072*P) GOTO 3000
1100 IF Q<=31810 THEN I=(R*.2)-(3309*P) GOTO 3000
1200 IF Q<=39970 THEN I=(R*.25)-(4900*P) GOTO 3000
1300 IF Q<=48360 THEN I=(R*.3)-(6898.5*P) GOTO 3000
1400 IF Q<=55790 THEN I=(R*.35)-(9316.5*P) GOTO 3000
1500 IF Q<=92970 THEN I=(R*.4)-(12106*P) GOTO 3000
1600 IF Q<=127860 THEN I=(R*.45)-(16754.5*P) GOTO 3000
1700 IF Q<=151250 THEN I=(R*.5)-(23147.5*P) GOTO 3000
1800 IF Q<=172040 THEN I=(R*.55)-(30710*P) GOTO 3000
1900 IF Q<=195000 THEN I=(R*.6)-(39312*P) GOTO 3000
2000 I=(R*.65)-(49062*P)
3000 PRINT"Votre impot a payer:";I;"Francs"
4000 IF INKEY="" THEN 4000
4100 GOTO 100


```

Pour la postérité.



___
### page 41 : ETUDE DE MARCHE

```basic
TO DO
```

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