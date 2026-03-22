; Désassemblage du code machine Z80 pour Canon X07
; Chargé à l'adresse &H1C00

    org     1C00h       ; Adresse de début du programme

main:
    CD 9E CE       call    0CE9Eh       ; Appelle une routine système (initialisation graphique?)
    1E 15          ld      e, 15h       ; Charge E avec 21 (code d'opération graphique)
    CD 25 1C       call    graph_call   ; Appelle la routine d'affichage graphique
    
    1E 3C          ld      e, 3Ch       ; Charge E avec 60 (paramètre X ou couleur?)
    CD 25 1C       call    graph_call   ; Appelle la routine d'affichage graphique
    
    1E 0F          ld      e, 0Fh       ; Charge E avec 15 (paramètre Y ou couleur?)
    CD 25 1C       call    graph_call   ; Appelle la routine d'affichage graphique
    
    1E 0A          ld      e, 0Ah       ; Charge E avec 10 (rayon ou autre paramètre?)
    CD 25 1C       call    graph_call   ; Appelle la routine d'affichage graphique
    
    ; Boucle pour dessiner plusieurs éléments
    06 FF          ld      b, 0FFh      ; Charge B avec 255 (compteur de boucle)
loop:
    1E 2B          ld      e, 2Bh       ; Charge E avec 43 (code d'opération ou paramètre)
    CD 25 1C       call    graph_call   ; Appelle la routine d'affichage graphique
    
    1E 2C          ld      e, 2Ch       ; Charge E avec 44 (code d'opération ou paramètre)
    CD 25 1C       call    graph_call   ; Appelle la routine d'affichage graphique
    
    10 F4          djnz    loop         ; Décrémente B et boucle si non nul

; Routine d'appel graphique - Envoie des commandes au matériel graphique
graph_call:         ; Adresse 1C25h
    F5             push    af           ; Sauvegarde A
    C5             push    bc           ; Sauvegarde BC
    D5             push    de           ; Sauvegarde DE
    
    0E F1          ld      c, 0F1h      ; Port de sortie graphique
    CD C0 C9       call    0C9C0h       ; Appelle une routine système (préparation I/O?)
    
    3A 6C 02       ld      a, (026Ch)   ; Charge une valeur système
    F6 80          or      80h          ; Met le bit 7 à 1
    D3 F0          out     (0F0h), a    ; Envoie au port F0h
    
    ED 59          out     (c), e       ; Envoie E au port dans C (F1h)
    
    3E 02          ld      a, 02h       ; Charge A avec 2
    D3 F5          out     (0F5h), a    ; Envoie au port F5h
    
    D1             pop     de           ; Restaure DE
    C1             pop     bc           ; Restaure BC
    F1             pop     af           ; Restaure A
    C9             ret                  ; Retourne
    
    00 00          db      00h, 00h     ; Octets de données ou espace réservé