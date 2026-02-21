120
121

# INVERSION DE L'APFICHEUR VIDEO

Le but de cette routine est d'inverser octet par octet la mémoire d'écran VIDEO du X-07 dans les modes SCREEN 5 et 6.

On obtient ainsi une inversion des couleurs de l'affichage quasi instantanée.

Le principe du logiciel est basé sur une petite astuce logique ... Effectivement, nous utilisons l'instruction XOR dont la table de vérité est décrite dans la première partie de cet ouvrage.

En chargeant le registre B uniquement avec des chiffres 1, on effectue le XOR logique avec le registre A et nous obtenons alors :

1 XOR 1 = 0 et 1 XOR 0 = 1

Donc, en partant de l'adresse minimale de la mémoire VIDEO (Rappel : cette V.RAM s'étend des adresses 8000h à 97FFh), nous pouvons inverser octet par octet chaque parcelle de cette mémoire en suivant le principe précédemment décrit ... Qui a dit que l'interface VIDEO était lente ? ...

Longueur de la routine : 22 octets.
Implantation de la routine : de 1C00h à 1C15h.

![img-0.jpeg](img-0.jpeg)

|  Codage graphique | Codage binaire | Codage hexa.  |
| --- | --- | --- |
|   | 11111111 | FF  |
|   | 10000001 | δ1  |
|   | 10000001 | δ1  |
|   | 10000001 | δ1  |
|   | 10000001 | δ1  |
|   | 10000001 | δ1  |
|   | 10000001 | δ1  |
|   | 11111111 | FF  |

FIGURE 1 : AFFICHAGE