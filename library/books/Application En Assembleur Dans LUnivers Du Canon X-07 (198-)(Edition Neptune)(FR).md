# Application En Assembleur Dans LUnivers Du Canon X-07 (198-)(Edition Neptune)(FR)

___
# Introduction

Report ici des codes sources du livre.\
Les programmes étant court, les espaces sont ajoutés pour rendre le code plus lisible.

___
# Les Listings

Certain listings ont pu être retrouvés chez l'association Silicium.\
On peut les retrouver aussi dans la bibliothèque "[sources]()".

Les codes L.M qui sont entre les crochets [ et ] sont pour l'assembleur 2 passes de la revue Micro Systèmes.


___
## Page 22

Exemple 1

```basic
10 GOTO 20
15   REM01234567890123456789
20 RESTORE 15 : AD% = PEEK (&H329) * 256 + PEEK (&H328) + 6
30 FOR I% = 0 TO 19 : READ B$: POKE AD%+I%,VAL("&H"+B$): NEXT I%
40 DATA 06,08,E1,10,FD,2A,15,03,E5,D1,CD,0B,F3,FD,21,00,40,C3,8A,FE
50 ON ERROR GOTO 65000
60 ' DEBUT DU PROGRAMME
100 A = 5 : B = 0 : C = A/B
64999 END
65000 PRINT "Erreur"
65010 EXEC AD%
```

NDR : Le programme est incorrect.

Programme corrigé :

```basic
10 GOTO 20
15 REM01234567890123456789
20 RESTORE 15: AD%=PEEK(&H329)*256+PEEK(&H328)+6
30 FOR I%=0 TO 19: READ B$: POKE AD%+I%,VAL("&H"+B$): NEXT I%
40 DATA 06,08,E1,10,FD,2A,15,03,E5,D1,CD,0B,F3,FD,21,00,40,C3,8A,FE
50 ON ERROR GOTO 65000
60 ' DEBUT DU PROGRAMME
100 A = 5 : B = 0 : C = A/B
110 EXEC AD%
64999 END
65000 PRINT "Erreur"
65010 END
```


Exemple 2

```basic
10 A$ = STRING$ (20,"#")
20 AD% = VARPTR (A$) : AD% = PEEK (AD% + 1) + 256 * PEEK (AD% + 2)
30 FOR I% = 0 TO 19 : READ B$ : POKE AD% + I% , VAL (" &H" + B$): NEXT I%
40 DATA 06,08,E1,10,FD,2A,15,03,E5,D1,CD,0B,F3,FD,21,00,40,C3,8A,FE
50 ON ERROR GOTO 65000
60 ' DEBUT DU PROGRAMME
100 A = 5 : B = 0 : C = A/B
64999 END
65000 PRINT "Erreur"
65005 AD% = VARPTR (A$) : AD% = PEEK (AD% + 1) + 256 * PEEK (AD% + 2)
65010 EXEC AD%
```

NDR: Même problème, coorectif à faire.

___
## Page 23

Exemple 3

```basic
10 DIM U%(9)
20 U%(0) = &H0806 : U%(1) = &H10E1 : U%(2) = &H2AFD : U%(3) = &H0315 : U%(4) = &HD1E5
30 U%(5) = &H0BCD : U%(6) = &HFDF3 : U%(7) = &H0021 : U%(8) = &HC340 : U%(9) = &HFE8A
50 ON ERROR GOTO 65000
100 D$ = 5
64999 END
65000 PRINT "Erreur"
65010 EXEC VARPTR (U%(0))
```

NDR: Même problème, coorectif à faire.

Exemple 4

```basic
10 DEFINT A-Z : N = 50 : DIM U(7) , A!(N)
15 AD = 0
20 U(0) = 8448 : U(2) = 4352 : U(4) = 256 U(6) = -20243 U(7) = 201
30 A!(0) = 100 : GOSUB 100
40 PRINT A!(0) ; A!(1) ; A!(20)
50 A!(0) = 0 : GOSUB 100
60 PRINT A!(0) ; A!(1) ; A!(20)
70 END
100 U(1) = VARPTR (A!(0)) : U(3) = VARPTR (A!(1)) U(5) = N*4
110 EXEC VARPTR (U(0)) : RETURN
```

NDR: Même problème, coorectif à faire.

___
## Page 24

Exemple 5

```basic
5 SCREEN 2 : CLS
6 LINE (0,0) - (200,180)
10 DEFINT A-Z : DIM US(7)
20 US(0) = 8448 : US(2) = 4352 : US(4) = 256 : US(6) = -20243 : US(7) = 201
30 US(1) = &H8000 : US(3) = &H8001 : US(5) = 511
40 POKE &H8000 , 64
50 EXEC VARPTR (US(0))
70 END
```

NDR: Même problème, coorectif à faire.

___
## Page 25

Exemple 6

```basic
1' ATTENTION : NE PAS RENUMEROTER ! !
10 DEFINT A-Z : CLS : PRINT "Logogénèse"
20 RM$ ; STRING$ (18,0) : GOSUB 90
30 FOR I = 0 TO 17 : READ B$ : POKE AD + I, VAL ("&H" + B$) : NEXT: Z = RND (0)
40 DATA 23 , 23 , 5E , 23 , 56 , CD , 0D , F3 , 60 , 69 , D2 , 38 , F6 , 2B , 22 , 28 , 03 , C9
45 J = INT (RND (1) * 33) + 100 : GOSUB 90
50 Z = USR (AD,J) : N = INT (RND (1) * 4 + 1)
55 FOR I = 1 TO N : READ D$ : NEXT
60 K = INT (RND (1) * 14) + 200 : GOSUB 90
65 Z = USR (AD,K) : N = INT (RND (1) * 4 + 1)
70 FOR I = 1 TO N : READ F$ : NEXT
75 PRINT D$ ; F$ : IF INKEY$ = "" TREN 45
80 IF INKEY$ = "" THEN 80 ELSE 45
90 AD = V ARPTR (RM$) : AD = PEEK (AD + 1) + 256 * PEEK (AD + 2) : RETURN
95 END
```

NDR : Consulter la gazette No 5 du Club C7.


___
## Page 32

Trace de droite.

```asm
DROITE PUSH BC		; Sauvegarde de BC (nombre de droites)
	LD A , $14		; Chargement de A avec la commande 14h
	LD BC, $400		; B contient le chiffre 4 (4 paramètres) et C contient 0 car il n'y a pas d'octet de réponse attendu
	CALL $C92F		; Appel du sous-processeur
	POP BC			; On récupère le nombre de droites ...
	DJNZ DROITE		; ... afin de vérifier si l'on a terminé ...
	RET				; ... si oui , on quitte la routine
```

___
## page 33

Implentation caractères graphiques.\
Pour les codes ASCII 80 à 9F et E0 à FF.


```asm
CRECAR	LD B nbre de car.	; Chargement de B avec le nombre de caractères à implanter
		LD HL, TCAR			; Chargement de HL avec l'adresse de début de la table des codes
CC		PUSH BC				; Sauvegarde du nombre de caractères
		LD A, $1A			; Chargement de A avec le N° de la commande
		LD BC, $900			; B contient le nombre de paramètres (9) et C le nombre d'octets attendus (0)
		CALL $C92F			; Appel du sous-processeur
		POP BC				; On récupère le nombre de caractères ...
		DJNZCC				; ... afin de vérifier si l'on a terminé ...
		RET					; ... si oui , on quitte le sous-programme
```

___
## Page 34

Test Curseur

