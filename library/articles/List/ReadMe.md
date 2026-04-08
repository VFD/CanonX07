# List

TO DO

___
## Introduction





___
## Les Tests de LIST

Nous n'avons pas les résultats ppour le X07.\
Il serait possible de le faire, cepandant il faudrait modifier les programmes pour utiliser le TIME du X07.\
Ci-après les boucles de tests.

<p align="center">────────────────────</p>


### Test 1 - Boucle vide

```basic
10 FOR I = 1 TO 10000
20 NEXT I
30 END
```

<p align="center">────────────────────</p>

### Test 2 - Sous-programmes

```basic
10 FOR I = 1 TO 10000
15 GOSUB 100
20 NEXT l
30 END
100 GOSUB 110
110 RETURN
```

<p align="center">────────────────────</p>

### Test 3 - Matrice

```basic
5 DIM A(J0,10)
10 FOR I = 1 TO 10
12 FOR J = 1 TO 10
13 FOR K = 1 TO 100
15 A(I,J) = K
17 NEXT K
18 NEXT J
20 NEXT I
30 END
```

<p align="center">────────────────────</p>

### Test 4 - Opérations sur les chaînes de caractères

```basic
5 A$ = " LISTEST "
10 FOR I=1 TO 10000
15 B$ = LEFT$(A$,2) + MID$(A$,3,3) + RIGHT$(A$,2)
20 NEXT I
30 END
```

<p align="center">────────────────────</p>

### Test 5 - Arithmétique

```basic
JO FOR I=1 TO 10000
15 J = I*7 + 3/I
20 NEXT I
30 END
```

<p align="center">────────────────────</p>

### Test 6 - Calcul scientifique

```basic
10 FOR I=1 TO 10000
15 J = SIN (LOG(I))
20 NEXT I
30 END
```

<p align="center">────────────────────</p>

### Test 7 - Affichage

```basic
10 FOR I=1 TO 10000
15 PRINT CHR$(11);" LISTEST ";I
20 NEXT I
30 END
```

<p align="center">────────────────────</p>

### Test 8 - Tracé d'une ligne graphique

```basic
10 FOR I=1 TO 10000
15 LINE(0,0)-(319,199)
20 NEXT I
30 END
```

<p align="center">────────────────────</p>

### Test 9 - Ecriture de fichiers

```basic
5 A$ = " LISTEST "
6 OPEN "O",#1,"FICHIER"
10 FOR I=1 TO 10000
15 PRINT#1,A$
20 NEXT I
25 CLOSE
30 END
```

<p align="center">────────────────────</p>

### Test 10 - Lecture de fichiers

```basic
6 OPEN "I",#1,"FICHIER"
JO FOR I=1 TO 10000
15 INPUT#1,A$
20 NEXT I
25 CLOSE
30 END
```


___
___
