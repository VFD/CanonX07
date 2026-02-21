80
81

3F L'instruction **REQUEST SLEEP** coupe l'alimentation du X-07 et le CANON se trouve en mode SLEEP.

40 L'instruction **UDK INIT** rétablit les assignations par défaut des touches de fonction.

41 L'instruction **Ecriture de caractère** affiche le motif de 6*8 points spécifié par l'utilisateur sur la position du curseur. Le curseur avance ensuite sur la position suivante. Le motif est composé de 8 octets de données suivant la commande. Le format reste le même que celui de la commande 1A.

42 L'instruction **Lecture de caractère** fait sortir 8 octets de données sur la position du curseur.

43 L'instruction **SCANR** renvoie 8 bits de données indiquant les réglages des points dans la zone 6*8 (emplacement du curseur). Le format reste le même que celui de la commande 1B.

44 L'instruction **SCANL** renvoie le nombre de points posés à gauche de la position (X-1,Y).

45 L'instruction **TIME CHK** controle les réglages des données de temps vus précédemment suivant les lois normales.
0&lt;=seconde&lt;60 sinon Bit 0=1 (Etat d'erreur ...)
0&lt;=minute&lt;60 sinon Bit 1=1
0&lt;=heure&lt;24 sinon Bit 2=1
0&lt;=jour&lt;=28,29,30,31 sinon Bit 3=1
0&lt;=mois&lt;=12 sinon Bit 4=1
1901&lt;=année&lt;=2099 sinon Bit 5=1
On note que Bit 6=Bit 7=0

46 L'instruction **ALM CHK** controle les réglages d'alarme.

La figure 24 récapitule chaque numéro de fonction accompagné de son nombre d'octets (commande et opérateur) et de sa longueur de réponse.

Nous étudierons ensuite le secteur mémoire du T6864, zone réservée exclusivement au sous-processeur ...

|  N° | Nombre d'octets | Réponse (octets) | N° | Nombre d'octets | Réponse  |
| --- | --- | --- | --- | --- | --- |
|  01 | 1 | 8 | 26 | 1 | 0  |
|  02 | 1 | 1 | 27 | 3 | 1  |
|  03 | 1 | 1 | 28 | 2 | 1  |
|  04 | 1 | 1 | 29 | 1 | 0  |
|  05 | 3 | 1 | 2A | 2 | 0  |
|  06 | 4 | 0 | 2B | 1 | 0  |
|  07 | 3 | 0 | 2C | 1 | 0  |
|  08 | 1 | 0 | 2D | 1 | 0  |
|  09 | 2 | 0 | 2E | 1 | 0  |
|  0A | 9 | 0 | 2F | 1 | 0  |
|  0B | 1 | 0 | 30 | 1 | 0  |
|  0C | 9 | 0 | 31 | 1 | 0  |
|  0D | 1 | 0 | 32 | 1 | 0  |
|  0E | 1 | 0 | 33 | 1 | 0  |
|  0F | 2 | 120 | 34 | 1 | 0  |
|  10 | 3 | 1 | 35 | 2*n*00" | 0  |
|  11 | 3 | 0 | 36 | 1 | 8  |
|  12 | 3 | 0 | 37 | 1 | 1  |
|  13 | 3 | 0 | 38 | 1 | 0  |
|  14 | 5 | 0 | 39 | 1 | 0  |
|  15 | 4 | 0 | 3A | 1 | 0  |
|  16 | 2*n*00" | 0 | 3B | 1 | 0  |
|  17 | 2 | n*00" | 3C | 1 | 0  |
|  18 | 1 | 0 | 3D | 1 | 0  |
|  19 | 1 | 0 | 3E | 1 | 0  |
|  1A | 10 | 0 | 3F | 1 | 0  |
|  1B | 2 | 8 | 40 | 1 | 0  |
|  1C | 1 | 0 | 41 | 9 | 0  |
|  1D | 1*n*00" | 0 | 42 | 1 | 8  |
|  1E | 1*n*00" | 0 | 43 | 3 | 2  |
|  1F | 1 | 0 | 44 | 3 | 2  |
|  20 | 1 | 0 | 45 | 1 | 1  |
|  21 | 1 | n*00" | 46 | 1 | 1  |
|  22 | 1 | 1 |  |  |   |
|  23 | 1 | 0 |  |  |   |
|  24 | 4 | 0 |  |  |   |
|  25 | 1 | 0 |  |  |   |

L'ETIRE 24 : TABLEAU des COMMANDES