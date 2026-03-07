# Club Canon X-07, issue 10 (198-)(Club Canon)(FR)

___
## Introduction



___
## Sommaire

Absent. Oubli de scan ?


___
## Les Listings


<p align="center">────────────────────</p>

### Page 4

DAO.

```basic

```

<p align="center">────────────────────</p>

### Page 6

DAO ?

```basic

```

<p align="center">────────────────────</p>

### Page 9

ROOTS.

```basic

```

<p align="center">────────────────────</p>

### Page 11

ROBOT D'APPEL.

```basic

```


<p align="center">────────────────────</p>


### Page 12

Au vieux Canon.

Attente d'une touche. Plusieurs solutions.

```basic
1000 IF INKEY$="" THEN 1000
```

```basic
1000 POKE 43,4
```

```asm
#DE		CALL $C8C5
		LD(#AD).A
		RET
#AD		DEFB $FF
```

Validité d'une date :

```basic
10 INPUT "Date à tester JJ/MM/AA";A$
20 B$=DATE$
30 C$="19"+ RIGHT$(A$,2) + "/" + MID$(A$,4,3) + LEFT$(A$,2)
40 ON ERROR GOTO 70
50 DATE$=C$: PRINT"Ok, date valide"
60 DATE$="19"+LEFT$(B$,8): END
70 PRINT"Date invalide": END
```

<p align="center">────────────────────</p>

### page 13

```asm
to do
```

```asm
to do
```


<p align="center">────────────────────</p>

### Page 15

Un peu de musique

```basic
to do
```

```basic
200 FR=440*2-((Z+2)/12): RETURN
```

<p align="center">────────────────────</p>

### Page 16

Saisie des programmes sur Minitel.

```basic
to do
```

___
