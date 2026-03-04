# Production Club C7, Neptune, LOGI'STICK

___
## Introduction

Club C7, Neptune, LOGI'STICK, c'est quasiment la même chose.\
En gros les même personnes derrière.

- Neptune : Maison d'édition
- LOGI'STICK : édition de logiciels
- Club C7 : Association, gazette "Le Son du Canon"


Le Nom des fichiers dans les tableaux est en principe le nom du programme codé lors de sa sauvegarde.\
Les programmes sont dans l'ordre d'apparition de la cassette.\
Ceci afin de pouvoir restaurer si nécessaire des cassettes identiques à ce qui a été fait.\

Le nom du fichier final utilise la nomenclature [TOSEC](https://www.tosecdev.org/tosec-naming-convention).

### Source : Silicium

- 14 cassettes connues minimum
- Autres K7 inconnues listé aussi

il y a aussi du Pocket Soft.

### Tableau de suivi

| Icon | État |
|------|-------|
|  ✅  | BAS, CAS, WAV sont disponibles |
|  ❌  | Echec, pb code source ou autre |
|  ❕  | À trouver |
|  📝  | En cours de récupération |

NDR : nous recherchons tous les sources possibles.

NDR : Soucis dans les codes sources.\
Ils sont en ANSI et il faut les convertir UTF-8.\
Sauf que certain caractères sont problématiques :

- à -> |
- ù -> @
- ° -> [
- § -> ]

Après conversion UTF8, faire les changements.\
Refaire ensuite le CAS et éventuellement le WAV.

Ressources :

- [Silicium](https://oldskool.silicium.org/calc/x07/index.htm)
- [Marcus von Cube](https://www.mvcsys.de/doc/basic-compare.html)


___
## Les Programmes des cassettes Silicium

Reprise du fichier info.txt et mise en tableau.\
Dispatch final quand complet.

___
### Neptune

à faire.

___
### LOGI'STICK

Production de plusieurs logiciels.

<p align="center">────────────────────</p>

#### *** TEXTE ***

| Nom     | Face | Status | Fichier | Commentaire |
|---------|------|--------|---------|-------------|
| TOUCHE  | A    |        |         |             |
| TEXTE   | A    |        |         |             |
| V-TEXTE | A    |        |         |             |
| TOUCHE  | B    |        |         |             |
| V-TEXTE | B    |        |         |             | 
| TEXTE   | B    |        |         |             |

#### *** FONCTIONS - MATRICES ***

| Nom     | Face | Status | Fichier | Commentaire |
|---------|------|--------|---------|-------------|


#### *** AGENDA ***

Nécessite 8 Ko.

| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|
| AGENDA | A    |        | ❌     | pb illisible |
| AGENDA | A    |        | ❌     | pb illisible |
| AGENDA | B    |        | ❌     | pb illisible |
| AGENDA | B    |        | ❌     | pb illisible |

NDR :\
Le code transféré "foire" car il s'agit d'une ligne REM contenant le code assembleur.\
Il faut reloader depuis un X-07 puis envois via liaison série.

#### *** CALC ***

| Nom     | Face | Status | Fichier | Commentaire |
|---------|------|--------|---------|-------------|
| CALC    | ?    |        |         |             |

NDR : check dernière ligne erronée.


#### *** GRAPHE ***

| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|
| GRAF1  | A    |        |         |             |
| GRAF2  | A    |        |         |    |
| (LM ?) | A    |        |         |    |
| GRAF2  | B    |        |         |    |
| GRAF1  | B    |        |         |    |

#### *** FICHIER ***

| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|
| LFICHE | A    |        |         |             |
| VFICHE | A    |        |         |    |
| VFICHE | B    |        |         |    |
| LFICHE | B    |        |         |    |

Cassette de couleur orange et fichier au singulier.

#### *** FICHIERS ***

| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|
| FICHES | ?    |        |         |             |

Cassette grise, et fichier au pluriel.

#### *** DIETETIQUE ***

| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|


#### *** ASSEMBLEUR-DESASSEMBLEUR ***

| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|


#### *** AIDE BASIC ***

| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|

#### *** BANQUE ***

| Nom     | Face | Status | Fichier | Commentaire |
|---------|------|--------|---------|-------------|
| L-BANK  |      |        |         |             |
| V-BANK  |      |        |         |             |



#### *** ASTRO ***

Nécessite 24 Ko.

| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|
| ASTRO  | B    |        |         ||



#### *** JEUX 1 ***

| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|
| MEMORY | A, B |        |         |             |
| JACK   | A, B |        |         |    |
| MASTER | A, B |        |         |    |
| HANOI  | A, B |        |         |    |
| POKER  | A, B |        |         |    |
| BABY   | A, B |        |         |    |
| PENDU  | A, B |        |         |    |
| KOALA  | A, B |        |         |    |
| T-T-T  | A, B |        |         |    |
| HARPE  | A, B |        |         |    |

NDR : Face A et B identique.


#### *** JEUX 2 ***

| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|
| CARPAC | A    |        |         | (LM) defini les caracteres puis attends le suivant "cload" executé automatiquement ! |
| CAPMAN | A    |        |         | 2 eme partie pacman |
| SNAKE1 | A    |        |         | Anaconda |
| SNAKE2 | A    |        |         | Anaconda X-720 |
| SNAKE1 | B    |        |         | Anaconda |
| SNAKE2 | B    |        |         | Anaconda X-720 |
| CARPAC | B    |        |         | (LM) sert à lancer CAPMAN ! |
| CAPMAN | B    |        |         | 2 eme partie pacman |


#### *** ALPHATRUC ***

| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|



___
### Le Son du Canon, les cassettes

Les LM sont chargés en principe via un programme loader qui lit les octets.\
Il faudrait les fichiers sources WAV pour combler les manques.

NDR :
- Il faut confirmer ces cassettes.
- Entre parenthèses le no de la cassette du info de silicium


#### SON DU CANON NO 1 (K7-2)

| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|
| PROG A | A    |        |         | Dactylo Folie - X-721 optocoupleur |
| PROG B | A    |        |         | Dactylo Folie - X-721 optocoupleur |
| CIRCUS | A    |        |         | |
| GEO    | A    |        |         | |
| TELE   | A    |        |         | telecran |
| LOTO   | A    |        |         | |
| ALEA   | A    |        |         | |

NDR :
- La face B est vierge, cf. p42.
- Dactylo Folie se joue avec 2 X07 et le X-721.

### Le Son du CANON n°2 (K7 ?)

TO DO.

Autoprogrammation p17-19


### Le Son du CANON n°9 (K7 ?)

| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|
| RAYONZ | A    |        |         | jeu |
| TELTAX | A    |        |         | calcul taxes téléphoniques |
| ETI    | A    |        |         | création d'étiquettes |
| GAMES2 | A    |        |         | jeux olympiques II |
| MINITE | A    |        |         | Liaison Minitel |
| RAYONZ | B    |        |         | jeu |




#### K7-1

| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|
| REF16B | A?   |        | ❌❕   | + codes speciaux asm ! |
| EXA16B | A?   |        | ❌❕   | + codes speciaux asm ! |
| PIEGEL | A?   |        | ❌❕   | + codes speciaux asm ! |
| PIEGVI | A?   |        | ❌❕   | + codes speciaux asm ! |
| OTH-RE | A?   |        | ❌❕   | + codes speciaux asm ! |
| LMDATA | B?   |        |         | |
| CANON  | B?   |        |         | |
| RESTOR | B?   |        |         | |
| COPIE  | B?   |        |         | |
| LLISTB | B?   |        | ❌❕   | + codes speciaux asm ! |
| LOGOGE | B?   |        |         | |
| LABYR  | B?   |        | ❌❕   | + codes speciaux asm ! |
| PENTO  | B?   |        | ❌❕   | + codes speciaux asm ! |
| SOLIT  | B?   |        | ❌❕   | + codes speciaux asm ! |
| AUTNUM | B?   |        |         | |



#### K7-3 (4/5)


| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|
| PENTA  | ?    |        |         | + codes speciaux asm ! |
| SOL    | ?    |        |         | + codes speciaux asm ! |
| BREAK  | ?    |        |         | |
| BOX    | ?    |        |         | |
| TRIL-L | ?    |        |         | |
| CAMEMB | ?    |        |         | pour X710 |
| DIRECT | ?    |        |         | utilitaire |
| COCA   | ?    |        |         | demo Cocacola |
| 3D     | ?    |        |         | demo carré 3D  + codes speciaux asm ??? |
| EXA8BA | ?    |        |         | + codes speciaux asm ! |
| BOX    | ?    |        |         | |
| LMDATA | ?    |        |         | |
| CANON  | ?    |        |         | |
| C7TEXT | ?    |        |         | | + codes speciaux asm ! |


#### K7-4 (6/7)


| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|
| POKER  | A?   |        |         | |
| SAUTE  | A?   |        |         | Saute-moutons |
| ALARME | A?   |        | |
| CARAC  | A?   |        | |
| MEMORY | A?   |        | |
| LABY   | A?   |        | + codes speciaux asm ! |
| UTIL   | B?   |        | + codes speciaux asm ! |
| COURBE | B?   |        | |
| NOTES  | B?   |        | |

#### K7-5 (8)

| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|
| POLYGO | A    | | |              |
| AMORTL | A    | | |
| AMORTD | A    | | |
| ANEVID | A    | | |
| SIMVID | A    | | |
| BURGER | B    | | |
| BLITZ  | B    | | |


#### K7-6 (Jeux Andre Tonic)

| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|
| HARPOO  | ?   |        |         | Harpoon |
| STAR    | ?   |        |         | Star Blaster |
| SERPEN  | ?   |        |         | Serpent |
| MARCHA  | ?   |        |         | Le marchand de l'espace |
| CIRCUS  | ?   |        |         | Magic Circus |
| C.L-M   | ?   |        |         |
| TRI     | ?   |        |         |
| CALC2   | ?   |        |         |
| CASSE   | ?   |        |         | Casse Briques |
| DONJON  | ?   |        |         |
| MORPIO  | ?   |        |         | Morpion
| PROG A2 | ?   |        |         | Dactylo 1 ? |
| PROG B2 | ?   |        |         | Dactylo 2 ? |
| COPIE   | ?   |        |         |
| COURBE  | ?   |        |         | traceur de courbes |
| MEMORY  | ?   |        |         | Memory |
| MASTER  | ?   |        |         | Master Mind |
| JACK    | ?   |        |         | Jack Pot |
| T-T-T   | ?   |        |         | Tic tac toe |

#### K7-7 (divers)

| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|
| ASTRO  | ?    |        |         |  Astrologie |
| NUMERO | ?    |        |         |  Numerologie 24 K0 |
| TRON   | ?    |        |         |  |
| MATRIC | ?    |        |         |  Calcul matriciel |
| STARS  | ?    |        |         |  Jeu 7K0 |
| RIX    | ?    |        |         | + codes speciaux asm ! |
| AWARI  | ?    |        |         | + codes speciaux asm ! |
| 421    | ?    |        |         | Jeu du 421 |
| CITE   | ?    |        |         |  La Cite interdite |
| GP     | ?    |        |         |  Grand Prix |
| PROTEC | ?    |        |         |  |
| CVBASE | ?    |        |         |  |
| BLOCOC | ?    |        |         |  |
| K7     | ?    |        |         |  |


#### K7-8 (MATRIC)

| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|
| RESET  | A?   |        |         |             |
| IA     | A?   |        |         |    |
| GRAPHO | A?   |        |         |    |
| JOUR   | A?   |        |         |    |
| PROTEC | A?   |        |         |    |
| CVBASE | A?   |        |         |    |
| MINITE | A?   |        |         |    |
| TELE   | B?   |        |         |    |
| LMDATA | B?   |        |         |    |
| TELTAX | B?   |        |         |    |
| ETI    | B?   |        |         |    |
| FICHES | B?   |        |         |    |
| CALC   | B?   |        |         |    |


#### K7-9

Sur Cassette C-60 SBL.

| Nom        | Face | Status | Fichier | Commentaire |
|------------|------|--------|---------|-------------|
| SERPEN     | A?   |        |         |             |
| F 1        | A?   |        |         |             |
| BOMB       | A?   |        |         |             |
| COFFRE     | A?   |        |         |             |
| METEOR     | A?   |        |         |             |
| MUR LM     | A?   |        |         |             |
| CARACT.TXT | A?   |        |         | ???         |
| King F     | A?   |        |         |             |
| B ROGE     | A?   |        |         | Buck Rogers |
| AXIES      | A?   |        |         |             |
| RASE M     | A?   |        |         |             |
| Axies	     | A?   |        |         |             |
| SKIING     | A?   |        |         |             |
| DELTA      | A?   |        |         |             |
| KEY        | A?   |        |         |             |
| Fichie     | A?   |        |         |             |
| Laby       | A?   |        |         |             |
| K7         | B?   |        |         | trace etiquettes |
| K7 (2)     | B?   |        |         | trace etiquettes |
| T.T        | B?   |        |         | Traitement texte |
| T.T (2)    | B?   |        |         | Traitement texte |


#### K7-10

| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|
| TUNNEL | ?    |        |         |             |
| BREAK  | ?    |        |         |             |
| GASP   | ?    |        |         | Gaspation 1985 Nelson Productions |
| TEMPLE | ?    |        |         |             |
| CHENIL | ?    |        |         |             |
| WAR    | ?    |        |         | Star Wars   |
| OTHELL | ?    |        |         | Othello     |
| GRAVIT | ?    |        |         | Gravitation |


#### K7-11

Sur cassette BASF 60.

| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|
| SNAKE  | ?    |        |         |             |
| MAZOG  | ?    |        |         |    |
| TRI    | ?    |        |         |    |
| ANAC   | ?    |        |         |    |
| CARAC  | ?    |        |         |    |
| X07CAR | ?    |        |         |    |
| BENC   | ?    |        |         |    |
| C.3D   | ?    |        |         |    |
| 3D OI  | ?    |        |         |    |
| POLAR  | ?    |        |         |    |
| FACT   | ?    |        |         |    |
| POLYG  | ?    |        |         |    |
| TIC    | ?    |        |         |    |
| INVER  | ?    |        |         |    |
| PH     | ?    |        |         |    |
| RENUM  | ?    |        |         |    |
| DEUL   | ?    |        |         |    |
| 3DOI2  | ?    |        |         |    |
| FACTO  | ?    |        |         |    |
| KEY    | ?    |        |         |    |
| COURBE | ?    |        |         |    |
| CALEND | ?    |        |         |    |
| TIRAGE | ?    |        |         |    |
| 3D RAP | ?    |        |         |    |
| TEXTE  | ?    |        |         |    |
| CERCLE | ?    |        |         |    |
| MONT   | ?    |        |         |    |
| MANDEL | ?    |        |         |    |


#### K7-12

Casette carrefour ?

| Nom      | Face | Status | Fichier | Commentaire |
|----------|------|--------|---------|-------------|
| SI-VOL   | A    |        |         | Simulateur de vol |
| MINEUR   | A    |        |         | |
| GRAVIT   | A    |        |         | |
| MOON1    | A    |        |         | Moon Patrol 1 |
| MOON2    | A    |        |         | Moon Patrol 2 |
| MATHS    | A    |        |         | |
| ALIEN    | A    |        |         | |
| GASP     | A    |        |         | |
| AZAT     | A    |        |         | Presentation Azathot |
| AZATOT   | A    |        |         | Azathot |
| POKRTL   | A    |        |         | |
| DRAGON   | A    |        |         | |
| POKER    | A    |        |         | |
| ALARME   | A    |        |         | |
| GEOGRAPH | A    |        |         | |
| FRANCE   | A    |        |         | |
| accesN   | A    |        |         | |
| ACCES0   | A    |        |         | |
| RISK     | A    |        |         | |
| STRIP    | B    |        |         | Strip Poker |
| OTHELL   | B    |        |         | Othello |
| OTELO    | B    |        |         | |
| SEAWAR   | B    |        |         | |
| GOLF     | B    |        |         | |
| MOTEUR   | B    |        |         | |
| COKE     | B    |        |         | | 


#### K7-13

Cassette BASF LH 90.

| Nom      | Face | Status | Fichier | Commentaire |
|----------|------|--------|---------|-------------|
| FICHIE   | A    |        |         | Base de données
| CALC     | A    |        |         | Tableur
| 421      | A    |        |         |
| IA       | A    |        |         |
| BABY     | A    |        |         | Babylone
| JACK     | A    |        |         | Jack Pot
| KOALA    | A    |        |         | 
| koala    | A    |        |         |
| MASTER   | A    |        |         |  ???
| MEMORY   | A    |        |         | 
| GP       | A    |        |         |
| NUMERO   | A    |        |         | Numerologie
| CITE     | A    |        |         | La Cité Interdite
| DICTAT   | A    |        |         | 
| RESET    | A    |        |         | 
| GRAPHO   | A    |        |         | 
| LOGO     | A    |        |         | 
| DANSE    | A    |        |         | 
| PROTEC   | A    |        |         | 
| CVBASE   | A    |        |         | Conversion de bases
| BLOCOC   | A    |        |         | 
| K7       | A    |        |         | 
| MATRIC   | A    |        |         | Calcul matriciel
| SCHUBE   | A    |        |         | 
| JXINT    | A    |        |         | 
| ON TOP   | A    |        |         | 
| CIRCUS   | B    |        |         | Magic Circus 
| GEO      | B    |        |         | Définition de caracteres
| TELE     | B    |        |         |  
| COPIE    | B    |        |         |  
| AUT-F6   | B    |        |         | Autoprogrammation avec touche F6
| AUT-2    | B    |        |         |  
| AUT-3    | B    |        |         |  
| PAINT    | B    |        |         |  
| BREAK    | B    |        |         |  
| BOX      | B    |        |         |  
| CAMEMB   | B    |        |         |  
| LMDATA   | B    |        |         |  
| POKER    | B    |        |         |  
| SAUTE    | B    |        |         |  
| ALARM    | B    |        |         |  
| CARAC    | B    |        |         |  
| POLYGO   | B    |        |         |  
| AMORTL   | B    |        |         | Amortissement Linéaire
| AMORTD   | B    |        |         | Amortissement Dégressif
| ANEVID   | B    |        |         | Ane Rouge (sur video)
| RAYONZ   | B    |        |         | jeu (sur video)
| SIMVID   | B    |        |         | jeu (sur video)
| TELTAX   | B    |        |         | Calcul conso telephonique (necessite interface)
| ETI      | B    |        |         | Trace etiquettes K7 sur X-730
| GAMES2   | B    |        |         | Jeux Olympiques 


#### K7-14

Cassete TDK D46 ; MEMOREX 60 dBSI

| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|
| TRON   | ?    |        |         |  |
| JEU NB | ?    |        |         |  |
| CALCUL | ?    |        |         |  |
| CERCLE | ?    |        |         |  |
| MINMAX | ?    |        |         |  |
| MIROIR | ?    |        |         |  |
| COURSE | ?    |        |         |  |
| MUSIC  | ?    |        |         |  |
| PIANO  | ?    |        |         |  |
| POINT  | ?    |        |         |  |
| BILLE  | ?    |        |         |  |
| RONDS  | ?    |        |         |  |
| ESPACE | ?    |        |         |  |
| DORMIR | ?    |        |         |  |
| SOS    | ?    |        |         |  |
| SALUT  | ?    |        |         |  |



### Dossier speciaux informatiques 1-7 (Editions Neptune)

| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|
| 3D     | A    |        |         |  |
| GRAPH  | A    |        |         |  |
| TEST   | A    |        |         |  |
| MNTCC7 | A    |        |         |  |
| PERT   | A    |        |         |  |
| PIGAUS | A    |        |         | pivot de Gauss |
| DECOLU | A    |        |         | resolution aX=b |
| DECLDL | A    |        |         |  |
| GIVENS | A    |        |         |  |
| JACOBI | A    |        |         |  |
| GAUSEI | A    |        |         | Gauss Seidel |
| AUTOMA | A    |        |         |  |
 
Face B ?

### LE KIT'APPEL (Logi'stick) : gere appels telephoniques

| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|
| KIT'AP | A    |        |         |             |
| ?????? | A    |        |         | + données non reconnus |
| KIT'AP | B    |        |         |             |
| ?????? | B    |        |         | + données non reconnus |


### Le Son du CANON  n° 13

| Nom    | Face | Status | Fichier | Commentaire |
|--------|------|--------|---------|-------------|
| audio  | ?    |        |         | Explications  sur Burger (16 Ko mini) |
| BURGER | ?    |        |         | |
| CDT.1  | ?    |        |         | editeur d'icones |



 Jeux / Utilitaires
 - MUSIC 
 - TEMPLE
 - G-PRIX
 - LABYR
 - BATTLE pb au chargement
 - PROTECTEUR
 - AWARI + codes
 - VIE + codes
 - TERRE pb decodage
 
------------------------------------------------------------------------
 
 Aide Basic
 - RDI nok
 - MATRIX nok
 - MONITE 
 - MONITE moniteur memoire Canon X-07

------------------------------------------------------------------------


NAUTILUS
 - NAUTIL
 - NAUTIL2.txt
 
 BANQUE
 - V-BANK
 - L-BANK
 - + codes supplémentaires !





------------------------------------------------------------------------
POCKET SOFT
------------------------------------------------------------------------
X-07GRAPH
---------
 - XGRAPH
 - XCONV
 
X-07BASE
--------
 - XBASE
 - XTRANS
  
X-07CALC
--------
 - XCALC
 - XPLOT
 
X-07PERT
--------
 - XPERT






