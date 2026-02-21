Ensuite, la phase d'assemblage proprement dite débute. Elle est divisée, en général, en deux parties appelées des "PASSES".

La première PASSE examine consciencieusement le code source entré en mémoire et détermine la longueur de chaque instruction. En effet, la longueur d'une instruction peut varier de 1 à 4 octets (ex : RET occupe un octet et JP 4000 en occupe trois ...). De plus, une table des labels rencontrés est construite et la syntaxe du code source est minutieusement contrôlée.

La deuxième PASSE permet à l'ASSEMBLEUR de générer le code objet de chaque instruction. De plus, une adresse réelle est affectée à chaque label ou symbole.

Nous allons maintenant étudier le format du code source, équivalent de nos lignes BASIC.

## 2.5 FORMAT du CODE SOURCE

Le code source est constitué de lignes écrites les unes à la suite des autres. Chaque ligne possède deux types de formats :

- Le format FONCTIONNEL, traité par l'ASSEMBLEUR, se compose de quatre champs distincts : LABEL, OPERATION, OPERANDE, COMMENTAIRE.

- Le format COMMENTAIRE débute par un caractère précis (; ou ' en général). Les lignes "commentaires" sont uniquement destinées à documenter le listing source. Elles correspondent aux lignes débutant par un "REM" en BASIC.

Voici un exemple de "lignes source" :

EXEMPLE

FIN JP 4000 On saute à la fin du programme

Champs : label/opération/opérande/commentaire

La première ligne est une ligne de commentaires et la deuxième est fonctionnelle. Sous chaque instruction, le type du champ est défini. À partir de cela, nous allons étudier les particularités de chaque champ.

## 2.5.1 Le champ LABEL

Ce champ débute toujours en première position de la ligne source par un caractère spécial (ex : #). Il est formé de caractères numériques ou alphabétiques, sans espace. Sa longueur est déterminée par les performances de l'assembleur utilisé. En général, ce champ se termine par le séparateur BASIC ";".

Ce champ label se révèle optionnel à l'usage : on peut très bien s'en passer bien que l'utilisation de labels clarifie le programme.

Exemples de LABELS : #EV, #1, #DEBUT ...

## 2.5.2 Le champ OPERATION

Ce champ commence immédiatement après le champ LABEL si celui-ci est présent. Il est toujours obligatoire dans le format fonctionnel et se compose d'une instruction ou d'une pseudo-instruction (Voir chapitres 4 et 5).

Exemples : CALL, LD, JP, RET ; ORG, DEFM ...

## 2.5.3 Le champ OPERANDE

Ce champ est pratiquement toujours présent (sauf dans le cas de certaines instructions telles RET, NOP ou HALT...) et lié au type d'opération effectué immédiatement avant.

Ce champ peut comporter un ou deux arguments suivant le cas. Par exemple, RET N2 est un opérande comprenant un argument (NZ) et LD A,B en comprend deux (A et B).

Chaque argument peut adopter l'une des significations suivantes :

- Une adresse.
- Un pointeur adresse.
- Un registre.
- Un pointeur registre.
- Une donnée.
- Un mot-clé de condition.

Ces différents types d'argument vont être détaillés dans le paragraphe 2.6.

## 2.5.4 Le champ COMMENTAIRE

Le champ "commentaire" doit obligatoirement être placé après le champ opérande.

Il est signalé à son début par un caractère spécial du style "" ou ";". Ce champ est optionnel et permet une meilleure documentation du listing source.