32
33

# 2.6 Les ARGUMENTS de L'OPERANDE.

Nous avons vu précédemment que l'argument d'un opérande pouvait prendre plusieurs significations. En effet, l'argument d'opérande peut être constitué par ...

## 2.6.1 Une ADRESSE.

Il s'agit d'une adresse mémoire codée sur 16 bits ne pouvant être contenue que dans un double registre (BC, DE, HL ...). Par exemple, on peut trouver LD HL,4520h ; LD IX,2020h ... ('h' désigne la base 16).

## 2.6.2 Un POINTEUR ADRESSE.

Un pointeur adresse permet d'accéder à l'octet pointé par une adresse mémoire. Par exemple, en exécutant LD HL,(2000h), on ne stocke pas l'adresse 2000h dans le double registre HL mais l'octet situé à l'adresse 2000h. Manière tout à fait indirecte !! Notez que les parenthèses spécifient ce type d'argument.

## 2.6.3 Un REGISTRE.

En effet, l'argument d'opérande prendra alors le nom de l'un des 16 registres suivants : BC, DE, HL, SP, IX, IY, AF, A, B, C, D, E, H, L, I ou R. Vous ne remarquez rien ? ... Le registre F ne peut être utilisé seul car c'est un registre spécial (Voir le paragraphe 1.7.3). Par exemple, on peut avoir OR D ; POP IX ; LD B,E ...

## 2.6.4 Un POINTEUR REGISTRE.

Nous avons vu au paragraphe 2.6.2 une façon indirecte de désigner un octet via une adresse. Le fait de prendre un registre au lieu d'une adresse ne change rien à l'affaire !

En effet, ce pointeur est constitué par l'un des registres suivants : (DE), (HL), (BC), (IY), (IX) et (SP). Notez au passage que ces registres sont pourvus de parenthèses comme pour le pointeur adresse.

Je pense que vous avez deviné l'action de ce pointeur. Il permet d'accéder à l'octet pointé par l'adresse contenue dans le registre mentionné entre les parenthèses ... OUF !!!

Par exemple, si le registre HL contient l'adresse 4500h et que l'on exécute LD B,(HL), qu'arrivera t-il ? ... Eh bien, le registre B contiendra l'octet situé en 4500h.

# 2.6.5 Une DONNEE.

Il peut s'agir d'une donnée constituée de 8 ou de 16 bits selon le type d'instruction utilisée. Cette donnée peut adopter plusieurs formes différentes exposées au paragraphe 2.7.

Quelques exemples : LD BC,4543h ; LD B,4 ; LD A,18h ...

## 2.6.6 Un MOT-CLE de CONDITION.

Les instructions du NSC 800 peuvent tester la présence de conditions particulières matérialisées par les fameux indicateurs du registre F (Voir paragraphe 1.7.3).

Un mot-clé correspond à chacune de ces conditions. Il se trouve toujours en premier argument de l'opérande des instructions de branchement (Ex : JP, CALL, RET ...).

Il existe 8 mots-clés différents :

|  Z | ---→ | Zéro  |
| --- | --- | --- |
|  NZ | ---→ | Non Zéro  |
|  C | ---→ | Carry  |
|  NC | ---→ | Non Carry  |
|  PE | ---→ | Parité Paire  |
|  PO | ---→ | Parité Impaire  |
|  M | ---→ | Moins (négatif)  |
|  P | ---→ | Plus (positif)  |

Voici deux exemples afin d'éclaircir vos idées :

1/
CALL NZ, 4000h
LD HL, (1000h)

Ici, si l'indicateur NZ est positionné à 1, le programme se poursuivra en exécutant le sous programme situé à l'adresse 4000h puis reviendra. Sinon, si NZ n'est pas positionné, le programme n'ira pas en 4000h et chargera seulement, dans le registre HL, l'octet situé en 1000h.

2/
RET C
JP 5000h

Ici, si l'indicateur se trouve être égal à 1, le programme exécutera le RET (RETURN). Sinon, il poursuivra à l'adresse 5000h à cause du JP (JUMP).

Après avoir terminé le détail des champs, occupons-nous des données ...