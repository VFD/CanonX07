108
109

C5CD
E : charger le registre A avec 1 ou 2.
A : valide ou invalide le programme de lancement.
Si le registre A est égal à 1, le programme de lancement est validé et le CANON X-07 est éteint.
Par contre, si le registre A est égal à 2, le programme de lancement est invalidé et l'alimentation du X-07 est coupée.
S : rien.
M : aucun registre.

C5A6
E : rien.
A : contrôle de BREAKFLAG.
S : Si l'indicateur S est à 1, tous les bits de BREAKFLAG sont remis à 0 et le CANON est éteint.
Si l'indicateur S est à 0, la commande est renvoyée au programme principal.
M : aucun registre.

E327
E : rien.
A : initialisation de la minuterie d'alimentation de 15 minutes en remettant à 0 le bit d'arrêt de minuterie de BREAKFLAG.
S : rien.
M : les registres AF, B.

C62E
E : charger HL avec l'adresse à interroger.
A : la commande C62E contrôle si l'adresse contenue dans HL est bien une adresse de MEV.
S : Si l'adresse est incluse dans la MEV, le drapeau Z est mis à 1. Sinon, le drapeau Z est mis à 0.
M : les registres AF, B.

C59B
E : rien.
A : introduction de l'état SLEEP OFF. SLEEP sauvegarde l'indicateur de piles actuel à l'adresse 226h et le contenu de HL à l'adresse 264h. Puis, l'état SLEEP OFF est introduit.
S : rien.
M : aucun registre.

E8E8
E : rien.
A : interrogation de BREAKFLAG.
S : l'indicateur Z est mis à 1 si un bit quelconque de BREAKFLAG est à 1.
M : le registre AF.

F680
CONT général du système.

D5B0
Cette commande affiche un message sur l'afficheur LCD. Il suffit de charger le registre HL avec l'adresse de la chaîne à afficher. La chaîne doit être terminée par un zéro ou par le code 0D. Utilisation de la zone des chaînes BASIC.

FEF7
Cette commande affiche également un message, comme ci-dessus, mais n'utilise pas la zone des chaînes BASIC. La chaîne doit être également terminée par un zéro.

EBF2
Cette instruction permet d'obtenir l'entrée clavier avec l'affichage du point d'interrogation. En sortie, le registre HL pointe sur l'adresse du tampon d'entrée -1.

EBFF
Cette commande a les mêmes spécifications que l'instruction EBF2 à part que le point d'interrogation n'est pas affiché.

F30D
E : charger le registre DE avec le numéro de ligne à trouver.
A : recherche l'adresse d'une ligne écrite sous BASIC.
S : la ligne est trouvée quand les indicateurs C et Z sont égaux à 1. Alors, le registre BC contient l'adresse de la ligne en question.

FE5E
E : charger le registre A avec une valeur.
A : cette commande évalue de façon entière (nombres &lt; 255) le contenu du registre A (expression, constante ...).
S : le résultat se trouve dans le registre DE et le poids faible dans A. L'affichage de "FC ERROR" peut intervenir si A &gt; 255.

FFCC
Comme ci-dessus, la commande FFCC évalue de façon entière. Le résultat se trouve dans les registres DE et A.