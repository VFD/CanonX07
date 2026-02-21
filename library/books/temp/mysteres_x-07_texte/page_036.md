68
69

![img-0.jpeg](img-0.jpeg)
FIGURE 19: STRUCTURE - MEMOIRE

![img-1.jpeg](img-1.jpeg)
FIGURE 20: les ENTREES / SORTIES

La carte étant détectée par voie logicielle, le programme d'initialisation recherche un mot-clé baptisé "love" dans la mémoire. Dès que ce mot-clé est repéré, on considère les six octets le suivant comme les adresses de trois sous-programmes à exécuter immédiatement avant de continuer à effectuer le programme d'initialisation.

En fait, le X-07 exécute toujours les routines correspondant aux deux premières adresses, la troisième servant lorsque le CANON a été éteint par l'ordre SLEEP du BASIC.

Pour éviter toute confusion (En effet, rien ne prouve que vous n'écrivez jamais le mot "love" dans la mémoire du CANON. Sait-on jamais, l'amour peut prendre toutes les formes !!), le X-07 ne recherche pas ce mot-clé dans toute la mémoire, mais seulement entre les adresses 2000h et B000h et ceci tous les 2048 octets (800 en hexadécimal).

Nous vous conseillons fortement de vous reporter au programme de "COPYRIGHT personnel" de la troisième partie qui vous permettra de bien comprendre ce processus. En effet, comme vous le verrez, rien ne vous empêche de placer le mot "love" avant celui de la version de base afin de faire exécuter par le CANON vos propres routines (L'imagination est au pouvoir !!).

# 7.5 La PUCE de CONTROLE "ENTREES/SORTIES".

Cette puce constitue un circuit spécialisé controlant la réception et l'exécution des données.

Bien qu'étant relativement inintéressante pour la programmation du CANON X-07, son architecture et son mode de travail va vous permettre de mieux appréhender le fonctionnement de votre micro-ordinateur.

Son bloc-diagramme est représenté par la figure 20. En regardant de près ce schéma, on note la grande puissance et la tâche ardue de ce circuit qui doit gérer les sorties CENTRONICS, les entrées/sorties SERIE, le BUZZER et l'interface cassette.

Le NSC 800 communique avec ce circuit via les ports d'adresse F0 à F7. Comment ? Tout simplement en écrivant dans les registres de notre transistor HD61L202F, décrit précédemment.

Voici la liste des informations lues et écrites avec l'adresse du port correspondant. Le mode d'adressage de ces registres est celui utilisé normalement par le NSC 800. Le port est spécifié par l'adresse de l'opérande, D7 à D0, correspondant au bus de données.