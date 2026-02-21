LES INSTRUCTIONS DU NSC 800

![img-0.jpeg](img-0.jpeg)

FIGURE 11: L'ADRESSAGE RELATIF

. IX - 2224h

. En faisant : LD A,(IX-2) → A-7
LD A,(IX-2) → A-5

![img-1.jpeg](img-1.jpeg)

FIGURE 12: L'ADRESSAGE INDEXE

Nous allons maintenant aborder le "gros morceau" de cette première partie consacrée à l'assembleur Z-80. En effet, nous allons vous exposer toutes les instructions disponibles, soit quelques 696 commandes distinctes !!

Rassurez-vous, nous n'allons tout de même pas vous les donner en vrac ... Nous avons distingué 11 familles d'opérations différentes, décrites une à une dans les pages suivantes.

De plus, un tableau général, situé à l'annexe 1, récapitule toutes les instructions disponibles. N'hésitez surtout pas à vous y reporter en cours de lecture ...

Avant de commencer, voici la liste des symboles utilisés :

nn  désignera une adresse sur 16 bits
v  désignera une valeur sur 8 bits
vv  désignera une valeur sur 16 bits
dpl  désignera un déplacement dans l'opérande des instructions en mode relatif
r  désignera un registre 8 bits
rr  désignera un registre 16 bits

## 4.1 CHARGEMENT et RANGEMENT

On utilise l'instruction LD (LoaD). Les informations transiteront vers la mémoire d'un registre ou vice-versa.

Ainsi, LD A,(nn) charge l'accumulateur avec la valeur contenue dans la case mémoire d'adresse nn. On a aussi :

LD A,(HL)  et inversement  LD (HL),A
LD B,(HL)  LD (HL),B
LD r,(HL)  LD (HL),r

Ceci est donc valable pour tous les registres. Ici, c'est le registre HL qui sert de pointeur mémoire. De plus, le registre A possède un privilège :

LD A,(BC)  et  LD (BC),A
LD A,(DE)  LD (DE),A