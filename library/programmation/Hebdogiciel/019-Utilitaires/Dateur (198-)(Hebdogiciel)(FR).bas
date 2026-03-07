## B) DATEUR de Bernard DUPIN
## Dateur permet de connaître la date et l'heure de la demière utilisation
## de votre canon. Amusant non ? Et cela peut devenir trés utile dans le
## cas d'utilisation de cartes amovibles (date et heure de la demière
## utiliation de la carte).

5 REM CANON X07  -  "DATEUR"  -
10 A=256*PEEK(529)+PEEK(528)
20 FORI=1TO4:J$(I)=RIGHT$(STR$(PEEK(A-5+I)),2):NEXTI
30 FORI=3TO4:IFLEFT$(J$(I),1)=" "THENj$(I)="0"+RIGHT$(J$(I),1):NEXTI 
40 CLS:PRINT" CE X07 A ETE ETEINT" '
50 PRINT" LE ";J$(1);" A ";J$(2);":";J$(3);":";J$(4)
60 END
