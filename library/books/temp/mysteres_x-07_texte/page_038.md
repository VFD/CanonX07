72
73

|  D7 | D6 | D5 | D4 | D3 | D2 | D1 | DO (Bits)  |
| --- | --- | --- | --- | --- | --- | --- | --- |
|  TRO1 | TRQ0 | BIE | ALMIE | XTIE | XRIE | TIE | RIE  |
|  XBRR : STOCKAGE DE DONNEES VENANT DU C.C.U  |   |   |   |   |   |   |   |
|  DRAPEAUX  |   |   |   |   |   |   |   |
|  CBSY | ALRM | AUX1 | AUX2 | 0 | BGI | XTRE | XRRE  |
|  MODE  |   |   |   |   |   |   |   |
|  FCAS | BRGST | CNTR | LEO | MD1 | MDO | BZON | REM  |
|  STATUS  |   |   |   |   |   |   |   |
|  CTS, |  | FE | OE | PE | TXE | RXRDY | TXRDY  |
|  RECEPTION DES DONNEES SERIE  |   |   |   |   |   |   |   |

FIGURE 22 : DONNEES LUES

Le port F6 controle l'UART donc la transmission et la réception série. Voici la description des symboles :

- IR : initialisation de l'UART.
- RTS : transmission du signal de contrôle quand ce bit se trouve à 1. La patte RTS du HD61L202F est mise à 0.
- ER : initialisation des drapeaux d'erreurs (PE, OE et FE).
- SBRK : la transmission du chiffre 0 est forcé même si des données sont présentes quand ce bit est à 1.
- R*E : autorise la réception s'il est mis à 1. S'il est mis à 0, la réception n'est pas autorisée.
- T*EN : autorise la transmission s'il est mis à 1. S'il est mis à 0, la transmission n'est pas autorisée.

Le port F7 stocke les données allant être transmises.

## 7.5.2 Le mode LECTURE

Les ports où se trouvent les informations sont lus par le NSC 800. Reportez-vous à la figure 23 pour les détails. Voici les explications port par port ...

Le port F0 controle toujours les interruptions. Seulement deux bits ont une signification différente :

- TRQ0 : ce bit est mis à 1 si la touche BREAK est enfoncée.
- TRQ1 : si ce bit est mis à 1 par le T6834, le NSC 800 ne peut entrer en mode "sauvegarde".

Le port F1 stocke les informations transmises par le T6834.

Le port F2 contient des drapeaux informant le NSC 800 des différents états du CANON X-07. Voici la signification de ces divers symboles :

- CBSY : ce bit est mis à 1 par le signal indiquant que le port parallèle est occupé.
- ALRM : ce bit controle l'état des piles. Il est d'ailleurs passé au crible toutes les quatre minutes par le sous-processeur. S'il se trouve à 1, les piles sont épuisées.
- AUX2 : contrôle de la pile d'une carte mémoire insérée dans le X-07.
- AUX1 : ce bit est mis à 0 quand l'interrupteur de la prise d'extension est placé sur la position "RAM".
- BGI : ce bit est accordé au signal de sortie du générateur de bauds.
- XTRE : ce bit est mis à 1 quand le T6834 lit le registre XBTR.
- XRRF : ce bit est mis à 1 quand le T6834 écrit dans le registre XBRR.

Le port F4 fonctionne exactement comme en mode écriture sauf pour deux signaux décrits ci-après :