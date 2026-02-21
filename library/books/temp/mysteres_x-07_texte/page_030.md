LES PRINCIPALES
PSEUDO-INSTRUCTIONS
DE L'ASSEMBLEUR

Ces nouvelles commandes sont un peu particulières. En effet, elles sont spécifiques de l'ASSEMBLEUR que vous utilisez. Un ASSEMBLEUR peut donc très bien ne posséder aucune de ces pseudo-instructions.

Ces directives se plient aux mêmes règles syntaxiques que les instructions classiques. Effectivement, leur format source possède les mêmes champs que ceux étudiés au paragraphe 2.5.

Les huit "pseudo-instructions" que nous allons vous exposer s'adressent uniquement au programme ASSEMBLEUR et non au NSC 800, comme le font les instructions vues au chapitre 4. Elles agissent sur le listing source en modifiant sa disposition, son implantation...

## 5.1 ADRESSE D'IMPLANTATION : ORG

La directive "ORG" permet, comme son nom l'indique (ORiGine), d'implanter le programme écrit en ASSEMBLEUR à partir d'une adresse donnée. En effet, elle accepte un opérande représenté par une valeur codée sur 8 ou 16 bits.

Ainsi, la pseudo-instruction "ORG 2500h" suivi d'un programme ASSEMBLEUR fizera l'origine de ce dernier à l'adresse 2500h.

Voyons un exemple concret :
ORG 4000h
NOP
LD HL.22h
RET

Cette petite routine sera implantée à partir de l'adresse 4000h. La case mémoire 4000h contiendra le code de l'instruction NOP (00).

## 5.2 RESERVATION DE MEMOIRE : DEFS

Cette directive a pour fonction de réserver un certain nombre d'octets en mémoire. Elle accepte pour opérande des valeurs codées sur 8 ou 16 bits.

Par exemple, la directive "DEFS 350" réservera 350 octets dans le programme suivant :

Adresse 2000 : LD A.5
DEFS 350
2352 : LD BC.2250

Remarquez qu'après l'adresse 2000 (en décimal), le code source reprend en 2352 étant donné que DEFS 350 n'est pas assemblé...

## 5.3 DEFINITION D'EQUIVALENCE : DEFL et EQU

Ces deux directives varient souvent suivant l'ASSEMBLEUR utilisé. En effet, le signe "=" d'affectation est souvent préféré.

On emploie "DEFL" et "EQU" quand on désire manipuler des symboles, l'instar des valeurs. Effectivement, la directive "EQU" assigne une immuable à un symbole. Par exemple, "DEBUT EQU 6500h" assigne au symbole "DEBUT" la valeur 6500h. Ceci est équivalent à "DEBUT=6500h".

Lorsqu'une équivalence est définie, elle reste "intouchable" durant tout le déroulement du programme. Néanmoins, il existe un recours : la directive "DEFL", employée à la place de "EQU", permet de contrer cette interdiction.

Le programme suivant vous développe son utilisation :

VAL1 EQU 56 ---&gt; Première assignation
LD A,VAL1
LD B,53
VAL1 DEFL 54 ---&gt; Possibilité de changer la première assignation
LD BC,VAL1
VAL1 DEFL 60 ---&gt; Troisième assignation
LD DE,VAL1

## 5.4 DEFINITION de DONNEES : DEFB, DEFM et DEFW

Ces trois directives se démarquent des précédentes. En effet, elles produisent chacune un code objet contrairement à ORG, DEFL, EQU, DEFL et END.

### 5.4.1 La directive DEFB

"DEFB" permet de définir un octet (DEFine Byte en anglais). Par exemple, la ligne "OCTET DEFB 24h" assignera au symbole "OCTET" la valeur 24h.