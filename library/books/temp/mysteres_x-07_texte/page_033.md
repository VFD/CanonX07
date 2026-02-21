10 ' TRI CROISSANT ET DECROISSANT
20 ' NOMBRES POSITIFS INFERIEURS A 255
30 DATA 6,0,21,25,10,4E,D,23,23,7E,2B,BE,D2,16,10,56,77,23,72,6,1,2B,D,C2,7
40 DATA 10,78,FE,1,C0,C3,0,10 : RESTORE 30 : FOR I=4096 TO 4128 : READ A$
50 POKE I,VAL ('&amp;H'«A$) : NEXT I
55 CLS : CLEAR 50,4050 : INPUT "Nombre de données ";N : POKE &amp;H1025,N
60 FOR I=&amp;H1026 TO &amp;H1025+N : BEEP 9,2 : PRINT "Donnée";I-&amp;H1025;
INPUT A
70 POKE I,A : NEXT I
80 CLS : EXEC &amp;H1000 : PRINT "(C)roissant ou ...(D)écroissant...""
90 G$=INKEY$ : IF G$="D" THEN 120
100 IF G$&gt; "C" THEN 90
110 CLS : FOR I = &amp;H1026 TO &amp;H1025+N : PRINT PEEK(I); : NEXT I : BEEP 9,2 :
END
120 CLS : FOR I=&amp;H1025+N TO &amp;H1026 STEP -1 : PRINT PEEK(I); : NEXT I :
BEEP 9,2 : END

Ce petit programme va vous être explicité ci-dessous :

Ligne 10 : commentaire.
Ligne 20 : commentaire.
Ligne 30 : données concernant la routine en L.M.
Ligne 40 : fin des données. Boucle permettant de charger les codes en mémoire, de l'adresse 4096 à 4128.
Ligne 50 : fin de la boucle.
Ligne 55 : le nombre de données est demandé. Cette valeur est "POKEE" à l'adresse &amp;H1025. Le CLEAR permet de réserver de la place pour la routine écrite en ASSEMBLEUR.
Ligne 60 : entrée des différentes données.
Ligne 70 : stockage de ces données en mémoire.
Ligne 80 : le tri est lancé au moyen de la commande EXEC.
Ligne 90 : pour un tri décroissant, on va en ligne 120.
Ligne 100 : contrôle des entrées.
Ligne 110 : affichage du tri croissant.
Ligne 120 : affichage du tri décroissant.

Voilà !! Cette application type vous permet de juger de la rapidité du langage machine par rapport au BASIC. Vous serez sans doute surpris de noter la surprenante vélocité de ce tri : à peine avez-vous tapé sur la lettre "D" ou "C" que les nombres triés s'affichent à l'écran !!

De nombreuses autres applications vous attendent tout au long de la troisième partie de ce livre. Mais, avant de vous lancer à corps perdu dans les nombreux programmes que nous vous avons concocté, la deuxième partie de cet ouvrage va vous entrainer au cœur même de votre CANON X-07. En effet, vous allez découvrir ses recoins les plus cachés ...

![img-0.jpeg](img-0.jpeg)

POYAGE AU COEUR DU

CANON X-07