```asm
FLECHE	CALL $COBD			; Les tampons clavier et sous-processeur sont vidés
		LD A , $82			; Commande N°2 du T6834 (STICK)
		LD BC, $1			; Un paramètre est attendu en retour
		PUSH DE				; Sauvegarde de DE (si nécessaire ... )
		LO DE, BUF			; Le registre DE est chargé avec l'adresse d'un tampon utilisateur que vous devez définir . Ce tampon sert à sauvegarder la réponse du T6834
		CALL $C92F			; Appel du T6834
		LD A, (DE)			; On charge A avec la réponse contenue dans le BUFfer utilisateur
		POP DE				; On récupère DE
		CP $33				; Curseur droit pressé ? .
		JR Z, DROITE		; si oui , saut à une routine de traitement
		CP $37				; Curseur gauche pressé ?
		JR Z, GAUCHE		; si oui , saut ...
		CP $35				; Curseur bas pressé ?
		JR Z, BAS			; si oui , saut ...
		CP $31				; Curseur haut pressé ?
		JR Z, HAUT			; si oui , saut ...
		RET					; Le registre A contient la valeur $30 si aucun curseur n'a été pressé ...
```

___
## Page 35

Test d'une touche particulière.

```asm
TOUCHE	LD HL , BUF + 4		; Le registre HL est chargé avec l'adresse du buffer utilisateur augmenté de 4
		LD (HL), A			; Le contenu de A ( code de la touche à tester) est stocké dans le buffer
		LD A, $28			; A est chargé avec la commande N°28
		LD BC , $101		; B contient le nombre de paramètres (1) et C le nombre d'octets attendus (1)
		LD DE, BUF + 2		; Le registre DE est chargé avec l'adresse du buffer augmenté de 2 unités
		CALL $C92F			; Appel du T6834
		LD A, (DE)			; A est chargé avec la réponse du T6834 stockée dans le buffer . Si A = 0 , la touche a été pressée sinon A = $FF
		ORA					; Les indicateurs Z et S "ressortent" ...
		RET					; Retour
```

Temporisation

```asm
DELAY	DEC B				; Décrémentation du registre B
		LD A, B				; Chargement de A avec B pour effectuer une comparaison
		OR C				; Test ...
		JR NZ, DELAY		; S'il fait encore nuit , on continue à temporiser !!
		RET					; Le jour se lève : fini de dormir !
```

___
## Page 36

Musique

```asm
```

___
## Page 37

SET, RESET, POINT

```asm
SET		LD A , $11			; Chargement de A avec la commande $11
		JR SETI				; Saut à la routine de traitement
POINT	LD A , $13			; Chargement de A avec la commande $13
		JR SET1				; Saut ...
RESET	LD A , $12			; Chargement de A avec la commande $12
SET1	LD HL, BUF			; Chargement de HL avec l'adresse du buffer utilisateur
		LD BC , $200		; B contient le nombre de paramètres envoyés (2) et C le nombre d'octets attendus (en l'occurence , 0)
		JP $C92F			; Le traitement graphique se fait ...
```

___
## Page 38

Input

```asm
ACQMES	LD HL , MESSAGE		; HL contient l'adresse du message qui doit être impérativement terminé par un O .
		CALL $FEF7			; Le message est affiché ...
		CALL $EBF2			; L'entrée clavier est obtenue .
		INC HL				; On incrémente HL pour obtenir le début du tampon d'entrée étant donné que la routine $EBF2 fait pointer HL sur cette adresse - 1 .
		LD DE, BUF			; DE est chargé avec l'adresse du tampon utilisateur
		LD C, 0				; C = compteur
ACQ		LD A, (HL)			; Transfert vers tampon interne
		LD (DE), A			; suite du transfert
		OR A				; Test du O situé en fin de "A$"
		JR Z, ACQ2			; Saut à ACQ2 si réalisé
		INC HL				; caractère suivant
		INC DE				;         "
		INC C				; incrémentation de C
		LD A,C				; Longueur maximale atteinte ?
		CP 20				; Test sur la longueur (ici 20)
		JR C, ACQ			; Si la longueur est atteinte , on sort de la boucle ...
ACQ2	LD A ,C				; 
		CP 0				; Si la chaîne est vide , on recommence ...
		JR Z, ACQMES		; 
		LD(LONG),A			; Sauvegarde de la longueur
		RET					; Retour
```

___
## Page 39

Entrée d'un nombre

```asm
ACQNUM	LD HL , MESSAGE		; 
		CALL $FEF7			; Affichage du message et entrée clavier
		CALL $EBF2			; 
		RST $10				; Teste si un nombre a bien été entré ...
		CALL $F595			; Transfère le nombre dans le registre DE
```

Utilisation X-710

```asm
		LD HL , CHAINE		; HL est chargé avec l'adresse du début de la chaîne
LPRINT	LD A , (HL)			; A est chargé avec l'un des codes de la chaîne
		OR A				; Test afin de savoir si le dernier code a été
		RETZ				; envoyé vers la X-710
		PUSH HL				; Sauvegarde de l'adresse des codes
		CALL $CEF7			; Transmission du code contenu dans A
		POP HL				; On récupère l'adresse du prochain code
		INC HL				; Incrémentation du registre HL
		JR LPRINT			; On continue le cycle ...
```

___
## Page 55

```basic
10 REM LES 2
20 FOR I=&H1A00 TO &H1A0B
30 READ A$:POKE I,VAL("&H"+A$):NEXT
50 RESTORE 700
60 FOR I=&H1800 TO &H184C
70 READ A$:POKE I,VAL("&H"+A$):NEXT
90 EXEC &H1A00: EXEC &H1800
500 DATA 3E,C3,32,66,00,21,20,1B,20
501 DATA 67,0,C9
700 DATA 3E,0,3C,21,2,5,22,B8,0
701 DATA C0,BE,C1,C1,11,1B
710 DATA 18,F1,F5,C5,3E,7F,6,FF,5
711 DATA 20,F0,30,20,F8
720 DATA C1,F1,C9,F5,C5,D5,E5,21,1
721 DATA 1,22,B8,0,21
730 DATA 3C,18,CD,F7,FE,CD,J1,18,C1
731 DATA 9E,CE,El,D1
740 DATA C1,F1,ED,40,49,4E,54,45,5
741 DATA 55,50,54,49,4F,4E,20,21
750 DATA 21,21,2 1,0
```
Code à revoir car scan tronqué.


___
## Page 56

```asm
10  '[
20  ' ORG $1800
30  '***********************************
40  '**     CHent du saut pour NMI     *
50  '***********************************
60  'LD A.$C3
70  'LD ($66).A
80  'LD HL.#DB
90  'LD ($67).HL
100 'RET
110 '**********************************
120 '**      LA ROUTINE DE BEEP       *
130 '**********************************
140 '#DB LD A,$07:*"BELL=CHR$(07)
150 'CALL $C1BE
160 'RETI
170 ']
```

```basic
5 REM LE BEEP
10 FOR I=&H1B00 TO &H1B12
20 READ A$:POKE I,VAL("&H"+A$)
30 NEXT
40 CLS: PRINT"COURT-CIRCUITEZ LES BROCHES"
50 FOR I=1 TO 10000
60 LOCATE 10,2: PRINT I
70 NEXT
100 DATA 3E,C3,32,66,00,21,0,15
101 DATA 22,67,0,C9
102 DATA 3E,7,CD,BE,C1,ED,40
```


___
## Page 60


```asm
10 '[
20 ' ORG $1C00				; 
30 ' LD DE.$E987			; Adresse de tableau du dispositif CASO .
40 ' LD IY.$02C5			; Adresse de la partie spécialisée de la RAM .
50 ' LD A.$00				; Mise à 0 du registre A .
60 ' CALL $E6A8				; Appel d'ouverture du dispositif .
70 ' RET					; 
80 ']
```

