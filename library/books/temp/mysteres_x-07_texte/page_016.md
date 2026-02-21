MINEMONIQUE &amp; ASSEMBLEUR

Nous allons attaquer ensemble une des parties les plus importantes du livre. En effet, vous brulez surement de savoir comment développer la programmation de l'ASSEMBLEUR. Tout ceci va être élucidé au cours de ce chapitre.

## 2.1 INTRODUCTION

Nous avons vu précédemment que rien ne différenciait dans la mémoire une donnée d'une instruction. En effet, elles sont toutes deux codées de la même manière, une suite de 1 et de 0. Si nous devions programmer de cette façon, c'est à dire écrire une longue suite de 1 et de 0, nous commettrions probablement beaucoup d'erreurs ! De plus, la lecture d'un programme déjà écrit ne serait pas du tout évidente.

Pour pallier à cet état de faits, les constructeurs ont donné un nom à chaque commande. Ce nom constitue la MNEMONIQUE de l'instruction. Ainsi, le "GOTO" du BASIC se nommera, en mnémonique Z-80, "JP" (Diminutif de "JumP" qui se traduit par "sauter" en français). Sa véritable écriture en binaire est "11000011" et "C3" en hexadécimal (Remarquons au passage que cela devient déjà beaucoup plus simple en hexadécimal...).

## 2.2 De L'UTILITE d'un ASSEMBLEUR

Essayons d'écrire en binaire "aller à la case mémoire 4000". Très simple, n'est-ce pas ? Cela fait : "11000011" (JP) et "0000111110100000" (4000 code sur 16 bits). De plus, pour simplifier la chose (!), il faut écrire les 8 bits les plus importants (dits de "poids fort") à l'adresse de poids fort. En effet, les mots étant stockés sur 8 bits, on obtiendrait logiquement :

|  Adresse | Contenu  |
| --- | --- |
|  02 | 10100000  |
|  01 | 00001111  |
|  00 | 11000011  |

Seulement, si l'on stocke les nombres de cette façon, la partie faible de l'adresse du saut sera stockée à l'adresse la plus forte. Il faut donc inverser la deuxième partie de l'adresse.

En fait, on trouvera dans la mémoire la configuration suivante :

|  Adresse en DECIMAL | Contenu en BINAIRE | Contenu en HEXA  |
| --- | --- | --- |
|  02 | 00001111 | 0F  |
|  01 | 10100000 | A0  |
|  00 | 11000011 | C3  |

Comme vous avez pu le remarquer, toutes ces opérations deviennent très rapidement fastidieuses à effectuer "à la main". Par contre, c'est le travail typique dont peut se charger un ordinateur.

Par conséquent, on a écrit un logiciel auquel on fournit la liste de toutes les mnémoniques, qui les transforme en binaire puis les range à l'adresse désirée. Le listing en mnémoniques s'intitule "le code source", les mots binaires obtenus représentant "les codes objets". Le logiciel se nomme alors un "ASSEMBLEUR".

## 2.3 Les LABELS

Un label constitue une référence placée dans le code source. On pourra ensuite y faire appel, l'ASSEMBLEUR se chargeant de la transformer.

Ainsi, au lieu de "JP 4000", nous aurons pu écrire "JP LABEL" si nous avions défini auparavant "4000" comme un "LABEL". Ceci s'appelle, en termes techniques, l'adressage symbolique. Ce mode d'adressage n'existe pas dans le BASIC du X-07 mais, à titre d'exemple, les micro-ordinateurs de la gamme SHARP (PC 1212, 1500...) peuvent utiliser ce type d'adressage (Ex : GOTO "DEBUT", GOSUB "FIN"...).

Mais les labels ne sont pas strictement réservés à l'adressage symbolique. Effectivement, nous pouvons écrire LD A, "SOMME" si nous avons précédemment affecté une valeur au symbole "SOMME" (Ex : "SOMME" = 11 ; LD A, "SOMME" est alors équivalent à LD A,11). Notons que la commande "LD" charge un nombre dans le registre spécifié : nous verrons ceci plus en détail au chapitre 4.

En fait, les possibilités réelles d'un ASSEMBLEUR varient et sont toujours exposées dans sa notice.

## 2.4 FONCTIONNALITES de L'ASSEMBLEUR

Vous devez probablement vous demander la façon d'introduire le code source en mémoire... Cette opération se pratique avec un éditeur de textes intégré ou non au logiciel ASSEMBLEUR. Parfois, cet éditeur de textes s'identifie à l'éditeur BASIC. En effet, les deux ASSEMBLEURS pour X-07 (Voir ANNEXE 2) utilisent l'éditeur BASIC très complet du CANON afin d'éviter d'en réécrire un.