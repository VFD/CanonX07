Basic étendu ( 4221 pas de programme )
tiré du magazine Hebdogiciel N°156

	Augmentez efficacement et à moindre frais les performances de votre Basic.

Mode d'emploi :
	En règle générale, n'oubliez pas que le signe "\" correspond au signe "yen" qui s'obtient par "?" en mode GRPH.
	Videz la mémoire fichier si celle-ci est occupée et sauvegardez le listing 1 de la manière suivante 
FSET 2048:SAVE "logeLM
	Tapez ensuite et lancez le listing 2 pour l'implantation du langage machine ( le listing 3 contient à titre indicatif la routine désassemblée ). Un "bip" grave signale la présence d'une erreur éventuelle. Cette dernière dans les sommes de contrôles, les lignes 30 et 40 sont listées, sinon l'ordinateur indique la ligne erronnée. Le langage machine en mémoire, le Canon s'éteint. A l'allumage, le message contenu dans START$ initialise les fonctions. Si vous faites DIR, vous devez obtenir :
LogeLM P BasicE D
2048/367
	L'originalité de ce programme réside dans le fait qu'il se reloge selon le mouvement de la mémoire fichier. Toutefois, la fonction FSET s'utilise différemment et c'est là qu'intervient le fichier "LogeLM". Pour réserver N octets, il faut faire :
SLEEP:FSET n:RUN"LogeELM
	Ainsi, SLEEP supprime les nouvelles fonctions et RUN "LogeLM reloge la routine et réinitialise le START$ en éteignant la machine par OFF1. Si dans un autre cas vous perdez accidentellement le contenu de START$, RUN "LogeLM le réçinitialise. Ce petit inconvénient est largement compensé par les avantages incontestables des nouvelles fonctions que voici :
- vitesse d'affichage améliorée : très utile, vérifiez cette rapidité par DIR, LIST ou PRINT "message...". Le curseur est parfois un peu perturbé lors d'un LIST @ ou d'un LINEINPUT, mais l'appui sur une touche remet tout en ordre.
- PAINT x,y : échange le contenu des variables x et y ( SWAP ), exemple : A=3:B=2:PAINT A,B nous donne B=3 et A=2.
	A$="+":B$="*":PAINT A$,B$ nous donne A$="*" et B$="+". Celà marche également avec des tableaux. Attention, si ce sont des chaines, le "$" est obligatoire pour le terme de gauche, même s'il y a eu l'ordre DEFSTR, exemple : DEFSTR A,B:A$="+":B="*":PAINT A$,B ou bien PAINT B$,A
- COLOR "xxxx" : protège le Canon avec le mot de passe "xxxx", exemple : COLOR "TOTO". Lorsque vous utilisez cette fonction, le Canon s'éteint et au rallumage, vous disposez d'environ 4 secondes pour entrer le mot de passe ( les lettres tapées ne s'affichent pas ). Le temps écoulé et le mot incorrect, l'ordinateur retourne à son sommeil. Donc, n'oubliez pas le mot de passe sous peine de devoir user d'un RESET destructeur, car OFF et ON sont inopérants.
- CIRCLE : GOTO, GOSUB, RESTORE et RESUME acceptent des expressions algébriques, exemple :
	X=10:CIRCLE GOTO X
	X=10:CIRCLE GOSUB X*10
	X=10:CIRCLE RESTORE X+2+X
	X=10:CIRCLE RESUME 2*X+3+LOG(X)/LOG(10)
	équivaut à GOTO 10, GOSUB 100, RESTORE 110, RESUME2001. Aucune modification de CIRCLE(x,y),z qui trace toujours un cercle.
- PSET ON et OFF : MERGE 2 programmes, exemple : sauvez la ligne 10 GOTO 0 en RAM par SAVE "ESSAI", puis faites NEW. Tapez la ligne 0?"*HEBDOGICIEL*" et FAITES PSET ON. Le curseur s'affiche, chargez alors par LOAD "ESSAI votre 1er programme sauvegardé et faites PSET OFF. Vos 2 programmes se trouvent "mergés" ( vérifiez par LIST ). Veillez toutefois à ce que les N° des lignes du programme à coller, soient strictement supérieurs à ceux des lignes du programme déjà en mémoire. Aucune modification de PSET (x,y) qui allume toujours un point.
- PRESET @ ou [ valeur intiale, valeur finale,, incrément : affiche des valeurs entières et permet des boucles d'affichage ultra-rapide, exemple : PRESET @ A écrit le contenu de A ( compris entre -32767 et 32768 ) sans laisser d'espace avant et après le résultat. PRESET @ 0,1000,2 ou PRESET @0 TO 1000 STEP 2 écrit une boucle de 0 à 1000 avec  un incrément de 2 ( qui est de 1 par défaut ). PRESET [15,0,-1 ou PRESET [15TO0STEP-1 écrit une boucle de 15 à 0 avec un décrément de 1. Pour utiliser des nombres négatifs ( par exemple de -1 à -100 ), il faut faire : ?"-";:PRESET @1,100 ou ?"-";PRESET @1TO100. Sachez que toutes les valeurs peuvent être des expressions algébriques qui ne doivent pas être inférieures à -32767 et supérieures à 32768. Aucune modification de PRESET (x,y) qui efface toujours un point. 
- LINE : relie plus de 2 points ensemble, exemple : LINE (0,0)-(119,0)-(0,31)-(0,0). Aucune modification de LINE INPUT.
	Vous sont offerts gracieusement 7 courts programmes de démonstration :
BLITZ : afin d'atterrir, bombardez des immeubles par espace. Niveau de difficulté croissant.
LOTO : tirage speedé de 6 numéros avec minimum de graphisme.
CLASS : classe des mots par ordre alphabétique.
HHMMSS : donne l'heure avec les centièmes de seconde.
PASS : initialise une touche de fonction pour déclencher un mot de passe.
DECI : donne les décimales à l'infini d'une fraction de 2 nombres entiers.
COMPTE : vous fait jouer au jeu "le compte est bon".
