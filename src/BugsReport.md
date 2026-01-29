# Rapport de BUG sur le X-07


___
### Introduction

Report ici des bug trouvé sur le canon X-07 au fil des lectures.


___
## Liste des bugs


### Appuye sur les touches

Appuis simultané. Combo à éviter dans les programmes.\
Apparement dépend des versions de X-07.\


| Touche | Touche    | Résultat   | Commentaire |
|--------|-----------|------------|-------------|
| Espace | Haut      | Extinction |  |
| Ctrl   | S-G       | Extinction |  |
| Ctrl   | X-B       | Extinction |  |
| Graph  | Haut      | Extinction |  |
| Graph  | Droite    | Extinction |  |
| Num    | Curseur H | Extinction |  |
| Num    | Curseur G | Extinction |  |

Autres subtilités avec CTRL Q-W; CTRL A-S; CTRL Z-X.

Tester sur les machines et prendre note.

Voir Club Canon no 3; Problème lié à la matrice de gestion du clavier.

### Boucle infinie

Cf. Club Canon no 3.

```basic
1 DEFSNGA:FORA=999992760TO999992766:PRINTA;:NEXTA
```

```basic
1 DEFSNGA:FORA=32760TO32767:PRINTA;:NEXTA
```

Tester sur les machines et prendre note.

### élévation à la puissance

```basic
2 PRINT 2^31 : GOTO 2
```

### sur fonctions LOG et EXP

```basic
PRINT LOG(EXP(1))
```


___
