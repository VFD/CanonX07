10 PR INT"AJUSTEMENT D’UNE COURBE"
20 INPUT "Nombre de points" ;N
30 FOR 1=1 TO N
40 INPUT "Abscisse";A
50 INPUT "Ordonnée";O
55 Z=LOGC103
60 B=B+A
70 C=C+0
80 D=D+A-2
80 E=E+0's2
100 F=F+A*O
120 H=H+0*A~2
130 K=K+AZ'3
150 ri=ri+A''4
160 IF O<=0 THEN 200
165 XA=XA+LOGCA3z?
170 U=U+LOGCO3/Z
175 XC=XC+CLOGCA3/Z3,"2
180 S=S+AXLOGCO3/?
180 XY=XY + LOGCA3XLOGCO3/Z-/S2
200 frIEXTI
210 PRINT "Type de courbe-"
220 PRINT" - Droite C13, Courbe hyperbol i que C23," ;
225 INPUT" Parabolique C33 ou exponentie lie C43";P
230 ON P GOTO 235,400,600,800
232 GOTO 210
235 IF D-B^2=0 THEN 622
240 U=CF-BXC/N3/CD-B*B/N3
250 IaJ=C/N~U*B/N
260 PRINT"Y=" ;ü;"*X+" ; LJ
265 IF INKEY$="” THEN 265
270 PRINT "Précision C13, changement de courbe C23, " 1
280 INPUT" ou fin C33" ;X













