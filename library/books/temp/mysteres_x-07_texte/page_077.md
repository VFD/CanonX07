150
151

|  CB04 | RLC H |   |
| --- | --- | --- |
|  CB05 | RLC L |   |
|  07 | RLCA |   |
|  ED6F | RLD | N=H=0,C inchangé
S,Z,P modifiés  |
|  CB1E | RR (HL) |   |
|  DDCBdpl1E | RR (IX + dpl) |   |
|  FDCBdpl1E | RR (IY + dpl) |   |
|  CB1F | RR A |   |
|  CB18 | RR B | H=N=0  |
|  CB19 | RR C | S,Z,C,P modifiés  |
|  CB1A | RR D |   |
|  CB1B | RR E |   |
|  CB1C | RR H |   |
|  CB1D | RR L |   |
|  1F | RRA | idem que RLA  |
|  CB0E | RRC (HL) |   |
|  DDCBdpl0E | RRC (IX + dpl) |   |
|  FDCBdpl0E | RRC (IY + dpl) |   |
|  CB0F | RRC A |   |
|  CB08 | RRC B |   |
|  CB09 | RRC C | N=H=0  |
|  CB0A | RRC D | S,Z,C,P modifiés  |
|  CB0B | RRC E |   |
|  CB0C | RRC H |   |
|  CBOD | RRC L |   |
|  0F | RRCA |   |
|  ED67 | RRD | idem que RLD  |
|  C7 | RST $00 |   |
|  CF | RST $08 |   |
|  D7 | RST $10 |   |
|  DF | RST $18 |   |
|  E7 | RST $20 | non-affectés  |
|  EF | RST $28 |   |
|  F7 | RST $30 |   |
|  FF | RST $38 |   |
|  9E | SBC A,(HL) |   |
|  DD9Edpl | SBC A,(IX + dpl) |   |
|  FD9Edpl | SBC A,(IY + dpl) |   |
|  9F | SBC A,A | modifiés  |
|  98 | SBC A,B |   |
|  99 | SBC A,C |   |
|  9A | SBC A,D |   |
| --- | --- | --- |
|  9B | SBC A,E |   |
|  9C | SBC A,H |   |
|  9D | SBC A,L |   |
|  DEV | SBC A,V | modifiés  |
|  ED42 | SBC HL,BC |   |
|  ED52 | SBC HL,DE |   |
|  ED62 | SBC HL,HL |   |
|  ED72 | SBC HL,SP |   |
|  37 | SCF | C=1,H=N=0  |
|  CBC6 | SET 0,(HL) |   |
|  DDCBdplC6 | SET 0,(IX + dpl) |   |
|  FDCBdplC6 | SET 0,(IY + dpl) |   |
|  CBC7 | SET 0,A |   |
|  CBC0 | SET 0,B |   |
|  CBC1 | SET 0,C |   |
|  CBC2 | SET 0,D |   |
|  CBC3 | SET 0,E |   |
|  CBC4 | SET 0,H |   |
|  CBC5 | SET 0,L |   |
|  CBCE | SET 1,(HL) |   |
|  DDCBdplCE | SET 1,(IX + dpl) |   |
|  FDCBdplCE | SET 1,(IY + dpl) |   |
|  CBCF | SET 1,A |   |
|  CBC8 | SET 1,B |   |
|  CBC9 | SET 1,C | inchangés  |
|  CBCA | SET 1,D |   |
|  CBCB | SET 1,E |   |
|  CBCC | SET 1,H |   |
|  CBCD | SET 1,L |   |
|  CBD6 | SET 2,(HL) |   |
|  DDCBdplD6 | SET 2,(IX + dpl) |   |
|  FDCBdplD6 | SET 2,(IY + dpl) |   |
|  CBD7 | SET 2,A |   |
|  CBD0 | SET 2,B |   |
|  CBD1 | SET 2,C |   |
|  CBD2 | SET 2,D |   |
|  CBD3 | SET 2,E |   |
|  CBD4 | SET 2,H |   |
|  CBD5 | SET 2,L |   |
|  CBDE | SET 3,(HL) |   |