```
10 ' [
20 ' ORG $1C00
30 ' LD DE.$E796
40 ' LD IY.$02C5
50 ' LD A.$00
60 ' CALL $E6A8
65 ' IN A.($F4)				;  Le démarrage du magnétophone nécessite la
66 ' SET 0.A				; mise à 1 du bit D0 du port F4 (lignes 65 à
70 ' OUT ($F4).A			; 70).
80 ' CALL #TP				; Temporisation ...
90 ' CALL #TP
100 ' LD DE.$02C5
110 ' CALL $E827			; On assigne la sortie CASO
120 ' LD A.$00				; Les lignes 120 à 170 signalent le début des
130 ' CALL $E88F			; données par un triple 0
140 ' LD A.$00
150 ' CALL $E88F
160 ' LD A.$00
170 ' CALL $E88F

180 ' LD HL.#DD				; Les lignes 180 à 230 constituent la sortie
190 ' #ST LD A.(HL)			; des données ...
200 ' CP $00
210 ' JR Z.#TE
220 ' CALL $E88F
225 ' INC HL
230 ' JR #ST
240 ' #TE LD A.$FF			; Les lignes 240 à 290 signalent la fin des
250 ' CALL $E88F			; données par un triple 255 ...
260 ' LD A.$FF
270 ' C ALL $E88F
280 ' LD A.$FF
290 ' CALL $E88F
291 ' CALL #TP				; Les lignes 291 à 294 constituent l'arrêt du
292 ' IN A.($F4)			; magnétophone ...
293 ' RES 0.A
294 ' OUT ($F4).A
300 ' RET
310 ' #TP PUSH BC			; Les lignes 310 à 390 signalent constituent la boucle
320 ' LD B.$00				; de temporisation .
330 ' #E1 LD C.$FF
340 ' #E2 DEC C
350 ' JR NZ.#E2
360 ' DEC B
370 ' JR NZ.#E1
380 ' POP BC
390 ' RET
400 '#DD DEFB $01 ,02 , 03 , 04 , 05 , 06 , 00		; données
410 ']
```

___
## Page 61

```basic
10 FOR I=&H1C00 TO &H1C00+103
20 READ A$ : POKE I,VAL("&H"+A$)
30 NEXT I
40 PRINT "EXEC &H1C00 POUR DEMARRER LE PROGRAMME"
50 DATA 11,96,E7,FD,21,C5,2,3E,0,CD,A8,E6,DB,F4,CB,C7
60 DATA D3,F4,CD,54,1C,CD,54,1C,11,CS,2,CD,27,E8,3E,0
70 DATA CD,8F,E8,3E,0,CD,8F,E8,3E,0,CD,8F,E8,21,61,1C
80 DATA 7E,FE,0,28,6,CD,8F,E8,23,18,F5,3E,FF,CD,8F,E8
90 DATA 3E,FF,CD,8F,E8,3E,FF,CD,8F,E8,CD,54,1C,DB,F4
100 DATA CB,87,D3,F4,C9,C5,6,7F,E,FF,D,20,FD,5,20,F8
110 DATA C1,C9,1,2,3,4,5,6,0
```

NDR : Modifié pour être plus lisible


___
## Page 62

```asm
10 ' [
20 ' ORG $1C00
30 ' * INIT#1,"CASI:"			; Les lignes 30 à 70 initialisent le dispositif 1
40 ' LD DE.$E787				; en tant que "CASI" .
50 ' LD IY.$2C5
60 ' LD A.$0
70 ' CALL $E6A8
80 ' * Démarrage du magnétophone
90 ' IN A.($F4 )
100 ' SET 0.A
110 ' OUT ($F4 ).A
120 ' * On assigne CASI :
130 ' LD DE.$2C5
140 ' CALL $E827
150 ' * Entrées des données			; Le triple 0 est recherché des lignes 150 à
160 ' #E1 CALL $E8D4				; 210 ...
170 ' JR NZ.#E1
180 ' CALL $E8D4
190 ' JR NZ.#E1
200 ' CALL $E8D4
210 ' JR NZ.#E1
220 ' LD HL.$1B00					; Les lignes 220 à 28 0 constituent la
230 ' #E2 CALL $E8D4				; recherche de la fin des données ....
240 ' CP $FF
250 ' JR Z.#FI
260 ' LD (HL).A
270 ' INC HL
280 ' JR #E2
290 ' #FI CALL $E8D4				; Si le code suivant le premier $FF n'est pas
300 ' CP $FF						; $FF , on écrit le code dans la mémoire
310 ' JR Z.#F1						; (lignes 290 à 320) .
320 ' LD A.(HL)
330 ' INC HL						; On incrémente le pointeur et on continue le
340 ' JR #E2						; chargement ...
350 ' #F1 CALL $E8D4				; Si le deuxième code est $FF, on vérifie le
360 ' CP $FF						; troisième ... lignes 350 à 400 .
370 ' JR Z.#F2
380 ' LO A.(HL)
390 ' INC HL
400 ' JR Z.#E2
410 ' * Arrêt magnétophone
420 ' #F2 IN A.($F4)
430 ' RES 0.A
440 ' OUT ($F4).A
450 ' RET
460 ']
```

NDR : ajout de la ligne 460.

___
## Page 64


```basic
10 FOR I=&H1C00 TO &H1C00+82
20 READ A$ : POKE I,VAL("&H"+A$)
30 NEXT I
40 PRINT "EXEC &H1C00 POUR DEMARRER LE PROGRAMME"
50 DATA 11,87,E7,FD,21,CS,02,3E,00,CD,A8,E6,DB,F4,CB
60 DATA C7,D3,F4,11,CS,02,CD,27,E8,CD,D4,E8,20,PB,CD,D4,E8
70 DATA 20,F6,CD,D4,ES,20,F1,21,00,1B,CD,D4,E8,FE,FF,28,04
80 DATA 77,23,18,F5,CD,D4,E8,FE,FF,28,04,7E,23,18,EA,CD,D4
90 DATA E8,8F,FE,FF,28,04,7E,23,18,DF,DB,F4,CB,87,D3,F4,C9
```

NDR : Modifié pour être plus lisible

___
## Page 65

Fichiers GPR et KBD


```asm
10  ' [
20  ' ORG $1C00				; Les lignes 20 à 70 constituent l'initialisation
30  ' * INIT #1,"GPR:"		; du dispositif 1 ...
40  ' LD DE.$E7B2			; 
50  ' LD IY.$02C5			; 
60  ' LD A.$0				; 
70  ' CALL $F6A8			; 
80  ' * INIT #2,"KBD:"		; Les lignes 80 à 120 représentent l'initialisation
90  ' LD DE.$E778			; du dispositif n°2 .
100 ' LD IY.$02CD			; 
110 ' LD A.$0				; 
120 ' CALL $E6A8			; 
130 ' * Assignation de KBD	; Entrées sur la console ...
140 ' #BL LD DE.$2CD		; 
150 ' CALL $E827			; 
170 ' CALL $E8D4			; Entrée d'une touche ...
175 ' PUSH AF				; 
190 ' LD DE.$2C5			; Les sorties se font sur l'imprimante
200 ' CALL $E827			; 
205 ' POP AF				; 
206 ' CP $0E				; Si on appuie sur CTRL N , on arrête
207 ' RETZ					; 
210 ' CALL $E88F			; Sinon , écriture sur l'imprimante .
220 ' JR #BL				; 
230 ' ]
```


