# Dessins géométriques (1985)(Eyrolle, Delahaye)(FR)


## Introduction

To do


___
## Les Listings

Tous les listings du livre sont ci-dessous.\
Ils sont complet contrairement au livre qui ne donne que les modifications à faire.

L'idée est de valider le programme principale puis de construire toutes les dérivées.

___
### 1. Polygones réguliers, étoiles, etc.

#### Polygones réguliers

Dessin 1 :

```basic
10 'POLYGONES REGULIERS
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K=4: CX=NP/2: CY=NP/2: R=NP*.45: AD=PI/4
200 FOR I=0 TO K
210 X=CX+R*COS(2*I*PI/K+AD): X%=INT(X)
220 Y=CY+R*SIN(2*I*PI/K+AD): Y%=INT(Y)
250 IF I=0 THEN LPRINT"M";X%;",";Y%
260 IF I>0 THEN LPRINT"D";X%;",";Y%
300 NEXT I
500 END
```

<p align="center">────────────────────</p>

Dessin 2 :

```basic
10 'POLYGONES REGULIERS
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K=3: CX=NP/2: CY=NP/2: R=NP*.45: AD=0
200 FOR I=0 TO K
210 X=CX+R*COS(2*I*PI/K+AD): X%=INT(X)
220 Y=CY+R*SIN(2*I*PI/K+AD): Y%=INT(Y)
250 IF I=0 THEN LPRINT"M";X%;",";Y%
260 IF I>0 THEN LPRINT"D";X%;",";Y%
300 NEXT I
500 END
```
<p align="center">────────────────────</p>

Dessin 3 :

```basic
10 'POLYGONES REGULIERS
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K=3: CX=NP/2: CY=NP/2: R=NP*.45: AD=PI/2
200 FOR I=0 TO K
210 X=CX+R*COS(2*I*PI/K+AD): X%=INT(X)
220 Y=CY+R*SIN(2*I*PI/K+AD): Y%=INT(Y)
250 IF I=0 THEN LPRINT"M";X%;",";Y%
260 IF I>0 THEN LPRINT"D";X%;",";Y%
300 NEXT I
500 END
```

<p align="center">────────────────────</p>

Dessin 4 :

```basic
10 'POLYGONES REGULIERS
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K=5: CX=NP/2: CY=NP/2: R=NP*.45: AD=PI/2
200 FOR I=0 TO K
210 X=CX+R*COS(2*I*PI/K+AD): X%=INT(X)
220 Y=CY+R*SIN(2*I*PI/K+AD): Y%=INT(Y)
250 IF I=0 THEN LPRINT"M";X%;",";Y%
260 IF I>0 THEN LPRINT"D";X%;",";Y%
300 NEXT I
500 END
```

<p align="center">────────────────────</p>

Dessin 5 :

```basic
10 'POLYGONES REGULIERS
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K=8: CX=NP/2: CY=NP/2: R=NP*.5: AD=PI/8
200 FOR I=0 TO K
210 X=CX+R*COS(2*I*PI/K+AD): X%=INT(X)
220 Y=CY+R*SIN(2*I*PI/K+AD): Y%=INT(Y)
250 IF I=0 THEN LPRINT"M";X%;",";Y%
260 IF I>0 THEN LPRINT"D";X%;",";Y%
300 NEXT I
500 END
```

<p align="center">────────────────────</p>


Dessin 6 :

```basic
10 'POLYGONES REGULIERS
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K=20: CX=NP/2: CY=NP/2: R=NP*.4: AD=0
200 FOR I=0 TO K
210 X=CX+R*COS(2*I*PI/K+AD): X%=INT(X)
220 Y=CY+R*SIN(2*I*PI/K+AD): Y%=INT(Y)
250 IF I=0 THEN LPRINT"M";X%;",";Y%
260 IF I>0 THEN LPRINT"D";X%;",";Y%
300 NEXT I
500 END
```

<p align="center">────────────────────</p>

#### Étoiles régulières

Dessin 7 :

```basic
10 'ETOILES REGULIERS
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K=5: H=3: CX=NP/2: CY=NP/2: R=NP*.45: AD=PI/2
200 FOR I=0 TO K
210 X=CX+R*COS(2*I*H*PI/K+AD): X%=INT(X)
220 Y=CY+R*SIN(2*I*H*PI/K+AD): Y%=INT(Y)
250 IF I=0 THEN LPRINT"M";X%;",";Y%
260 IF I>0 THEN LPRINT"D";X%;",";Y%
300 NEXT I
500 END
```

<p align="center">────────────────────</p>

Dessin 8 :

```basic
10 'ETOILES REGULIERS
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K=7: H=3: CX=NP/2: CY=NP/2: R=NP*.45: AD=PI/2
200 FOR I=0 TO K
210 X=CX+R*COS(2*I*H*PI/K+AD): X%=INT(X)
220 Y=CY+R*SIN(2*I*H*PI/K+AD): Y%=INT(Y)
250 IF I=0 THEN LPRINT"M";X%;",";Y%
260 IF I>0 THEN LPRINT"D";X%;",";Y%
300 NEXT I
500 END
```

<p align="center">────────────────────</p>

Dessin 9 :

```basic
10 'ETOILES REGULIERS
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K=20: H=9: CX=NP/2: CY=NP/2: R=NP*.45: AD=PI/2
200 FOR I=0 TO K
210 X=CX+R*COS(2*I*H*PI/K+AD): X%=INT(X)
220 Y=CY+R*SIN(2*I*H*PI/K+AD): Y%=INT(Y)
250 IF I=0 THEN LPRINT"M";X%;",";Y%
260 IF I>0 THEN LPRINT"D";X%;",";Y%
300 NEXT I
500 END
```

<p align="center">────────────────────</p>

Dessin 10 :

```basic
10 'ETOILES REGULIERS
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K=20: H=7: CX=NP/2: CY=NP/2: R=NP*.45: AD=PI/2
200 FOR I=0 TO K
210 X=CX+R*COS(2*I*H*PI/K+AD): X%=INT(X)
220 Y=CY+R*SIN(2*I*H*PI/K+AD): Y%=INT(Y)
250 IF I=0 THEN LPRINT"M";X%;",";Y%
260 IF I>0 THEN LPRINT"D";X%;",";Y%
300 NEXT I
500 END
```

<p align="center">────────────────────</p>

Dessin 11 :

```basic
10 'ETOILES REGULIERS
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K=51: H=20: CX=NP/2: CY=NP/2: R=NP*.45: AD=PI/2
200 FOR I=0 TO K
210 X=CX+R*COS(2*I*H*PI/K+AD): X%=INT(X)
220 Y=CY+R*SIN(2*I*H*PI/K+AD): Y%=INT(Y)
250 IF I=0 THEN LPRINT"M";X%;",";Y%
260 IF I>0 THEN LPRINT"D";X%;",";Y%
300 NEXT I
500 END
```

