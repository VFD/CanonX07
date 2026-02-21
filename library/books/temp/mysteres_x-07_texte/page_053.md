102
103

CCE7
E : charger HL et DE avec les nombres à multiplier.
Le drapeau 1D9 est à 2.
A : multiplication entière.
S : le produit se trouve dans HL, DE est préservé.
S'il y a OVERFLOW, le résultat se trouve dans A. FLAG TYPE à 8.

FA79
E : charger DE et HL avec les nombres à diviser (DE/HL).
A : division entière.
S : quotient en double précision dans l'accumulateur.

9.3.2 En SIMPLE PRECISION

CDA9
E : charger un nombre dans A, l'autre dans BC et DE.
Le drapeau 1D9 est à 4.
A : addition.
S : le résultat se trouve dans l'accumulateur.

CDB2
E : charger l'accumulateur avec le 1er nombre et BC, DE avec le 2ème.
A : soustraction (A-(BC,DE)).
S : le résultat se trouve dans A.

CDB7
E : charger l'accumulateur avec le 1er nombre et BC, DE avec le 2ème.
A : multiplication (A*(BC,DE)).
S : le résultat se trouve dans A.

CDC2
E : charger l'accumulateur avec le 2ème nombre et BC, DE avec le 1er.
A : division ((BC,DE)/A).
S : le résultat se trouve dans A.

9.3.3 En DOUBLE PRECISION

B20E
E : charger l'accumulateur 2 et l'accumulateur.
Le drapeau 1D9 est à 8.
A : addition.
S : le résultat se trouve dans l'accumulateur.

B200
E : charger l'accumulateur 2 et l'accumulateur.
A : soustraction (Accum. - Accum. 2).
S : le résultat se trouve dans A.

B376
E : charger l'accumulateur 2 et l'accumulateur.
A : multiplication.
S : le résultat se trouve dans A.

B42F
E : charger l'accumulateur 2 et l'accumulateur.
A : division (Accum. / Accum. 2).
S : le résultat se trouve dans A.

9.3.4 De COMPARAISONS

CA7B
E : charger BC, DE avec le 1er nombre et A avec le 2ème.
A : comparaison en Simple Précision.
S : Si (BC,DE) &gt; (A), A = -1. Les () marquent le contenu du registre.
Si (BC,DE) &lt; (A), A = 1.
Si (BC,DE) = (A), A = 0.

CAA5
E : charger HL et DE avec les deux nombres à comparer.
A : comparaison entière.
S : Si (DE) &gt; (HL), A = -1.
Si (DE) &lt; (HL), A = 1.
Si (DE) = (HL), A = 0.

CAD9
E : charger Accum. 2 et Accum.
A : comparaison en Double Precision.
S : Si (Accum. 2) &gt; (Accum.), A = -1.
Si (Accum. 2) &lt; (Accum.), A = 1.
Si (Accum. 2) = (Accum), A = 0.

C9FB
E : charger l'accumulateur. Le drapeau 1D9 est à 8.
A : donne le signe en Double Précision.
S : Si (A) &gt; 0, A = 1.
Si (A) &lt; 0, A = -1.
Si (A) = 0, A = 0.