142
143

|  ED78 | IN A,(C) |   |
| --- | --- | --- |
|  DBv | IN A,(v) | Non-affectés  |
|  ED40 | IN B,(C) | pour IN A,(v)  |
|  ED48 | IN C,(C) | Sinon, S,Z,H et P  |
|  ED50 | IN D,(C) | modifiés, N=0,  |
|  ED58 | IN E,(C) | C inchangé  |
|  ED60 | IN H,(C) |   |
|  ED68 | IN L,(C) |   |
|  34 | INC (HL) |   |
|  DD34dpl | INC (IX + dpl) |   |
|  FD34dpl | INC (IY + dpl) |   |
|  3C | INC A |   |
|  04 | INC B |   |
|  03 | INC BC |   |
|  0C | INC C |   |
|  14 | INC D |   |
|  13 | INC DE | Idem que DEC  |
|  1C | INC E |   |
|  24 | INC H |   |
|  23 | INC HL |   |
|  DD23 | INC IX |   |
|  FD23 | INC IY |   |
|  2C | INC L |   |
|  33 | INC SP |   |
|  EDAA | IND | N=1, C inchangé
Z=1 si B=0, les
autres sont
indéterminés.  |
|  EDB. | INDR | C inchangé, N et
Z=1, les autres
sont quelconques  |
|  EDA2 | INI | idem que IND  |
|  EDB2 | INIR | idem que INDR  |
|  E9 | JP (HL) | non-affectés  |
|  DDE9 | JP (IX) |   |
|  FDE9 | JP (IY) |   |
| --- | --- | --- |
|  DAnn | JP C,nn |   |
|  FAnn | JP M,nn |   |
|  D2nn | JP NC,nn |   |
|  C3nn | JP nn |   |
|  C2nn | JP NZ,nn |   |
|  F2nn | JP P,nn |   |
|  EAnn | JP PE,nn | non-affectés  |
|  E2nn | JP PO,nn |   |
|  CAnn | JP Z,nn |   |
|  38dpl | JR C,label |   |
|  18dpl | JR label |   |
|  30dpl | JR NC,label |   |
|  20dpl | JR NZ,label |   |
|  28dpl | JR Z,label |   |
|  02 | LD (BC),A |   |
|  12 | LD (DE),A |   |
|  77 | LD (HL),A |   |
|  70 | LD (HL),B |   |
|  71 | LD (HL),C |   |
|  72 | LD (HL),D |   |
|  73 | LD (HL),E |   |
|  74 | LD (HL),H |   |
|  75 | LD (HL),L |   |
|  36v | LD (HL),v |   |
|  DD74dpl | LD (IX + dpl),A |   |
|  DD70dpl | LD (IX + dpl),B |   |
|  DD71dpl | LD (IX + dpl),C | non-affectés  |
|  DD72dpl | LD (IX + dpl),D |   |
|  DD73dpl | LD (IX + dpl),E |   |
|  DD74dpl | LD (IX + dpl),H |   |
|  DD75dpl | LD (IX + dpl),L |   |
|  DD36dplv | LD (IX + dpl),v |   |
|  FD77dpl | LD (IY + dpl),A |   |
|  FD70dpl | LD (IY + dpl),B |   |
|  FD71dpl | LD (IY + dpl),C |   |
|  FD72dpl | LD (IY + dpl),D |   |
|  FD73dpl | LD (IY + dpl),E |   |
|  FD74dpl | LD (IY + dpl),H |   |
|  FD75dpl | LD (IY + dpl),L |   |
|  FD36dplv | LD (IY + dpl),v |   |
|  32nn | LD (nn),A |   |
|  ED43nn | LD (nn),BC |   |
|  ED53nn | LD (nn),DE |   |
|  22nn | LD (nn),HL |   |