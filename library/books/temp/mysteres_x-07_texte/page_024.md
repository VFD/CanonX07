44
45

## 4.4.2 L'instruction OR

Ecrivons la table de vérité de cette fonction :

|  A | B | A OR B  |
| --- | --- | --- |
|  0 | 0 | 0  |
|  0 | 1 | 1  |
|  1 | 0 | 1  |
|  1 | 1 | 1  |

On possède les mêmes possibilités qu'avec le AND logique :

|  OR v | OR (IX + dpl)  |
| --- | --- |
|  OR (HL) | OR (IY + dpl)  |
|  OR r |   |

Notons au passage que OR A fait aussi "ressortir" les indicateurs Z et S.

## 4.4.3 La disjonction logique ou XOR

Voici la table de vérité de XOR :

|  A | B | A XOR B  |
| --- | --- | --- |
|  0 | 0 | 0  |
|  0 | 1 | 1  |
|  1 | 0 | 1  |
|  1 | 1 | 0  |

Les possibilités exploitables restent identiques :

|  XOR v | XOR (IX + dpl)  |
| --- | --- |
|  XOR (HL) | XOR (IY + dpl)  |
|  XOR r |   |

*A noter* : XOR A permet de remettre à 0 l'accumulateur en un seul octet. En effet, l'instruction LD A,0 en nécessite deux !! Astucieux ...

## 4.4.4 COMPLEMENT et NEGATION

Ces commandes réalisent le complément à 1 (NOT) ou le complément à 2 (Négation) de l'accumulateur. Elles se nomment CPL et NEG. Voici un exemple vous permettant de saisir le rôle de ces deux instructions :

|  LD A,14h | Après l'instruction CPL, le registre A contiendra "EB".  |
| --- | --- |
|  CPL | Après l'instruction NEG, l'accumulateur contiendra la  |
|  NEG | valeur "15" en hexadécimal.  |

## 4.5 COMPARAISONS

Bien que les comparaisons et les décalages (Voir paragraphe 4.6) soient des fonctions logiques, nous avons préféré les séparer dans un pur souci de clarté.

Les comparaisons entre deux valeurs ne sont en fait qu'une soustraction provoquant la "montée" du CARRY s'il n'y a pas report du BIT 7. En fait, inutile de réfléchir autant car il suffit simplement de savoir que :

|  CARRY - 0 | ---→ | Accumulateur | → | Opérande  |
| --- | --- | --- | --- | --- |
|  CARRY - 1 | ---→ | Accumulateur | ← | Opérande  |

On note que la comparaison se fait toujours avec le registre A. Nous obtenons les commandes suivantes :

|  CP v | CP (IX + dpl)  |
| --- | --- |
|  CP r | CP (IX + dpl)  |
|  CP (HL) |   |

De plus, il existe les commandes CPI et CPD (en rapport avec LD1 et LDD) : le registre HL pointe l'octet à comparer et le registre BC sert de compteur.

## 4.6 LES DECALAGES

Il existe cinq grands types de décalages étudiés en détail ci-dessous.

## 4.6.1 DECALAGES CIRCULAIRES gauche et droite

Les bits de l'opérande sont décalés vers la gauche ou vers la droite. De plus, le bit sortant d'un côté entre de l'autre, tout en étant recopié dans le bit CARRY (Voir figure 13).

On obtient les possibilités suivantes :

|  RLC r | RRC r  |
| --- | --- |
|  RLC (HL) | RRC (HL)  |
|  RLC (IX + dpl) | RRC (IX + dpl)  |
|  RLC (IY + dpl) | RRC (IY + dpl)  |
|  RLCA | RRCA  |