```basic
10 FOR I=&H1C00 TO &H1C00+48
20 READ A$: POKE I,VAL("&H"+A$): NEXT
40 PRINT "EXEC &H1C00 pour démarrer ... "
50 DATA 11,F8,E7,FD,21,CS,02,3E,00,CD,A8,E6,11,78,E7
60 DATA FD,21,CD,02,3E,00,CD,A8,E6,11,CD,02,CD,27,E8,CD,D4
70 DATA E8,F5,11,CS,02,CD,27,E8,F1,FE,0E,C8,CD,8F,E8,18,E7
```

NDR : Modifié pour être plus lisible

___
## Page 66

Prise SERIE


```asm
10  ' [
20  ' ORG $1C00				; 
30  ' LD DE.$E7A4			; Dispositif COM activé
40  ' LD A.$0				; 
50  ' LD B."G"				; Mode G de l'ACIA
60  ' LD IX.&1200			; Vitesse : 1200 bauds
70  ' LD IY.$2C5			; 
80  ' CALL $E6A8			; Ouverture ...
85  ' LD DE.$2C5			; 
86  ' CALL $E827			; 
87  ' LD HL.#ME				; Ecriture du message ...
90  ' #ET LD A.(HL)			; 
91  ' CP $0					; 
92  ' JR Z.#FI				; 
100 ' CALL $E88F			; 
105 ' INC HL				; 
106 ' JR #ET				; 
120 ' #FI RET				; 
124 ' #ME DEFB &12			; 
125 ' DEFM Cela marche bien comme cela ...
126 ' DEFB $00				; 
130 ' ]
```

___
## Page 67


```basic
10 FOR I=&H1C00 TO &H1C00+63
20 READ A$: POKE I,VAL("&H"+A$): NEXT
40 PRINT "EXEC &H1C00 pour démarrer ... "
60 DATA 11,A4,E7,3E,00,06,47,DD,21,BO,04,FD,21,CS,02
70 DATA CD,A8,E6,11,C5,02,CD,27,E8,21,27,1C,7E,FE,00,28,06
80 DATA CD,8F,E8,23,18,F5,C9,0C,43,41,20,4D,41,52,43,48
90 DATA 45,20,42,49,45,4E,20,43,4F,4D,4D,45,20,43,41,00
```

NDR : Modifié pour être plus lisible

Lecture Série


```asm
20  ' [
30  ' ORG $1C00				; 
40  ' LD DE.$E7A4			; Les lignes 40 à 90 initialisent le 1er fichier
50  ' LD A.$0				;à COM .
60  ' LD B."G"				; 
70  ' LD IX.&1200			; 
80  ' LD IY.$2C5			; 
90  ' CALL $E6A8			; 
100 ' LD DE.$2C5			; Les lignes 100 à 110 assignent l'entrée .
110 ' CALL $E827			; 
120 ' CALL $E8D4			; Caractère entré dans A .
130 ' CALL $C1BE			; Caractère affiché à l'écran
140 ' RET					; 
150 ' ]
```

___
## Page 68


```basic
20 FOR I=&H1C00 TO &H1C00+29
30 READ A$: POKE I,VAL("&H"+A$): NEXT
50 PRINT "EXEC &H1C00 pour démarrer ... "
60 DATA 11,A4,E7,3E,00,06,47,DD,21,B0,04,FD,21,C5,02,CD
70 DATA A8,E6,11,CS,02,CD,27,E8,CD,D4,E8,CD,DE,C1,C9
```

___
## Page 81

Concerne l'extension X-720.

Figure 12

Dans le code BASIC il y a un RET et pas dans les ASM, donc ajout.

```asm
10 ' [
20 ' ORG $1C00
30 ' * TEST DE LA PRESENCE DE LA X-720
40 ' LD A,$80
50 ' LD ($8000).A : * DEBUT VRAM
60 ' LD A.($8000)
70 ' CP $80
80 ' JP NZ.$F1AA: * SAUT EN ERREUR
90 ' RET
100 ' ]
```

```asm
1C00	3E 80			LD A,80
1C02	32 00 80		LD (8000),A
1C05	3A 00 80		LD A,(8000)
1C08	FE 80			CP 80
1C0A	C2 AA F1		JP NZ,F1AA
1C0D	C9
```

```basic
10 REM TEST DE LA X-720
20 FOR I=&H1C00 TO &H1C0D
30 READ A$: POKE I,VAL("&H"+A$)
40 NEXT I
50 DATA 3E,80,32,00,80,3A,00,80,FE,80
60 DATA C2,AA,F1,C9
```

Figure 13

```
10 ' [
20 ' ORG $1C00
30 ' * EFFACEMENT PARTIEL DE L' ECRA
40 ' CALL #SC : * EFFACEMENT DE LA
50 ' CALL $CE9E : * 8 ème LIGNE à LA FI
60 ' LD HL.$108
70 ' LD ($B8).HL : * CURSEUR (Cl , L8 )
80 ' RET
90 ' #SC LD A.$8 : * Ligne de roulemen1
100 ' LD ($BB).A
110 ' LD A.&16 : * DERNIERE LIGNE
120 ' LD ($BC).A
130 ' LD A.(&16-8+1) : * Nb de lignes
140 ' LD ($BD).A
150 ' RET
160 ' ]
```

```asm
1C00 CD 0D 1C			CALL 1C0D
1C03 CD 9E CE			CALL CE9E
1C06 21 08 01			LD HL,0108
1C09 22 B8 00			LD (00B8),HL
1C0C C9					RET
1C0D 3E	08				LD A,08
1C0F 32	BB 00			LD (00BB),A
1C12 3E 10				LD A,10
1C17 3A 10 00			LD A,(0010)
1C14 32 BC 00			LD (00BC),A
1C1A 32 BD 00			LD (00BD),A
1C1D C9 RET
```

```basic
0 REM EFFACEMENT PARTIEL
20 FOR I=&H1C00 TO &H1C1D
30 READ A$: POKE I,VAL("&H"+A$)
40 NEXT I
50 DATA CD,0D,1C,CD,9E,CE,21,08,01,22,B8,00,C9
60 DATA 3E,08,32,BB,00,3E,10,32,BC,00,3A,10,00
70 DATA 32,BD,00,C9
```

___
## Page 82

Figure 14

```asm
10 ' [
20 ' ORG $1C00
30 ' *** SCREEN ***
40 ' LD A.$00 : * SCREEN 1
50 ' LD ($D1).A
60 ' LD C.A
70 ' LD A.$01
80 ' LD D.A : * PAGE ACTIVE - 1
90 ' LD E.A : * PAGE VISUELLE - 1
100 ' JP $AB09
110 ' ]
```

```asm
1C00 3E 00			LD A,00
1C02 32 D1 00		LD (00D1),A
1C05 4F				LD C,A
1C06 32 01			LD A,01
1C08 57				LD D,A
1C09 SF				LD E,A
1C0A C3 09 AB		JP AB09
```

```basic
10 REM *** SCREEN ***
20 FOR I=&H1C00 TO &H1C0C
30 READ A$: POKE I,VAL("&H"+A$)
40 NEXT I
50 DATA 3E,00,32,D1,00,4F,3E,01,57
60 DATA 5F,C3,09,AB
```


Figure 15

```
10 ' [
20 ' ORG $1C00
30 ' *** COULEUR ***
40 ' LD A.$01
50 ' LD ($4E5).A : * COULEUR LETTRES
60 ' LD A.$02
70 ' LD ($4E6).A
80 ' LD A.$00
90 ' LD ($4E7).A : * PALETTE 0 ou 2
100 ' RET
110 ' ]
```

```asm
1C00 3E 01			LD A,01
1C02 32 E5 04		LD (04E5),A
1C05 3E 02			LD A,02
1C07 32 E6 04		LD (04E6),A
1C0A 3E 00			LD A,00
1C0C 32 E7 04		LD (04E7),A
1C0F C9				RET
```

