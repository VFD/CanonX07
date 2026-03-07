# XP-110 F

___
## Introduction

Listing de la documentation du la carte.

___
## Les listings

Ci-après les listings de la documentation.\
Si vous constatez des erreurs, merci de la signaler.

### Page 53

```basic
100 ' File Card ---> Tape
110 CLEAR 1200:DEFINT A-Z
120 INIT #1,"CASO:"
130 AD=&H2000
140 FOR I=0 TO &H3F
150   A$=""
160   FOR J=0 TO &H3F
170     X$=HEX$(PEEK(AD))
180     X$=RIGHT$("0"+X$,2)
190     A$=A$+X$
200     AD=AD+1
210   NEXT
220   PRINT #1,A$
230   PRINT "Block";I;" Saved"
240 NEXT
250 PRINT "Job Completed!"
260 END
```

### Page 54

```basic
100 ' Tape ---> File Card
110 CLEAR 1200:DEFINT A-Z
120 INIT #1,"CASI:"
130 AD=&H2000
140 FOR I=0 TO &H3F
150   INPUT #1,A$
160   FOR J=0 TO &H7F step 2
170     X$=MID$(A$,J,2)
180     POKE AD,VAL("&H"+X$)
190     AD=AD+1
200   NEXT
210   PRINT "Block";I;" Loaded"
220 NEXT
230 PRINT "Job Completed!"
240 END
```