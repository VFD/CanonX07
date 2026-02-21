34
35

# 2.7 DEFINITION des DONNEES

Une donnée en ASSEMBLEUR peut être constituée par une constante ou une adresse mémoire. On peut définir une donnée ...

## 2.7.1 En DECIMAL

La notation décimale est la plus répandue avec l'hexadécimal. Les données peuvent être signées ou non (Elles peuvent posséder un signe négatif ou positif).

Exemples : LD BC,6000 ; LD A,32 ; LD C,-9 ...

## 2.7.2 En HEXADECIMAL

Suivant l'ASSEMBLEUR utilisé, un signe sera placé devant ou derrière la donnée pour préciser qu'il s'agit d'un nombre hexadécimal. Les symboles peuvent être : $, h, H, \&amp;H, \&amp;...

Exemples : LD IX,22h ; LD A,29h ...

## 2.7.3 En BINAIRE

Cette notation peut commode (comme nous l'avons déjà remarqué ...) s'utilise assez rarement et tous les ASSEMBLEURS ne l'acceptent pas.

Exemples : LD HL,11010001B ; LD SP,11000011B ...

Notez que la lettre "B" spécifie la base du nombre.

## 2.7.4 Sous forme d'un CARACTÈRE ASCII

Ecrire un nombre sous forme ASCII est très ingénieux car la lecture du listing source en est grandement facilitée. On encadre en général le caractère entre deux guillemets.

Exemples : LD B,"A" (équivaut à LD B,65).

## 2.7.5 Sous forme d'un LABEL ou d'un SYMBOLS

Si vous avez la précaution de définir des labels, vous pouvez définir des données "parlantes".

Exemples : LD A,"VALEUR1" ou JP "FIN" ...

# 2.7.6 Sous forme d'une EXPRESSION

Certains ASSEMBLEURS permettent ce genre de désignation. En effet, vous pouvez définir une donnée comme le résultat d'un expression à calculer.

Exemples : LD BC,2*(10-7)+5 AND 17 ; JP DEBUT + 8 ...

# 2.7.7 Sous forme OCTALE

Enfin, la notation octale, très peu utilisée, peut servir à définir une donnée. En effet, la base 8 était très utilisée sur les premiers ordinateurs. Très peu de matériels acceptent dorénavant cette notation.

Exemples (désuets !!) : LD B,640 ; LD A,1010 ...

Notez la lettre "O" désignant la base 8.

Ce chapitre sur la structure intime de l'ASSEMBLEUR s'achève. Vous pouvez vous référer dès maintenant aux programmes du chapitre 6 pour revoir en détail toutes les concepts exposés précédemment.

Après cela, vous pourrez continuer votre quête du savoir en notre compagnie et celle des modes d'adressage...