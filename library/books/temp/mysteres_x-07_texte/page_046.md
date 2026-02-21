FICHER 27 :

TABLEAU des CODES

|  ADRESSES | CODE | INSTRUCTIONS | COMMENTAIRES  |
| --- | --- | --- | --- |
|  1369 | 42 | * | Code ASCII de l'étoile.  |
|  1370 | 42 | * | Code ASCII de l'étoile.  |
|  1371 | 00 | Fin de LIGNE | A chaque fin de ligne, un 00.  |
|  1372 | 106 | INDICATEUR | Ligne suivante:106+256*5=1386.  |
|  1373 | 05 |  |   |
|  1374 | 200 | N° de LIGNE | Ici, on a 200+256*0=200  |
|  1375 | 00 |  |   |
|  1376 | 166 | CLS | Code de la fonction BASIC CLS.  |
|  1377 | 58 | : | Code du séparateur BASIC.  |
|  1378 | 65 | A |   |
|  1379 | 36 | $ |   |
|  1380 | 221 | = | Codage d'une déclaration de variable alphanumérique.  |
|  1381 | 34 | " |   |
|  1382 | 67 | C |   |
|  1383 | 55 | 7 |   |
|  1384 | 34 | " |   |
|  1385 | 00 | Fin de LIGNE |   |
|  1386 | 124 | INDICATEUR | Ligne suivante:124+256*5=1404.  |
|  1387 | 05 |  |   |
|  1388 | 15 | N° de LIGNE | Ici, on a 15+256*39=9999.  |
|  1389 | 39 |  |   |
|  1390 | 159 | PRINT | Code de la fonction BASIC PRINT  |
|  1391 | 34 | " | Code ASCII des guillemets.  |
|  1392 | 69 | E | Code ASCII de la lettre "E".  |
|  1393 | 78 | N | Code ASCII de la lettre "N".  |
|  1394 | 68 | D | Code ASCII de la lettre "D".  |
|  1395 | 34 | " | Code ASCII des guillemets.  |
|  1396 | 44 | , | Code ASCII de la virgule.  |
|  1397 | 34 | " | Code ASCII des guillemets.  |
|  1398 | 67 | C | Code ASCII de la lettre "C".  |
|  1399 | 55 | 7 | Code ASCII du chiffre "7".  |
|  1400 | 34 | " | Code ASCII des guillemets.  |
|  1401 | 58 | : | Code ASCII du séparateur.  |
|  1402 | 128 | END | Code de la fonction BASIC END.  |
|  1403 | 00 | Fin de LIGNE |   |

Vous pouvez remarquer la simplicité de codage du BASIC en mémoire vive. Dans le tableau de la figure 27, les 256 codes ASCII disponibles vous sont présentés. Vous noterez que les fonctions BASIC sont codées au même endroit que les caractères graphiques.

En ce qui concerne le codage des variables en mémoire, vous pouvez vous reporter aux manuels bleu et jaune du CANON X-07 et plus particulièrement à la fonction VARPTR.

88

|  0 | 16 | 32 | 48 | 64 | 80 | 96 | 112 | 128 | 144 | 160 | 176 | 192 | 208 | 224 | 240  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|   |  | SPC | 0 | @ | P |  | D | END | ELSE | CONT | FSET | STRIMS | STEP | INT | FIX  |
|   | DC1 | 1 | 1 | A | Q | B | q | FOR | TR | LIST | PAINT | INSTR | F M | ABS | LEN  |
|   | DC2 | - | 2 | B | R | b | r | NEXT | MOTOR | LLIST | LOAD | INKEY$ | F M | FRE | HEX$  |
|   |  | * | 3 | C | S | c | s | DATA | DEFSTR | CLEAR | SAVE | INP | F M | POS | STR$  |
|   |  | $ | 4 | D | T | d | t | INPUT | DEFINT | CIRCLE | INIT | VARPTR | F M | SQR | VAL  |
|   |  | % | 5 | E | U | e | u | DIM | DEFEND | CONTOLU | ERASE | USR | F M | RND | ASC  |
|   |  | & | 6 | F | V | f | v | READ | DEFENL | CLS | BEEP | SNS | AND | LOG | CHR$  |
|  BELL |  |  | 7 | G | W | g | w | LET | LINE | COLOR | CLOAD | ALM$ | OR | EXP | TKEY  |
|  BS |  | ( | 8 | H | X | h | x | GOTO | ERROR | EXEC | CSAVE | DATE$ | KOR | COS | LEFT$  |
|   |  | ) | 9 | I | Y | i | y | RUN | RESUME | LOCATE | NEW | TIME$ | EQV | SIN | RIGHT$  |
|  LF |  | * |  | J | Z | J | z | IF | OUT | PSET | TAB | START$ | MOD | TAN | MID$  |
|  LU |  | * | : | K | I | k | l | RESTORE | ON | PRESET | TO | FONT$ | F M | ATN | CSRLIN  |
|  CLS | → |  | < | L | V | l | : | GOSUB | DEFFN | OFF | FN | KEY$ | F M | PEEK | STICK  |
|  CR | ← |  | = | M | J | m | ) | RETURN | LPRINT | SLEEP | USING | SCREEN | = F M | CINT | STRIG  |
|  SO | ? |  | > | N | - | n | - | REM | POKE | DIR | ERL | THEN | F M | CSNG | POINT  |
|  SI | ↓ | / | ? | O | - | o | 6 | STOP | PRINT | DELETE | ERR | NOT | SGN | CDBL |   |

89