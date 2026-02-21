54
55

# 4.10 INSTRUCTIONS sur BITS et CHAINES

## 4.10.1 INSTRUCTIONS sur BITS

Habituellement, le NSC 800 travaille sur des valeurs de 8 bits ou exceptionnellement sur des quartets (groupe de 4 octets). Les commandes sur bits affinent encore ces opérations avec :

- Mise à 1 d'un bit : instruction SET.
- Mise à 0 d'un bit : instruction RES.
- Test de la valeur d'un bit : instruction BIT.

L'instruction BIT charge dans le drapeau Z l'inverse du bit testé. Les commandes disponibles sont (b représente le numéro du bit):

|  BIT b, (HL) | SET b, (HL) | RES b, (HL)  |
| --- | --- | --- |
|  BIT b, (IX + dpi) | SET b, (IX + dpi) | RES b, (IX + dpi)  |
|  BIT b, (IY + dpi) | SET b, (IY + dpi) | RES b, (IY + dpi)  |
|  BIT b, r | SET b, r | RES b, r  |

## 4.10.2 INSTRUCTIONS sur CHAINES

Ces commandes opèrent sur des chaînes, des zones de mémoire. On recense trois groupes principaux d'instructions sur chaînes : les commandes de TRANSFERT, de COMPARAISON (ou de RECHERCHE) et d'ENTREES / SORTIES.

Les instructions de transfert permettent de transférer une zone mémoire d'un endroit à un autre. Si l'on part du début de la zone, on utilise l'instruction LDIR. À l'inverse, si l'on part de la fin de la zone, on utilise la commande LDDR. Les registres suivants sont utilisés :

- HL ———→ adresse de la zone source à déplacer.
- DE ———→ adresse de la zone de destination.
- BC ———→ longueur de la zone en octets.

On transfert les octets pointés par le registre HL dans la zone pointée par le registre DE et ce, jusqu'à ce que le registre BC soit nul. Les registres HL et DE ont été incrémentés ou décrémentés durant l'opération, suivant l'instruction LDIR ou LDDR.

Les deux instructions de recherche CPIR et CPDR permettent de rechercher une coincidence entre l'octet contenu dans le registre A et les octets d'une chaîne pointée par le registre HL.

Cette opération prend fin lorsque la coincidence attendue a été établie ou lorsque l'on arrive à la fin de la chaîne. La zone mémoire peut être scrutée de haut en bas (instruction CPIR) ou de bas en haut (commande CPDR).

Dans le cas de CPIR, l'accumulateur est comparé avec l'octet pointé par le registre HL. HL est incrémenté et BC se trouve décrémenté. Si la valeur du registre A est égale à la valeur de l'octet pointé, l'opération se termine et le drapeau Z est mis à 1. Sinon, l'opération se poursuit jusqu'à trouver cette égalité ou la fin de chaîne (le registre BC est alors égal à 0 et le drapeau V est mis à 0).

Les instructions d'entrées / sorties sont au nombre de quatre et permettent de dialoguer avec un périphérique, avec une zone mémoire longue de 1 à 256 octets.

L'adresse du périphérique est contenue dans le registre C et l'adresse de la chaîne à émettre ou à recevoir se trouve dans le registre HL. Comme pour les autres commandes de chaîne vues précédemment, l'avant dernière lettre de la mûrionique indique si l'adresse de la chaîne doit s'incrémenter ou se décrémenter.

Nous obtenons les commandes suivantes :

|  OTIR | OTDR  |
| --- | --- |
|  INIR | INDR  |

## 4.11 INSTRUCTIONS de PILE

Les instructions de PILE sont au nombre de deux : PUSH et POP. La commande PUSH enverra vers la pile le contenu du double registre spécifié. Evidemment, l'instruction POP ira chercher la première valeur se trouvant sur cette pile et la stockera dans le double registre présent en opérande.

Les deux instructions disponibles sont donc :

|  PUSH rr | POP rr  |
| --- | --- |

rr désigne n'importe quel registre 16 bits sauf le registre PC, bien sûr ...

Ouf !! Vous pouvez souffler !! Nous savons que l'inventaire des instructions d'un micro-processeur est fastidieux mais il est nécessaire. Ne vous affolez surtout pas à la vue de toutes ces commandes ... Bien qu'elles soient très nombreuses, vous apprendrez très rapidement à les maîtriser en les utilisant. Cela paraît évident mais l'ASSEMBLEUR étant un langage plus ardu à appréhender que le BASIC, il nécessite une longue pratique ainsi qu'une grande rigueur. Passons maintenant aux "PSEUDO INSTRUCTIONS" ...