<p align="center">────────────────────</p>

Dessin 12 :

```basic
10 'ETOILES REGULIERS
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K=51: H=25: CX=NP/2: CY=NP/2: R=NP*.45: AD=PI/2
200 FOR I=0 TO K
210 X=CX+R*COS(2*I*H*PI/K+AD): X%=INT(X)
220 Y=CY+R*SIN(2*I*H*PI/K+AD): Y%=INT(Y)
250 IF I=0 THEN LPRINT"M";X%;",";Y%
260 IF I>0 THEN LPRINT"D";X%;",";Y%
300 NEXT I
500 END
```

<p align="center">────────────────────</p>

#### Composition 1

Dessin 13 :

```basic
10 'COMPOSITION 1
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K1=5: DX=NP/2: DY=NP/2: R1=NP*.27: A1=PI/2
110 K=25: H=12: R=NP*.22: AD=PI/2
200 FOR I1=0 TO K1-1
210 CX=DX+R1*COS(2*PI*I1/K1+A1)
220 CY=DY+R1*SIN(2*PI*I1/K1+A1)
250 GOSUB 5000
300 NEXT I1
500 END
5000 'SOUS-PROGRAMME ETOILES REGULIERES
5200 FOR I=0 TO K
5210 X=CX+R*COS(2*I*H*PI/K+AD): X%=INT(X)
5220 Y=CY+R*SIN(2*I*H*PI/K+AD): Y%=INT(Y)
5250 IF I=0 THEN LPRINT"M";X%;",";Y%
5260 IF I>0 THEN LPRINT"D";X%;",";Y%
5300 NEXT I
5500 RETURN
```

<p align="center">────────────────────</p>

Dessin 14 :

```basic
10 'COMPOSITION 1
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K1=6: DX=NP/2: DY=NP/2: R1=NP*.2: A1=0
110 K=24: H=11: R=NP*.3: AD=0
200 FOR I1=0 TO K1-1
210 CX=DX+R1*COS(2*PI*I1/K1+A1)
220 CY=DY+R1*SIN(2*PI*I1/K1+A1)
250 GOSUB 5000
300 NEXT I1
500 END
5000 'SOUS-PROGRAMME ETOILES REGULIERES
5200 FOR I=0 TO K
5210 X=CX+R*COS(2*I*H*PI/K+AD): X%=INT(X)
5220 Y=CY+R*SIN(2*I*H*PI/K+AD): Y%=INT(Y)
5250 IF I=0 THEN LPRINT"M";X%;",";Y%
5260 IF I>0 THEN LPRINT"D";X%;",";Y%
5300 NEXT I
5500 RETURN
```

<p align="center">────────────────────</p>

Dessin 15 :

```basic
10 'COMPOSITION 1
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K1=40: DX=NP/2: DY=NP/2: R1=NP*.25: A1=PI/2
110 K=80: H=1: R=NP*.25: AD=PI/2
200 FOR I1=0 TO K1-1
210 CX=DX+R1*COS(2*PI*I1/K1+A1)
220 CY=DY+R1*SIN(2*PI*I1/K1+A1)
250 GOSUB 5000
300 NEXT I1
500 END
5000 'SOUS-PROGRAMME ETOILES REGULIERES
5200 FOR I=0 TO K
5210 X=CX+R*COS(2*I*H*PI/K+AD): X%=INT(X)
5220 Y=CY+R*SIN(2*I*H*PI/K+AD): Y%=INT(Y)
5250 IF I=0 THEN LPRINT"M";X%;",";Y%
5260 IF I>0 THEN LPRINT"D";X%;",";Y%
5300 NEXT I
5500 RETURN
```

<p align="center">────────────────────</p>

Dessin 16 :

```basic
10 'COMPOSITION 1
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K1=10: DX=NP/2: DY=NP/2: R1=NP*.35: REM A1=PI/2
110 K=10: H=3: R=NP*.15: AD=0
200 FOR I1=0 TO K1-1
210 CX=DX+R1*COS(2*PI*I1/K1+A1)
220 CY=DY+R1*SIN(2*PI*I1/K1+A1)
250 GOSUB 5000
300 NEXT I1
500 END
5000 'SOUS-PROGRAMME ETOILES REGULIERES
5200 FOR I=0 TO K
5210 X=CX+R*COS(2*I*H*PI/K+AD): X%=INT(X)
5220 Y=CY+R*SIN(2*I*H*PI/K+AD): Y%=INT(Y)
5250 IF I=0 THEN LPRINT"M";X%;",";Y%
5260 IF I>0 THEN LPRINT"D";X%;",";Y%
5300 NEXT I
5500 RETURN
```

NDR : PB ligne 100, A1 absent dans le livre. En REM et donc à tester.

<p align="center">────────────────────</p>

Dessin 17 :

```basic
10 'COMPOSITION 1
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K1=63: DX=NP/2: DY=NP/2: R1=NP*.15: A1=0
110 K=4: H=1: R=NP*.35: AD=0
200 FOR I1=0 TO K1-1
210 CX=DX+R1*COS(2*PI*I1/K1+A1)
220 CY=DY+R1*SIN(2*PI*I1/K1+A1)
250 GOSUB 5000
300 NEXT I1
500 END
5000 'SOUS-PROGRAMME ETOILES REGULIERES
5200 FOR I=0 TO K
5210 X=CX+R*COS(2*I*H*PI/K+AD): X%=INT(X)
5220 Y=CY+R*SIN(2*I*H*PI/K+AD): Y%=INT(Y)
5250 IF I=0 THEN LPRINT"M";X%;",";Y%
5260 IF I>0 THEN LPRINT"D";X%;",";Y%
5300 NEXT I
5500 RETURN
```

<p align="center">────────────────────</p>

Dessin 18 :

```basic
10 'COMPOSITION 1
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K1=25: DX=NP/2: DY=NP/2: R1=NP*.1: A1=PI/2
110 K=5: H=2: R=NP*.4: AD=PI/2
200 FOR I1=0 TO K1-1
210 CX=DX+R1*COS(2*PI*I1/K1+A1)
220 CY=DY+R1*SIN(2*PI*I1/K1+A1)
250 GOSUB 5000
300 NEXT I1
500 END
5000 'SOUS-PROGRAMME ETOILES REGULIERES
5200 FOR I=0 TO K
5210 X=CX+R*COS(2*I*H*PI/K+AD): X%=INT(X)
5220 Y=CY+R*SIN(2*I*H*PI/K+AD): Y%=INT(Y)
5250 IF I=0 THEN LPRINT"M";X%;",";Y%
5260 IF I>0 THEN LPRINT"D";X%;",";Y%
5300 NEXT I
5500 RETURN
```

<p align="center">────────────────────</p>

Dessin 19 :

