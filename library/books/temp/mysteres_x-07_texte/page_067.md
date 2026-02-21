ECRITURE sur X-710
130
131

# BRUTTAGES DIVERS

Ce programme va surement enthousiasmer plus d'un programmeur ... En effet, en utilisant les ports de sortie du NSC 800, nous allons déclencher le BUZZER d'une façon tout à fait particulière. Que les adhérents du CLUB C7 se rappellent de la gazette N°1, d'un certain article qui émettait des sons assez inattendus !!

Le principe est le suivant ... Nous allons utiliser trois ports :

- Le port F4 qui met en route le BUZZER. On y place la configuration de bits suivante : le bit B2 ON est mis à 1, les bits MD1 et MD0 sont forcés à 1 (sortie sur le BUZZER) et le bit BRGST est aussi positionné à 1 (le générateur de bauds peut compter ...).

Donc, le port F4 contient la valeur 4Eh.

- Les ports F2 et F3 servent à placer la vitesse d'émission des impulsions du BUZZER dans le générateur de bauds. Cette vitesse est codée sur 12 bits comme nous l'avons déjà fait remarquer : 8 octets dans le port F2 et 4 autres dans le port F3.

En modifiant les valeurs contenues dans ces différents ports, le son varie indéfiniment !!

Une routine TEMPO est incluse dans le programme. Elle a pour but de ralentir le processeur pour que les sons soient audibles.

Comment faire pour arrêter le BUZZER ? Tout simplement placer le code "00" dans le port F4.

Longueur de la routine : 44 octets.
Implantation de la routine : de 1C00h à 1C28h.

```html
|  10.1  |
| --- |
|  20. ORG #1C00  |
|  30. *ECRITURE  |
|  40. CALL #CFB7:INITIAL,CE L'IMP.  |
|  50. LD HL,#TB  |
|  60. #1E LD A,(HL)  |
|  70. CP #00:FIN DE CHAINE  |
|  80. RET Z  |
|  90. PUSH AF  |
|  100. PUSH BC  |
|  110. PUSH CE  |
|  120. PUSH HL  |
|  130. CALL #CED6:ECRITURE SUR IMP.  |
|  140. POP HL  |
|  150. POP DE  |
|  160. POP BC  |
|  170. POP AF  |
|  180. INC HL  |
|  190. JR #1E  |
|  200. #TB DEFM BONJOUR DE #07  |
|  210. DEFB #00  |
|  220. J  |
|  1C00 CDB7CF CALL CFB7  |
|  1C03 21181C LD HL,1C18  |
|  1C06 7E LD A,(HL)  |
|  1C07 FE00 CP 00  |
|  1C09 C8 RET Z  |
|  1C0A F5 PUSH AF  |
|  1C0B C5 PUSH BC  |
|  1C0C D5 PUSH DE  |
|  1C0D E5 PUSH HL  |
|  1C0E CDD6CE CALL CED6  |
|  1C11 E1 POP HL  |
|  1C12 D1 POP DE  |
|  1C13 C1 POP BC  |
|  1C14 F1 POP AF  |
|  1C15 23 INC HL  |
|  1C16 18EE JR 1C06  |
|  10 CLS:PRINT'un instant !  |
|  20 FOR I=&H1C00 TO &H1C26  |
|  30 READ A#:POKE I,VAL("&H"+A#)  |
|  40 NEXT !  |
|  60 DATA CD,B7,CF,21,18,1C,7E,FE,00,C8,F5  |
|  C5,D5,E5,CD,D6,CE,E1,D1,E1,F1,23  |
|  70 DATA 18,EE,42,4F,4E,4A,4F,55,52,20,44  |
|  45,20,59,30,37,00  |
```