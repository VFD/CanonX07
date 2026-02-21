ECRITOIRE SUR LA X-710

|  200A CD9ECE | CALL CE9E  |
| --- | --- |
|  200C 210203 | LD HL,0302  |
|  2010 22B000 | LD (0098),HL  |
|  2013 211C20 | LD HL,201C  |
|  2016 CDF7FE | CALL FEF7  |
|  2019 C33DF2 | JP F23D  |
|  2000:6C 6F 76 65 0A 20 19 20 | 16ve.  |
| --- | --- |
|  2000:19 20 CD 9E CE 21 02.03 | . M.NE.  |
|  201A:3D F2 | 76 65 76 65 20 6C | =rV:ve 1  |
| --- | --- | --- |
|  2022:65 20 58 30 37 00 00 00 | e X07.. |   |
|  10 'I  |
| --- |
|  20 '*COPYRIGHT  |
|  30 'ORG #2000  |
|  40 'DEFM love  |
|  50 'DEFB #0A,20:*IER SOUS PROG.  |
|  60 'DEFB #19,20:*2EME SOUS PROG.  |
|  70 'DEFB #19,20:*SOUS PROG DE SLEEP  |
|  80 'CALL #CE9E:*EFFACE L'ECRAN  |
|  90 'LD HL.#0302  |
|  100 'LD (#00BB).HL:*POSITION DE CURSEUR  |
|  110 'LD HL.#ME  |
|  120 'CALL #FEF7  |
|  130 'JP F23D:*ATTENTE CURSEUR  |
|  140 '#ME DEFM vive le X07  |
|  150 'DEFB #00  |
|  160 'I  |
|  10 CLS:PRINT"un instant"  |
| --- |
|  20 FOR I=&H2000 TO &H2027 30  |
|  30 READ A#:POKE I,JALC"&H"+A#)  |
|  40 NEXT I  |
|  50 OFF  |
|  60 DATA 6C,6F,76,65,0A,20,19,20,19,20,CD  |
|  ,9E,CE,21,02,03,22,BB,00,21,1C,20  |
|  70 DATA CD,F7,FE,C3,3D,F2 76,69,76,65,20  |
|  ,6C,6S,20,58,30,37,00,00,00  |
|  Dé tournament des sous-programmes originels  |
| --- |
|  affichage du message personnel par un CALL FEF7h  |
|  Retour au mode "attente curseur"  |

# ECRITOIRE

FIGURE 55: COPYRIGHT