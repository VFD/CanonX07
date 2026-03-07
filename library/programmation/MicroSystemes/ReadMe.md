# Micros Systèmes

___
## Introduction

COmpilation des codes sources publiés dans la revue Micro Systèmes.

___
## Les listings


### Tableau de suivi

| Icon | État |
|------|-------|
|  ✅  | Terminé et fonctionnel |
|  ❌  | Echec |
|  ❕  | À faire |
|  📝  | En cours et à tester |



| No | Date    | Programme              | Status | Commentaire |
|----|---------|------------------------|--------|-------------|
| 42 | 1984-05 | Moniteur-Desassembleur | ❕     |             |
| 44 | 1984-07 | Verouillage-Minuscule  | 📝     |             |
| 46 | 1984-10 | jeu MAZOG              | ❕     |             |
| 47 | 1984-10 | extention basic        | ❕     |             |
| 48 | 1984-12 | Course aux FONT$       | ❕     |             |
| 49 | 1985-01 | Password               | ❕     |             |
| 49 | 1985-01 | Assembleur 2 passes    | 📝     |             |
| 50 | 1985-02 | Dictator               | 📝     |             |
| 52 | 1985-04 | Extension basic        | ❕     |             |
| 56 | 1985-09 | Clavier AZERTY         | ❕     |             |
| 60 | 1986-01 | Extension basic        | ❕     |             |
| 61 | 1986-02 | Labyrinthe             | ❕     |             |


Pas d'autres listings trouvé.

___
## MS 44 1984-07
Verouillage-Minuscule

```basic
10000 ' * VERROUILLAGE DES MINUSCULES *
15000 ' ** (c) 1984 EMMANUEL SANDER **
20000 FOR I=0 T0 33
25000 READ A$
30000 POKE &H1F00+I,VAL("&H"+A$)
35000 NEXT
40000 DATA F5,FE,04,20,0B,E5,3E,20,21,1E
45000 DATA 1F,AE,77,E1,F1,C9,D6,41,E6,DF
50000 DATA FE,1A,38,04,F1,C3,BE,C1,F1,EE
55000 DATA 00,C3,BE,C1
```


```asm
1F00 PUSH af
1F01 CP 04
1F03 JR NZ,1F10
1F05 PUSH hl
1F06 LD a,20
1F08 LD hl,1F1E
1F0B XOR (hl)
1FOC LD (hl),a
1F0D POP hl
1F0E POP af
1F0F RET
1F10 SUB 41
1F12 AND DF
1F14 CP 1A
1F16 JR C,1F1C
1F18 POP af
1F19 JP C1BE
1F1C POP af
1F10 XOR 00
1F1F JP C1BE
```


___