```basic
10 REM *** COLOR ***
20 FOR I=&H1C00 TO &H1C0F
30 READ A$: POKE I,VAL("&H"+A$)
40 NEXT I
50 DATA 3E,01,32,E5,04,3E,02,32,E6,04
60 DATA 3E,00,32,E7,04,C9
```



___
## Page 87

Figure 16 : LMDATA

```basic
1 REM Ecriture automatique de codes LM en DATA
10 CLEAR 50,&H1F00: DEFINT A-Z: LL=16: CA=48: CLS
20 INPUT"Adres. debut routine";DM: DD=DM
30 INPUT"Adresse fin routine";FM: NC=FM-DM+1: JC=INT(NC/LL)
40 RESTORE 10000: AD=PEEK(&H328)+256*PEEK(&H329)+6
50 LB=LL: FOR J=1 TO JC
55 PRINT"LIGNE";10000+10*J
60 GOSUB 200: AD=AD+5: NEXT J
70 LB=NC-JC*LL: IF LB=0 THEN 100
80 GOSUB 200
90 PRINT"Effacer la fin de la ligne";10000+10*JC
100 PRINT"Effacer les lignes";10000+10*(JC+1);"‰";10150;
110 IF INKEY$="" THEN 110
120 END
200 FOR I=1 TO LB: VC=PEEK(DM): DM=DM+1
210 C=INT(VC*.01): D=INT((VC-100*C)/10): U=VC-10*D-100*C
220 POKE AD,C+CA: POKE AD+1,D+CA: POKE AD+2,U+CA: AD=AD+4
230 NEXT: RETURN
10000 DATA...,...,...,...,...,...,...,...,...,...,...,...,...,...,...,...
10010 DATA...,...,...,...,...,...,...,...,...,...,...,...,...,...,...,...
10020 DATA...,...,...,...,...,...,...,...,...,...,...,...,...,...,...,...
10030 DATA...,...,...,...,...,...,...,...,...,...,...,...,...,...,...,...
10040 DATA...,...,...,...,...,...,...,...,...,...,...,...,...,...,...,...
10050 DATA...,...,...,...,...,...,...,...,...,...,...,...,...,...,...,...
10060 DATA...,...,...,...,...,...,...,...,...,...,...,...,...,...,...,...
10070 DATA...,...,...,...,...,...,...,...,...,...,...,...,...,...,...,...
10080 DATA...,...,...,...,...,...,...,...,...,...,...,...,...,...,...,...
10090 DATA...,...,...,...,...,...,...,...,...,...,...,...,...,...,...,...
10100 DATA...,...,...,...,...,...,...,...,...,...,...,...,...,...,...,...
10110 DATA...,...,...,...,...,...,...,...,...,...,...,...,...,...,...,...
10120 DATA...,...,...,...,...,...,...,...,...,...,...,...,...,...,...,...
10130 DATA...,...,...,...,...,...,...,...,...,...,...,...,...,...,...,...
10140 DATA...,...,...,...,...,...,...,...,...,...,...,...,...,...,...,...
10150 DATA...,...,...,...,...,...,...,...,...,...,...,...,...,...,...,...
```
NDR : version avec ajout d'espaces pour la lisibilité.


Figure 17 : EXEMPLE

```basic
1 REM Exemple de RESTORE CALCULE.
2 REM Cree par LMDATA
10 CLEAR 50,&H1FFF: DEFINT A-Z
20 RESTORE 10000
30 FOR I=0 TO 17: READ A: POKE &H2000+I,A: NEXT
40 INPUT"N= (1..3)";N
50 IFN<1 OR N>3 THEN 40
60 J=N*100
70 Z=USR(&H2000,J)
80 READ A$: PRINT A$: GOTO 40
100 DATA"lecture DATA 100"
200 DATA"lecture DATA 200"
300 DATA"lecture DATA 300"
999 END
10000 DATA 035,035,094,035,086,205,013,243,096,105,210,056,246,043,034,040
10010 DATA 003,201
```

___
## Page 88

Figure 18 : Logo CANON

```basic
5 REM EXEMPLE DE GRAPHISME - DATA STOCKEES AVEC LMDATA
10 CLEAR 200: DEFINT A-Z
20 X=23: CLS
30 FOR L=6 TO 25
40 A1=1: F=1
50 READ A: A1=A1+A: IF F=1 THEN 70
60 F=1: GOTO 80
70 FOR I=A1-A TO A1-1: PSET(X+I,L): NEXT: F=0
80 IF A1=<79 THEN 50
90 NEXT
100 END
110 DATA 79,9,4,66,8,6,65,6,10,63
120 DATA 5,12,7,4,9,3,3,2,7,7,6,3,3,2,6
130 DATA 4,6,6,2,5,6,7,5,1,4,5,9,4,5,1,4,5
140 DATA 4,5,6,4,2,9,4,13,3,2,3,6,1,13,4
150 DATA 3,6,6,2,10,3,6,5,2,5,2,3,2,6,3,5,2,5,3
160 DATA 3,5,6,1,12,4,5,5,2,5,1,4,3,6,2,5,2,5,3
170 DATA 3,5,15,8,5,5,2,5,1,4,3,6,2,5,2,5,3
180 DATA 3,5,14,10,4,5,2,5,1,5,3,5,2,5,2,5,3
190 DATA 3,5,13,5,2,4,4,5,2,5,1,5,3,5,2,5,2,5,3
200 DATA 3,6,11,5,4,4,3,5,2,5,1,6,3,4,2,5,2,5,3
210 DATA 4,5,9,1,1,5,4,4,3,5,2,5,1,6,3,4,2,5,2,5,3
220 DATA 4,6,6,2,2,6,2,6,2,5,2,5,2,6,2,3,3,5,2,5,3
230 DATA 5,12,4,8,1,4,2,5,2,5,2,6,3,2,3,5,2,5,3
240 DATA 6,10,6,6,2,5,1,5,2,5,3,9,4,5,2,5,3
250 DATA 8,6,9,4,3,5,1,5,2,5,4,7,5,5,2,5,3,79,79
```

Figure 19 : Copie rapide

```basic
1 REM Copie cran
2 REM Mthode de la chaine
3 REM DATA cres par LMDATA.
10 CLEAR 100: DEFINT A-Z
20 CH$=STRING$(53,"£")
30 GOSUB 300
40 FOR I=0 TO 52: READ A: POKE AD+I,A: NEXT
100 PRINT" Copie rapide de l'"
110 PRINT"     ecran sur"
120 PRINT" l'imprimante X-710"
130 PRINT"       +++";
200 GOSUB 300:EXEC AD
210 END
300 AD=VARPTR(CH$): AD=PEEK(AD+1)+256*PEEK(AD+2): RETURN
10000 DATA006,000,033,020,002,197,229,001,019,000,009,126,254,032,032,004
10010 DATA043,013,032,247,012,225,229,126,004,035,229,197,205,247,206,193
10020 DATA225,120,185,032,242,205,176,207,225,001,020,000,009,193,004,120
10030 DATA254,004,032,209,201
```

___
## Page 90

FIGURE 20 : Logogenese

