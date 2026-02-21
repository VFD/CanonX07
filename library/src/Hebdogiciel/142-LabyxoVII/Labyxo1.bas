0 ' ************ LABYXO VII **************
0 ' **************************************
10 FONT$(128)="0,120,204,120,0,0,0,0"
20 FONT$(129)="0,0,0,0,120,204,120,0"
30 FONT$(132)="0,0,248,8,8,8,8,8"
40 FONT$(133)="0,0,124,64,64,64,64,64"
50 FONT$(134)="8,8,8,8,8,248,0,0"
60 FONT$(135)="64,64,64,64,64,124,0,0"
70 FONT$(138)="0,0,252,0,0,0,0,0"
80 FONT$(139)="0,0,0,0,0,252,0,0"
90 FONT$(140)="0,0,124,64,64,64,224,160"
100 FONT$(141)="160,224,64,64,64,124,0,0"
110 FONT$(142)="0,0,248,8,8,8,28,20"
120 FONT$(143)="20,28,8,8,8,248,0,0"
130 FONT$(224)="252,252,252,252,252,252,252,252"
135 CONSOLE0,4:GOTO1000:CLEAR50,16000
140 N$="":CLS:PRINT"Nom:§5F":LOCATE0,1:PRINT"(10 lettres au plus)";:LOCATE4,0
150 INIT#1,"KBD:":FORQ=1TO10:I=INP(#1):BEEPI,4:IFI=13THENPRINT" ";:GOTO180
160 IFI=29THENQ=Q-2:PRINTCHR$(29)"§5F"CHR$(29);:N$=LEFT$(N$,LEN(N$)-1):NEXT
170 PRINTCHR$(I)"§5F"CHR$(29);:N$=N$+CHR$(I):NEXT:PRINT" ";
180 CLS:P=INT(RND(0)*100)+101:IFN$=""THENN$="L'inconnu"
190 PRINTN$:LOCATE12,0:PRINT"OR:"P:CONSOLE1,3:CLS
200 PRINT"1.Bouclier  20","2.Cotte     55","3.Armure   100";
210 I=INP(#1):BEEP30,4:IFI<48ORI>51THENBEEP-1,10:GOTO210
220 PR=I-48:P=P-((PR-1)*45+10-10*(PR=1))*-(PR>0):LOCATE15,0:PRINTP" ";
230 CLS:PRINT"1.Couteau  10","2.Masse    30","3.Epee    100";
240 I=INP(#1):BEEP30,4:IFI<48ORI>51THENBEEP-1,9:GOTO240
250 AR=I-48:PI=(10+(AR-1)*20-(AR>2)*50)*-(AR>0):IFP-PI<0THENBEEP-1,10:GOTO240
260 P=P-PI:LOCATE15,0:PRINTP" ":CLS:PRINT"A.Torche  5","B.Vivres 10","C.Aventure";
270 I=INP(#1):IFI<65ORI>67THENBEEP-1,10:GOTO270ELSEBEEP30,4:Z=I-64
280 IFZ=3THEN300ELSEIF(P-5*Z)<0THENBEEP-1,10:GOTO270ELSEP=P-5*Z:MA(Z)=MA(Z)+1
290 LOCATE15,0:PRINTP;:LOCATE15,Z:PRINTMA(Z):GOTO270
300 POKE16001,P:POKE16002,MA(1):POKE16003,MA(2):Q=10-LEN(N$):IFQ=0THEN320
310 FORW=1TOQ:N$=N$+" ":NEXT:POKE16014,PR:POKE16015,AR
320 FORQ=1TO10:A=ASC(MID$(N$,Q,1)):POKE16003+Q,A:NEXT:CONSOLE0,4:CLS
330 PRINT" Mettez la cassette   sur le programme        principal";:CLOAD
1000 DATA62,43,205,40,228,201:CLEAR50,16000:FORQ=1TO6:READA:POKE16000+Q,A:NEXT
1010 EXEC16001:CLS:LOCATE5,1:PRINT"LABYXO VII";
1020 FORA=2TO3:LOCATE1,A:FORQ=1TO18:READB:PRINTCHR$(B+128);:NEXTQ,A
1030 FORQ=1TO16STEP15:FORA=0TO1:LOCATEQ,A:FORB=1TO3:READC:PRINTCHR$(C+128);
1040 NEXTB,A,Q:POKE16002,44:EXEC16001
1050 FORA=0TO24STEP2:PSET(15,A):BEEPA,3:NEXT
1060 FORQ=15TO105STEP2:PSET(Q,24):BEEPQ,2:NEXT
1070 FORQ=24TO0STEP-2:PSET(105,Q):BEEPQ,1:NEXT
1080 CLS:INPUT"Desirez-vous le moded'emploi (O ou N)";R$:IFR$="N"THEN140
1085 CLS:PRINT"*** Avant-Propos ************************"
1090 LOCATE19,2:PRINT"* ******************";:CLEAR300:RESTORE1160
1100 FORA=1TO26:READA$:LOCATE1,2:PRINTMID$(A$,1,18):FORQ=1TO300:NEXTQ
1105 FORB=1TOLEN(A$)-17:LOCATE1,2:PRINTMID$(A$,B,18):NEXTB
1110 FORC=1TO10:BEEPC,3:NEXTC,A:GOTO140
1130 DATA5,0,14,12,10,14,12,10,14,12,10,14,12,10,14,12,0,4
1140 DATA7,11,15,13,11,15,13,1,15,13,1,15,13,11,15,13,11,6
1150 DATA5,0,4,7,1,6,5,0,4,7,1,6
1160 DATABienvenu dans l'univers de Labyxo.
1170 DATAVous etes en l'An 7 Post Herculem dans le pays de Traplun.
1180 DATALe terrible Dragon Malodorus s'est empare des trois trophes sacres.
1185 DATALa gemme - l'anneau - le sceptre.
1190 DATA Ces tresors symbolisent la paix et la prosperite du royaume.
1200 DATADepuis le royaume est en guerre.
1210 DATALe roi Mollus 1er vous a donc charge de les retrouver.
1220 DATAVous savez que le Dragon habite un labyrinthe en trois niveaux.
1230 DATAChacun des objets est la cle du niveau ou il se trouve.
1240 DATAPour votre mission vous disposez d'un peu d'or.
1250 DATAAvec vous pouvez acheter une armure et une arme ainsi que des vivres.
1260 DATASoyez judicieux dans votre choix.
1270 DATAVoici le vocabulaire possible...
1280 DATAAllume Torche - Bois fiole - Jette sort - Lis carte ou livre -
1290 DATAMange...(nombre) - Ouvre coffre ou porte - Prends...(Objet) -
1300 DATASuicide - Va nord est sud ou ouest.
1310 DATAQuand vous rencontrez un monstre vous pouvez...
1320 DATA(A)ttaquer - (F)uir (M]archander - Lancer un (S)ort -
1325 DATALes combats sont en temps reel n'hesitez pas trop longtemps.
1330 DATAVous disposez des sorts suivants...
1340 DATABoule de feu - Desintegration - Sommeil - Teleportation -
1350 DATAGuerison - Lumiere - Serrure -
1360 DATAPour ecrire un mot il suffit d'ecrire ses deux premieres lettres.
1365 DATA(D) Jeu en sommeil - (I) Inventaire - (F6) Repete l'action -
1370 DATASurtout ne perdez pas patience et ne vous enervez Jamais.
1380 DATA -------------------BONNE CHANCE-------------------
