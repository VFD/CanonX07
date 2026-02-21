COPYRIGHT PERSONNEL

![img-0.jpeg](img-0.jpeg)

Cette routine va vous autoriser à afficher un message personnel dès la mise en route du X-07 ... L'imagination est au pouvoir !!

Le principe de la routine est basé sur la structure logicielle de démarrage du CANON. Effectivement, on utilise le mot-clé "love" (Voir le paragraphe 7.4) pour envoyer le pointeur de la machine vers un sous-programme personnel d'affichage.

Dans le cas présent, on a uniquement utilisé l'appel à une routine ... Si on avait voulu obtenir la même chose en démarrant après un SLEEP, il aurait fallu se servir de la troisième adresse positionnée après le mot-clé "love".

La routine est entièrement relogée ... ATTENTION! Le mot-clé "love" n'est testé que tous les 800h octets (donc tous les 2048 octets) à partir de l'adresse 2000h. On en conclut que les adresses possibles se résument à : 2000h, 2800h, 3000h, 3800h, 4000h, 4800h, 5000h.

De plus, il est primordial de modifier les adresses des sous-programmes en fonction de l'emplacement du programme personnel.

Par exemple, si la routine avait débuté en 3000h, elle se serait présentée de la manière suivante :

- ORG $3000
- DEFM love
- DEFB $0A,30
- DEFB $19,30
- DEFB $19,30

Référez-vous vite à la figure 35 ... Votre CANON va dorénavant posséder un visage différent !!

Longueur de la routine : 29 octets.
Implantation de la routine : de 200Ah à 2026h.

EIGHTE 24: AFFICHAGE d'un TITRE