```basic
10 'COMPOSITION 1
50 LPRINT CHR$(18): LPRINT"M0,-800": LPRINT"I": NP=480: PI=ATN(1)*4
100 K1=99: DX=NP/2: DY=NP/2: R1=NP*.25: A1=0
110 K=7: H=3: R=NP*.25: AD=PI/2
200 FOR I1=0 TO K1-1
210 CX=DX+R1*COS(2*PI*I1/K1+A1)
220 CY=DY+R1*SIN(2*PI*I1/K1+A1)
250 GOSUB 5000
300 NEXT I1
500 END
5000 'SOUS-PROGRAMME ETOILES REGULIERES
5200 FOR I=0 TO K
5210 X=CX+R*COS(2*I*H*PI/K+AD): X%=INT(X)
5220 Y=CY+R*SIN(2*I*H*PI/K+AD): Y%=INT(1.5*Y)
5250 IF I=0 THEN LPRINT"M";X%;",";Y%
5260 IF I>0 THEN LPRINT"D";X%;",";Y%
5300 NEXT I
5500 RETURN
```

NDR :
- M0,-800, en ligne 50 corrigé, sinon le dessin déborde du papier en haut.

<p align="center">────────────────────</p>

#### Composition 2


Dessin 20 :

```basic
10 'COMPOSITION 2
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K1=8: N=32: K=16: H=5: R1=NP*.36: R=NP*.14: RR=.9
110 DX=NP/2: DY=NP/2: A1=0: AD=0
200 FOR I1=0 TO N
210 R2=R1*RR^I1: R3=R*RR^I1
220 CX=DX+R2*COS(2*PI*I1/K1+A1)
230 CY=DY+R2*SIN(2*PI*I1/K1+A1)
250 GOSUB 5000
260 IF I>0 THEN LPRINT"D";X%;",";Y%
300 NEXT I1
500 END
5000 'SOUS-PROGRAMME ETOILES REGULIERES
5200 FOR I=0 TO K
5210 X=CX+R3*COS(2*I*H*PI/K+AD): X%=INT(X)
5220 Y=CY+R3*SIN(2*I*H*PI/K+AD): Y%=INT(Y)
5250 IF I=0 THEN LPRINT"M";X%;",";Y%
5260 IF I>0 THEN LPRINT"D";X%;",";Y%
5300 NEXT I
5500 RETURN
```

<p align="center">────────────────────</p>

Dessin 21 :

```basic
10 'COMPOSITION 2
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K1=10: N=30: K=8: H=3: R1=NP*.35: R=NP*.15: RR=.85
110 DX=NP/2: DY=NP/2: A1=0: AD=0
200 FOR I1=0 TO N
210 R2=R1*RR^I1: R3=R*RR^I1
220 CX=DX+R2*COS(2*PI*I1/K1+A1)
230 CY=DY+R2*SIN(2*PI*I1/K1+A1)
250 GOSUB 5000
260 IF I>0 THEN LPRINT"D";X%;",";Y%
300 NEXT I1
500 END
5000 'SOUS-PROGRAMME ETOILES REGULIERES
5200 FOR I=0 TO K
5210 X=CX+R3*COS(2*I*H*PI/K+AD): X%=INT(X)
5220 Y=CY+R3*SIN(2*I*H*PI/K+AD): Y%=INT(Y)
5250 IF I=0 THEN LPRINT"M";X%;",";Y%
5260 IF I>0 THEN LPRINT"D";X%;",";Y%
5300 NEXT I
5500 RETURN
```

<p align="center">────────────────────</p>

Dessin 22 :

```basic
10 'COMPOSITION 2
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K1=10: N=10: K=18: H=7: R1=NP*.0: R=NP*.5: RR=.80
110 DX=NP/2: DY=NP/2: A1=0: AD=0
200 FOR I1=0 TO N
210 R2=R1*RR^I1: R3=R*RR^I1
220 CX=DX+R2*COS(2*PI*I1/K1+A1)
230 CY=DY+R2*SIN(2*PI*I1/K1+A1)
250 GOSUB 5000
260 IF I>0 THEN LPRINT"D";X%;",";Y%
300 NEXT I1
500 END
5000 'SOUS-PROGRAMME ETOILES REGULIERES
5200 FOR I=0 TO K
5210 X=CX+R3*COS(2*I*H*PI/K+AD): X%=INT(X)
5220 Y=CY+R3*SIN(2*I*H*PI/K+AD): Y%=INT(Y)
5250 IF I=0 THEN LPRINT"M";X%;",";Y%
5260 IF I>0 THEN LPRINT"D";X%;",";Y%
5300 NEXT I
5500 RETURN
```

<p align="center">────────────────────</p>

Dessin 23 :

```basic
10 'COMPOSITION 2
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K1=10: N=10: K=21: H=10: R1=NP*.0: R=NP*.5: RR=.75
110 DX=NP/2: DY=NP/2: A1=0: AD=0
200 FOR I1=0 TO N
210 R2=R1*RR^I1: R3=R*RR^I1
220 CX=DX+R2*COS(2*PI*I1/K1+A1)
230 CY=DY+R2*SIN(2*PI*I1/K1+A1)
250 GOSUB 5000
260 IF I>0 THEN LPRINT"D";X%;",";Y%
300 NEXT I1
500 END
5000 'SOUS-PROGRAMME ETOILES REGULIERES
5200 FOR I=0 TO K
5210 X=CX+R3*COS(2*I*H*PI/K+AD): X%=INT(X)
5220 Y=CY+R3*SIN(2*I*H*PI/K+AD): Y%=INT(Y)
5250 IF I=0 THEN LPRINT"M";X%;",";Y%
5260 IF I>0 THEN LPRINT"D";X%;",";Y%
5300 NEXT I
5500 RETURN
```

<p align="center">────────────────────</p>

Dessin 24 :

```basic
10 'COMPOSITION 2
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K1=28: N=56: K=7: H=3: R1=NP*.15: R=NP*.35: RR=.95
110 DX=NP/2: DY=NP/2: A1=0: AD=0
200 FOR I1=0 TO N
210 R2=R1*RR^I1: R3=R*RR^I1
220 CX=DX+R2*COS(2*PI*I1/K1+A1)
230 CY=DY+R2*SIN(2*PI*I1/K1+A1)
250 GOSUB 5000
260 IF I>0 THEN LPRINT"D";X%;",";Y%
300 NEXT I1
500 END
5000 'SOUS-PROGRAMME ETOILES REGULIERES
5200 FOR I=0 TO K
5210 X=CX+R3*COS(2*I*H*PI/K+AD): X%=INT(X)
5220 Y=CY+R3*SIN(2*I*H*PI/K+AD): Y%=INT(Y)
5250 IF I=0 THEN LPRINT"M";X%;",";Y%
5260 IF I>0 THEN LPRINT"D";X%;",";Y%
5300 NEXT I
5500 RETURN
```

<p align="center">────────────────────</p>

