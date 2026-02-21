74
75

- FCAS : ce bit représente le reflet de ce que lit le CANON sur une bande magnétique.
- REM : télécommande du magnétophone.

Le port F6 s'occupe de la gestion des erreurs lors des transmissions sérielles. Voici l'explication des différents symboles :
- CTS : ce bit vérifie le signal CTS du port SERIE. Si le bit CTS est égal à 0 et le bit T*EN égal à 1, les données sérielles sont transmises.
- FE : ce bit est mis à 1 s'il manque un bit de STOP.
- OE : ce bit est mis à 1 si des informations sont reçues avant que le X-07 ait pu lire les précédentes.
- PE : ce bit est mis à 1 en cas d'erreur de parité.
- T*E : ce bit est mis à 1 quand le registre de transmission ne contient pas les informations attendues.
- T*RDY : réception prête.
- R*RDY : transmission prête.

Le port F7 stocke les données sérielles reçues.

Notons que les ports F3 et F5 ne servent à rien présentement.

Avec toutes ces informations, il est possible de réaliser à peu près n'importe quel logiciel de transmission de données.

Il est vrai que les pages décrivant les ports sont un peu techniques donc ardues pour les néophytes. Nous vous conseillons donc de ne pas trop vous attarder sur les ports si vous êtes débutant en ASSEMBLEUR. En effet, il sont plutôt utilisés en programmation avancée et permettent des foules de choses.

La puissance se paie en difficulté de compréhension mais une fois que vous maîtriserez mieux les mystères du CANON X-07, vous pourrez revenir fouiller dans ces ports...

Allons découvrir ensemble le sous-processeur T6834... en détail !!

## 7.6 Le SOUS-PROCESSSEUR "TOSHIBA 6834"

Comme nous l'avons vu précédemment, ce deuxième processeur gère le clavier, l'affichage ainsi que les caractères graphiques, l'horloge, l'alarme, l'alimentation et le contrôle des piles.

Il dispose de 70 commandes transmises par le NSC 800 via le circuit HD61L202F. Ces instructions sont souvent suivies de paramètres et, si nécessaire, le T6834 répond par une suite d'octets.

## 7.6.1 Les COMMANDES ACCESSIBLES

Les commandes accessibles sont très nombreuses (70 exactement) et permettent de multiples réalisations. Elles vous sont données ci-dessous avec quelques explications. Notons que chaque commande possède un code de contrôle à rappeler dès son utilisation dans un logiciel usant de la programmation avec le T6834.

|  CODE (HEXA) | COMMENTAIRES  |
| --- | --- |
|  01 | L'instruction TIME CALL renvoie 8 octets correspondant à l'année (2 octets), le mois, la date, le jour de la semaine, l'heure, les minutes et les secondes.  |
|  02 | L'instruction STICK renvoie un octet correspondant à la touche de curseur enfoncée.
Aucun curseur enfoncé : 30 est renvoyé.
Curseur haut enfoncé : 31 est renvoyé.
Curseur droit enfoncé : 32 est renvoyé.
Curseur gauche enfoncé : 37 est renvoyé.
Curseur bas enfoncé : 36 est renvoyé.  |
|  03 | L'instruction STRIG renvoie 0 si la touche F6 est enfoncée sinon elle renvoie FFh.  |
|  04 | L'instruction STRIG1 renvoie 0 si la barre d'espace est enfoncée sinon elle renvoie FFh.  |
|  05 | L'instruction RAM READ permet au NSC 800 de lire la mémoire du T6834. Lorsque les octets haut et bas de l'adresse sont spécifiés après la commande, le contenu de l'adresse est envoyé à l'accumulateur.  |
|  06 | L'instruction RAM WRITE permet au NSC 800 d'écrire des données dans la mémoire réservée au T6834. Lorsque les octets haut et bas de l'adresse sont spécifiés après la commande, les données sont écrites à l'adresse spécifiée de la mémoire du T6834.  |
|  07 | L'instruction SCROLL SET, suivie de deux octets, fixe la première et la dernière ligne de roulement de l'écran LCD.  |
|  08 | L'instruction SCROLL EXET utilisée sans paramètre fait dérouler l'écran. On note que le curseur ne bouge pas.  |
|  09 | L'instruction LINE CLEAR efface la ligne spécifiée par l'octet suivant la commande.  |