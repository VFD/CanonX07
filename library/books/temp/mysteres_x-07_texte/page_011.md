18
19

|  DECIMAL | BINAIRE | HEXA.  |
| --- | --- | --- |
|  0 | 0 | 0  |
|  1 | 1 | 1  |
|  2 | 10 | 2  |
|  3 | 11 | 3  |
|  4 | 100 | 4  |
|  5 | 101 | 5  |
|  6 | 110 | 6  |
|  7 | 111 | 7  |
|  8 | 1000 | 8  |
|  9 | 1001 | 9  |
|  10 | 1010 | A  |
|  11 | 1011 | B  |
|  12 | 1100 | C  |
|  13 | 1101 | D  |
|  14 | 1110 | E  |
|  15 | 1111 | F  |

FIGURE 2: CORRESPONDANCES

|  0 | 1 | 0 | 0 | 0 | 0 | 0 | 0  |
| --- | --- | --- | --- | --- | --- | --- | --- |
|  128 | 64 | 32 | 16 | 8 | 4 | 2 | 1  |
|  1 | 0 | 0 | 0 | 0 | 0 | 0 | 0  |
| --- | --- | --- | --- | --- | --- | --- | --- |
|  128 | 64 | 32 | 16 | 8 | 4 | 2 | 1  |

POIDS: 0 ou 1

RANG: UNE DES CASES DESSINEES

FIGURE 4: DEUX OCTETS DIFFERENTS

Un mot ou un octet : a.2⁷ · a.2⁶ · a.2⁵ · a.2⁴ · a.2³ · a.2² · a.2¹ · a.2⁰

Soit avec a-1 : 1.2⁷ · 1.2⁶ · 1.2⁵ · 1.2⁴ · 1.2³ · 1.2² · 1.2¹ · 1.2⁰
= 255

Donc, le nombre 255 représente la valeur maximale qui peut être attribuée à un octet.

## 1.4 La MEMOIRE.

Puisque le micro-processeur travaille avec des mots de 8 bits, la mémoire ne contiendra que des mots de 8 bits également. Elle est reliée au NSC 800 (pour le CANON X-07...) par un deuxième bus de 16 fils. Ce "bus d'Adresse" sert à indiquer quels octets elle doit fournir au micro-processeur. En adoptant la notation binaire, 16 fils correspondent à 2¹⁵ · 2¹⁴ · 2¹³ · 2¹² · 2¹¹ · 2¹⁰ · 2⁹ · 2⁸ · 2⁷ · 2⁶ · 2⁵ · 2⁴ · 2³ · 2² · 2¹ · 2⁰ = 65536 cases désignables possibles.

En fait, on peut assimiler la mémoire du X-07 à un meuble de 65536 tiroirs (les octets), numérotés de 0 à 65535, chaque tiroir contenant 8 petites cases (les bits). Vous pouvez vous référer à la figure 2 pour mieux cerner cette métaphore.

## 1.5 L'HEXADECIMAL.

65536 positions possibles !! Cela paraît bien difficile à désigner avec des 1 et des 0 ! Pour pallier à cet inconvénient, une notation intermédiaire fut adoptée entre le binaire et le décimal : l'hexadécimal.

Si l'on désire coder des nombres de 4 bits, on pourra coder 16 symboles comme sur la figure 3.

Vous remarquerez qu'après le chiffre 9 en hexadécimal, on découvre la lettre "A". Les mathématiciens, devant statuer sur des symboles quelconques, ont décidé que les lettres A à F désigneraient les nombres de 10 à 15.

Maintenant, nous savons transformer un mot de 4 bits en hexadécimal... Mais comment procède-t-on pour un mot de 8 bits ? Surtout ne vous défenestrez pas pour si peu car, en fait, un mot de 8 bits est constitué par deux mots de 4 bits ! Afin de vous prouver la simplicité de la méthode, prenons deux exemples :