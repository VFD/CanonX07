# Le Son du Canon, issue 05 (1985-09)(Club C7)(FR)

___
## Introduction

Ce markdown à pour but de compiler les petits codes source de ce numéro.



___
### Sommaire

- EDITORIAL .................................. PAGE  1
- LA LETTRE DE CANON ......................... PAGE  3
- LES BO ADRESSES ............................ PAGE  4
- LE COURRIER DES LECTEURS ................... PAGE  6
- UTILITAIRE "REFBAS" ........................ PAGE  8
- UTILITAIRE "EXABAS" ........................ PAGE 11
- ESSAI DE FORTH (LOGl'STICK) ................ PAGE 14
- STAGE "ASSEMBLEUR II" ...................... PAGE 16
- INSTRUCTION GRAPHIQUE "BOX" ................ PAGE 18
- DOSSIERS TOUS AZIMUTS ...................... PAGE 21
- UTILITAIRES "LMDATA" ET "RESTORE" .......... PAGE 22
- PETITES ANNONCES ........................... PAGE 26
- LA DERNIERE BOMBE DE POWER SOFT ............ PAGE 27
- LA PROGRAMMATHEQUE DU CLUB C7 .............. PAGE 30
- TRAITEMENT DE TEXTES ....................... PAGE 34
- COOPERATIVE DU CLUB C7 ..................... PAGE 40
- VOTRE AVIS VAUT DE L'OR .................... PAGE 41
- C7 ANNONCE ................................. PAGE 42


___
## Les listings


### page 10 - REFBAS


Version 8Ko.

Le Chargeur

```basic

```

Le Master

```basic

```

Les Datas

```

```


Version 16Ko.


Le Chargeur

```basic

```

Le Master

```basic

```

Les Datas

```

```

### page 10 - EXABAS


Version 8Ko.

Le Chargeur

```basic

```

Le Master

```basic

```

Les Datas

```

```


Version 16Ko.


Le Chargeur

```basic

```

Le Master

```basic

```

Les Datas

```

```


### page 19 - BOX (A. TONIC)


Programme Basic :

```basic
10 '*** BOX *** (C) A.TONIC ***
20 RESTORE 70: FOR I=6000 TO 6224: READ A$: POKE I,VAL("&H"+A$): NEXT: EXEC 6000
30 '*** EXEMPLE D'EXECUTION ***
40 CLS: J=18: FOR I=58 TO 0 STEP -4: J=J-1: PAINT(I,J),(119-I,31-J): NEXT
50 IF INKEY$="" THEN 50 ELSE END
70 DATA 21,77,17,22,9A,0,C9,DD,E5,DD,2A,53,18,CF,28,CD,5E,FE,CD,22,18,DD,77,1,CF
80 DATA 2C,CD,5E,FE,CD,2A,18,DD,77,2,CF,29,CF,2C,CF,28,CD,5E,FE,CD,22,18,DD,77,3
90 DATA CF,2C,CD,5E,FE,CD,2A,18,DD,77,4,CF,29,C5,D5,CD,32,18,DD,5E,1,CD,3D,18,DD
92 DATA 5E,2,CD,3D,18,DD,5E,1,CD,3D,18,DD,5E,4,CD,3D,18,CD,32,18,DD,5E,1,CD,3D
93 DATA 18,DD,5E,4,CD,3D,18,DD,5E,3,CD,3D,18,DD,5E,4,CD,3D,18,CD,32,18,DD,5E,3
94 DATA CD,3D,18,DD,5E,4,CD,3D,18,DD,5E,3,CD,3D,18,DD,5E,2,CD,3D,18,CD,32,18,DD
95 DATA 5E,3,CD,3D,18,DD,5E,2,CD,3D,18,DD,5E,1,CD,3D,18,DD,5E,2,CD,3D,18,D1,C1
96 DATA DD,E1,C9,F5,FE,78,D2,38,18,F1,C9,F5,FE,20,D2,38,18,F1,C9,1E,14,CD,3D,18
97 DATA C9,1E,5,C3,C7,F1,C5,E,F1,CD,C0,C9,3A,6C,2,F6,80,D3,F0,ED,59,3E,2,D3,F5
98 DATA C1,C9
```


Programme LM :

```basic

```

### page 23 - Graphisme et Love

Ne serait pas présent sur la K7 du club.


Programme Graphisme :

```basic

```

Programme LOVE :

```basic

```


___
