# Club Canon Issue 04


___
## Introduction

TODO


___
## Les Listings

<p align="center">────────────────────</p>

### page 6

Inversion écran LM

To do


<p align="center">────────────────────</p>

### page 7 ...

Reine sur l'échiquier.

To DO.


<p align="center">────────────────────</p>

### page 13

Exemple pour FICHIER 5.

TO DO

<p align="center">────────────────────</p>

### page 15

Un 2 lignes

```basic
2 a=stick(0):y=y-(a=5)+(A=1)-4*(y=0):x=x+1:pset(w,y):w=xmod118:ifw=1thencls
3 h=h+1-rnd(0)*2-(h<0)+(H>23):pset(w,h):pset(w,h+8):ifpoint(w,y)thenprintxelse2
```

Bon c'est ilisible donc rework :

```basic
10 A=STICK(0):                          REM 
20 Y=Y-(A=5)+(A=1)-4*(Y=0):             REM 
30 X=X+1:                               REM incrémente X
40 PSET(W,Y):                           REM 
50 W=X MOD 118:                         REM 
60 IF W=1 THEN CLS:                     REM si W=1 efface l'écran
70 H=H+1-RND(0)*2-(H<0)+(H>23):         REM 
80 PSET(W,H):                           REM Affiche le point de coordonnée W,H
90 PSET(W,H+8):                         REM Affiche le point de coordonnée W,H+8
100 IF POINT(W,Y) THEN PRINT X ELSE 10: REM 
```

Explications : to do


___
