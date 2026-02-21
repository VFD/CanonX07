CONCLUSION

10 'I
20 'ORG #1C00
30 '*REDEF DE TOUCHE
40 '*CHANGEMENT DE HOOK
50 'LD HL.#DB
60 'LD (*A01.HL
70 'RET
80 '*
90 '* PROGRAMME
100 '*
110 '#DB PUSH AF
120 'CP "~"
130 'JR Z.#AF
140 'POP AF
150 'JP #C1BE
160 '#AF PUSH HL
170 'LD HL.#ME
180 'CALL #D5B0
190 'POP HL
200 'POP AF
210 'JP #F23D
220 '#ME DEFM X07
230 'DEFB #00
240 ')

1C00 21071C LD HL,1C07
1C03 22A000 LD (00A0),HL
1C06 C9 RET
1C07 F5 PUSH AF
1C08 FE7E CP 7E
1C0A 2804 JR Z,1C10
1C0C F1 POP AF
1C0D C3BEC1 JP C1BE
1C10 E5 PUSH HL
1C11 211C1C LD HL,1C1C
1C14 CDB0D5 CALL D5B0
1C17 E1 POP HL
1C18 F1 POP AF
1C19 C33DF2 JP F23D

10 PRINT "un instant"
20 FOR I+&amp;H1C00 TO &amp;H1C20
30 READ A#:POKEI,VAL("A#A")
40 NEXT
50 EXEC&amp;H1C00:PRINT "APPUYEZ SUR ~"
60 DATA 21,07,1C,22,A0,00,C9,F5,FE,7E,28
.04,F1,C3,BE,C1,E5,21,1C,1C,CD,B0,D5
70 DATA E1,F1,C3,3D,F2,20,5B,30,37,00

Adresse de la routine dans HL
Adresse placée en A0h

Code ASCII de la touche dans A
Tildé enfoncé ?
non
oui
Adresse du message dans HL
Affichage du message
Mode attente curseur (F23Dh)
Affichage de la touche enfoncée

FICHE 14: REDEFINITION

OCTOBRE 1985, QUELQUE PART EN FRANCE, 8 h 10 ...

CANDORE s'est assoupi ... Sur la table, plusieurs feuilles gribouillées de sa main trainent. Un micro portatif CANON X-07 trône près de lui agité par des spasmes bizarres. En effet, l'écran clignote intensément avec une vélocité phénoménale ; le BUZZER émet des sons totalement inconnus du BASIC classique ; l'imprimante trace des lignes à une vitesse effarante !!

Soudain, le téléviseur, un peu en retrait, projette ses couleurs sur les multiples facettes de la pièce, doublées d'un message triomphant : EUREKA !

OCTOBRE 1985, QUELQUE PART EN FRANCE, 16 h 45 ...

Quelques heures plus tard, CANDORE se réveille et retrouve joyeux ce petit monde qu'il vient d'animer. Il a réussi à réveiller toutes les possibilités sommeillant au fin fond de son matériel informatique.

Tout à coup, un flash !! CANDORE se rend compte que son rêve s'est réalisé ! Par l'intermédiaire de ce livre magique, le vieux sage ASSEMBLUS lui a révélé tous les secrets de son X-07...

Tout en jubilant intérieurement, CANDORE pense à la chance qu'il a d'avoir pu lire cet ouvrage : "le CANON X-07 et l'ASSEMBLEUR".

Qui sait ... Peut-être qu'un jour une suite paraîtra car, CANDORE le pressent, le X-07 n'a pas fini de nous éblouir !

A. TONIC