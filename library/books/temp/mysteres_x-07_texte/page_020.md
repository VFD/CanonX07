36
37

# LES DIVERS MODES D'ADRESSAGE DU NSC 800

Les modes d'adressage représentent les différents moyens d'accéder à une donnée. Ils facilitent considérablement l'écriture d'un logiciel tout en augmentant sa vitesse d'exécution. Le NSC 800 en possède sept explicités ci-dessous.

## 3.1 L'ADRESSAGE IMMEDIAT

Il constitue l'adressage le plus simple que vous puissiez rencontrer. En effet, il correspond à l'exemple précédemment évoqué "JP 4000". Il convient uniquement de fournir l'adresse après la commande. Ainsi, charger le registre A avec le chiffre 9 s'écrit "LD A.9" (LD signifiant "Load", c'est à dire charger en français).

## 3.2 L'ADRESSAGE REGISTRE

On part du principe que l'opérande se trouve dans un des registres du NSC 800. On obtiendra ainsi "LD A.B" (charge le registre A avec le contenu du registre B) mais aussi "JP HL" (saute à l'adresse contenue dans le registre HL).

## 3.3 L'ADRESSAGE INDIRECT REGISTRE

On utilise un registre afin de pointer sur une adresse mémoire. Par exemple, l'instruction "LD A. (HL)", avec HL contenant la valeur 4000h, chargera dans l'accumulateur la valeur se situant à l'adresse 4000h. Notez que les parenthèses marquent cette indirection.

## 3.4 L'ADRESSAGE DIRECT

Il fonctionne de la même manière que l'adressage indirect registre. Mais, au lieu de placer l'adresse dans un registre, on la donne directement. Ainsi, "LD A. (5000)" chargera dans le registre A la valeur située à l'adresse 5000.

## 3.5 L'ADRESSAGE RELATIF

Cet adressage n'est utilisé que pour les sauts. Nous avons vu précédemment l'instruction de saut "JP". Parallèlement, il en existe une autre notée "JR" (Jump Relative, en anglais) représentant le saut relatif.

Après l'instruction "JP", nous devons fournir l'adresse où nous désirons parvenir. Avec l'instruction "JR", nous fournissons le nombre de cases mémoires dont nous voulons nous déplacer aussi bien en avant qu'en arrière.

Ce déplacement est fourni sur un octet. De ce fait, cela entraîne une restriction importante puisque avec un octet, nous ne pouvons coder que 256 cases. Le déplacement ne pourra donc dépasser 127 cases en avant et 128 cases en arrière (Voir figure 11).

## 3.6 L'ADRESSAGE INDEXE

Il s'agit en fait de s'adresser à une case mémoire par un déplacement en avant ou en arrière. Cet adressage se pratique par rapport à une adresse précise contenue dans l'un des deux registres d'indexage IX ou IY (Voir paragraphe 1.7.1).

Ainsi, nous pouvons écrire "LD A. (IX + 5)" : le registre A sera chargé avec l'octet situé à l'adresse stockée dans le registre IX augmentée de 5.

Comme précédemment, le déplacement est limité à 127 en avant et 128 en arrière (Voir figure 12).

## 3.7 L'ADRESSAGE BIT

Maintenant, on ne s'adresse plus à un octet mais à un bit situé dans un registre ou dans une case mémoire.

Ainsi, la commande "SET 2. A" positionne à 1 le bit 2 du registre A, sans modifier les autres bits. On peut tester un bit ou le mettre à 0 de la même façon.

A la fin de ce chapitre, vous devez connaître à peu près la moitié de la structure de l'ASSEMBLEUR. Il ne reste plus qu'une étape, étape 6 combien primordiale : les instructions du NSC 800.