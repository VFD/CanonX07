; Désassemblage du code Z80 pour Canon X07 avec codes hexadécimaux
; Adresse de début: 7901h

start:
    21 00 00       ld      hl, 0000h    ; Initialisation du pointeur vers la mémoire BASIC
    3E 41          ld      a, 41h       ; Charge 'A' (65 en décimal) dans A
    36 30          ld      (hl), 30h    ; Stocke '0' à l'adresse pointée par HL
    23             inc     hl           ; Incrémente HL
    3D             dec     a            ; Décrémente A
    C2 E2 1E       jp      nz, 1EE2h    ; Boucle jusqu'à ce que A soit zéro
    
    21 00 00       ld      hl, 0000h    ; Réinitialise HL au début de la mémoire
    01 00 00       ld      bc, 0000h    ; Initialise BC à zéro
    
main_loop:
    0A             ld      a, (bc)      ; Charge le caractère à l'adresse BC
    
    FE 49          cp      49h          ; Compare avec 'I'
    C2 FA 1E       jp      nz, 1EFAh    ; Si pas égal, saute à check_L (1EFAh)
    36 E0          ld      (hl), 0E0h   ; Si égal, stocke E0h à l'adresse HL
    C3 C8 1F       jp      1FC8h        ; Saute à next_char (1FC8h)
    
check_L:           ; Adresse 1EFAh
    FE 4C          cp      4Ch          ; Compare avec 'L'
    C2 04 1F       jp      nz, 1F04h    ; Si pas égal, saute à check_M (1F04h)
    36 E6          ld      (hl), 0E6h   ; Si égal, stocke E6h à l'adresse HL
    C3 C8 1F       jp      1FC8h        ; Saute à next_char (1FC8h)
    
check_M:           ; Adresse 1F04h
    FE 4D          cp      4Dh          ; Compare avec 'M'
    C2 0E 1F       jp      nz, 1F0Eh    ; Si pas égal, saute à check_C (1F0Eh)
    36 DA          ld      (hl), 0DAh   ; Si égal, stocke DAh à l'adresse HL
    C3 C8 1F       jp      1FC8h        ; Saute à next_char (1FC8h)
    
check_C:           ; Adresse 1F0Eh
    FE 43          cp      43h          ; Compare avec 'C'
    00             nop                  ; Pas d'opération (NOP intermédiaire)
    C2 19 1F       jp      nz, 1F19h    ; Si pas égal, saute à check_caret (1F19h)
    36 E8          ld      (hl), 0E8h   ; Si égal, stocke E8h à l'adresse HL
    C3 C8 1F       jp      1FC8h        ; Saute à next_char (1FC8h)
    
check_caret:       ; Adresse 1F19h
    FE 5E          cp      5Eh          ; Compare avec '^'
    C2 23 1F       jp      nz, 1F23h    ; Si pas égal, saute à check_asterisk (1F23h)
    36 D5          ld      (hl), 0D5h   ; Si égal, stocke D5h à l'adresse HL
    C3 CA 1F       jp      1FCAh        ; Saute à next_char2 (1FCAh)
    
check_asterisk:    ; Adresse 1F23h
    FE 2A          cp      2Ah          ; Compare avec '*'
    C2 2D 1F       jp      nz, 1F2Dh    ; Si pas égal, saute à check_plus (1F2Dh)
    36 D3          ld      (hl), 0D3h   ; Si égal, stocke D3h à l'adresse HL
    C3 CA 1F       jp      1FCAh        ; Saute à next_char2 (1FCAh)
    
check_plus:        ; Adresse 1F2Dh
    FE 2B          cp      2Bh          ; Compare avec '+'
    C2 37 1F       jp      nz, 1F37h    ; Si pas égal, saute à check_minus (1F37h)
    36 D1          ld      (hl), 0D1h   ; Si égal, stocke D1h à l'adresse HL
    C3 CA 1F       jp      1FCAh        ; Saute à next_char2 (1FCAh)
    
check_minus:       ; Adresse 1F37h
    FE 2D          cp      2Dh          ; Compare avec '-'
    C2 42 1F       jp      nz, 1F42h    ; Si pas égal, saute à check_slash (1F42h)
    36 D2          ld      (hl), 0D2h   ; Si égal, stocke D2h à l'adresse HL
    C3 CA 1F       jp      1FCAh        ; Saute à next_char2 (1FCAh)
    
check_slash:       ; Adresse 1F42h
    00             nop                  ; Pas d'opération (NOP intermédiaire)
    FE 2F          cp      2Fh          ; Compare avec '/'
    C2 4C 1F       jp      nz, 1F4Ch    ; Si pas égal, saute à check_backslash (1F4Ch)
    36 D4          ld      (hl), 0D4h   ; Si égal, stocke D4h à l'adresse HL
    C3 CA 1F       jp      1FCAh        ; Saute à next_char2 (1FCAh)
    
check_backslash:   ; Adresse 1F4Ch
    FE 5C          cp      5Ch          ; Compare avec '\'
    C2 56 1F       jp      nz, 1F56h    ; Si pas égal, saute à check_O (1F56h)
    36 DB          ld      (hl), 0DBh   ; Si égal, stocke DBh à l'adresse HL
    C3 CA 1F       jp      1FCAh        ; Saute à next_char2 (1FCAh)
    
check_O:           ; Adresse 1F56h
    FE 4F          cp      4Fh          ; Compare avec 'O'
    C2 60 1F       jp      nz, 1F60h    ; Si pas égal, saute à check_N (1F60h)
    36 D7          ld      (hl), 0D7h   ; Si égal, stocke D7h à l'adresse HL
    C3 C9 1F       jp      1FC9h        ; Saute à next_char3 (1FC9h)
    
