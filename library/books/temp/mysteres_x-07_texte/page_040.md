76
77

0A
L'instruction TIME SET règle le temps. Les éléments du temps (seconde, minute, heure, jour, date, mois et année) sont envoyés séquentiellement après l'instruction. A noter que l'année est codée sur deux octets.

0B
L'instruction Calcul et Réglage du jour de la semaine pose le jour de la semaine correspondant à la date réglée via la commande TIME SET.

0C
L'instruction Réglage des données d'Alarme pose les données de l'alarme. Cette commande est programmée de la même façon que la commande 0A. On note que le deuxième paramètre spécifié n'a aucune signification.

0D
L'instruction BUZZER OFF fait cesser le BUZZER lorsque l'heure d'alarme est atteinte.

0E
L'instruction BUZZER ON fait retentir le BUZZER lorsque l'heure d'alarme est atteinte.

0F
L'instruction Transfert de Bit IMAGE sort la ligne spécifiée de l'écran LCD sous le format "bit image" (120 octets). Le chiffre (compris entre 0 et 3) suivant la commande constitue le numéro de ligne.

10
L'instruction POINT teste la présence d'un point allumé sur l'écran LCD. Le chiffre 0 est renvoyé si un point se trouve aux coordonnées (X,Y) sinon FFh est renvoyé.

11
L'instruction PSET allume le point de coordonnées (X,Y).

12
L'instruction PRESET éteint le point de coordonnées (X,Y).

13
L'instruction PEOR inverse le point de coordonnées (X,Y).

14
L'instruction LINE allume tous les points d'une ligne comprise entre les coordonnées (X₁,Y₁) et (X₂,Y₂). Donc, 4 octets doivent maintenant suivre la commande dans un ordre X₁, Y₁, X₂, Y₂.

15
L'instruction CIRCLE trace un cercle de rayon r autour du centre de coordonnées (X₁,Y₁). Les données devant suivre la commande sont X₁, Y₁ et r.

16
L'instruction USER DEFINE KEY WRITE assigne des définitions aux touches de fonction F1 à F12. On spécifie après la commande le nombre UDK (1 à 12), la chaîne constituant la définition (les 3 caractères de repérage et 38 caractères effectifs) et la chaîne '00' indiquant la fin. On peut noter que 42 caractères effectifs peuvent être programmés avec les touches F6 et F12.

17
L'instruction USER DEFINE KEY READ est utilisée par le NSC 800 pour lire les touches définies par l'utilisateur. Lorsque le nombre UDK est spécifié, 255 caractères sont renvoyés à partir de l'adresse de début du codage.

18
L'instruction UDK ON provoque le début d'envoi de UDK par le T6834.

19
L'instruction UDK OFF provoque l'arrêt d'envoi de UDK par le T6834.

1A
L'instruction USER DEFINE CHARACTER WRITE permet de définir des caractères affichables pour les codes de caractères 80 à 9F et 80 à FF. Il faut introduire le code du caractère et 8 octets de données de caractères (6 points horizontalement * 8 points verticalement) après la commande.

1B
L'instruction USER DEFINE CHARACTER READ est utilisée pour lire les définitions de la commande 1A. Les codes de caractères doivent se situer entre 20h et FFh.

1C
L'instruction UDC INT renvoie à UDC.

1D
L'instruction START PROGRAM WRITE définit un logiciel de lancement pouvant atteindre 511 octets. Le début du programme est posé à l'adresse de départ lorsque les données de chaîne et une terminaison ('00') sont introduites après la commande.

1E
L'instruction SP WRITE CONT écrit après la commande 1D.

1F
L'instruction SP ON permet l'exécution du programme de lancement.

20
L'instruction SP OFF invalide le programme de lancement.