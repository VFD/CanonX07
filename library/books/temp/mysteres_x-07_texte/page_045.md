86
87

# MMEMORIOUES

# COMMENTAIRES

PUSH AF
Sauvegarde du registre AF

PUSH DE
Sauvegarde du registre DE

PUSH BC
Sauvegarde du registre BC

LD C.$F1
C - Numéro du port de sortie

CALL $CDC9
Sous-processeur PRET ?

LD A.($26C)
Chargement du registre A

OR $80
Comparaison de A avec le code $80

OUT ($F0).A
Sortie de A sur le port $F0

OUT (C).E
Sortie de E sur le port $F1

LD A.$2
Chargement de A avec le chiffre 2

OUT ($F5).A
Sortie de A sur le port $F5

POP BC
Récupération du registre BC

POP DE
Récupération du registre DE

POP HL
Récupération du registre HL

RET
RETOUR AU BASIC

# UNE PETITE DEMONSTRATION...

5 REM programme BASIC implantant une routine en LANGAGE MACHINE contenant une démonstration ...

10 CLS : PRINT "Je charge les codes ... Un instant, SVP !"
20 FOR X = &amp;H1C00 TO &amp;H1C3E
30 READ A$ : POKE X,VAL ("&amp;H" + A$)
40 NEXT X
45 REM données de la routine LANGAGE MACHINE
50 DATA CD, 9E, CE, 1E, 15, CD, 25, 1C
60 DATA 1E, 3C, CD, 25, 1C, 1E, 0F, CD
70 DATA 25, 1C, 1E, 0A, CD, 25, 1C, 06
80 DATA FF, 1E, 2B, CD, 25, 1C, 1E, 2C
90 DATA CD, 25, 1C, 10, F4, F5, C5, D5
92 DATA 0E, F1, CD, C0, C9, 3A, 6C, 02
95 DATA F6, 80, D3, F0, ED, 59, 3E, 02
98 DATA D3, F5, D1, C1, F1, C9, 00, 00

# BASIC &amp; ZONE SYSTEME

Ce chapitre va être consacré à l'étude de trois secteurs importants du CANON X-07 : le codage en mémoire du BASIC, les points d'entrée en mémoire morte des fonctions BASIC et la zone de travail système.

En effet, pour pouvoir programmer efficacement en langage machine, il vous faut connaître la structure interne du BASIC. Les fonctions BASIC font très souvent appel à des routines préprogrammées qui vous serviront dans vos logiciels écrits en ASSEMBLEUR.

# 8.1 La MEMOIRE VIVE.

Nous allons étudier le codage du langage BASIC MICROSOFT en mémoire vive. En effet, vous vous demandez sûrement comment sont stockées les fonctions et les instructions du BASIC après que avoir tapé sur la touche "RETURN".

La programmation en BASIC obéit à des règles très strictes. Tout est structuré impeccablement pour que le NSC 800 puisse exécuter n'importe quelle ligne du programme quand vous le lui demandez.

L'adresse de départ des programmes BASIC est 1363 en décimal. De l'adresse 0 à 1362 se trouve la zone système que nous étudierons en détail au paragraphe 8.3.

Chaque fonction BASIC (PRINT, GOTO, THEN...) possède un code distinctif compris entre 80h et FEh. Chaque ligne est séparée d'une autre par le code 0. Nous allons "PEEKER" ensemble à partir de l'adresse 1363 après avoir entré le petit programme suivant :

1 REM **
200 CLS : A$-"C7"
9999 PRINT "END","C7":END

|  ADRESSES | CODE | INSTRUCTIONS | COMMENTAIRES  |
| --- | --- | --- | --- |
|  1363 | 92 | INDICATEUR | Cet indicateur se trouve au début de chaque ligne et indique l'adresse de la prochaine ligne. (Ici : 92-256*5 = 1372)  |
|  1364 | 05 |  |   |
|  1365 | 01 | N° de LIGNE | Codé sur 2 octets. Ici, on a donc 1-256*0 = 1 - ligne 1.  |
|  1366 | 00 |  |   |
|  1367 | 142 | REM | Code de la fonction BASIC REM.  |
|  1368 | 32 | ESPACE | Code ASCII de l'espace.  |