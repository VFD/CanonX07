48
49

![img-0.jpeg](img-0.jpeg)
FIGURE 15: DECALAGES ARITHMETIQUES

![img-1.jpeg](img-1.jpeg)
FIGURE 16: DECALAGES LOGIQUES

![img-2.jpeg](img-2.jpeg)
FIGURE 17: DECALAGES BCD

Avec cette instruction, des décalages ouverts sur 16 bits peuvent être réalisés.

On obtient les commandes suivantes :

SRL r    SRL (HL)    SRL (IX + dpi)    SRL (IY + dpi)

## 4.6.5 DECALAGES CIRCULAIRES BCD gauche et droite

Ce dernier groupe de décalages concerne deux instructions puissantes en arithmétique. En effet, les décalages BCD ne se font plus sur un bit comme précédemment mais sur quatre bits. L'accumulateur est utilisé comme registre de manœuvre et l'opérande sera le pointeur registre HL (Voir figures 17).

## 4.7 INSTRUCTIONS D'USAGE GENERAL et de CONTROLES

Ce sont des instructions réparties en trois catégories principales :

- Les instructions agissant sur le CARRY.
- Les commandes liées aux interruptions.
- Les opérations "indispensables".

### 4.7.1 Les instructions agissant sur le CARRY

Elles sont au nombre de deux : SCF qui force le CARRY à prendre la valeur 1 et CCF qui inverse l'état du CARRY.

### 4.7.2 Les commandes liées aux INTERRUPTIONS

Une interruption est un événement matériel extérieur provoquant l'interruption du programme en cours d'exécution. Une routine spécifique traite alors l'interruption et le programme interrompu repart. Une interruption peut très bien venir d'un périphérique, une imprimante par exemple qui alerte l'ordinateur de la fin prochaine de son travail.

Les instructions HI et DI sont utilisées pour activer et désactiver le système de prise en compte des interruptions du 280.

Les commandes IM 0, IM 1 et IM 2 effectuent le passage dans les différents modes d'interruption. Ne vous inquiétez pas, le CANON X-07 ne travaille qu'en mode 0.