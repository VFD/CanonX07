100
101

# 9.2 Les ROUTINES de CONVERSION

## 9.2.1 Les CONVERSIONS de TYPE

**CAE0**
E : charger l'accumulateur avec la donnée à convertir.
A : convertit la donnée flottante en donnée entière (Fonction CINT).
S : rien.
M : tous les registres sont modifiés.

**CB08**
E : charger l'accumulateur avec la donnée à convertir.
A : le contenu de l'accumulateur est converti en Simple Précision (Fonction CSNG).
S : rien.
M : tous les registres sont modifiés.

**CB1E**
E : charger la donnée entière dans l'accumulateur.
A : le contenu de l'accumulateur est converti en Simple Précision.
S : rien.
M : tous les registres sont modifiés.

**CB90**
E : charger l'accumulateur avec la donnée à convertir.
A : convertit le contenu de l'accumulateur en Double Précision (Fonction CDBL).
S : rien.
M : tous les registres sont modifiés.

## 9.2.2 Les CONVERSIONS ASCII-BINAIRE

**F595**
E : le registre HL doit pointer sur la chaîne à convertir.
A : Conversion de la chaîne ASCII en entier. La conversion prend fin au premier caractère non numérique.
S : le registre DE contient le résultat.

**BA21**
E : le registre HL pointe sur la chaîne à convertir.
A : Conversion en flottant de la chaîne. Le FLAG est ajusté.
S : le résultat se trouve dans l'accumulateur.

# 9.2.3 Les CONVERSIONS BINAIRE-ASCII

**BB98**
E : on charge le registre HL avec la donnée à convertir.
A : Conversion de HL en ASCII. On peut se servir de BB98 pour afficher un registre à l'écran.
S : écriture à l'écran de la chaîne ASCII.

**BE5F**
E : L'entier doit se trouver dans l'accumulateur. De plus, le registre HL doit pointer sur le tampon de sortie.
A : Conversion du contenu entier de A en ASCII. B et C doivent contenir des valeurs supérieures à 6.
S : la chaîne se trouve dans le tampon.
M : tous les registres sont modifiés.

**BBAB**
E : charger l'accumulateur avec le nombre flottant.
B = nombre de digits à gauche du point décimal.
C = nombre de digits à droite du point décimal.
Si A=0, conversion Binaire-ASCII pur.
Si A=X, Bit 7=1→Edition ; Bit 6=1
Bit 5=1→* en tête ; Bit 4=1→$ en tête
Bit 3=1→signe présent ; Bit 2=1→signe suivant valeur
Bit 0=1→notation exponentielle.
A : Conversion Flottant en ASCII.
S : Valeur dans le buffer pointé par HL (En général, 41E ...).

# 9.3 Les ROUTINES ARITHMETIQUES

## 9.3.1 Sur les ENTIERS

**CCC6**
E : charger HL et DE avec les nombres entiers à additionner. Le drapeau 1D9 est à 2.
A : additionnel entière.
S : le résultat se trouve dans le registre HL. DE est préservé. S'il y a OVERFLOW, le résultat se trouve dans l'accumulateur. Le FLAG TYPE est actualisé à 8.

**CCBB**
E : charger HL et DE avec les nombres à soustraire (HL-DE). Le drapeau 1D9 est à 2.
A : soustraction entière.
S : le résultat se trouve dans HL. DE est préservé. S'il y a OVERFLOW, le résultat est dans A. FLAG TYPE à 8.