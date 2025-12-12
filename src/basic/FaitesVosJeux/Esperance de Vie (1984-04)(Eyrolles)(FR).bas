100 PRINT" ESPERANCE DE UIE"
200 INPUT"Votre age";A
250 IF A<0 THEN 200
260 IF A>159 THEN 200
270 IF A<1 THEN A=1
300 INPUT"Uotre sexe : 1IHascul in> 2JFemin in" ;S
400 INPUT"Uotre travai l HJTres manuel) 2 DHanuel) 31Peu manuel";T
500 INPUT"Uous travaillez dans le secteu rîllPubliC) 2DPrive)3Dne sait pas";P
510 IF P=1 THEN Q=1
520 IF P=2 THEN Q=0
530 IF P=3 THEN Q=.5
600 E=~.922*A+69.89
700 IF A<50 THEN 1000
800 E=-.596*A+53. 58
850 IF A<80 THEN 1000
900 E=-.25*A + 25.94

930 IF A<99 THEN 1000
950 E=-0.0187*A+3
1000 F=3*T-5+5.3*(S-1}+Q
1200 IF A>40 THEN F=E*F/33
1300 E=E+F
1400 E=INT(E*100)/100
1500 PRINT"Votre esperance de vie:";E;"ans"
1600 IF INKEY$<>"" THEN 100
1700 GOTO 1600