Dessin 25 :

```basic
10 'COMPOSITION 2
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K1=28: N=60: K=8: H=1: R1=NP*.05: R=NP*.45: RR=.945
110 DX=NP/2: DY=NP/2: A1=0: AD=0
200 FOR I1=0 TO N
210 R2=R1*RR^I1: R3=R*RR^I1
220 CX=DX+R2*COS(2*PI*I1/K1+A1)
230 CY=DY+R2*SIN(2*PI*I1/K1+A1)
250 GOSUB 5000
260 IF I>0 THEN LPRINT"D";X%;",";Y%
300 NEXT I1
500 END
5000 'SOUS-PROGRAMME ETOILES REGULIERES
5200 FOR I=0 TO K
5210 X=CX+R3*COS(2*I*H*PI/K+AD): X%=INT(X)
5220 Y=CY+R3*SIN(2*I*H*PI/K+AD): Y%=INT(Y)
5250 IF I=0 THEN LPRINT"M";X%;",";Y%
5260 IF I>0 THEN LPRINT"D";X%;",";Y%
5300 NEXT I
5500 RETURN
```

<p align="center">────────────────────</p>

#### Joligone

Dessin 26 :

```basic
10 ' JOLIGONES
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K=200: AN=15*PI/31: RA=.98
110 AA=0: RR=.80*NP
120 X=(NP-RR)/2: Y=0: X%=INT(X): Y%=INT(Y)
130 LPRINT"M";X%;",";Y%
200 FOR I=0 TO K
210 X=X+RR*COS(AA): X%=INT(X)
220 Y=Y+RR*SIN(AA): Y%=INT(Y)
230 LPRINT"D";X%;",";Y%
240 AA=AA+AN: RR=RR*AA
300 NEXT I1
500 END
```

<p align="center">────────────────────</p>

Dessin 27 :

```basic
10 ' JOLIGONES
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K=120: AN=29*PI/30: RA=.98
110 AA=0: RR=.80*NP
120 X=(NP-RR)/2: Y=0: X%=INT(X): Y%=INT(Y)
130 LPRINT"M";X%;",";Y%
200 FOR I=0 TO K
210 X=X+RR*COS(AA): X%=INT(X)
220 Y=Y+RR*SIN(AA): Y%=INT(Y)
230 LPRINT"D";X%;",";Y%
240 AA=AA+AN: RR=RR*AA
300 NEXT I1
500 END
```

<p align="center">────────────────────</p>

Dessin 28 :

```basic
10 ' JOLIGONES
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K=200: AN=PI/4: RA=.98
110 AA=0: RR=.40*NP
120 X=(NP-RR)/2: Y=0: X%=INT(X): Y%=INT(Y)
130 LPRINT"M";X%;",";Y%
200 FOR I=0 TO K
210 X=X+RR*COS(AA): X%=INT(X)
220 Y=Y+RR*SIN(AA): Y%=INT(Y)
230 LPRINT"D";X%;",";Y%
240 AA=AA+AN: RR=RR*AA
300 NEXT I1
500 END
```

<p align="center">────────────────────</p>

Dessin 29 :

```basic
10 ' JOLIGONES
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K=2000: AN=PI/20: RA=.998
110 AA=0: RR=.065*NP
120 X=(NP-RR)/2: Y=0: X%=INT(X): Y%=INT(Y)
130 LPRINT"M";X%;",";Y%
200 FOR I=0 TO K
210 X=X+RR*COS(AA): X%=INT(X)
220 Y=Y+RR*SIN(AA): Y%=INT(Y)
230 LPRINT"D";X%;",";Y%
240 AA=AA+AN: RR=RR*AA
300 NEXT I1
500 END
```

<p align="center">────────────────────</p>

Dessin 30 :

```basic
10 ' JOLIGONES
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K=200: AN=4*PI/5+.02: RA=.99
110 AA=0: RR=.80*NP
120 X=(NP-RR)/2: Y=0: X%=INT(X): Y%=INT(Y)
130 LPRINT"M";X%;",";Y%
200 FOR I=0 TO K
210 X=X+RR*COS(AA): X%=INT(X)
220 Y=Y+RR*SIN(AA): Y%=INT(Y)
230 LPRINT"D";X%;",";Y%
240 AA=AA+AN: RR=RR*AA
300 NEXT I1
500 END
```

<p align="center">────────────────────</p>

Dessin 31 :

```basic
10 ' JOLIGONES
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K=100: AN=6*PI/7: RA=.98
110 AA=0: RR=.80*NP
120 X=(NP-RR)/2: Y=0: X%=INT(X): Y%=INT(Y)
130 LPRINT"M";X%;",";Y%
200 FOR I=0 TO K
210 X=X+RR*COS(AA): X%=INT(X)
220 Y=Y+RR*SIN(AA): Y%=INT(Y)
230 LPRINT"D";X%;",";Y%
240 AA=AA+AN: RR=RR*AA
300 NEXT I1
500 END
```

<p align="center">────────────────────</p>

Dessin 32 :

```basic
10 ' JOLIGONES
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K=300: AN=2*PI/5+.01: RA=.993
110 AA=0: RR=.60*NP
120 X=(NP-RR)/2: Y=0: X%=INT(X): Y%=INT(Y)
130 LPRINT"M";X%;",";Y%
200 FOR I=0 TO K
210 X=X+RR*COS(AA): X%=INT(X)
220 Y=Y+RR*SIN(AA): Y%=INT(Y)
230 LPRINT"D";X%;",";Y%
240 AA=AA+AN: RR=RR*AA
300 NEXT I1
500 END
```

<p align="center">────────────────────</p>

Dessin 33 :

```basic
10 ' JOLIGONES
50 LPRINT CHR$(18): LPRINT"M0,-800": LPRINT"I": NP=480: PI=ATN(1)*4
100 K=400: AN=19*PI/60: RA=.996
110 AA=0: RR=.40*NP
120 X=(NP-RR)/2: Y=0: X%=INT(X): Y%=INT(Y)
130 LPRINT"M";X%;",";Y%
200 FOR I=0 TO K
210 X=X+RR*COS(AA): X%=INT(X)
220 Y=Y+RR*SIN(AA): Y%=INT(1.7*Y)
230 LPRINT"D";X%;",";Y%
240 AA=AA+AN: RR=RR*AA
300 NEXT I1
500 END
```

NDR :
- M0,-800, en ligne 50 corrigé, sinon le dessin déborde du papier en haut.

___
### 2. Dessins à partir de données

#### Cheval


Dessin 34 :

