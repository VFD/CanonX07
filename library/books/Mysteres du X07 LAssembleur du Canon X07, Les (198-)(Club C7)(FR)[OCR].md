# Les Mysteres du X07 LAssembleur du Canon X07

___
## Introduction

L'objectif est de reprendre les codes sources ici.

___
## Listings

### page 62

``` Basic
```


### page 86

Errata nécessaire "pop AF" au lieu de "POP HL".

```asm
	PUSH AF
	PUSH DB
	PUSH BC
	LD C,$Fl
	CALL $COC9
	LD A,($26C)
	OR $80
	OUT ($F0),A
	OUT (C),E
	LD A,$2
	OUT ($F5),A
	POP BC
	POP DB
	POP AF
	RET
```

```asm

```

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


```asm
```

```basic
```

```basic
```

### page 130


```asm
```

```basic
```

```basic
```

### page 132


```asm
```

```basic
```

```basic
```

### page 134


```asm
```

```basic
```

```basic
```


___