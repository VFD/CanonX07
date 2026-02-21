140
141

|  DCnn | CALL C,nn |  |  |  |  |   |
| --- | --- | --- | --- | --- | --- | --- |
|  FCnn | CALL M,nn |  |  | 27 | DAA | N inchangé, les autres modifiés  |
|  D4nn | CALL NC,nn |  |  |  |  |   |
|  CDnn | CALL nn |  |  |  |  |   |
|  C4nn | CALL N2,nn | non-affectés |  |  |  |   |
|  F4nn | CALL P,nn |  |  | 35 | DEC (HL) |   |
|  ECnn | CALL PE,nn |  |  | DD35dpi | DEC (IX + dpi) |   |
|  E4nn | CALL PO,nn |  |  | FD35dpi | DEC (IY + dpi) |   |
|  CCnn | CALL Z,nn |  |  | 3D | DEC A |   |
|   |  |  |  | 05 | DEC B |   |
|  3F | CCF | C modifié, N=0 |  | 0B | DEC BC | Pour les DEC rr, non-modifiés.  |
|   |  |  |  | 0D | DEC C | Sinon, C inchangé  |
|   |  |  |  | 15 | DEC D | autres modifiés.  |
|  BE | CP (HL) |  |  | 1B | DEC DE |   |
|  DDBEdpi | CP (IX + dpi) |  |  | 1D | DEC E |   |
|  FDBEdpi | CP (IY + dpi) |  |  | 25 | DEC H |   |
|  BF | CP A |  |  | 2B | DEC HL |   |
|  B8 | CP B |  |  | DD2B | DEC IX |   |
|  B9 | CP C | N=1, les autres |  | FD2B | DEC IY |   |
|  BA | CP D | sont modifiés |  | 2D | DEC L |   |
|  BB | CP E |  |  | 3B | DEC SP |   |
|  BC | CP H |  |  |  |  |   |
|  BD | CP L |  |  |  |  |   |
|  FEv | CP v |  |  | F3 | DI | non-affectés  |
|  EDA9 | CPD | N=1, C inchangé |  | 10dpi | DJNZ label | non-affectés  |
|   |  | P/V=1 sauf si BC =0, Z=1 si A=(BC) |  | FB | EI | non-affectés  |
|  EDB9 | CPDR | C inchangé, N=1 |  | E3 | EX (SP),HL | non-affectés  |
|   |  | S et H modifiés |  | DDE3 | EX (SP),IX |   |
|   |  | V=0 si BC=0 |  | FDE3 | EX (SP),IY |   |
|   |  | Z=1 si égalité |  | 08 | EX AF,AF' | état du reg. F'  |
|   |  |  |  | EB | EX DE,HL | non-affectés  |
|  EDA1 | CPI | idem que CPD |  | D9 | EXX |   |
|  EDB1 | CPIR | idem que CPDR |  | 76 | HALT | non-modifiés  |
|  2F | CPL | N=H=1, les autres |  | ED46 | IM 0 | non-affectés  |
|   |  | sont inchangés |  | ED56 | IM 1 |   |
|   |  |  |  | ED5E | IM 2 |   |