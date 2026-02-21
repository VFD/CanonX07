58
59

En effet, si par la suite on découvre la ligne "LD A.(OCTET)", le registre A ne contiendra pas l'octet pointé par l'adresse 24h mais la valeur 24h elle-même.

## 5.4.2 La directive DEFM

"DEFM" a pour fonction de définir un message quelconque (DEFine Message en anglais). Par exemple, la ligne "DEFM 'AU REVOIR'" sera assemblée et produira une donnée 'AU REVOIR' codée en ASCII. Cette donnée pourra ensuite être exploitée par le programme.

Cette directive est très utilisée pour afficher des textes, des tableaux ... sur l'écran ou sur un périphérique quelconque (imprimante, traceur ...).

## 5.4.3 La directive DEFW

"DEFW" permet de définir un mot (DEFine Word en anglais). Par exemple, la ligne "ADRESSE DEFW 2500h" assignera au symbole "ADRESSE" la valeur 2500h.

En effet, si par la suite l'ASSEMBLEUR découvre la ligne "LD HL.(ADRESSE)", le double registre HL contiendra l'adresse correspondant au symbole "ADRESSE", c'est-à-dire la valeur 2500h.

## 5.5 FIN du PROGRAMME SOURCE : END

Cette directive constitue obligatoirement la dernière ligne source du logiciel. Sa fonction est évidente : elle indique à l'ASSEMBLEUR la fin du programme (comme en BASIC).

Dans certains cas, "END" possède un opérande constitué par une valeur ou un label. Cela permet de lancer le programme ASSEMBLEUR dès que son chargement est terminé.

|  DEBUT | LD A.5 | Par exemple, dès que cette routine sera chargée en mémoire et assemblée, elle sera lancée automatiquement par la ligne "END DEBUT".  |
| --- | --- | --- |
|   | LD HL.2020 |   |
|   | END DEBUT |   |

A l'image de cette directive ASSEMBLEUR, nous avons terminé ce cinquième chapitre et aussi cette première partie. Quoi ? Qu'entends-je ? ? ... Vous désirez des exemples ? Vos désirs étant des ordres, un sixième et dernier chapitre va apparaître insidieusement devant vos yeux, vous permettant de bien vous roder à l'ASSEMBLEUR. Après ceci, le CANON X-07 deviendra le maître suprême de cet ouvrage !!

# APPLICATION : TRI À BULLES

Dans ce dernier chapitre de la première partie, nous allons "disséquer" une application écrite en langage machine qui vous permettra de bien comprendre l'écriture et la forme d'une routine ASSEMBLEUR.

L'application choisie est constituée par une routine de "tri à bulles" autorisant un tri croissant ou décroissant sur des valeurs comprises entre 0 et 255 uniquement. En effet, un tri sur tous les nombres possibles compliquerait singulièrement les choses et ce n'est pas notre but.

Le listing BASIC, le listing source et le listing désassemblé vont vous être présentés ci-dessous.

# LISTING SOURCE

Nous vous rappelons que le listing source constitue le programme construit à l'aide d'un logiciel "ASSEMBLEUR" (Ici, celui de la revue MICRO SYSTEMES : voir annexe 2). En voici le détail :

0 ** TRI DE NOMBRES COMPRIS ENTRE 0 ET 255 **
5 1
10 'ORG &amp;4096
20 'DE LD B.&amp;0
30 'LD HL$1025
40 'LD C.(HL)
50 'DEC C
60 'BB INC HL
70 'INC HL
80 'LD A.(HL)
90 'DEC HL
100 'CP (HL)
110 'JP NC.AA
120 'LD D.(HL)
130 'LD (HL).A
140 'INC HL
150 'LD (HL).D
160 'LD B.&amp;1
170 'DEC HL
180 'AA DEC C
190 'JP NZ.BB
200 'LD A.B
210 'CP &amp;1
220 'RET NZ
230 'JP DE
240 '1