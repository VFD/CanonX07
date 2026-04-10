; Jeu de la vie (1985-03)(Club C7)(FR)
; Désassemblage Z80 par CLAUDE 4.5 Haiku
; à refaire avec copilot car CLAUDE ne fait pas ce qu'on lui demande.
; donc ici à titre informatif.

ORG 0A00h

A00:    CALL    0C98h           ; Appel routine
A03:    CALL    0C0Eh           ; Appel routine
A06:    CALL    0C4Fh           ; Appel routine
A09:    LD      A, 0Ah
A0B:    LD      HL, 0FE0h
A0E:    XOR     A
A0F:    LD      (HL), A
A10:    LD      DE, 010Fh
A13:    LD      BC, 0FFFh
A16:    LDIR                    ; Copie bloc
A18:    LD      HL, 0000h
A1B:    LD      (0A48h), HL
A1E:    LD      (0A4Dh), HL
A21:    RET
A22:    LD      A, 9Eh
A24:    XOR     CEh
A26:    CALL    0D17h
A29:    CALL    0A96h
A2C:    LD      BC, 0308h
A2F:    LD      HL, 1700h
A32:    LD      DE, 000Fh
A35:    LDIR
A37:    LD      HL, (0A49h)
A3A:    INC     HL
A3B:    LD      (0A49h), HL
A3E:    CALL    0A56h
A41:    CALL    0A0Ah
A44:    RET

A45:    CP      42h             ; Compare avec 'B'
A47:    JP      Z, 0C528h
A4A:    CP      41h             ; Compare avec 'A'
A4C:    JP      Z, 0C528h
A4F:    CALL    0DA18h
A52:    DEC     BC
A53:    DEC     BC
A54:    XOR     A
A55:    CALL    0A0Ah
A58:    JP      Z, 0A50h
A5A:    RET

A5B:    LD      HL, 003Fh
A5E:    LD      C, 0E0h
A60:    LD      B, 40h
A62:    LD      E, 00h
A64:    LD      A, (HL)
A65:    CP      00h
A67:    LD      H, 00h
A69:    CP      01h
A6B:    JP      Z, 0A6Fh
A6E:    LD      A, 12h
A70:    JP      0A72h
A72:    INC     A
A73:    LD      DE, 07C0h
A76:    LD      A, (DE)
A77:    INC     C
A78:    INC     HL
A79:    DJNZ    0A6Ah
A7B:    DEC     C
A7C:    LD      A, 20h
A7D:    CP      B9h
A7E:    JP      NZ, 0A78h
A81:    JP      0C0CDh
A84:    E5
A85:    C5
A86:    F5
A87:    LD      A, E
A88:    LD      (0E0F0h), A
A8B:    LD      A, C
A8C:    LD      (0E0F1h), A
A8F:    LD      BC, 0002h
A92:    LD      HL, 0E0F0h
A95:    LD      A, (0E0F1h)
A98:    CP      C0h
A9A:    JP      Z, 0A2Fh
A9D:    RET
A9E:    LD      C, E1h
A9F:    RET

AA0:    LD      HL, 0000h
AA3:    LD      (0A4Dh), HL
AA6:    LD      HL, 020Fh
AA9:    LD      C, 20h
AAB:    LD      B, 40h
AAD:    LD      A, C
AAE:    CP      20h
AB0:    JP      Z, 0A4Dh
AB3:    CP      01h
AB5:    JP      Z, 0A6Fh
AB8:    PUSH    HL
AB9:    POP     DE
ABA:    LD      E, 01h
ABC:    LD      D, 00h
ABD:    LD      A, B
ABE:    CP      40h
AC0:    JP      Z, 0B30h
AC3:    CP      B3h
AC5:    JP      Z, 0B38h
AC8:    LD      A, (IX+00h)
ACA:    CP      BFh
ACC:    LD      H, A
ACD:    JP      NZ, 0A01h
AD0:    INC     D
AD1:    POP     DE
AD2:    LD      A, (IX+41h)
AD4:    CP      B5h
AD6:    LD      HL, 0114h
AD9:    POP     DE
ADA:    LD      A, (IX+00h)
ADC:    CP      C0h
ADE:    CP      BBh
AE0:    JP      NZ, 0A01h
AE3:    INC     D
AE4:    LD      A, (IX+C1h)
AE6:    CP      BBh
AE8:    JP      NZ, 0A01h
AEB:    INC     D
AEC:    LD      A, (IX+40h)
AEE:    CP      BBh
AF0:    JP      NZ, 0A01h
AF3:    INC     D
AF4:    LD      A, (IX+3Fh)
AF6:    CP      BBh
AF8:    JP      NZ, 0A01h
AFB:    INC     D
AFC:    LD      A, (IX+00h)
AFE:    CP      8Bh
B00:    JP      NZ, 0A01h
B03:    INC     D
B04:    LD      A, (IX+00h)
B06:    CP      FFh
B08:    CP      98h
B0A:    JP      NZ, 0A01h
B0D:    INC     D
B0E:    CALL    0B02h
B11:    DEC     B
B12:    JP      NZ, 0A0Ah
B15:    JP      0A0A1h