```basic
1 'ATTENTION NE PAS RENUMEROTER
10 DEFINT A-Z: CLS: PRINT"Logognse"
20 RM$=STRING$(18,0): GOSUB 90
30 FOR I=0 TO 17: READ B$: POKE AD+I, VAL("&H"+B$): NEXT: Z=RND(0)
40 DATA 23,23,5E,23,56,CD,0D,F3,60,69,D2,38,F6,2B,22,28,03,C9
45 J=INT(RND(1)*33)+100: GOSUB 90
50 Z=USR(AD,J): N=INT(RND(1)*4+1)
55 FOR I=1 TO N: READ D$: NEXT
60 K=INT(RND(1)*14)+200: GOSUB 90
65 Z=USR(AD,K): N=INT(RND(1)*4+1)
70 FOR I=1 TO N: READ F$: NEXT
75 PRINT D$;F$: IF INKEY$="" THEN 45
80 IF INKEY$="" THEN 80 ELSE 45
90 AD=VARPTR(RM$): AD=PEEK(AD+1)+256*PEEK(AD+2): RETURN
95 END
100 DATA AERO,AGRO,AMBI,ANDRO
101 DATA ANTI,ASTRO,BIBLIO,BIO
102 DATA CACO,CALLI,CLEPTO,CHIMIO
103 DATA CHRONO,CINE,COPRO,COSMO
104 DATA CRYO,CRYPTO,DECI,DECA
105 DATA HEMI,DERMO,DEXTRO,DODECA
106 DATA DROMO,DYNAMO,DYS,ECTO
107 DATA ELECTRO,EMBRYO,ENTOMO
108 DATA ERGO,EROTICO,GASTRO,GEO
109 DATA GLOSSO,GONIO,GONO,GYMNO
110 DATA HECTO,HELIO,HEMATO,HETERO
111 DATA HIERO,HIPPO,HOLO,HOMEO
112 DATA HOMO,HYDRO,HYPER,HYPO
113 DATA ICONO,IDEO,INFRA,ISO
114 DATA INTRA,LATERO,LIPO,LOGO
115 DATA LOXO,MACRO,MEGALO,METEO
116 DATA META,§ICRO,MKsO,MNEMO
117 DATA MORPHO,MYTHO,NECRO,NEO
118 DATA NOSO,NUGLEO,OCTO,OLEO
119 DATA OMNI,ORTHO,PALEO,PAN
120 DATA PARA,PAPYRO,PATHO,PEDO
121 DATA PENTA,PERI,PETRO,PHAGO
122 DATA PHALLO,PHANERO,PHILO,PHYTO
123 DATA PHOBO,PHONO,PHOTO,PHRENO
124 DATA PHYSIO,POLY,MONO,HEMI
125 DATA PORNO,POST,PROTO,PSEUDO
126 DATA PSYCHO,RADIO,RETRO,RHINO
127 DATA SADO,STEREO,SCLERO,SEMI
128 DATA SCHIZO,SIMILI,SPELEO,STENO
129 DATA SUB,SUPRA,SUPER,TACHY
130 DATA TECHNO,TELE,TELEO,THEO
131 DATA THERMO,TRIBO,ULTRA,VIDEO
132 DATA XENO,XYLO,ZOO,MINI
200 DATA ALGIE,CARDE,CINESE,CEPHALE
201 DATA CLASTE,COSMOS,CYCLE,DACTYLE
202 DATA DERME,DIDACTE,DOXE,DROME
203 DATA DYNE,FUGE,GAME,GASTRE
204 DATA GLOTTE,GENESE,GENE,GRADE
205 DATA GYNE,LATERE,LATRE,LOGIE
206 DATA LOGUE,MANCIE,MANE,MANIE
207 DATA MATIQUE,MEGALIE,METRIE,MNESIE
208 DATA MORPHE,NAUTE,NEVROSE,NOMIE
209 DATA PATHE,PHAGE,PHANIE,PHILE
210 DATA PHOBE,PHONE,PNEE,PYGE
211 DATA RRHEE,SCAPHE,SCOPE,SCOPIE
212 DATA STASE,STENIE,THEISME,TONIQUE
213 DATA TROPE,TYPE,VORE,TIQUE
```

___
## Page 92

LLIST

```asm
DEB			LD HL,($212)			; HL contient l'adresse du fond de la mémoire
			DEC HL					; 
			LD BC,fin-début			; Longueur à déplacer
			XOR A					; Mise du drapeau CARRY à 0
			SBC HL,BC				; HL contient l'adresse du début du programme
			PUSH HL					; 
			PUSH HL					; Empilages pour usages ultérieurs
			PUSH HL					; 
			CALL $CE9E				; Effacement de l'écran
			LO HL,MSG1				; Affichage sur l'écran LCD du message :
			CALL $FEF7				; "NOTEZ AD=....."
			POP HL					; 
			CALL $BB98				; Affichage de AD en décimal
			LO HL,MSG2				; Affichage sur l'écran LCD du message :
			CALL $FEF7				; "Pressez une touche"
KEY			XOR A					; 
			CALL $C90A				; Attente de la pression d'une touche
			JR Z,KEY				; 
			POP HL					; HL contient le début après transfert
			LO DE,début				; DE contient le début après transfert
			XOR A					; 
			SBC HL,DE				; HL = offset
			PUSH HL					; 
			POP BC					; BC = offset
			LD IX,table				; Table des adresses à modifier

DEB0		LD L,(IX+0)				; 
			LD H,(IX+1)				; HL = adresse à modifier
			LD E,(HL)				; 
			INC HL					; 
			LD D,(HL)				; DE = contenu à modifier
			DEC HL					; Réajustement de HL
			PUSH HL					; Sauvegarde de l'adresse à modifier
			EX DE,HL				; HL = contenu à modifier
			ADD HL,BC				; HL = HL + offset
			EX DE,HL				; DE = valeur modifiée
			POP HL					; Récupération de l'adresse à modifier
			LD (HL),E				; 
			INC HL					; Modification effectuée
			LD (HL),D				; 
			INC IX					; Adresse suivante de la table
			INC IX					; Adresse suivante de la table
			LD A,(IX+0)				; 
			CP 0					; Fini ?
			JR NZ,DEB0				; Si ce n'est pas terminé , on boucle ...
			POP DE					; ... Sinon DE = adresse début (MEM haute)
			LD HL,début				; HL = adresse début (MEM basse)
			LD BC,fin-début			; Longueur à transfére
			LDIR					; Transfert du programme modifié
			LD HL,DEB				; 
			LD A,$C3				; On écrit à la place de DEB les codes
			LD B,3					; "C3C3C3" afin de rendre le relocateur
DEB1		LD (HL),A				; inutilisable
			INC HL					; 
			DJNZ DEB1				; 
			JP $C3C3				; Retour au BASIC
MSG1		DB 'NOTEZ AD=',0		; 0 est le terminateur pour la routine FEF7
MSG2		DB 'Pressez ..."',0		; Message "Pressez une touche"
TABLE		DW A1+1 , .....
			DB 0					; Fin de la table
```

Exemple de programme à reloger :

```asm
DEBUT		CALL $CE9E
A1			LD HL,MSIMP				;Première adresse à modifier
			CALL $FEF7
			.....
FIN			EQU $					; Fin du logiciel à reloger
```

Figure 21 : LLIST

```asm
to do
```

___
## Page 95

Figure 22 : Chargeurs

```basic
0 CLEAR 50,&H7FF
20 INIT#1,"CASI:"
30 INPUT#1,N$,D,F
40 MOTOR
50 PRINT"Trouv :";N$
60 FOR I=D-1 TO F
70 POKE I,INP(#1)
80 NEXT: MOTOR
90 END
100 CLEAR 50,&H7FF
110 D=&H800 : F=&HA29
120 N$="LLIST": INIT#1,"CASO:"
130 INPUT"Magnto OK";T$
140 PRINT#1,N$,D,F: MOTOR
150 FOR I=1 TO 1800: NEXT
160 FOR I=D TO F: OUT#1,PEEK(I)
170 NEXT: MOTOR
180 END
```