check_N:           ; Adresse 1F60h
    FE 4E          cp      4Eh          ; Compare avec 'N'
    C2 6A 1F       jp      nz, 1F6Ah    ; Si pas égal, saute à check_X (1F6Ah)
    36 CF          ld      (hl), 0CFh   ; Si égal, stocke CFh à l'adresse HL
    C3 C8 1F       jp      1FC8h        ; Saute à next_char (1FC8h)
    
check_X:           ; Adresse 1F6Ah
    FE 58          cp      58h          ; Compare avec 'X'
    C2 74 1F       jp      nz, 1F74h    ; Si pas égal, saute à check_S (1F74h)
    36 D8          ld      (hl), 0D8h   ; Si égal, stocke D8h à l'adresse HL
    C3 C8 1F       jp      1FC8h        ; Saute à next_char (1FC8h)
    
check_S:           ; Adresse 1F74h
    FE 53          cp      53h          ; Compare avec 'S'
    C2 8B 1F       jp      nz, 1F8Bh    ; Si pas égal, saute à check_E (1F8Bh)
    
    ; Traitement spécial pour 'S'
    03             inc     bc           ; Incrémente BC
    0A             ld      a, (bc)      ; Charge le caractère suivant
    0B             dec     bc           ; Restaure BC
    
    FE 49          cp      49h          ; Compare avec 'I'
    C2 86 1F       jp      nz, 1F86h    ; Si pas égal, saute à s_not_i (1F86h)
    36 E9          ld      (hl), 0E9h   ; Si égal, stocke E9h à l'adresse HL
    C3 C8 1F       jp      1FC8h        ; Saute à next_char (1FC8h)
    
s_not_i:           ; Adresse 1F86h
    36 E4          ld      (hl), 0E4h   ; Stocke E4h à l'adresse HL
    C3 C8 1F       jp      1FC8h        ; Saute à next_char (1FC8h)
    
check_E:           ; Adresse 1F8Bh
    FE 45          cp      45h          ; Compare avec 'E'
    C2 A2 1F       jp      nz, 1FA2h    ; Si pas égal, saute à check_A (1FA2h)
    
    ; Traitement spécial pour 'E'
    03             inc     bc           ; Incrémente BC
    0A             ld      a, (bc)      ; Charge le caractère suivant
    0B             dec     bc           ; Restaure BC
    
    FE 58          cp      58h          ; Compare avec 'X'
    C2 9D 1F       jp      nz, 1F9Dh    ; Si pas égal, saute à e_not_x (1F9Dh)
    36 E7          ld      (hl), 0E7h   ; Si égal, stocke E7h à l'adresse HL
    C3 C8 1F       jp      1FC8h        ; Saute à next_char (1FC8h)
    
e_not_x:           ; Adresse 1F9Dh
    36 D9          ld      (hl), 0D9h   ; Stocke D9h à l'adresse HL
    C3 C8 1F       jp      1FC8h        ; Saute à next_char (1FC8h)
    
check_A:           ; Adresse 1FA2h
    FE 41          cp      41h          ; Compare avec 'A'
    CA AB 1F       jp      z, 1FABh     ; Si égal, saute à a_special (1FABh)
    77             ld      (hl), a      ; Sinon, stocke A directement à l'adresse HL
    C3 CA 1F       jp      1FCAh        ; Saute à next_char2 (1FCAh)
    
a_special:         ; Adresse 1FABh
    ; Traitement spécial pour 'A'
    03             inc     bc           ; Incrémente BC
    0A             ld      a, (bc)      ; Charge le caractère suivant
    0B             dec     bc           ; Restaure BC
    
    FE 42          cp      42h          ; Compare avec 'B'
    C2 B8 1F       jp      nz, 1FB8h    ; Si pas égal, saute à check_T (1FB8h)
    36 E1          ld      (hl), 0E1h   ; Si égal, stocke E1h à l'adresse HL
    C3 C8 1F       jp      1FC8h        ; Saute à next_char (1FC8h)
    
check_T:           ; Adresse 1FB8h
    FE 54          cp      54h          ; Compare avec 'T'
    C2 C2 1F       jp      nz, 1FC2h    ; Si pas égal, saute à default_char (1FC2h)
    36 EB          ld      (hl), 0EBh   ; Si égal, stocke EBh à l'adresse HL
    C3 C8 1F       jp      1FC8h        ; Saute à next_char (1FC8h)
    
default_char:      ; Adresse 1FC2h
    36 D6          ld      (hl), 0D6h   ; Stocke D6h à l'adresse HL
    00             nop                  ; Pas d'opération (NOP intermédiaire)
    C3 C8 1F       jp      1FC8h        ; Saute à next_char (1FC8h)
    
next_char:         ; Adresse 1FC8h
    03             inc     bc           ; Incrémente BC (avance dans la source)
    03             inc     bc           ; Incrémente BC encore
    03             inc     bc           ; Incrémente BC une troisième fois
    
next_char2:        ; Adresse 1FCAh
    23             inc     hl           ; Incrémente HL (avance dans la destination)
    
next_char3:        ; Adresse 1FC9h
    3E 00          ld      a, 00h       ; Charge 0 dans A
    B9             cp      c            ; Compare avec C
    0A             ld      a, (bc)      ; Charge le caractère à l'adresse BC
    
    C2 F0 1E       jp      nz, 1EF0h    ; Si pas égal à zéro, retourne à main_loop (1EF0h)
    
    ; Fin du traitement
    36 D1          ld      (hl), 0D1h   ; Stocke D1h à l'adresse HL
    C9             ret                  ; Retourne au programme appelant