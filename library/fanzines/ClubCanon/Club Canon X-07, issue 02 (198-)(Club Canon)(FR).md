# Club Canon X-07, issue 02 (198-)(Club Canon)(FR)[OCR]

___
## Introduction

Reprend les codes sources pour faciliter les copier/coller et la restauration.



___
## Sommaire

- Editorial
- Pour être pratique
- Pause Cui Cui
- Des extensions pour votre CANON
- Des logiciels pour votre CANON X-07
- De la lecture pour votre X-07
- Nouveau et intéressant
- Les bévues de notre CANON
- Vu dans la presse
- Le coin du bidouilleur
- Essai logiciel
- Tribune libre
- Petites annonces
- Nouvelles brèves
- Conclusion



___
## Les listings

Les codes ci-dessous en fonction des pages.

<p align="center">────────────────────</p>

### Page 3

Pause CUI-CUI.

```basic
5 OUT 244,78: OUT 243,0
10 X=RND(0)*15+30: Y=RND(I)*15+30
20 S=SGN(Y-X): P=10*S: FOR A=X TO Y+P STEP S: OUT 142,A: NEXT A: OUT 242,0
30 IF RND(0)\4 THEN 30 ELSE 10
```

NDR : Espace ajouté ci-dessus pour une meilleurs lisibilité.

NDR: Le programme est corrigé à la main dans le buletin scané. Laissé tel quel.

- OUT 244, 78 active le haut parleur·
- OUT 24 3,0 met a zero l'octet de poids fort (celui que l'on multiplie par 256 pour coder un nombre supérieur à 255).
- OUT 242, A donne la valeur A à l'octet de poids faible 242.
- Le nombre obtenu par l'opération 256 * octet 243 + octet 242 donne un son d'autant plus grave qu'il est élevé.

<p align="center">────────────────────</p>

### Page 13

Un RENUM en BASIC.

```basic
5 CLS:PRINT"RENUM":PL=1363:DEFFNX(X)=PEEK(PL)+256*PEEK(PL+1):INPUT"PAS";I:LR=I
10 INPUT"(A)UTO OU (M)ANUEL";CH$:IFCH$="A" THENGOSUB100:GOTO30
15 INPUT"PREMIERE LIGNE";Ll:INPUT"LIGNE D'ARRET";LA
20 INPUT"NOUVEAU PREMIER NUMERO DE LIGNE";LR
30 PL=FNX(PL):NL=PEEK(PL+2)+256*PEEK(PL+3)
35 IFNL=20488 THENEND
40 IFCH$="A" THEN60
50 IFNL<L1THEN30ELSEIFNL>LATHENEND
60 GOSUB100:GOTO30
100 POKEPL+2,LRMOD256:POKEPL+3,LR*256:LR=LR+I:RETURN
```

NDR: C'est compacté est difficile à lire. Donc à ajout d'une version plus lisible.

```basic
5 CLS: PRINT"RENUM": PL=1363 :DEF FN X(X)=PEEK(PL)+256*PEEK(PL+1): INPUT"PAS";I: LR=I
10 INPUT"(A)UTO OU (M)ANUEL";CH$: IF CH$="A" THEN GOSUB 100: GOTO 30
15 INPUT"PREMIERE LIGNE";Ll: INPUT"LIGNE D'ARRET";LA
20 INPUT"NOUVEAU PREMIER NUMERO DE LIGNE";LR
30 PL=FN X(PL): NL=PEEK(PL+2)+256*PEEK(PL+3)
35 IF NL=20488 THEN END
40 IF CH$="A" THEN 60
50 IF NL<L1 THEN 30 ELSE IF NL>LA THEN END
60 GOSUB 100: GOTO 30
100 POKE PL+2,LR MOD 256: POKE PL+3,LR*256: LR=LR+I: RETURN
```

NDR : Bien lire le buletin, ce programme n'est pas efficace, le garder juste pour exemple.


L'article indique aussi la structure d'une ligne basic.
| Adresse | Octet | Commentaire |
|---------|-------|-------------|
| &H0552  | 1     | 00 ; séparateur de ligne ; 1ère ligne en &H0552 | 
| &H0553  | 2     | Adresse ligne suivante poids faible | 
| &H0554  | 3     | Adresse ligne suivante poids fort |
| &H0555  | 4     | Numéro de ligne poids Faible |
| &H0556  | 5     | Numéro de ligne poids Fort |
| &H0557  | 6     | Instruction
| &H0558  | 7     | et suite de la ligne en ASCII |
| &Hn-2   | n-2   | 00 ; séparateur de ligne | 
| &Hn-1   | n-1   | 00 ; fin de programme |
| &Hn     | n     | 00 ; fin de programme |

NDR :
- Il apparaît que le 00 est plutôt un séparateur qu'un début de ligne, car il se retrouve aussi à la fin même si pas de nouvelle ligne.
- Voir avec le programme RALP (ZX81) comment l'adapter au X07.

___
