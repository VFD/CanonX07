Tout d'abord, ce listing amène quelques remarques étant donné que chaque ASSEMBLEUR possède ses particularités :

- Cet ASSEMBLEUR utilise l'éditeur BASIC pour l'écriture des routines.
- Chaque routine est précédée du caractère "I" et terminée par le signe "I", ceci pour bien délimiter le champ du programme à assembler.
- Après chaque numéro de ligne, le signe d'apostrophe apparaît. Cela peut paraître contradictoire car, en général, c'est le symbole des lignes de remarques. Ici, le symbole des lignes de commentaires est "*". Le signe d'apostrophe est utilisé par cet ASSEMBLEUR pour différencier les lignes BASIC des lignes à assembler.
- Le point décimal est utilisé à la place de la virgule. De plus, les labels sont symbolisés par deux lettres précédées du signe "*".
- Enfin, le signe "$" assigne la notation hexadécimale à une valeur. De même, le symbole "&amp;" assigne la notation décimale à une donnée.

Nous allons pouvoir passer à l'explication du programme :

- Ligne 0 : titre de la routine.
- Ligne 5 : début de la routine.
- Ligne 10 : fixation de l'origine à l'adresse 4096 en décimal (1000h en hexa).
- Ligne 20 : chargement du registre B avec la valeur 0 (label *DE : début).
- Ligne 30 : chargement du registre HL avec l'adresse $1025 (Les octets qui suivent cette adresse $1025 contiennent les données "POKEES" à partir du programme BASIC).
- Ligne 40 : chargement du registre C avec le nombre de données (Cette valeur est "POKEE" à partir du programme BASIC).
- Ligne 50 : on décrémente le registre C d'une unité.
- Ligne 60 : on incrémente le registre HL d'une unité (label *BB présent).
- Ligne 70 : on incrémente le registre HL d'une unité.
- Ligne 80 : le registre A est chargé avec la donnée contenue dans l'octet pointé par le registre HL.
- Ligne 90 : on décrémente le registre HL.
- Ligne 100 : on compare la donnée pointée par le registre HL à la donnée contenue dans l'accumulateur.
- Ligne 110 : si la donnée pointée par HL est plus petite ou égale à la donnée contenue dans A, on saute au label *AA*.
- Ligne 120 : sinon, on charge le registre D avec la valeur pointée par HL.
- Ligne 130 : on charge l'octet pointé par HL avec le contenu du registre A.
- Ligne 140 : on incrémente HL.
- Ligne 150 : on charge l'octet pointé par HL avec la donnée contenue dans le registre D.
- Ligne 160 : on charge le registre B avec la valeur 1.
- Ligne 170 : on décrémente HL.
- Ligne 180 : le label *AA est présent. On décrémente le registre C.
- Ligne 190 : on saute au label *BB si le registre A n'est pas égal à la donnée pointée par le registre HL

Ligne 200 : sinon, le registre A est chargé avec la valeur contenue dans B.
Ligne 210 : le registre A est comparé à la valeur 1.
Ligne 220 : si le tri est terminé (B=0), alors on retourne au BASIC.
Ligne 230 : sinon, on repart au label *DE pour continuer le tri.
Ligne 240 : fin de la routine ASSEMBLEUR.

## LISTING DESASSEMBLE

Le listing désassemblé est constitué par les codes rentrés en mémoire transformés en mnémoniques. Ce travail est opéré par un DESASSEMBLEUR (Voir annexe 2).

|  Adresse (HEXA) | Adresse (DECIMAL) | Mnémonique  |
| --- | --- | --- |
|  1000 | 4096 | LD B,00  |
|  1002 | 4098 | LD HL,1025  |
|  1005 | 4101 | LD C,(HL)  |
|  1006 | 4102 | DEC C  |
|  1007 | 4103 | INC HL  |
|  1008 | 4104 | INC HL  |
|  1009 | 4105 | LD A,(HL)  |
|  100A | 4106 | DEC HL  |
|  100B | 4107 | CP (HL)  |
|  100C | 4108 | JP NC,1016  |
|  100F | 4111 | LD D,(HL)  |
|  1010 | 4112 | LD (HL),A  |
|  1011 | 4113 | INC HL  |
|  1012 | 4114 | LD (HL),D  |
|  1013 | 4115 | LD B,01  |
|  1015 | 4117 | DEC HL  |
|  1016 | 4118 | DEC C  |
|  1017 | 4119 | JP NZ,1007  |
|  101A | 4122 | LD A,B  |
|  101B | 4123 | CP 01  |
|  101D | 4125 | RET NZ  |
|  101E | 4126 | JP 1000  |

## LISTING du PROGRAMME BASIC

Nous allons utiliser un programme écrit en BASIC pour charger les codes de la routine écrite en langage machine. De plus, ce programme nous permettra de rentrer le nombre de données ainsi que les données une à une. Le tri peut être croissant ou décroissant et les nombres seront affichés dès que vous aurez choisi votre classement.