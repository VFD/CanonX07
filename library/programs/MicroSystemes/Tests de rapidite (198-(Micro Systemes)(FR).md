# Les tests de rapidité Micro Systèmes


___
## introduction

TO DO

___
## Les listings

Trouver l'origine.


```basic
10 FOR A=1 TO 10000
20 NEXT A
30 END
```

```basic
10 FOR A=1 TO 10000
20 B=A+A-A/A*A
30 NEXT A
40 END
```

```basic
10 FOR A=1 TO 100
20 B=ATN(SIN(A)*COS(A)/TAN(A))
30 NEXT A
40 END
```

```basic
10 CLS
20 FOR A=1 TO 100
30 PRINT "TEST AFFICHAGE SIMPLE"
40 NEXT A
50 END
```

```basic
10 A%=1
20 B%=A%+A%-A%/A%*A%
30 A%=A%+1
40 IF A%<1001 THEN GOTO 20
50 END
```

```basic
10 A=1
20 B=A+A-A/A*A
30 A=A+1
40 IF A<1001 THEN GOTO 20
50 END
```

```basic
10 CLS
20 DIM A(1000)
30 FOR B=1 TO 1000
40 GOSUB 70
50 NEXT B
60 END
70 A(B)=B+B-B/B*B*COS(A(B))/TAN(A(B))
80 A(B)=ATN(SIN(A(B))
90 RETURN
```

```basic
10 CLS
20 DIM A(1000)
30 B=1
40 GOSUB 110
50 FOR C=1 TO 10
60 IF C>B THEN PRINT "valeur ",B,C
70 NEXT C
80 B=B+1
90 IF B<99 THEN GOTO 40
100 END
110 A(13-10+C)=SQR(B*B+C*C)
120 RETURN
```


```basic
10 OPEN "R",1,"ESSAI"
20 FIELD #1,128 AS A$
30 B$=""
40 FOR A=1 TO 128
50 B$=B$+"*"
60 NEXT A
70 FOR A=1 TO 100
80 LSET A$=B$
90 PUT #1,A
100 NEXT A
110 CLOSE 1
120 END
```
