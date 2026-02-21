## A) DIR de Bernard DUPIN :
## L'instruction DIR présente quelques inconvénients :
## - mauvaise lisibilité
## - défilemenl rapide difficile à ccntrôler (par contrôle S)
## - aucune indication sur la longueur des fichiers ou programmes.
## Le programme DIR remédie à ces petits défauts par un affichage ligne
## par ligne, cammandé par pression sur la barre d'espace, un seul fichier
## par ligne et affichage de la longueur (en octets) du fichier.
## Pour lister le catalogue sur l'imprimante, il suffit de remplacer les PRINT
## par des LPRINT et de supprimer l'attente.
## Enfin, il est intéressant de programmer une touche fonction.
## Par exemple :
## KEY$(1)="dir RUN"+CHR$(34)+"DIR"+CHR$(13)
## Le programme étant stocké en zone RAM pour fichier

5 REM "DIR" CANON X07 -
10 D=PEEK(528)+256*PEEK(529):ST=D:J=1
20 IFPEEK(ST)=0THEN70
30 N$="":FORI=1TO6:N$=N$+CHR$(PEEK(ST+I-1)):NEXTI
40 PRINTJ;TAB(4);N$;" ";CHR$(PEEK(ST+6));
50 L=PEEK(ST+7)+256*PEEK(ST+8):PRINTL
60 IF INKEY$=""THEN 60ELSEST=ST+L:J=J+1:GOTO20
70 F=PEEK(530)+256*PEEK(531):PRINT"FSET =";F-D+13,"RESTE  =";F-ST
80 END

