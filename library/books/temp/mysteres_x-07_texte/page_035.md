FIGURE 14: BLOC-DIAGRAMME
66

![img-0.jpeg](img-0.jpeg)

Par conséquent, pour que les programmeurs intrépides de la caste CANON puissent utiliser cette étonnante mémoire LCD (Nous en verrons l'utilité dans la troisième partie ...), il va falloir qu'ils demandent au T6834 d'envoyer certains codes de contrôle afin d'y écrire. Eh oui, le Z-80 ne sait pas écrire dans cette mémoire !

## L'unité centrale comprend :

- Un microprocesseur Z-80.
- 8 Kilo-octets de RAM en version de base.
- 20 Kilo-octets de ROM contenant l'interpréteur BASIC.

## On peut, en outre, y adjoindre :

- 16 Kilo-octets de RAM (sous forme de CHIP ou de carte mémoire).
- 8 Kilo-octets de ROM (carte préprogrammée CANON).
- 4 Kilo-octets de ROM (interface vidéo X-720).
- 16 Kilo-octets de RAM Vidéo.

## 7.3 Le PLAN de la MEMOIRE.

Le NSC 800 peut adresser 64 Kilo-octets de mémoire (comme tous les processeurs 8 bits...) répartis en plusieurs secteurs décrits à la figure 19.

Deux choses particulièrement importantes sont à noter :

- L'adressage de la carte mémoire et de la prise est inversé lorsque l'on place une mémoire additionnelle de 8 Kilo-octets. Ceci permet d'obtenir un adressage continu lorsqu'une carte est retirée.
- On note que la partie basse de la mémoire est divisée en deux zones. Pourquoi ? A la mise sous tension du X-07, le NSC 800, comme tous les processeurs, cherche à effectuer les instructions se situant à l'adresse 0000. Il est donc absolument vital qu'un programme s'y trouve... A la mise en route du CANON, cette zone mémoire est constituée par de la RAM puis le X-07 la "masque" et le bas de la mémoire redevient de la RAM.

## 7.4 La ROM des CARTES MEMOIRE.

Lorsque l'on place une carte mémoire dans le logement destiné à cet effet, il est primordial que le X-07 la détecte pour que l'on puisse s'en servir.

Une fois la carte détectée, le CANON modifie la zone "RAM système" (Pour en savoir plus sur cette zone, reportez-vous au chapitre 8).

67