# Son du Canon Le, issue 01 (198-)(Club C7)(FR)

___
## Introduction

Ce markdown à pour but de compiler les petits codes source de ce numéro.

NDR : 2 page sont manquantes.

## To DO



Page 6\
Nombre Aléatoire
```basic
5 REM "GENERATEUR ALEATOIRE"
10 DATA 16,0,1E,0,ED,5F,6F,3A,6A,1F,AD,17,6F,ED,5F,AD,32,6A,1F,CD,48,1F,7C,3C
20 DATA 0,C3,56,1F,21,0,0,29,CB,27,D2,52,1F,19,C2,4B,1F,C9,32,26,1F,C9
30 RESTORE 10:FOR I=7980 TO 8025:READ A$:POKE I,VAL(A$):NEXT:CLEAR 50,7970
40 CLS:BEEP 5,2:INPUT "Nombre Maximal ";N:IF N<0 OR N>255 THEN 40
50 POKE 7983,N:EXEC ÈÇ_À:CLS:PRINT "Nombre Aleatoire......";PEEK(7974)
60 FOR I=1 TO 4096:BEEP I,1:G$=INKEY$:IFF G$="" THEN NEXT:GOTO 60
70 IF G$=" " THEN 40
80 IF G$=CHR$(13) THEN 50
90 CLS:BEEP:9,5:END
```




```basic
```




```asm
```


___
