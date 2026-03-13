# Dessins géométriques (1985)(Eyrolle, Delahaye)(FR)


## Introduction

To do


___
## Les Listings

Tous les listings du livre sont ci-dessous.\
Ils sont complet contrairement au livre qui ne donne que les modifications à faire.

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

#### Composition 1

Dessin 13 :

```basic
10 'COMPOSITION 1
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K1=5: DX=NP/2: DY=NP/2: R1=NP*.27: A1=PI/2
110 K=25: H=12: R=NP*.22: AD=PI/2
200 FOR I1=0 TO K1-1
210 CX=DX+R1*COS(2*PII1/K1+A1)
220 CY=DY+R1*SIN(2*PII1/K1+A1)
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


Dessin 14 :

```basic
10 'COMPOSITION 1
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K1=6: DX=NP/2: DY=NP/2: R1=NP*.2: A1=0
110 K=24: H=11: R=NP*.3: AD=0
200 FOR I1=0 TO K1-1
210 CX=DX+R1*COS(2*PII1/K1+A1)
220 CY=DY+R1*SIN(2*PII1/K1+A1)
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


Dessin 15 :

```basic
10 'COMPOSITION 1
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K1=40: DX=NP/2: DY=NP/2: R1=NP*.25: A1=PI/2
110 K=80: H=1: R=NP*.25: AD=PI/2
200 FOR I1=0 TO K1-1
210 CX=DX+R1*COS(2*PII1/K1+A1)
220 CY=DY+R1*SIN(2*PII1/K1+A1)
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


Dessin 16 :

```basic
10 'COMPOSITION 1
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K1=10: DX=NP/2: DY=NP/2: R1=NP*.35: REM A1=PI/2
110 K=10: H=3: R=NP*.15: AD=0
200 FOR I1=0 TO K1-1
210 CX=DX+R1*COS(2*PII1/K1+A1)
220 CY=DY+R1*SIN(2*PII1/K1+A1)
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

NDR : PB ligne 100, A1 absent dans le livre.



Dessin 17 :

```basic
10 'COMPOSITION 1
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K1=63: DX=NP/2: DY=NP/2: R1=NP*.15: A1=0
110 K=4: H=1: R=NP*.35: AD=0
200 FOR I1=0 TO K1-1
210 CX=DX+R1*COS(2*PII1/K1+A1)
220 CY=DY+R1*SIN(2*PII1/K1+A1)
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


Dessin 18 :

```basic
10 'COMPOSITION 1
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K1=25: DX=NP/2: DY=NP/2: R1=NP*.1: A1=PI/2
110 K=5: H=2: R=NP*.4: AD=PI/2
200 FOR I1=0 TO K1-1
210 CX=DX+R1*COS(2*PII1/K1+A1)
220 CY=DY+R1*SIN(2*PII1/K1+A1)
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


Dessin 19 :

```basic
10 'COMPOSITION 1
50 LPRINT CHR$(18): LPRINT"M0,-500": LPRINT"I": NP=480: PI=ATN(1)*4
100 K1=99: DX=NP/2: DY=NP/2: R1=NP*.25: A1=0
110 K=7: H=3: R=NP*.25: AD=PI/2
200 FOR I1=0 TO K1-1
210 CX=DX+R1*COS(2*PII1/K1+A1)
220 CY=DY+R1*SIN(2*PII1/K1+A1)
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

#### Composition 2

```basic
```


___
### 2. Dessins à partir de données

#### Cheval

```basic
```


#### Lion, oiseaux-poissons, smurf

```basic
```

___
### 3. Dragons de papiers pliés

#### Dragons

```basic
```

___
### 4. Étoiles fractales

#### Étoiles fractales


```basic
```


___
#### 5. Courbes

#### Courbes orbitales


```basic
```


#### Courbes tournantes


```basic
```


#### Courbes spirales


```basic
```


___
### 6. Dessins linéaires

#### Biparti complet


```basic
```


#### Linéaires modulo


```basic
```


#### linéaires batons


```basic
```


___
### 7. Fractales simples

#### Fractales simples 


```basic
```


#### Fractales simples arrondies


```basic
```


#### Fractales simples déformées


```basic
```


___
### 8. Quadrillage classique


```basic
```


___
### 9. Dessiner des surfaces

#### Surfaces


```basic
```


___
### 10. la troisièmes dimension

#### D3 data


```basic
```


#### D3 cube


```basic
```


#### D3 structure


```basic
```



EOF
___