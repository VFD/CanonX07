;
; Fait via decodage des lignes data
; Le source du fanzine est different
;
        ORG  &6000

        LD   HL,1777h
        LD   (009Ah),HL
        RET

        PUSH IX
        LD   IX,(1853h)
        RST  08h
        JR   Z,$-51
        CALL FE5Eh
        CALL 1822h
        LD   (IX+01h),A
        RST  08h

        INC  L
        CALL FE5Eh
        CALL 182Ah
        LD   (IX+02h),A
        RST  08h
        ADD  HL,HL
        RST  08h
        INC  L
        RST  08h
        JR   Z,$-51
        CALL FE5Eh
        CALL 1822h
        LD   (IX+03h),A

        RST  08h
        INC  L
        CALL FE5Eh
        CALL 182Ah
        LD   (IX+04h),A
        RST  08h
        ADD  HL,HL

        PUSH BC
        PUSH DE
        CALL 1832h
        LD   E,(IX+01h)
        CALL 183Dh
        LD   E,(IX+02h)
        CALL 183Dh
        LD   E,(IX+01h)
        CALL 183Dh
        LD   E,(IX+04h)
        CALL 183Dh

        CALL 1832h
        LD   E,(IX+01h)
        CALL 183Dh
        LD   E,(IX+04h)
        CALL 183Dh
        LD   E,(IX+03h)
        CALL 183Dh
        LD   E,(IX+04h)
        CALL 183Dh

        CALL 1832h
        LD   E,(IX+03h)
        CALL 183Dh
        LD   E,(IX+04h)
        CALL 183Dh
        LD   E,(IX+03h)
        CALL 183Dh
        LD   E,(IX+02h)
        CALL 183Dh

        CALL 1832h
        LD   E,(IX+03h)
        CALL 183Dh
        LD   E,(IX+02h)
        CALL 183Dh
        LD   E,(IX+01h)
        CALL 183Dh
        LD   E,(IX+02h)
        CALL 183Dh

        POP  DE
        POP  BC
        POP  IX
        RET

        PUSH AF
        CP   78h
        JP   NC,1838h
        POP  AF
        RET

        PUSH AF
        CP   20h
        JP   NC,1838h
        POP  AF
        RET

        LD   E,14h
        CALL 183Dh
        RET

        LD   E,05h
        JP   F1C7h

        PUSH BC
        LD   C,F1h
        CALL C9C0h
        LD   A,(026Ch)
        OR   80h
        OUT  (F0h),A
        OUT  (C),A
        LD   A,02h
        OUT  (F5h),A
        POP  BC
        RET
