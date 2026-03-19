# Les Mysteres du X07 LAssembleur du Canon X07

___
## Introduction

L'objectif est de reprendre les codes sources ici.

___
## Listings

"Code pour l'assembleur Canon X07 - MS."

Signifie que vous avez l'assembleur 2 passes de la revue Micro Systèmes.\
La notation est assez spécifique.\
En effet le LM est dans un fichier BASIC avec une structure propre.

Il y a ausi un constat de listings incomplet dans le livre.\
Dans la mesure du possible tout devrait être corrigé ici.

Une fois tout vérifié (c'est très long), les codes seront aussi dans le répertoire "programs".


### page 59 - Tri à bulle

Code pour l'assembleur Canon X07 - MS.

```asm
0 '** TRI DE NOMBRES COMPRIS ENTRE 0 ET 255 **
5 '[
10 'ORG &4096
20 '#DE LD.B.&0
30 'LD HL.$1025
40 'LD C.(HL)
50 'DEC C
60 '#BB INC HL
70 'INC HL
80 'LD A.(HL)
90 'DBC HL
100 'CP (HL)
110 'JP NC.#AA
120 'JP D.(HL)
130 'JP (HL).A
140 'lNC HL
150 'LD (HL).D
160 'LD 8.&1
170 'DEC HL
180 '#AA DBC C
190 'JP NZ.#BB
200 'LD A.B
210 'CP &1
220 'RET NZ
230 'JP #DE
240 ']
```




### page 62

```Basic
10 ' TRI CROLSSANT ET DECROISSANT
20 'NOMBRES POSITTFS INFERIEURS A 255
30 DATA 6,0,21,25,10,4E,D,23,23,7E,2B,BE,D2,16,10,56,77,23,72,6,1,2B,D,C2,7
40 DATA 10,78,FE,1,C0,C3,0,10 : RESTORE 30 : FOR I=4096 TO 4128 : READ A$
50 POKE I,VAL("&H",A$): NEXT I
55 CLS : CLEAR 50,4050 : INPUT "Nombre de donnees";N: POKE &H1025,N
60 FOR I=&H1026 TO &H1025+N : BEEP 9,2 : PRINT "Donnee";i-&H1025;: INPUT A
70 POKE I,A : NEXT I
80 CLS : EXEC &H1000 : PRINT "(C)roisant ou ..... (D)ecroissant ... ?"
90 G$=INKEY$ : IF G$="D" THEN 120
100 IF GS<>"C" THEN 90
110 CLS : FOR I=&H1026 TO &H1025+N : PRINT PEEK(I); : NEXT I :BEEP 9,2 :END
120 CLS : FOR I=&H1025+N TO &H1026 STEP -1 : PRINT PEEK(I);: NEXT I :BHEP 9,2 : END
```

### page 85 - clignotement écran

```asm
		LD B,$FF
#1		LD B,$2B
		CALL $E428
		LD A,$2C
		CALL $E428
		DJNZ #1
		RET
```


### page 86

Errata nécessaire "pop AF" au lieu de "POP HL".

```asm
	PUSH AF				; Sauvqarde du registre AF
	PUSH DE				; Sauvegarde du regbtre DE
	PUSH BC				; Sauvqarde du reglstre BC
	LD C,$Fl			; C = Numéro du port de sortie
	CALL $C0C9			; Sous-processeur PRET ?
	LD A,($26C)			; Chargement du registre A
	OR $80				; Comparaison de A avec le code $80
	OUT ($F0),A			; Sortie de A sur le port $F0
	OUT (C),E			; Sortie de B sur le port $F1
	LD A,$2				; Chargement de A avec le chiffre 2
	OUT ($F5),A			; Sortie de A sur le port $F5
	POP BC				; Récupèration du registre BC
	POP DE				; Rècupération du registre DE
	POP AF				; Rêcupèration du registre HL
	RET					; RETOUR AU BASIC
```

La démonstration suivante n'est pas le code LM ci-dessus.

``` Basic
5 REM programme BASIC implantant une routine en LANGAGE MACHINE contenant une démonstration
10 CLS:PRINT "Je charge les codes ... Un instant S.V.P !"
20 FOR X=&HC100 TO &H1C3E
30 READ A$:POKE X,VAL("&H"+A$)
40 NEXT X
45 REM données de la routine LANGAGE MACHINE
50 DATA CD,9E,CE,1E,15,CD,25,1C
60 DATA 1E,3C,CD,25,1C,1E,0F,CD
70 DATA 25,1C,1E,0A,CD,25,1C,06
80 DATA FF,1E,2B,CD,25,1C,1E,2C
90 DATA CD,25,1C,10,F4,F5,C5,D5
92 DATA OE,F1,CD,C0,C9,3A,6C,02
95 DATA F6,80,D3,F0,ED,59,3E,02
98 DATA D3,F5,D1,C1,F1,C9,00,00
99 DATA 00,00,00,00,00,00,00,00
```

L'ASM décodé ci-dessous :

```asm
C100 : CD 9E CE       CALL CE9E          ; Appel d’une routine système (initialisation ?)
C103 : 1E 15          LD   E,15h         ; Charge E = 0x15
C105 : CD 25 1C       CALL 1C25          ; Appel d’une routine interne (affichage/son ?)
C108 : 1E 3C          LD   E,3Ch         ; E = 0x3C
C10A : CD 25 1C       CALL 1C25
C10D : 1E 0F          LD   E,0Fh         ; E = 0x0F
C10F : CD 25 1C       CALL 1C25

C112 : 1E 0A          LD   E,0Ah         ; E = 0x0A
C114 : CD 25 1C       CALL 1C25
C117 : 06 FF          LD   B,FFh         ; B = 255 → compteur de boucle
C119 : 1E 2B          LD   E,2Bh         ; E = 0x2B
C11B : CD 25 1C       CALL 1C25
C11E : 1E 2C          LD   E,2Ch         ; E = 0x2C
C120 : CD 25 1C       CALL 1C25
C123 : 10 F4          DJNZ C119          ; Boucle : répète les deux appels 0x2B/0x2C

C125 : F5             PUSH AF            ; Sauvegarde AF
C126 : C5             PUSH BC            ; Sauvegarde BC
C127 : D5             PUSH DE            ; Sauvegarde DE
C128 : 0E F1          LD   C,F1h         ; C = port F1h
C12A : CD C0 C9       CALL C9C0          ; Appel d’une routine système (prob. timer/IO)
C12D : 3A 6C 02       LD   A,(026Ch)     ; Lit un octet système (état clavier/son ?)
C130 : F6 80          OR   80h           ; Force le bit 7
C132 : D3 F0          OUT  (F0h),A       ; Envoie vers port F0h (contrôle interne X‑07)
C134 : ED 59          OUT  (C),A         ; OUT (F1h),A
C136 : 3E 02          LD   A,02h         ; A = 2
C138 : D3 F5          OUT  (F5h),A       ; Port F5h (prob. validation/trigger)
C13A : D1             POP  DE            ; Restaure DE
C13B : C1             POP  BC            ; Restaure BC
C13C : F1             POP  AF            ; Restaure AF
C13D : C9             RET                ; Retour

C13E : 00             NOP                ; Padding
C13F : 00             NOP
C140 : 00             NOP
C141 : 00             NOP
C142 : 00             NOP
C143 : 00             NOP
C144 : 00             NOP
C145 : 00             NOP

```



### page 120


```asm


```

```basic
```

### page 122


```asm
```

```basic
```

```basic
```

### page 124


```asm
```

```basic
```

```basic
```


### page 126


```asm
```

```basic
```

```basic
```


### page 128

N66

Code pour l'assembleur Canon X07 - MS.

```basic
10 '[
20 '*COPYRIGHT
30 'ORG #2000
40 'DEFM love
50 'DEFB #0A,20:*1ER SOUS PROG.
60 'DEFB #19,20:*2EME SOUS PROG.
70 'DEFB #19,20:*SOUS PROG DE SLEEP
80 'CALL #CE9E:*EFFACE L'ECRAN
90 'LD HL.#0302
100 'LD (#00BB).HL:*POSITION DE CURSEUR
110 'LD HL.#ME
120 'CALL #FEF7
130 'JP F23D:*ATTENTE CURSEUR
140 '#ME DEFM vive le X07
150 'DEFB #00
160 ']
```

Le LM :

```asm
2000 : 6C            DEFB 6Ch           ; 'l'
2001 : 6F            DEFB 6Fh           ; 'o'
2002 : 76            DEFB 76h           ; 'v'
2003 : 65            DEFB 65h           ; 'e'
2004 : 0A            DEFB 0Ah           ; LF
2005 : 20            DEFB 20h           ; ' '
2006 : 19            DEFB 19h
2007 : 20            DEFB 20h
2008 : 19            DEFB 19h
2009 : 20            DEFB 20h

200A : CD 9E CE      CALL CE9Eh         ; efface écran
200D : 21 02 03      LD   HL,0302h
2010 : 22 BB 00      LD   (00BBh),HL    ; position curseur
2013 : 21 18 20      LD   HL,2018h      ; adresse du texte
2016 : CD F7 FE      CALL FEF7h         ; impression
2019 : C3 3D F2      JP   F23Dh         ; attente curseur

; ---- Texte : "vive le X07",00 ----

201C : 76            DEFB 76h           ; v
201D : 69            DEFB 69h           ; i
201E : 76            DEFB 76h           ; v
201F : 65            DEFB 65h           ; e
2020 : 20            DEFB 20h           ; ' '
2021 : 6C            DEFB 6Ch           ; l
2022 : 65            DEFB 65h           ; e
2023 : 20            DEFB 20h           ; ' '
2024 : 58            DEFB 58h           ; X
2025 : 30            DEFB 30h           ; 0
2026 : 37            DEFB 37h           ; 7
2027 : 00            DEFB 00h           ; fin de chaîne

```

Le bon dump :

```
2000 : 6C 6F 76 65 0A 20 19 20   love. . 
2008 : 19 20 CD 9E CE 21 02 03   . ....!.
2010 : 22 BB 00 21 1C 20 CD F7   "..!. .. 
2018 : FE C3 3D F2 76 69 76 65   ..=.vive
2020 : 20 6C 65 20 58 30 37 00    le X07.
```

Le chargeur BASIC :

```basic
10 CLS: PRINT"un instant"
20 FOR I=&H2000 TO &H2027
30 READ A$: POKE I,VAL("&H"+A$)
40 NEXT
50 OFF
60 DATA 6C,6F,76,65,0A,20,19,20,19,20,CD,9E,CE,21,02,03,22,BB,00,21,1C,20
70 DATA CD,F7,FE,C3,3D,F2,76,69,76,65,20,6C,65,20,58,30,37,00
```

### page 130 - Écriture sur X-710

N67

Code pour l'assembleur Canon X07 - MS.

```basic
10 '[
20 ' ORG #1C00
30 ' *ECRITURE
40 ' CALL #CFB7:*INITIAL.DE L'IMP.
50 ' LD HL,#TB
60 ' #1E LD A,(HL)
70 ' CP #00:*FIN DE CHAINE
80 ' RET Z
90 ' PUSH AF
100 'PUSH BC
110 'PUSH CE
120 'PUSH HL
130 'CALL $CED6:*ECRITURE SUR IMP.
140 'POP HL
150 'POP DE
160 'POP BC
170 'POP AF
180 'INC HL
190 'JR #1E
200 '#TB DEFM BONJOUR DE X07
210 'DEFB $00
220 ']
```

Le LM :

```asm
1C00		CD B7 CF		CALL CFB7
1C03		21 18 1C		LD HL,1C18
1C06		7E				LD A,(HL)
1C07		FE 00			CP 00
1C09		C8				RET Z
1C0A		F5				PUSH AF
1C0B		C5				PUSH BC
1C0C		D5				PUSH DE
1C0D		E5				PUSH HL
1C0E		CD D6 CE		CALL CED6
1C11		E1				POP HL
1C12		D1				POP DE
1C13		C1				POP BC
1C14		F1				POP AF
1C15		23				INC HL
1C16		18 EE			JR 1C06

; #TB : DEFM "BONJOUR DE Y07"
;       DEFB 00

1C18		42				DEFB 42h		; 'B'
1C19		4F				DEFB 4Fh		; 'O'
1C1A		4E				DEFB 4Eh		; 'N'
1C1B		4A				DEFB 4Ah		; 'J'
1C1C		4F				DEFB 4Fh		; 'O'
1C1D		55				DEFB 55h		; 'U'
1C1E		52				DEFB 52h		; 'R'
1C1F		20				DEFB 20h		; ' '
1C20		44				DEFB 44h		; 'D'
1C21		45				DEFB 45h		; 'E'
1C22		20				DEFB 20h		; ' '
1C23		58				DEFB 59h		; 'X'
1C24		30				DEFB 30h		; '0'
1C25		37				DEFB 37h		; '7'
1C26		00				DEFB 00h		; fin de chaîne
```

Le chargeur BASIC :

```basic
10 CLS: PRINT"un instant !"
20 FOR I=&H1C00 TO &H1C26
30 READ A$: POKE I,VAL("&H"+A$)
40 NEXT
60 DATA CD,B7,CF,21,18,1C,7E,FE,00,C8,F5,C5,D5,E5,CD,D6,CE,E1,D1,E1,F1,23
70 DATA 18,EE,42,4F,4E,4A,4F,55,52,20,44,45,20,58,30,37,00
```


### page 132 - Bruitage

Code pour l'assembleur Canon X07 - MS.

```basic
10 '[
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
195 '#---------------
196 '#     ARRET
197 '#---------------
200 '#F1 LD A.#00
210 'OUT (#F4).A
220 'RET
225 '#---------------
226 '#     TEMPO
227 '#---------------
230 '#TE PUSH AF
240 'LD A.#00
250 '#LD DEC A
260 'JR NZ.#LO
265 'POP AF
270 'RET
280 ']
```

NDR : asm à faire.


Le chargeur BASIC :

```basic
10 PRINT "un instant !"
20 FOR I=&H1C00 TO &H1C2B
30 READ A$: POKE I,VAL("&H"+A$)
40 NEXT
50 EXEC &H1C00
60 DATA 3E,00,06,0F,D3,F3,3E,4E,D3,F4,3E,FF,D3,F2,3D,2B,05,CD,24,1C
70 DATA 1B,F6,7B,3D,2B,05,D3,F3,47,1B,EB,3E,00,D3,F4,C9,F5,3E,80,3D,20,FD,F1,C9
```


### page 134 - Redefinition de touche

Figure 38

Code pour l'assembleur Canon X07 - MS.

```basic
10 '[
20 'ORG #1C00
30 '*REDEF DE TOUCHE
40 '*CHANGEMENT DE HOOK
50 'LD HL.#DB
60 'LD (#A0).HL
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
240 ']
```

Le LM :

```asm
1C00	21 07 1C		LD HL,1C07
1C03	22 A0 00		LD (00A0),HL
1C06	C9				RET
1C07	F5				PUSH AF
1C08	FE 7E			CP 7E
1C0A	28 04			JR Z,1C10
1C0C	F1				POP AF
1C0D	C3 BE C1		JP C1BE
1C10	E5				PUSH HL
1C11	21 1C 1C		LD HL,1C1C
1C14	CD B0 D5		CALL D5B0
1C17	E1				POP HL
1C18	F1				POP AF
1C19	C3 3D F2		JP F23D
1C1C	20				DEFB 20h           ; " "
1C1D	58				DEFB 58h           ; "X"
1C1E	30				DEFB 30h           ; "0"
1C1F	37				DEFB 37h           ; "7"
1C20	00				DEFB 00h           ; fin de chaîne
```

Le chargeur BASIC :

```basic
10 PRINT "un instant"
20 FOR I=&H1C00 TO &H1C20
30 READ A$: POKE I,VAL("&H"+A$)
40 NEXT
50 EXEC &H1C00: PRINT "APPUYEZ SUR ~"
60 DATA 21,07,1C,22,A0,00,C9,F5,FE,7E,28,04,F1,C3,BE,C1,E5,21,1C,1C,CD,B0,D5
70 DATA E1,F1,C3,3D,F2,20,5B,30,37,00
```


EOF
___