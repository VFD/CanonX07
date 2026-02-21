146
147

|  6B | LD L,E |   |
| --- | --- | --- |
|  6C | LD L,H |   |
|  6D | LD L,L |   |
|  2Ev | LD L,v |   |
|  ED47 | LD R,A |   |
|  ED7Bnn | LD SP,(nn) | non-affectés  |
|  F9 | LD SP,HL |   |
|  DDF9 | LD SP,IX |   |
|  FDF9 | LD SP,IY |   |
|  31vv | LD SP,vv |   |
|  EDA8 | LDD | S,2,C inchangés  |
|   |  | N=H=0  |
|   |  | P/V=0 si BC=0  |
|   |  | sinon P/V=1  |
|  EDB0 | LDIR | N=P+H=0  |
|   |  | autres inchangés  |
|  ED44 | NEG | N=1  |
|   |  | autres modifiés  |
|  00 | NOP | non-affectés  |
|  B6 | OR (HL) |   |
|  DDB6dpl | OR (IX + dpl) |   |
|  FDB6dpl | OR (IY + dpl) |   |
|  B7 | OR A |   |
|  B0 | OR B |   |
|  B1 | OR C | idem que AND  |
|  B2 | OR D |   |
|  B3 | OR E |   |
|  B4 | OR H |   |
|  B5 | OR L |   |
|  F6v | OR v |   |
|  EDBB | OTDR | idem que INIR  |
|  EDB3 | OTIR |   |
|  ED79 | OUT (C),A |   |
|  ED41 | OUT (C),B |   |
|  ED49 | OUT (C),C |   |
| --- | --- | --- |
|  ED51 | OUT (C),D |   |
|  ED59 | OUT (C),E |   |
|  ED61 | OUT (C),H | non-affectés  |
|  ED69 | OUT (C),L |   |
|  D3v | OUT (v),A |   |
|  EDAB | OUTD | idem que IND  |
|  EDA3 | OUTI |   |
|  F1 | POP AF |   |
|  C1 | POP BC |   |
|  D1 | POP DE |   |
|  E1 | POP HL |   |
|  DDE1 | POP IX |   |
|  FDE1 | POP IY | non-affectés sauf pour le POP AF  |
|  F5 | PUSH AF |   |
|  C5 | PUSH BC |   |
|  D5 | PUSH DE |   |
|  E5 | PUSH HL |   |
|  DDE5 | PUSH IX |   |
|  FDE5 | PUSH IY |   |
|  CB86 | RES 0,(HL) |   |
|  DDCBdpl86 | RES 0,(IX + dpl) |   |
|  FDCBdpl86 | RES 0,(IY + dpl) |   |
|  CB87 | RES 0,A |   |
|  CB80 | RES 0,B |   |
|  CB81 | RES 0,C |   |
|  CB82 | RES 0,D |   |
|  CB83 | RES 0,E |   |
|  CB84 | RES 0,H |   |
|  CB85 | RES 0,L |   |
|  CB8E | RES 1,(HL) |   |
|  DDCBdpl8E | RES 1,(IX + dpl) |   |
|  FDCBdpl8E | RES 1,(IY + dpl) |   |
|  CB8F | RES 1,A |   |
|  CB88 | RES 1,B |   |
|  CB89 | RES 1,C | non-modifiés  |
|  CB8A | RES 1,D |   |
|  CB8B | RES 1,E |   |
|  CB8C | RES 1,H |   |
|  CB8D | RES 1,L |   |
|  CB96 | RES 2,(HL) |   |
|  DDCBdpl96 | RES 2,(IX + dpl) |   |
|  FDCBdpl96 | RES 2,(IY + dpl) |   |