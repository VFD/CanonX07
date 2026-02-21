INVERSION DE L'APPROCHURE
LCD

10 'I
15 'INVERSE VIDEO
20 'ORG #1C00
30 'LD B.#FF
40 'LD HL.#8000 :DEBUT DE LA VRAM
50 '#1E LD A.(HL)
60 'XOR B
70 'LD (HL),A
80 'LD A.H
90 'CP #87 :OCTET FORT DE L'AD.DE FIN
100 'JR Z.#FI
110 '#2E INC HL
120 'JR #1E
130 '#F1 LD A.L
140 'CP #FF:OCTET FAIBLE DE L'AD.DE FIN
150 'RET Z
160 'JR #2E
170 'J

1C00 06FF  LD  B,FF
1C02 210080  LD  HL,8000
1C05 2E  LD  A,(HL)
1C06 AB  XOR  B
1C07 27  LD  (HL),A
1C08 2C  LD  A,H
1C09 FES7  CP  97
1C08 2803  JR  Z,1C10
1C0D 23  INC  HL
1C0E 18F5  JR  1C05
1C10 2D  LD  A,L
1C11 FEFF  CP  FF
1C13 C8  RET  Z
1C14 18F7  JR  1C0D

10 CLS:PRINT"un instant ?"
20 FOR I=&amp;H1C00 TO &amp;H1C15
30 READ A:POKE I,VAL( &amp;H*+A*)
40 NEXT
50 DATA 06,FF,21,00,80,2E,AB,27,2C,FE,97
,20,03,23,18,FS,2D,FE,FF,C8,18,F7
60 SCREEN 5
70 PRINT"INVERSE VIDEO"
90 FOR I=0 TO 100
90 PSET (I,50):NEXT
100 EXEC&amp;H1C00
110 FOR I=0 TO 500 NEXT:GOTO 100

![img-0.jpeg](img-0.jpeg)

On reprend le même principe pour inverser l'afficheur LCD que pour inverser l'afficheur VIDEO.

On inverse octet par octet le contenu de la RAM LCD à l'aide de la fonction XOR mais un détail diffère ... En effet, vous vous rappelez sans doute que la mémoire d'écran LCD est adressée non pas par le NSC 800 mais par notre cher sous-processeur T6834 !! Résoudre ce problème nous amène à utiliser des routines d'écriture et de lecture dans la RAM LCD décrites dans le chapitre 9.

Par contre, afin de rendre le programme plus véloce, nous n'avons pas réellement tenu compte de l'adressage de la RAM ... Quoi ??? Ne vous affolez surtout pas !!

En effet, nous inversons tous les octets compris entre les adresses E000h et E1FEh. Or, nous pouvons très bien nous passer d'inverser les octets E00Fh, E01Fh et E02Fh... Mais, étant donné que les tests sur ces valeurs prendraient beaucoup plus de temps que l'inversion pure et simple de ces trois octets, nous avons préféré privilégier la vitesse d'exécution. Peu de personnes dénigreraient cette astuce connaissant la lenteur extrême de l'afficheur LCD.

ATTENTION ! Sur certaines versions du CANON X-07, il arrive que des octets échappent à l'inversion si le T6834 se trouve débordé par le flux d'informations transitant vers ses circuits... Pour pallier à ce problème, les utilisateurs possédant un X-07 fainéant peuvent se servir de la fonction N°13h décrite au paragraphe 7.6.1.

Longueur de la routine : 29 octets
Implantation de la routine : de 1C00h à 1C1Ch

FICHIER 92 : INVERSION VIDEO