```basic
10 'CHEVAL
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
1000 DATA 1000, 10,10, 8,12, 9,16, 12,17, 13,18, 14,20
1010 DATA 1000, 13,18, 12,19, 9,21, 9,20, 10,19, 9,17, 7,20, 8,22, 12,22
1020 DATA 1000, 12,20, 12,22, 13,26, 16,31, 18,31, 19,32
1030 DATA 1000, 16,31, 14,31, 14,32
1040 DATA 1000, 14,31, 10,30, 12,31, 10,32
1050 DATA 1000, 12,32, 13,31
1060 DATA 1000, 10,34, 16,36
1070 DATR 1000, 16,35, 16,37, 18,35, 17,34
1080 DATA 1000, 17,36, 20,36, 22,32, 19,26
1090 DATA 1000, 20,36, 22,36, 22,34, 24,32, 24,30, 19,26, 18,23, 21,22, 21,24
1100 DATA 30,30, 34,31, 36,31, 33,26, 32,22, 28,22, 27,20, 29,17, 30,19, 29,20
1110 DATA 29,21, 32,19, 33,18, 32,17, 29,16, 28,12, 30,10, 21,4, 21,2 
1120 DATA 18,3, 19,6, 24,10, 24,12, 22,14, 22,16, 23,17
1130 DATA 1000, 22,16, 17,16, 16,17, 17,18
1140 DATA 1000, 16,17, 16,16, 10,14, 10,12, 12,11, 10,10
1150 DATA 1000, 21,21, 22,24, 30,30
1160 DATA 1000, 24,24, 34,28
1170 DATA 1000, 25,23, 33,26
1190 DATA 1000, 25,21, 27,20
1200 DATA 1000, 23,21, 24,19
1210 DATA 1000, 27,20, 22,19, 22,21
1220 DATA 1000, 22,19, 21,20
1230 DATA 1000, 12,34, 15,35, 16,34, 16,33
1240 DATA 1000, 15,35, 15,34, 16,34, 15,34, 15,35
1250 DATA 1000, 24,12, 26,19, 19,5, 19,5
1260 DATA 1000, 28,22, 25,22
1500 DATA 2000
2000 '
2100 READ A
2110 IF A=2000 THEN 2400
2120 IF A=1000 THEN B1=0 :READ A
2130 READ B
2200 X%=NP*A/40
2210 Y%=NP*B/40
2300 IF B1=0 THEN B1=1: LPRINT"M";X%;",";Y%
2310 IF B1=1 THEN LPRINT"D";X%;",";Y%
2320 GOTO 2100
2400 REM
5000 END
```

<p align="center">────────────────────</p>

Dessin 35 :

```basic
```

<p align="center">────────────────────</p>

Dessin 36 :

```basic
```


<p align="center">────────────────────</p>

Dessin 37 :

```basic
```

<p align="center">────────────────────</p>

Dessin 38 :

```basic
```


<p align="center">────────────────────</p>

Dessin 39 :

```basic
```

<p align="center">────────────────────</p>

Dessin 40 :

```basic
```

<p align="center">────────────────────</p>

Dessin 41 :

```basic
```

<p align="center">────────────────────</p>

Dessin 42 :

```basic
```

<p align="center">────────────────────</p>

Dessin 43 :

```basic
```



#### Lion, oiseaux-poissons, smurf

Dessin 44 :

```basic
10 'LION
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
1000 DATA 1000, -2.5,0, -2,1, -1,2, 0,7, 1,7, 2,8, 2,11, 3,14, 3,5, 13,5
1010 DATA 2.5,11, 2.5,9
1020 DATA 1000, 3.5,13.5, 4,13, 3,11, 3,9, 3,11, 4,13, 5,12, 3.5,11, 3.5,9
1030 DATA 3.5,11, 5,12, 5,11, 4,10, 4,9, 8,9, 7,11, 8,13, 10,14, 12,13, 13,11
1040 DATA 12,11, 11,10, 12,8, 13,7, 14,2, 15,2, 16,1, 16,0, 12,0, 12,2, 11,5
1050 DATA 11.5,6, 11,5, 9,3, 9,2, 10,1, 10,0, 6,0, 7,2, 8,6, 7,2, 6,4, 4,5
1060 DATA 5,7, 4,8, 5,7, 4,5, 2,4, 1,2, 2,2, 3,1, 2.5,0, -2.5,0
1070 DATA 1000, 6,4, 7.5,3.5
1080 DATA 1000, 12,11, 10,10.5, 9,10.5
1090 DATA 1000, 12.5,12, 12,12, 11,11.5, 12,12, 12,12.5, 11.5,12.5, 10.5,13
1100 DATA 10,13, 10,13.5, 10.5,13.5, 10.5,13, 11.5,12.5, 12,12.5, 12,13
1110 DATA 1000, 7.5,12, 8.5,12, 8.5,11.5
1200 DATA 2000
2000 '
2100 READ A
2110 IF A=2000 THEN 2400
2120 IF A=1000 THEN B1=0: READ A
2130 READ B
2200 X%=INT(NP*(A+5)/25)
2210 Y%=INT(NP*(B+5)/25)
2300 IF B1=0 THEN B1=1: LPRINT"M";X%;",";Y%
2310 IF B1=1 THEN LPRINT"D";X%;",";Y%
2320 GOTO 2100
2400 REM
3000 END
```

<p align="center">────────────────────</p>

Dessin 45 :

```basic
```

<p align="center">────────────────────</p>

Dessin 46 : Oiseaux-Poissons

```basic
```

<p align="center">────────────────────</p>

Dessin 47 :

```basic
```

<p align="center">────────────────────</p>

Dessin 48 : Smurf

```basic
```

<p align="center">────────────────────</p>

Dessin 49 :

```basic
```



___
### 3. Dragons de papiers pliés

#### Dragons

Dessin 50 :

```basic
10 'DRAGONS
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4





```

<p align="center">────────────────────</p>

Dessin 51 :

```basic
```

<p align="center">────────────────────</p>

Dessin 52 :

```basic
```

<p align="center">────────────────────</p>

Dessin 53 :

```basic
```

<p align="center">────────────────────</p>

Dessin 54 :

```basic
```

<p align="center">────────────────────</p>

Dessin 55 :

```basic
```

<p align="center">────────────────────</p>

Dessin 56 :

```basic
```

<p align="center">────────────────────</p>

Dessin 57 :

```basic
```

<p align="center">────────────────────</p>

Dessin 58 :

```basic
```

<p align="center">────────────────────</p>

Dessin 59 :

```basic
```

<p align="center">────────────────────</p>

Dessin 60 :

```basic
```

<p align="center">────────────────────</p>

Dessin 61 :

```basic
```

<p align="center">────────────────────</p>

Dessin 62 :

```basic
```


<p align="center">────────────────────</p>

Dessin 63 :

```basic
```


<p align="center">────────────────────</p>

Dessin 64 :

```basic
```


___
### 4. Étoiles fractales

#### Étoiles fractales


Dessin 65 :

