# Son du Canon - Club C7 - Numéro 1



___
## Introduction

TO DO

___
## Les Listings

- Chargeur LM
- Dactylofolie (A-B à vérifier)
- Generateur aleatoire (1984-11)(Club C7)(FR).bas
- Geometrie (1984-11)(Club C7)(FR).bas
- Loto (1984-11)(Club C7)(FR).bas
- Magic Circus (1984-11)(Club C7)(FR).bas
- Telecran (1984-11)(Club C7)(FR).bas


#### page 20

Programme très court, repris ici.\
Des espaces sont ajoutés pour la lisibilité du code.

Programme 1 :

```basic
10 DEFINT A-Z: S=1: N=242
20 FOR I=1 TO 48
30 BEEP 1,S
40 NEXT
50 BEEP 1,0
60 OUT 243,0
70 OUT 244,78
80 FOR L=255 TO 0 STEP-1
90 OUT N,L
100 NEXT
```

```basic
10 DEFINT A-Z: N=242
20 OUT 243,0: OUT 244,0
30 FOR L=0 TO 255
40 OUT N,L: OUT N,255-L
50 NEXT
```


___