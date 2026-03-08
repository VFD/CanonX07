# Club Canon X-07, issue 12 (198-)(Club Canon)(FR)

___
## Introduction

TO DO



___
## Sommaire

<pre>
EDITORIAL ..........................................  1
LlSTlNG "BOMBER" RELOGEABLE ........................  2
OTHELLO en L.M : COMMENT CA MARCHE (1ère partie) ...  4
DU MATERIEL X-07 INTERESSANT chez J. VAUCELLE  .....  8
APPEL AUX CONNAISSEURS DU X-07  ....................  9
BEST OF "2 LIGNES"  ................................ 10
UN PROGRAMME DE HAUT NIVEAU : BASlC STRUCTURE ...... 14
TOP SECRET  ........................................ 20
CAN'ELL : LA NOUVELLE VERSION ...................... 21
REDIRECTION DES ENTREES SORTIES : UNE APPLICATION .. 24
ESSAI COMPLET DE "MILLE MILLIARDS" ................. 26
LA LISTE DES PROGRAMMES DU CLUB .................... 29
</pre>

___
## Les Listings


<p align="center">────────────────────</p>

### Page 2

Bomber : relogeable

```basic
to do
```

<p align="center">────────────────────</p>

### Page 10

Best of 2 lignes.

```basic
to do
```

```basic
to do
```

```basic
to do
```

```basic
to do
```

```basic
to do
```

```basic
to do
```

<p align="center">────────────────────</p>

### Page 11

Best of 2 lignes.


```basic
to do
```

```basic
to do
```

```basic
to do
```

```basic
to do
```

```basic
to do
```

```basic
to do
```

<p align="center">────────────────────</p>

### Page 12

Best of 2 lignes.


```basic
to do
```


```basic
to do
```


```basic
to do
```


```basic
to do
```


```basic
to do
```


<p align="center">────────────────────</p>

### Page 13

Best of 2 lignes.


```basic
to do
```


```basic
to do
```


<p align="center">────────────────────</p>

### Page 15

Sans doute à externaliser.

```basic
to do
```


<p align="center">────────────────────</p>

### Page 17

Sans doute à externaliser.

```asm
to do
```


<p align="center">────────────────────</p>

### Page 20

CAN'ELL

```basic
to do
```


<p align="center">────────────────────</p>

### Page 20

Redirection Entrée/Sortie.

```basic
10 INIT#1,"CON:"
20 PRINT#1,"Bonjour chez vous"
```

```asm
26EE LD DE,$E7F8
26F1 LO IY,$02C5
26F5 LD A,$00
26F7 CALL $E6A8
26FA LD DE,$02C5
26FD CALL $E827
2700 CALL $2D4F
```

```basic
10 FOR A=1 TO 18: READ A$: POKE &H26ED+A,VAL("&H"+A$): NEXT
20 DATA 11,F8,E7,FD,21,C5,02,3E,00,CD,A8,E6,11,C5,02,CD,27,E8
```


___