```basic
10 ' ETOILES FRACTALES
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(I)*4
100 N=5: K=5: RA=.35: LL=NP: AA=4*PI/5
110 X0=(NP-LL)/2: Y0=NP/4: A0=-AA
120 LPRINT"M";INT(X0);",";INT(Y0)
190 NN=N*(N-1)^(K-1)-1
200 FOR I=0 TO NN
210 I1=I: H=0
300 IF (I1 MOD (N-1))=0 AND H<K-1 THEN I1=I1/(N-1): H=H+1: GOTO 300
310 L0=LL*RA^(K-1-H)
320 A0=A0+AA
330 X0=X0+L0*COS(A0)
340 Y0=Y0+L0*SIN(A0)
350 LPRINT "D";INT(X0);",";INT(Y0)
400 NEXT I
1000 END
```

<p align="center">────────────────────</p>

Dessin 66 :

```basic
```

<p align="center">────────────────────</p>

Dessin 67 :

```basic
```

<p align="center">────────────────────</p>

Dessin 68 :

```basic
```

<p align="center">────────────────────</p>

Dessin 68 :

```basic
```

<p align="center">────────────────────</p>

Dessin 69 :

```basic
```

<p align="center">────────────────────</p>

Dessin 70 :

```basic
```

<p align="center">────────────────────</p>

Dessin 71 :

```basic
```

<p align="center">────────────────────</p>

Dessin 72 :

```basic
```

<p align="center">────────────────────</p>

Dessin 73 :

```basic
```

<p align="center">────────────────────</p>

Dessin 74 :

```basic
```

<p align="center">────────────────────</p>

Dessin 75 :

```basic
```

<p align="center">────────────────────</p>

Dessin 76 :

```basic
```

<p align="center">────────────────────</p>

Dessin 77 :

```basic
```



___
#### 5. Courbes

#### Courbes orbitales

Dessin 78 :

```basic
10 ' COURBES ORBITALES
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(I)*4
100 N=2000: T1=2: T2=100: K1=1: K2=1: R1=NP*.25
200 FOR I=0 TO N
210 R2=NP*.2*(1-I/N)
220 A1=2*PI*I/N*T1: A2=2*PI*I/N*T2
230 X%=INT(NP*.5+R1*COS(K1*A1)+R2*COS(A2))
240 X%=INT(NP*.5+R1*SIN(K2*A1)+R2*SIN(A2))
300 IF I=0 THEN LPRINT"M";X%;",";Y%
310 IF I>0 THEN LPRINT"D";X%;",";Y%
400 NEXT I
500 END
```

<p align="center">────────────────────</p>

Dessin 79 :

```basic
```

<p align="center">────────────────────</p>

Dessin 80 :

```basic
```

<p align="center">────────────────────</p>

Dessin 81 :

```basic
```

<p align="center">────────────────────</p>

Dessin 82 :

```basic
```

<p align="center">────────────────────</p>

Dessin 83 :

```basic
```

<p align="center">────────────────────</p>

Dessin 84 :

```basic
```

<p align="center">────────────────────</p>

Dessin 85 :

```basic
```

<p align="center">────────────────────</p>

Dessin 86 :

```basic
```

<p align="center">────────────────────</p>

#### Courbes tournantes

Dessin 87 :

```basic
10 'COURBE TOURNANTES
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(I)*4
100 N=2000: T1=1: T2=100: K1=1: K2=1: H1=1: H2=1: R1=NP/6 :R2=NP/4
200 FOR I=0 TO N
210 S=COS(4*PI*I/N)*.4+.6
220 AN=2*PI*I/N
230 C1=COS(H1*AN*T1): S1=SIN(H2*AN*T1)
240 C2=S*COS(K1*AN*T2): S2=S*SIN(K2*AN*T2)
300 X=NP/2+R1*C1+R2*(C1*C2-S1*S2)
310 Y=NP/2+R1*S1+R2*(S1*C2+C1*S2)
400 IF I=0 THEN LPRINT'M";INT(X);",";INT(Y)
410 IF I>0 THEN LPRINT'D";INT(X);",";INT(Y)
500 NEXT I
1000 END
```

<p align="center">────────────────────</p>

Dessin 88 :

```basic
```

<p align="center">────────────────────</p>

Dessin 89 :

```basic
```

<p align="center">────────────────────</p>

Dessin 90 :

```basic
```

<p align="center">────────────────────</p>

Dessin 91 :

```basic
```

<p align="center">────────────────────</p>

Dessin 92 :

```basic
```

<p align="center">────────────────────</p>

Dessin 93 :

```basic
```

<p align="center">────────────────────</p>

Dessin 93 :

```basic
```

<p align="center">────────────────────</p>

Dessin 94 :

```basic
```

<p align="center">────────────────────</p>

Dessin 95 :

```basic
```

<p align="center">────────────────────</p>

Dessin 96 :

```basic
```


<p align="center">────────────────────</p>

#### Courbes spirales

Dessin 97 :

```basic
10 'COURBE SPIRALES
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(I)*4
100 N=2000: T=40: R=.8: L=.1
200 FOR I=0 TO N
210 RR=L^(I/N)
220 AN=2*PI*I/N
230 X=RR*COS(T*AN): Y=RR*R*SIN(T*AN)
240 CO=COS(AN): SI=SIN(AN)
250 XX=X*CO-Y*SI: YY=X*SI+Y*CO
260 X%=INT(NP/2*(1+XX))
270 Y%=INT(NP/2*(1+YY))
300 IF I=0 THEN LPRINT"M";X%;",";Y%
310 IF Y>0 THEN LPRINT"D";X%;",";Y%
400 NEXT I
500 END
```

<p align="center">────────────────────</p>

Dessin 98 :

```basic
```

<p align="center">────────────────────</p>

Dessin 99 :

```basic
```

<p align="center">────────────────────</p>

Dessin 100 :

```basic
```


___
### 6. Dessins linéaires

#### Biparti complet

Dessin 101 :

```basic
10 'BIPARTI COMPLET
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(I)*4
100 N=10: XA=0: YA=0: XB=0: YB=NP: XC=NP: YC=0: XD=NP: YD=NP
200 FOR I=0 TO N
210 X1=(I*XA+(N-I)*XB)/N
220 Y1=(I*YA+(N-I)*YB)/N
230 X%=INT(X1): Y%=INT(Y1)
300 FOR J=0 TO N
310 LPRINT"M";X%;",";Y%
320 X2=(J*XC+(N-J)*XD)/N
330 Y2=(J*YC+(N-J)*YD)/N
340 XX%=INT(X2): YY%=INT(Y2)
350 LPRINT"D";XX%;",";YY%
400 NEXT J:NEXT I
500 END
```

<p align="center">────────────────────</p>

Dessin 102 :

```basic
```

<p align="center">────────────────────</p>

Dessin 103 :

```basic
```

<p align="center">────────────────────</p>

Dessin 104 :

```basic
```


<p align="center">────────────────────</p>

#### Linéaires modulo

