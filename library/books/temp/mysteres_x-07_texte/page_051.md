C18A
E : charger le registre A avec le code ASCII du caractère à afficher.
A : affiche le contenu de A sur la position du curseur et fait avancer le curseur.
S : rien.
M : aucun registre.

C0A1
E : charger le registre A avec la valeur 0 ou 1.
A : si le registre A est égal à 0, le curseur est affiché sur l'écran LCD. Par contre, si le registre A est égal à 1, le curseur disparaît.
S : rien.
M : les registres AF, BC, DE.

9.1.4 L'IMPRIMANTE

CFB7
E : rien.
A : initialise l'imprimante parallèle --&gt; Mode texte, taille 2, couleur 0.
S : rien.
M : les registres AF, BC, DE, HL.

CFB0
E : rien.
A : émission des codes de contrôle LF + CR vers l'imprimante parallèle.
S : rien.
M : les registres AF, BC, DE, HL.

CEF7
E : charger le registre A avec l'octet à émettre.
A : émission du contenu de A vers l'imprimante. Les indicateurs BUSY et BREAK sont testés.
S : rien.
M : les registres AF, BC, DE, HL.

CF11
E : charger le registre A avec un caractère.
A : envoie le contenu du registre A vers le point d'accès parallèle.
S : aucun.
M : les registres AF, B, E.

9.1.5 Le sous-processeur T6834

E428
E : le registre A contient l'octet à émettre.
A : émission vers le T6834 d'une commande sans paramètre.
S : rien.
M : les registres AF, C.

C92F
E : le registre A contient le code de la commande, HL contient le pointeur de la zone où sont stockés les paramètres, B contient le nombre de paramètres, C contient le nombre d'octets constituant la réponse, DE contient l'adresse du tampon retour (En général, la valeur 26E).
A : émission d'un ordre avec paramètres vers le T6834.
S : réponse pointée par le registre DE.
M : les registres AF, BC, HL. De plus, le bit 7 de A doit être positionné si B est nul, c'est-à-dire s'il n'y a pas de paramètre.

C0BD
E : rien.
A : vide les tampons clavier et sous-processeur.
S : rien.
M : le registre AF.

E348
E : le registre HL doit être chargé avec une adresse de MEV du T6834.
A : lit un octet pointé par HL dans la MEV du T6834.
S : le registre A contient les données revenant du T6834.
M : les registres AF, BC, DE.

E334
E : le registre HL est chargé avec une adresse de MEV contenue dans la MEV du T6834, le registre A contient les données à écrire dans la MEV du T6834.
A : écriture d'un octet contenu dans A à l'adresse de la MEV du sous-processeur contenue dans HL.
S : rien.
M : les registres AF, DE, BC.

9.1.6 Les ROUTINES GENERALES

C39D
E : rien.
A : initialisation des points d'accès parallèle, série, optique, imprimante et cassette.
S : rien.
M : les registres AF, BC, DE.

CF2A
E : rien.
A : contrôle des bits d'état. Attente du passage de la borne BUSY du point d'accès parallèle à l'état bas. Contrôle des bits OFF, BREAK, piles épuisées.
S : rien.
M : le registre AF.

98
99