Voici quelques détails sur les abréviations du précédent tableau :

- BELL : sonnerie.
- BS : BACK SPACE.
- LF : LINE FEED (Déroulement d'une ligne).
- LU : LINE UP (Retour en arrière d'une ligne).
- DC1 : DEVICE CONTROL 1 (Passage Texte/Graphique sur la X-710).
- DC2 : DEVICE CONTROL 2 (Passage Graphique/Texte sur la X-710).
- S1 : SHIFT IN (Utilisation de caractères pour la X-710 provenant d'une ROM EXTERNE).
- SO : SHIFT ON (Utilisation de caractères pour la X-710 provenant de la ROM INTERNE).
- F.M : Fonction mathématique.

## 8.2 Les POINTS D'ENTREE en MÉMOIRE MORTE.

Nous ne vous apprendrons pas que le BASIC MICROSOFT du CANON X-07 est très puissant. Comme la puissance se paie, il a fallu 20 Kilo-octets de mémoire morte (appelé aussi ROM comme Read Only Memory ou MEM) pour le stocker complètement.

L'interpréteur BASIC se trouve entre les adresses B000h et FFFFh, c'est-à-dire complètement en haut de la mémoire étant donné que l'adresse FFFFh représente la dernière adresse disponible.

Nous allons vous donner tous les points d'entrée en MEM des fonctions BASIC du X-07. Avec ces adresses, vous pourrez fouiller la mémoire et récupérer toutes les routines utilisées par les fonctions BASIC (Voir figure 28).

Mais si vous ne désirez pas fouiller la mémoire à grands coups de PEEK, reportez-vous au chapitre 9 ...

## 8.3 La ZONE de TRAVAIL du SYSTEME.

Appelé abusivement "zone système", la zone de travail du système est constituée d'une zone de mémoire vive utilisée par le BASIC afin de faire des appels au système.

En ce qui concerne le CANON X-07, la zone système occupe quelques 1363 octets de l'adresse 0000 à l'adresse 1362 en décimal (0 à 552 en hexadécimal).

|  MOTS CLES | CODES | ENTREE | MOTS CLES | CODES | ENTREE  |
| --- | --- | --- | --- | --- | --- |
|  ABS | E1 | C9DC | LET | 87 | F685  |
|  ALMS | C7 | D928 | LINE | 97 | F7C6  |
|  AND | D6 | FC68 | LIST | A1 | FE75  |
|  ASC | F5 | D81A | LLIST | A2 | FE6B  |
|  ATN | EB | B5AC | LOAD | B2 | DF38  |
|  BEEP | B6 | C2CD | LOCATE | A9 | E212  |
|  CDBL | EF | CB90 | LOG | E6 | B609  |
|  CHRS | F6 | D828 | LOCATE | A9 | E212  |
|  CINT | ED | CAE0 | LOG | E6 | B609  |
|  CIRCLE | A4 | 009C | LPRINT | 9C | E9DE  |
|  CLEAR | A3 | D1D0 | MIDS | FA | DC93  |
|  CLOAD | B7 | DF30 | MOTOR | 92 | EBB9  |
|  CLS | A6 | CE9E | NEW | B9 | D214  |
|  COLOR | A7 | 008A | NEXT | 82 | D30C  |
|  CONSOLE | A5 | E243 | NOT | CF | FC1A  |
|  CONT | A0 | D178 | OFF | AC | C5B1  |
|  CUS | E8 | B530 | ON | 9B | F6F1  |
|  CSAVE | B8 | DEF9 | OUT | 9A | E98C  |
|  CSNG | EE | CB08 | PAINT | B1 | 0099  |
|  CSRLIN | FB | CEAF | PEEK | EC | FC7A  |
|  DATA | 83 | F66A | POINT | FE | 0093  |
|  DATE$ | C8 | D8CE | POKE | 9E | FC80  |
|  DEFDBL | 96 | F557 | POS | E3 | FC8C  |
|  DEFFN | 9D | FC96 | PRESET | AB | 0090  |
|  DEFINT | 94 | F551 | PRINT | 9F | EA05  |
|  DEFSNG | 95 | F554 | PSET | AA | 008D  |
|  DEFSTR | 93 | F54E | READ | 86 | F86B  |
|  DELETE | AF | E682 | REM | 8E | F666  |
|  DIM | 85 | B005 | RESTORE | 8B | D296  |
|  DIR | AE | E5E3 | RESUME | 99 | F734  |
|  ELSE | 90 | F666 | RETURN | 8D | F63D  |
|  END | 80 | D2B0 | RIGHTS | F9 | DC8A  |
|  EUV | D9 | FC72 | RND | E5 | B771  |
|  ERASE | B5 | E3CF | RUN | 89 | F5B7  |
|  ERL | BE | FAC4 | SAVE | B3 | DEFE  |
|  ERR | BF | FAB6 | SCREEN | CD | 0087  |
|  ERROR | 98 | F78C | SGN | DF | C9F1  |
|  EXEC | A8 | CEB8 | SIN | E9 | B549  |
|  EXP | E7 | B6DD | SLEEP | AD | C59B  |
|  FIX | F0 | CC14 | SNS | C6 | E961  |
|  FN | BC | FCB5 | SQR | E4 | B694  |
|  FONT$ | CB | D739 | START$ | CA | DA99  |
|  FOR | 81 | F3F7 | STEP | D0 | F537  |
|  FRE | E2 | DDD7 | STICK | FC | D7E3  |
|  FSET | B0 | BF56 | STOP | 8F | D2CD  |
|  GOSUB | 8C | F610 | STRS | F3 | D53D  |
|  GOTO | 88 | F621 | STRIG | FD | D7F8  |
|  HEX$ | F2 | D538 | STRUNGS | CD | D835  |
|  IF | 8A | F797 | TAN | EA | B593  |
|  INIT | B4 | E699 | TIMES | C9 | D868  |
|  INKEY$ | C2 | C103 | TKEY | F7 | D7CC  |
|  INP | C3 | E931 | TR | 91 | D1B7  |
|  INPUT | 84 | F82F | USR | C5 | E9BB  |
|  INSTR | C1 | DCD6 | VAL | F4 | DCB3  |
|  INT | E0 | CC23 | VARPTR | C4 | E9A7  |
|  KEY$ | CC | DA39 |  |  |   |
|  LEFT$ | F8 | DC5A |  |  |   |
|  LEN | F1 | D72D |  |  |   |

FIGURE 14 : POINTS D'ENTREE en MEM.