# Son du Canon Le, issue 03 (1985-05)(Club C7)(FR)


___
## Introduction

TO DO


___
## Sommaire

<pre>
EDITORIAL ................................  1
LES BONNES ADRESSES DE C7 ................  3
LA LETTRE DE CANON FRANCE ................  5
COPYRIGHTS EN FOLIE ......................  6
CALC LOGI'STICK (BANC D'ESSAI) ...........  8
LES BOOLEENS DU CANON X-07 ............... 11
C7 INFORME ............................... 15
COURRIER DES LECTEURS .................... 18
GRAPHE (BANC D'ESSAI) .................... 20
LE SOUS PROCESSEUR 16834 ................. 23
LA PROGRAMMATHEQUE ....................... 26
LES SYMPATHISANTS DU X-07 ................ 28
NAUTILUS LOOGI'STICK (BANC D'ESSAI) ...... 35
COOPERATIVE C7 ........................... 38
VOTRE AVIS VAUT DE L'OR .................. 39
TRUCS EN VRAC ............................ 40
PETITES ANNONCES ......................... 41
C7 ANNONCE ............................... 42
</pre>

___
## Les Listings

### Page 14 - Amélioration

#### Magic Circus (Gazette 1)

Proposition d'amélioration :\
La ligne 145 est optionnelle.

```basic
...
145 B=-B*(B>=0)
...
400 FOR V = 1 TO 4096 : BEEP V, 1 : IF NOT TKEY(CHR$(13)) THEN NEXT V : GOTO 400 ELSE RETURN
...
500 FOR M=1 TO 2 : E=F : F=F+TKEY("l")-TKEY("3"): IF F>19 THEN F=19
510 F=-F*(F>=O)
...
```

<p align="center">────────────────────</p>

#### Télécran

```basic
...
40 B=STICK (0)
50 Y=Y+(B=1)+(B=2)+(B=8)-(B=4)-(B=5)-(B=6)
60 X=X+(B=6)+(B=7)+(B=8)-(B=2)-(B=3)-(B=4)
...
```

<p align="center">────────────────────</p>


### Page 24 - TOSHIBA T6834

Exemple : 

```asm
		PUSH AF				; 
		PUSH DE				; 
		PUSH BC				; 
		LD C,$F1			; 
		CALL $C0C9			; 
		LD A,($026C)		; 
		OR $80				; 
		OUT ($F0),A			; 
		OUT (C),E			; 
		LD A,$02			; 
		OUT ($F5),A			; 
		POP BC				; 
		POP DE				; 
		POP AF				; 
		RET					; 
```

<p align="center">────────────────────</p>

Le programme Basic de démo :

```basic
5 REM programme BASIC implantant une routine en LANGAGE MACHINE contenant une démonstration .
10 CLS:PRINT"je charge les codes ..."
20 FOR X=&H1C00 TO &H1C3E
30 READ A$:POKE X,VAL("&H"+A$)
40 NEIT X
45 REM données de la routine LANGAGE MACHINE
50 DATA CD,9E,CE,1E,15,CD,25,1C
60 DATA 1E,3C,CD,25,1C,1E,0F,CD
70 DATA 25,1C,1E,0A,CD,25,1C,06
80 DATA FF,1E,2B,CD,25,1C,1E,2C
90 DATA CD,25,1C,10,F4,F5,C5,D5
92 DATA 0E,F1,CD,C0,C9,3A,6C,02
95 DATA F6,80,D3,F0,ED,59,3E,02
98 DATA D3,F5,D1,C1,F1,C9,00,00
```

<p align="center">────────────────────</p>

L'ASM de démo :

```asm
; Désassemblage du code machine Z80 pour Canon X07
; Chargé à l'adresse &H1C00

    org     1C00h       ; Adresse de début du programme

main:
    CD 9E CE       call    0CE9Eh       ; Appelle une routine système (initialisation graphique?)
    1E 15          ld      e, 15h       ; Charge E avec 21 (code d'opération graphique)
    CD 25 1C       call    graph_call   ; Appelle la routine d'affichage graphique
    
    1E 3C          ld      e, 3Ch       ; Charge E avec 60 (paramètre X ou couleur?)
    CD 25 1C       call    graph_call   ; Appelle la routine d'affichage graphique
    
    1E 0F          ld      e, 0Fh       ; Charge E avec 15 (paramètre Y ou couleur?)
    CD 25 1C       call    graph_call   ; Appelle la routine d'affichage graphique
    
    1E 0A          ld      e, 0Ah       ; Charge E avec 10 (rayon ou autre paramètre?)
    CD 25 1C       call    graph_call   ; Appelle la routine d'affichage graphique
    
    ; Boucle pour dessiner plusieurs éléments
    06 FF          ld      b, 0FFh      ; Charge B avec 255 (compteur de boucle)
loop:
    1E 2B          ld      e, 2Bh       ; Charge E avec 43 (code d'opération ou paramètre)
    CD 25 1C       call    graph_call   ; Appelle la routine d'affichage graphique
    
    1E 2C          ld      e, 2Ch       ; Charge E avec 44 (code d'opération ou paramètre)
    CD 25 1C       call    graph_call   ; Appelle la routine d'affichage graphique
    
    10 F4          djnz    loop         ; Décrémente B et boucle si non nul

; Routine d'appel graphique - Envoie des commandes au matériel graphique
graph_call:         ; Adresse 1C25h
    F5             push    af           ; Sauvegarde A
    C5             push    bc           ; Sauvegarde BC
    D5             push    de           ; Sauvegarde DE
    
    0E F1          ld      c, 0F1h      ; Port de sortie graphique
    CD C0 C9       call    0C9C0h       ; Appelle une routine système (préparation I/O?)
    
    3A 6C 02       ld      a, (026Ch)   ; Charge une valeur système
    F6 80          or      80h          ; Met le bit 7 à 1
    D3 F0          out     (0F0h), a    ; Envoie au port F0h
    
    ED 59          out     (c), e       ; Envoie E au port dans C (F1h)
    
    3E 02          ld      a, 02h       ; Charge A avec 2
    D3 F5          out     (0F5h), a    ; Envoie au port F5h
    
    D1             pop     de           ; Restaure DE
    C1             pop     bc           ; Restaure BC
    F1             pop     af           ; Restaure A
    C9             ret                  ; Retourne
    
    00 00          db      00h, 00h     ; Octets de données ou espace réservé
```




EOF
___
