110
111

C528 A cette adresse, on arrive au niveau de l'affichage du message "COPY-RIGHT".

C3C3 Initialisation générale. Départ à froid du X-07.

FB4F Entrée d'une routine hexadécimale.

C4D1 Affichage de "CREATE SYSTEM ?". Taper Y, "RETURN" pour continuer. Routine très pratique pour effacer complètement une carte mémoire. org 7000: 6C6F7665D1C6 . need ? / labrange

F23D Mode "attente curseur".

F1AA Affichage du message "SN ERROR".

F1C7 Charger le registre E avec le numéro de l'erreur à créer. Le saut à cette adresse permet d'afficher l'erreur désirée.

Après cet inventaire qui réjouira plus d'un programmeur, nous allons aborder le dernier chapitre de cette seconde partie. Il est consacré aux trois périphériques les plus importants du CANON X-07 : la carte mémoire, l'imprimante X-710 et l'interface PERITELEVISION X-720.

# TROIS PÉRIPHÉRIQUES

Bien que les informations sur les périphériques du CANON X-07 soient assez rares, nous allons quand même vous parler des trois périphériques les plus utilisés : la carte mémoire, la X-710 et la X-720.

## 10.1 Les CARTES MÉMOIRE.

Du point de vue logiciel, bien peu de choses restent à dire, l'interface ayant déjà été abordé dans les chapitres précédents. Deux types de cartes sont disponibles : les cartes comprenant uniquement de la RAM (4 ou 8 Kilo-octets) et les cartes comprenant un programme en ROM (en général, 8 Ko) et 4 Kilo-octets de RAM (dont 3 utilisateur car un kilo-octet est réservé par la carte comme zone de travail).

Pour les techniciens, voici le détail du brochage de ces cartes :

|  PATTE | SIGNAL | PATTE | SIGNAL  |
| --- | --- | --- | --- |
|  1 | VCC1 (Alimentation | 19 | A12  |
|  2 | VCC2 du X-07) | 20 | A11  |
|  3 | NC | 21 | A10  |
|  4 | V+ (Détection LOW BAT.) | 22 | A9  |
|  5 | NC | 23 | A8  |
|  6 | Accès RAM (RAM ON) | 24 | A7  |
|  7 | Niveau bas sélection RAM | 25 | A6  |
|  8 | WR | 26 | A5  |
|  9 | RD | 27 | A4  |
|  10 | Niveau bas sélection ROM | 28 | A3  |
|  11 | D7 | 29 | A2  |
|  12 | D6 | 30 | A1  |
|  13 | D5 | 31 | A0  |
|  14 | D4 | 32 | Masse  |
|  15 | D3 | 33 | Masse  |
|  16 | D2 |  |   |
|  17 | D1 |  |   |
|  18 | D0 |  |   |