```basic
5 ' *** ENTREUR DE CODES ***
10 CLEAR 50,&H7FF: A=&H800
20 PRINT HEX$(A);" : ";: INPUT C$
30 V=VAL("&H"+C$): POKE A,V
49 A=A+1: IF A>&HA29 THEN PRINT "...": BEEP 2,3: END
50 GOTO 20
```

Figure 23 : Exemple

Listing logo Canon

```basic
10 CLEAR 200: DEFINT A-Z
20 X=23: CLS
30 FOR L=6 TO 25
40 A1=1: F=1
50 READ A: A1=A1+A: IF F=1 THEN 70
60 F=1: GOTO 80
70 FOR I=A1-A TO A1-1: PSET(X+I,L): NEXT: F=0
80 IF A1=<79 THEN 50
90 NEXT
100 END
110 DATA 79,9,4,66,8,6,65,6,10,63
120 DATA 5,12,7,4,9,3,3,2,7,7,6,3,3,2,6
130 DATA 4,6,6,2,5,6,7,5,1,4,5,9,4,5,1,4,5
140 DATA 4,5,6,4,2,9,4,13,3,2,3,6,1,13,4
150 DATA 3,6,6,2,10,3,6,5,2,5,2,3,2,6,3,5,2,5,3
160 DATA 3,5,6,1,12,4,5,5,2,5,1,4,3,6,2,5,2,5,3
170 DATA 3,5,15,8,5,5,2,5,1,4,3,6,2,5,2,5,3
180 DATA 3,5,14,10,4,5,2,5,1,5,3,5,2,5,2,5,3
190 DATA 3,5,13,5,2,4,4,5,2,5,1,5,3,5,2,5,2,5,3
200 DATA 3,6,11,5,4,4,3,5,2,5,1,6,3,4,2,5,2,5,3
210 DATA 4,5,9,1,1,5,4,4,3,5,2,5,1,6,3,4,2,5,2,5,3
220 DATA 4,6,6,2,2,6,2,6,2,5,2,5,2,6,2,3,3,5,2,5,3
230 DATA 5,12,4,8,1,4,2,5,2,5,2,6,3,2,3,5,2,5,3
240 DATA 6,10,6,6,2,5,1,5,2,5,3,9,4,5,2,5,3
250 DATA 8,6,9,4,3,5,1,5,2,5,4,7,5,5,2,5,3,79,79
```

___
## Page 98

Figure 24 : Labyrinthe 3D

```
to do
```

Figure 25 : Chargeurs

Programme 1

```basic
2 '*** PROGRAMME 1 ***
5 '*** CHARGEUR BASIC ***
10 CLEAR 50,&H7F0
20 INIT#1,"CASI:"
30 INPUT#1,N$,D,F
40 MOTOR
50 PRINT"Trouv :";N$
60 FOR I=D-1 TO F
70 POKE I,INP(#1)
80 NEXT: MOTOR
90 END
100 CLEAR 50,&H7F0
110 D=&H800: F=&H1012
120 N$="PLABIR": INIT#1,"CASO:"
130 INPUT"Magnto OK";T$
140 PRINT#1,N$,D,F: MOTOR
150 FOR I=1 TO 1800: NEXT
160 FOR I=D TO F: OUT#1,PEEK(I)
170 NEXT: MOTOR
180 END
```

Programme 2

```basic
2 '*** PROGRAMME 2 ***
5 ' *** ENTREUR DE CODES ***
10 CLEAR 50,&H7FF: A=&H800
20 PRINT HEX$(A);" : ";: INPUT C$
30 V=VAL("&H"+C$): POKE A,V
49 A=A+1: IF A>&H1012 THEN PRINT "...": BEEP 2,3: END
50 GOTO 20
```

___
## Page 103

Figure 26 : Solitaire

```
```

Figure 27

Programme 1

```basic
10 CLEAR 50,&H7FF
20 INIT#1,"CASI:"
30 INPUT#1,N$,D,F
40 MOTOR
50 PRINT"Trouv :";N$
60 FOR I=D-1 TO F
70 POKE I,INP(#1)
80 NEXT: MOTOR
90 END
100 CLEAR 50,&H7FF
110 D=&H800: F=&H11D5
120 N$="SOL": INIT#1,"CASO:"
130 INPUT"Magnto OK";T$
140 PRINT#1,N$,D,F: MOTOR
150 FOR I=1 TO 1800: NEXT
160 FOR I=D TO F: OUT#1,PEEK(I)
170 NEXT: MOTOR: END
```

Programme 2

```basic
5 REM *** ENTREUR DE CODES ***
10 CLEAR 50,&H7FF:A=&H800
20 PRINTHEX$(A);" : ";:INPUT C$
30 V=VAL("&H"+C$):POKE A,V
49 A=A+1:IF A>&H11D5 THEN PRINT"...":BEEP 2,3:END
50 GOTO20
```

___
## Page 109

Figure 28 : Les Pentominos

```
```

Figure 29

```basic
10 CLEAR 50,&H7FF
20 INIT#1,"CASI:"
30 INPUT#1,N$,D,F
40 MOTOR
50 PRINT"Trouv :";N$
60 FOR I=D-1 TO F
70 POKE I,INP(#1): NEXT: MOTOR: END
100 CLEAR 50,&H7FF
110 D=&H800: F=&H159A
120 N$="PENTA": INIT#1,"CASO:"
130 INPUT"Magnto OK";T$
140 PRINT#1,N$,D,F: MOTOR
150 FOR I=1 TO 1800: NEXT
160 FOR I=D TO F: OUT#1,PEEK(I)
170 NEXT: MOTOR: END
```

```basic
5 REM *** ENTREUR DE CODES ***
10 CLEAR 50,&H7FF:A=&H800
20 PRINTHEX$(A);" : ";:INPUT C$
30 V=VAL("&H"+C$):POKE A,V
49 A=A+1:IF A>&H159A THEN PRINT"...":BEEP 2,3:END
50 GOTO20
```

___
## Page 115

Autonum

```asm
Début		LD HL,$D5D1				; Ecriture en $300 de la séquence :
			LD ($300),(HL)			;             POP DE
			LD A,$C9				;             PUSH DE
			LD ($302),A				;             RET
			CALL $300				; Lors du CALL , l'adresse XXX est empilée
XXX			LD HL,14				; Au retour du CALL , DE = XXX
			ADD HL,DE				; HL = AUTONUM (14 octets entre XXX et AUTONUM)
			DI						; 
			LD ($3D),HL				; Nouveau vecteur d'interruption
			EI						; 
			XOR A					; Inactiver la routine AUTONUM : l'adresse
			LD ($300),A				; $300 contient le drapeau activé par la
			RET						; séquence CTRL Z
AUTO		Début du logiciel ...
```

___
## Page 116

Figure 30 : AUTONUM

```basic
1 REM fonction AUTONUM pour X-07
10 CLEAR50,&HFFF:DEFINTA-Z:CLS
20 INPUT"Adr. fin ";A$:F=VAL("&H"+A$)
30 D=F-215:PRINT"Adr. deb = ";HEX$(D)
40 FORI=DTOF:READA:POKEI,A:NEXT
50 EXECD:END
10000 DATA033,209,213,034,000,003,062,201,050,002,003,205,000,003,033,014
10010 DATA000,025,243,034,061,000,251,175,050,000,003,201,217,008,219,242
10020 DATA230,001,202,193,200,219,240,230,192,040,008,230,128,202,053,200
10030 DATA195,012,200,219,241,254,013,032,075,095,175,205,098,194,175,205
10040 DATA170,194,058,000,003,183,202,189,200,062,001,211,245,217,008,197
10050 DATA213,229,245,237,091,001,003,042,003,003,025,034,001,003,235,205
10060 DATA156,187,035,205,110,213,205,004,215,205,059,202,010,197,213,095
10070 DATA175,205,098,194,175,205,170,194,209,193,021,003,032,238,241,225
10080 DATA209,193,251,201,254,026,032,027,062,001,211,245,217,008,197,213
10090 DATA229,245,062,013,239,062,010,239,033,000,003,175,182,047,119,032
10100 DATA221,024,176,254,014,032,041,062,001,211,245,217,008,197,213,229
10110 DATA245,175,050,000,003,205,242,235,215,205,204,255,237,083,001,003
10120 DATA207,044,205,204,255,237,083,003,003,175,061,050,000,003,024,131
10130 DATA254,017,194,128,200,195,195,195
```


