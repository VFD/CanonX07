# X-722 RS232C Level Converter Manuel (198-)(Canon)(FR)



___
## Introduction

Listings de la documentation X-722.

___
## Les listings

Ci-après les listings de la documentation.\
Si vous constatez des erreurs, merci de la signaler.

### Page 20

```basic
10 INIT #1,"CON:",4800,"B":INIT #2,"CON:"
20 A=SNS(#1)
30 IF A=0 THEN GOTO 60
40 IF A=&H0D THEN PRINT CHR$(10);
50 PRINT CHR$(A)
60 B=SNS(#2)
20 IF B=0 THEN GOTO 20
80 IF B=&H0D THEN PRINT#1,CHR$(10);
90 OUT#1,CHR$(B);:GOTO 20
```
### Page 21

```basic
10 INTI#1,"COM",1200
20 INPUT A$
30 PRINT#1,A$
40 GOTO 20
```




___
