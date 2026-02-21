Pour les "techniciens du SOFT", nous pouvons préciser que cette zone est divisée en quatre parties bien distinctes :

- De 0000 à 00AE : zone initialisée conventionnellement.
- De 00AE à 00B4 : zone initialisée lors de la mise sous tension.
- De 00B4 à 00BE : zone initialisée lorsque le BASIC et remis à zéro.
- De 00BE à 0552 : zone générale de travail du système.

Voici maintenant le désassemblage complet de cette zone système ainsi que les explications indispensables à ce long périple. Tous les chiffres sont donnés en Hexadécimal sauf contre-indication.

|  ADRESSES | INSTRUCTIONS | COMMENTAIRES  |
| --- | --- | --- |
|  000-002 | C9 | RST 0 (Break point de la carte XP140F)  |
|  003 |  | Nombres de caractères imprimés * taille  |
|  004 | $50-80 décimal | Longueur d'une ligne sur la X-710  |
|  005 |  | Taille des caractères sur la X-710  |
|  008-00A | JP F52F | RST 08 (Voir les fonctions systèmes, Chap. 9)  |
|  00C-00D |  | START de la ROM1  |
|  010-012 | JP F537 | RST 10 (Test caractère)  |
|  015-014 |  | FIN de la ROM1  |
|  018-01A | JP C9C7 | RST 18 (Emission de commande vers T6834)  |
|  020-022 | JP EE45 | RST 20 (Comparaison entre HL et DE)  |
|  024-025 |  | START de la ROM2  |
|  025-027 |  | FIN de la ROM2  |
|  028-02A | JP E88F | RST 28 (Emission de A vers dispositif ouvert)  |
|  02B |  | FLAG de BREAK  |
|  02C-02E | C9 | INTERRUPT C (Clignotement curseur)  |
|  030-032 | JP FC2F | RST 30 (Test du type de données)  |
|  034-036 | JP C7A3 | INTERRUPT B (Interruptions SERIE)  |
|  038-03A | JP E906 | RST 38 (Calcul des adresses de tableaux)  |
|  03C-03E | JP C799 | INTERRUPT A (Interruptions du T6834)  |
|  03F-041 | JP CED6 | Appel de GPRPUT (Imprimante parallèle)  |
|  042-044 | JP E512 | Emission du contenu de A vers KBD, CASI  |
|  045-046 |  | Pointeur de la table pour RST 38  |
|  047-056 |  | Table des HOCKS  |
|  057-059 | JP E327 | Minuterie automatique  |
|  05A-05C | JP C16C | RETOUR  |
|  05D | JP C1FA |   |
|  060 | JP C181 |   |
|  063 | JP C219 |   |
|  066 | C9 | NMI  |
|  069 | JP C582 |   |
|  06C | JP C0A1 | LSET CURSEUR  |
|  06F | JP C210 |   |
|  072 | JP C231 | Affiche le contenu de C à l'adresse écran  |
|  ADRESSES | INSTRUCTIONS | COMMENTAIRES  |
| --- | --- | --- |
|  075 | JP C250 | SCREEN / Image miroir  |
|  078 | JP C154 |   |
|  07B | JP C138 |   |
|  07E | JP C120 |   |
|  081 | JP C24B | TXT TAB  |
|  084 | JP F1AA | SN ERROR  |
|  087 | JP E403 | SCREEN  |
|  08A | JP F1AA | Instruction COLOR PERITEL / Sinon SN ERROR  |
|  08D | JP CDF4 | Instruction PSET  |
|  090 | JP CDF7 | Instruction PRESET  |
|  093 | JP CE05 | Instruction POINT  |
|  096 | JP CE19 | Instruction LINE  |
|  099 | JP F1AA | Instruction PAINT PERITEL / Sinon SN ERROR  |
|  09C | JP CE32 | Instruction CIRCLE  |
|   |  | La zone s'étendant des adresses 057 à 09E est le secteur de communication "afficheur LCD/ afficheur VIDEO PERITEL".  |
|  09F | JP C1BE | Sortie CONSOLE (Implicite LCD)  |
|  0A2 | JP C90A | Entrée CONSOLE (Implicite KBD)  |
|  0A5 | JP C16D |   |
|  0A8 | C9 | ABORT HOCK (JP 7535 sur la carte XP 140F)  |
|  0AB | C9 | ERREUR HOCK (JP 756C sur la carte XP 140F)  |
|  0B1 |  | FLAG RESUME en cours  |
|  0B2-0B3 |  | Pointeur TXT TAB (Début BASIC)  |
|  0B8-0B9 |  | Adresse Curseur : X dans 0B8/Y dans 0B9  |
|  0BA |  | Longueur d'une ligne d'écran LCD  |
|  0BB |  | N° de la première ligne de roulement  |
|  0BC |  | N° de la dernière ligne de roulement  |
|  0BD |  | Nombre de lignes de roulement  |
|  0D5-1D4 |  | Tampon d'entrée  |
|  1D8 |  | FLAG variable (0, elle existe / FF, à créer)  |
|  1D9 |  | Type de données : 02 ---> %  |
|   |  | 03 ---> $  |
|   |  | 04 ---> !  |
|   |  | 08 ---> #  |
|  1DB-1DC |  | Dernière ligne exécutée  |
|  1DD-1DE |  | Fin de la pile (Indicateur STKTOP)  |
|  1DF-1E0 |  | Fin de la zone BASIC (Indicateur MEMSIZ)  |
|  1E1-1E2 |  | Prochaine adresse disponible dans la table des manipulations de chaines  |
|  1E3-200 |  | Table des manipulations de chaines  |
|  201 |  | Longueur de la chaîne (entre 0 et 255)  |
|  202-203 |  | Adresse de la chaîne  |