# 2ème PARTIE :

## MYSTERES DU X-07

## L'ARCHITECTURE INTERNE DU CANON X-07

### 7.1 GENERALITES

Le CANON X-07 a été construit avec des circuits à technologie CMOS (faible consommateurs d'énergie), étant donné sa finalité de portable. Il est, de ce fait, alimenté par quatre piles de 1,5 Volts.

Si cette technologie CMOS est très économe en électricité, elle est par contre très lente dans son travail !! Par conséquent, les ingénieurs de la société CANON ont adopté une architecture un peu particulière pour le X-07 ...

En effet, si le microprocesseur du CANON X-07 est bien un Z-80 (ou plutôt un NSC 800, simili Z-80), il existe un deuxième microprocesseur chargé de la gestion des entrées/sorties (clavier, buzzer, affichage ...). Ce "T6834", microprocesseur de TOSHIBA, permet de soulager le X-07 de fonctions importantes et la vitesse du CANON s'en trouve améliorée d'autant.

Dans notre machine préférée, le NSC 800 envoie simplement des commandes au T6834 à travers un circuit spécialisé dans les transmissions nommé "HD61L202F".

Une fois que le T6834 a signalé qu'il a bien reçu les commandes envoyées, le microprocesseur principal peut continuer l'exécution du programme en cours pendant que les entrées/sorties s'effectuent.

Le bloc-diagramme, présent à la page 66 (figure 18), nous permet de survoler cette organisation. En fait, tout se passe comme si un ordinateur construit autour d'un Z-80 transmettait des ordres à un ordinateur équipé d'un T6834.

Afin de vous préparer à l'exploration systématique des ressources cachées du X-07, nous allons vous exposer l'architecture des deux parties du X-07 : celle attachée au NSC 800 et celle obéissant au T6834.

### 7.2 L'UNITE CENTRALE

L'unité centrale contient un bloc de mémoire directement accessible à partir du BASIC du X-07 par les commandes PEEK et POKE. En effet, la mémoire LCD (Par exemple ...) ne nous est pas accessible car elle est directement adressée par le T6834.

65