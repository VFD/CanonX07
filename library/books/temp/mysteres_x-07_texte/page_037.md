70
71

|  D7 D6 D5 D4 D3 D2 D1 DO (Bits)  |   |   |   |   |   |   |   |
| --- | --- | --- | --- | --- | --- | --- | --- |
|  CONTROLE DES INTERRUPTIONS  |   |   |   |   |   |   |   |
|  OFFRQ | SETPS | BIE | ALMIE | XTIE | XRIE | TIE | RIE  |
|  XBTR : STOCKAGE DES INFORMATIONS POUR C.C.U  |   |   |   |   |   |   |   |
|  |   |   |   |   |   |   |   |
|  CONTROLE DE BAUDS - POIDS FAIBLE  |   |   |   |   |   |   |   |
|  |   |   |   |   |   |   |   |
|  CONTROLE DE BAUDS - POIDS FORT  |   |   |   |   |   |   |   |
|  |   |   |   |   |   |   |   |
|  MODES  |   |   |   |   |   |   |   |
|  SETBC | BRGST | CNTR | LEO | MD1 | MDO | BZON | REM  |
|  INTERRUPTION (RESET)  |   |   |   |   |   |   |   |
|  RALRM | CSTB | CSFT | RBGI | RTDRE | RRDRF | RXTRE | RXRRF  |
|  CONFIGURATION de l'UART  |   |   |   |   |   |   |   |
|   | IR | RTS | ER | SBRK | RXE |  | TXEN  |
|  TRANSMISSION SERIE  |   |   |   |   |   |   |   |
|  S2 |  | EP | PEN |  | L1 | B2 | FX04  |
|  CONTROLE de l'UART  |   |   |   |   |   |   |   |
|  |   |   |   |   |   |   |   |

FIGURE 21 : DONNEES ECRITES

|  MD1 | MDO | Mode  |
| --- | --- | --- |
|  0 | 0 | RESET - Le compteur de bauds s'arrête  |
|  0 | 1 | Mode SERIE  |
|  1 | 0 | Mode K7 - Le signal sort sur la prise  |
|  1 | 1 | Le son sort sur le BUZZER  |

FIGURE 22 : MD1 et MD0

## 7.5.1 Le mode ECRITURE

Le schéma représenté par la figure 21 exposent les registres du HD61L202F dans lesquels le NSC 800 écrit les informations.

Voici la signification des symboles utilisés dans cette figure et le détail de l'utilisation de chaque port.

**Le port F0** controle les interruptions. Il faut noter que la modification des données inscrites dans ce port risque de bloquer le CANON X-07. Voici la signification des différents symboles :

- OFFRQ : demande la coupure d'alimentation.
- SETPS : entrée en mode d'alimentation économique (X-07 éteint).
- BIE : le générateur de vitesse est autorisé à émettre des interruptions.
- ALMIE : autorisation des interruptions provenant de l'alarme.
- XTIE : autorisation des interruptions provenant du bus d'extension.
- TIE : autorisation des interruptions provenant de la transmission des données (SERIE).
- RIE : autorisation des interruptions provenant de la réception de données (SERIE).

**Le port F1** stocke les informations transmises au sous-processeur.

Les ports F2 et F3 indiquent les vitesses de transmission. Le compteur de bauds étant codé sur 12 bits, on obtient les 8 bits de poids faible dans le port F2 et les 4 bits de poids fort dans les 4 bits de poids faible du port F3 (Soulignons que les 4 bits de poids fort du port F3 ne servent pas dans ce cas précis...).

**Le port F4** s'occupe du mode des transmissions. Les symboles sont les suivants :

- SETBC : au niveau haut (bit à 1), il permet la mise en place dans le générateur de bauds des informations contenues dans les ports F2 et F3.
- BRGST : au niveau haut, le générateur de bauds compte ... Dès qu'il atteint 0, ce générateur est stoppé.
- CNTR : stockage d'un bit allant être envoyé à la prise parallèle.
- LEO : au niveau haut, le signal de 38,4 KHZ est transmis au coupleur optique.
- MD1 et MD0 : utilisés afin de forcer le mode de transmission comme à la figure 22.
- BZON : un signal est émis par le BUZZER.
- REM : quand ce bit est à 1, le chiffre 1 est placé sur le canal REM.

**Le port F5** sert à réinitialiser les interruptions.