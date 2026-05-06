# 40 Programmes pour Canon X-07

ETSF, Micro Systèmes\
ISBN 2-85535-103-0

Auteurs : Gilles PROBST, André TONIC, Bertrand RAVEL.

___
# Introduction

To DO

Il existe une cassette contenant les programmes.\
Distribuée par D.D.I.

NDR :
- [a] version "alternate" pour lisibilité.
- Version éditeur à faire aussi.
- [X710] indique qu'il faut cette imprimante

___
## Les Listings

Beaucoup souffrent d'erreurs de conception et d'optimisation.\
C'est le cas notament des boucles qui utilisent des variables différentes,
alors qu'il serait possible d'en utiliser pratiquement 1 ou 2.

Il y avait sans doute un choix fait de condenser les programmes au détrimant de la lisibilité.\
Probable version [a2] à faire pour décondenser ceux-ci et effectuer des corrections.

Certains éléments pourraient être utilisés comme sous routines.\
C'est à étudier pour, par exemple, les utiliser dans **X07-Studio**.

<p align="center">────────────────────</p>

### Tableau de suivi

Ci-dessous les tableaux d'avancement de récupération des listings.

| Icon | État |
|------|-------|
|  ✅  | Terminé et fonctionnel |
|  ❌  | Echec |
|  ❕  | À faire |
|  📝  | En cours |

### Travail en cours - Recherche et/ou Saisie

Dans l'ordre du livre.\
44 programmes en tout.

<p align="center">────────────────────</p>

#### Jeux (15)

| Nom              | État | Commentaire |
|------------------|------|-------------|
| Allumettes       | 📝 |  |
| Big Mind         | 📝 |  |
| Chiffres mélangés| 📝 |  |
| Dragoon          | 📝 | Adaptation de Acey Ducey - David H. Ahl |
| Goal             | 📝 |  |
| Graphic brain    | 📝 |  |
| Jeu du pendu     | 📝 | Reprise de Logi'Stick Jeux 1 |
| Jimbo            | 📝 |  |
| Petit poucet     | 📝 |  |
| Phenix           | 📝 |  |
| Sentinelle       | 📝 |  |
| Slot machine     | 📝 |  |
| Super mind       | 📝 |  |
| Tirage de cartes | 📝 |  |
| Tirage de dés    | 📝 |  |


<p align="center">────────────────────</p>

#### Apprentissage (4)

| Nom            | État | Commentaire |
|----------------|------|-------------|
| Dactylographie | 📝 |  |
| Mélodia        | 📝 |  |
| Morse          | 📝 | problème de cohérence sur le morse |
| Signalisation  | 📝 |  |

Bugs :
- Morse : les data doivent correspondre à la chaîne H$
- Signalisation : Ohio ? - Oscar, à réviser


<p align="center">────────────────────</p>

#### Mathématiques (8)

| Nom                   | État | Commentaire |
|-----------------------|------|-------------|
| Calculs sur fractions | 📝 |  |
| Cinématique           | 📝 |  |
| Discriminant          | 📝 | a*x^2 + b*x + c = 0|
| Factorielles          | 📝 | n! |
| Nombres premiers      | 📝 | 1, 3, 5, 7, ... |
| PGCD - PPCM           | 📝 |  |
| Statistiques          | 📝 |  |
| Surfaces diverse      | 📝 | carré, cercle, cylindre, cube, sphère |


<p align="center">────────────────────</p>

#### Vie pratique (10)

| Nom                     | État | Commentaire |
|-------------------------|------|-------------|
| Biorythme               | 📝 |  |
| Canon script            | ❕ |  |
| Compteur téléphonique   | 📝 |  |
| Conversion acre-hectare | 📝 |  |
| Conversion arabe-romain | 📝 |  |
| Conversion de capacités | ❕ |  |
| Conversion de forces    | 📝 |  |
| Conversion de longueurs | 📝 |  |
| Conversion de poids     | 📝 |  |
| Dates                   | ❕ |  |

<p align="center">────────────────────</p>

**BONUS**

<br />
Ajustement 2026 des capacités.

| Option | De | Vers | Formule |
|--------|-----|------|---------|
| 1 | Litres | Gallons GB | Gallons GB = Litres × 0.219969 |
| 1 | Gallons GB | Litres | Litres = Gallons GB × 4.54609 |
| 2 | Litres | Gallons US | Gallons US = Litres × 0.264172 |
| 2 | Gallons US | Litres | Litres = Gallons US × 3.78541 |
| 3 | Litres | Pints GB | Pints GB = Litres × 1.75975 |
| 3 | Pints GB | Litres | Litres = Pints GB × 0.568261 |
| 4 | Litres | Pints US | Pints US = Litres × 2.11338 |
| 4 | Pints US | Litres | Litres = Pints US × 0.473176 |
| 5 | Litres | Quarts GB | Quarts GB = Litres × 0.879875 |
| 5 | Quarts GB | Litres | Litres = Quarts GB × 1.13652 |
| 6 | Litres | Quarts US | Quarts US = Litres × 1.05669 |
| 6 | Quarts US | Litres | Litres = Quarts US × 0.946353 |

<br /><br />
Ajustement 2026 des distances.

| Option | De | Vers | Formule |
|--------|-----|------|---------|
| 1 | Mètres | Pieds | Pieds = Mètres × 3.2808399 |
| 1 | Pieds | Mètres | Mètres = pieds × 0.3048 |
| 2 | Mètres | Pouces | Pouces = Mètres × 39.3701 |
| 2 | Pouces | Mètres | Mètres = Pouces × 0.0254 |
| 3 | Kilomètres | Miles | Miles = Km × 0.621371 |
| 3 | Miles | Kilomètres | Km = Miles × 1.60934 |
| 4 | Kilomètres | Miles nautiques | Mn = Km × 0.5399568 |
| 4 | Miles nautiques | Kilomètres | Km = Mn × 1.852 |
| 5 | Mètres | Yards | Yards = Mètres × 1.0936132 |
| 5 | Yards | Mètres | Mètres = Yards × 0.9144 |

<br />

<p align="center">────────────────────</p>

#### Graphisme (7)

| Nom               | État | Commentaire |
|-------------------|------|-------------|
| Canon LOGO        | 📝 | Pseudo langage LOGO sur X-710 |
| Cercles colorés   | 📝 | X-710 |
| Cycloîdes         | 📝 | X-710 |
| Ellipses          | 📝 | X-710 |
| Graphismes divers | ❕ | LCD |
| Inversion vidéo   | 📝 | LCD |
| Télécran          | 📝 | LCD |

NDR :
- Prendre plutôt la version assembleur du Club C7pour l'inversion vidéo.

___
