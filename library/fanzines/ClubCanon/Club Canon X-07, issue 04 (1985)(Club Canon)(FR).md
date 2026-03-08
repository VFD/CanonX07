# Club Canon Issue 04


___
## Introduction

TODO


___
## Sommaire

<pre>
Editorial ......................................  1
Des extensions pour votre x-07 .................  2
Des logiciels pour votre CANON X-07 ............  3
De la lecture pour votre X-07 ..................  4
Nouveau et intéressant .........................  5
Inversion de l'écran (suite) ...................  6
Reines sur l'échiquier .........................  7
Communication entre deux X-07 .................. 10
La parole au X-07 .............................. 11
Le fichier 5 ................................... 13
Le coin des jivaros ............................ 15
Essai logiciel : FOHTH de LOGI'STICK ........... 16
En bref ........................................ 17
Liste des programmes du club ................... 18
</pre>

___
## Les Listings

<p align="center">────────────────────</p>

### page 6

Inversion écran LM

```asm
To do
```

<p align="center">────────────────────</p>

### Page 7

Reine sur l'échiquier.

```basic
10 CLS:PRINT:PRINT"   Reine sur","l'echiquier (LM)"
20 PRINT STRING$(18,"%");: LOCATE 6,3: PRINT " Nsc 800 ";: FOR I=1 TO 350: NEXT: DEFINT A-Z
41 DIM A$(102): FOR T=0 TO 102: READ A$(T): POKE &H1D00+T,VAL("&H"+A$(T)): NEXT T
50 CLS: PRINT: INPUT" Taille echiquier   ";S: IF S>30 THEN 50 ELSE CLS
52 LOCATE 11,2: PRINT"% Reines": LOCATE 10,3: PRINT"Dim.";S;
54 LINE(0.0)-(1+S,0): LINE-(1+S,1+S): LINE-(0,1+S): LINE-(0,0)
55 POKE &H1DF0,S: POKE &H1DF1,&H01: POKE &HlDF2,&H1E: EXEC &H1D00: K=1
65 A=PEEK(&H1DF1): IF A=0 THEN CLS: END ELSE A=A-1:POKE &H1DF1,A
101 FOR I=0 TO 3: LOCATE 0,I:PRINT"        ";: NEXT
102 LINE(0,0)-(1+S,0): LINE-(1+S,1+S): LINE-(0,1+S): LINE-(0,0): BEEP 24,2
105 FOR J=1 TO S: A=PEEK(&H1E00+J): PSET(J,A): NEXT J
123 LOCATE 12,0: PRINT">>";K;: POKE 43,4: BEEP 28,1: EXEC &H1D50: K=K+1: GOTO 65
200 DATA 2A,F1,1D,0,0,0,0,0,0,0,0,0,0,0,0,0,36,1,7D,FE
205 DATA 1,CA,40,1D,11,0,1E,13,7D,BB,CA,40,1D,46,1A
210 DATA B8,CA,50,1D,90,FE,80,DA,2F,1D,2F,3C,83,9D
215 DATA CA,50,1D,C3,1B,1D,0,0,0,0,0,0,0,0,0
216 DATA 23,22,F1,1D,3A,F0,1D,BD
220 DATA D2,10,1D,C9,0,0,0,0,2A,F1,1D,34,3A,F0,1D
225 DATA BE,D2,12,1D,28,22,F1,1D,7D,FE,0,C2,53,1D,C9,0,0,0
```


<p align="center">────────────────────</p>

### Page 9

Version tout BASIC.

```basic

```


<p align="center">────────────────────</p>

### page 14

Exemple pour FICHIER 5.

```basic
5 ' AUTONUMEROTATION
10 INIT#5,"B",100: I=0
15 I=I+1: A=I*10: A$=STR$(A): A$=RIGHT$(A$,LEN(A$)-1): B$=" ": PRINT A$;
17 I$=INKEY$: IF I$="" THEN 1720 IF I$=CHR$(13) THEN 25 ELSE IF I$=CHR$(26) THEN 40 ELSE B$=B$+I$: PRINT I$;: GOT0 17
25 PRINT#5,A$;B$: PRINT: GOTO 15
40 EXEC &HEE1F
```

```basic
5 ' SUPRESS ION D E L I GNES
10 CLS: INPUT"1ere Ligne a detruire";D: INPUT "derniere ligne";F
20 Z=1363: DEFFNP(Z)=PEEK(Z)+256*PEEK(Z+1)
30 INIT#5,"FICH#5"
40 A=FNP(Z): B=FNP(Z+2): IF A=0 THEN 70
50 IF B>=C AND B<=F THEN PRINT#5,STR$(B)
60 Z=A: GOTO 40
70 EXEC &HEE1F
```

```basic
2 ' RECHERCHE DE CHAINE DE CARACTERES
5 CLEAR 300: ON ERROR GOTO 100: CLS
10 INIT#5,"FICH#5"
25 LINE INPUT"CHAINE?";C$: IF C$=CHR$(26) THEN END
30 INPUT#5,A$
40 N=INSTR(A$,C$): IF N=0 THEN 30
60 PRINT A$
70 IF INKEY$="" THEN 70 ELSE 30100 IF ERR=22 THEN RESUME 110 ELSE PRINT"Erreur code "ERR"en ligne "ERL: END
110 PRINT"AUTRE ";:GOTO 10
```

```basic
5 ' CONVERSION MAJUSCULES-minuscules
10 CLS:INIT#5,"FICH#5"
20 A=INP(#5): IF A=0 THEN END
50 A=A+32*(A>=65)*(A<=90):LPRINT CHR$(A);: GOTO 20
```

```basic
TO DO
```




<p align="center">────────────────────</p>

### page 15

Un 2 lignes

```basic
2 a=stick(0):y=y-(a=5)+(A=1)-4*(y=0):x=x+1:pset(w,y):w=xmod118:ifw=1thencls
3 h=h+1-rnd(0)*2-(h<0)+(H>23):pset(w,h):pset(w,h+8):ifpoint(w,y)thenprintxelse2
```

Bon c'est illisible donc rework :

```basic
10 A=STICK(0):                          REM 
20 Y=Y-(A=5)+(A=1)-4*(Y=0):             REM 
30 X=X+1:                               REM incremente X
40 PSET(W,Y):                           REM 
50 W=X MOD 118:                         REM 
60 IF W=1 THEN CLS:                     REM si W=1 efface l'ecran
70 H=H+1-RND(0)*2-(H<0)+(H>23):         REM 
80 PSET(W,H):                           REM Affiche le point de coordonnee W,H
90 PSET(W,H+8):                         REM Affiche le point de coordonnee W,H+8
100 IF POINT(W,Y) THEN PRINT X ELSE 10: REM 
```

Explications : to do


___