___
## Page 118

```asm
			LD IX,(TXTTAB)			; Initialisation
BOUCLE		XOR A					; A=0
			CP (IX+1)				; Si (IX+1)=0 , c'est la fin du programme
			JP Z,fin				; Fin
			PUSH IX					; Sauve l'adresse du début de l a l igne
			LD L,(IX+0)				; L'adresse de la ligne suivante est stockée
			LD H,(IX+1)				; dans le registre HL
			LD E,(IX+2)				; Le numéro de ligne est stocké dans le
			LD D,(IX+3)				; registre DE
			PUSH HL					; 
			POP IX					; IX pointe sur la ligne suivante
			POP HL					; On récupère l'adresse du début de la ligne
			LD BC,4					; 
			ADD HL,BC				; HL contie nt le premier code de la l igne
			...						; Traitement
			JP BOUCLE				; 
```

___
## Page 120

Figure 32: Exemple+Chargeurs

```basic
10 CLEAR 50,&H7FF
20 INIT#1,"CASI:"
30 INPUT#1,N$,D,F
40 MOTOR
50 PRINT"Trouv :";N$
60 FOR I=D-1 TO F
70 POKE I,INP(#1)
80 NEXT: MOTOR
90 END
100 CLEAR 50,&H7FF
110 D=&H3C10: F=&H3FE9
120 N$="REFBAS": INIT#1,"CASO:"
130 INPUT"Magnto OK";T$
140 PRINT#1,N$,D,F: MOTOR
150 FOR I=1 TO 1800: NEXT
160 FOR I=D TO F: OUT#1,PEEK(I)
170 NEXT: MOTOR
180 END
```

```basic
5 REM *** ENTREUR DE CODES ***
10 CLEAR 50,&H9FF:A=&H3C10
20 PRINTHEX$(A);" : ";:INPUT C$
30 V=VAL("&H"+C$):POKE A,V
49 A=A+1:IF A>&H3FE9 THEN PRINT"...":BEEP 2,3:END
50 GOTO20
```


___
## Page 123

Figure 33: EXABAS

```asm
to do
```

___
## Page 124

Figure 34: Chargeurs

```basic
10 CLEAR 50,&H9FF
20 INIT#1,"CASI:"
30 INPUT#1,N$,D,F
40 MOTOR
50 PRINT"Trouv :";N$
60 FOR I=D-1 TO F
70 POKE I,INP(#1)
80 NEXT: MOTOR
90 END
100 CLEAR 50,&H9FF
110 D=&H3C10: F=&H3F95
120 N$="EXABAS": INIT#1,"CASO:"
130 INPUT"Magnto OK";T$
140 PRINT#1,N$,D,F: MOTOR
150 FOR I=1 TO 1800: NEXT
160 FOR I=D TO F: OUT#1,PEEK(I)
170 NEXT: MOTOR
180 END
```

```basic
5 REM *** ENTREUR DE CODES ***
10 CLEAR 50,&H9FF:A=&H3C10
20 PRINTHEX$(A);" : ";:INPUT C$
30 V=VAL("&H"+C$):POKE A,V
49 A=A+1:IF A>&H3F95 THEN PRINT"...":BEEP 2,3:END
50 GOTO20
```


___
## Page 126

Figure 35: LE PIEGE

```asm
to do
```

___
## Page 131


Figure 36 : Chargeurs

```basic
5 REM *** CHARGEUR - VERSION LCD ***
10 CLEAR 50,&H7FF
20 INIT#1,"CASI:"
30 INPUT#1,N$,D,F
40 MOTOR
50 PRINT"Trouv :";N$
60 FOR I=D-1 TO F
70 POKE I,INP(#1)
80 NEXT: MOTOR
90 END
100 CLEAR 50,&H9FF
110 D=&H800: F=&H186C
120 N$="AVENT2": INIT#1,"CASO:"
130 INPUT"Magnto OK";T$
140 PRINT#1,N$,D,F: MOTOR
150 FOR I=1 TO 1800: NEXT
160 FOR I=D TO F: OUT#1,PEEK(I)
170 NEXT: MOTOR
180 END
```

```basic
5 REM *** ENTREUR DE CODES - LCD ***
10 CLEAR 50,&H7FF:A=&H800
20 PRINTHEX$(A);" : ";:INPUT C$
30 V=VAL("&H"+C$):POKE A,V
49 A=A+1:IF A>&H186C THEN PRINT"...":BEEP 2,3:END
50 GOTO20
```

__
## Page 132


Figure 37 : LE PIEGE (VIDEO)

```asm
```

__
## Page 137


Figure 38 : Chargeurs

```basic
5 REM *** CHARGEUR - VERSION VIDEO ***
10 CLEAR 50,&H7F0: DEFINT A-Z
20 INIT#1,"CASI:"
30 INPUT#1,N$,D,F
40 MOTOR
50 PRINT"Trouv :";N$
60 FOR I=D-1 TO F
70 POKE I,INP(#1)
80 NEXT: MOTOR
90 END
100 CLEAR 50,&H7F0
110 D=&H800: F=&H18E8
120 N$="AVENT": INIT#1,"CASO:"
130 INPUT"Magnto OK";T$
140 PRINT#1,N$,D,F: MOTOR
150 FOR I=1 TO 1800: NEXT
160 FOR I=D TO F: OUT#1,PEEK(I)
170 NEXT: MOTOR
180 END
```

```basic
5 REM *** ENTREUR DE CODES - VIDEO ***
10 CLEAR 50,&H7FF:A=&H800
20 PRINTHEX$(A);" : ";:INPUT C$
30 V=VAL("&H"+C$):POKE A,V
49 A=A+1:IF A>&H18E8 THEN PRINT"...":BEEP 2,3:END
50 GOTO20
```



__
## Page 140


Figure 39: OTHELLO

```asm
```

__
## Page 144

```basic
5 REM *** OTHELLO - REVERSI ***
10 CLEAR 50,&H7FF
20 INIT#1,"CASI:"
30 INPUT#1,N$,D,F
40 MOTOR
50 PRINT"Trouv :";N$
60 FOR I=D-1 TO F
70 POKE I,INP(#1)
80 NEXT: MOTOR
90 END
100 CLEAR 50,&H7FF
110 D=&H800: F=&H1400
120 N$="OTHEL": INIT#1,"CASO:"
130 INPUT"Magnto OK";T$
140 PRINT#1,N$,D,F: MOTOR
150 FOR I=1 TO 1800: NEXT
160 FOR I=D TO F: OUT#1,PEEK(I)
170 NEXT: MOTOR
180 END
```

NDR : Ligne 120 corrigée pour le nom.


```basic
5 REM *** ENTREUR DE CODES - VIDEO ***
10 CLEAR 50,&H7FF:A=&H800
20 PRINTHEX$(A);" : ";:INPUT C$
30 V=VAL("&H"+C$):POKE A,V
49 A=A+1:IF A>&H1400 THEN PRINT"...":BEEP 2,3:END
50 GOTO20
```



EOF
___
