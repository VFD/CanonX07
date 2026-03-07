## D) DATE de Bernard DUPIN
## Ce programme très court permet d'imprimer la date en bon français
## ainsi que l'heure en continu.
## Il doit être interrompu par la touche 'BREAK' (pas END).

5 REM CANON X07  -  "DATE"  -
10 CLS:A$=DATE$:B$="-19"+LEFT$(A$,2)
20 B$=MID$(A$,4,2)+B$:B$=MID$(A$,7,2)+"-"+B$:C$=MID$(A$,10,3)
30 N=(INSTR("MONTUEWEDTHUFRISATSUN",C$)+2)/3
40 FORI=1TON:READC$:NEXTI:PRINTC$:LOCATE10,0:PRINTB$
50 LOCATE6,2:PRINTTIME$:GOTO50
60 DATALUNDI,MARDI,MERCREDI,JEUDI,VENDREDI,SAMEDI,DIMANCHE