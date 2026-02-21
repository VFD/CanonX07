84
85

_ C01Ah : l'alarme est validée si le bit 0 de cette adresse est égal à 1 .

_ C040h à C04Eh : tous les deux octets, les données du temps sont mémorisées. Les nombres stockés les uns après les autres représentent : les secondes, les minutes, les heures, le jour de la semaine, la date, le mois et l'année en cours.

_ C050h à C05Eh : de même, les données de l'alarme sont stockées entre ces deux adresses.

_ C080h : indicateur de curseur.

_ C082h : indicateur de touche définie par l'utilisateur.

_ C084h : compteur de buzzer. Le buzzer cesse de retentir lorsque l'indicateur de report est posé.

_ C092h : compteur de la minuterie d'alimentation.

_ C096h : fin du défilement de l'affichage.

_ C09Eh : début de défilement de l'affichage.

Après avoir vu toutes les commandes du T6834 et ausculté sa mémoire intime, nous allons apprendre à l'utiliser ...

## 7.6.3 L'UTILISATION du T6834

Eh oui !! C'est bien joli d'avoir 70 commandes mais il faudrait savoir les utiliser intelligemment afin de tirer parti d'un processeur puissant autorisant des foules de choses comme vous le verrez bientôt ...

Nous avons plusieurs possibilités pour se servir du T6834. En effet, le BASIC du CANON utilise fréquemment le T6834 : il lui faut donc des routines toutes faites en ROM pour qu'il puisse communiquer aisément avec ce circuit.

Il existe deux routines principales se chargeant de ces transmissions. Leur adresse respective est E428h et C92Fh.

La routine E428h sert à envoyer un ordre précis au T6834 si l'on a aucun paramètre et que l'on attend pas de réponse. Il est impératif de placer le numéro de la commande dans le registre A et d'appeler ensuite la routine par un CALL $E428. Attention !! En retour, les registres A, F et L seront modifiés.

Ainsi, la petite routine suivante fera clignoter l'écran du X-07 :

```
LD B.$FF
#1 LD B.$2B
CALL $E428
LD A.$2C
CALL $E428
DJN2 #1
RET
```

La deuxième routine d'adresse C92Fh est beaucoup plus puissante. En effet, elle permet le passage de paramètres et utilise six registres du NSC 800 de la façon suivante :

- Dans A : numéro de la commande.
- Dans HL : adresse des opérateurs ou paramètres.
- Dans B : nombre de paramètres.
- Dans C : nombre de réponses arrivées.
- Dans D : pointeur du tampon qui stocke les données (En général, $26E).

Le problème est qu'au retour, les registres AF, BC, DE et HL seront modifiés. Immobiliser autant de registres devient très vite embarrassant car le NSC 800 ne dispose pas de 200 registres !!

Nous avons résolu ce problème en développant une petite routine qui n'utilise en tout et pour tout que le registre E !! De plus, seuls les registres A et C seront modifiés.

Cette routine permet d'envoyer le code d'une commande au T6834 ainsi que des paramètres et d'obtenir des réponses. L'utilisation de cette routine est donc très souple et vous permet d'économiser vos précieux registres.

Voici le listing de cette routine ainsi que divers commentaires. De plus, vous allez avoir droit à une petite démonstration graphique utilisant quelques possibilités du sous-processeur. Notez la vitesse de traitement : vous vous apercevrez que travailler en direct avec le T6834 n'est pas une chose vaine !!

Dans le listing joint, notons qu'au retour, aucun registre n'est modifié car ils sont sauvegardés et récupérés grâce aux instructions PUSH et POP. De plus, la routine C9C0h vérifie que le T6834 est prêt à recevoir des informations : elle ne rend la main au programme que s'il est prêt...

Vous pouvez vous reporter au programme d'inversion VIDEO LCD illustrant lui aussi les possibilités du T6834, présent dans la troisième partie.