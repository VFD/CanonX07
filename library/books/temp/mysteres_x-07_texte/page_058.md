112
# 10.2 L'IMPRIMANTE GRAPHIQUE X-710.

Elle possède son propre micro-processeur 4 bits ainsi qu'une ROM de 4096 * 10 bits et une RAM de 256 * 4 bits. Le tout fonctionne grâce à une horloge interne battant à quelques 600 Khz.

Les caractères imprimés correspondent aux codes ASCII selon la table décrite dans les manuels d'utilisation du CANON.

Les informations de déplacement du stylo sont interprétées de la façon suivante :

Bit 7 --&gt; information de fin (1, fin de déplacement / 0, déplacement).
Bits 4 à 6 --&gt; taille du mouvement.
Bit 3 --&gt; s'il est égal à 0, le stylo est levé. S'il est égal à 1, le stylo trace.
Bits 0 à 2 --&gt; direction du mouvement.

A titre purement indicatif, nous vous exposons le plan de l'imprimante X-710. En effet, les inconditionnels du "fer à souder" trouveront dans l'exploitation de ce plan et du brochage joint, la possibilité de rajouter une ROM contenant d'autres caractères... Nous vous souhaitons bonne chance !!

Les deux figures présentes dans les pages suivantes vont relancer les ventes de fer à souder dans les prochaines semaines ... Merci aux auteurs !!

# 10.3 L'INTERFACE VIDEO X-720.

La X-720 contient 6 Kilo-octets de mémoire vidéo contenus entre les adresses 800h et 97FFh. Cette mémoire est totalement utilisée par les modes SCREEN 5 et 6.

Dans les modes "Basse résolution", deux pages d'écran sont accessibles permettant des sauts de page à grande vitesse.

De plus, cette interface contient 4 Kilo-octets de ROM, des adresses 4000h à 8000h. Elle modifie certaines adresses de la zone système selon la même méthode que les cartes. Par exemple, la carte XP 140F modifie plusieurs adresses de retour par des sauts (Voir paragraphe 8.3). De même, la X-720, en modifiant certaines adresses, obtient diverses fonctions BASIC nécessaires à son fonctionnement : SCREEN, PAINT, COLOR. Notons que les instructions comme LINE, PSET, PRESET, CIRCLE sont étendues.

A titre indicatif, nous désirons répondre aux personnes qui recherchent l'utilité du connecteur placé au dos de la X-720. Normalement, cette prise devrait servir soit à des cartouches ROM, soit à des extensions de mémoire vive. Mais aucune extension n'a encore été commercialisée à ce jour ...

![img-0.jpeg](img-0.jpeg)

Pin contents

|  Pin No. | Designation | Input | Output | Form of terminal | Function  |   |
| --- | --- | --- | --- | --- | --- | --- |
|  1 | D4 | ○ |  | A | SCS (Scale Set) L: Scale 1 after reset; H: Scale 0 after reset  |   |
|  2 | D5 | ○ |  | A | CRM (Cantage Return Mode) L: CR only; H: CR + LF  |   |
|  3 | D6 |  | ○ | A | EXEN (Rom Enable)  |   |
|  4 | D7 | ○ |  | B | Paper feed
Back feed
Color change
Pen change | Switch input from outside  |
|  5 | D8 | ○ |  | B  |   |   |
|  6 | D9 | ○ |  | S  |   |   |
|  7 | D10 | ○ |  | B  |   |   |
|  8 | D11 | ○ |  | A | PWS (Paper Width Select) L: 58 mm; H: 114 mm  |   |
|  9 | D12 | ○ |  | A | DNS (Color Number Select) L: 1 color; H: 4 colors  |   |
|  10 | D13 |  | ○ | C | (Hair Enable) HLTEN (Positive logo)  |   |
|  11 | D14 |  | ○ | C | STR (Scribe Latch F/F reset)  |   |
|  12 | D15 |  | ○ | C | SSR (Busy Latch F/F reset)  |   |
|  13 | R40 | ○ |  | A | D3
D1
D2
D3 | Parallel data input
Character code input from outside  |
|  14 | R41 | ○ |  | A  |   |   |
|  15 | R42 | ○ |  | A  |   |   |
|  16 | R43 | ○ |  | A  |   |   |
|  17 | R50 | ○ |  | A | D4
D1
D2
D3 | Parallel data input  |
|  18 | R51 | ○ |  | A  |   |   |
|  19 | R52 | ○ |  | A  |   |   |
|  20 | R53 | ○ |  | A  |   |   |

113