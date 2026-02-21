RÉDEFINITION DE TOUCHES

10 'C
20 'ORG #1C00
30 '#BRUIT
35 'LD A.#00
40 'LD B.#0F
50 'OUT (#F3).A
60 'LD A.#4E
70 'OUT (#F4).A
80 '#ZE LD A.#FF
90 '#1E OUT (#F2).A
100 'DEC A
110 'JR Z.#F3
120 'CALL #TE
130 'JR #1E
140 '#F3 LD A.B
150 'DEC A
160 'JR Z.#F1
170 'OUT (#F3).A
180 'LD B.A
190 'JR #2E
195 '#-
196 '# ARRET
197 '#-
200 '#F1 LD A.#00
210 'OUT (#F4).A
220 'RET
225 '#-
226 '# TEMPO
227 '#-
230 '#TE PUSH AF
240 'LD A.#00
250 '#LD DEC A
260 'JR NZ.#LO
265 'POP AF
270 'RET
280 ']

10 PRINT "un instant E"
20 FOR I=&amp;H1C00 TO &amp;H1C2B
30 READ A#PORE I,VAL("&amp;H"+A#)
40 NEXT
50 EXEC&amp;H1C00
60 DATA 3E,00,06,0F,D3,F3,3E,4E,D3,F4,3E
,FF,D3,F2,3D,2B,05,CD,24,1C
70 DATA 1B,F6,7B,3D,2B,05,D3,F3,47,1B,EB
,3E,00,D3,F4,C9,F5,3E,80,3D,20,FD,F1,C9

![img-0.jpeg](img-0.jpeg)

Le but de ce dernier programme est d'assigner à une touche quelconque du clavier un message. Vous percevez surement l'utilité de cette routine : le clavier entier peut être redéfini en AZERTY, par exemple.

Ici, la touche " (Tildé espagnol) provoquera l'affichage de "X-07" à chaque appui.

Le principe adopté est d'appeler la routine d'affichage à chaque appui d'une touche. Cette routine est appelée par une adresse se trouvant en zone système, exactement en 9Fh (Voir le paragraphe 8.3).

En modifiant l'adresse de saut, on fait passer cette routine par un petit programme personnel comparant la touche appuyée avec le code ASCII se trouvant dans le registre A (Code ASCII de la touche redéfinie). Si les deux codes sont égaux, on exécute l'affichage du message défini, sinon on retourne à la routine initiale (CEB1h) qui affichera le caractère contenu dans l'accumulateur.

Le programme se présente donc en deux parties :

- La première partie modifie l'adresse de saut se trouvant à l'adresse 9Fh.
- La deuxième partie effectue la comparaison et affiche le message si cela se révèle nécessaire.

Si vous regardez l'organigramme, vous remarquerez qu'il n'y a pas de FIN à ce programme ... Pourquoi ? Tout simplement parce que la routine est interactive : elle décide d'elle-même si elle doit fonctionner ou pas ...

Longueur de la routine : 32 octets
Implantation de la routine : de 1C00h à 1C1Fh

FIGURE 37: BRUITAGES