50
51

## 4.7.3 Les opérations "INDISPENSABLES".

Il existe effectivement deux instructions indispensables : NOP et HALT.

L'instruction NOP est très puissante car ... elle ne fait rien ! A quoi peut-elle bien servir alors ? Par exemple, à remplacer les instructions inutiles dans le listing source : cela évite de tout réassembler, de changer les adresses, etc. ... De plus, la fonction NOP constitue une excellente temporisation pour différentes routines ...

L'instruction HALT, comme son nom l'indique, sert à stopper le déroulement du programme. Ce dernier ne pourra être relancé que par un "RESET" ou une interruption quelconque (Appel de périphérique ...).

## 4.8 Les RUPTURES de SEQUENCE.

Ce sont les "GOTO" et les "GOSUB" du langage BASIC.

### 4.8.1 Les SAUTS.

Les sauts sont représentés par l'instruction "JP". Cette commande peut être astreinte à une condition particulière définie ci-dessous :

```
C, Z, M, PE, NC, P, PO, NZ
```

Le saut sera effectué si le drapeau concerné (Z, C...) se trouve positionné à 1. Sinon, le programme continuera à l'instruction suivante. Ainsi, pour l'instruction JP, les possibilités sont les suivantes :

```
JP nn          JP NZ, nn
JP C, nn      JP NC, nn
JP Z, nn       JP PO, nn
JP M, nn        JP PE, nn
JP P, nn
```

N'oubliez pas que "nn" représente une adresse codée sur 16 bits (Les sauts peuvent aussi se faire sur 8 bits ...). De plus, l'adresse de saut peut aussi être fournie par un registre :

```
JP (HL)      JP (IX)      JP (IY)
```

Ceci permet d'exécuter un saut à une adresse calculée.

De même, les sauts relatifs (instruction JR) fonctionne de manière identique à trois restrictions près :

- Les limites des sauts sont fixés à 127 en avant et 128 en arrière.
- On ne peut utiliser l'adresse se trouvant dans un registre.
- Les conditions sont beaucoup plus limitées.

On obtient tout de même :

```
JR dpl      JR NC, dpl
JR C, dpl     JR NZ, dpl
JR Z, dpl
```

Enfin, il existe une puissante commande nommée DJNZ. C'est une instruction de saut agissant avec le registre B. Elle décrémente le registre B et saute à l'adresse indiquée en opérande s'il n'est pas égal à 0. Par contre, s'il est nul, la prochaine instruction sera exécutée.

### 4.8.2 Les APPELS de SOUS-PROGRAMMES.

L'instruction CALL fait ici office de "GOSUB". Lors d'un CALL, le NSC 800 sauvegarde l'adresse de retour dans la pile. De ce fait, il faut prendre garde à ne pas perdre cette adresse de retour pour que le pointeur puisse retourner au programme principal, une fois la routine terminée. Donc, amateurs en L.M., ne touchez pas trop à la PILE quand vous appelez un sous-programme !

Il existe, comme pour l'instruction JP, les CALL suivants :

```
CALL nn      CALL NZ, nn
CALL C, nn      CALL NC, nn
CALL Z, nn      CALL PO, nn
CALL M, nn      CALL PE, nn
CALL P, nn
```

### 4.8.3 Les RETOURS de SOUS-PROGRAMMES.

L'instruction RET est assimilable au "RETURN" du BASIC. On obtient les possibilités suivantes :

```
RET      RET NZ
RET C     RET NC
RET Z     RET PO
RET M     RET PE
RET P