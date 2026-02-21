106
107

CA42
E : charger l'accumulateur avec une valeur et le registre HL avec l'adresse d'un tampon.
A : mouvement du contenu de A vers un tampon pointé par HL.
S : le tampon se remplit.

CA51
E : charger B avec le nombre d'octets à mouvoir. De plus, DE doit contenir l'adresse du tampon de départ et HL, l'adresse du tampon d'arrivée.
A : mouvement d'un groupe d'octets vers un tampon.
S : HL et DE croissent.

CA58
E : pareil que CA51.
A : pareil que CA51.
S : HL et DE décroissent.

CAEF
E : charger HL avec une valeur.
A : le contenu de HL transite vers le registre A.
S : A prend la valeur de HL. Le drapeau 1D9 prend la valeur 2.

CA5F
E : charger l'accumulateur 2 avec une valeur.
A : le contenu de l'accumulateur 2 transite vers l'accumulateur.
S : le registre A prend la valeur de Accum. 2.

CA67
E : charger l'accumulateur avec une valeur.
A : le contenu du registre A transite vers l'accumulateur 2.
S : l'Accum. 2 prend la valeur du registre A.

# 9.6 Les ROUTINES SECONDAIRES

C02D
E : rien.
A : interrogation de BREAKFLAG (Octet situé en 2B : le bit 0 contient l'indicateur BREAK, le bit 1 l'indicateur "piles épuisées", le bit 3 l'indicateur "pile carte épuisée", le bit 6 l'indicateur d'arrêt de minuterie et le bit 7 l'indicateur OFF).
S : Si le bit d'introduction (Bit 6) est à 1, la commande C02D le met à 0, vide le tampon de touches et met à 1 le bit d'indication Z. Par contre, si le bit 6 est à 0, la commande C02D envoie la commande au programme appelant, avec l'indicateur Z réglé.
M : aucun registre.

C5A6
E : rien.
A : contrôle les bits d'épuisement de la pile de la carte et des piles du X-07 (Controle des bits de BREAKFLAG).
S : Si le bit de piles épuisées est à 1, affichage de "LOW BATTERY" et retour au programme appelant, avec l'indicateur Z remis à 0.
Si le bit de la pile de carte épuisée est à 1, le message "CARD LOW BATTERY" est renvoyé et on retourne au programme appelant avec l'indicateur Z remis à 0.
Par contre, si les deux bits précédents sont à 1, on retourne au programme appelant avec l'indicateur Z mis à 1.
De plus, le registre A est chargé avec les dernières données BREAKFLAG.
M : aucun registre.

EE13
E : charger HL avec l'adresse de saut de tableau et C avec le décalage.
A : saut dans le tableau du vecteur.
S : HL change de valeur.
M : les registres AF, BC, DE, HL.

C557
E : rien.
A : contrôle du commutateur de prise (MEV/MEM).
S : cette commande charge HL avec 4000h si le commutateur de prise est réglé sur la position MEV.
Sinon, HL est chargé avec la valeur 2000h (Position MEM).
M : les registres AF et HL.

C5C3
E : rien.
A : coupe l'alimentation du CANON.
S : rien.
M : tous les registres.

SC 6F 7C 15 C3C5