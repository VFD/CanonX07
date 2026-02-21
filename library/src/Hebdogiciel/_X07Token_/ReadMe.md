# Utiliataire X07 Token

Repris du site : http://dskcenter.free.fr/X07/


*********************************************

   X-07 Token.
  _____________              -= XavSnap =-             


http://dskcenter.free.fr/X07/

For "Hebdogiciel, Les listings"
    at www.hebdogiciel.fr 
**********************************************

X-07 Token !
-------------

It's a text to CAS Canon X07 Virtual tape files converter.
It able to create a MICROSOFT/CANON BASIC file from a Text file .
Also convert a tape file to a Basic text file.

*Also generate a binary code for "PockEmul" coded by Remy Rouvin.
Located at <http://perso.club-internet.fr/r_rouvin>

Cas file:
Right clic on the X07 picture, select "TapeI/O" >>> "Load CAS" and open the Cas file.
Type CLOAD to read it.

Bin file:
Just open the "DUMP MEMORY" popup, and click on the "Load Binary File"
Select the BIN file and validate.(Keep the memory offset at &0000)
And type RUN.

Text rules:
----------
USE : The "##" tag to add comments.

 USE : the "\" character to cut a long line
    without add a "return" directive. (Just a the end of the line)
          (Don't put any characters beyond this end of line tag!)

If any character follow this tag, it's assume to convert the next character as a "GRAPH"ed key.
Graph+A = \A = "§88" = CHR$(136)
Graph+Z = \Z = "§E1" = CHR$(225)
...
(Unshifted key assignment)


 USE : the "§" character to get an ASCII character (HEX).
       "§41"="A" ... "§09" = chr$(9) (add a Zero then using a § tag !)
       "§41§42§43§44" = "ABCD"
	(Hexadecimals codes in "\infos_ASCII" folder.)

ASM and ASCII CAS files:
 USE :  [ASM ORG(&h700) X07NAME:"ASM" HEX: ]

     : [ASM ORG(&h700)... 
	Get following datas to fill memeory at specified offset.
     : X07NAME:"ASM"
	If the "Text->CAS" is selected, this code will be saved in an extra file named "ASM.cas", in an ASCII data format.(tagged:&h9C)
     : "BIN:","HEX:" or "DEC:" specify datas bases:binary, decimals or hexadecimals.


Type-in the Basic program in ascii chars.

First   Release v.1   : *** (19/08/2012)
        Release v.11  : *** (02/10/2012)
        Release v.2  : *** (07/03/2013)
        Release v.6  : *** (23/12/2016)

THIS PROGRAM IS A VB PROGRAM, YOU HAD TO INSTALL SPECIFICS
DLL TO LAUNCH THE EXE FILE !

PLEASE DOWNLOAD THE DLL PACKAGE AVAILABLE ON THE DOWNLOAD SITE.
or download it on http://dskcenter.free.fr
(It's a Visual Basic V5 Fr Runtime package ... not a Vb6 !!!)

Have Fun.


Mail: 
  dskcenter at free dot fr
 

XavSnap.

Note:
This SoftWare is a Freeware and can't be associate with any donations
 and advertising.
