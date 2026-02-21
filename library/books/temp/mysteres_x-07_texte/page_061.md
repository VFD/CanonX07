# SÈME PARTIE :

## APPLICATIONS

![img-0.jpeg](img-0.jpeg)

# APPICHAGE

Ce programme permet d'afficher un motif de 8*8 points en l'écrivant directement dans la mémoire LCD du sous-processeur T6834 (Voir le paragraphe 7.7 pour plus de précisions).

L'avantage de cette routine est constitué par le fait que nous ne sommes plus limités par des caractères définis par 6*8 points.

Le principe en est relativement simple. En effet, en RAM, le plus petit point adressable est constitué par une "ligne" de 8 points dans laquelle le chiffre 1 représente un point allumé et le chiffre 0 un point éteint.

On définira donc la forme désirée par une suite de 8 octets où tous les chiffres 1 représenteront des points allumés. Ensuite, nous irons écrire tous ces points les uns après les autres dans la RAM du sous-processeur.

En fait, nous utilisons le même principe que l'instruction BASIC FONT$.

Reportez-vous aux listings de la figure 31 afin de bien comprendre le déroulement du logiciel. Le programme BASIC chargeant les codes est directement utilisable.

Longueur de la routine : 27 octets.
Implantation de la routine : de 1B00h à 1B1Ah.

119