Dessin 105 :

```basic
10 'LINEAIRES MODULO
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(I)*4
100 n=400: m=n: K1=4: k2=5: h=2
110 dim x%(n),y%(n)
200 for i=0 to n
210 X%(I)=INT(NP*.5*(1+SIN(K1*I*PI/N)))
220 Y%(I)=INT(NP*.75*(1+COS(K2*I*PI/N)))
230 NEXT I
300 FOR I=0 TO M
310 I1=I MOD N: I2=H*I MOD N
320 LPRINT"M";X%(I1);",";Y%(I1)
330 LPRINT"D";X%(I2);",";Y%(I2)
400 NEXT I
500 END
```

<p align="center">────────────────────</p>

Dessin 106 :

```basic
```

<p align="center">────────────────────</p>

Dessin 107 :

```basic
```

<p align="center">────────────────────</p>

Dessin 108 :

```basic
```

<p align="center">────────────────────</p>

Dessin 109 :

```basic
```


<p align="center">────────────────────</p>

#### linéaires batons


Dessin 110 :

```basic
```

<p align="center">────────────────────</p>

Dessin 111 :

```basic
```

<p align="center">────────────────────</p>

Dessin 112 :

```basic
```

<p align="center">────────────────────</p>

Dessin 113 :

```basic
```

<p align="center">────────────────────</p>

Dessin 114 :

```basic
```


___
### 7. Fractales simples

#### Fractales simples 

Dessin 115 :

```basic
10 'FRACTALES SIMPLES
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 M=3: N=4: K=4
110 DIM X(M),Y(M),L(N-1),A(N-1)
120 X(0)=0: X(1)=NP: X(2)=NP*.5: X(3)=0
130 Y(0)=SQR(3)/2*NP: Y(1)=Y(0): Y(2)=0: Y(3)=Y(0)
140 L(0)=1/3: L(1)=L(0): L(2)=L(0): L(3)=L(0)
150 A(0)=0: A(1)=PI/3: A(2)=-A(1): A(3)=0
200 FOR II=0 TO M-1
210 XD=X(II): YD=Y(II): XA=X(II+1): YA=(Y(II+1)
250 X0=XD: Y0=YD
260 X1=INT(X0): Y1=INT(Y0)
270 LPRINT"M";X1;",";Y1
280 IF XA<>XD THEN A0=ATN((YA-YD)/(XA-XD)) ELSE A0=PI/2*SGN(YA-YD)
285 IF (XA-XD)<0 THEN A0=A0+PI
290 L0=SQR((XA-XD)^2+(YA-YD)^2
300 FOR I=0 TO N^K-1
310 LL=L0: AA=A0: T1=I
390 IF K=0 THEN 470
400 FOR J=K-1 TO 0 STEP -1
410 R=N^J: T2=INT(T1/R)
430 AA=AA+A(T2): LL=LL*L(T2)
440 T1=T1-T2*R
450 NEXT J
470 X0=X0+LL*COS(AA): X1=INT(X0)
480 Y0=Y0+LL*SIN(AA): Y1=INT(Y0)
490 LPRINT"D";X1;",";Y1
500 NEXT I
600 NEXT II
1000 END
```

<p align="center">────────────────────</p>

Dessin 116 :

```basic
```

<p align="center">────────────────────</p>

Dessin 117 :

```basic
```

<p align="center">────────────────────</p>

Dessin 118 :

```basic
```

<p align="center">────────────────────</p>

Dessin 119 :

```basic
```

<p align="center">────────────────────</p>

Dessin 120 :

```basic
```

<p align="center">────────────────────</p>

Dessin 121 :

```basic
```

<p align="center">────────────────────</p>

Dessin 122 :

```basic
```

<p align="center">────────────────────</p>

Dessin 123 :

```basic
```


<p align="center">────────────────────</p>

Dessin 124 :

```basic
```

<p align="center">────────────────────</p>

Dessin 125 :

```basic
```


<p align="center">────────────────────</p>

Dessin 126 :

```basic
```

<p align="center">────────────────────</p>

Dessin 127 :

```basic
```

<p align="center">────────────────────</p>

Dessin 128 :

```basic
```


<p align="center">────────────────────</p>

Dessin 129 :

```basic
```

<p align="center">────────────────────</p>

Dessin 130 :

```basic
```

<p align="center">────────────────────</p>

Dessin 131 :

```basic
```

<p align="center">────────────────────</p>

Dessin 132 :

```basic
```

<p align="center">────────────────────</p>

Dessin 133 :

```basic
```

<p align="center">────────────────────</p>

Dessin 134 :

```basic
```

<p align="center">────────────────────</p>

Dessin 135 :

```basic
```





#### Fractales simples arrondies

Dessin 136 :

```basic
```

<p align="center">────────────────────</p>

Dessin 137 :

```basic
```

<p align="center">────────────────────</p>

Dessin 138 :

```basic
```

<p align="center">────────────────────</p>

Dessin 139 :

```basic
```

<p align="center">────────────────────</p>

Dessin 140 :

```basic
```

<p align="center">────────────────────</p>

Dessin 141 :

```basic
```

<p align="center">────────────────────</p>

Dessin 142 :

```basic
```

<p align="center">────────────────────</p>

Dessin 143 :

```basic
```

<p align="center">────────────────────</p>

Dessin 144 :

```basic
```

<p align="center">────────────────────</p>

Dessin 145 :

```basic
```

<p align="center">────────────────────</p>

Dessin 146 :

```basic
```

<p align="center">────────────────────</p>

Dessin 147 :

```basic
```

<p align="center">────────────────────</p>

Dessin 148 :

```basic
```

<p align="center">────────────────────</p>

Dessin 149 :

```basic
```

<p align="center">────────────────────</p>

Dessin 150 :

```basic
```

<p align="center">────────────────────</p>

Dessin 151 :

```basic
```



<p align="center">────────────────────</p>

#### Fractales simples déformées


Dessin 152 :

```basic
```

<p align="center">────────────────────</p>

Dessin 153 :

```basic
```

<p align="center">────────────────────</p>

Dessin 154 :

```basic
```

<p align="center">────────────────────</p>

Dessin 155 :

```basic
```

<p align="center">────────────────────</p>

Dessin 156 :

```basic
```

<p align="center">────────────────────</p>

Dessin 157 :

```basic
```

<p align="center">────────────────────</p>

Dessin 158 :

```basic
```

<p align="center">────────────────────</p>

Dessin 159 :

```basic
```

<p align="center">────────────────────</p>

Dessin 160 :

```basic
```


<p align="center">────────────────────</p>

Dessin 161 :

```basic
```


<p align="center">────────────────────</p>

Dessin 162 :

```basic
```


<p align="center">────────────────────</p>

Dessin 163 :

```basic
```


___
### 8. Quadrillage classique


Dessin 164 :

```basic
```


<p align="center">────────────────────</p>

