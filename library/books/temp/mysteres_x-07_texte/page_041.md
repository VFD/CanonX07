78
79

21 L'instruction SP READ lit le programme de lancement.

22 L'instruction ON STATE permet d'obtenir le OFF, ON et le SLEEP ON (Bit 0=1 --&gt; OFF,ON / Bit 6=1 --&gt; SLEEP ON).

23 L'instruction OFF REQUEST demande la coupure pure et simple de l'alimentation.

24 L'instruction LOCATE déplace la curseur sur la position spécifiée et affiche le caractère. On note que si "00" est spécifié, le curseur est déplacé mais aucun caractère n'est affiché. On doit faire suivre la commande des coordonnées (X,Y) classiques et du code du caractère à afficher.

25 L'instruction Affichage du Curseur allume le curseur.

26 L'instruction Non affichage du Curseur éteint le curseur.

27 L'instruction TEST KEY permet de tester une touche. Lorsque la ligne d'échantillonnage de touches (K) est spécifiée (2 octets) après la commande, la valeur d'échantillonnage de touches OR est renvoyée. Pour plus de détails, voir la matrice de clavier (figure 25).

28 L'instruction TEST CHR renvoie 0 si la touche du caractère envoyé est enfoncée sinon FFh est répondu. Le caractère spécifié (code ASCII) doit pouvoir être spécifié dans le mode alphanumérique sans utiliser la touche "SHIFT".

29 L'instruction Remise à Zéro des Secondes initialise les secondes.

2A L'instruction Réglage des données de la Date écrit les données de la date.

2B L'instruction Effacement de l'affichage coupe le signal commun de l'écran LCD. La MEV d'affichage peut être lue ou écrite mais son contenu ne sera pas affiché.

2C L'instruction Allumage de l'affichage rétablit l'affichage de l'écran LCD après la commande 2B.

2D L'instruction KEY BUFFER CLEAR vide le registre "tampon de touches", sans affecter UDK et SP.

2E L'instruction CLS permet de "nettoyer" l'écran LCD.

2F L'instruction HOME déplace le curseur à (0,0).

30 L'instruction Affichage de UDK affiche les labels de touches, définies par l'utilisateur, à la ligne 3.

31 L'instruction Non affichage de UDK éteint l'affichage des précédents labels.

32 L'instruction REPEAT KEY ON valide l'entrée répétée.

33 L'instruction REPEAT KEY OFF invalide l'entrée répétée.

34 L'instruction Réglages des caractères KANA assigne les caractères KANA à UDK.

35 L'instruction UDK CONT WRITE ajoute des données... chaine de caractères actuellement assignée à l'une des touches de fonction.

36 L'instruction ALARM READ lit les réglages d'alarme. Son format est le même que la commande 01.

37 L'instruction BUZZER ZERO renvoie 0 si le nombre est 0 sinon renvoie FFh.

38 L'instruction CLICK OFF déclenche la fonction "click".

39 L'instruction CLICK ON enclenche la fonction "click".

3A L'instruction LOCATE CLOSE ramène le curseur dans les limites de défilement lorsque ce dernier a été déplacé hors des limites grâce à la commande 24.

3B L'instruction Validation de Sortie de touche d'unité centrale valide l'entrée de touches.

3C L'instruction Invalidation de Sortie de touche d'unité centrale invalide l'entrée de touches.

3D L'instruction Programme de Lancement provoque l'exécution du programme de lancement dès l'enclenchement de l'alimentation.

3E L'instruction Initialisation du Programme de Lancement provoque l'inexécution du programme de lancement à l'enclenchement de l'alimentation.