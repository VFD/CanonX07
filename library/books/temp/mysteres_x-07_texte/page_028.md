52
53

# 4.8.4 Les APPELS de SOUS-PROGRAMMES en PAGE 0

Ce sont seulement des CALL mais présentant deux différences essentielles par rapport aux CALL précédents :

- D'une part, le code opératoire de ces commandes n'occupe qu'un seul octet contre trois pour les CALL classiques.
- Ils se réfèrent à des SOUS-PROGRAMMES d'adresses fixes, situés en début de mémoire (PAGE 0).

Les sous-programmes appelés seront implantés aux adresses 0, 8, 10h, 18h, 20h, 28h, 30h et 38h. L'adressage de ces instructions est direct et les indicateurs ne sont pas affectés lors de leur emploi.

Dans le mode 0 du NSC 800, l'apparition d'une interruption déclenche un appel à l'une de ces adresses contenant des routines d'interruption. Ces commandes portent aussi le doux nom de ReSTarts.

En ce qui concerne le X-07, voici à quoi correspondent tous ces appels systèmes :

→ RST 0 : Correspond au "BREAK POINT" de la carte moniteur XP 140F. Un code C9 (RET) est implanté en 0 quand la carte n'est pas en place.

→ RST 8 : Cette commande compare deux symboles entre eux. La comparaison se fait entre l'octet pointé par HL et l'octet suivant l'appel par RST 8 : _Si concordance, retour à RST 8 + 2 et HL=HL+1. _Si désaccord, "SN ERROR" est affiché.

→ RST 10h : Cette instruction examine le symbole suivant. Elle charge dans A le caractère pointé par HL. En sortie, HL incrémenté et : _C=1 si caractère alphanumérique _C=0 si caractère alphabétique.

→ RST 18h : Cette commande émet un ordre vers le sous-processeur T6834. Le registre A doit contenir le code de la commande. Il n'y a pas de paramètres possibles.

→ RST 20h : Cette instruction compare les registres DE et HL :
- Si HL &lt; DE, C=1
- Si HL &gt; DE, C=0
- Si HL = DE, Z=1
- Seul le registre A est modifié.

→ RST 28h : Cette instruction émet le contenu de A vers le dispositif ouvert, en général l'écran LCD. Tous les registres sont préservés.

→ RST 30h : Cette instruction teste le type de données se trouvant dans A. On obtient le tableau récapitulatif suivant :

|  Adresse 1D9h | TYPE | FLAGS | Contenu de A  |
| --- | --- | --- | --- |
|  2 | ENTIER | NC, Z, M | -1  |
|  3 | CHAINE | Z, C, P | 0  |
|  4 | S. PRE | NZ, C, P | 1  |
|  8 | D. PRE | NZ, NC, P | 5  |

→ RST 38h : Cette commande calcule l'adresse des tableaux.

# 4.9 Les ENTREES / SORTIES

Il n'existe en fait que deux instructions relatives aux entrées / sorties : IN et OUT. Mais il existe différentes façons de les appeler, ce qui offre beaucoup de possibilités.

Nous avons déjà les commandes OUT (v), A et IN A, (v) : le contenu du registre A est envoyé à l'organe périphérique d'adresse v, dans le cas de l'instruction OUT. Par contre, pour la commande IN, le registre A est chargé avec l'information émise par le périphérique d'adresse v.

Nous avons aussi OUT (C), r et IN (C), r. Ici, l'adresse du périphérique est contenue dans le registre C et r peut représenter n'importe quel registre 8 bits du NSC 800.

Enfin, il existe quatre puissantes commandes nommées INI, IND, OUTI et OUTD. L'adresse du périphérique se trouve toujours dans le registre C mais l'information émise (OUT) ou lue (IN) se trouve en mémoire (pointée par le registre HL) et non plus dans un registre comme précédemment.

A chaque exécution de l'une de ces instructions, le registre B est décrémenté de 1, le registre HL est incrémenté de 1 pour les instructions INI et OUTI et décrémenté de 1 pour les instructions IND et OUTD.

Les ports de sortie exploités par ces instructions seront exploités dans la deuxième partie de cette ouvrage.