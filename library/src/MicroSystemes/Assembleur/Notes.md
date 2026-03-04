INFORMATION ASSEMBLEUR MICROSYSTEME CANON X-07

- Il est prévu pour etre utilisé avec un Canon X-07 equipé d'une carte de 4 Ko
- Le programme doit s'implanter a des adresse precises et risque de ne pas fonctionner avec autre chose.

- Il fonctionne avec un Canon avec carte externe de 4Ko

- Idem avec canon + chip interne de 8 Ko (14940 bytes free au demarrage)

- Il y a des X-07 avec 8 Ko ou 6 Ko en plus ? ? ?
  si on ajoute une puce interne de memoire, il faut basculer l'inverseur à coté
  pour inverser les zones d'adresses entre puce et carte d'extension

- Le programe s'implante entre &H2010 et &H2FF7 [8208 - 12279] soit 4071 octets

- Il est censé se trouver dans la zone de la carte d'extension

- Mais la carte d'extension est entre 3FFF et 1FFF ? ? ?
  Il semble donc etre a cheval entre les deux ?
  En fait il a été implanté sur un Canon avec une autre memoire ! d'ou la confusion !
  
  On peut l'utiliser avec un X-07 equipé d'autre chose mais il faut implanter
  le programme dans la zone prevue sinon il ne fonctionne pas !
  
  On aura des problemes en faisant dir mais le reste fonctionne
  
  peut etre est-ce possible de le trafiquer en ajoutant un fichier fictif
  dans la memoire pour simuler 4Ko d'occupés ?
  
  Il faut reserver suffisamment de memoire par FSET pour que le la zone de RAM
  fichier commence en &H2004 (PEEK &H210 et &H211)
  
  Depuis h2004, le fichier est stocké de la façon suivante:
  [nom:6] [type:1] [longueur:2] [reserve:5] [contenu]
  le contenu commence donc en &H2012
  Les codes du prog commencent donc en &H2010 : on fixe les 2 denier octets
  de la zone reservée à 00. Pourquoi ?
  Peut etre pourcréer un signal de stabilisaion de la liaison audio
  Il aurait fallu la rendre plus longue
    
  le dernier code du programme s'arrette donc en &H2FF7 : juste la fin de la zone RAM fichier
  
  Le chargeur attend le code 76 (&H4C) puis charge uniquement le code du programme
  L'entete du fichier n'est pas modifiée
  
  
 - L'assemblage du code source d'un listing assembleur semble produire l'exécutable
  en &H1C00

- La zone de stockage des fichiers en RAM est la zone la plus haute
- elle est définie par l'instruction FSET
- Valeur par défaut: 13 Octets de 3FFF à 3FF8
-> la fin de la zone est donc 3FF7

RAMEND  - &H212
	RAM fichiers
RAMSTRT - &H210
	Zone pour LM
MEMSIZ  - &H1DF
	Variables (utilisé)
FRETOP  - &H204
	Variables (libre)
STKTOP  - &H1DD
	Pile
STREND  - &H326
	Tableaux
ARYTAB  - &H324
	Variables
VARTAB  - &H322
	Programme BASIC actif
TXTTAB  - &H0B2

Dans la zone RAM fichier, les programes sont stockés de bas en haut
(depuis RAMSTRT vers RAMEND)

d'abord 14 octets d'entete puis les données du programe
Nom      - 6
Type     - 1
Longueur - 2
Reserve  - 5

La zone pour Langage Machine contient par défaut 6 octets
Les 4 octets les plus en haut sont la copie de mot clef de fichier
(derniere date et heure d'extinction)
les 2 autre sont ???

Il est possible de délimiter cette zone par l'instruction clear a,b
a = taille pour variables de chaine: 50 par defaut
b = adresse de début de zone LM

WARNING ! Cette zone est reduite à 6 octets à chaque FSET !

X-O7 face effacée: 0 puce, inverseur vers le bas - 6748 Bytes free
	avec carte XM-100 [4Ko] - 10844 Bytes Free
X-07 [215944] 06 puce Toshiba TC 5565PL-15, inverseur vers le haut - 14940 Bytes free
X-07 [305886] 08 puce Toshiba TC 5565PL-15, inverseur vers le haut - 14940 Bytes free