; Désassemblage du code machine Z80 pour Canon X07
; Instructions graphiques par E.Arvian et C7
; Chargé à l'adresse &H1E80

    org     1E80h       ; Adresse de début du programme

; Initialisation - Stocke l'adresse de la routine dans un vecteur
init:
    21 87 1E       ld      hl, 1E87h    ; Charge l'adresse de la routine principale
    22 9A 00       ld      (009Ah), hl  ; Stocke cette adresse à 009Ah (vecteur d'interruption?)
    C9             ret                  ; Retourne au BASIC

; Routine principale - Point d'entrée pour les commandes graphiques
main_routine:
    DD E5          push    ix           ; Sauvegarde IX
    DD 2A 9C 1F    ld      ix, (1F9Ch)  ; Charge IX avec une adresse de paramètres
    CD 5E FE       call    0FE5Eh       ; Appelle une routine système (récupération de paramètre?)
    F5             push    af           ; Sauvegarde A
    CF 2C          rst     08h          ; Appel système avec paramètre 2Ch
    CF 28          rst     08h          ; Appel système avec paramètre 28h
    F1             pop     af           ; Restaure A
    
    ; Détermine quelle commande graphique exécuter
    FE 01          cp      01h          ; Est-ce la commande 1?
    CA AA 1E       jp      z, cmd_1     ; Si oui, saute à cmd_1
    FE 02          cp      02h          ; Est-ce la commande 2?
    CA E9 1E       jp      z, cmd_2     ; Si oui, saute à cmd_2
    FE 03          cp      03h          ; Est-ce la commande 3?
    CA 17 1F       jp      z, cmd_3     ; Si oui, saute à cmd_3
    
    ; Si aucune commande reconnue, retourne une erreur
    1E 05          ld      e, 05h       ; Code d'erreur 5
    C3 C7 F1       jp      0F1C7h       ; Saute à la routine d'erreur

; Commande 1 - Semble être une commande de dessin (PAINT 1)
cmd_1:
    CD 5E FE       call    0FE5Eh       ; Récupère un paramètre
    CD 75 1F       call    get_x        ; Convertit en coordonnée X
    DD 77 01       ld      (ix+01h), a  ; Stocke X dans IX+1
    CF 2C          rst     08h          ; Appel système
    CD 5E FE       call    0FE5Eh       ; Récupère un autre paramètre
    CD 7C 1F       call    get_y        ; Convertit en coordonnée Y
    DD 77 02       ld      (ix+02h), a  ; Stocke Y dans IX+2
    CF 29          rst     08h          ; Appel système
    CF 2C          rst     08h          ; Appel système
    CD 5E FE       call    0FE5Eh       ; Récupère un paramètre de couleur
    DD 77 03       ld      (ix+03h), a  ; Stocke la couleur dans IX+3
    
    ; Boucle pour dessiner
    C5             push    bc           ; Sauvegarde BC
    D5             push    de           ; Sauvegarde DE
    DD 46 03       ld      b, (ix+03h)  ; Charge B avec la couleur
    1E 15          ld      e, 15h       ; Paramètre pour l'appel graphique
    CD 88 1F       call    graph_call   ; Appel à la routine graphique
    DD 5E 01       ld      e, (ix+01h)  ; Charge E avec X
    CD 88 1F       call    graph_call   ; Appel à la routine graphique
    DD 5E 02       ld      e, (ix+02h)  ; Charge E avec Y
    CD 88 1F       call    graph_call   ; Appel à la routine graphique
    58             ld      e, b         ; Charge E avec la couleur
    CD 88 1F       call    graph_call   ; Appel à la routine graphique
    10 E9          djnz    $-23         ; Boucle B fois
    
    D1             pop     de           ; Restaure DE
    C1             pop     bc           ; Restaure BC
    DD E1          pop     ix           ; Restaure IX
    C9             ret                  ; Retourne au BASIC

; Commande 2 - Semble être une commande pour dessiner un point (PAINT 2)
cmd_2:
    D5             push    de           ; Sauvegarde DE
    C5             push    bc           ; Sauvegarde BC
    CD 5E FE       call    0FE5Eh       ; Récupère un paramètre
    CD 75 1F       call    get_x        ; Convertit en coordonnée X
    DD 77 01       ld      (ix+01h), a  ; Stocke X dans IX+1
    CF 2C          rst     08h          ; Appel système
    CD 5E FE       call    0FE5Eh       ; Récupère un autre paramètre
    CD 7C 1F       call    get_y        ; Convertit en coordonnée Y
    DD 77 02       ld      (ix+02h), a  ; Stocke Y dans IX+2
    CF 29          rst     08h          ; Appel système
    
    ; Dessine le point
    1E 13          ld      e, 13h       ; Paramètre pour l'appel graphique (dessiner point)
    CD 88 1F       call    graph_call   ; Appel à la routine graphique
    DD 5E 01       ld      e, (ix+01h)  ; Charge E avec X
    CD 88 1F       call    graph_call   ; Appel à la routine graphique
    DD 5E 02       ld      e, (ix+02h)  ; Charge E avec Y
    CD 88 1F       call    graph_call   ; Appel à la routine graphique
    
    C1             pop     bc           ; Restaure BC
    D1             pop     de           ; Restaure DE
    DD E1          pop     ix           ; Restaure IX
    C9             ret                  ; Retourne au BASIC

; Commande 3 - Semble être une commande pour remplir une zone (PAINT 3)
cmd_3:
    CD 5E FE       call    0FE5Eh       ; Récupère un paramètre
    CD 75 1F       call    get_x        ; Convertit en coordonnée X de départ
    DD 77 01       ld      (ix+01h), a  ; Stocke X de départ dans IX+1
    CF 2C          rst     08h          ; Appel système
    CD 5E FE       call    0FE5Eh       ; Récupère un autre paramètre
    CD 7C 1F       call    get_y        ; Convertit en coordonnée Y de départ
    DD 77 02       ld      (ix+02h), a  ; Stocke Y de départ dans IX+2
    CF 29          rst     08h          ; Appel système
    CF 2C          rst     08h          ; Appel système
    CF 28          rst     08h          ; Appel système
    CD 5E FE       call    0FE5Eh       ; Récupère un paramètre
    CD 75 1F       call    get_x        ; Convertit en coordonnée X de fin
    DD 77 03       ld      (ix+03h), a  ; Stocke X de fin dans IX+3
    CF 2C          rst     08h          ; Appel système
    CD 5E FE       call    0FE5Eh       ; Récupère un autre paramètre
    CD 7C 1F       call    get_y        ; Convertit en coordonnée Y de fin
    DD 77 04       ld      (ix+04h), a  ; Stocke Y de fin dans IX+4
    CF 29          rst     08h          ; Appel système
    
    ; Boucle de remplissage
    D5             push    de           ; Sauvegarde DE
    C5             push    bc           ; Sauvegarde BC
    E5             push    hl           ; Sauvegarde HL
    DD 66 01       ld      h, (ix+01h)  ; Charge H avec X de départ
    DD 6E 02       ld      l, (ix+02h)  ; Charge L avec Y de départ
    
fill_loop:
    1E 13          ld      e, 13h       ; Paramètre pour l'appel graphique (dessiner point)
    CD 88 1F       call    graph_call   ; Appel à la routine graphique
    5D             ld      e, l         ; Charge E avec Y courant
    CD 88 1F       call    graph_call   ; Appel à la routine graphique
    5C             ld      e, h         ; Charge E avec X courant
    CD 88 1F       call    graph_call   ; Appel à la routine graphique
    
    ; Vérifie si on a atteint les limites
    7D             ld      a, l         ; Charge A avec Y courant
    DD BE 03       cp      (ix+03h)     ; Compare avec Y de fin
    28 03          jr      z, check_x   ; Si égal, vérifie X
    2C             inc     l            ; Sinon, incrémente Y
    18 EA          jr      fill_loop    ; Continue la boucle
    
check_x:
    7C             ld      a, h         ; Charge A avec X courant
    DD BE 04       cp      (ix+04h)     ; Compare avec X de fin
    28 03          jr      z, fill_done ; Si égal, terminé
    24             inc     h            ; Sinon, incrémente X
    18 DE          jr      fill_loop    ; Continue la boucle
    
fill_done:
    E1             pop     hl           ; Restaure HL
    D1             pop     de           ; Restaure DE
    C1             pop     bc           ; Restaure BC
    DD E1          pop     ix           ; Restaure IX
    C9             ret                  ; Retourne au BASIC

; Routine de conversion de coordonnée X
get_x:
    F5             push    af           ; Sauvegarde A
    FE 78          cp      78h          ; Compare avec 120 (limite X?)
    28 09          jr      z, x_error   ; Si égal, erreur
    F1             pop     af           ; Restaure A
    C9             ret                  ; Retourne
    
x_error:
    F5             push    af           ; Sauvegarde A
    FE 20          cp      20h          ; Compare avec 32
    28 02          jr      z, valid_x   ; Si égal, valide
    F1             pop     af           ; Restaure A
    C9             ret                  ; Retourne
    
valid_x:
    1E 05          ld      e, 05h       ; Code d'erreur 5
    C3 C7 F1       jp      0F1C7h       ; Saute à la routine d'erreur

; Routine de conversion de coordonnée Y
get_y:
    ; Cette routine n'est pas explicitement définie dans le code fourni
    ; Elle est probablement similaire à get_x

; Routine d'appel graphique
graph_call:
    0E F1          ld      c, 0F1h      ; Port de sortie graphique?
    CD C0 C9       call    0C9C0h       ; Appelle une routine système
    3A 6C 02       ld      a, (026Ch)   ; Charge une valeur système
    F6 80          or      80h          ; Met le bit 7 à 1
    D3 F0          out     (0F0h), a    ; Envoie au port F0h
    ED 59          out     (c), e       ; Envoie E au port dans C
    3E 02          ld      a, 02h       ; Charge A avec 2
    D3 F5          out     (0F5h), a    ; Envoie au port F5h
    C9             ret                  ; Retourne

; Données ou espace réservé
    00             db      00h          ; Octet de données ou espace réservé