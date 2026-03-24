# Ordinateur Individuel, issue 063 (1984-10)(Ordinateur Individuel)(FR)


___
## Listing

```basic
100 PSET(X,Y): Z=STICK(0): U=X-(Z=3)+(Z=7): V=Y+(Z=1)-(Z=5)
110 IF POINT(U,V) THEN BEEP Z,3 ELSE PRESET (X,Y) : X=U: Y=V
120 IF X<119 THEN 100
```

Explication :

Détail ligne par ligne :

La ligne 100 fait un PSET(X,Y) qui initialise le point.\
Elle lit l'état du joystick avec STICK(0) et stocke la valeur dans Z.\
Ensuite, elle calcule les nouvelles coordonnées U et V en fonction de la direction du joystick :

- Si Z=3 (joystick à gauche), U diminue de 1
- Si Z=7 (joystick à droite), U augmente de 1
- Si Z=1 (joystick vers le haut), V augmente de 1
- Si Z=5 (joystick vers le bas), V diminue de 1

La ligne 110 vérifie si le point aux coordonnées (U,V) est déjà dessiné avec POINT(U,V).\
Si c'est le cas, un bip sonore se déclenche (BEEP Z,3).\
Sinon, le point précédent est effacé avec PRESET(X,Y), et les coordonnées sont mises à jour vers la nouvelle position.

La ligne 120 crée la boucle :
- tant que X est inférieur à 119, le programme revient à la ligne 100 pour continuer le mouvement.

___

