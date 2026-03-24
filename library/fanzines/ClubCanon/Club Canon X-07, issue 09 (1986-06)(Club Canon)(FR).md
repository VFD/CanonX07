# Club Canon X-07, issue 09 (1986-06)(Club Canon)(FR)

___
## Introduction

Certaines pages sont manuscrites (2 et 3).

Semble complet.

Il faudrait refaire les pages manuscrites.

___
## Sommaire

<pre>
Editorial .....................................  1
Premiers mots FORTH ...........................  2
Nouvelles fraiches ............................  3
Essai interface X-740 / X-07 COM ..............  4
Communication X-07 / IBM et compatibles .......  8
Petites annonces .............................. 10
Programmation de la ligne de calcul ........... 11
Petites annonces (suite) ...................... 13
Liste de la "ligne de calcul" Calorimétrie .... 14
</pre>


NDR : La page contient un errata de "Calorimétrie"

__
## Les listings


### page 09

Programme de transfert X-07 --> GRID via RS232

```basic
to do
```

<p align="center">────────────────────</p>

### Page 12

Figure 2 :

```basic
10010 Z=4
10014 P=1
10020 NF=2
10032 SY$="HGTV"
```

Figure 3 :

```basic
7050 H=T(0):G=T(1):T=T(2):V=T(3)
7130 ON L GOSUB 8010,8020,8030,80,40
7135 IF L<5 THEN 7500 ELSE L=L-4
7140 ON L GOSUB 8050,8060,8070,8080
```

<p align="center">────────────────────</p>

### Page 13

```basic
8010 T(O)=0.5*G*T^2: RETURN
8020 T(O)=V*2/(2*G): RETURN
8030 T(1)=(2*H)/T^2: RETURN
8040 T(1)=V/T: RETURN
8050 T(2)=SQR(2*H/G): RETURN
8060 T(2)=V/G: RETURN
8070 T(3)=G*T: RETURN
8080 T(3)=SQR(2*G*H): RETURN
```

```basic
10036 DATA 6, 10, 5, 12, 3, 10, 6, 3
```

<p align="center">────────────────────</p>

### Page 14

Calorimétrie

Version corrigée.

```basic
to do
```


___