B18:    LD      A, (HL)
B19:    CP      01h
B1B:    JP      Z, 0B20h
B1E:    LD      A, E
B1F:    CP      03h
B21:    JP      Z, 0B30h
B24:    XOR     A
B25:    JP      0B38h
B28:    LD      A, E
B29:    CP      02h
B2B:    JP      Z, 0B50h
B2E:    CP      03h
B30:    JP      Z, 0B34h
B33:    LD      A, FFh
B35:    JP      0B40h
B38:    LD      A, 01h
B3A:    LD      DE, (0A40h)
B3D:    INC     DE
B3E:    LD      (0A40h), DE
B41:    LD      DE, 0823h
B44:    PUSH    HL
B45:    ADD     HL, DE
B46:    LD      (HL), A
B47:    POP     HL
B48:    INC     HL
B49:    RET

B4A:    LD      A, (IX+7Fh)
B4C:    CP      BBh
B4E:    JP      NZ, 0A0C6h
B51:    INC     D
B52:    JP      0A0C6h
B55:    LD      A, (IX+00h)
B57:    CP      9Fh
B59:    ADD     A, 83h
B5B:    JP      NZ, 0A01h
B5E:    INC     D
B5F:    LD      A, (IX+81h)
B61:    CP      BBh
B63:    JP      NZ, 0A0CDh
B66:    INC     D
B67:    JP      0A0CDh

B6A:    LD      C, (IX+AEh)
B6C:    CALL    0B8Eh
B6F:    DEC     B
B70:    LD      IY, 0BEEh
B74:    CALL    0B8Eh
B77:    DEC     B
B78:    LD      A, B
B79:    CP      01h
B7B:    JP      NZ, 0B60h
B7E:    POP     AF
B7F:    LD      HL, 08BEh
B82:    CALL    0B8Eh
B85:    LD      C, 0Dh
B87:    JP      0A0A1h

B8A:    LD      C, (IX+CEh)
B8C:    CALL    0B8Eh
B8F:    DEC     B
B90:    POP     AF
B91:    LD      HL, 08FEh
B94:    CP      01h
B96:    JP      NZ, 0B80h
B99:    LD      IY, 0DEh
B9D:    CALL    0B8Eh
B9F:    LD      C, 0Dh
BA1:    RET

BA2:    LD      C, 06h
BA4:    LD      C, 00h
BA6:    PUSH    HL
BA7:    LD      A, (IY+00h)
BA9:    LD      D, (IY+01h)
BAB:    ADD     HL, DE
BAC:    INC     IY
BAD:    INC     IY
BAE:    LD      A, (HL)
BAF:    CP      01h
BB1:    POP     HL
BB2:    JP      NZ, 0BA04h
BB5:    INC     C
BB6:    DJNZ    0BAEBh
BB8:    DEC     C
BB9:    CALL    0B02h
BBC:    RET

BBD:    LD      BC, 03F00h
BC0:    LD      DE, 0040h
BC3:    LD      HL, 0041h
BC6:    LD      A, 007Fh
BC8:    LD      (00C0h), A
BCB:    LD      (00C1h), A
BCE:    LD      (00FFh), A
BD1:    LD      (0FFFFh), A
BD4:    LD      (0001h), A
BD7:    LD      (00C1h), A
BDA:    LD      (003Fh), A
BDD:    LD      (0040h), A
BE0:    LD      (00BFh), A
BE3:    LD      (00C0h), A
BE6:    LD      (0081h), A
BE9:    LD      (003Fh), A
BEC:    LD      (0001h), A
BEF:    LD      (0FFFFh), A
BF2:    LD      (00C0h), A
BF5:    LD      (00C1h), A
BF8:    LD      (007Fh), A
BFB:    LD      (0F840h), A
BFE:    LD      (0040h), A
C01:    LD      (0F841h), A
C04:    LD      (0BFh), A
C07:    LD      (0FFFFh), A
C0A:    LD      (00C0h), A
C0D:    LD      (00FFh), A
C10:    LD      (0FFFFh), A
C13:    LD      (003Fh), A
C16:    LD      (0F840h), A
C19:    LD      (0040h), A
C1C:    LD      (0F841h), A
C1F:    LD      A, 32h
C21:    LD      (07D0Ch), A
C24:    CALL    0C75h
C27:    LD      HL, 0205h
C2A:    LD      DE, 0C32h
C2D:    CALL    0C0A4h
C30:    CALL    0C75h
C33:    CALL    0E07h
C36:    LD      HL, 0304h
C39:    LD      DE, 0C40h
C3C:    CALL    0C0A4h
C3F:    CALL    0C50h
C42:    RET

