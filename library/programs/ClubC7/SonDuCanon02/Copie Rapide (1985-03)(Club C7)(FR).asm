; Désassemblage du code machine Z80 pour Canon X07
; Programme de copie d'écran sur imprimante X-710
; Chargé à l'adresse AD (calculée à partir de &H328 et &H329 + 6)

    ; Données extraites des lignes DATA 50-70:
    ; 06 00 21 14 02 C5 E5 01 13 00 09 7E FE 20 20 04 2B 0D 20 F7 0C E1 E5 7E
    ; 04 23 E5 C5 CD F7 CE C1 E1 78 B9 20 F2 CD B0 CF E1 01 14 00 09 C1 04 78
    ; FE 04 20 D1 C9

; A CORRIGER

; org 0563h		; ligne REM

start:
    06 00          ld      b, 00h       ; Initialise B à 0 ; lsb, 00h
    21 14 02       ld      hl, 0214h    ; Charge HL avec l'adresse 0214h (adresse de l'écran?)
    
main_loop:
    C5             push    bc           ; Sauvegarde BC
    E5             push    hl           ; Sauvegarde HL
    01 13 00       ld      bc, 0013h    ; Charge BC avec 19 (largeur de ligne?)
    09             add     hl, bc       ; Ajoute BC à HL (positionne à la fin de la ligne?)
    
scan_line:
    7E             ld      a, (hl)      ; Charge le caractère à l'adresse HL
    FE 20          cp      20h          ; Compare avec espace (20h)
    20 04          jr      nz, found_char ; Si pas un espace, saute à found_char
    2B             dec     hl           ; Sinon, recule d'un caractère
    0D             dec     c            ; Décrémente C (compteur de caractères)
    20 F7          jr      nz, scan_line ; Si C n'est pas zéro, continue le scan
    
    0C             inc     c            ; Incrémente C (au moins un caractère)
    
found_char:
    E1             pop     hl           ; Restaure HL (début de ligne)
    E5             push    hl           ; Sauvegarde HL à nouveau
    7E             ld      a, (hl)      ; Charge le premier caractère de la ligne
    04             inc     b            ; Incrémente B (compteur de lignes)
    23             inc     hl           ; Avance à la position suivante
    
print_line:
    E5             push    hl           ; Sauvegarde HL
    C5             push    bc           ; Sauvegarde BC
    CD F7 CE       call    0CEF7h       ; Appelle une routine (impression d'un caractère?)
    C1             pop     bc           ; Restaure BC
    E1             pop     hl           ; Restaure HL
    
    78             ld      a, b         ; Charge B dans A
    B9             cp      c            ; Compare avec C
    20 F2          jr      nz, print_line ; Si pas égal, continue l'impression
    
    CD B0 CF       call    0CFB0h       ; Appelle une routine (retour chariot/nouvelle ligne?)
    E1             pop     hl           ; Restaure HL (début de ligne)
    01 14 00       ld      bc, 0014h    ; Charge BC avec 20 (longueur de ligne?)
    09             add     hl, bc       ; Ajoute BC à HL (passe à la ligne suivante)
    C1             pop     bc           ; Restaure BC (compteur de lignes)
    04             inc     b            ; Incrémente B
    
    78             ld      a, b         ; Charge B dans A
    FE 04          cp      04h          ; Compare avec 4 (nombre de lignes à imprimer?)
    20 D1          jr      nz, main_loop ; Si pas égal à 4, continue la boucle principale
    
    C9             ret                  ; Retourne au programme BASIC