## C) NUMERO de Bernard DUPIN
## Il est désagréable de devoir retaper la totalité d'une ligne basic pour en
## changer le numéro (ou de faire plusieurs manipulations hasardeuses
## avec l'éditeur).
## Numéro permet de changer le numéro d'une ligne d'un programme en
## zone texte. Prudence tout de méme!

5 REM CANON X07  -  "NUMERO"  -
10 INPUT"LIGNE";N1
20 INPUT"NOUVEAU NUMERO";N2 
30 A=1363
40 P=PEEK(A)+256*PEEK(A+1)
50 N=PEEK(A+2)+256*PEEK(A+3)
60 IFP=0THENPRINT"N'EXISTE PAS":END
70 IFN<>N1THENA=P:GOTO40
80 X1=N2\256:X2=N2-x1*256
90 POKEA+3,X1:POKEA+2,X2:END   
