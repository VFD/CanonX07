# X-07 Technical Guide

___
## Introduction

Listings du Technical Guide.

___
## Listings

### Page 119, Listing 1

```basic
10 CLS:PRINT"RAM CHECK":A=&H55:PRINT"DATA=";HEX$(A)
20 FOR I=&H2000 TO &H2FFF
30 POKE I,A
40 NEXT I
50 FOR I=&H2000 TO &H2FFF
60 IF A<>PEEK(I) THEN PRINT"ERR ";HEX$(I);" ";HEX$(A):END
70 NEXT I
75 PRINT"* OK"
80 IF A=&HAA THE PRINT "*END":END
90 A=&HAA:PRINT"DATA=";HEX$(A):GOTO 20
```

### Page 119, Listing 2

```basic
10 A=0
20 FOR I=&HB000 TO &HBFFF
30 A=PEEK(I)+A:IF A>256 THEN A=A-256
40 NEXT I
50 PRINT HEX$(A):END
```

### Page 120, Listing

```basic
10 INTI#1,"COM:",300,D
20 FOR I=1 TO 10
30 OUT #1,&H55
40 PRINT HEX$(INP(#1));I
50 NEXT I
60 END
```



___
