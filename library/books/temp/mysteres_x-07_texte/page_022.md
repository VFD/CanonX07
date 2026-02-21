Attention ! Seul le registre A peut accéder à la mémoire en se servant des registres BC et DE comme pointeurs. Nous avons aussi les adressages indirects indexés :

LD (IX + dpl),r et LD r,(IX + dpl)
LD (IY + dpl),r LD r,(IY + dpl)

En ce qui concerne LD (IX + dpl),r (respectivement LD (IY + dpl),r), le registre considéré est chargé à l'adresse représentée par IX + dpl (respectivement IY + dpl). Les instructions LD r,(IX + dpl) et LD r,(IY + dpl) permettent de charger le registre r avec le contenu de l'adresse IX + dpl ou IY + dpl. De plus, on a les commandes suivantes :

LD (HL),v
LD (IX + dpl),v
LD (IY + dpl),v

Dans ce cas, on range directement la valeur v en mémoire à l'adresse correspondante (adresse contenue dans le registre HL, IX + dpl ou IY + dpl). Par exemple, LD (HL),8, avec HL contenant 4000, va stocker à l'adresse 4000 le chiffre 8. Voyons maintenant l'adressage direct 16 bits :

LD (nn),rr et LD rr,(nn)

Le contenu du double registre (BC, DE ou HL) est directement rangé ou chargé à l'adresse nn (Poids faible à l'adresse faible nn et poids fort à l'adresse forte nn+1). Par exemple, LD (7000),BC charge le contenu du double registre BC à l'adresse 7000. De même, LD HL,(9000) charge le contenu de l'adresse 9000 dans le double registre HL.

Pour terminer cette rubrique, voici deux instructions très particulières : LDD et LDI. L'octet dont l'adresse est pointée par le registre HL est chargé à l'adresse pointée par le registre DE. Simultanément, le registre BC se trouve décrémenté de 1 et provoque le passage à 0 de l'indicateur P/V lorsqu'il atteint une valeur nulle. De plus, les registres DE et HL sont décrémentés par LDD et incrémentés par LDI.

## 4.2 CHARGEMENT des REGISTRES et ECHANGE

L'instruction LD r,n permet de charger le registre r avec la valeur n. L'instruction LD rr,nn permet de charger le registre rr avec la valeur nn. De plus, LD r1,r2 charge le registre r1 avec la valeur du registre r2 : r : une restriction !! On peut très bien écrire LD A,A même si ce n'est pas très utile ...

Il existe trois autres instructions qui sont :
LD SP,HL
LD SP,IX
LD SP,IY

Le registre SP (Stack Pointer) est chargé avec la valeur d'un de ces trois registres.

Plus précisément, voyons maintenant l'instruction EXX. Nous avons vu précédemment un deuxième groupe de registres (A' à L') : EXX échange les deux familles de registres, les mémoires A' à L' se comportant alors exactement comme les registres A à L. Par exemple, EX AF,AF' échange le registre AF avec le registre AF'. Il existe aussi EX (SP),HL, EX (SP),IX et EX (SP),IY : l'échange est effectué entre l'un des doubles registres HL, IX et IY d'une part, et la case mémoire pointée par le registre SP d'autre part (la pile ...).

## 4.3 FONCTIONS ARITHMETIQUES

### 4.3.1 ADDITION avec et sans CARRY

Les deux instructions ADD A,v et ADC A,v permettent d'ajouter la valeur v à celle contenue dans le registre A. L'accumulateur contiendra donc le résultat en fin de calcul. Dans le cas de la commande ADC, le bit CARRY est positionné s'il existe une retenue.

De la même façon, ADD A,r et ADC A,r permettent d'ajouter le contenu du registre r à celui du registre A qui contiendra le résultat final. D'autre part, les instructions suivantes permettent quantité de choses :

ADD A,(HL) ADC A,(HL)
ADD A,(IX + dpl) ADC A,(IX + dpl)
ADD A,(IY + dpl) ADC A,(IY + dpl)

Ici, le contenu de la case mémoire adressée par le registre HL (ou par IX + dpl, IY + dpl) est ajouté au contenu de l'accumulateur.

De plus, ADD HL,rr et ADC HL,rr (rr pouvant représenter les registres HL, DE, BC ou SP) permettent d'ajouter le contenu du registre rr au registre HL jouant le rôle d'un accumulateur.

Enfin, ADD IX,rr et ADD IY,rr (avec rr pouvant représenter BC, DE, HL ou SP) permettent d'effectuer l'addition du contenu du registre rr avec le contenu du registre IX ou IY. On remarque qu'il n'existe pas les instructions ADD IX,rr ou ADC IY,rr.