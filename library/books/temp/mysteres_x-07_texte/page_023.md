42
43

## 4.3.2 SOUSTRACTION avec et sans CARRY

Nous gardons le même principe que pour l'addition à part une petite exception de syntaxe. En effet, nous avons écrit ADD A,r mais la soustraction sans CARRY se trouve privée de son premier argument : elle s'écrira SUB r, le premier argument étant toujours constitué par le registre A. Nous aurons donc deux instructions notées SUB v et SBC A,v : elles soustraient la valeur v au contenu de l'accumulateur avec, dans le cas de SBC A,v, la valeur du CARRY otée du résultat.

De plus, SUB r et SBC A,r permettent de soustraire le contenu du registre r au contenu de l'accumulateur. Attention !! Si SUB A donne toujours 0, la commande SBC A,A peut donner 0 ou FF (-1 sur le CANON X-07) si le CARRY était égal à 1 avant l'opération.

De plus, il existe aussi les instructions suivantes :

|  SUB (HL) | SBC A,(HL)  |
| --- | --- |
|  SUB (IX + dpi) | SBC A,(IX + dpi)  |
|  SUB (IY + dpi) | SBC A,(IY + dpi)  |

Ici, on soustrait à l'accumulateur le contenu de la case mémoire pointée par l'argument.

Enfin, on a :

|  SBC HL,BC | SBC HL,DE  |
| --- | --- |
|  SBC HL,HL | SBC HL,SP  |

Il n'existe pas de SUB équivalent. L'accumulateur est représenté par le registre HL.

## 4.3.3 INCREMENT et DECREMENT

Ce n'est pas autre chose qu'une addition ou une soustraction d'une unité. Ces instructions sont très utilisées en ASSEMBLEUR et correspondent à INC r et DEC r. Un exemple : LD A,45

DEC A

Après l'instruction DEC A, le registre A contiendra la valeur 44.

Le principe est le même pour les instructions suivantes :

|  INC (HL) | DEC (HL)  |
| --- | --- |
|  INC (IX + dpi) | DEC (IX + dpi)  |
|  INC (IY + dpi) | DEC (IY + dpi)  |

Ici, l'octet contenu dans la case mémoire pointée par le registre en argument se trouve incrémenté ou décrémenté. De plus, sur 16 bits, on découvre les instructions INC rr et DEC rr (avec rr pouvant représenter les registres BC, DE, HL, IX, IY ou SP).

Attention !! Il existe cependant un piège malgré l'apparente désinvolture de ces instructions :

LD HL,FFFF

INC HL

donnera ? ... Eh bien, le registre HL contiendra 0000 et aucun indicateur ne sera positionné !!!

Une dernière chose : il existe un mode d'adressage particulier appelé "implicite". L'instruction sait automatiquement à quel registre elle doit s'adresser ... Cette instruction se nomme DAA et effectue l'ajustement décimal du contenu de l'accumulateur. Voici un petit exemple :

|  LD A,8 | L'accumulateur contiendra la valeur "0E" avant l'instruction  |
| --- | --- |
|  LD B,6 | DAA. Puis, la valeur 14 sera stockée dans le registre A. La  |
|  ADD A,B | commande DAA ajoute 6 au contenu de A si la valeur des 4  |
|  DAA | bits de poids faible dépasse 9.  |

C'est une manière de transformer le binaire en décimal.

## 4.4 Les FONCTIONS LOGIQUES

Toutes ces instructions logiques opèrent implicitement sur le registre A, celui-ci ne figurant pas dans l'opérande.

### 4.4.1 L'instruction AND

Tout d'abord, traçons la table de vérité de cette fonction. Rappelons qu'une table de vérité donne la valeur de l'assertion résultante en fonction des assertions que l'opérateur fait intervenir.

Pour la fonction AND, on obtient :

|  A | B | A AND B  |
| --- | --- | --- |
|  0 | 0 | 1  |
|  0 | 1 | 0  |
|  1 | 0 | 0  |
|  1 | 1 | 1  |

L'instruction AND v effectue le AND logique de l'accumulateur avec la valeur v. Avec les fonctions AND (HL), AND (IX + dpi), AND (IX + dpi), le AND est exécuté avec l'octet pointé par l'opérande.

L'instruction AND r effectue le AND avec un registre. De plus, la commande AND A peut déterminer la valeur qui se trouve dans le registre A. Ainsi, si nous avons LD A,(HL), AND A positionnera les indicateurs en fonction du contenu de l'accumulateur.