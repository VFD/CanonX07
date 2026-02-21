104
105

# 9.4 Les ROUTINES MATHEMATIQUES

C9DC
E : charger l'accumulateur avec un nombre.
A : l'accumulateur est converti en son équivalent positif. (Fonction ABS).
S : valeur positive dans A.

CC23
E : charger l'accumulateur avec un nombre.
A : donne la partie entière du nombre stocké dans A. (Fonction INT).
S : la partie entière de l'accumulateur est laissée dans A. Le drapeau 1D9 est actualisé.

# 9.5 Les ROUTINES SYSTEMES

## 9.5.1 Les ReSTarts

RST 00 Correspond au "BREAK POINT" de la carte MONITEUR XP 140F. Un code C9 (RET) est implanté à l'adresse 0000.

RST 08 La routine correspondante est implantée en F52F.
Cette commande compare deux symboles.
Comparaison entre l'octet pointé par HL et l'octet qui suit l'appel par RST 08 :
- Si concordance, retour à RST 08+2 et HL incrémenté.
- Si désaccord, "SN ERROR" s'affiche.

RST 10 La routine correspondante est implantée en F537.
Cette commande examine le symbole suivant. De plus, elle charge dans A le caractère pointé par le registre HL.
En sortie, HL est incrémenté et :
- C=1 si caractère alphanumérique.
- C=0 si caractère alphabétique.

RST 18 La routine correspondante est implantée en C937.
Cette instruction émet un ordre vers le T6834.
A doit contenir le code de commande (Pas de paramètre).

RST 20 La routine correspondante est implantée en EE45.
Cette instruction compare DE avec HL.
- Si HL &lt; DE, C=1.
- Si HL &gt; DE, C=0.
- Si HL = DE, Z=1.

RST 28 La routine correspondante est implantée en E88F.
Cette instruction émet le contenu de A vers le dispositif ouvert, en général l'écran LCD. Tous les registres sont préservés.

RST 30 La routine correspondante est implantée en FC2F.
Cette instruction teste le type de données se trouvant dans A. On a :

|  1D9 | TYPE | FLAGS | A  |
| --- | --- | --- | --- |
|  2 | ENTIER | NC, Z, M | -1  |
|  3 | CHAINE | Z, C, P | 0  |
|  4 | Simple PRE | NZ, C, P | 1  |
|  8 | Double PRE | NZ, NC, P | 5  |

RST 38 La routine correspondante est implantée en E906.
Cette commande calcule l'adresse des tableaux.

## 9.5.2 Les MOUVEMENTS de DONNEES

CA0B
E : charger l'accumulateur avec une donnée en Simple Précision.
A : empile (PUSH) le contenu de A.
Le drapeau 1D9 n'est pas testé.
S : la pile a augmenté d'une donnée.

CA1B
E : charger les registres BC et DE avec des valeurs.
A : le contenu des registres BC et DE transitent vers le registre A.
S : l'accumulateur stocke la nouvelle valeur.

CA26
E : charger le registre A avec une valeur.
A : le contenu de A transite vers les registres BC et DE.
S : les registres BC et DE stockent la nouvelle valeur.