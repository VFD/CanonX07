95 SUB L modifiés
D6v SUB v

|  AE | XOR (HL)  |
| --- | --- |
|  DDAEdpl | XOR (IX + dpl)  |
|  FDAEdpl | XOR (IY + dpl)  |
|  AF | XOR A  |
|  A6 | XOR B  |
|  A9 | XOR C  |
|  AA | XOR D  |
|  AB | XOR E  |
|  AC | XOR H  |
|  AD | XOR L  |
|  EEv | XOR v  |

idem que OR

# ANNEXE 2
## ASSEMBLEUR &amp; DESASSEMBLEUR

Maintenant que vous connaissez l'ASSEMBLEUR, il faudrait vous équiper d'un logiciel "ASSEMBLEUR" vous permettant d'échapper au studieux travail de rentrée des codes !!

Il existe pour le moment sur le marché deux ASSEMBLEURS très corrects : celui de la société LOGI'STICK et celui du mensuel MICRO SYSTEMES.

Le premier est relativement bien fait mais présente quelques lacunes : limitations au niveau des labels, pas de directives (ORG, DEFM ...), un peu compliqué d'emploi.

Le deuxième, écrit entièrement en langage machine, est pratiquement parfait. En effet, il tient sur un carte mémoire de 4 Kilo-octets, possède beaucoup de pseudo-instructions ainsi que des fonctions de contrôle très puissantes. Nous le préférons nettement à celui de la société LOGI'STICK pour sa rapidité, sa compacité et, surtout, pour sa grande facilité d'emploi. Tous les listings source de cet ouvrage ont d'ailleurs été réalisés avec ce programme. Il est paru dans le numéro 49 de la revue MICRO SYSTEMES.

Vous devez sûrement vous douter qu'il existe un programme qui permet d'effectuer l'opération inverse d'un ASSEMBLEUR. Effectivement, quand vous avez assemblé un programme en mémoire, vous désirez probablement vérifier si cela a été bien opéré. Afin de calmer vos angoisses, il existe un logiciel appelé "DESASSEMBLEUR" permettant de lister la mémoire et de désassembler les codes entrés. En général, un DESASSEMBLEUR est accompagné d'un programme "MONITEUR" possédant d'autres fonctions intéressantes (mode TRACE, sauvegarde de codes, listings de codes en ASCII, sortie sur imprimante ...).

Trois logiciels se disputent la "suprématie du marché" : celui de LOGI'STICK, de CANON et de MICRO SYSTEMES.

La société LOGI'STICK édite, sur la même cassette que l'ASSEMBLEUR, un DESASSEMBLEUR-MONITEUR. À l'instar du premier programme, le DESASSEMBLEUR est très bien fait et autorise de multiples opérations sur la mémoire. Il est rapide et très pratique d'utilisation. Actuellement, la cassette incluant l'ASSEMBLEUR et le DESASSEMBLEUR-MONITEUR est vendu au prix de 125 Francs par le CLUB C7 (Le plus bas prix constaté, réservé uniquement aux adhérents ...).