C43:    DB      4Ah, 45h, 55h, 20h, 44h, 45h
C49:    DB      20h, 4Ch, 41h, 20h, 56h, 49h, 45h, 00h
C57:    DB      41h, 30h, 50h, 61h, 75h, 73h, 65h, 20h
C5F:    DB      20h, 42h, 30h, 42h, 61h, 73h, 69h, 63h
C67:    DB      00h

C68:    LD      A, 14h
C6A:    LD      DE, 0E0Eh
C6D:    CALL    0C2Fh
C70:    RET

C71:    LD      HL, 0C88h
C74:    CALL    0C51h
C77:    LD      HL, 0C8Ch
C7A:    CALL    0C51h
C7D:    LD      HL, 0C90h
C80:    CALL    0C51h
C83:    LD      HL, 0C94h
C86:    CALL    0C51h
C89:    LD      A, CEh
C8B:    OUT     (0F4h), A
C8D:    XOR     A
C8E:    OUT     (03h), A
C90:    DI
C91:    LD      B, 19h
C93:    DJNZ    0C93h
C95:    OUT     (0F2h), A
C97:    INC     A
C98:    JP      NZ, 0C97h
C9B:    OUT     (0F4h), A
C9D:    RET

C9E:    DB      00h, 02h, 77h, 02h, 00h, 14h, 77h, 14h
CA6:    DB      02h, 00h, 02h, 16h, 75h, 00h, 75h, 16h

CAE:    LD      A, 33h
CB0:    CALL    0E428h
CB3:    CALL    0C0BDh
CB6:    CALL    0CE9Eh
CB9:    RET

CBA:    DEC     B
CBB:    LD      C, 20h
CBD:    CALL    0D31h
CC0:    CP      1Ah
CC2:    JP      Z, 0C01h
CC5:    ADD     A, 87h
CC7:    JP      Z, 0C13h
CCA:    CALL    0CBAh
CCD:    JP      NZ, 0C18h
CD0:    LD      (0450h), HL
CD3:    LD      BC, 0707h
CD6:    LD      HL, 0EE2h
CD9:    CALL    0BE5Fh
CDC:    LD      HL, 0EE2h
CDF:    LD      A, (HL)
CE0:    CP      30h
CE2:    JP      NZ, 0C0C0h
CE5:    LD      A, 20h
CE7:    LD      (HL), A
CE8:    INC     HL
CE9:    JP      0C6F6h

CEA:    LD      HL, 0A47h
CED:    LD      (0E0E2h), HL
CF0:    LD      HL, (0A48h)
CF3:    CALL    0C84h
CF6:    LD      HL, 0002h
CF9:    LD      DE, 0E0E0h
CFC:    CALL    0C0A4h
CFF:    LD      HL, 0A50h
D02:    LD      (0E0E2h), HL
D05:    LD      HL, (0A40h)
D08:    CALL    0C84h
D0B:    LD      HL, 0D03h
D0E:    LD      DE, 0E0E0h
D11:    CALL    0C0A4h
D14:    LD      A, 19h
D16:    LD      (07D0Ch), A
D19:    JP      0C75h

D1C:    DB      30h, 30h, 45h, 66h, 66h, 61h, 63h, 65h
D24:    DB      20h, 31h, 30h, 45h, 63h, 72h, 69h, 74h
D2C:    DB      00h, 46h, 3Dh, 46h, 63h, 6Eh, 00h

