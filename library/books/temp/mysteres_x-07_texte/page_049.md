94
95

|  ADRESSES | INSTRUCTIONS | COMMENTAIRES  |
| --- | --- | --- |
|  204-205 |  | Prochaine adresse vide dans la zone de stockage des chaînes (Indicateur FRETOP)  |
|  206-207 |  | Pointeur du dernier code exécuté ou taille des tableaux et FLAG de PRINT USING  |
|  208-209 |  | D43A  |
|  20A-20B |  | Pile des boucles FOR-NEXT  |
|  20E |  | FLAG pour l'instruction FOR  |
|  20F |  | FLAG pour C977  |
|  210-211 |  | Pointeur du début de la zone fichier RAM (Indicateur RAMSTR)  |
|  212-213 |  | Pointeur de la fin de la zone fichier RAM (Indicateur RAMEND)  |
|  214-263 |  | Image miroir de l'écran LCD  |
|  264-265 |  | Sauvegarde du pointeur BASIC (Registre HL) si le CANON est éteint par SLEEP  |
|  266-267 |  | Sauvegarde du pointeur de pile (Registre SP) si le CANON est éteint par SLEEP  |
|  268-26B |  | Mot-Clé (Jour, heure, minute, seconde) posé en RAMSTR-4 et RAMEND-1  |
|  26C |  | INTIMAG  |
|  26D |  | Nombre d'octets de réponse attendu par le T6834  |
|  26E- |  | 1er tampon de communication avec le T6834  |
|  2C3-2C4 |  | Adresse pilote de sortie  |
|  2C5-2E8 |  | Indicateur KBNTAB : table de INIT* (5 fois 8 octets). Adresse + sauvegarde des registres HL, DE et BC  |
|  2F5 |  | N° du dispositif ouvert  |
|  2F6-2F7 |  | Adresse du pilote  |
|  2F8-2FD |  | FLAG DATE$ (0 si actif et 1 si ALM$ actif)  |
|  2FE |  | FLAG ALM$, TIME$, DATE$  |
|  2FF-304 |  | Tampon pour la sauvegarde du nom de fichier cassette à trouver (6 octets)  |
|  305-30A |  | Tampon pour le nom de fichier lu sur la bande magnétique (SKIP ou FOUND)  |
|  30B |  | UCRIMAG  |
|  30C |  | RSERFLAG  |
|  30D |  | 1 si INPUT en cours / 0 autrement  |
|  30E |  | FLAG pour l'instruction READ  |
|  30F-310 |  | Appel à l'adresse 0B2 par RUN  |
|  311-312 |  | Numéro de ligne en cours d'exécution  |
|  313-314 |  | Sauvegarde du registre SP pendant la phase active de l'interpréteur  |
|  317-318 |  | Numéro de la ligne où une erreur se produit  |