20
21

"10101111" en binaire peut être facilement transcrit en hexadécimal. En effet, la première tranche "1010" constitue 4 bits et la deuxième tranche "1111" constitue 4 autres bits. Par conséquent, en s'aidant de la figure 3, "1010" équivaut à "E" et "1111" équivaut à "F". En définitive, "10101111" équivaut à "EF" en hexadécimal!

De même, "10111000" équivaut à "B8" en hexadécimal car "1011" est équivalent à "B" et "1000" à "8". Simple, non?

De plus, signalons que la technique est la même pour un mot de 16 bits. Par conséquent, "111111111111111" équivaut à "FFFF" en hexadécimal.

La notation hexadécimale est beaucoup plus claire que la notation binaire. Effectivement, mieux vaut travailler avec "FFFF" qu'avec "111111111111111"!

Notons, pour terminer, que le "haut" de la mémoire, précédemment désigné par "65535", est également représenté par "FFFF".

## 1.6 Le MICRO-PROCESSEUR

Le NSC 800 de votre CANON X-07 constitue véritablement le "Dieu tout-puissant". C'est lui qui ordonne, organise et planifie toutes les opérations effectuées à chaque instant au sein de votre machine.

Au niveau "HARD", il est formé d'un minuscule circuit intégré rassemblant plusieurs milliers de transistors sur une pastille de SILICIUM.

Il faut savoir que la rapidité et la puissance d'un ordinateur dépendent principalement du processeur employé. Le NSC 800 est un micro-processeur 8 bits relativement obsolète : il est donc tout à fait normal qu'il soit dépassé du point de vue vitesse de traitement, par exemple. En effet, de nouveaux micro-processeurs 16/32 bits équipant la nouvelle génération d'ordinateurs domestiques, se révèlent des plus puissants et des plus véloces (le MOTOROLA 68000, entre autres ...). Pour pallier cette "vieillesse", des co-processeurs (un T6834 pour le X-07) déchargent le processeur principal d'une partie des taches pour gagner en vitesse (Voir la deuxième partie de cet ouvrage).

Gageons que la société CANON nous réserve de bonnes surprises pour l'année 1986...

Enfin, chaque type de micro-processeur possède son architecture propre. Nous allons étudier en détail la structure du NSC 800.

## 1.7 ARCHITECTURE du NSC 800

### 1.7.1 Les REGISTRES

Les registres sont constitués par des mémoires rapides qui servent soit de "cahier de brouillon" au micro-processeur, soit de repères.

Il en existe 13 plus 8 autres appelés "registres secondaires". Certains sont constitués de 8 bits, d'autres de 16 bits (N'oublions pas qu'il existe 16 fils reliant le NSC 800 à la mémoire) et d'autres peuvent être "accolés" pour former des registres de 16 bits (ou "doubles registres").

Pour mieux appréhender cette importante notion, vous pouvez vous référer à la figure 5.

Le registre A, appelé aussi "L'ACCUMULATEUR", constitue le registre le plus important. Beaucoup d'opérations transitent par cette mémoire et, de plus, il garde la majeure partie du temps le résultat des opérations. Vous en appréhenderez l'importance bientôt.

Le registre F est un peu spécial car c'est le registre des drapeaux (en anglais, "drapeau" se traduit par "FLAG" d'où le registre F). On y trouve des indications sur le résultat ou le type d'une opération. Ce registre sera passé "au peigne fin" au paragraphe 1.7.3.

Les registres B, C, D, E, H et L sont formés de 8 bits. Ils peuvent fort bien constituer des registres de 16 bits dont les noms seront BC, DE et HL. On pourra ainsi travailler directement sur des mots de 16 bits, ce qui est beaucoup plus rapide que de répéter deux fois la même opération sur deux mots de 8 bits.

Les deux registres IX et IY, formés de 16 bits, se nomment "registres d'adressage indexé". En fait, ils se révèlent d'une grande utilité bien que d'un usage relativement restreint. Pour les utiliser, il faut y stocker une valeur de base à laquelle on ajoute un index (nombre de 8 bits) afin d'obtenir la valeur désirée. Ne paniquez pas, nous expliciterons ceci au chapitre 3.6.

Le registre SP est lui aussi un registre 16 bits. Pour expliquer son utilité, il nous faut d'abord exposer la notion de "PILE". Lorsque le NSC 800 exécute un programme, il peut avoir besoin de sauvegarder des données. Par exemple, s'il doit exécuter un sous-programme puis retourner au programme principal, il rangera à un endroit précis les données du programme principal, exécutera le sous-programme, récupérera les données précédemment sauvées puis reviendra au programme principal.

En fait, ranger les données s'appelle "EMPILER" et les retrouver "DEPILER". La pile est donc une zone de la mémoire où le NSC 800 ira ranger les données à sauvegarder "l'une au-dessus de l'autre".