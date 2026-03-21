# Les variantes de la X-710 et les commandes

___
## Introduction

Le but ici est de donner un tableau des imprimantes équivalante à la X-710.\
En effet il s'agit d'imprimante issue de ALPS en marque blanche.

La mécanique et le fonctionnement est le même.\
La différences peut être dans les mots clés pour faire les tracés et surtout l'initialisation.\
En croisant les notices il est possible de découvrire des fonctions cachées.

Il y aurait une ROM interne.\
Un dump serait bienvenu si c'est le cas.

Autre projet, un emulateur de ce type d'imprimante.

___
## /!\ Problème de batteires /!\

Il est impératif d'enlever la batterie de votre imprimante X-710.\
De toute manière elle est KO.

Voir https://oldskool.silicium.org/calc/x07/bidx710.htm

Il semblerait que ce ne soit pas efficace.\
Autre solution à trouver.

___
## Tableaux des notices

Modèles dont nous avons la notice.

| Nom       | Marque | Année | Commentaire |
|-----------|--------|-------|-------------|
| X-710     | Canon  | 1983  |             |
| FP-1011PL | Casio  |       |             |


Liste à vérifier/trouver.

| Modèle                  | Marque          |
|-------------------------|-----------------|
| DPG-1302 (mécanisme)    | ALPS            |
| 1020                    | Atari           |
| CGP-115                 | Tandy / Radio Shack |
| 4-COLOR PRINTER / MCP-40| Mattel Aquarius |
| HX-1000                 | Texas Instruments |
| 1520                    | Commodore       |
| FA-10                   | Casio           |
| FA-11                   | Casio           |
| CE-1600P                | Sharp           |
| MZ-1P01                 | Sharp           |
| MZ-1P16                 | Sharp           |
| PC-2500 Printer         | Sharp           |
| PL-10                   | Olivetti        |
| SP-400                  | Sega            |
| EB-50                   | Silver Reed     |
| Laser PP-40I            | VTech           |
| Microprinter WP-100     | Convergent      |
| MCP-40X                 | Astron          |

Quand on les trouve, les notices sont jointes dans ce répertoire.

___
## Commandes

L'idée est de donner un résumé efficace des commandes pour ce type de traceur.\
Attention, ici pour la Canon X-710.

TO DO.

Tous passe par LPRINT. 

<p align="center">────────────────────</p>

### Mode TEXTE

Valeur décimale.

| Commande | Action |
|----------|---------|
| CHR$(8)  | 1 caractère vers la gauche |
| CHR$(10) | Passe à la ligne |
| CHR$(11) | Ligne précédente |
| CHR$(13) | Revient tout à gauche |

Taille et couleur des caractères :

LPRINT [I,J],"Hello World!"

I : Taille du caractère [1,16]\
J : Couleur [0:noir, 1:bleu, 2:vert, 3:rouge] - sauf si vous avez mis les stylots ailleurs.

Par défaut : 2,0

<p align="center">────────────────────</p>

### Mode GRAPHIQUE

LPRINT CHR$(18)

| Commande | Action | Paramètre |
|----------|--------|-----------|
| L        |        | |
| A        |        | |
| H        |        | |
| I        |        | |
| D        |        | |
| J        |        | |
| M        |        | |
| R        |        | |
| C        |        | |
| S        |        | |
| Q        |        | |
| P        |        | |
| F        |        | |

TO DO






___