D34:    LD      HL, 0232h
D37:    LD      DE, 0CFFh
D3A:    CALL    0C0A4h
D3D:    LD      HL, 0308h
D40:    LD      DE, 0D11h
D43:    CALL    0C0A4h
D46:    CALL    0A4Fh
D49:    CALL    0CE9Eh
D4C:    CALL    0A56h
D4F:    LD      B, 20h
D51:    LD      C, 10h
D53:    CALL    0D7Bh
D56:    CALL    0D0B5h
D59:    PUSH    HL
D5A:    LD      A, B
D5B:    LD      (0E0F0h), A
D5E:    LD      A, C
D5F:    LD      (0E0F1h), A
D62:    CALL    0D0C9h
D65:    LD      HL, 0E0F4h
D68:    LD      A, 30h
D6A:    LD      (HL), A
D6B:    CALL    0D0EEh
D6E:    CP      00h
D70:    JP      Z, 0D92h
D73:    LD      HL, 0E0F4h
D76:    LD      A, 31h
D78:    LD      (HL), A
D79:    CALL    0D0EEh
D7C:    CP      00h
D7E:    LD      A, 01h
D80:    JP      Z, 0D93h
D83:    POP     HL
D84:    LD      A, (HL)
D85:    LD      E, A
D86:    LD      A, 12h
D88:    SUB     E
D89:    CALL    0D0CBh
D8C:    CALL    0A0Ah
D8F:    CP      46h
D91:    JP      Z, 0C0BDh
D94:    JP      0C0BFh
D97:    POP     HL
D98:    LD      (HL), A
D99:    JP      0D0EBh
D9C:    CALL    0D0DFh
D9F:    CP      33h
DA1:    JP      Z, 0D20h
DA4:    CP      37h
DA6:    JP      Z, 0D25h
DA9:    CP      31h
DAB:    JP      Z, 0D05h
DAE:    CP      35h
DB0:    JP      Z, 0D0Bh
DB3:    RET

DB4:    LD      A, C
DB5:    DEC     A
DB6:    CP      FFh
DB8:    JP      NZ, 0D02h
DBB:    LD      A, 1Fh
DBD:    LD      C, A
DBE:    RET

DBF:    LD      A, C
DC0:    INC     A
DC1:    CP      20h
DC3:    JP      NZ, 0D01h
DC6:    XOR     A
DC7:    LD      C, A
DC8:    RET

DC9:    LD      A, B
DCA:    INC     A
DCB:    CP      40h
DCD:    JP      NZ, 0D01h
DD0:    XOR     A
DD1:    LD      B, A
DD2:    RET

DD3:    LD      A, B
DD4:    DEC     A
DD5:    CP      FFh
DD7:    JP      NZ, 0D02h
DDA:    LD      A, 3Fh
DDC:    LD      B, A
DDD:    RET

DDE:    LD      C, 00h
DE0:    LD      HL, 000Fh
DE3:    LD      D, 00h
DE5:    LD      E, 40h
DE7:    XOR     A
DE8:    ADD     A, C
DE9:    JP      Z, 0DECh
DEC:    ADD     HL, DE
DED:    DEC     E
DEE:    JP      NZ, 0DE8h
DF1:    LD      B, HL
DF2:    ADD     HL, DE
DF3:    LD      C, 00h
DF4:    RET

DF5:    LD      A, 11h
DF7:    LD      C, 00h
DF9:    LD      BC, 0002h
DFC:    LD      HL, 0E0F0h
DFF:    CP      C0h
E01:    JP      Z, 0A2Fh
E04:    RET

E05:    LD      BC, 0008h
E08:    LD      B, 0Bh
E0A:    LD      A, B
E0B:    OR      C
E0C:    JP      NZ, 0E0Bh
E0F:    LD      C, 00h
E11:    RET

E12:    LD      C, 82h
E14:    LD      DE, 0E0F0h
E17:    LD      BC, 0001h
E1A:    CP      C0h
E1C:    JP      Z, 0A2Fh
E1F:    LD      C, 00h
E21:    RET

E22:    LD      A, 28h
E24:    LD      BC, 0101h
E27:    LD      DE, 0E0F2h
E2A:    CP      C0h
E2C:    JP      Z, 0A2Fh
E2F:    JP      0E1Ah
E32:    RET

E33:    LD      C, 00h
E35:    LD      B, 78h
E37:    LD      BC, 0002h
E3A:    CALL    0C2Fh
E3D:    LD      C, 00h
E3F:    RET

E40:    LD      E, 13h
E42:    LD      C, 14h
E44:    LD      B, 05h
E46:    LD      HL, 0E0F0h
E49:    LD      A, (HL)
E4A:    INC     HL
E4B:    LD      (HL), A
E4C:    CALL    0FD00h
E4F:    DEC     B
E50:    LD      A, B
E51:    CP      11h
E53:    JP      NZ, 0E50h
E56:    INC     C
E57:    LD      A, C
E58:    CP      69h
E5A:    JP      NZ, 0E48h
E5D:    RET

E5E:    DB      00h, 00h, 00h, 00h

END