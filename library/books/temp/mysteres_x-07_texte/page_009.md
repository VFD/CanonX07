15

# 1ère PARTIE :

## L'ASSEMBLEUR 2-30

## GENERALITÉS

Avant de nous lancer dans l'ASSEMBLEUR pur, ménageons-nous une petite mise en condition avec quelques généralités. Elles vous permettront de glisser en douceur vers le monstre sacré que constitue le langage machine ...

### 1.1 DEFINITION d'un ORDINATEUR.

"COMPUTER, ORDINATEUR, MICRO, MINI...". Tous ces mots magiques désignent en fait un "simple" amas de circuits électroniques. L'ordinateur est une machine ne sachant pas réfléchir elle-même : elle sait seulement répéter, un millier de fois si nécessaire, une opération et exécuter un programme lui permettant de résoudre un problème donné. Effectivement, ce n'est déjà pas si mal que ça!!

Tout ordinateur possède un "cerveau" (le micro-processeur) et une mémoire plus ou moins importante, se mesurant en Kilo, Méga ou Giga Octets. L'exécution d'un programme quelconque (jeu, CALC, Gestion de fichiers...) entraîne toujours les mêmes conséquences : le micro-processeur effectue les opérations qu'il trouve dans la mémoire et communique les résultats aux organes d'Entrée/Sortie (Ecran vidéo, Imprimante, Mémoire de stockage...). Un schéma simplifié peut vous faire saisir l'ensemble cohérent que constitue un ordinateur (Voir figure 1).

Bien qu'il puisse se présenter de manière disparate, l'ordinateur forme un "tout" indissociable. Par exemple, le micro-processeur ne peut fonctionner sans mémoire ou encore, aucun résultat ne peut être visualisé sans écran.

Plus précisément, nous pouvons "ausculter" l'intérieur de la mémoire, coeur de cet univers fascinant. En effet, le type et les performances du système utilisé dépendent du format des ordres placés en mémoire. De plus, la façon dont est relié le micro-processeur à ses périphériques est primordiale.

### 1.2 FORMAT des ORDRES et des DONNEES.

On peut se poser la question de savoir comment des chiffres peuvent être stockés dans la mémoire d'un ordinateur. En fait, l'ordinateur étant électroniquement constitué, la présence ou l'absence d'un courant électrique peut être facilement détectée.