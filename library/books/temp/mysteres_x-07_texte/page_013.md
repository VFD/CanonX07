22
23

|  REGISTRES PRIMAIRES  |   |
| --- | --- |
|  A | F  |
|  B | C  |
|  D | E  |
|  H | L  |
|  IX  |   |
|  IY  |   |
|  SP  |   |
|  I | R  |
|  REGISTRES SECONDAIRES  |   |
| --- | --- |
|  A' | F'  |
|  B' | C'  |
|  D' | E'  |
|  H' | L'  |
|  8 BITS  |   |
|  16 BITS  |   |

FIGURE 5: SCHEMA DES REGISTRES

![img-0.jpeg](img-0.jpeg)

FIGURE 6: LA PILE

L'emplacement de la dernière donnée empilée est continuellement inscrit dans le registre SP. On dit alors que SP représente le pointeur de pile (Stack Pointer en anglais) car il pointe sur la dernière donnée entrée. Le fait de conserver l'emplacement (le numéro de la case mémoire, en fait ...) de cette dernière donnée fait que c'est la seule donnée directement accessible. La pile est alors nommée pile "L.I.F.O.", de l'anglais "Last In First Out" (en français, premier entré, dernier sorti). On peut d'ailleurs la comparer à une pile d'assiette (comme dessiné à la figure 6), les assiettes représentant les données empilées.

I est un registre 8 bits utilisé au sein d'un mode particulier du NSC 800, mode lié aux "interruptions". Il faut savoir qu'une interruption est constituée par un événement extérieur influant sur le déroulement des opérations internes. Par exemple, l'imprimante X-710 envoyant des codes de contrôle au X-07 représente une interruption. La fonction du registre I est de contenir une partie d'une adresse vers laquelle se branchera le programme. Ceci arrivera uniquement en cas d'interruption due à un périphérique. En général, ce registre est assez peu utilisé en programmation.

Le registre R n'est pour nous d'aucune utilité. Sa fonction est très technique : il sert à "rafraîchir" la mémoire du NSC 800. En effet, la mémoire ne garde pas éternellement les données qu'elle contient et, de temps à autre, le micro-processeur va les lire pour ensuite les réécrire. Cette opération précise se déroule à notre insu et nous est donc totalement étrangère.

Avant de terminer cet exposé sur les registres, il nous faut vous entretenir d'un dernier registre : PC. En effet, ce "Program Counter" ou compteur ordinal n'est pas accessible en programmation. C'est un registre indiquant l'instruction que va exécuter le NSC 800. On peut donc comparer son contenu au numéro de ligne du langage BASIC. Sa fonction est d'indiquer le numéro de la case dans laquelle se trouve l'instruction à exécuter. Ce numéro de case se nomme une adresse (comme vous vous en doutiez surement ...).

Pour finir, nous devons préciser une notion primordiale. Nous savons que le NSC 800 ne comprend que des suites de 1 et de 0. En fait, rien ne distingue dans la mémoire, une donnée d'une instruction. Cette différence à effectuer provient indirectement du registre PC. Effectivement, à la mise sous tension, PC contient "0000" et, de ce fait, le NSC 800 exécutera ce qui se trouve à l'adresse "0000" (Ceci constitue un besoin physique ...). Vous entrevoyez le "Hic" ? ... Eh oui !! Si en "0000" se trouve une instruction, il n'y aura pas de problème ... Par contre, si vous y avez malencontreusement placé des données, le NSC 800 se comportera avec elles comme s'il s'agissait d'ordres et les effectuera !! Autant dire qu'il déraillera complètement et que le "RESET" (placé à l'arrière du X-07) sera le bienvenu !!

Donc c'est à vous de placer correctement données et instructions en mémoire ... Vous êtes livré à vous-même et la moindre erreur sera fatale à vos programmes !