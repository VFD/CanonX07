46
47

![img-0.jpeg](img-0.jpeg)
FIGURE 13: DECALAGES CIRCULAIRES

![img-1.jpeg](img-1.jpeg)
FIGURE 14: DECALAGES / CARRY

Un peu de langue anglaise : RLC signifie Rotate Left Circular et RRC se traduit par Rotate Right Circular.

Les instructions RLCA et RRCA ne sont pas spécifiques au micro-processeur Z-80. En effet, elles proviennent du micro-processeur 8080 de la société INTEL et fonctionnent de la même manière que les commandes RLC A et RRC A à part que les indicateurs sont positionnés avec ces dernières.

## 4.6.2 DECALAGES à travers le CARRY, à droite et à gauche.

Tout se passe comme si l'opérande ne faisait plus 8 bits mais 9 et qu'il soit décalé d'une position binaire. Le bit sortant d'un côté entre dans le bit CARRY et l'ancienne valeur du CARRY entre de l'autre côté de l'opérande (Voir figure 14). Pour les instructions RLA et RRA que vous allez découvrir ci-dessous, les remarques précédentes sont valables (issues du 8080 ...). Voici les commandes disponibles :

|  RL r | RR r  |
| --- | --- |
|  RL (HL) | RR (HL)  |
|  RL (IX + dpl) | RR (IX + dpl)  |
|  RL (IY + dpl) | RR (IY + dpl)  |
|  RLA | RRA  |

## 4.6.3 DECALAGES OUVERTS ARITHMETIQUES droite et gauche.

Ces décalages sont "ouverts" car le bit sortant est perdu alors que le bit entrant est nul. De plus, le décalage à droite conserve le signe (Voir figure 15). Les possibilités restent identiques :

|  SLA r | SRA r  |
| --- | --- |
|  SLA (HL) | SLA (HL)  |
|  SLA (IX + dpl) | SRA (IX + dpl)  |
|  SLA (IY + dpl) | SRA (IY + dpl)  |

SLA se traduit en anglais par Shift Left Arithmetic et SRA par Shift Right Arithmetic.

## 4.6.4 DECALAGES "OUVERTS LOGIQUES" à droite.

Pour "contrebalancer" l'instruction SRA qui recopie le bit de signe après le décalage, il existe une autre instruction nommée SRL. l'octet mémoire pointé par l'opérande sera décalé logiquement de une position vers la droite (Voir figure 16).