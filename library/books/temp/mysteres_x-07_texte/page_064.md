124
125

# AFFICHAGE D' UN TITRE

Ce programme bloque la première ligne de l'écran en y affichant un message personnel. Ce "titre" ne peut être effacé par un scrolling (déroulement, en français...) de l'affichage mais seulement par un CLS.

Le principe est des plus classiques. En effet, après avoir effacé l'écran par l'ordre CE9Eh (Voir chapitre 9), on écrit dans la MEV d'unité centrale secondaire la ligne de début du SCROLL (à l'adresse C09Eh) et la ligne de fin de ce SCROLL (à l'adresse C096h).

Ensuite, on peut afficher le message par la routine FEF7h étudiée au paragraphe 9.6. Le programme expose affiche le message "PROGRAMME" mais rien ne vous empêche d'en choisir un autre. N'oubliez surtout pas de terminer votre message par le code "00" pour que la routine FEF7h puisse en déterminer la fin.

Longueur de la routine : 44 octets.
Implantation de la routine : de LCD0h à IC2Bh.

```html
|  10 | 11  |
| --- | --- |
|  15 | #INVERSE LCD  |
|  20 | ORS #1C00  |
|  30 | LD HL.#OFFF:#RAM LCD -1  |
|  31 | #1E INC HL  |
|  40 | CALL #E348:#LECTURE RAM LCD  |
|  42 | LD B.#FF  |
|  50 | XOR B  |
|  60 | CALL #E334:#ECRITURE RAM LCD  |
|  65 | PUSH HL  |
|  70 | LD A.H  |
|  80 | CP #E1:#OCTET FORT AD.RAM LCD  |
|  90 | JR 2.#F1  |
|  95 | POP HL  |
|  110 | JR #1E  |
|  120 | #F1 LD A.L  |
|  130 | CP #FE:#OCTET FAIBLE AD.RAM LCD  |
|  135 | POP HL  |
|  140 | RET 2  |
|  160 | JR #1E  |
|  170 | J  |
|  1C00 21FFDF | LD HL,OFFF  |
|  1C03 23 | INC HL  |
|  1C04 CD48E3 | CALL E348  |
|  1C07 06FF | LD B,FF  |
|  1C09 A8 | XOR B  |
|  1C0A CD34E3 | CALL E334  |
|  1C0D E5 | PUSH HL  |
|  1C0E 2C | LD A,H  |
|  1C0F FEE1 | CP E1  |
|  1C11 2003 | JR 2,1C16  |
|  1C13 E1 | POP HL  |
|  1C14 18ED | JR 1C03  |
|  1C16 2D | LD A,L  |
|  1C17 FEFE | CP FE  |
|  1C19 E1 | POP HL  |
|  1C1A C8 | RET 2  |
|  1C1B 18E6 | JR 1C03  |
```

10 CLS : PRINT "un instant"
20 FOR 1=&amp;H1C00 TO &amp;H1C18
30 READ A#:POKE1,UAL("H+A#")
40 NEXT
45 EXEC&amp;H1C00
50 DATA 21,FF,DF,23,CD,48,E3,06,FF,A8,CD
,34,E3,E5,7C,FE,E1,28,03,E1,18,ED,7D
60 DATA FE,FE,E1,C8,18,E6

![img-0.jpeg](img-0.jpeg)

FIGURE 124