Dessin 165 :

```basic
```

<p align="center">────────────────────</p>

Dessin 166 :

```basic
```

<p align="center">────────────────────</p>

Dessin 167 :

```basic
```

<p align="center">────────────────────</p>

Dessin 168 :

```basic
```


<p align="center">────────────────────</p>

Dessin 169 :

```basic
```


<p align="center">────────────────────</p>

Dessin 170 :

```basic
```

<p align="center">────────────────────</p>

Dessin 171 :

```basic
```

<p align="center">────────────────────</p>

Dessin 172 :

```basic
```

<p align="center">────────────────────</p>

Dessin 173 :

```basic
```

<p align="center">────────────────────</p>

Dessin 174 :

```basic
```

<p align="center">────────────────────</p>

Dessin 175 :

```basic
```

<p align="center">────────────────────</p>

Dessin 176 :

```basic
```


___
### 9. Dessiner des surfaces

#### Surfaces

Dessin 177 :

```basic
```

<p align="center">────────────────────</p>

Dessin 178 :

```basic
```

<p align="center">────────────────────</p>

Dessin 179 :

```basic
```

<p align="center">────────────────────</p>

Dessin 180 :

```basic
```


<p align="center">────────────────────</p>

Dessin 181 :

```basic
```


<p align="center">────────────────────</p>

Dessin 182 :

```basic
```


<p align="center">────────────────────</p>

Dessin 183 :

```basic
```


<p align="center">────────────────────</p>

Dessin 184 :

```basic
```

<p align="center">────────────────────</p>

Dessin 185 :

```basic
```

<p align="center">────────────────────</p>

Dessin 186 :

```basic
```

<p align="center">────────────────────</p>

Dessin 187 :

```basic
```

<p align="center">────────────────────</p>

Dessin 188 :

```basic
```

<p align="center">────────────────────</p>

Dessin 189 :

```basic
```

<p align="center">────────────────────</p>

Dessin 190 :

```basic
```

<p align="center">────────────────────</p>

Dessin 191 :

```basic
```

<p align="center">────────────────────</p>

Dessin 192 :

```basic
```

<p align="center">────────────────────</p>

Dessin 193 :

```basic
```


<p align="center">────────────────────</p>

Dessin 194 :

```basic
```


<p align="center">────────────────────</p>

Dessin 195 :

```basic
```

<p align="center">────────────────────</p>

Dessin 196 :

```basic
```

<p align="center">────────────────────</p>

Dessin 197 :

```basic
```

<p align="center">────────────────────</p>

Dessin 198 :

```basic
```

<p align="center">────────────────────</p>

Dessin 199 :

```basic
```

<p align="center">────────────────────</p>

Dessin 200 :

```basic
```


___
### 10. la troisièmes dimension

#### D3 data

Dessin 201 :

```basic
```

<p align="center">────────────────────</p>

Dessin 202 :

```basic
```

<p align="center">────────────────────</p>

Dessin 203 :

```basic
```

<p align="center">────────────────────</p>

Dessin 204 :

```basic
```

<p align="center">────────────────────</p>

Dessin 205 :

```basic
```

<p align="center">────────────────────</p>

Dessin 206 :

```basic
```

<p align="center">────────────────────</p>

#### D3 cube

Dessin 207 :

```basic
```

<p align="center">────────────────────</p>

Dessin 208 :

```basic
```

<p align="center">────────────────────</p>

Dessin 209 :

```basic
```

<p align="center">────────────────────</p>

Dessin 210 :

```basic
```

<p align="center">────────────────────</p>

Dessin 211 :

```basic
```

<p align="center">────────────────────</p>

Dessin 212 :

```basic
```

<p align="center">────────────────────</p>

Dessin 213 :

```basic
```

<p align="center">────────────────────</p>

Dessin 214 :

```basic
```

<p align="center">────────────────────</p>

Dessin 215 :

```basic
```

<p align="center">────────────────────</p>

Dessin 216 :

```basic
```

<p align="center">────────────────────</p>

Dessin 217 :

```basic
```

<p align="center">────────────────────</p>

Dessin 218 :

```basic
```

<p align="center">────────────────────</p>

Dessin 219 :

```basic
```

<p align="center">────────────────────</p>

Dessin 220 :

```basic
```



#### D3 structure

Dessin 221 :

```basic
```

<p align="center">────────────────────</p>

Dessin 221 :

```basic
```

<p align="center">────────────────────</p>

Dessin 222 :

```basic
```

<p align="center">────────────────────</p>

Dessin 223 :

```basic
```

<p align="center">────────────────────</p>

Dessin 224 :

```basic
```

<p align="center">────────────────────</p>

Dessin 225 :

```basic
```

<p align="center">────────────────────</p>

Dessin 226 :

```basic
```

<p align="center">────────────────────</p>

Dessin 227 :

```basic
```

<p align="center">────────────────────</p>

Dessin 228 :

```basic
```

<p align="center">────────────────────</p>

Dessin 229 :

```basic
```

<p align="center">────────────────────</p>

Dessin 230 :

```basic
```

<p align="center">────────────────────</p>

Dessin 231 :

```basic
```

<p align="center">────────────────────</p>

Dessin 232 :

```basic
```

<p align="center">────────────────────</p>

Dessin 234 :

```basic
```

<p align="center">────────────────────</p>

Dessin 235 :

```basic
```

<p align="center">────────────────────</p>

Dessin 236 :

```basic
```

<p align="center">────────────────────</p>

Dessin 237 :

```basic
```

<p align="center">────────────────────</p>

Dessin 238 :

```basic
```

<p align="center">────────────────────</p>

Dessin 239 :

```basic
```

<p align="center">────────────────────</p>

Dessin 240 :

```basic
```

<p align="center">────────────────────</p>

Dessin 241 :

```basic
```

<p align="center">────────────────────</p>

Dessin 242 :

```basic
```

<p align="center">────────────────────</p>

Dessin 243 :

```basic
```

<p align="center">────────────────────</p>

Dessin 244 :

```basic
```

<p align="center">────────────────────</p>

Dessin 245 :

```basic
```

<p align="center">────────────────────</p>

Dessin 246 :

```basic
```

<p align="center">────────────────────</p>

Dessin 247 :

```basic
```

<p align="center">────────────────────</p>

Dessin 248 :

```basic
```

<p align="center">────────────────────</p>

Dessin 249 :

```basic
```

<p align="center">────────────────────</p>

Dessin 250 :

```basic
```

<p align="center">────────────────────</p>

Dessin 251 :

```basic
```

<p align="center">────────────────────</p>

Dessin 252 :

```basic
```


___
## ANNEXE

L'annexe contient quelques exemples pour faire des adaptations sur d'autres ordinateurs.


___
## Bibliographie

À consulter si vous vous intéressez à ce type de dessins.\
Elle est assez exhaustive.



___
