# Les variantes de la X-710 et les commandes

___
## Introduction

Le but ici est de donner un tableau des imprimantes équivalante à la X-710.\
En effet il s'agit d'imprimante issue de ALPS en marque blanche.

La mécanique et le fonctionnement est le même.\
La différences peut être dans les mots clés pour faire les tracés et surtout l'initialisation.

Il y aurait une ROM interne.\
Un dump serait bienvenu.

### Problème de batteires

Voir https://oldskool.silicium.org/calc/x07/bidx710.htm

___
## Tableau

| Nom     | Marque | Année | Commentaire |
|---------|--------|-------|-------------|
| X-710   | Canon  | 1983  |             |
| FP-1000 | Casio  |       |             |

Tandy, commodore, ...

Liste à vérifier.

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

### Mode GRAPHIQUE

LPRINT CHR$(18)

| Commande | Action | Paramètre |
|----------|--------|-----------|
| L        |        |
| A        |        |
| H        |        |
| I        |        |
| D        |        |
| J        |        |
| M        |        |
| R        |        |
| C        |        |
| S        |        |
| Q        |        |
| P        |        |
| F        |        |

TO DO






___
