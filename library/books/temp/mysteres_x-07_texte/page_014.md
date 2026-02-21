1.7.2 L'UAL, l'UCC...

Afin d'exécuter les instructions, le micro-processeur possède une Unité Aritmétique et Logique, reliée directement aux registres, qui se charge des calculs. On la désigne par "UAL" ou "ALU" selon que l'on emploie le français ou l'anglais.

De plus, on découvre dans le NSC 800 une unité de décodage des instructions représentée par un bloc de logique cablé. En fonction des 1 et des 0 qu'elle rencontre, elle effectuera un certain nombre d'opérations constituant l'instruction à exécuter.

Le micro-processeur possède aussi une logique baptisée UCC (Unité de Commande et de Controle) qui permet d'indiquer aux mémoires si elles doivent, par exemple, fournir une donnée ou bien la conserver (Signal Ecriture/Lecture), ce bus détecte les "tops" de l'horloge interne qui lui servent à rythmer les opérations et les appels des périphériques.

De plus, le NSC 800 a encore un dernier registre de 16 bits permettant d'augmenter ou de diminuer le registre PC en fonction des instructions rencontrées. Afin de vous faire une idée synoptique du micro-processeur, vous pouvez vous référer à la figure 7.

## 1.7.3 Les INDICATEURS

Nous avons vu précédemment que le registre F était différent des autres. En effet, F ne contient pas un mot de 8 bits car chacun de ses bits indique un état particulier après une opération. Pour "survoler" sa structure, référez-vous à la figure 8.

Le bit 0 nommé "CARRY" (Report ou Retenue en français) indique qu'il existe une retenue. De plus, nous verrons dans le chapitre "Instructions du NSC 800" qu'il nous permet de tenter des comparaisons et bien d'autres choses encore...

Le bit 1 nommé "N" (Négatif) sera positionné à 1 si la dernière opération était une décrémentation ou une soustraction.

Le bit 2 nommé "P/V" (Parité/oVerflow = débordement en français) indique deux choses : la parité (le nombre de bits mis à 1 est pair ou impair) et le débordement lors d'une instruction arithmétique (Voir figure 9).

Les bits 3 et 5 se sont donnés le mot : ils ne servent strictement à rien!

Le bit 4 nommé "H" (Half-carry) constitue une demi-retenue. Il est égal à 1 lorsqu'il existe une retenue sur les quatre premiers bits d'un opérande (Voir figure 10). Il est très peu utilisé par les programmeurs.

![img-0.jpeg](img-0.jpeg)
FIGURE 7 : STRUCTURE INTERNE

![img-1.jpeg](img-1.jpeg)
FIGURE 8 : LES INDICATEURS