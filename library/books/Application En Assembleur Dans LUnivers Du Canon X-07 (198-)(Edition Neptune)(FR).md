# Application En Assembleur Dans LUnivers Du Canon X-07 (198-)(Edition Neptune)(FR)



___
# Introduction

Report ici des codes sources du livre.\
Les programmes étant court, les espaces sont ajoutés pour rendre le code plus lisible.

___
# Les Listings


## Page 22

Exemple 1

```basic
10 GOTO 20
15   REM01234567890123456789
20 RESTORE 15 : AD% = PEEK (&H329) * 256 + PEEK (&H328) + 6
30 FOR I% = 0 TO 19 : READ B$: POKE AD%+ I% , VAL ("&H" + B$): NEXT I%
40 DATA 06 , 08 , El , 10 , FD , 2A , 15 ,03 , E5 , Dl , CD , OB , F3 , FD , 21 ,
00 , 40 , C3 , 8 A , FE
50 ON ERROR GOTO 65000
60 ' DEBUT DU PROGRAMME
100 A = 5 : B = 0 : C = A/B
64999 END
65000 PRINT "Erreur"
65010 EXEC AD%
```

Exemple 2

```basic
10 A$ = STRING$ (20,"#")
20 AD% = VARPTR (A$) : AD% = PEEK (AD% + 1) + 256 * PEEK (AD% + 2)
30 FOR I% = 0 TO 19 : READ B$ : POKE AD% + I% , VAL (" &H" + B$): NEXT I%
40 DATA 06 , 08 , El , 10 , FD , 2A , 15 , 03 , E5 , Dl , CD , OB , F3 , FD , 21 ,
00 , 40 , C3 , 8 A , FE
50 ON ERROR GOTO 65000
60 ' DEBUT DU PROGRAMME
100 A = 5 : B = 0 : C = A/B
64999 END
65000 PRINT "Erreur"
65005 AD% = VARPTR (A$) : AD% = PEEK (AD% + 1) + 256 * PEEK (AD% + 2)
65010 EXEC AD%
```

## Page 23

Exemple 3

```basic
10 DIM U%(9)
20 U%(0) = &H0806 : U%(1) = &Hl0El : U%(2) = &H2AFD : U%(3) = &H0315 : U%(4) = &HD1E5
30 U%(5) = &H0BCD : U%(6) = &HFDF3 : U%(7) = &H0021 : U%(8) = &HC340 : U%(9) = &HFE8A
50 ON ERROR GOTO 65000
100 D$ = 5
64999 END
65000 PRINT "Erreur"
65010 EXEC VARPTR (U%(0))
```


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


## Page 36

Musique

```asm
```


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


## PAGE 55

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

## Page 60


```
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

```

## Page 61

```basic
10 FOR I = &H1C00 TO &H1C00 + 103
20 READ A$ : POKE I , V AL (" &H" + A$)
30 NEXT I
40 PRINT "EXEC &H1C00 POUR DEMARRER LE PROGRAMME"
50 DATA 11 , 96 , E7 , FD , 21 , C5 , 2 , 3E , 0 , CD , A8 , E6 , DB , F4 , CB , C7 , D3 , F4 , CD , 54 , 1 C , CD , 54 , 1 C , 11 , CS , 2 , CD , 27 , E8 , 3E , 0 , CD, 8F , E8 , 3E , 0 , CD , 8F , E8 , 3E , 0 , CD , 8F , E8 , 21 , 61 , lC , 7E , FE , 0 , 28 , 6 , CD , 8F , E8 , 23 , 18 , F5 , 3E , FF , CD , 8F , E8 , 3E , FF , CD , 8F, E8 , 3E , FF, CD, 8F, E8 , CD , 54 , lC, DB , F4 , CB , 87 , D3 , F4 , C9 , C5 , 6 , 7F , E , FF , D , 20 , FD , 5 , 20 , F8 , C 1 , C9 , 1 , 2 , 3 , 4 , 5 , 6 , 0
```


