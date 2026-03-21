    OPT --syntax=a
    ORG $B000

;
; x07.bin ROM annotations
; The analysis work was mainly done with IA assistance, it can
; contain errors! It can serve as a general reference though.
;
start_of_rom: defb     $2b,$d7,$c8,$cf,$2c                          ; +...,      ; 
;
; ---------------------------------------------------------------------------
; inst_dim — DIM statement
; ---------------------------------------------------------------------------
; DIM varname[(dims)][, varname[(dims)]]...
; The handler shares entry with callb00a (variable lookup/create).
; Entry via inst_dim: push program-start address $B000 (used later as
; "DIM mode" sentinel), then fall into variable lookup.
; callb00a: clear $01D8 (array-subscript flag), read variable name char,
; check if it is a letter (calld2fd), scan for trailing type suffix:
; default type is read from DEFTYPE table at $032A indexed by letter.
; Fetch next token; if letter follows, loop to build a multi-char name.
; If the next char is `(`: array access — when DIM mode, allocate a new
; array; otherwise, look up the existing array.
; Returns DE = variable address, A = type byte stored in $01D9.
; 
; DIM statement entry.  Pushes sentinel $B000 (DIM-mode flag)
; and falls into variable lookup (callb00a) for each variable.
; Arrays are allocated rather than looked up when DIM mode is active.
;
inst_dim:    defb     $01,$00,$b0,$c5,$f6                          ; .....      ; 
;
; Variable lookup / creation.  Reads variable name from token
; stream, resolves type from suffix (%, $, !, #) or DEFTYPE table.
; Returns DE = variable address, A = type byte (→ $01D9).
;
lookup_or_create_var: xor      a,a                  ; $b00a af              ; 
             ld       ($01d8),a            ; $b00b 32 d8 01        ; 
             ld       c,(hl)               ; $b00e 4e              ; 
jumpb00f:    call     calld2fd             ; $b00f cd fd d2        ; 
             jp       c,basic_raise_error_02 ; $b012 da aa f1        ; 
             xor      a,a                  ; $b015 af              ; 
             ld       b,a                  ; $b016 47              ; 
             rst      rst0010              ; $b017 d7              ; 
             jr       c,skipb01f           ; $b018 38 05           ; 
             call     calld2fe             ; $b01a cd fe d2        ; 
             jr       c,var_parse_type_suffix ; $b01d 38 09           ; 
skipb01f:    ld       b,a                  ; $b01f 47              ; 
loopb020:    rst      rst0010              ; $b020 d7              ; 
             jr       c,loopb020           ; $b021 38 fd           ; 
             call     calld2fe             ; $b023 cd fe d2        ; 
             jr       nc,loopb020          ; $b026 30 f8           ; 
;
; Checks for an explicit BASIC type suffix after the variable name.
; Recognises % / $ / ! / # and maps them to the internal size/type
; bytes used in descriptors; otherwise falls through to DEFTYPE lookup.
;
var_parse_type_suffix: cp       a,$26                ; $b028 fe 26           ; 
             jr       nc,var_default_type_for_letter ; $b02a 30 17           ; 
             ld       de,$b051             ; $b02c 11 51 b0        ; 
             push     de                   ; $b02f d5              ; 
             ld       d,$02                ; $b030 16 02           ; 
             cp       a,$25                ; $b032 fe 25           ; 
             ret      z                    ; $b034 c8              ; 

             inc      d                    ; $b035 14              ; 
             cp       a,$24                ; $b036 fe 24           ; 
             ret      z                    ; $b038 c8              ; 

             inc      d                    ; $b039 14              ; 
             cp       a,$21                ; $b03a fe 21           ; 
             ret      z                    ; $b03c c8              ; 

             ld       d,$08                ; $b03d 16 08           ; 
             cp       a,$23                ; $b03f fe 23           ; 
             ret      z                    ; $b041 c8              ; 

             pop      af                   ; $b042 f1              ; 
;
; Uses the first letter of the variable name (masked to 7-bit ASCII)
; as an index into the DEFTYPE table at $032A and returns the default
; descriptor type byte in A / D.
;
var_default_type_for_letter: ld       a,c                  ; $b043 79              ; 
             and      a,$7f                ; $b044 e6 7f           ; 
             ld       e,a                  ; $b046 5f              ; 
             ld       d,$00                ; $b047 16 00           ; 
             push     hl                   ; $b049 e5              ; 
             ld       hl,$02e9             ; $b04a 21 e9 02        ; 
             add      hl,de                ; $b04d 19              ; 
             ld       d,(hl)               ; $b04e 56              ; 
             pop      hl                   ; $b04f e1              ; 
             dec      hl                   ; $b050 2b              ; 
             ld       a,d                  ; $b051 7a              ; 
             ld       ($01d9),a            ; $b052 32 d9 01        ; 
             rst      rst0010              ; $b055 d7              ; 
             ld       a,($020e)            ; $b056 3a 0e 02        ; 
             dec      a                    ; $b059 3d              ; 
             jp       z,var_find_or_create_array ; $b05a ca 39 b1        ; 
             jp       p,var_find_scalar_descriptor ; $b05d f2 6b b0        ; 
             ld       a,(hl)               ; $b060 7e              ; 
             sub      a,$28                ; $b061 d6 28           ; 
             jp       z,var_parse_subscripts ; $b063 ca 0c b1        ; 
             sub      a,$33                ; $b066 d6 33           ; 
             jp       z,var_parse_subscripts ; $b068 ca 0c b1        ; 
;
; Search scalar/FN-local variable descriptors.  If an FN call frame is
; active ($0417 != 0), scan that local descriptor list first; then
; fall back to the global scalar table from $0322 up to $0324.
;
var_find_scalar_descriptor: xor      a,a                  ; $b06b af              ; 
             ld       ($020e),a            ; $b06c 32 0e 02        ; 
             push     hl                   ; $b06f e5              ; 
             ld       a,($0417)            ; $b070 3a 17 04        ; 
             or       a,a                  ; $b073 b7              ; 
             ld       ($0414),a            ; $b074 32 14 04        ; 
             jr       z,skipb0b3           ; $b077 28 3a           ; 
             ld       hl,($0346)           ; $b079 2a 46 03        ; 
             ld       de,$0348             ; $b07c 11 48 03        ; 
             add      hl,de                ; $b07f 19              ; 
             ld       ($0415),hl           ; $b080 22 15 04        ; 
             ex       de,hl                ; $b083 eb              ; 
             jr       skipb09c             ; $b084 18 16           ; 

;
; Inner scalar-descriptor scan.  Each record is:
; type/size][name_char_1][name_char_2][value bytes...
; Non-matching records are skipped by advancing 3 + type bytes.
;
var_scan_scalar_descriptors: ld       a,(de)               ; $b086 1a              ; 
             ld       l,a                  ; $b087 6f              ; 
             inc      de                   ; $b088 13              ; 
             ld       a,(de)               ; $b089 1a              ; 
             inc      de                   ; $b08a 13              ; 
             cp       a,c                  ; $b08b b9              ; 
             jr       nz,skipb098          ; $b08c 20 0a           ; 
             ld       a,($01d9)            ; $b08e 3a d9 01        ; 
             cp       a,l                  ; $b091 bd              ; 
             jr       nz,skipb098          ; $b092 20 04           ; 
             ld       a,(de)               ; $b094 1a              ; 
             cp       a,b                  ; $b095 b8              ; 
             jr       z,skipb0f6           ; $b096 28 5e           ; 
skipb098:    inc      de                   ; $b098 13              ; 
             ld       h,$00                ; $b099 26 00           ; 
             add      hl,de                ; $b09b 19              ; 
skipb09c:    ex       de,hl                ; $b09c eb              ; 
             ld       a,($0415)            ; $b09d 3a 15 04        ; 
             cp       a,e                  ; $b0a0 bb              ; 
             jr       nz,var_scan_scalar_descriptors ; $b0a1 20 e3           ; 
             ld       a,($0416)            ; $b0a3 3a 16 04        ; 
             cp       a,d                  ; $b0a6 ba              ; 
             jr       nz,var_scan_scalar_descriptors ; $b0a7 20 dd           ; 
             ld       a,($0414)            ; $b0a9 3a 14 04        ; 
             or       a,a                  ; $b0ac b7              ; 
             jr       z,var_create_scalar  ; $b0ad 28 0f           ; 
             xor      a,a                  ; $b0af af              ; 
             ld       ($0414),a            ; $b0b0 32 14 04        ; 
skipb0b3:    ld       hl,($0324)           ; $b0b3 2a 24 03        ; 
             ld       ($0415),hl           ; $b0b6 22 15 04        ; 
             ld       hl,($0322)           ; $b0b9 2a 22 03        ; 
             jr       skipb09c             ; $b0bc 18 de           ; 

;
; Missing-scalar handler.  In assignment / DIM / INPUT-style contexts
; it allocates a new scalar descriptor at the top of variable storage,
; zero-fills the value slot, and updates $0324/$0326.
;
var_create_scalar: pop      hl                   ; $b0be e1              ; 
             ex       (sp),hl              ; $b0bf e3              ; 
             push     de                   ; $b0c0 d5              ; 
             ld       de,$fb35             ; $b0c1 11 35 fb        ; 
             rst      rst0020              ; $b0c4 e7              ; 
             pop      de                   ; $b0c5 d1              ; 
             jr       z,var_return_default_value ; $b0c6 28 31           ; 
             ex       (sp),hl              ; $b0c8 e3              ; 
             push     hl                   ; $b0c9 e5              ; 
             push     bc                   ; $b0ca c5              ; 
             ld       a,($01d9)            ; $b0cb 3a d9 01        ; 
             ld       c,a                  ; $b0ce 4f              ; 
             push     bc                   ; $b0cf c5              ; 
             ld       b,$00                ; $b0d0 06 00           ; 
             inc      bc                   ; $b0d2 03              ; 
             inc      bc                   ; $b0d3 03              ; 
             inc      bc                   ; $b0d4 03              ; 
             ld       hl,($0326)           ; $b0d5 2a 26 03        ; 
             push     hl                   ; $b0d8 e5              ; 
             add      hl,bc                ; $b0d9 09              ; 
             pop      bc                   ; $b0da c1              ; 
             push     hl                   ; $b0db e5              ; 
             call     move_block_up_checked ; $b0dc cd 6a d1        ; 
             pop      hl                   ; $b0df e1              ; 
             ld       ($0326),hl           ; $b0e0 22 26 03        ; 
             ld       h,b                  ; $b0e3 60              ; 
             ld       l,c                  ; $b0e4 69              ; 
             ld       ($0324),hl           ; $b0e5 22 24 03        ; 
loopb0e8:    dec      hl                   ; $b0e8 2b              ; 
             ld       (hl),$00             ; $b0e9 36 00           ; 
             rst      rst0020              ; $b0eb e7              ; 
             jr       nz,loopb0e8          ; $b0ec 20 fa           ; 
             pop      de                   ; $b0ee d1              ; 
             ld       (hl),e               ; $b0ef 73              ; 
             inc      hl                   ; $b0f0 23              ; 
             pop      de                   ; $b0f1 d1              ; 
             ld       (hl),e               ; $b0f2 73              ; 
             inc      hl                   ; $b0f3 23              ; 
             ld       (hl),d               ; $b0f4 72              ; 
             ex       de,hl                ; $b0f5 eb              ; 
skipb0f6:    inc      de                   ; $b0f6 13              ; 
             pop      hl                   ; $b0f7 e1              ; 
             ret                           ; $b0f8 c9              ; 

;
; Expression-only fast path for an undefined scalar reference.
; Returns the implicit BASIC default value without creating storage:
; numeric zero, or the shared empty-string descriptor for strings.
;
var_return_default_value: ld       ($044e),a            ; $b0f9 32 4e 04        ; 
             ld       h,a                  ; $b0fc 67              ; 
             ld       l,a                  ; $b0fd 6f              ; 
             ld       ($0450),hl           ; $b0fe 22 50 04        ; 
             rst      rst0030              ; $b101 f7              ; 
             jr       nz,skipb10a          ; $b102 20 06           ; 
             ld       hl,$f168             ; $b104 21 68 f1        ; 
             ld       ($0450),hl           ; $b107 22 50 04        ; 
skipb10a:    pop      hl                   ; $b10a e1              ; 
             ret                           ; $b10b c9              ; 

;
; Parse comma-separated array subscripts inside () or [].
; Each subscript expression is converted to signed 16-bit integer and
; left on the stack; the dimension count is saved in $01D8.
;
var_parse_subscripts: push     hl                   ; $b10c e5              ; 
             ld       hl,($01d8)           ; $b10d 2a d8 01        ; 
             ex       (sp),hl              ; $b110 e3              ; 
             ld       d,a                  ; $b111 57              ; 
loopb112:    push     de                   ; $b112 d5              ; 
             push     bc                   ; $b113 c5              ; 
             call     callf58b             ; $b114 cd 8b f5        ; 
             pop      bc                   ; $b117 c1              ; 
             pop      af                   ; $b118 f1              ; 
             ex       de,hl                ; $b119 eb              ; 
             ex       (sp),hl              ; $b11a e3              ; 
             push     hl                   ; $b11b e5              ; 
             ex       de,hl                ; $b11c eb              ; 
             inc      a                    ; $b11d 3c              ; 
             ld       d,a                  ; $b11e 57              ; 
             ld       a,(hl)               ; $b11f 7e              ; 
             cp       a,$2c                ; $b120 fe 2c           ; 
             jr       z,loopb112           ; $b122 28 ee           ; 
             cp       a,$29                ; $b124 fe 29           ; 
             jr       z,skipb12d           ; $b126 28 05           ; 
             cp       a,$5d                ; $b128 fe 5d           ; 
             jp       nz,basic_raise_error_02 ; $b12a c2 aa f1        ; 
skipb12d:    rst      rst0010              ; $b12d d7              ; 
             ld       ($031c),hl           ; $b12e 22 1c 03        ; 
             pop      hl                   ; $b131 e1              ; 
             ld       ($01d8),hl           ; $b132 22 d8 01        ; 
             ld       e,$00                ; $b135 1e 00           ; 
             push     de                   ; $b137 d5              ; 
             defb     $11                  ; $b138 11 e5 f5        ;   As: ld     de,$f5e5   ; 11 e5 f5   ; Next: $b13b
;
; Array lookup / creation entry.  Scans the array-descriptor area
; ($0324..$0326) for a matching name+type and either resolves the
; requested element, returns the descriptor, or builds a new array.
;
var_find_or_create_array: push     hl                   ; $b139 e5              ; 
             push     af                   ; $b13a f5              ; 
             ld       hl,($0324)           ; $b13b 2a 24 03        ; 
             defb     $3e                  ; $b13e 3e 19           ;   As: ld     a,$19      ; 3e 19      ; Next: $b140
;
; Inner array-descriptor walk.  Compares [type][char1][char2], then
; uses the stored array payload length to skip to the next descriptor.
;
var_scan_array_descriptors: add      hl,de                ; $b13f 19              ; 
             ld       de,($0326)           ; $b140 ed 5b 26 03     ; 
             rst      rst0020              ; $b144 e7              ; 
             jr       z,var_create_array_descriptor ; $b145 28 2c           ; 
             ld       e,(hl)               ; $b147 5e              ; 
             inc      hl                   ; $b148 23              ; 
             ld       a,(hl)               ; $b149 7e              ; 
             inc      hl                   ; $b14a 23              ; 
             cp       a,c                  ; $b14b b9              ; 
             jr       nz,skipb156          ; $b14c 20 08           ; 
             ld       a,($01d9)            ; $b14e 3a d9 01        ; 
             cp       a,e                  ; $b151 bb              ; 
             jr       nz,skipb156          ; $b152 20 02           ; 
             ld       a,(hl)               ; $b154 7e              ; 
             cp       a,b                  ; $b155 b8              ; 
skipb156:    inc      hl                   ; $b156 23              ; 
             ld       e,(hl)               ; $b157 5e              ; 
             inc      hl                   ; $b158 23              ; 
             ld       d,(hl)               ; $b159 56              ; 
             inc      hl                   ; $b15a 23              ; 
             jr       nz,var_scan_array_descriptors ; $b15b 20 e2           ; 
             ld       a,($01d8)            ; $b15d 3a d8 01        ; 
             or       a,a                  ; $b160 b7              ; 
             jp       nz,basic_raise_error_0a ; $b161 c2 b3 f1        ; 
             pop      af                   ; $b164 f1              ; 
             ld       b,h                  ; $b165 44              ; 
             ld       c,l                  ; $b166 4d              ; 
             jp       z,pop_hl_and_return  ; $b167 ca f2 cd        ; 
             sub      a,(hl)               ; $b16a 96              ; 
             jr       z,var_compute_array_offset ; $b16b 28 60           ; 
loopb16d:    ld       de,$0009             ; $b16d 11 09 00        ; 
             jp       basic_raise_error    ; $b170 c3 c7 f1        ; 

;
; Create a new array descriptor from the parsed subscript list.
; Stores type/name/rank and dimension bounds, computes total element
; count, allocates backing storage, zero-fills it, and updates $0326.
;
var_create_array_descriptor: ld       a,($01d9)            ; $b173 3a d9 01        ; 
             ld       (hl),a               ; $b176 77              ; 
             inc      hl                   ; $b177 23              ; 
             ld       e,a                  ; $b178 5f              ; 
             ld       d,$00                ; $b179 16 00           ; 
             pop      af                   ; $b17b f1              ; 
             jp       z,jumpf590           ; $b17c ca 90 f5        ; 
             ld       (hl),c               ; $b17f 71              ; 
             inc      hl                   ; $b180 23              ; 
             ld       (hl),b               ; $b181 70              ; 
             inc      hl                   ; $b182 23              ; 
             ld       c,a                  ; $b183 4f              ; 
             call     check_stack_space    ; $b184 cd 8b d1        ; 
             inc      hl                   ; $b187 23              ; 
             inc      hl                   ; $b188 23              ; 
             ld       ($0206),hl           ; $b189 22 06 02        ; 
             ld       (hl),c               ; $b18c 71              ; 
             inc      hl                   ; $b18d 23              ; 
             ld       a,($01d8)            ; $b18e 3a d8 01        ; 
             rla                           ; $b191 17              ; 
             ld       a,c                  ; $b192 79              ; 
loopb193:    ld       bc,$000b             ; $b193 01 0b 00        ; 
             jr       nc,var_store_array_bound ; $b196 30 02           ; 
             pop      bc                   ; $b198 c1              ; 
             inc      bc                   ; $b199 03              ; 
;
; var_store_array_bound — store one declared array bound and extend the
; cumulative element count
; Writes the current dimension extent into the new array descriptor, then
; multiplies the running total element count before the next bound is
; parsed or allocation begins.
;
var_store_array_bound: ld       (hl),c               ; $b19a 71              ; 
             push     af                   ; $b19b f5              ; 
             inc      hl                   ; $b19c 23              ; 
             ld       (hl),b               ; $b19d 70              ; 
             inc      hl                   ; $b19e 23              ; 
             call     uint16_mul_bc_de     ; $b19f cd 9e cc        ; 
             pop      af                   ; $b1a2 f1              ; 
             dec      a                    ; $b1a3 3d              ; 
             jr       nz,loopb193          ; $b1a4 20 ed           ; 
             push     af                   ; $b1a6 f5              ; 
             ld       b,d                  ; $b1a7 42              ; 
             ld       c,e                  ; $b1a8 4b              ; 
             ex       de,hl                ; $b1a9 eb              ; 
             add      hl,de                ; $b1aa 19              ; 
             jp       c,basic_relink_and_raise_oom ; $b1ab da 9a d1        ; 
             call     check_move_target_space ; $b1ae cd 94 d1        ; 
             ld       ($0326),hl           ; $b1b1 22 26 03        ; 
loopb1b4:    dec      hl                   ; $b1b4 2b              ; 
             ld       (hl),$00             ; $b1b5 36 00           ; 
             rst      rst0020              ; $b1b7 e7              ; 
             jr       nz,loopb1b4          ; $b1b8 20 fa           ; 
             inc      bc                   ; $b1ba 03              ; 
             ld       d,a                  ; $b1bb 57              ; 
             ld       hl,($0206)           ; $b1bc 2a 06 02        ; 
             ld       e,(hl)               ; $b1bf 5e              ; 
             ex       de,hl                ; $b1c0 eb              ; 
             add      hl,hl                ; $b1c1 29              ; 
             add      hl,bc                ; $b1c2 09              ; 
             ex       de,hl                ; $b1c3 eb              ; 
             dec      hl                   ; $b1c4 2b              ; 
             dec      hl                   ; $b1c5 2b              ; 
             ld       (hl),e               ; $b1c6 73              ; 
             inc      hl                   ; $b1c7 23              ; 
             ld       (hl),d               ; $b1c8 72              ; 
             inc      hl                   ; $b1c9 23              ; 
             pop      af                   ; $b1ca f1              ; 
             jr       c,skipb1fc           ; $b1cb 38 2f           ; 
;
; Convert a parsed subscript tuple into an element address inside an
; existing array.  Walks the declared extents, checks each index
; against bounds, and accumulates the row-major element offset.
;
var_compute_array_offset: ld       b,a                  ; $b1cd 47              ; 
             ld       c,a                  ; $b1ce 4f              ; 
             ld       a,(hl)               ; $b1cf 7e              ; 
             inc      hl                   ; $b1d0 23              ; 
             defb     $16                  ; $b1d1 16 e1           ;   As: ld     d,$e1      ; 16 e1      ; Next: $b1d3
loopb1d2:    pop      hl                   ; $b1d2 e1              ; 
             ld       e,(hl)               ; $b1d3 5e              ; 
             inc      hl                   ; $b1d4 23              ; 
             ld       d,(hl)               ; $b1d5 56              ; 
             inc      hl                   ; $b1d6 23              ; 
             ex       (sp),hl              ; $b1d7 e3              ; 
             push     af                   ; $b1d8 f5              ; 
             rst      rst0020              ; $b1d9 e7              ; 
             jr       nc,loopb16d          ; $b1da 30 91           ; 
             call     uint16_mul_bc_de     ; $b1dc cd 9e cc        ; 
             add      hl,de                ; $b1df 19              ; 
             pop      af                   ; $b1e0 f1              ; 
             dec      a                    ; $b1e1 3d              ; 
             ld       b,h                  ; $b1e2 44              ; 
             ld       c,l                  ; $b1e3 4d              ; 
             jr       nz,loopb1d2          ; $b1e4 20 ec           ; 
             ld       a,($01d9)            ; $b1e6 3a d9 01        ; 
             ld       b,h                  ; $b1e9 44              ; 
             ld       c,l                  ; $b1ea 4d              ; 
             add      hl,hl                ; $b1eb 29              ; 
             sub      a,$04                ; $b1ec d6 04           ; 
             jr       c,skipb1f4           ; $b1ee 38 04           ; 
             add      hl,hl                ; $b1f0 29              ; 
             jr       z,var_finish_array_element_ptr ; $b1f1 28 06           ; 
             add      hl,hl                ; $b1f3 29              ; 
skipb1f4:    or       a,a                  ; $b1f4 b7              ; 
             jp       po,var_finish_array_element_ptr ; $b1f5 e2 f9 b1        ; 
             add      hl,bc                ; $b1f8 09              ; 
;
; var_finish_array_element_ptr — add the descriptor base back onto the
; computed row-major offset
; Final tail of var_compute_array_offset.  Restores the descriptor base
; from the stack, adds it to the computed element displacement, returns
; DE = element slot, and reloads HL from the saved source pointer at
; $031c.
;
var_finish_array_element_ptr: pop      bc                   ; $b1f9 c1              ; 
             add      hl,bc                ; $b1fa 09              ; 
             ex       de,hl                ; $b1fb eb              ; 
skipb1fc:    ld       hl,($031c)           ; $b1fc 2a 1c 03        ; 
             ret                           ; $b1ff c9              ; 

;
; ----
; fp_add_work_signed — add signed work accumulator into main FP value
; ----
; Takes the packed operand in the work area at $049f, flips its sign
; when needed, then drops into the common exponent-alignment and
; mantissa-add path used by the transcendental library.
;
fp_add_work_signed: ld       hl,$049f             ; $b200 21 9f 04        ; 
             ld       a,(hl)               ; $b203 7e              ; 
             or       a,a                  ; $b204 b7              ; 
             ret      z                    ; $b205 c8              ; 

             xor      a,$80                ; $b206 ee 80           ; 
             ld       (hl),a               ; $b208 77              ; 
             jr       skipb214             ; $b209 18 09           ; 

callb20b:    call     callca49             ; $b20b cd 49 ca        ; 
;
; ----
; fp_add_work — align work and main FP accumulators
; ----
; Compares exponents in the main accumulator ($044e...) and work
; accumulator ($049f...), swaps them when necessary, shifts the
; smaller mantissa, then merges the two values.
;
fp_add_work: ld       hl,$049f             ; $b20e 21 9f 04        ; 
             ld       a,(hl)               ; $b211 7e              ; 
             or       a,a                  ; $b212 b7              ; 
             ret      z                    ; $b213 c8              ; 

skipb214:    and      a,$7f                ; $b214 e6 7f           ; 
             ld       b,a                  ; $b216 47              ; 
             ld       de,$044e             ; $b217 11 4e 04        ; 
             ld       a,(de)               ; $b21a 1a              ; 
             or       a,a                  ; $b21b b7              ; 
             jp       z,jumpca5f           ; $b21c ca 5f ca        ; 
             and      a,$7f                ; $b21f e6 7f           ; 
             sub      a,b                  ; $b221 90              ; 
             jr       nc,skipb235          ; $b222 30 11           ; 
             cpl                           ; $b224 2f              ; 
             inc      a                    ; $b225 3c              ; 
             push     af                   ; $b226 f5              ; 
             push     hl                   ; $b227 e5              ; 
             ld       b,$08                ; $b228 06 08           ; 
loopb22a:    ld       a,(de)               ; $b22a 1a              ; 
             ld       c,(hl)               ; $b22b 4e              ; 
             ld       (hl),a               ; $b22c 77              ; 
             ld       a,c                  ; $b22d 79              ; 
             ld       (de),a               ; $b22e 12              ; 
             inc      de                   ; $b22f 13              ; 
             inc      hl                   ; $b230 23              ; 
             djnz     loopb22a             ; $b231 10 f7           ; 
             pop      hl                   ; $b233 e1              ; 
             pop      af                   ; $b234 f1              ; 
skipb235:    cp       a,$10                ; $b235 fe 10           ; 
             ret      nc                   ; $b237 d0              ; 

             push     af                   ; $b238 f5              ; 
             xor      a,a                  ; $b239 af              ; 
             ld       ($0456),a            ; $b23a 32 56 04        ; 
             ld       ($04a7),a            ; $b23d 32 a7 04        ; 
             ld       hl,$04a0             ; $b240 21 a0 04        ; 
             pop      af                   ; $b243 f1              ; 
             call     fp_shift_decimal_right ; $b244 cd 2b b3        ; 
             ld       hl,$049f             ; $b247 21 9f 04        ; 
             ld       a,($044e)            ; $b24a 3a 4e 04        ; 
             xor      a,(hl)               ; $b24d ae              ; 
             jp       m,jumpb26c           ; $b24e fa 6c b2        ; 
             ld       a,($04a7)            ; $b251 3a a7 04        ; 
             ld       ($0456),a            ; $b254 32 56 04        ; 
             call     fp_accumulate_bcd    ; $b257 cd ce b2        ; 
             jr       nc,skipb2b1          ; $b25a 30 55           ; 
             ex       de,hl                ; $b25c eb              ; 
             ld       a,(hl)               ; $b25d 7e              ; 
             inc      (hl)                 ; $b25e 34              ; 
             xor      a,(hl)               ; $b25f ae              ; 
             jp       m,basic_raise_error_06 ; $b260 fa bc f1        ; 
             call     fp_shift_main_right  ; $b263 cd 6b b3        ; 
             ld       a,(hl)               ; $b266 7e              ; 
             or       a,$10                ; $b267 f6 10           ; 
             ld       (hl),a               ; $b269 77              ; 
             jr       skipb2b1             ; $b26a 18 45           ; 

jumpb26c:    call     fp_ten_complement_work ; $b26c cd e0 b2        ; 
jumpb26f:    ld       hl,$044f             ; $b26f 21 4f 04        ; 
             ld       bc,$0800             ; $b272 01 00 08        ; 
loopb275:    ld       a,(hl)               ; $b275 7e              ; 
             or       a,a                  ; $b276 b7              ; 
             jr       nz,skipb281          ; $b277 20 08           ; 
             inc      hl                   ; $b279 23              ; 
             dec      c                    ; $b27a 0d              ; 
             dec      c                    ; $b27b 0d              ; 
             djnz     loopb275             ; $b27c 10 f7           ; 
             jp       jumpc9d7             ; $b27e c3 d7 c9        ; 

skipb281:    and      a,$f0                ; $b281 e6 f0           ; 
             jr       nz,skipb28b          ; $b283 20 06           ; 
             push     hl                   ; $b285 e5              ; 
             call     fp_shift_mantissa_left ; $b286 cd 15 b3        ; 
             pop      hl                   ; $b289 e1              ; 
             dec      c                    ; $b28a 0d              ; 
skipb28b:    ld       a,$08                ; $b28b 3e 08           ; 
             sub      a,b                  ; $b28d 90              ; 
             jr       z,skipb2a2           ; $b28e 28 12           ; 
             push     af                   ; $b290 f5              ; 
             push     bc                   ; $b291 c5              ; 
             ld       c,b                  ; $b292 48              ; 
             ld       de,$044f             ; $b293 11 4f 04        ; 
             ld       b,$00                ; $b296 06 00           ; 
             ldir                          ; $b298 ed b0           ; 
             pop      bc                   ; $b29a c1              ; 
             pop      af                   ; $b29b f1              ; 
             ld       b,a                  ; $b29c 47              ; 
             xor      a,a                  ; $b29d af              ; 
loopb29e:    ld       (de),a               ; $b29e 12              ; 
             inc      de                   ; $b29f 13              ; 
             djnz     loopb29e             ; $b2a0 10 fc           ; 
skipb2a2:    ld       a,c                  ; $b2a2 79              ; 
             or       a,a                  ; $b2a3 b7              ; 
             jr       z,skipb2b1           ; $b2a4 28 0b           ; 
             ld       hl,$044e             ; $b2a6 21 4e 04        ; 
             ld       b,(hl)               ; $b2a9 46              ; 
             add      a,(hl)               ; $b2aa 86              ; 
             ld       (hl),a               ; $b2ab 77              ; 
             xor      a,b                  ; $b2ac a8              ; 
             jp       m,basic_raise_error_06 ; $b2ad fa bc f1        ; 
             ret      z                    ; $b2b0 c8              ; 

skipb2b1:    ld       hl,$0456             ; $b2b1 21 56 04        ; 
             ld       b,$07                ; $b2b4 06 07           ; 
jumpb2b6:    ld       a,(hl)               ; $b2b6 7e              ; 
             cp       a,$50                ; $b2b7 fe 50           ; 
             ret      c                    ; $b2b9 d8              ; 

             dec      hl                   ; $b2ba 2b              ; 
             xor      a,a                  ; $b2bb af              ; 
             scf                           ; $b2bc 37              ; 
loopb2bd:    adc      a,(hl)               ; $b2bd 8e              ; 
             daa                           ; $b2be 27              ; 
             ld       (hl),a               ; $b2bf 77              ; 
             ret      nc                   ; $b2c0 d0              ; 

             dec      hl                   ; $b2c1 2b              ; 
             djnz     loopb2bd             ; $b2c2 10 f9           ; 
             ld       a,(hl)               ; $b2c4 7e              ; 
             inc      (hl)                 ; $b2c5 34              ; 
             xor      a,(hl)               ; $b2c6 ae              ; 
             jp       m,basic_raise_error_06 ; $b2c7 fa bc f1        ; 
             inc      hl                   ; $b2ca 23              ; 
             ld       (hl),$10             ; $b2cb 36 10           ; 
             ret                           ; $b2cd c9              ; 

;
; ----
; fp_accumulate_bcd — accumulate packed-BCD mantissas
; ----
; Adds the seven-byte packed mantissa at $04a6 into the destination
; mantissa at $0455 and propagates decimal carries across the block.
;
fp_accumulate_bcd: ld       hl,$04a6             ; $b2ce 21 a6 04        ; 
             ld       de,$0455             ; $b2d1 11 55 04        ; 
             ld       b,$07                ; $b2d4 06 07           ; 
callb2d6:    xor      a,a                  ; $b2d6 af              ; 
loopb2d7:    ld       a,(de)               ; $b2d7 1a              ; 
             adc      a,(hl)               ; $b2d8 8e              ; 
             daa                           ; $b2d9 27              ; 
             ld       (de),a               ; $b2da 12              ; 
             dec      de                   ; $b2db 1b              ; 
             dec      hl                   ; $b2dc 2b              ; 
             djnz     loopb2d7             ; $b2dd 10 f8           ; 
             ret                           ; $b2df c9              ; 

;
; ----
; fp_ten_complement_work — negate packed work mantissa
; ----
; Converts the packed-BCD mantissa in the work area to its ten's
; complement form so subtraction can reuse the common addition path.
;
fp_ten_complement_work: ld       hl,$04a7             ; $b2e0 21 a7 04        ; 
             ld       a,(hl)               ; $b2e3 7e              ; 
             cp       a,$50                ; $b2e4 fe 50           ; 
             jr       nz,skipb2e9          ; $b2e6 20 01           ; 
             inc      (hl)                 ; $b2e8 34              ; 
skipb2e9:    ld       de,$0456             ; $b2e9 11 56 04        ; 
             ld       b,$08                ; $b2ec 06 08           ; 
             scf                           ; $b2ee 37              ; 
loopb2ef:    ld       a,$99                ; $b2ef 3e 99           ; 
             adc      a,$00                ; $b2f1 ce 00           ; 
             sub      a,(hl)               ; $b2f3 96              ; 
             ld       c,a                  ; $b2f4 4f              ; 
             ld       a,(de)               ; $b2f5 1a              ; 
             add      a,c                  ; $b2f6 81              ; 
             daa                           ; $b2f7 27              ; 
             ld       (de),a               ; $b2f8 12              ; 
             dec      de                   ; $b2f9 1b              ; 
             dec      hl                   ; $b2fa 2b              ; 
             djnz     loopb2ef             ; $b2fb 10 f2           ; 
             ret      c                    ; $b2fd d8              ; 

             ex       de,hl                ; $b2fe eb              ; 
             ld       a,(hl)               ; $b2ff 7e              ; 
             xor      a,$80                ; $b300 ee 80           ; 
             ld       (hl),a               ; $b302 77              ; 
             ld       hl,$0456             ; $b303 21 56 04        ; 
             ld       b,$08                ; $b306 06 08           ; 
             xor      a,a                  ; $b308 af              ; 
loopb309:    ld       a,$9a                ; $b309 3e 9a           ; 
             sbc      a,(hl)               ; $b30b 9e              ; 
             adc      a,$00                ; $b30c ce 00           ; 
             daa                           ; $b30e 27              ; 
             ccf                           ; $b30f 3f              ; 
             ld       (hl),a               ; $b310 77              ; 
             dec      hl                   ; $b311 2b              ; 
             djnz     loopb309             ; $b312 10 f5           ; 
             ret                           ; $b314 c9              ; 

;
; fp_shift_mantissa_left — left-shift a packed mantissa block during
; normalisation
; Shared counterpart to fp_shift_decimal_right.  Rotates the packed-BCD
; mantissa bytes left across the whole block until the caller's target
; digit alignment is restored after cancellation/subtraction.
;
fp_shift_mantissa_left: ld       hl,$0456             ; $b315 21 56 04        ; 
callb318:    push     bc                   ; $b318 c5              ; 
             ld       d,b                  ; $b319 50              ; 
             ld       c,$04                ; $b31a 0e 04           ; 
loopb31c:    push     hl                   ; $b31c e5              ; 
             or       a,a                  ; $b31d b7              ; 
loopb31e:    ld       a,(hl)               ; $b31e 7e              ; 
             rla                           ; $b31f 17              ; 
             ld       (hl),a               ; $b320 77              ; 
             dec      hl                   ; $b321 2b              ; 
             djnz     loopb31e             ; $b322 10 fa           ; 
             ld       b,d                  ; $b324 42              ; 
             pop      hl                   ; $b325 e1              ; 
             dec      c                    ; $b326 0d              ; 
             jr       nz,loopb31c          ; $b327 20 f3           ; 
             pop      bc                   ; $b329 c1              ; 
             ret                           ; $b32a c9              ; 

;
; ----
; fp_shift_decimal_right — decimal right shift with zero fill
; ----
; Shifts a packed mantissa right by a variable number of decimal
; digits, preserving packed-BCD format and clearing the vacated nibbles.
;
fp_shift_decimal_right: or       a,a                  ; $b32b b7              ; 
             rra                           ; $b32c 1f              ; 
             push     af                   ; $b32d f5              ; 
             or       a,a                  ; $b32e b7              ; 
             jr       z,skipb372           ; $b32f 28 41           ; 
             push     af                   ; $b331 f5              ; 
             cpl                           ; $b332 2f              ; 
             inc      a                    ; $b333 3c              ; 
             ld       c,a                  ; $b334 4f              ; 
             ld       b,$ff                ; $b335 06 ff           ; 
             ld       de,$0007             ; $b337 11 07 00        ; 
             add      hl,de                ; $b33a 19              ; 
             ld       d,h                  ; $b33b 54              ; 
             ld       e,l                  ; $b33c 5d              ; 
             add      hl,bc                ; $b33d 09              ; 
             ld       a,$08                ; $b33e 3e 08           ; 
             add      a,c                  ; $b340 81              ; 
             ld       c,a                  ; $b341 4f              ; 
             push     bc                   ; $b342 c5              ; 
             ld       b,$00                ; $b343 06 00           ; 
             lddr                          ; $b345 ed b8           ; 
             pop      bc                   ; $b347 c1              ; 
             pop      af                   ; $b348 f1              ; 
             inc      hl                   ; $b349 23              ; 
             inc      de                   ; $b34a 13              ; 
             push     de                   ; $b34b d5              ; 
             ld       b,a                  ; $b34c 47              ; 
             xor      a,a                  ; $b34d af              ; 
loopb34e:    ld       (hl),a               ; $b34e 77              ; 
             inc      hl                   ; $b34f 23              ; 
             djnz     loopb34e             ; $b350 10 fc           ; 
             pop      hl                   ; $b352 e1              ; 
             pop      af                   ; $b353 f1              ; 
             ret      nc                   ; $b354 d0              ; 

             ld       a,c                  ; $b355 79              ; 
loopb356:    push     bc                   ; $b356 c5              ; 
             push     de                   ; $b357 d5              ; 
             ld       d,a                  ; $b358 57              ; 
             ld       c,$04                ; $b359 0e 04           ; 
loopb35b:    ld       b,d                  ; $b35b 42              ; 
             push     hl                   ; $b35c e5              ; 
             or       a,a                  ; $b35d b7              ; 
loopb35e:    ld       a,(hl)               ; $b35e 7e              ; 
             rra                           ; $b35f 1f              ; 
             ld       (hl),a               ; $b360 77              ; 
             inc      hl                   ; $b361 23              ; 
             djnz     loopb35e             ; $b362 10 fa           ; 
             pop      hl                   ; $b364 e1              ; 
             dec      c                    ; $b365 0d              ; 
             jr       nz,loopb35b          ; $b366 20 f3           ; 
             pop      de                   ; $b368 d1              ; 
             pop      bc                   ; $b369 c1              ; 
             ret                           ; $b36a c9              ; 

;
; ----
; fp_shift_main_right — right shift the main mantissa block
; ----
; Entry helper for shifting the primary accumulator at $044f... right
; in packed-BCD form during exponent alignment and normalisation.
;
fp_shift_main_right: ld       hl,$044f             ; $b36b 21 4f 04        ; 
loopb36e:    ld       a,$08                ; $b36e 3e 08           ; 
             jr       loopb356             ; $b370 18 e4           ; 

skipb372:    pop      af                   ; $b372 f1              ; 
             ret      nc                   ; $b373 d0              ; 

             jr       loopb36e             ; $b374 18 f8           ; 

;
; ----
; fp_multiply_main_work — multiply main and work FP accumulators
; ----
; Combines signs and exponents from the two accumulators, prepares
; temporary multiply buffers, then dispatches into the shared packed-BCD
; multiply core before normalising the result.
;
fp_multiply_main_work: rst      rst0018              ; $b376 df              ; 
             ret      z                    ; $b377 c8              ; 

             ld       a,($049f)            ; $b378 3a 9f 04        ; 
             or       a,a                  ; $b37b b7              ; 
             jp       z,jumpc9d7           ; $b37c ca d7 c9        ; 
             ld       b,a                  ; $b37f 47              ; 
             ld       hl,$044e             ; $b380 21 4e 04        ; 
             xor      a,(hl)               ; $b383 ae              ; 
             and      a,$80                ; $b384 e6 80           ; 
             ld       c,a                  ; $b386 4f              ; 
             ld       a,b                  ; $b387 78              ; 
             and      a,$7f                ; $b388 e6 7f           ; 
             ld       b,a                  ; $b38a 47              ; 
             ld       a,(hl)               ; $b38b 7e              ; 
             and      a,$7f                ; $b38c e6 7f           ; 
             add      a,b                  ; $b38e 80              ; 
             ld       b,a                  ; $b38f 47              ; 
             ld       (hl),$00             ; $b390 36 00           ; 
             and      a,$c0                ; $b392 e6 c0           ; 
             ret      z                    ; $b394 c8              ; 

             cp       a,$c0                ; $b395 fe c0           ; 
             jr       nz,skipb39c          ; $b397 20 03           ; 
             jp       basic_raise_error_06 ; $b399 c3 bc f1        ; 

skipb39c:    ld       a,b                  ; $b39c 78              ; 
             add      a,$40                ; $b39d c6 40           ; 
             and      a,$7f                ; $b39f e6 7f           ; 
             ret      z                    ; $b3a1 c8              ; 

             or       a,c                  ; $b3a2 b1              ; 
             dec      hl                   ; $b3a3 2b              ; 
             ld       (hl),a               ; $b3a4 77              ; 
             ld       de,$049d             ; $b3a5 11 9d 04        ; 
             ld       bc,rst0008           ; $b3a8 01 08 00        ; 
             ld       hl,$0455             ; $b3ab 21 55 04        ; 
             push     de                   ; $b3ae d5              ; 
             lddr                          ; $b3af ed b8           ; 
             inc      hl                   ; $b3b1 23              ; 
             xor      a,a                  ; $b3b2 af              ; 
             ld       b,$08                ; $b3b3 06 08           ; 
loopb3b5:    ld       (hl),a               ; $b3b5 77              ; 
             inc      hl                   ; $b3b6 23              ; 
             djnz     loopb3b5             ; $b3b7 10 fc           ; 
             pop      de                   ; $b3b9 d1              ; 
             ld       bc,jumpb413          ; $b3ba 01 13 b4        ; 
             push     bc                   ; $b3bd c5              ; 
;
; ----
; fp_multiply_bcd — packed-BCD mantissa multiply core
; ----
; Generates the packed partial products used by LOG, EXP, SIN/COS,
; SQR, and other math functions, then compresses the result back into
; the ROM's floating-point work buffers.
;
fp_multiply_bcd: call     callb41a             ; $b3be cd 1a b4        ; 
             push     hl                   ; $b3c1 e5              ; 
             ld       bc,rst0008           ; $b3c2 01 08 00        ; 
             ex       de,hl                ; $b3c5 eb              ; 
             lddr                          ; $b3c6 ed b8           ; 
             ex       de,hl                ; $b3c8 eb              ; 
             ld       hl,$0495             ; $b3c9 21 95 04        ; 
             ld       b,$08                ; $b3cc 06 08           ; 
             call     callb2d6             ; $b3ce cd d6 b2        ; 
             pop      de                   ; $b3d1 d1              ; 
             call     callb41a             ; $b3d2 cd 1a b4        ; 
             ld       c,$07                ; $b3d5 0e 07           ; 
             ld       de,$04a6             ; $b3d7 11 a6 04        ; 
loopb3da:    ld       a,(de)               ; $b3da 1a              ; 
             or       a,a                  ; $b3db b7              ; 
             jr       nz,skipb3e2          ; $b3dc 20 04           ; 
             dec      de                   ; $b3de 1b              ; 
             dec      c                    ; $b3df 0d              ; 
             jr       loopb3da             ; $b3e0 18 f8           ; 

skipb3e2:    ld       a,(de)               ; $b3e2 1a              ; 
             dec      de                   ; $b3e3 1b              ; 
             push     de                   ; $b3e4 d5              ; 
             ld       hl,$0465             ; $b3e5 21 65 04        ; 
loopb3e8:    add      a,a                  ; $b3e8 87              ; 
             jr       c,skipb3f3           ; $b3e9 38 08           ; 
             jr       z,skipb401           ; $b3eb 28 14           ; 
loopb3ed:    ld       de,rst0008           ; $b3ed 11 08 00        ; 
             add      hl,de                ; $b3f0 19              ; 
             jr       loopb3e8             ; $b3f1 18 f5           ; 

skipb3f3:    push     af                   ; $b3f3 f5              ; 
             ld       b,$08                ; $b3f4 06 08           ; 
             ld       de,$0455             ; $b3f6 11 55 04        ; 
             push     hl                   ; $b3f9 e5              ; 
             call     callb2d6             ; $b3fa cd d6 b2        ; 
             pop      hl                   ; $b3fd e1              ; 
             pop      af                   ; $b3fe f1              ; 
             jr       loopb3ed             ; $b3ff 18 ec           ; 

skipb401:    ld       b,$0f                ; $b401 06 0f           ; 
             ld       de,$045c             ; $b403 11 5c 04        ; 
             ld       hl,$045d             ; $b406 21 5d 04        ; 
             call     callca58             ; $b409 cd 58 ca        ; 
             ld       (hl),$00             ; $b40c 36 00           ; 
             pop      de                   ; $b40e d1              ; 
             dec      c                    ; $b40f 0d              ; 
             jr       nz,skipb3e2          ; $b410 20 d0           ; 
             ret                           ; $b412 c9              ; 

jumpb413:    dec      hl                   ; $b413 2b              ; 
             ld       a,(hl)               ; $b414 7e              ; 
             inc      hl                   ; $b415 23              ; 
             ld       (hl),a               ; $b416 77              ; 
             jp       jumpb26f             ; $b417 c3 6f b2        ; 

callb41a:    ld       hl,$fff8             ; $b41a 21 f8 ff        ; 
             add      hl,de                ; $b41d 19              ; 
             ld       c,$03                ; $b41e 0e 03           ; 
loopb420:    ld       b,$08                ; $b420 06 08           ; 
             or       a,a                  ; $b422 b7              ; 
loopb423:    ld       a,(de)               ; $b423 1a              ; 
             adc      a,a                  ; $b424 8f              ; 
             daa                           ; $b425 27              ; 
             ld       (hl),a               ; $b426 77              ; 
             dec      hl                   ; $b427 2b              ; 
             dec      de                   ; $b428 1b              ; 
             djnz     loopb423             ; $b429 10 f8           ; 
             dec      c                    ; $b42b 0d              ; 
             jr       nz,loopb420          ; $b42c 20 f2           ; 
             ret                           ; $b42e c9              ; 

jumpb42f:    ld       a,($049f)            ; $b42f 3a 9f 04        ; 
             or       a,a                  ; $b432 b7              ; 
             jp       z,basic_raise_error_0b ; $b433 ca ad f1        ; 
             ld       b,a                  ; $b436 47              ; 
             ld       hl,$044e             ; $b437 21 4e 04        ; 
             ld       a,(hl)               ; $b43a 7e              ; 
             or       a,a                  ; $b43b b7              ; 
             jp       z,jumpc9d7           ; $b43c ca d7 c9        ; 
             xor      a,b                  ; $b43f a8              ; 
             and      a,$80                ; $b440 e6 80           ; 
             ld       c,a                  ; $b442 4f              ; 
             ld       a,b                  ; $b443 78              ; 
             and      a,$7f                ; $b444 e6 7f           ; 
             ld       b,a                  ; $b446 47              ; 
             ld       a,(hl)               ; $b447 7e              ; 
             and      a,$7f                ; $b448 e6 7f           ; 
             sub      a,b                  ; $b44a 90              ; 
             ld       b,a                  ; $b44b 47              ; 
             rra                           ; $b44c 1f              ; 
             xor      a,b                  ; $b44d a8              ; 
             and      a,$40                ; $b44e e6 40           ; 
             ld       (hl),$00             ; $b450 36 00           ; 
             jr       z,skipb45b           ; $b452 28 07           ; 
             ld       a,b                  ; $b454 78              ; 
             and      a,$80                ; $b455 e6 80           ; 
             ret      nz                   ; $b457 c0              ; 

loopb458:    jp       basic_raise_error_06 ; $b458 c3 bc f1        ; 

skipb45b:    ld       a,b                  ; $b45b 78              ; 
             add      a,$41                ; $b45c c6 41           ; 
             and      a,$7f                ; $b45e e6 7f           ; 
             ld       (hl),a               ; $b460 77              ; 
             jr       z,loopb458           ; $b461 28 f5           ; 
             or       a,c                  ; $b463 b1              ; 
             ld       (hl),$00             ; $b464 36 00           ; 
             dec      hl                   ; $b466 2b              ; 
             ld       (hl),a               ; $b467 77              ; 
             ld       de,$0455             ; $b468 11 55 04        ; 
             ld       hl,$04a6             ; $b46b 21 a6 04        ; 
             ld       b,$07                ; $b46e 06 07           ; 
loopb470:    ld       a,(hl)               ; $b470 7e              ; 
             or       a,a                  ; $b471 b7              ; 
             jr       nz,skipb478          ; $b472 20 04           ; 
             dec      de                   ; $b474 1b              ; 
             dec      hl                   ; $b475 2b              ; 
             djnz     loopb470             ; $b476 10 f8           ; 
skipb478:    ld       ($044a),hl           ; $b478 22 4a 04        ; 
             ex       de,hl                ; $b47b eb              ; 
             ld       ($0448),hl           ; $b47c 22 48 04        ; 
             ld       a,b                  ; $b47f 78              ; 
             ld       ($044c),a            ; $b480 32 4c 04        ; 
             ld       hl,$0496             ; $b483 21 96 04        ; 
jumpb486:    ld       b,$0f                ; $b486 06 0f           ; 
jumpb488:    push     hl                   ; $b488 e5              ; 
             push     bc                   ; $b489 c5              ; 
             ld       hl,($044a)           ; $b48a 2a 4a 04        ; 
             ex       de,hl                ; $b48d eb              ; 
             ld       hl,($0448)           ; $b48e 2a 48 04        ; 
             ld       a,($044c)            ; $b491 3a 4c 04        ; 
             ld       c,$ff                ; $b494 0e ff           ; 
loopb496:    scf                           ; $b496 37              ; 
             inc      c                    ; $b497 0c              ; 
             ld       b,a                  ; $b498 47              ; 
             push     hl                   ; $b499 e5              ; 
             push     de                   ; $b49a d5              ; 
loopb49b:    ld       a,$99                ; $b49b 3e 99           ; 
             adc      a,$00                ; $b49d ce 00           ; 
             ex       de,hl                ; $b49f eb              ; 
             sub      a,(hl)               ; $b4a0 96              ; 
             ex       de,hl                ; $b4a1 eb              ; 
             add      a,(hl)               ; $b4a2 86              ; 
             daa                           ; $b4a3 27              ; 
             ld       (hl),a               ; $b4a4 77              ; 
             dec      hl                   ; $b4a5 2b              ; 
             dec      de                   ; $b4a6 1b              ; 
             djnz     loopb49b             ; $b4a7 10 f2           ; 
             ld       a,(hl)               ; $b4a9 7e              ; 
             ccf                           ; $b4aa 3f              ; 
             sbc      a,$00                ; $b4ab de 00           ; 
             ld       (hl),a               ; $b4ad 77              ; 
             pop      de                   ; $b4ae d1              ; 
             pop      hl                   ; $b4af e1              ; 
             ld       a,($044c)            ; $b4b0 3a 4c 04        ; 
             jr       nc,loopb496          ; $b4b3 30 e1           ; 
             ld       b,a                  ; $b4b5 47              ; 
             ex       de,hl                ; $b4b6 eb              ; 
             call     callb2d6             ; $b4b7 cd d6 b2        ; 
             jr       nc,skipb4be          ; $b4ba 30 02           ; 
             ex       de,hl                ; $b4bc eb              ; 
             inc      (hl)                 ; $b4bd 34              ; 
skipb4be:    ld       a,c                  ; $b4be 79              ; 
             pop      bc                   ; $b4bf c1              ; 
             ld       c,a                  ; $b4c0 4f              ; 
             push     bc                   ; $b4c1 c5              ; 
             ld       a,b                  ; $b4c2 78              ; 
             or       a,a                  ; $b4c3 b7              ; 
             rra                           ; $b4c4 1f              ; 
             ld       b,a                  ; $b4c5 47              ; 
             inc      b                    ; $b4c6 04              ; 
             ld       e,b                  ; $b4c7 58              ; 
             ld       d,$00                ; $b4c8 16 00           ; 
             ld       hl,$044d             ; $b4ca 21 4d 04        ; 
             add      hl,de                ; $b4cd 19              ; 
             call     callb318             ; $b4ce cd 18 b3        ; 
             pop      bc                   ; $b4d1 c1              ; 
             pop      hl                   ; $b4d2 e1              ; 
             ld       a,b                  ; $b4d3 78              ; 
             inc      c                    ; $b4d4 0c              ; 
             dec      c                    ; $b4d5 0d              ; 
             jr       nz,skipb510          ; $b4d6 20 38           ; 
             cp       a,$0f                ; $b4d8 fe 0f           ; 
             jr       z,skipb501           ; $b4da 28 25           ; 
             rrca                          ; $b4dc 0f              ; 
             rlca                          ; $b4dd 07              ; 
             jr       nc,skipb510          ; $b4de 30 30           ; 
             push     bc                   ; $b4e0 c5              ; 
             push     hl                   ; $b4e1 e5              ; 
             ld       hl,$044e             ; $b4e2 21 4e 04        ; 
             ld       b,$08                ; $b4e5 06 08           ; 
loopb4e7:    ld       a,(hl)               ; $b4e7 7e              ; 
             or       a,a                  ; $b4e8 b7              ; 
             jr       nz,skipb4fc          ; $b4e9 20 11           ; 
             inc      hl                   ; $b4eb 23              ; 
             djnz     loopb4e7             ; $b4ec 10 f9           ; 
             pop      hl                   ; $b4ee e1              ; 
             pop      bc                   ; $b4ef c1              ; 
             ld       a,b                  ; $b4f0 78              ; 
             or       a,a                  ; $b4f1 b7              ; 
             rra                           ; $b4f2 1f              ; 
             inc      a                    ; $b4f3 3c              ; 
             ld       b,a                  ; $b4f4 47              ; 
             xor      a,a                  ; $b4f5 af              ; 
loopb4f6:    ld       (hl),a               ; $b4f6 77              ; 
             inc      hl                   ; $b4f7 23              ; 
             djnz     loopb4f6             ; $b4f8 10 fc           ; 
             jr       skipb522             ; $b4fa 18 26           ; 

skipb4fc:    pop      hl                   ; $b4fc e1              ; 
             pop      bc                   ; $b4fd c1              ; 
             ld       a,b                  ; $b4fe 78              ; 
             jr       skipb510             ; $b4ff 18 0f           ; 

skipb501:    ld       a,($044d)            ; $b501 3a 4d 04        ; 
             ld       e,a                  ; $b504 5f              ; 
             dec      a                    ; $b505 3d              ; 
             ld       ($044d),a            ; $b506 32 4d 04        ; 
             xor      a,e                  ; $b509 ab              ; 
             jp       p,jumpb486           ; $b50a f2 86 b4        ; 
             jp       jumpc9d7             ; $b50d c3 d7 c9        ; 

skipb510:    rra                           ; $b510 1f              ; 
             ld       a,c                  ; $b511 79              ; 
             jr       c,skipb519           ; $b512 38 05           ; 
             or       a,(hl)               ; $b514 b6              ; 
             ld       (hl),a               ; $b515 77              ; 
             inc      hl                   ; $b516 23              ; 
             jr       skipb51e             ; $b517 18 05           ; 

skipb519:    add      a,a                  ; $b519 87              ; 
             add      a,a                  ; $b51a 87              ; 
             add      a,a                  ; $b51b 87              ; 
             add      a,a                  ; $b51c 87              ; 
             ld       (hl),a               ; $b51d 77              ; 
skipb51e:    dec      b                    ; $b51e 05              ; 
             jp       nz,jumpb488          ; $b51f c2 88 b4        ; 
skipb522:    ld       hl,$0456             ; $b522 21 56 04        ; 
             ld       de,$049d             ; $b525 11 9d 04        ; 
             ld       b,$08                ; $b528 06 08           ; 
             call     callca58             ; $b52a cd 58 ca        ; 
             jp       jumpb413             ; $b52d c3 13 b4        ; 

;
; fn_cos — COS function
; COS(expr) — returns the cosine of expr (in radians)
; as a floating-point number.
; Implemented as COS(x) = SIN(x + π/2): loads the π/2
; constant from $b913 and adds it to the argument via
; callb7d4, then flips the sign flag (jumpc9e7: XOR $80
; on the sign byte at $044e), and falls through to the
; shared SIN angle-reduction path at $b54f.
; Delegates to the floating-point library in the ROM.
;
fn_cos:      ld       hl,$b913             ; $b530 21 13 b9        ; 
             call     fp_mul_with_operand  ; $b533 cd d4 b7        ; 
             ld       a,($044e)            ; $b536 3a 4e 04        ; 
             and      a,$7f                ; $b539 e6 7f           ; 
             ld       ($044e),a            ; $b53b 32 4e 04        ; 
             ld       hl,$b8d3             ; $b53e 21 d3 b8        ; 
             call     fp_add_signed_with_operand ; $b541 cd cb b7        ; 
             call     callc9e7             ; $b544 cd e7 c9        ; 
             jr       skipb54f             ; $b547 18 06           ; 

;
; fn_sin — SIN function
; SIN(expr) — returns the sine of expr (in radians) as
; a floating-point number.
; Loads the π-related constant at $b913, calls callb7d4
; (FP add/normalise), then performs angle reduction via
; the shared path at $b54f (checks sign/carry of $044e)
; before evaluating the sine polynomial approximation.
; Delegates to the floating-point library in the ROM.
;
fn_sin:      ld       hl,$b913             ; $b549 21 13 b9        ; 
             call     fp_mul_with_operand  ; $b54c cd d4 b7        ; 
skipb54f:    ld       a,($044e)            ; $b54f 3a 4e 04        ; 
             or       a,a                  ; $b552 b7              ; 
             call     m,fp_abs_with_restore_on_return ; $b553 fc 2d b8        ; 
             call     fp_push_main         ; $b556 cd 7b b8        ; 
             call     fn_int               ; $b559 cd 23 cc        ; 
             call     callb7fb             ; $b55c cd fb b7        ; 
             call     fp_pop_main          ; $b55f cd 91 b8        ; 
             call     fp_add_work_signed   ; $b562 cd 00 b2        ; 
             ld       a,($044e)            ; $b565 3a 4e 04        ; 
             cp       a,$40                ; $b568 fe 40           ; 
             jr       c,skipb58e           ; $b56a 38 22           ; 
             ld       a,($044f)            ; $b56c 3a 4f 04        ; 
             cp       a,$25                ; $b56f fe 25           ; 
             jr       c,skipb58e           ; $b571 38 1b           ; 
             cp       a,$75                ; $b573 fe 75           ; 
             jr       nc,skipb585          ; $b575 30 0e           ; 
             call     callb7fb             ; $b577 cd fb b7        ; 
             ld       hl,$b8c1             ; $b57a 21 c1 b8        ; 
             call     callb80a             ; $b57d cd 0a b8        ; 
             call     fp_add_work_signed   ; $b580 cd 00 b2        ; 
             jr       skipb58e             ; $b583 18 09           ; 

skipb585:    ld       hl,$b8cb             ; $b585 21 cb b8        ; 
             call     fp_exchange_main_work ; $b588 cd fe b7        ; 
             call     fp_add_work_signed   ; $b58b cd 00 b2        ; 
skipb58e:    ld       hl,$b99f             ; $b58e 21 9f b9        ; 
             jr       skipb606             ; $b591 18 73           ; 

;
; fn_tan — TAN function
; TAN(expr) — returns the tangent of expr (in radians)
; as a floating-point number.
; Computed as SIN/COS using shared FP library routines.
; Delegates to the floating-point library in the ROM.
;
fn_tan:      call     fp_push_main         ; $b593 cd 7b b8        ; 
             call     fn_cos               ; $b596 cd 30 b5        ; 
             call     fp_with_saved_operand ; $b599 cd 1c b8        ; 
             call     fn_sin               ; $b59c cd 49 b5        ; 
             call     fp_push_work         ; $b59f cd 8b b8        ; 
             ld       a,($049f)            ; $b5a2 3a 9f 04        ; 
             or       a,a                  ; $b5a5 b7              ; 
             jp       nz,jumpb42f          ; $b5a6 c2 2f b4        ; 
             jp       basic_raise_error_06 ; $b5a9 c3 bc f1        ; 

;
; fn_atn — ATN function
; ATN(expr) — returns the arctangent of expr in radians
; as a floating-point number.
; Uses a polynomial approximation via the FP library
; routines (callbxxx series).
; Delegates to the floating-point library in the ROM.
;
fn_atn:      ld       a,($044e)            ; $b5ac 3a 4e 04        ; 
             or       a,a                  ; $b5af b7              ; 
             ret      z                    ; $b5b0 c8              ; 

             call     m,fp_abs_with_restore_on_return ; $b5b1 fc 2d b8        ; 
             cp       a,$41                ; $b5b4 fe 41           ; 
             jr       c,callb5d3           ; $b5b6 38 1b           ; 
             call     callb7fb             ; $b5b8 cd fb b7        ; 
             ld       hl,$b8cb             ; $b5bb 21 cb b8        ; 
             call     callb80a             ; $b5be cd 0a b8        ; 
             call     jumpb42f             ; $b5c1 cd 2f b4        ; 
             call     callb5d3             ; $b5c4 cd d3 b5        ; 
             call     callb7fb             ; $b5c7 cd fb b7        ; 
             ld       hl,$b8f3             ; $b5ca 21 f3 b8        ; 
             call     callb80a             ; $b5cd cd 0a b8        ; 
             jp       fp_add_work_signed   ; $b5d0 c3 00 b2        ; 

callb5d3:    ld       hl,$b8fb             ; $b5d3 21 fb b8        ; 
             call     fp_compare_with_operand ; $b5d6 cd df b7        ; 
             jp       m,callb603           ; $b5d9 fa 03 b6        ; 
             call     fp_push_main         ; $b5dc cd 7b b8        ; 
             ld       hl,$b903             ; $b5df 21 03 b9        ; 
             call     fp_add_with_operand  ; $b5e2 cd c5 b7        ; 
             call     fp_with_saved_operand ; $b5e5 cd 1c b8        ; 
             ld       hl,$b903             ; $b5e8 21 03 b9        ; 
             call     fp_mul_with_operand  ; $b5eb cd d4 b7        ; 
             ld       hl,$b8cb             ; $b5ee 21 cb b8        ; 
             call     fp_add_signed_with_operand ; $b5f1 cd cb b7        ; 
             call     fp_push_work         ; $b5f4 cd 8b b8        ; 
             call     jumpb42f             ; $b5f7 cd 2f b4        ; 
             call     callb603             ; $b5fa cd 03 b6        ; 
             ld       hl,$b90b             ; $b5fd 21 0b b9        ; 
             jp       fp_add_with_operand  ; $b600 c3 c5 b7        ; 

callb603:    ld       hl,$b9e0             ; $b603 21 e0 b9        ; 
skipb606:    jp       fp_eval_series_times_main ; $b606 c3 40 b8        ; 

;
; fn_log — LOG function
; LOG(expr) — returns the natural logarithm of expr.
; The first byte is RST $18 ($df): evaluates expr via
; the RST $18 channel.  If the result is negative or
; zero (JP M / JP Z to $f590), an error is raised.
; Saves the exponent byte ($044e), forces it to $41
; (normalised form), then computes ln via a multi-step
; polynomial approximation using callb7df, callb87b,
; callb7c5, callb81c, callb852 etc.
; Delegates to the floating-point library in the ROM.
;
fn_log:      rst      rst0018              ; $b609 df              ; 
             jp       m,jumpf590           ; $b60a fa 90 f5        ; 
             jp       z,jumpf590           ; $b60d ca 90 f5        ; 
             ld       hl,$044e             ; $b610 21 4e 04        ; 
             ld       a,(hl)               ; $b613 7e              ; 
             push     af                   ; $b614 f5              ; 
             ld       (hl),$41             ; $b615 36 41           ; 
             ld       hl,$b8db             ; $b617 21 db b8        ; 
             call     fp_compare_with_operand ; $b61a cd df b7        ; 
             jp       m,jumpb627           ; $b61d fa 27 b6        ; 
             pop      af                   ; $b620 f1              ; 
             inc      a                    ; $b621 3c              ; 
             push     af                   ; $b622 f5              ; 
             ld       hl,$044e             ; $b623 21 4e 04        ; 
             dec      (hl)                 ; $b626 35              ; 
jumpb627:    pop      af                   ; $b627 f1              ; 
             ld       ($0206),a            ; $b628 32 06 02        ; 
             call     fp_push_main         ; $b62b cd 7b b8        ; 
             ld       hl,$b8cb             ; $b62e 21 cb b8        ; 
             call     fp_add_with_operand  ; $b631 cd c5 b7        ; 
             call     fp_with_saved_operand ; $b634 cd 1c b8        ; 
             ld       hl,$b8cb             ; $b637 21 cb b8        ; 
             call     fp_add_signed_with_operand ; $b63a cd cb b7        ; 
             call     fp_push_work         ; $b63d cd 8b b8        ; 
             call     jumpb42f             ; $b640 cd 2f b4        ; 
             call     fp_push_main         ; $b643 cd 7b b8        ; 
             call     callb7d1             ; $b646 cd d1 b7        ; 
             call     fp_push_main         ; $b649 cd 7b b8        ; 
             call     fp_push_main         ; $b64c cd 7b b8        ; 
             ld       hl,$b976             ; $b64f 21 76 b9        ; 
             call     fp_eval_series       ; $b652 cd 52 b8        ; 
             call     fp_with_saved_operand ; $b655 cd 1c b8        ; 
             ld       hl,$b955             ; $b658 21 55 b9        ; 
             call     fp_eval_series       ; $b65b cd 52 b8        ; 
             call     fp_push_work         ; $b65e cd 8b b8        ; 
             call     jumpb42f             ; $b661 cd 2f b4        ; 
             call     fp_push_work         ; $b664 cd 8b b8        ; 
             call     fp_multiply_main_work ; $b667 cd 76 b3        ; 
             ld       hl,$b8e3             ; $b66a 21 e3 b8        ; 
             call     fp_add_with_operand  ; $b66d cd c5 b7        ; 
             call     fp_push_work         ; $b670 cd 8b b8        ; 
             call     fp_multiply_main_work ; $b673 cd 76 b3        ; 
             call     fp_push_main         ; $b676 cd 7b b8        ; 
             ld       a,($0206)            ; $b679 3a 06 02        ; 
             sub      a,$41                ; $b67c d6 41           ; 
             ld       l,a                  ; $b67e 6f              ; 
             add      a,a                  ; $b67f 87              ; 
             sbc      a,a                  ; $b680 9f              ; 
             ld       h,a                  ; $b681 67              ; 
             call     callcb21             ; $b682 cd 21 cb        ; 
             call     fp_clear_extended_mantissa ; $b685 cd 98 cb        ; 
             call     fp_push_work         ; $b688 cd 8b b8        ; 
             call     fp_add_work          ; $b68b cd 0e b2        ; 
             ld       hl,$b8eb             ; $b68e 21 eb b8        ; 
             jp       fp_mul_with_operand  ; $b691 c3 d4 b7        ; 

;
; fn_sqr — SQR function
; SQR(expr) — returns the square root of expr.
; The first byte ($df) at $b694 is RST $18: evaluates
; expr, then the implementation uses the FP library
; (callb7d4, callb87b, callcae0, etc.) to compute the
; square root.
; Delegates to the floating-point library in the ROM.
;
fn_sqr:      rst      rst0018              ; $b694 df              ; 
             ret      z                    ; $b695 c8              ; 

             jp       m,jumpf590           ; $b696 fa 90 f5        ; 
             call     callb7fb             ; $b699 cd fb b7        ; 
             ld       a,($044e)            ; $b69c 3a 4e 04        ; 
             or       a,a                  ; $b69f b7              ; 
             rra                           ; $b6a0 1f              ; 
             adc      a,$20                ; $b6a1 ce 20           ; 
             ld       ($049f),a            ; $b6a3 32 9f 04        ; 
             ld       a,($044f)            ; $b6a6 3a 4f 04        ; 
             or       a,a                  ; $b6a9 b7              ; 
             rrca                          ; $b6aa 0f              ; 
             or       a,a                  ; $b6ab b7              ; 
             rrca                          ; $b6ac 0f              ; 
             and      a,$33                ; $b6ad e6 33           ; 
             add      a,$10                ; $b6af c6 10           ; 
             ld       ($04a0),a            ; $b6b1 32 a0 04        ; 
             ld       a,$07                ; $b6b4 3e 07           ; 
loopb6b6:    ld       ($0206),a            ; $b6b6 32 06 02        ; 
             call     fp_push_main         ; $b6b9 cd 7b b8        ; 
             call     fp_push_extended_tail ; $b6bc cd 76 b8        ; 
             call     jumpb42f             ; $b6bf cd 2f b4        ; 
             call     fp_push_work         ; $b6c2 cd 8b b8        ; 
             call     fp_add_work          ; $b6c5 cd 0e b2        ; 
             ld       hl,$b8c1             ; $b6c8 21 c1 b8        ; 
             call     fp_mul_with_operand  ; $b6cb cd d4 b7        ; 
             call     callb7fb             ; $b6ce cd fb b7        ; 
             call     fp_pop_main          ; $b6d1 cd 91 b8        ; 
             ld       a,($0206)            ; $b6d4 3a 06 02        ; 
             dec      a                    ; $b6d7 3d              ; 
             jr       nz,loopb6b6          ; $b6d8 20 dc           ; 
             jp       jumpb807             ; $b6da c3 07 b8        ; 

;
; fn_exp — EXP function
; EXP(expr) — returns e raised to the power of expr.
; Loads the constant at $b8b9 (ln(2) or related) and
; calls callb7d4 (FP multiply/normalise).  Then calls
; callb87b and callcae0 (CINT) to extract the integer
; exponent part.  Computes the fractional part via
; callcb90 (CDBL) and the exponential polynomial
; approximation from the FP library.
; Delegates to the floating-point library in the ROM.
; 
; ; ============================================================
; ; SGN and ABS handlers (near RST $18 at $C9C7)
; ; ============================================================
;
fn_exp:      ld       hl,$b8b9             ; $b6dd 21 b9 b8        ; 
             call     fp_mul_with_operand  ; $b6e0 cd d4 b7        ; 
             call     fp_push_main         ; $b6e3 cd 7b b8        ; 
             call     fn_cint              ; $b6e6 cd e0 ca        ; 
             ld       a,l                  ; $b6e9 7d              ; 
             rla                           ; $b6ea 17              ; 
             sbc      a,a                  ; $b6eb 9f              ; 
             cp       a,h                  ; $b6ec bc              ; 
             jr       z,skipb702           ; $b6ed 28 13           ; 
             ld       a,h                  ; $b6ef 7c              ; 
             or       a,a                  ; $b6f0 b7              ; 
             jp       p,jumpb700           ; $b6f1 f2 00 b7        ; 
             call     fp_set_double_precision ; $b6f4 cd a5 cb        ; 
             call     fp_pop_main          ; $b6f7 cd 91 b8        ; 
             ld       hl,$b8c3             ; $b6fa 21 c3 b8        ; 
             jp       callb80a             ; $b6fd c3 0a b8        ; 

jumpb700:    jr       skipb76e             ; $b700 18 6c           ; 

skipb702:    ld       ($0206),hl           ; $b702 22 06 02        ; 
             call     fn_cdbl              ; $b705 cd 90 cb        ; 
             call     callb7fb             ; $b708 cd fb b7        ; 
             call     fp_pop_main          ; $b70b cd 91 b8        ; 
             call     fp_add_work_signed   ; $b70e cd 00 b2        ; 
             ld       hl,$b8c1             ; $b711 21 c1 b8        ; 
             call     fp_compare_with_operand ; $b714 cd df b7        ; 
             push     af                   ; $b717 f5              ; 
             jr       z,skipb722           ; $b718 28 08           ; 
             jr       c,skipb722           ; $b71a 38 06           ; 
             ld       hl,$b8c1             ; $b71c 21 c1 b8        ; 
             call     fp_add_signed_with_operand ; $b71f cd cb b7        ; 
skipb722:    call     fp_push_main         ; $b722 cd 7b b8        ; 
             ld       hl,$b93c             ; $b725 21 3c b9        ; 
             call     fp_eval_series_times_main ; $b728 cd 40 b8        ; 
             call     fp_with_saved_operand ; $b72b cd 1c b8        ; 
             ld       hl,$b91b             ; $b72e 21 1b b9        ; 
             call     fp_eval_square_series ; $b731 cd 35 b8        ; 
             call     fp_push_work         ; $b734 cd 8b b8        ; 
             call     fp_push_extended_tail ; $b737 cd 76 b8        ; 
             call     fp_push_main         ; $b73a cd 7b b8        ; 
             call     fp_add_work_signed   ; $b73d cd 00 b2        ; 
             ld       hl,$0496             ; $b740 21 96 04        ; 
             call     callb814             ; $b743 cd 14 b8        ; 
             call     fp_push_work         ; $b746 cd 8b b8        ; 
             call     fp_pop_main          ; $b749 cd 91 b8        ; 
             call     fp_add_work          ; $b74c cd 0e b2        ; 
             ld       hl,$0496             ; $b74f 21 96 04        ; 
             call     fp_exchange_main_work ; $b752 cd fe b7        ; 
             call     jumpb42f             ; $b755 cd 2f b4        ; 
             pop      af                   ; $b758 f1              ; 
             jr       c,skipb763           ; $b759 38 08           ; 
             jr       z,skipb763           ; $b75b 28 06           ; 
             ld       hl,$b8db             ; $b75d 21 db b8        ; 
             call     fp_mul_with_operand  ; $b760 cd d4 b7        ; 
skipb763:    ld       a,($0206)            ; $b763 3a 06 02        ; 
             ld       hl,$044e             ; $b766 21 4e 04        ; 
             ld       c,(hl)               ; $b769 4e              ; 
             add      a,(hl)               ; $b76a 86              ; 
             ld       (hl),a               ; $b76b 77              ; 
             xor      a,c                  ; $b76c a9              ; 
             ret      p                    ; $b76d f0              ; 

skipb76e:    jp       basic_raise_error_06 ; $b76e c3 bc f1        ; 

;
; fn_rnd — RND function
; RND(expr) — returns a pseudo-random floating-point
; number in the range [0, 1).
; If expr > 0: returns the next value in the sequence.
; If expr = 0: returns the last value generated.
; If expr < 0: reseeds the generator with expr.
; The first byte ($df) at $b771 is RST $18 which
; evaluates the argument.  The seed is kept in RAM.
; Delegates to the floating-point library in the ROM.
; 
; ; ============================================================
; ; EXP handler ($B6DD)
; ; ============================================================
;
fn_rnd:      rst      rst0018              ; $b771 df              ; 
             ld       hl,$04af             ; $b772 21 af 04        ; 
             call     z,fp_seed_from_masked_block ; $b775 cc e5 b7        ; 
             call     m,callb814           ; $b778 fc 14 b8        ; 
             ld       hl,$0496             ; $b77b 21 96 04        ; 
             ld       de,$04af             ; $b77e 11 af 04        ; 
             call     fp_copy_block        ; $b781 cd 17 b8        ; 
             ld       hl,$b8a9             ; $b784 21 a9 b8        ; 
             call     fp_exchange_main_work ; $b787 cd fe b7        ; 
             ld       hl,$b8a1             ; $b78a 21 a1 b8        ; 
             call     callb80a             ; $b78d cd 0a b8        ; 
             ld       de,$049d             ; $b790 11 9d 04        ; 
             call     fp_multiply_bcd      ; $b793 cd be b3        ; 
             ld       de,$0456             ; $b796 11 56 04        ; 
             ld       hl,$04b0             ; $b799 21 b0 04        ; 
             ld       b,$07                ; $b79c 06 07           ; 
             call     callca51             ; $b79e cd 51 ca        ; 
             ld       hl,$04af             ; $b7a1 21 af 04        ; 
             ld       (hl),$00             ; $b7a4 36 00           ; 
             call     callb80a             ; $b7a6 cd 0a b8        ; 
             ld       hl,$044e             ; $b7a9 21 4e 04        ; 
             ld       (hl),$40             ; $b7ac 36 40           ; 
             xor      a,a                  ; $b7ae af              ; 
             ld       ($0456),a            ; $b7af 32 56 04        ; 
             jp       jumpb26f             ; $b7b2 c3 6f b2        ; 

;
; fp_load_rnd_seed_constant — copy the fixed ROM seed block into the saved
; RND state area at $04af
; Thin wrapper over fp_copy_block used when the pseudo-random generator
; reinitialises from its built-in bootstrap seed.
;
fp_load_rnd_seed_constant: ld       de,$b8b1             ; $b7b5 11 b1 b8        ; 
             ld       hl,$04af             ; $b7b8 21 af 04        ; 
             jr       fp_copy_block        ; $b7bb 18 5a           ; 

             defb     $cd,$21,$cb,$21,$af,$04,$18,$4f              ; .!.!...O   ; 
;
; fp_add_with_operand — swap a caller-supplied FP block into work and add
; it to the main accumulator
; Shared wrapper used by the transcendental polynomial code before it
; rejoins fp_add_work.
;
fp_add_with_operand: call     fp_exchange_main_work ; $b7c5 cd fe b7        ; 
             jp       fp_add_work          ; $b7c8 c3 0e b2        ; 

;
; fp_add_signed_with_operand — swap a caller-supplied FP block into work
; and rejoin the signed add/subtract path
; Companion wrapper to fp_add_with_operand that falls through
; fp_add_work_signed when the operand sign must participate in the merge.
;
fp_add_signed_with_operand: call     fp_exchange_main_work ; $b7cb cd fe b7        ; 
             jp       fp_add_work_signed   ; $b7ce c3 00 b2        ; 

callb7d1:    ld       hl,$044e             ; $b7d1 21 4e 04        ; 
;
; ----
; fp_mul_with_operand — swap in operand and multiply
; ----
; Common entry used by many math functions: first exchanges the
; caller-supplied operand with the work accumulator via $b7fe, then
; falls into the shared multiply-and-normalise path at $b376.
;
fp_mul_with_operand: call     fp_exchange_main_work ; $b7d4 cd fe b7        ; 
             jr       skipb84f             ; $b7d7 18 76           ; 

             defb     $cd,$fe,$b7,$c3,$2f,$b4                      ; ..../.     ; 
;
; fp_compare_with_operand — compare the main FP accumulator against a
; caller-supplied operand block
; Exchanges the operand into the work area, then jumps to
; fp_compare_work_and_main.
;
fp_compare_with_operand: call     fp_exchange_main_work ; $b7df cd fe b7        ; 
             jp       fp_compare_work_and_main ; $b7e2 c3 b4 ca        ; 

;
; fp_seed_from_masked_block — copy an 8-byte block after clearing the
; sign/flag bits in every byte
; Used by the RND path to sanitise seed bytes before copying them into
; the active FP register block.
;
fp_seed_from_masked_block: push     af                   ; $b7e5 f5              ; 
             push     hl                   ; $b7e6 e5              ; 
             call     lcd_submit_tile_mode ; $b7e7 cd 0b db        ; 
             push     de                   ; $b7ea d5              ; 
             ld       b,$08                ; $b7eb 06 08           ; 
loopb7ed:    ld       a,(de)               ; $b7ed 1a              ; 
             and      a,$77                ; $b7ee e6 77           ; 
             ld       (de),a               ; $b7f0 12              ; 
             inc      de                   ; $b7f1 13              ; 
             djnz     loopb7ed             ; $b7f2 10 f9           ; 
             pop      de                   ; $b7f4 d1              ; 
             pop      hl                   ; $b7f5 e1              ; 
             call     fp_copy_block        ; $b7f6 cd 17 b8        ; 
             pop      af                   ; $b7f9 f1              ; 
             ret                           ; $b7fa c9              ; 

callb7fb:    ld       hl,$044e             ; $b7fb 21 4e 04        ; 
;
; ----
; fp_exchange_main_work — exchange the main and work FP registers
; ----
; Copies eight bytes between the main accumulator at $044e and the
; secondary work area at $049f. Used pervasively to stage operands.
;
fp_exchange_main_work: ld       de,$049f             ; $b7fe 11 9f 04        ; 
loopb801:    ex       de,hl                ; $b801 eb              ; 
             call     fp_copy_block        ; $b802 cd 17 b8        ; 
             ex       de,hl                ; $b805 eb              ; 
             ret                           ; $b806 c9              ; 

jumpb807:    ld       hl,$049f             ; $b807 21 9f 04        ; 
callb80a:    ld       de,$044e             ; $b80a 11 4e 04        ; 
             jr       loopb801             ; $b80d 18 f2           ; 

             defb     $11,$9f,$04,$18,$03                          ; .....      ; 
callb814:    ld       de,$044e             ; $b814 11 4e 04        ; 
;
; ----
; fp_copy_block — copy one 8-byte FP register block
; ----
; Thin wrapper around callca51 with B=$08. Used for main/work swaps,
; seed copies, and moving packed FP values between scratch buffers.
;
fp_copy_block: ld       b,$08                ; $b817 06 08           ; 
             jp       callca51             ; $b819 c3 51 ca        ; 

;
; ----
; fp_with_saved_operand — preserve callback target across FP setup
; ----
; Pops a return address into $041d, snapshots both FP register sets,
; then jumps back through the saved address. This lets higher-level
; math code sequence binary operations without losing its operand.
;
fp_with_saved_operand: pop      hl                   ; $b81c e1              ; 
             ld       ($041d),hl           ; $b81d 22 1d 04        ; 
             call     fp_push_work         ; $b820 cd 8b b8        ; 
             call     fp_push_main         ; $b823 cd 7b b8        ; 
             call     jumpb807             ; $b826 cd 07 b8        ; 
             ld       hl,($041d)           ; $b829 2a 1d 04        ; 
             jp       (hl)                 ; $b82c e9              ; 

;
; fp_abs_with_restore_on_return — flip the current FP sign and install the
; inverse-sign tail as the synthetic return address
; Lets odd/even transcendental helpers work on `ABS(x)` and automatically
; restore the original sign when the wrapped computation returns.
;
fp_abs_with_restore_on_return: call     callc9e7             ; $b82d cd e7 c9        ; 
             ld       hl,callc9e7          ; $b830 21 e7 c9        ; 
             ex       (sp),hl              ; $b833 e3              ; 
             jp       (hl)                 ; $b834 e9              ; 

;
; fp_eval_square_series — square the current operand, then evaluate a
; counted coefficient series
; Saves the coefficient-table pointer in $041d, squares the active FP
; value, then falls into the shared Horner-series worker at $b852.
;
fp_eval_square_series: ld       ($041d),hl           ; $b835 22 1d 04        ; 
             call     callb7d1             ; $b838 cd d1 b7        ; 
             ld       hl,($041d)           ; $b83b 2a 1d 04        ; 
             jr       fp_eval_series       ; $b83e 18 12           ; 

;
; fp_eval_series_times_main — evaluate a counted coefficient series, then
; multiply the result by the saved main operand
; Used by LOG / ATN / EXP-style approximations that need `x * P(x)` after
; preserving the original argument across the internal polynomial pass.
;
fp_eval_series_times_main: ld       ($041d),hl           ; $b840 22 1d 04        ; 
             call     fp_push_main         ; $b843 cd 7b b8        ; 
             ld       hl,($041d)           ; $b846 2a 1d 04        ; 
             call     fp_eval_square_series ; $b849 cd 35 b8        ; 
             call     fp_push_work         ; $b84c cd 8b b8        ; 
skipb84f:    jp       fp_multiply_main_work ; $b84f c3 76 b3        ; 

;
; fp_eval_series — evaluate a counted FP coefficient series by Horner's
; rule
; The first byte at (HL) is the remaining coefficient count.  Each pass
; copies the next 8-byte coefficient, multiplies the current partial
; result by the saved operand, adds the new coefficient, and repeats.
;
fp_eval_series: ld       a,(hl)               ; $b852 7e              ; 
             push     af                   ; $b853 f5              ; 
             inc      hl                   ; $b854 23              ; 
             push     hl                   ; $b855 e5              ; 
             ld       hl,$041d             ; $b856 21 1d 04        ; 
             call     callb814             ; $b859 cd 14 b8        ; 
             pop      hl                   ; $b85c e1              ; 
             call     callb80a             ; $b85d cd 0a b8        ; 
loopb860:    pop      af                   ; $b860 f1              ; 
             dec      a                    ; $b861 3d              ; 
             ret      z                    ; $b862 c8              ; 

             push     af                   ; $b863 f5              ; 
             push     hl                   ; $b864 e5              ; 
             ld       hl,$041d             ; $b865 21 1d 04        ; 
             call     fp_mul_with_operand  ; $b868 cd d4 b7        ; 
             pop      hl                   ; $b86b e1              ; 
             call     fp_exchange_main_work ; $b86c cd fe b7        ; 
             push     hl                   ; $b86f e5              ; 
             call     fp_add_work          ; $b870 cd 0e b2        ; 
             pop      hl                   ; $b873 e1              ; 
             jr       loopb860             ; $b874 18 ea           ; 

;
; fp_push_extended_tail — push the extended mantissa scratch block onto
; the CPU stack
; Variant of fp_push_main used by SQR and related helpers when the packed
; bytes rooted at $04a6 must be preserved across iterative steps.
;
fp_push_extended_tail: ld       hl,$04a6             ; $b876 21 a6 04        ; 
             jr       skipb87e             ; $b879 18 03           ; 

;
; ----
; fp_push_main — push main FP accumulator on the CPU stack
; ----
; Pushes the four packed words that make up the primary FP value
; starting at $0455 so later helpers can restore or reuse it.
;
fp_push_main: ld       hl,$0455             ; $b87b 21 55 04        ; 
skipb87e:    ld       a,$04                ; $b87e 3e 04           ; 
             pop      de                   ; $b880 d1              ; 
loopb881:    ld       b,(hl)               ; $b881 46              ; 
             dec      hl                   ; $b882 2b              ; 
             ld       c,(hl)               ; $b883 4e              ; 
             dec      hl                   ; $b884 2b              ; 
             push     bc                   ; $b885 c5              ; 
             dec      a                    ; $b886 3d              ; 
             jr       nz,loopb881          ; $b887 20 f8           ; 
             ex       de,hl                ; $b889 eb              ; 
             jp       (hl)                 ; $b88a e9              ; 

;
; ----
; fp_push_work — push work FP accumulator on the CPU stack
; ----
; Stack helper paired with fp_push_main, but sourced from the work
; register block at $049f. Often used around polynomial steps.
;
fp_push_work: ld       hl,$049f             ; $b88b 21 9f 04        ; 
             jp       jumpb894             ; $b88e c3 94 b8        ; 

;
; ----
; fp_pop_main — restore the main FP accumulator from the stack
; ----
; Pops the stacked packed-FP words back into the primary accumulator
; at $044e after a helper has consumed a saved operand.
; 
; ; ============================================================
; ; Floating-point math library function handlers ($B530–$B771)
; ; ============================================================
; ; These handlers reside in the floating-point library region.
; ; Each evaluates its BASIC argument via RST $18 ($C9C7) or a
; ; helper, then delegates to low-level FP arithmetic routines
; ; (callbxxx series).  The ROM uses a 5-byte packed floating-
; ; point format with the exponent at $044e and the mantissa at
; ; $044f–$0453 (or similar).
;
fp_pop_main: ld       hl,$044e             ; $b891 21 4e 04        ; 
jumpb894:    ld       a,$04                ; $b894 3e 04           ; 
             pop      de                   ; $b896 d1              ; 
loopb897:    pop      bc                   ; $b897 c1              ; 
             ld       (hl),c               ; $b898 71              ; 
             inc      hl                   ; $b899 23              ; 
             ld       (hl),b               ; $b89a 70              ; 
             inc      hl                   ; $b89b 23              ; 
             dec      a                    ; $b89c 3d              ; 
             jr       nz,loopb897          ; $b89d 20 f8           ; 
             ex       de,hl                ; $b89f eb              ; 
             jp       (hl)                 ; $b8a0 e9              ; 

             defb     $00,$14,$38,$98,$20,$42,$08,$21,$00,$21      ; ..8..B.!.! ; 
             defb     $13,$24,$86,$54,$05,$19,$00,$40,$64,$96      ; .$.T...@d. ; 
             defm     "Q7#X@CB"                                                 ;
             defb     $94,$48,$19,$03,$24,$40,$50,$00,$00,$00      ; .H..$@P... ; 
             defb     $00,$00,$00,$00,$00,$41,$10,$00,$00,$00      ; .....A.... ; 
             defb     $00,$00,$00,$40,$25,$00,$00,$00,$00,$00      ; ...@%..... ; 
             defb     $00                                          ; .          ; 
             defm     "A1b'v`"                                                  ;
             defb     $16,$84,$40,$86,$85,$88,$96,$38,$06,$50      ; ..@....8.P ; 
             defb     $41,$23,$02,$58,$50,$92,$99,$40,$41,$15      ; A#.XP..@A. ; 
             defm     "pyc&yI@&yI"                                              ;
             defb     $19,$24,$31,$12,$41,$17,$32,$05,$08,$07      ; .$1.A.2... ; 
             defb     $56,$89,$40,$52,$35,$98,$77,$55,$98,$30      ; V.@R5.wU.0 ; 
             defb     $40,$15,$91,$54,$94,$30,$91,$90,$04,$41      ; @..T.0...A ; 
             defb     $10,$00,$00,$00,$00,$00,$00,$43,$15,$93      ; .......C.. ; 
             defb     $74,$15                                      ; t.         ; 
             defm     "#`1D'"                                                   ;
             defb     $09,$31,$69,$40,$85,$16,$44,$44,$97          ; .1i@..DD.  ; 
             defm     "c5W@X"                                                   ;
             defb     $03,$42,$18,$31,$23,$60,$15,$92,$75,$43      ; .B.1#`..uC ; 
             defb     $83,$14,$06,$72,$12,$93                      ; ...r..     ; 
             defm     "qDQx"                                                    ;
             defb     $09,$19,$91,$51,$62,$04,$c0,$71,$43,$33      ; ...Qb..qC3 ; 
             defb     $82,$15                                      ; ..         ; 
             defm     "2&AbP6Q",$12,"y"                                         ;
             defb     $08,$c2,$13                                  ; ...        ; 
             defm     "h#p$"                                                    ;
             defb     $15,$03,$41,$85,$16,$73,$19,$87,$23,$89      ; ..A..s..#. ; 
             defb     $05,$41,$10,$00,$00,$00,$00,$00,$00,$c2      ; .A........ ; 
             defb     $13,$21,$04,$78,$35,$01,$56,$42,$47,$92      ; .!.x5.VBG. ; 
             defb     $52,$56,$04,$38,$73,$c2,$64,$90,$66,$82      ; RV.8s.d.f. ; 
             defb     $74,$09                                      ; t.         ; 
             defm     "CB)AWP"                                                  ;
             defb     $17,$23,$23,$08,$c0,$69,$21,$56,$92,$29      ; .##..i!V.) ; 
             defb     $18,$09,$41,$38,$17,$28,$86,$38,$57,$71      ; ..A8.(.8Wq ; 
             defb     $c2,$15,$09,$44,$99,$47,$48,$01,$42,$42      ; ...D.GH.BB ; 
             defb     $05,$86,$89,$66,$73,$55,$c2                  ; ...fsU.    ; 
             defm     "vpXYh2"                                                  ;
             defb     $91,$42,$81                                  ; .B.        ; 
             defm     "`RI'U"                                                   ;
             defb     $13,$c2,$41,$34,$17,$02,$24,$03,$98,$41      ; ..A4..$..A ; 
             defb     $62,$83,$18,$53,$07,$17,$96,$08,$bf,$52      ; b..S.....R ; 
             defb     $08,$69,$39,$04,$00,$00                      ; .i9...     ; 
             defm     "?u0qI"                                                   ;
             defb     $13,$48,$00,$bf,$90,$81                      ; .H....     ; 
             defm     "42$pP@",$11,$11                                          ;
             defb     $07,$94,$18,$40,$29,$c0,$14,$28,$56,$08      ; ...@)..(V. ; 
             defb     $55,$48,$84,$40,$19,$99,$99,$99,$94,$89      ; UH.@...... ; 
             defb     $67,$c0                                      ; g.         ; 
             defm     "333331`A"                                                ;
             defb     $10,$00,$00,$00,$00,$00,$00                  ; .......    ; 
;
; ----
; parse_numeric_literal — parse BASIC numeric text into the FP accumulator
; ----
; Shared scanner used by VAL and the BASIC expression reader. Handles
; optional sign, decimal point, exponent marker, and type suffixes
; before routing the value into the numeric conversion helpers.
;
parse_numeric_literal: ex       de,hl                ; $ba21 eb              ; 
             ld       bc,$00ff             ; $ba22 01 ff 00        ; 
             ld       h,b                  ; $ba25 60              ; 
             ld       l,b                  ; $ba26 68              ; 
             call     num_store_int_result ; $ba27 cd ef ca        ; 
             ex       de,hl                ; $ba2a eb              ; 
             ld       a,(hl)               ; $ba2b 7e              ; 
             cp       a,$26                ; $ba2c fe 26           ; 
             jp       z,expr_parse_hex_octal_literal ; $ba2e ca 4f fb        ; 
             cp       a,$2d                ; $ba31 fe 2d           ; 
             push     af                   ; $ba33 f5              ; 
             jr       z,num_scan_literal_body ; $ba34 28 05           ; 
             cp       a,$2b                ; $ba36 fe 2b           ; 
             jr       z,num_scan_literal_body ; $ba38 28 01           ; 
             dec      hl                   ; $ba3a 2b              ; 
;
; num_scan_literal_body — main digit / exponent scan loop inside
; parse_numeric_literal
; Reached after the optional leading sign has been consumed.  Dispatches
; digits, decimal point, exponent marker, and suffix characters while
; maintaining the in-flight integer / floating representation.
;
num_scan_literal_body: rst      rst0010              ; $ba3b d7              ; 
             jp       c,num_accumulate_digit ; $ba3c da 0e bb        ; 
             cp       a,$2e                ; $ba3f fe 2e           ; 
             jp       z,num_note_decimal_point ; $ba41 ca d7 ba        ; 
             cp       a,$65                ; $ba44 fe 65           ; 
             jr       z,skipba4a           ; $ba46 28 02           ; 
             cp       a,$45                ; $ba48 fe 45           ; 
skipba4a:    jr       nz,skipba66          ; $ba4a 20 1a           ; 
             push     hl                   ; $ba4c e5              ; 
             rst      rst0010              ; $ba4d d7              ; 
             cp       a,$6c                ; $ba4e fe 6c           ; 
             jr       z,skipba5c           ; $ba50 28 0a           ; 
             cp       a,$4c                ; $ba52 fe 4c           ; 
             jr       z,skipba5c           ; $ba54 28 06           ; 
             cp       a,$71                ; $ba56 fe 71           ; 
             jr       z,skipba5c           ; $ba58 28 02           ; 
             cp       a,$51                ; $ba5a fe 51           ; 
skipba5c:    pop      hl                   ; $ba5c e1              ; 
             jr       z,skipba65           ; $ba5d 28 06           ; 
             rst      rst0030              ; $ba5f f7              ; 
             jr       nc,skipba7d          ; $ba60 30 1b           ; 
             xor      a,a                  ; $ba62 af              ; 
             jr       skipba7e             ; $ba63 18 19           ; 

skipba65:    ld       a,(hl)               ; $ba65 7e              ; 
skipba66:    cp       a,$25                ; $ba66 fe 25           ; 
             jp       z,num_suffix_integer ; $ba68 ca ea ba        ; 
             cp       a,$23                ; $ba6b fe 23           ; 
             jp       z,num_suffix_double  ; $ba6d ca f8 ba        ; 
             cp       a,$21                ; $ba70 fe 21           ; 
             jp       z,num_suffix_single  ; $ba72 ca f9 ba        ; 
             cp       a,$64                ; $ba75 fe 64           ; 
             jr       z,skipba7d           ; $ba77 28 04           ; 
             cp       a,$44                ; $ba79 fe 44           ; 
             jr       nz,loopbaa6          ; $ba7b 20 29           ; 
skipba7d:    or       a,a                  ; $ba7d b7              ; 
skipba7e:    call     numeric_select_precision ; $ba7e cd ff ba        ; 
             rst      rst0010              ; $ba81 d7              ; 
             push     de                   ; $ba82 d5              ; 
             ld       d,$00                ; $ba83 16 00           ; 
             call     num_scan_optional_sign ; $ba85 cd fe fb        ; 
             ld       c,d                  ; $ba88 4a              ; 
             pop      de                   ; $ba89 d1              ; 
loopba8a:    rst      rst0010              ; $ba8a d7              ; 
             jr       nc,skipbaa0          ; $ba8b 30 13           ; 
             ld       a,e                  ; $ba8d 7b              ; 
             cp       a,$0c                ; $ba8e fe 0c           ; 
             jr       nc,skipba9c          ; $ba90 30 0a           ; 
             rlca                          ; $ba92 07              ; 
             rlca                          ; $ba93 07              ; 
             add      a,e                  ; $ba94 83              ; 
             rlca                          ; $ba95 07              ; 
             add      a,(hl)               ; $ba96 86              ; 
             sub      a,$30                ; $ba97 d6 30           ; 
             ld       e,a                  ; $ba99 5f              ; 
             jr       loopba8a             ; $ba9a 18 ee           ; 

skipba9c:    ld       e,$80                ; $ba9c 1e 80           ; 
             jr       loopba8a             ; $ba9e 18 ea           ; 

skipbaa0:    inc      c                    ; $baa0 0c              ; 
             jr       nz,loopbaa6          ; $baa1 20 03           ; 
             xor      a,a                  ; $baa3 af              ; 
             sub      a,e                  ; $baa4 93              ; 
             ld       e,a                  ; $baa5 5f              ; 
loopbaa6:    rst      rst0030              ; $baa6 f7              ; 
             jp       m,skipbabc           ; $baa7 fa bc ba        ; 
             ld       a,($044e)            ; $baaa 3a 4e 04        ; 
             or       a,a                  ; $baad b7              ; 
             jr       z,skipbabc           ; $baae 28 0c           ; 
             ld       a,d                  ; $bab0 7a              ; 
             sub      a,b                  ; $bab1 90              ; 
             add      a,e                  ; $bab2 83              ; 
             add      a,$40                ; $bab3 c6 40           ; 
             ld       ($044e),a            ; $bab5 32 4e 04        ; 
             or       a,a                  ; $bab8 b7              ; 
             call     m,num_literal_raise_overflow ; $bab9 fc d4 ba        ; 
skipbabc:    pop      af                   ; $babc f1              ; 
             push     hl                   ; $babd e5              ; 
             call     z,jumpc9e0           ; $babe cc e0 c9        ; 
             rst      rst0030              ; $bac1 f7              ; 
             jr       nc,skipbacf          ; $bac2 30 0b           ; 
             pop      hl                   ; $bac4 e1              ; 
             ret      pe                   ; $bac5 e8              ; 

             push     hl                   ; $bac6 e5              ; 
             ld       hl,pop_hl_and_return ; $bac7 21 f2 cd        ; 
             push     hl                   ; $baca e5              ; 
             call     num_parse_minint_edge ; $bacb cd f8 ca        ; 
             ret                           ; $bace c9              ; 

skipbacf:    call     skipb2b1             ; $bacf cd b1 b2        ; 
             pop      hl                   ; $bad2 e1              ; 
             ret                           ; $bad3 c9              ; 

;
; num_literal_raise_overflow — shared numeric-literal overflow/error tail
; Used when too many exponent or mantissa digits would overflow the
; literal builder before the final coercion stage.
;
num_literal_raise_overflow: jp       basic_raise_error_06 ; $bad4 c3 bc f1        ; 

;
; Handles the `.` branch inside parse_numeric_literal.  Marks that
; fractional digits are now being scanned, promotes to floating-point
; format when needed, and then resumes the shared digit loop.
;
num_note_decimal_point: rst      rst0030              ; $bad7 f7              ; 
             inc      c                    ; $bad8 0c              ; 
             jr       nz,loopbaa6          ; $bad9 20 cb           ; 
             jr       nc,skipbae7          ; $badb 30 0a           ; 
             call     numeric_select_precision ; $badd cd ff ba        ; 
             ld       a,($044e)            ; $bae0 3a 4e 04        ; 
             or       a,a                  ; $bae3 b7              ; 
             jr       nz,skipbae7          ; $bae4 20 01           ; 
             ld       d,a                  ; $bae6 57              ; 
skipbae7:    jp       num_scan_literal_body ; $bae7 c3 3b ba        ; 

;
; Handles a trailing `%` integer suffix.  Queues fn_cint as the final
; coercion step, then resumes the common numeric-literal exit path.
;
num_suffix_integer: rst      rst0010              ; $baea d7              ; 
             pop      af                   ; $baeb f1              ; 
             push     hl                   ; $baec e5              ; 
             ld       hl,pop_hl_and_return ; $baed 21 f2 cd        ; 
             push     hl                   ; $baf0 e5              ; 
             ld       hl,fn_cint           ; $baf1 21 e0 ca        ; 
             push     hl                   ; $baf4 e5              ; 
             push     af                   ; $baf5 f5              ; 
             jr       loopbaa6             ; $baf6 18 ae           ; 

;
; Handles a trailing `#` suffix.  Leaves the precision selector in
; the double-precision state before entering numeric_select_precision.
;
num_suffix_double: or       a,a                  ; $baf8 b7              ; 
;
; Handles a trailing `!` suffix.  Routes the literal through the
; single-precision side of numeric_select_precision.
;
num_suffix_single: call     numeric_select_precision ; $baf9 cd ff ba        ; 
             rst      rst0010              ; $bafc d7              ; 
             jr       loopbaa6             ; $bafd 18 a7           ; 

;
; ----
; numeric_select_precision — choose CSNG versus CDBL result format
; ----
; Small but central bridge that preserves registers, then dispatches
; to fn_csng or fn_cdbl depending on the pending precision/type flags.
;
numeric_select_precision: push     hl                   ; $baff e5              ; 
             push     de                   ; $bb00 d5              ; 
             push     bc                   ; $bb01 c5              ; 
             push     af                   ; $bb02 f5              ; 
             call     z,fn_csng            ; $bb03 cc 08 cb        ; 
             pop      af                   ; $bb06 f1              ; 
             call     nz,fn_cdbl           ; $bb07 c4 90 cb        ; 
             pop      bc                   ; $bb0a c1              ; 
             pop      de                   ; $bb0b d1              ; 
             pop      hl                   ; $bb0c e1              ; 
             ret                           ; $bb0d c9              ; 

;
; Core decimal digit accumulator used by parse_numeric_literal.
; Updates the in-flight value with ×10+digit, tracks digit-count /
; scale state, and loops back to fetch the next character.
;
num_accumulate_digit: sub      a,$30                ; $bb0e d6 30           ; 
             jr       nz,skipbb19          ; $bb10 20 07           ; 
             or       a,c                  ; $bb12 b1              ; 
             jr       z,skipbb19           ; $bb13 28 04           ; 
             and      a,d                  ; $bb15 a2              ; 
             jp       z,num_scan_literal_body ; $bb16 ca 3b ba        ; 
skipbb19:    inc      d                    ; $bb19 14              ; 
             ld       a,d                  ; $bb1a 7a              ; 
             cp       a,$07                ; $bb1b fe 07           ; 
             jr       nz,skipbb23          ; $bb1d 20 04           ; 
             or       a,a                  ; $bb1f b7              ; 
             call     numeric_select_precision ; $bb20 cd ff ba        ; 
skipbb23:    push     de                   ; $bb23 d5              ; 
             ld       a,b                  ; $bb24 78              ; 
             add      a,c                  ; $bb25 81              ; 
             inc      a                    ; $bb26 3c              ; 
             ld       b,a                  ; $bb27 47              ; 
             push     bc                   ; $bb28 c5              ; 
             push     hl                   ; $bb29 e5              ; 
             ld       a,(hl)               ; $bb2a 7e              ; 
             sub      a,$30                ; $bb2b d6 30           ; 
             push     af                   ; $bb2d f5              ; 
             rst      rst0030              ; $bb2e f7              ; 
             jp       p,jumpbb57           ; $bb2f f2 57 bb        ; 
             ld       hl,($0450)           ; $bb32 2a 50 04        ; 
             ld       de,$0ccd             ; $bb35 11 cd 0c        ; 
             rst      rst0020              ; $bb38 e7              ; 
             jr       nc,skipbb54          ; $bb39 30 19           ; 
             ld       d,h                  ; $bb3b 54              ; 
             ld       e,l                  ; $bb3c 5d              ; 
             add      hl,hl                ; $bb3d 29              ; 
             add      hl,hl                ; $bb3e 29              ; 
             add      hl,de                ; $bb3f 19              ; 
             add      hl,hl                ; $bb40 29              ; 
             pop      af                   ; $bb41 f1              ; 
             ld       c,a                  ; $bb42 4f              ; 
             add      hl,bc                ; $bb43 09              ; 
             ld       a,h                  ; $bb44 7c              ; 
             or       a,a                  ; $bb45 b7              ; 
             jp       m,jumpbb52           ; $bb46 fa 52 bb        ; 
             ld       ($0450),hl           ; $bb49 22 50 04        ; 
loopbb4c:    pop      hl                   ; $bb4c e1              ; 
             pop      bc                   ; $bb4d c1              ; 
             pop      de                   ; $bb4e d1              ; 
             jp       num_scan_literal_body ; $bb4f c3 3b ba        ; 

jumpbb52:    ld       a,c                  ; $bb52 79              ; 
             push     af                   ; $bb53 f5              ; 
skipbb54:    call     fp_load_int_accumulator ; $bb54 cd 1e cb        ; 
jumpbb57:    pop      af                   ; $bb57 f1              ; 
             pop      hl                   ; $bb58 e1              ; 
             pop      bc                   ; $bb59 c1              ; 
             pop      de                   ; $bb5a d1              ; 
             jr       nz,skipbb69          ; $bb5b 20 0c           ; 
             ld       a,($044e)            ; $bb5d 3a 4e 04        ; 
             or       a,a                  ; $bb60 b7              ; 
             ld       a,$00                ; $bb61 3e 00           ; 
             jr       nz,skipbb69          ; $bb63 20 04           ; 
             ld       d,a                  ; $bb65 57              ; 
             jp       num_scan_literal_body ; $bb66 c3 3b ba        ; 

skipbb69:    push     de                   ; $bb69 d5              ; 
             push     bc                   ; $bb6a c5              ; 
             push     hl                   ; $bb6b e5              ; 
             push     af                   ; $bb6c f5              ; 
             ld       hl,$044e             ; $bb6d 21 4e 04        ; 
             ld       (hl),$01             ; $bb70 36 01           ; 
             ld       a,d                  ; $bb72 7a              ; 
             cp       a,$10                ; $bb73 fe 10           ; 
             jr       c,skipbb7a           ; $bb75 38 03           ; 
             pop      af                   ; $bb77 f1              ; 
             jr       loopbb4c             ; $bb78 18 d2           ; 

skipbb7a:    inc      a                    ; $bb7a 3c              ; 
             or       a,a                  ; $bb7b b7              ; 
             rra                           ; $bb7c 1f              ; 
             ld       b,$00                ; $bb7d 06 00           ; 
             ld       c,a                  ; $bb7f 4f              ; 
             add      hl,bc                ; $bb80 09              ; 
             pop      af                   ; $bb81 f1              ; 
             ld       c,a                  ; $bb82 4f              ; 
             ld       a,d                  ; $bb83 7a              ; 
             rra                           ; $bb84 1f              ; 
             ld       a,c                  ; $bb85 79              ; 
             jr       nc,skipbb8c          ; $bb86 30 04           ; 
             add      a,a                  ; $bb88 87              ; 
             add      a,a                  ; $bb89 87              ; 
             add      a,a                  ; $bb8a 87              ; 
             add      a,a                  ; $bb8b 87              ; 
skipbb8c:    or       a,(hl)               ; $bb8c b6              ; 
             ld       (hl),a               ; $bb8d 77              ; 
             jr       loopbb4c             ; $bb8e 18 bc           ; 

;
; print_in_keyword — emit the BASIC message fragment `" in "` for shared
; diagnostics / prompts
; Loads the ROM string at basic_msg_in and hands it to the standard
; string-item printer.
;
print_in_keyword: push     hl                   ; $bb90 e5              ; 
             ld       hl,basic_msg_in      ; $bb91 21 64 f1        ; 
             call     print_prepare_string_item ; $bb94 cd b1 d5        ; 
             pop      hl                   ; $bb97 e1              ; 
;
; print_uint16_decimal — convert the integer result in HL to decimal text
; at the shared number-output buffer
; Routes HL through num_store_int_result, seeds the formatting buffer with
; a leading blank, then rejoins the common numeric-to-string formatter.
;
print_uint16_decimal: ld       bc,$d5b0             ; $bb98 01 b0 d5        ; 
             push     bc                   ; $bb9b c5              ; 
             call     num_store_int_result ; $bb9c cd ef ca        ; 
             xor      a,a                  ; $bb9f af              ; 
             ld       ($0206),a            ; $bba0 32 06 02        ; 
             ld       hl,$041e             ; $bba3 21 1e 04        ; 
             ld       (hl),$20             ; $bba6 36 20           ; 
             or       a,(hl)               ; $bba8 b6              ; 
             jr       jumpbbc7             ; $bba9 18 1c           ; 

;
; ----
; str_format_number — convert numeric accumulator to printable text
; ----
; Main decimal formatting entry used by STR$ and by other routines that
; need an ASCII rendering of the current FP value. Handles sign, digit
; generation, trimming, and formatting-mode selection.
;
str_format_number: xor      a,a                  ; $bbab af              ; 
callbbac:    call     str_prepare_number_format ; $bbac cd ee be        ; 
             and      a,$08                ; $bbaf e6 08           ; 
             jr       z,skipbbb5           ; $bbb1 28 02           ; 
             ld       (hl),$2b             ; $bbb3 36 2b           ; 
skipbbb5:    ex       de,hl                ; $bbb5 eb              ; 
             call     callc9fb             ; $bbb6 cd fb c9        ; 
             ex       de,hl                ; $bbb9 eb              ; 
             jp       p,jumpbbc7           ; $bbba f2 c7 bb        ; 
             ld       (hl),$2d             ; $bbbd 36 2d           ; 
             push     bc                   ; $bbbf c5              ; 
             push     hl                   ; $bbc0 e5              ; 
             call     jumpc9e0             ; $bbc1 cd e0 c9        ; 
             pop      hl                   ; $bbc4 e1              ; 
             pop      bc                   ; $bbc5 c1              ; 
             or       a,h                  ; $bbc6 b4              ; 
jumpbbc7:    inc      hl                   ; $bbc7 23              ; 
             ld       (hl),$30             ; $bbc8 36 30           ; 
             ld       a,($0206)            ; $bbca 3a 06 02        ; 
             ld       d,a                  ; $bbcd 57              ; 
             rla                           ; $bbce 17              ; 
             ld       a,($01d9)            ; $bbcf 3a d9 01        ; 
             jp       c,jumpbc7c           ; $bbd2 da 7c bc        ; 
             jp       z,jumpbc74           ; $bbd5 ca 74 bc        ; 
             cp       a,$04                ; $bbd8 fe 04           ; 
             jr       nc,skipbc26          ; $bbda 30 4a           ; 
             ld       bc,$0000             ; $bbdc 01 00 00        ; 
             call     callbe5f             ; $bbdf cd 5f be        ; 
;
; ----
; str_init_number_buffer — seed the numeric output buffer
; ----
; Initialises the temporary string buffer at $041e with space, zero,
; and suffix markers before digits are emitted into it.
;
str_init_number_buffer: ld       hl,$041e             ; $bbe2 21 1e 04        ; 
             ld       b,(hl)               ; $bbe5 46              ; 
             ld       c,$20                ; $bbe6 0e 20           ; 
             ld       a,($0206)            ; $bbe8 3a 06 02        ; 
             ld       e,a                  ; $bbeb 5f              ; 
             and      a,$20                ; $bbec e6 20           ; 
             jr       z,loopbbfc           ; $bbee 28 0c           ; 
             ld       a,b                  ; $bbf0 78              ; 
             cp       a,c                  ; $bbf1 b9              ; 
             ld       c,$2a                ; $bbf2 0e 2a           ; 
             jr       nz,loopbbfc          ; $bbf4 20 06           ; 
             ld       a,e                  ; $bbf6 7b              ; 
             and      a,$04                ; $bbf7 e6 04           ; 
             jr       nz,loopbbfc          ; $bbf9 20 01           ; 
             ld       b,c                  ; $bbfb 41              ; 
loopbbfc:    ld       (hl),c               ; $bbfc 71              ; 
             rst      rst0010              ; $bbfd d7              ; 
             jr       z,skipbc14           ; $bbfe 28 14           ; 
             cp       a,$45                ; $bc00 fe 45           ; 
             jr       z,skipbc14           ; $bc02 28 10           ; 
             cp       a,$44                ; $bc04 fe 44           ; 
             jr       z,skipbc14           ; $bc06 28 0c           ; 
             cp       a,$30                ; $bc08 fe 30           ; 
             jr       z,loopbbfc           ; $bc0a 28 f0           ; 
             cp       a,$2c                ; $bc0c fe 2c           ; 
             jr       z,loopbbfc           ; $bc0e 28 ec           ; 
             cp       a,$2e                ; $bc10 fe 2e           ; 
             jr       nz,skipbc17          ; $bc12 20 03           ; 
skipbc14:    dec      hl                   ; $bc14 2b              ; 
             ld       (hl),$30             ; $bc15 36 30           ; 
skipbc17:    ld       a,e                  ; $bc17 7b              ; 
             and      a,$10                ; $bc18 e6 10           ; 
             jr       z,skipbc1f           ; $bc1a 28 03           ; 
             dec      hl                   ; $bc1c 2b              ; 
             ld       (hl),$24             ; $bc1d 36 24           ; 
skipbc1f:    ld       a,e                  ; $bc1f 7b              ; 
             and      a,$04                ; $bc20 e6 04           ; 
             ret      nz                   ; $bc22 c0              ; 

             dec      hl                   ; $bc23 2b              ; 
             ld       (hl),b               ; $bc24 70              ; 
             ret                           ; $bc25 c9              ; 

skipbc26:    push     hl                   ; $bc26 e5              ; 
             call     callbee1             ; $bc27 cd e1 be        ; 
             ld       d,b                  ; $bc2a 50              ; 
             inc      d                    ; $bc2b 14              ; 
             ld       bc,$0300             ; $bc2c 01 00 03        ; 
             ld       a,($044e)            ; $bc2f 3a 4e 04        ; 
             sub      a,$3f                ; $bc32 d6 3f           ; 
             jr       c,skipbc3e           ; $bc34 38 08           ; 
             inc      d                    ; $bc36 14              ; 
             cp       a,d                  ; $bc37 ba              ; 
             jr       nc,skipbc3e          ; $bc38 30 04           ; 
             inc      a                    ; $bc3a 3c              ; 
             ld       b,a                  ; $bc3b 47              ; 
             ld       a,$02                ; $bc3c 3e 02           ; 
skipbc3e:    sub      a,$02                ; $bc3e d6 02           ; 
             pop      hl                   ; $bc40 e1              ; 
             push     af                   ; $bc41 f5              ; 
             call     callbe12             ; $bc42 cd 12 be        ; 
             ld       (hl),$30             ; $bc45 36 30           ; 
             call     z,callca40           ; $bc47 cc 40 ca        ; 
             call     callbe37             ; $bc4a cd 37 be        ; 
loopbc4d:    dec      hl                   ; $bc4d 2b              ; 
             ld       a,(hl)               ; $bc4e 7e              ; 
             cp       a,$30                ; $bc4f fe 30           ; 
             jr       z,loopbc4d           ; $bc51 28 fa           ; 
             cp       a,$2e                ; $bc53 fe 2e           ; 
             call     nz,callca40          ; $bc55 c4 40 ca        ; 
             pop      af                   ; $bc58 f1              ; 
             jr       z,skipbc75           ; $bc59 28 1a           ; 
;
; ----
; str_append_exponent — append scientific-notation exponent
; ----
; Writes the E±nn trailer used when a numeric result must be printed
; in exponential form. Shared by the generic number formatter.
;
str_append_exponent: ld       (hl),$45             ; $bc5b 36 45           ; 
             inc      hl                   ; $bc5d 23              ; 
             ld       (hl),$2b             ; $bc5e 36 2b           ; 
             jp       p,jumpbc67           ; $bc60 f2 67 bc        ; 
             ld       (hl),$2d             ; $bc63 36 2d           ; 
             cpl                           ; $bc65 2f              ; 
             inc      a                    ; $bc66 3c              ; 
jumpbc67:    ld       b,$2f                ; $bc67 06 2f           ; 
loopbc69:    inc      b                    ; $bc69 04              ; 
             sub      a,$0a                ; $bc6a d6 0a           ; 
             jr       nc,loopbc69          ; $bc6c 30 fb           ; 
             add      a,$3a                ; $bc6e c6 3a           ; 
             inc      hl                   ; $bc70 23              ; 
             ld       (hl),b               ; $bc71 70              ; 
             inc      hl                   ; $bc72 23              ; 
             ld       (hl),a               ; $bc73 77              ; 
jumpbc74:    inc      hl                   ; $bc74 23              ; 
skipbc75:    ld       (hl),$00             ; $bc75 36 00           ; 
             ex       de,hl                ; $bc77 eb              ; 
             ld       hl,$041e             ; $bc78 21 1e 04        ; 
             ret                           ; $bc7b c9              ; 

jumpbc7c:    inc      hl                   ; $bc7c 23              ; 
             push     bc                   ; $bc7d c5              ; 
             cp       a,$04                ; $bc7e fe 04           ; 
             ld       a,d                  ; $bc80 7a              ; 
             jr       nc,skipbcea          ; $bc81 30 67           ; 
             rra                           ; $bc83 1f              ; 
             jp       c,jumpbd73           ; $bc84 da 73 bd        ; 
             ld       bc,$0603             ; $bc87 01 03 06        ; 
             call     callbe0a             ; $bc8a cd 0a be        ; 
             pop      de                   ; $bc8d d1              ; 
             ld       a,d                  ; $bc8e 7a              ; 
             sub      a,$05                ; $bc8f d6 05           ; 
             call     p,callbdea           ; $bc91 f4 ea bd        ; 
             call     callbe5f             ; $bc94 cd 5f be        ; 
jumpbc97:    ld       a,e                  ; $bc97 7b              ; 
             or       a,a                  ; $bc98 b7              ; 
             call     z,dec_hl             ; $bc99 cc f0 cd        ; 
             dec      a                    ; $bc9c 3d              ; 
             call     p,callbdea           ; $bc9d f4 ea bd        ; 
jumpbca0:    push     hl                   ; $bca0 e5              ; 
             call     str_init_number_buffer ; $bca1 cd e2 bb        ; 
             pop      hl                   ; $bca4 e1              ; 
             jr       z,skipbca9           ; $bca5 28 02           ; 
             ld       (hl),b               ; $bca7 70              ; 
             inc      hl                   ; $bca8 23              ; 
skipbca9:    ld       (hl),$00             ; $bca9 36 00           ; 
             ld       hl,$041d             ; $bcab 21 1d 04        ; 
loopbcae:    inc      hl                   ; $bcae 23              ; 
loopbcaf:    ld       a,($031c)            ; $bcaf 3a 1c 03        ; 
             sub      a,l                  ; $bcb2 95              ; 
             sub      a,d                  ; $bcb3 92              ; 
             ret      z                    ; $bcb4 c8              ; 

             ld       a,(hl)               ; $bcb5 7e              ; 
             cp       a,$20                ; $bcb6 fe 20           ; 
             jr       z,loopbcae           ; $bcb8 28 f4           ; 
             cp       a,$2a                ; $bcba fe 2a           ; 
             jr       z,loopbcae           ; $bcbc 28 f0           ; 
             dec      hl                   ; $bcbe 2b              ; 
             push     hl                   ; $bcbf e5              ; 
             push     af                   ; $bcc0 f5              ; 
             ld       bc,$bcc0             ; $bcc1 01 c0 bc        ; 
             push     bc                   ; $bcc4 c5              ; 
             rst      rst0010              ; $bcc5 d7              ; 
             cp       a,$2d                ; $bcc6 fe 2d           ; 
             ret      z                    ; $bcc8 c8              ; 

             cp       a,$2b                ; $bcc9 fe 2b           ; 
             ret      z                    ; $bccb c8              ; 

             cp       a,$24                ; $bccc fe 24           ; 
             ret      z                    ; $bcce c8              ; 

             pop      bc                   ; $bccf c1              ; 
             cp       a,$30                ; $bcd0 fe 30           ; 
             jr       nz,skipbce3          ; $bcd2 20 0f           ; 
             inc      hl                   ; $bcd4 23              ; 
             rst      rst0010              ; $bcd5 d7              ; 
             jr       nc,skipbce3          ; $bcd6 30 0b           ; 
             dec      hl                   ; $bcd8 2b              ; 
             jr       skipbcdd             ; $bcd9 18 02           ; 

loopbcdb:    dec      hl                   ; $bcdb 2b              ; 
             ld       (hl),a               ; $bcdc 77              ; 
skipbcdd:    pop      af                   ; $bcdd f1              ; 
             jr       z,loopbcdb           ; $bcde 28 fb           ; 
             pop      bc                   ; $bce0 c1              ; 
             jr       loopbcaf             ; $bce1 18 cc           ; 

skipbce3:    pop      af                   ; $bce3 f1              ; 
             jr       z,skipbce3           ; $bce4 28 fd           ; 
             pop      hl                   ; $bce6 e1              ; 
             ld       (hl),$25             ; $bce7 36 25           ; 
             ret                           ; $bce9 c9              ; 

skipbcea:    push     hl                   ; $bcea e5              ; 
             rra                           ; $bceb 1f              ; 
             jp       c,jumpbd79           ; $bcec da 79 bd        ; 
             call     callbee1             ; $bcef cd e1 be        ; 
             ld       d,b                  ; $bcf2 50              ; 
             ld       a,($044e)            ; $bcf3 3a 4e 04        ; 
             sub      a,$4f                ; $bcf6 d6 4f           ; 
             jr       c,skipbd05           ; $bcf8 38 0b           ; 
             pop      hl                   ; $bcfa e1              ; 
             pop      bc                   ; $bcfb c1              ; 
             call     str_format_number    ; $bcfc cd ab bb        ; 
             ld       hl,$041d             ; $bcff 21 1d 04        ; 
             ld       (hl),$25             ; $bd02 36 25           ; 
             ret                           ; $bd04 c9              ; 

skipbd05:    call     rst18_io_channel_status ; $bd05 cd c7 c9        ; 
             call     nz,callbf30          ; $bd08 c4 30 bf        ; 
             pop      hl                   ; $bd0b e1              ; 
             pop      bc                   ; $bd0c c1              ; 
             jp       m,jumpbd2a           ; $bd0d fa 2a bd        ; 
             push     bc                   ; $bd10 c5              ; 
             ld       e,a                  ; $bd11 5f              ; 
             ld       a,b                  ; $bd12 78              ; 
             sub      a,d                  ; $bd13 92              ; 
             sub      a,e                  ; $bd14 93              ; 
             call     p,callbdea           ; $bd15 f4 ea bd        ; 
             call     callbdfe             ; $bd18 cd fe bd        ; 
             call     callbe37             ; $bd1b cd 37 be        ; 
             or       a,e                  ; $bd1e b3              ; 
             call     nz,callbdf8          ; $bd1f c4 f8 bd        ; 
             or       a,e                  ; $bd22 b3              ; 
             call     nz,callbe24          ; $bd23 c4 24 be        ; 
             pop      de                   ; $bd26 d1              ; 
             jp       jumpbc97             ; $bd27 c3 97 bc        ; 

jumpbd2a:    ld       e,a                  ; $bd2a 5f              ; 
             ld       a,c                  ; $bd2b 79              ; 
             or       a,a                  ; $bd2c b7              ; 
             call     nz,dec_a             ; $bd2d c4 ee cd        ; 
             add      a,e                  ; $bd30 83              ; 
             jp       m,jumpbd35           ; $bd31 fa 35 bd        ; 
             xor      a,a                  ; $bd34 af              ; 
jumpbd35:    push     bc                   ; $bd35 c5              ; 
             push     af                   ; $bd36 f5              ; 
             call     m,callbf0a           ; $bd37 fc 0a bf        ; 
             pop      bc                   ; $bd3a c1              ; 
             ld       a,e                  ; $bd3b 7b              ; 
             sub      a,b                  ; $bd3c 90              ; 
             pop      bc                   ; $bd3d c1              ; 
             ld       e,a                  ; $bd3e 5f              ; 
             add      a,d                  ; $bd3f 82              ; 
             ld       a,b                  ; $bd40 78              ; 
             jp       m,jumpbd4f           ; $bd41 fa 4f bd        ; 
             sub      a,d                  ; $bd44 92              ; 
             sub      a,e                  ; $bd45 93              ; 
             call     p,callbdea           ; $bd46 f4 ea bd        ; 
             push     bc                   ; $bd49 c5              ; 
             call     callbdfe             ; $bd4a cd fe bd        ; 
             jr       skipbd60             ; $bd4d 18 11           ; 

jumpbd4f:    call     callbdea             ; $bd4f cd ea bd        ; 
             ld       a,c                  ; $bd52 79              ; 
             call     callbe27             ; $bd53 cd 27 be        ; 
             ld       c,a                  ; $bd56 4f              ; 
             xor      a,a                  ; $bd57 af              ; 
             sub      a,d                  ; $bd58 92              ; 
             sub      a,e                  ; $bd59 93              ; 
             call     callbdea             ; $bd5a cd ea bd        ; 
             push     bc                   ; $bd5d c5              ; 
             ld       b,a                  ; $bd5e 47              ; 
             ld       c,a                  ; $bd5f 4f              ; 
skipbd60:    call     callbe37             ; $bd60 cd 37 be        ; 
             pop      bc                   ; $bd63 c1              ; 
             or       a,c                  ; $bd64 b1              ; 
             jr       nz,skipbd6a          ; $bd65 20 03           ; 
             ld       hl,($031c)           ; $bd67 2a 1c 03        ; 
skipbd6a:    add      a,e                  ; $bd6a 83              ; 
             dec      a                    ; $bd6b 3d              ; 
             call     p,callbdea           ; $bd6c f4 ea bd        ; 
             ld       d,b                  ; $bd6f 50              ; 
             jp       jumpbca0             ; $bd70 c3 a0 bc        ; 

jumpbd73:    push     hl                   ; $bd73 e5              ; 
             push     de                   ; $bd74 d5              ; 
             call     fp_load_int_accumulator ; $bd75 cd 1e cb        ; 
             pop      de                   ; $bd78 d1              ; 
jumpbd79:    call     callbee1             ; $bd79 cd e1 be        ; 
             ld       e,b                  ; $bd7c 58              ; 
             call     rst18_io_channel_status ; $bd7d cd c7 c9        ; 
             push     af                   ; $bd80 f5              ; 
             call     nz,callbf30          ; $bd81 c4 30 bf        ; 
             pop      af                   ; $bd84 f1              ; 
             pop      hl                   ; $bd85 e1              ; 
             pop      bc                   ; $bd86 c1              ; 
             push     af                   ; $bd87 f5              ; 
             ld       a,c                  ; $bd88 79              ; 
             or       a,a                  ; $bd89 b7              ; 
             push     af                   ; $bd8a f5              ; 
             call     nz,dec_a             ; $bd8b c4 ee cd        ; 
             add      a,b                  ; $bd8e 80              ; 
             ld       c,a                  ; $bd8f 4f              ; 
             ld       a,d                  ; $bd90 7a              ; 
             and      a,$04                ; $bd91 e6 04           ; 
             cp       a,$01                ; $bd93 fe 01           ; 
             sbc      a,a                  ; $bd95 9f              ; 
             ld       d,a                  ; $bd96 57              ; 
             add      a,c                  ; $bd97 81              ; 
             ld       c,a                  ; $bd98 4f              ; 
             sub      a,e                  ; $bd99 93              ; 
             push     af                   ; $bd9a f5              ; 
             jp       p,skipbdac           ; $bd9b f2 ac bd        ; 
             call     callbf0a             ; $bd9e cd 0a bf        ; 
             jr       nz,skipbdac          ; $bda1 20 09           ; 
             push     hl                   ; $bda3 e5              ; 
             call     fp_shift_main_right  ; $bda4 cd 6b b3        ; 
             ld       hl,$044e             ; $bda7 21 4e 04        ; 
             inc      (hl)                 ; $bdaa 34              ; 
             pop      hl                   ; $bdab e1              ; 
skipbdac:    pop      af                   ; $bdac f1              ; 
             push     bc                   ; $bdad c5              ; 
             push     af                   ; $bdae f5              ; 
             jp       m,jumpbdb3           ; $bdaf fa b3 bd        ; 
             xor      a,a                  ; $bdb2 af              ; 
jumpbdb3:    cpl                           ; $bdb3 2f              ; 
             inc      a                    ; $bdb4 3c              ; 
             add      a,b                  ; $bdb5 80              ; 
             inc      a                    ; $bdb6 3c              ; 
             add      a,d                  ; $bdb7 82              ; 
             ld       b,a                  ; $bdb8 47              ; 
             ld       c,$00                ; $bdb9 0e 00           ; 
             call     z,callbe12           ; $bdbb cc 12 be        ; 
             call     callbe37             ; $bdbe cd 37 be        ; 
             pop      af                   ; $bdc1 f1              ; 
             call     p,callbdf2           ; $bdc2 f4 f2 bd        ; 
             call     callbe24             ; $bdc5 cd 24 be        ; 
             pop      bc                   ; $bdc8 c1              ; 
             pop      af                   ; $bdc9 f1              ; 
             jr       nz,skipbdd8          ; $bdca 20 0c           ; 
             call     dec_hl               ; $bdcc cd f0 cd        ; 
             ld       a,(hl)               ; $bdcf 7e              ; 
             cp       a,$2e                ; $bdd0 fe 2e           ; 
             call     nz,callca40          ; $bdd2 c4 40 ca        ; 
             ld       ($031c),hl           ; $bdd5 22 1c 03        ; 
skipbdd8:    pop      af                   ; $bdd8 f1              ; 
             ld       a,($044e)            ; $bdd9 3a 4e 04        ; 
             jr       z,skipbde1           ; $bddc 28 03           ; 
             add      a,e                  ; $bdde 83              ; 
             sub      a,b                  ; $bddf 90              ; 
             sub      a,d                  ; $bde0 92              ; 
skipbde1:    push     bc                   ; $bde1 c5              ; 
             call     str_append_exponent  ; $bde2 cd 5b bc        ; 
             ex       de,hl                ; $bde5 eb              ; 
             pop      de                   ; $bde6 d1              ; 
             jp       jumpbca0             ; $bde7 c3 a0 bc        ; 

callbdea:    or       a,a                  ; $bdea b7              ; 
loopbdeb:    ret      z                    ; $bdeb c8              ; 

             dec      a                    ; $bdec 3d              ; 
             ld       (hl),$30             ; $bded 36 30           ; 
             inc      hl                   ; $bdef 23              ; 
             jr       loopbdeb             ; $bdf0 18 f9           ; 

callbdf2:    jr       nz,callbdf8          ; $bdf2 20 04           ; 
loopbdf4:    ret      z                    ; $bdf4 c8              ; 

             call     callbe24             ; $bdf5 cd 24 be        ; 
callbdf8:    ld       (hl),$30             ; $bdf8 36 30           ; 
             inc      hl                   ; $bdfa 23              ; 
             dec      a                    ; $bdfb 3d              ; 
             jr       loopbdf4             ; $bdfc 18 f6           ; 

callbdfe:    ld       a,e                  ; $bdfe 7b              ; 
             add      a,d                  ; $bdff 82              ; 
             inc      a                    ; $be00 3c              ; 
             ld       b,a                  ; $be01 47              ; 
             inc      a                    ; $be02 3c              ; 
loopbe03:    sub      a,$03                ; $be03 d6 03           ; 
             jr       nc,loopbe03          ; $be05 30 fc           ; 
             add      a,$05                ; $be07 c6 05           ; 
             ld       c,a                  ; $be09 4f              ; 
callbe0a:    ld       a,($0206)            ; $be0a 3a 06 02        ; 
             and      a,$40                ; $be0d e6 40           ; 
             ret      nz                   ; $be0f c0              ; 

             ld       c,a                  ; $be10 4f              ; 
             ret                           ; $be11 c9              ; 

callbe12:    dec      b                    ; $be12 05              ; 
             jp       p,jumpbe25           ; $be13 f2 25 be        ; 
             ld       ($031c),hl           ; $be16 22 1c 03        ; 
             ld       (hl),$2e             ; $be19 36 2e           ; 
loopbe1b:    inc      hl                   ; $be1b 23              ; 
             ld       (hl),$30             ; $be1c 36 30           ; 
             inc      b                    ; $be1e 04              ; 
             ld       c,b                  ; $be1f 48              ; 
             jr       nz,loopbe1b          ; $be20 20 f9           ; 
             inc      hl                   ; $be22 23              ; 
             ret                           ; $be23 c9              ; 

callbe24:    dec      b                    ; $be24 05              ; 
jumpbe25:    jr       nz,skipbe2f          ; $be25 20 08           ; 
callbe27:    ld       (hl),$2e             ; $be27 36 2e           ; 
             ld       ($031c),hl           ; $be29 22 1c 03        ; 
             inc      hl                   ; $be2c 23              ; 
             ld       c,b                  ; $be2d 48              ; 
             ret                           ; $be2e c9              ; 

skipbe2f:    dec      c                    ; $be2f 0d              ; 
             ret      nz                   ; $be30 c0              ; 

             ld       (hl),$2c             ; $be31 36 2c           ; 
             inc      hl                   ; $be33 23              ; 
             ld       c,$03                ; $be34 0e 03           ; 
             ret                           ; $be36 c9              ; 

callbe37:    push     de                   ; $be37 d5              ; 
             push     hl                   ; $be38 e5              ; 
             push     bc                   ; $be39 c5              ; 
             call     callbee1             ; $be3a cd e1 be        ; 
             ld       a,b                  ; $be3d 78              ; 
             pop      bc                   ; $be3e c1              ; 
             pop      hl                   ; $be3f e1              ; 
             ld       de,$044f             ; $be40 11 4f 04        ; 
             scf                           ; $be43 37              ; 
loopbe44:    push     af                   ; $be44 f5              ; 
             call     callbe24             ; $be45 cd 24 be        ; 
             ld       a,(de)               ; $be48 1a              ; 
             jr       nc,skipbe51          ; $be49 30 06           ; 
             rra                           ; $be4b 1f              ; 
             rra                           ; $be4c 1f              ; 
             rra                           ; $be4d 1f              ; 
             rra                           ; $be4e 1f              ; 
             jr       skipbe52             ; $be4f 18 01           ; 

skipbe51:    inc      de                   ; $be51 13              ; 
skipbe52:    and      a,$0f                ; $be52 e6 0f           ; 
             add      a,$30                ; $be54 c6 30           ; 
             ld       (hl),a               ; $be56 77              ; 
             inc      hl                   ; $be57 23              ; 
             pop      af                   ; $be58 f1              ; 
             dec      a                    ; $be59 3d              ; 
             ccf                           ; $be5a 3f              ; 
             jr       nz,loopbe44          ; $be5b 20 e7           ; 
             jr       skipbe8e             ; $be5d 18 2f           ; 

callbe5f:    push     de                   ; $be5f d5              ; 
             ld       de,$be94             ; $be60 11 94 be        ; 
             ld       a,$05                ; $be63 3e 05           ; 
loopbe65:    call     callbe24             ; $be65 cd 24 be        ; 
             push     bc                   ; $be68 c5              ; 
             push     af                   ; $be69 f5              ; 
             push     hl                   ; $be6a e5              ; 
             ex       de,hl                ; $be6b eb              ; 
             ld       c,(hl)               ; $be6c 4e              ; 
             inc      hl                   ; $be6d 23              ; 
             ld       b,(hl)               ; $be6e 46              ; 
             push     bc                   ; $be6f c5              ; 
             inc      hl                   ; $be70 23              ; 
             ex       (sp),hl              ; $be71 e3              ; 
             ex       de,hl                ; $be72 eb              ; 
             ld       hl,($0450)           ; $be73 2a 50 04        ; 
             ld       b,$2f                ; $be76 06 2f           ; 
loopbe78:    inc      b                    ; $be78 04              ; 
             ld       a,l                  ; $be79 7d              ; 
             sub      a,e                  ; $be7a 93              ; 
             ld       l,a                  ; $be7b 6f              ; 
             ld       a,h                  ; $be7c 7c              ; 
             sbc      a,d                  ; $be7d 9a              ; 
             ld       h,a                  ; $be7e 67              ; 
             jr       nc,loopbe78          ; $be7f 30 f7           ; 
             add      hl,de                ; $be81 19              ; 
             ld       ($0450),hl           ; $be82 22 50 04        ; 
             pop      de                   ; $be85 d1              ; 
             pop      hl                   ; $be86 e1              ; 
             ld       (hl),b               ; $be87 70              ; 
             inc      hl                   ; $be88 23              ; 
             pop      af                   ; $be89 f1              ; 
             pop      bc                   ; $be8a c1              ; 
             dec      a                    ; $be8b 3d              ; 
             jr       nz,loopbe65          ; $be8c 20 d7           ; 
skipbe8e:    call     callbe24             ; $be8e cd 24 be        ; 
             ld       (hl),a               ; $be91 77              ; 
             pop      de                   ; $be92 d1              ; 
             ret                           ; $be93 c9              ; 

             defb     $10,$27,$e8,$03,$64,$00,$0a,$00,$01,$00      ; .'..d..... ; 
callbe9e:    push     bc                   ; $be9e c5              ; 
             jr       loopbeb6             ; $be9f 18 15           ; 

callbea1:    ld       b,$01                ; $bea1 06 01           ; 
             push     bc                   ; $bea3 c5              ; 
             call     coerce_accumulator_to_addr_word ; $bea4 cd d6 ff        ; 
             pop      bc                   ; $bea7 c1              ; 
             ld       de,$041d             ; $bea8 11 1d 04        ; 
             push     de                   ; $beab d5              ; 
             xor      a,a                  ; $beac af              ; 
             ld       (de),a               ; $bead 12              ; 
             dec      b                    ; $beae 05              ; 
             inc      b                    ; $beaf 04              ; 
             ld       c,$06                ; $beb0 0e 06           ; 
             jr       z,skipbebc           ; $beb2 28 08           ; 
             ld       c,$04                ; $beb4 0e 04           ; 
loopbeb6:    add      hl,hl                ; $beb6 29              ; 
             adc      a,a                  ; $beb7 8f              ; 
loopbeb8:    add      hl,hl                ; $beb8 29              ; 
             adc      a,a                  ; $beb9 8f              ; 
             add      hl,hl                ; $beba 29              ; 
             adc      a,a                  ; $bebb 8f              ; 
skipbebc:    add      hl,hl                ; $bebc 29              ; 
             adc      a,a                  ; $bebd 8f              ; 
             jr       nz,skipbec9          ; $bebe 20 09           ; 
             ld       a,c                  ; $bec0 79              ; 
             dec      a                    ; $bec1 3d              ; 
             jr       z,skipbec9           ; $bec2 28 05           ; 
             ld       a,(de)               ; $bec4 1a              ; 
             or       a,a                  ; $bec5 b7              ; 
             jr       z,skipbed4           ; $bec6 28 0c           ; 
             xor      a,a                  ; $bec8 af              ; 
skipbec9:    add      a,$30                ; $bec9 c6 30           ; 
             cp       a,$3a                ; $becb fe 3a           ; 
             jr       c,skipbed1           ; $becd 38 02           ; 
             add      a,$07                ; $becf c6 07           ; 
skipbed1:    ld       (de),a               ; $bed1 12              ; 
             inc      de                   ; $bed2 13              ; 
             ld       (de),a               ; $bed3 12              ; 
skipbed4:    xor      a,a                  ; $bed4 af              ; 
             dec      c                    ; $bed5 0d              ; 
             jr       z,skipbede           ; $bed6 28 06           ; 
             dec      b                    ; $bed8 05              ; 
             inc      b                    ; $bed9 04              ; 
             jr       z,loopbeb8           ; $beda 28 dc           ; 
             jr       loopbeb6             ; $bedc 18 d8           ; 

skipbede:    ld       (de),a               ; $bede 12              ; 
             pop      hl                   ; $bedf e1              ; 
             ret                           ; $bee0 c9              ; 

callbee1:    rst      rst0030              ; $bee1 f7              ; 
             ld       hl,$0455             ; $bee2 21 55 04        ; 
             ld       b,$0e                ; $bee5 06 0e           ; 
             ret      nc                   ; $bee7 d0              ; 

             ld       hl,$0451             ; $bee8 21 51 04        ; 
             ld       b,$06                ; $beeb 06 06           ; 
             ret                           ; $beed c9              ; 

;
; ----
; str_prepare_number_format — coerce numeric value for string rendering
; ----
; Saves the caller's mode byte in $0206, converts the current value to
; double precision if needed, and initialises the output buffer at $041e
; before the decimal formatter runs.
;
str_prepare_number_format: ld       ($0206),a            ; $beee 32 06 02        ; 
             push     af                   ; $bef1 f5              ; 
             push     bc                   ; $bef2 c5              ; 
             push     de                   ; $bef3 d5              ; 
             call     fn_cdbl              ; $bef4 cd 90 cb        ; 
             ld       hl,$b8c3             ; $bef7 21 c3 b8        ; 
             ld       a,($044e)            ; $befa 3a 4e 04        ; 
             and      a,a                  ; $befd a7              ; 
             call     z,callb80a           ; $befe cc 0a b8        ; 
             pop      de                   ; $bf01 d1              ; 
             pop      bc                   ; $bf02 c1              ; 
             pop      af                   ; $bf03 f1              ; 
             ld       hl,$041e             ; $bf04 21 1e 04        ; 
             ld       (hl),$20             ; $bf07 36 20           ; 
             ret                           ; $bf09 c9              ; 

callbf0a:    push     hl                   ; $bf0a e5              ; 
             push     de                   ; $bf0b d5              ; 
             push     bc                   ; $bf0c c5              ; 
             push     af                   ; $bf0d f5              ; 
             cpl                           ; $bf0e 2f              ; 
             inc      a                    ; $bf0f 3c              ; 
             ld       e,a                  ; $bf10 5f              ; 
             ld       a,$01                ; $bf11 3e 01           ; 
             jr       z,skipbf2a           ; $bf13 28 15           ; 
             call     callbee1             ; $bf15 cd e1 be        ; 
             push     hl                   ; $bf18 e5              ; 
loopbf19:    call     fp_shift_main_right  ; $bf19 cd 6b b3        ; 
             dec      e                    ; $bf1c 1d              ; 
             jr       nz,loopbf19          ; $bf1d 20 fa           ; 
             pop      hl                   ; $bf1f e1              ; 
             inc      hl                   ; $bf20 23              ; 
             ld       a,b                  ; $bf21 78              ; 
             rrca                          ; $bf22 0f              ; 
             ld       b,a                  ; $bf23 47              ; 
             call     jumpb2b6             ; $bf24 cd b6 b2        ; 
             call     callbf42             ; $bf27 cd 42 bf        ; 
skipbf2a:    pop      bc                   ; $bf2a c1              ; 
             add      a,b                  ; $bf2b 80              ; 
             pop      bc                   ; $bf2c c1              ; 
             pop      de                   ; $bf2d d1              ; 
             pop      hl                   ; $bf2e e1              ; 
             ret                           ; $bf2f c9              ; 

callbf30:    push     bc                   ; $bf30 c5              ; 
             push     hl                   ; $bf31 e5              ; 
             call     callbee1             ; $bf32 cd e1 be        ; 
             ld       a,($044e)            ; $bf35 3a 4e 04        ; 
             sub      a,$40                ; $bf38 d6 40           ; 
             sub      a,b                  ; $bf3a 90              ; 
             ld       ($044e),a            ; $bf3b 32 4e 04        ; 
             pop      hl                   ; $bf3e e1              ; 
             pop      bc                   ; $bf3f c1              ; 
             or       a,a                  ; $bf40 b7              ; 
             ret                           ; $bf41 c9              ; 

callbf42:    push     bc                   ; $bf42 c5              ; 
             call     callbee1             ; $bf43 cd e1 be        ; 
loopbf46:    ld       a,(hl)               ; $bf46 7e              ; 
             and      a,$0f                ; $bf47 e6 0f           ; 
             jr       nz,skipbf53          ; $bf49 20 08           ; 
             dec      b                    ; $bf4b 05              ; 
             ld       a,(hl)               ; $bf4c 7e              ; 
             or       a,a                  ; $bf4d b7              ; 
             jr       nz,skipbf53          ; $bf4e 20 03           ; 
             dec      hl                   ; $bf50 2b              ; 
             djnz     loopbf46             ; $bf51 10 f3           ; 
skipbf53:    ld       a,b                  ; $bf53 78              ; 
             pop      bc                   ; $bf54 c1              ; 
             ret                           ; $bf55 c9              ; 

;
; inst_fset — FSET statement (File / memory partition setup)
; FSET addr[,size]
; Redefines the boundary between the user program area and the file
; storage area in RAM.
; 1. eval_expr_to_addr → HL (new partition address); error if Z (no arg).
; Store to $026E (file-set base address).
; 2. callbfe9: validate / compute new layout boundaries.
; 3. Check: HL + 13 > $0212 (top of variable space)? → boundary error.
; 4. Check: $0322 > $026E + $98 (at least 152 bytes)? → boundary error.
; 5. Check: $0210 − 4 > $026E? → if so, LDDR block from $0210-4 down
; to compact variable space.
; 6. Reset SP to $01D4, rebuild call frame, update $0210, $0212 pointers.
; 7. Call callc39d (redraw display); store new base in $026E; jump to
; ctrl_reset_runtime_state (clear variable area).
; 
; FSET statement.  Redefine program/file RAM partition.
; Validates new address against variable space and minimum file
; area.  Moves data if necessary (LDDR), resets pointers ($0210,
; $0212), redraws display, clears variable area.
;
inst_fset:   jp       z,basic_raise_error_02 ; $bf56 ca aa f1        ; 
             call     eval_expr_to_addr    ; $bf59 cd cc ff        ; 
             dec      hl                   ; $bf5c 2b              ; 
             rst      rst0010              ; $bf5d d7              ; 
             jp       nz,basic_raise_error_02 ; $bf5e c2 aa f1        ; 
             ld       ($026e),hl           ; $bf61 22 6e 02        ; 
             call     basic_measure_program_span ; $bf64 cd e9 bf        ; 
             ld       bc,$000d             ; $bf67 01 0d 00        ; 
             add      hl,bc                ; $bf6a 09              ; 
             ex       de,hl                ; $bf6b eb              ; 
             rst      rst0020              ; $bf6c e7              ; 
             jr       c,skipbf7a           ; $bf6d 38 0b           ; 
             ex       de,hl                ; $bf6f eb              ; 
             ld       hl,($0212)           ; $bf70 2a 12 02        ; 
             ld       bc,$0009             ; $bf73 01 09 00        ; 
             add      hl,bc                ; $bf76 09              ; 
             call     calld305             ; $bf77 cd 05 d3        ; 
skipbf7a:    jp       c,basic_raise_error_07 ; $bf7a da a5 d1        ; 
             ld       hl,($0322)           ; $bf7d 2a 22 03        ; 
             ld       bc,$0098             ; $bf80 01 98 00        ; 
             add      hl,bc                ; $bf83 09              ; 
             rst      rst0020              ; $bf84 e7              ; 
             jp       nc,basic_raise_error_07 ; $bf85 d2 a5 d1        ; 
             ld       hl,($0210)           ; $bf88 2a 10 02        ; 
             dec      hl                   ; $bf8b 2b              ; 
             dec      hl                   ; $bf8c 2b              ; 
             dec      hl                   ; $bf8d 2b              ; 
             dec      hl                   ; $bf8e 2b              ; 
             rst      rst0020              ; $bf8f e7              ; 
             pop      bc                   ; $bf90 c1              ; 
             ld       sp,$01d4             ; $bf91 31 d4 01        ; 
             push     bc                   ; $bf94 c5              ; 
             push     af                   ; $bf95 f5              ; 
             push     hl                   ; $bf96 e5              ; 
             call     basic_measure_program_span ; $bf97 cd e9 bf        ; 
             ld       bc,gpr_line_span     ; $bf9a 01 04 00        ; 
             add      hl,bc                ; $bf9d 09              ; 
             ld       b,h                  ; $bf9e 44              ; 
             ld       c,l                  ; $bf9f 4d              ; 
             pop      hl                   ; $bfa0 e1              ; 
             pop      af                   ; $bfa1 f1              ; 
             jr       nc,skipbfbc          ; $bfa2 30 18           ; 
             call     basic_update_area_bounds_from_partition ; $bfa4 cd c4 bf        ; 
             add      hl,bc                ; $bfa7 09              ; 
             push     hl                   ; $bfa8 e5              ; 
             ex       de,hl                ; $bfa9 eb              ; 
             add      hl,bc                ; $bfaa 09              ; 
             ex       de,hl                ; $bfab eb              ; 
             pop      hl                   ; $bfac e1              ; 
             inc      bc                   ; $bfad 03              ; 
             lddr                          ; $bfae ed b8           ; 
loopbfb0:    call     io_reset_channel_slots ; $bfb0 cd 78 e8        ; 
             call     hw_audio_reset       ; $bfb3 cd 9d c3        ; 
             ld       hl,($026e)           ; $bfb6 2a 6e 02        ; 
             jp       ctrl_reset_runtime_state ; $bfb9 c3 31 d2        ; 

skipbfbc:    call     basic_update_area_bounds_from_partition ; $bfbc cd c4 bf        ; 
             inc      bc                   ; $bfbf 03              ; 
             ldir                          ; $bfc0 ed b0           ; 
             jr       loopbfb0             ; $bfc2 18 ec           ; 

;
; basic_update_area_bounds_from_partition — store derived BASIC/file-space bounds
; Shared by FSET after it has decided whether the surrounding RAM block must
; move up or down.  Recomputes the dependent workspace pointers at $01dd/$01df,
; stores the new BASIC/file-area base in $0210, and writes the backlink word
; just past the current $0212 trailer so the partition metadata stays coherent.
;
basic_update_area_bounds_from_partition: push     de                   ; $bfc4 d5              ; 
             push     hl                   ; $bfc5 e5              ; 
             dec      de                   ; $bfc6 1b              ; 
             dec      de                   ; $bfc7 1b              ; 
             ld       ($01df),de           ; $bfc8 ed 53 df 01     ; 
             ld       hl,$ffce             ; $bfcc 21 ce ff        ; 
             add      hl,de                ; $bfcf 19              ; 
             ld       ($01dd),hl           ; $bfd0 22 dd 01        ; 
             ld       hl,$0006             ; $bfd3 21 06 00        ; 
             add      hl,de                ; $bfd6 19              ; 
             ld       ($0210),hl           ; $bfd7 22 10 02        ; 
             push     hl                   ; $bfda e5              ; 
             ld       hl,($0212)           ; $bfdb 2a 12 02        ; 
             ld       de,gpr_char_step     ; $bfde 11 05 00        ; 
             add      hl,de                ; $bfe1 19              ; 
             pop      de                   ; $bfe2 d1              ; 
             ld       (hl),e               ; $bfe3 73              ; 
             inc      hl                   ; $bfe4 23              ; 
             ld       (hl),d               ; $bfe5 72              ; 
             pop      hl                   ; $bfe6 e1              ; 
             pop      de                   ; $bfe7 d1              ; 
             ret                           ; $bfe8 c9              ; 

;
; basic_measure_program_span — measure occupied BASIC/file span from current base
; Walks the linked records starting at the current BASIC/file-area base pointer
; ($0210) until the terminating zero header, then returns the occupied span
; relative to that old base.  FSET uses the result to project where the same
; program/file payload would end after moving the partition.
;
basic_measure_program_span: push     de                   ; $bfe9 d5              ; 
             ld       hl,($0210)           ; $bfea 2a 10 02        ; 
             push     hl                   ; $bfed e5              ; 
loopbfee:    ld       a,(hl)               ; $bfee 7e              ; 
             or       a,a                  ; $bfef b7              ; 
             jr       z,skipbff7           ; $bff0 28 05           ; 
             rst      rst0038              ; $bff2 ff              ; 
             rlca                          ; $bff3 07              ; 
             add      hl,de                ; $bff4 19              ; 
             jr       loopbfee             ; $bff5 18 f7           ; 

skipbff7:    pop      de                   ; $bff7 d1              ; 
             and      a,a                  ; $bff8 a7              ; 
             sbc      hl,de                ; $bff9 ed 52           ; 
             pop      de                   ; $bffb d1              ; 
             ret                           ; $bffc c9              ; 

             defb     $56,$32,$ff                                  ; V2.        ; 
;
; ctrlc_io_service — Ctrl-C abort check with I/O servicing
; ----
; Saves AF and enters the service loop (loopc001).
; Calls io_flag_handler; if bit 2 of the result is set
; (hardware event pending), clears that bit, calls
; io_device_reset (callc0bd) to re-sync hardware state,
; then loops on key_scan (jump00a2) until a key arrives or
; the hardware flags clear; then repeats from the top.
; Once bit 2 is clear, calls output_queue_dispatch (callc06c)
; and abort_flag_handler (callc02d).  If no abort: pops AF
; and returns.  If a stop/break is signalled: jumps to
; stop_save_cont ($D2C1).
; 
; Poll hardware events, service output queues, check Ctrl-C.
; Jumps to stop_save_cont if STOP key or abort detected.
;
ctrlc_io_service: push     af                   ; $c000 f5              ; 
loopc001:    call     io_flag_handler      ; $c001 cd a6 c5        ; 
             bit      $02,a                ; $c004 cb 57           ; 
             jr       z,skipc01d           ; $c006 28 15           ; 
             res      $02,a                ; $c008 cb 97           ; 
             ld       ($002b),a            ; $c00a 32 2b 00        ; 
             call     io_device_reset      ; $c00d cd bd c0        ; 
loopc010:    call     jump00a2             ; $c010 cd a2 00        ; 
             jr       nz,skipc01d          ; $c013 20 08           ; 
             ld       a,($002b)            ; $c015 3a 2b 00        ; 
             or       a,a                  ; $c018 b7              ; 
             jr       z,loopc010           ; $c019 28 f5           ; 
             jr       loopc001             ; $c01b 18 e4           ; 

skipc01d:    call     output_queue_dispatch ; $c01d cd 6c c0        ; 
             call     z,abort_flag_handler ; $c020 cc 2d c0        ; 
             ei                            ; $c023 fb              ; 
             jr       z,loopc02b           ; $c024 28 05           ; 
             pop      af                   ; $c026 f1              ; 
             ei                            ; $c027 fb              ; 
             jp       stop_save_cont       ; $c028 c3 c1 d2        ; 

loopc02b:    pop      af                   ; $c02b f1              ; 
             ret                           ; $c02c c9              ; 

;
; abort_flag_handler — test and handle the abort bit
; ----
; Tests bit 0 of the hardware-status byte A (previously
; loaded by io_flag_handler).  If clear, returns immediately.
; Otherwise clears bits 0 and 1 (AND $FA), stores the result
; back to $002B, calls io_device_reset (callc0bd) to
; flush device state, then returns.
; Called from ctrlc_io_service and from io_event_service.
; 
; If bit 0 of A set: clear abort bits in $002B, call
; io_device_reset, then return.
;
abort_flag_handler: bit      $00,a                ; $c02d cb 47           ; 
             jr       z,skipc03b           ; $c02f 28 0a           ; 
             push     af                   ; $c031 f5              ; 
             and      a,$fa                ; $c032 e6 fa           ; 
             ld       ($002b),a            ; $c034 32 2b 00        ; 
             call     io_device_reset      ; $c037 cd bd c0        ; 
             pop      af                   ; $c03a f1              ; 
skipc03b:    ret                           ; $c03b c9              ; 

callc03c:    call     calle8d4             ; $c03c cd d4 e8        ; 
;
; io_event_service — I/O event service with display/key dispatch
; ----
; Saves AF, calls io_flag_handler and output_queue_dispatch
; (callc06c), then abort_flag_handler (callc02d) if Z.
; Enables interrupts.  If no abort, pops AF and returns.
; If an event is pending: calls the RAM hook at $00A8,
; calls calle89b (display close), loads BC = $C05B (return
; trampoline), loads HL from ($0313) (saved program counter),
; and jumps to jumpd26a (BASIC error-restart / statement
; re-entry).
; The entry point at $C03C additionally calls calle8d4
; (open display channel) before falling through.
; 
; Service I/O events: output queues, abort flag, display
; hooks.  On active event: restart BASIC at ($0313).
;
io_event_service: push     af                   ; $c03f f5              ; 
             call     io_flag_handler      ; $c040 cd a6 c5        ; 
             call     output_queue_dispatch ; $c043 cd 6c c0        ; 
             call     z,abort_flag_handler ; $c046 cc 2d c0        ; 
             ei                            ; $c049 fb              ; 
             jr       z,loopc02b           ; $c04a 28 df           ; 
             call     call00a8             ; $c04c cd a8 00        ; 
             call     calle89b             ; $c04f cd 9b e8        ; 
             ld       bc,$c05b             ; $c052 01 5b c0        ; 
             ld       hl,($0313)           ; $c055 2a 13 03        ; 
             jp       jumpd26a             ; $c058 c3 6a d2        ; 

             defb     $e1,$cd,$f4,$c0,$2a,$db,$01,$e5,$cd,$20      ; ....*..... ; 
             defb     $e9,$21,$b7,$c0,$c3,$31,$f2                  ; .!...1.    ; 
;
; output_queue_dispatch — service pending output queues
; ----
; Disables interrupts and reads the hardware-capability
; flags from $002B.  If bit 3 is set (printer pending):
; clears that bit, saves AF, points HL = $C0A6 (printer
; output string), and falls to skipc087.  If bit 1 is set
; (display pending): clears that bit, saves AF, points
; HL = $C0AA (display output string).
; At skipc087: stores the updated $002B, enables interrupts,
; calls jumpe89e (output channel open), calle929 (channel
; write), and callfef7 (print string at HL), then restores AF.
; Returns Z if no pending bits were set.
; 
; Check $002B bits 1/3; if set, flush the pending
; display or printer output string, then return.
;
output_queue_dispatch: di                            ; $c06c f3              ; 
             push     hl                   ; $c06d e5              ; 
             ld       a,($002b)            ; $c06e 3a 2b 00        ; 
             bit      $03,a                ; $c071 cb 5f           ; 
             jr       nz,skipc081          ; $c073 20 0c           ; 
             bit      $01,a                ; $c075 cb 4f           ; 
             jr       z,skipc095           ; $c077 28 1c           ; 
             push     af                   ; $c079 f5              ; 
             res      $01,a                ; $c07a cb 8f           ; 
             ld       hl,$c0aa             ; $c07c 21 aa c0        ; 
             jr       skipc087             ; $c07f 18 06           ; 

skipc081:    push     af                   ; $c081 f5              ; 
             res      $03,a                ; $c082 cb 9f           ; 
             ld       hl,$c0a6             ; $c084 21 a6 c0        ; 
skipc087:    ld       ($002b),a            ; $c087 32 2b 00        ; 
             ei                            ; $c08a fb              ; 
             call     io_close_channel     ; $c08b cd 9e e8        ; 
             call     print_emit_crlf      ; $c08e cd 29 e9        ; 
             call     print_c_string       ; $c091 cd f7 fe        ; 
             pop      af                   ; $c094 f1              ; 
skipc095:    pop      hl                   ; $c095 e1              ; 
             ret                           ; $c096 c9              ; 

;
; hw_flags_mask — AND-clear bits in hardware status $002B
; ----
; Disables interrupts, reads $002B into A, ANDs with B
; (caller supplies the mask), writes the result back to
; $002B, enables interrupts, and returns.
; Used by disp_reset to clear bit 6 (AND $BF), and by
; kbd_read_char to clear specific hardware-pending bits.
; 
; A = ($002B) AND B → ($002B); preserve/clear flag bits.
;
hw_flags_mask: di                            ; $c097 f3              ; 
             ld       a,($002b)            ; $c098 3a 2b 00        ; 
             and      a,b                  ; $c09b a0              ; 
             ld       ($002b),a            ; $c09c 32 2b 00        ; 
             ei                            ; $c09f fb              ; 
             ret                           ; $c0a0 c9              ; 

;
; error_translate — RST $20 syscall slot 7 (RAM $006C)
; ----
; Translates an internal error code by adding $A5 to A,
; then calls calle428 to signal the error to the LCD
; co-processor.  This maps compact internal codes to the
; wider LCD error-command namespace.
; 
; Add $A5 to error code in A, then signal via calle428.
;
error_translate: add      a,$a5                ; $c0a1 c6 a5           ; 
             jp       lcd_cmd_simple       ; $c0a3 c3 28 e4        ; 

             defm     "Card Low battery",0                                      ;
             defm     "Abort",0                                                 ;
;
; io_device_reset — hardware I/O device re-sync and key-matrix init
; ----
; Saves BC, DE, HL.  Sends LCD command $19 then $20 via
; calle428 (halt/flush device).  Probes the device at
; $C00E via calle348 (serial-bus read), masks bit 2 of
; the result (clears error bit), and calls calle334 to
; apply the result.  Then sends commands $AD and $BB via
; calle428 (re-initialise device protocol).  Disables
; interrupts, zeros 31 entries (B=$1F) of the key-matrix
; state table starting at RAM $0283 (6 bytes per entry)
; via key_entry_init (callc29a).  Enables interrupts and
; returns.
; Called at startup, from ctrlc_io_service, and from the
; joystick-read loop to reset I/O device state.
; 
; Flush LCD device, clear error, re-init key-matrix RAM
; at $0283 (31 entries × 6 bytes).
;
io_device_reset: push     bc                   ; $c0bd c5              ; 
             push     de                   ; $c0be d5              ; 
             push     hl                   ; $c0bf e5              ; 
             ld       a,$19                ; $c0c0 3e 19           ; 
             call     lcd_cmd_simple       ; $c0c2 cd 28 e4        ; 
             ld       a,$20                ; $c0c5 3e 20           ; 
             call     lcd_cmd_simple       ; $c0c7 cd 28 e4        ; 
             ld       hl,$c00e             ; $c0ca 21 0e c0        ; 
             call     lcd_cfg_read         ; $c0cd cd 48 e3        ; 
             and      a,$fb                ; $c0d0 e6 fb           ; 
             call     lcd_cfg_write        ; $c0d2 cd 34 e3        ; 
             ld       a,$ad                ; $c0d5 3e ad           ; 
             call     lcd_cmd_simple       ; $c0d7 cd 28 e4        ; 
             ld       a,$bb                ; $c0da 3e bb           ; 
             call     lcd_cmd_simple       ; $c0dc cd 28 e4        ; 
             di                            ; $c0df f3              ; 
             ld       de,$0283             ; $c0e0 11 83 02        ; 
             ld       b,$1f                ; $c0e3 06 1f           ; 
             xor      a,a                  ; $c0e5 af              ; 
             call     key_entry_init       ; $c0e6 cd 9a c2        ; 
             ei                            ; $c0e9 fb              ; 
             pop      hl                   ; $c0ea e1              ; 
             pop      de                   ; $c0eb d1              ; 
             pop      bc                   ; $c0ec c1              ; 
             ret                           ; $c0ed c9              ; 

;
; print_pos_clear — clear printer position registers
; ----
; Sets $0311 (print-head address) to $0000, then falls
; through to print_cursor_reset at $C0F4.
; Called when the print position needs to be fully reset.
; 
; Zero $0311 (print-head), then fall through to
; print_cursor_reset.
;
print_pos_clear: ld       hl,$0000             ; $c0ee 21 00 00        ; 
             ld       ($0311),hl           ; $c0f1 22 11 03        ; 
;
; print_cursor_reset — reset print cursor state
; ----
; Saves HL.  Clears the print-line counter at $031B (A = 0),
; then zeros HL and stores it to both $0319 (column position)
; and $0320 (row position).  Restores HL and returns.
; Establishes a clean cursor state for the output subsystem.
; 
; Zero $031B (line counter), $0319 (col), $0320 (row).
;
print_cursor_reset: push     hl                   ; $c0f4 e5              ; 
             xor      a,a                  ; $c0f5 af              ; 
             ld       ($031b),a            ; $c0f6 32 1b 03        ; 
             ld       l,a                  ; $c0f9 6f              ; 
             ld       h,a                  ; $c0fa 67              ; 
             ld       ($0319),hl           ; $c0fb 22 19 03        ; 
             ld       ($0320),hl           ; $c0fe 22 20 03        ; 
             pop      hl                   ; $c101 e1              ; 
             ret                           ; $c102 c9              ; 

;
; fn_inkey — INKEY$ function handler (expression token $C2)
; Non-blocking keyboard poll.  RST $10 advances past the INKEY$
; token.  Calls key_scan (jump00a2 / syscall $00A2) to read the
; current key without waiting.
; If a key is pressed (NZ after key_scan): calls calld55e to
; allocate a 1-byte string buffer, then calld82e to store the
; key character into it.
; If no key (Z): sets HL to the empty-string literal at $F168.
; In both cases, stores the result descriptor in the string
; scratch register $0450 and sets $01D9 = 3 (string type).
; Returns: string in $0450 — 1-char string if key pressed, "" otherwise.
;
fn_inkey:    rst      rst0010              ; $c103 d7              ; 
             push     hl                   ; $c104 e5              ; 
             call     jump00a2             ; $c105 cd a2 00        ; 
             jr       z,skipc113           ; $c108 28 09           ; 
             push     af                   ; $c10a f5              ; 
             call     str_make_char        ; $c10b cd 5e d5        ; 
             pop      af                   ; $c10e f1              ; 
             ld       e,a                  ; $c10f 5f              ; 
             call     str_return_single_char ; $c110 cd 2e d8        ; 
skipc113:    ld       hl,$f168             ; $c113 21 68 f1        ; 
             ld       ($0450),hl           ; $c116 22 50 04        ; 
             ld       a,$03                ; $c119 3e 03           ; 
             ld       ($01d9),a            ; $c11b 32 d9 01        ; 
             pop      hl                   ; $c11e e1              ; 
             ret                           ; $c11f c9              ; 

;
; disp_scroll_up — RST $20 syscall slot 13 (RAM $007E)
; ----
; Scroll the display up.  Computes a source row address via
; disp_row_addr (call0075), then copies B rows of ($00BA)
; bytes each upward using LDIR, finally clearing the bottom
; row with disp_fill_spaces.
; 
; Scroll display content up B rows; clear bottom row.
;
disp_scroll_up: ld       l,h                  ; $c120 6c              ; 
             call     call0075             ; $c121 cd 75 00        ; 
             ld       hl,($00ba)           ; $c124 2a ba 00        ; 
             ld       h,$00                ; $c127 26 00           ; 
             add      hl,de                ; $c129 19              ; 
loopc12a:    ld       a,($00ba)            ; $c12a 3a ba 00        ; 
             push     bc                   ; $c12d c5              ; 
             ld       b,$00                ; $c12e 06 00           ; 
             ld       c,a                  ; $c130 4f              ; 
             ldir                          ; $c131 ed b0           ; 
             pop      bc                   ; $c133 c1              ; 
             djnz     loopc12a             ; $c134 10 f4           ; 
             jr       disp_fill_spaces     ; $c136 18 1c           ; 

;
; disp_scroll_down — RST $20 syscall slot 12 (RAM $007B)
; ----
; Scroll the display down / insert a blank row.  Computes
; the target row address via disp_row_addr (call0075), then
; shifts screen-buffer rows downward, filling the freed row
; with spaces via disp_fill_spaces.
; 
; Scroll display content down one row; clear vacated row.
;
disp_scroll_down: ld       l,h                  ; $c138 6c              ; 
             inc      l                    ; $c139 2c              ; 
             call     call0075             ; $c13a cd 75 00        ; 
             ld       a,($00ba)            ; $c13d 3a ba 00        ; 
             defb     $ed,$44,$6f,$26,$ff,$19,$3a,$ba,$00,$4f      ; .Do&..:..O ; 
             defb     $1b,$2b,$7e,$12,$0d,$20,$f9,$10,$f3,$eb      ; .+~....... ; 
;
; disp_fill_spaces — RST $20 syscall slot 11 (RAM $0078)
; ----
; Fill a region of the screen buffer with spaces.  Reads
; the column width from $00BA into B, then stores $20 (space)
; into B consecutive bytes starting at DE.
; 
; Fill ($00BA) bytes starting at DE with ASCII space ($20).
;
disp_fill_spaces: ld       a,($00ba)            ; $c154 3a ba 00        ; 
             ld       b,a                  ; $c157 47              ; 
             ld       a,$20                ; $c158 3e 20           ; 
loopc15a:    ld       (de),a               ; $c15a 12              ; 
             inc      de                   ; $c15b 13              ; 
             djnz     loopc15a             ; $c15c 10 fc           ; 
             ret                           ; $c15e c9              ; 

loopc15f:    ld       hl,($00b8)           ; $c15f 2a b8 00        ; 
             ld       h,e                  ; $c162 63              ; 
             inc      h                    ; $c163 24              ; 
;
; Store the 1-based text cursor pair from HL into $00b8 and
; immediately resynchronise the LCD cursor through
; text_cursor_sync_from_state.
;
text_cursor_store_and_sync: ld       ($00b8),hl           ; $c164 22 b8 00        ; 
             push     af                   ; $c167 f5              ; 
             call     text_cursor_sync_from_state ; $c168 cd 42 eb        ; 
             pop      af                   ; $c16b f1              ; 
;
; disp_noop_1 — RST $20 syscall slot 1 (RAM $005A)
; ----
; Empty stub — immediately returns.  Reserved slot; no
; functionality installed in the base ROM.
; 
; Syscall slot 1: unimplemented — RET.
;
disp_noop_1: ret                           ; $c16c c9              ; 

;
; disp_ctrl_char — RST $20 syscall slot 26 (RAM $00A5)
; ----
; Dispatch a control character to the appropriate handler.
; A = $01: load 16-bit cursor info from $00B9, decrement
; the column, and return.
; A = $0F: seek cursor to next line (via loopc15f).
; A = $0E: call callec1c (display mode / attribute change).
; Other values: return immediately.
; 
; Handle control char A: $01=cursor query, $0F=seek, $0E=mode change.
;
disp_ctrl_char: cp       a,$01                ; $c16d fe 01           ; 
             jr       z,skipc17b           ; $c16f 28 0a           ; 
             cp       a,$0f                ; $c171 fe 0f           ; 
             jr       z,loopc15f           ; $c173 28 ea           ; 
             cp       a,$0e                ; $c175 fe 0e           ; 
             call     z,text_cursor_mark_row ; $c177 cc 1c ec        ; 
             ret                           ; $c17a c9              ; 

skipc17b:    ld       bc,($00b9)           ; $c17b ed 4b b9 00     ; 
             dec      c                    ; $c17f 0d              ; 
             ret                           ; $c180 c9              ; 

;
; disp_read_char — RST $20 syscall slot 3 (RAM $0060)
; ----
; Read the character stored at the current cursor position
; in the screen buffer.  Calls callebe5 (row×col → buffer
; address), reads the byte at that address into A, then
; restores HL and DE.
; 
; Read character at current cursor position; returns byte in A.
;
disp_read_char: push     hl                   ; $c181 e5              ; 
             push     de                   ; $c182 d5              ; 
             call     callebe5             ; $c183 cd e5 eb        ; 
             ld       a,(hl)               ; $c186 7e              ; 
             pop      de                   ; $c187 d1              ; 
             pop      hl                   ; $c188 e1              ; 
             ret                           ; $c189 c9              ; 

;
; lcd_char_write — low-level LCD hardware character write
; ----
; Write a single character byte (A) directly to the LCD
; display hardware.  Sets the busy flag at $0033 to $80,
; disables interrupts, masks bit 7 of ($026C) and calls
; jumpde97 (hardware handshake), then waits for the LCD
; controller to be ready via lcd_wait_ready.  Writes A to
; port $F1 (LCD data), then $02 to port $F5 (LCD strobe),
; and waits again for ready.  Clears the busy flag; if the
; error flag at $0023 is set, sends command $BC to the LCD
; co-processor and clears the error.
; Called by disp_send_row (once per character) and by
; disp_put_char for the bell ($07) control code.
; 
; Write char A to LCD hardware via port $F1/$F5 with
; interrupt protection and error recovery.
;
lcd_char_write: push     af                   ; $c18a f5              ; 
             ld       a,$80                ; $c18b 3e 80           ; 
             ld       ($0033),a            ; $c18d 32 33 00        ; 
             di                            ; $c190 f3              ; 
             ld       a,($026c)            ; $c191 3a 6c 02        ; 
             and      a,$7f                ; $c194 e6 7f           ; 
             call     io_ctrl_commit       ; $c196 cd 97 de        ; 
             call     lcd_wait_ready       ; $c199 cd c0 c9        ; 
             pop      af                   ; $c19c f1              ; 
             push     af                   ; $c19d f5              ; 
             out      ($f1),a              ; $c19e d3 f1           ; 
             ld       a,$02                ; $c1a0 3e 02           ; 
             out      ($f5),a              ; $c1a2 d3 f5           ; 
             call     lcd_wait_ready       ; $c1a4 cd c0 c9        ; 
             xor      a,a                  ; $c1a7 af              ; 
             ld       ($0033),a            ; $c1a8 32 33 00        ; 
             ld       a,($0023)            ; $c1ab 3a 23 00        ; 
             or       a,a                  ; $c1ae b7              ; 
             jr       z,skipc1bc           ; $c1af 28 0b           ; 
             push     bc                   ; $c1b1 c5              ; 
             ld       a,$bc                ; $c1b2 3e bc           ; 
             call     lcd_cmd_simple       ; $c1b4 cd 28 e4        ; 
             xor      a,a                  ; $c1b7 af              ; 
             ld       ($0023),a            ; $c1b8 32 23 00        ; 
             pop      bc                   ; $c1bb c1              ; 
skipc1bc:    pop      af                   ; $c1bc f1              ; 
             ret                           ; $c1bd c9              ; 

;
; disp_put_char — RST $20 syscall slot 24 (RAM $009F)
; ----
; Full character-output routine with control-code handling.
; Printable characters (A ≥ $20): computed via callebe5 to
; the screen buffer position from $00B8 (cursor), stored
; via callc209, display updated via callead9.
; Control codes dispatched by value:
; $07        — bell
; $09–$0D    — tab / LF / VT / FF / CR
; $1C–$1F    — cursor-movement sequences
; $01        — query cursor position
; $0F        — seek / advance line
; $0E        — callec1c (mode change)
; All registers saved and restored around the operation.
; 
; Output char A to LCD display with control-code processing.
;
disp_put_char: push     bc                   ; $c1be c5              ; 
             push     de                   ; $c1bf d5              ; 
             push     hl                   ; $c1c0 e5              ; 
             push     af                   ; $c1c1 f5              ; 
             cp       a,$20                ; $c1c2 fe 20           ; 
             jr       c,skipc1d7           ; $c1c4 38 11           ; 
             ld       hl,($00b8)           ; $c1c6 2a b8 00        ; 
             call     callebe5             ; $c1c9 cd e5 eb        ; 
             call     disp_buf_char        ; $c1cc cd 09 c2        ; 
             call     text_cursor_advance_after_write ; $c1cf cd d9 ea        ; 
loopc1d2:    pop      af                   ; $c1d2 f1              ; 
             pop      hl                   ; $c1d3 e1              ; 
             pop      de                   ; $c1d4 d1              ; 
             pop      bc                   ; $c1d5 c1              ; 
             ret                           ; $c1d6 c9              ; 

skipc1d7:    cp       a,$1c                ; $c1d7 fe 1c           ; 
             jr       nc,skipc1e9          ; $c1d9 30 0e           ; 
             cp       a,$07                ; $c1db fe 07           ; 
             jr       z,skipc1f5           ; $c1dd 28 16           ; 
             cp       a,$09                ; $c1df fe 09           ; 
             jr       c,loopc1d2           ; $c1e1 38 ef           ; 
             cp       a,$0e                ; $c1e3 fe 0e           ; 
             jr       nc,loopc1d2          ; $c1e5 30 eb           ; 
             add      a,$0e                ; $c1e7 c6 0e           ; 
skipc1e9:    ld       hl,$ea7a             ; $c1e9 21 7a ea        ; 
             ld       c,a                  ; $c1ec 4f              ; 
             call     callee13             ; $c1ed cd 13 ee        ; 
             call     text_cursor_sync_from_state ; $c1f0 cd 42 eb        ; 
             jr       loopc1d2             ; $c1f3 18 dd           ; 

skipc1f5:    call     lcd_char_write       ; $c1f5 cd 8a c1        ; 
             jr       loopc1d2             ; $c1f8 18 d8           ; 

;
; disp_set_col — RST $20 syscall slot 2 (RAM $005D)
; ----
; Set the LCD cursor column.  On entry, L holds the
; 1-based column number.  Decrements to make it 0-based,
; stores in the $026E parameter byte, then submits
; LCD command $09 with 1 data byte.
; 
; Set LCD cursor column (L = 1-based column number).
;
disp_set_col: ld       e,l                  ; $c1fa 5d              ; 
             ld       hl,$026e             ; $c1fb 21 6e 02        ; 
             dec      e                    ; $c1fe 1d              ; 
             ld       (hl),e               ; $c1ff 73              ; 
             ld       b,$01                ; $c200 06 01           ; 
             ld       c,$00                ; $c202 0e 00           ; 
             ld       a,$09                ; $c204 3e 09           ; 
             jp       lcd_submit           ; $c206 c3 2f c9        ; 

;
; disp_buf_char — write character to screen buffer and advance cursor
; ----
; Stores A at (HL) (the pre-computed screen-buffer address),
; then reads the current cursor position from $00B8 into HL,
; copies A to C, and falls through to disp_set_cursor to
; commit the updated column and row to the LCD co-processor
; via command $24.
; Called from disp_put_char for printable characters
; after callebe5 has resolved the buffer address.
; 
; Store char A at (HL); advance cursor via disp_set_cursor.
;
disp_buf_char: ld       (hl),a               ; $c209 77              ; 
             ld       hl,($00b8)           ; $c20a 2a b8 00        ; 
             ld       c,a                  ; $c20d 4f              ; 
             jr       disp_set_cursor      ; $c20e 18 21           ; 

;
; disp_write_char — RST $20 syscall slot 8 (RAM $006F)
; ----
; Write character A to the screen buffer at the current
; cursor position and advance the cursor.  Computes the
; buffer address via callebe5, stores the character, then
; falls through to disp_set_cursor to commit the new
; cursor position via LCD command $24.
; 
; Write char A to screen buffer at cursor; advance cursor.
;
disp_write_char: push     hl                   ; $c210 e5              ; 
             ld       c,a                  ; $c211 4f              ; 
             call     callebe5             ; $c212 cd e5 eb        ; 
             ld       (hl),c               ; $c215 71              ; 
             pop      hl                   ; $c216 e1              ; 
             jr       disp_set_cursor      ; $c217 18 18           ; 

;
; disp_send_row — RST $20 syscall slot 4 (RAM $0063)
; ----
; Send a row of 19 characters to the LCD display.
; On entry: HL → character buffer, E = 1-based row number.
; Calls disp_set_cursor to position to column 0 of row E,
; then loops 19 times sending each byte via callc18a
; (the low-level LCD character-output routine).
; 
; Output 19-char row E to LCD; HL → character source buffer.
;
disp_send_row: push     hl                   ; $c219 e5              ; 
             xor      a,a                  ; $c21a af              ; 
             ld       h,a                  ; $c21b 67              ; 
             inc      h                    ; $c21c 24              ; 
             ld       c,a                  ; $c21d 4f              ; 
             ld       l,e                  ; $c21e 6b              ; 
             call     disp_set_cursor      ; $c21f cd 31 c2        ; 
             ld       b,$13                ; $c222 06 13           ; 
             pop      hl                   ; $c224 e1              ; 
loopc225:    ld       a,(hl)               ; $c225 7e              ; 
             call     lcd_char_write       ; $c226 cd 8a c1        ; 
             inc      hl                   ; $c229 23              ; 
             djnz     loopc225             ; $c22a 10 f9           ; 
             ld       c,(hl)               ; $c22c 4e              ; 
             ld       h,$14                ; $c22d 26 14           ; 
             inc      e                    ; $c22f 1c              ; 
             ld       l,e                  ; $c230 6b              ; 
;
; disp_set_cursor — RST $20 syscall slot 9 (RAM $0072)
; ----
; Set the LCD cursor to an absolute (col, row) position.
; Stores the adjusted column (D−1) and row (E−1) into the
; $026E/$026F parameter bytes, stores the attribute byte C
; at $0270, then submits LCD command $24 with 3 data bytes.
; 
; Set LCD cursor to (D−1, E−1) with attribute C; submit command $24.
;
disp_set_cursor: push     hl                   ; $c231 e5              ; 
             ex       de,hl                ; $c232 eb              ; 
             ld       hl,$026e             ; $c233 21 6e 02        ; 
             dec      d                    ; $c236 15              ; 
             ld       (hl),d               ; $c237 72              ; 
             inc      hl                   ; $c238 23              ; 
             dec      e                    ; $c239 1d              ; 
             ld       (hl),e               ; $c23a 73              ; 
             inc      hl                   ; $c23b 23              ; 
             ld       (hl),c               ; $c23c 71              ; 
             ld       hl,$026e             ; $c23d 21 6e 02        ; 
             ld       b,$03                ; $c240 06 03           ; 
             ld       c,$00                ; $c242 0e 00           ; 
             ld       a,$24                ; $c244 3e 24           ; 
             call     lcd_submit           ; $c246 cd 2f c9        ; 
             pop      hl                   ; $c249 e1              ; 
             ret                           ; $c24a c9              ; 

;
; error_beep8 — RST $20 syscall slot 14 (RAM $0081)
; ----
; Loads A = $08 and jumps to calle428, which ORs in $80
; and sends the resulting command byte to the LCD
; co-processor.  Used to signal error code 8.
; 
; Signal LCD error code $08 (A = $08 → calle428).
;
error_beep8: ld       a,$08                ; $c24b 3e 08           ; 
             jp       lcd_cmd_simple       ; $c24d c3 28 e4        ; 

;
; disp_row_addr — RST $20 syscall slot 10 (RAM $0075)
; ----
; Convert a 1-based row number (L) to a screen-buffer address
; stored in DE.  Computes: DE = $0214 + (L − 1) × 20.
; Uses: HL*4 + HL*16 = HL*20 (via ADD HL,HL chains and DE save).
; Returns the row-start address in DE; HL is preserved.
; 
; Row number L (1-based) → DE = screen buffer row start address.
;
disp_row_addr: push     hl                   ; $c250 e5              ; 
             ld       h,$00                ; $c251 26 00           ; 
             dec      l                    ; $c253 2d              ; 
             add      hl,hl                ; $c254 29              ; 
             add      hl,hl                ; $c255 29              ; 
             ld       e,l                  ; $c256 5d              ; 
             ld       d,h                  ; $c257 54              ; 
             add      hl,hl                ; $c258 29              ; 
             add      hl,hl                ; $c259 29              ; 
             add      hl,de                ; $c25a 19              ; 
             ld       de,$0214             ; $c25b 11 14 02        ; 
             add      hl,de                ; $c25e 19              ; 
             ex       de,hl                ; $c25f eb              ; 
             pop      hl                   ; $c260 e1              ; 
             ret                           ; $c261 c9              ; 

callc262:    call     key_state_read       ; $c262 cd b9 c2        ; 
             ld       a,b                  ; $c265 78              ; 
             inc      a                    ; $c266 3c              ; 
             inc      hl                   ; $c267 23              ; 
             and      a,(hl)               ; $c268 a6              ; 
             cp       a,c                  ; $c269 b9              ; 
             ret      z                    ; $c26a c8              ; 

             push     hl                   ; $c26b e5              ; 
             dec      hl                   ; $c26c 2b              ; 
             dec      hl                   ; $c26d 2b              ; 
             dec      hl                   ; $c26e 2b              ; 
             ex       (sp),hl              ; $c26f e3              ; 
             inc      hl                   ; $c270 23              ; 
             ld       c,a                  ; $c271 4f              ; 
             ld       a,(hl)               ; $c272 7e              ; 
             inc      hl                   ; $c273 23              ; 
             ld       h,(hl)               ; $c274 66              ; 
             ld       l,a                  ; $c275 6f              ; 
             ld       b,$00                ; $c276 06 00           ; 
             add      hl,bc                ; $c278 09              ; 
             ld       (hl),e               ; $c279 73              ; 
             pop      hl                   ; $c27a e1              ; 
             ld       (hl),c               ; $c27b 71              ; 
             ret                           ; $c27c c9              ; 

;
; key_translate — translate raw key scancode to ASCII
; Reads the current keyboard matrix state via callc2b9 (which
; loads two consecutive scan-state bytes into B and C from the
; entry at [RAM $0006] + scancode×6).
; If the current state equals the previous (B == C), returns Z
; (no key change).  Otherwise uses the state bytes to index
; into the per-key ASCII translation table; returns A = ASCII
; character, NZ if a valid character is available; A = 0,
; Z clear otherwise.
; Returns: A = ASCII char (NZ), or A = 0 if no mappable key.
;
key_translate: call     key_state_read       ; $c27d cd b9 c2        ; 
             ld       a,c                  ; $c280 79              ; 
             cp       a,b                  ; $c281 b8              ; 
             ret      z                    ; $c282 c8              ; 

             push     hl                   ; $c283 e5              ; 
             inc      hl                   ; $c284 23              ; 
             inc      a                    ; $c285 3c              ; 
             and      a,(hl)               ; $c286 a6              ; 
             inc      hl                   ; $c287 23              ; 
             ld       c,a                  ; $c288 4f              ; 
             ld       a,(hl)               ; $c289 7e              ; 
             inc      hl                   ; $c28a 23              ; 
             ld       h,(hl)               ; $c28b 66              ; 
             ld       l,a                  ; $c28c 6f              ; 
             ld       b,$00                ; $c28d 06 00           ; 
             add      hl,bc                ; $c28f 09              ; 
             ld       a,(hl)               ; $c290 7e              ; 
             pop      hl                   ; $c291 e1              ; 
             dec      hl                   ; $c292 2b              ; 
             ld       (hl),c               ; $c293 71              ; 
             or       a,a                  ; $c294 b7              ; 
             ret      nz                   ; $c295 c0              ; 

             inc      a                    ; $c296 3c              ; 
             ld       a,$00                ; $c297 3e 00           ; 
             ret                           ; $c299 c9              ; 

;
; key_entry_init — initialize a key-matrix entry
; ----
; Calls key_matrix_ptr (callc2c1) to point HL at the
; 6-byte entry for scancode A in the key-matrix table.
; Pops BC (caller's saved value), stores B at (HL) and
; (HL+1) (both state bytes to B — marks entry as unchanged),
; advances HL by 3, pops AF (the scan byte), then stores
; A at (HL), E at (HL+1), and D at (HL+2) before returning.
; Used by io_device_reset to blank all 31 key-matrix entries.
; 
; Initialize key-matrix entry at ($0006 + A×6):
; clear state bytes, write scan values A/E/D.
;
key_entry_init: push     bc                   ; $c29a c5              ; 
             call     key_matrix_ptr       ; $c29b cd c1 c2        ; 
             ld       (hl),b               ; $c29e 70              ; 
             inc      hl                   ; $c29f 23              ; 
             ld       (hl),b               ; $c2a0 70              ; 
             inc      hl                   ; $c2a1 23              ; 
             inc      hl                   ; $c2a2 23              ; 
             pop      af                   ; $c2a3 f1              ; 
             ld       (hl),a               ; $c2a4 77              ; 
             inc      hl                   ; $c2a5 23              ; 
             ld       (hl),e               ; $c2a6 73              ; 
             inc      hl                   ; $c2a7 23              ; 
             ld       (hl),d               ; $c2a8 72              ; 
             ret                           ; $c2a9 c9              ; 

;
; key_matrix_scan — raw keyboard matrix change detection
; Reads two scan-state bytes (previous / current) via callc2b9
; from the key matrix table at [RAM $0006] + A×6.  Isolates
; newly pressed keys by computing the change between previous
; and current state bytes.  Returns HL = {H=0, L=scancode}
; where L is the raw scancode of the newly pressed key, or
; HL = 0 if no new key event.  A = L on return.
; Called by key_scan (and callc8c5 indirectly via key_scan).
;
key_matrix_scan: call     key_state_read       ; $c2aa cd b9 c2        ; 
             ld       a,b                  ; $c2ad 78              ; 
             inc      a                    ; $c2ae 3c              ; 
             inc      hl                   ; $c2af 23              ; 
             and      a,(hl)               ; $c2b0 a6              ; 
             ld       b,a                  ; $c2b1 47              ; 
             ld       a,c                  ; $c2b2 79              ; 
             sub      a,b                  ; $c2b3 90              ; 
             and      a,(hl)               ; $c2b4 a6              ; 
             ld       l,a                  ; $c2b5 6f              ; 
             ld       h,$00                ; $c2b6 26 00           ; 
             ret                           ; $c2b8 c9              ; 

;
; key_state_read — read two scan-state bytes for current key
; ----
; Calls key_matrix_ptr (callc2c1) to compute HL from the
; current scancode A and the table base at RAM $0006.
; Loads B = (HL) (previous state byte) and C = (HL+1)
; (current state byte), advances HL by 2, and returns.
; Used by key_translate and key_matrix_scan to fetch the
; pair of consecutive state bytes for a given key entry.
; 
; HL = key matrix entry pointer; B = prev state, C = cur state.
;
key_state_read: call     key_matrix_ptr       ; $c2b9 cd c1 c2        ; 
             ld       b,(hl)               ; $c2bc 46              ; 
             inc      hl                   ; $c2bd 23              ; 
             ld       c,(hl)               ; $c2be 4e              ; 
             inc      hl                   ; $c2bf 23              ; 
             ret                           ; $c2c0 c9              ; 

;
; key_matrix_ptr — compute key-matrix entry address for scancode A
; ----
; Multiplies A by 6 (via two RLCA and ADD A,B giving A×3,
; stored in C; A×6 is in BC with B=$00).  Loads HL from
; RAM $0006 (key-matrix table base pointer).  Adds BC to HL
; and returns HL = table_base + A×6, pointing at the
; 6-byte entry for scancode A.
; 
; HL = ($0006) + A×6  (key-matrix entry pointer).
;
key_matrix_ptr: rlca                          ; $c2c1 07              ; 
             ld       b,a                  ; $c2c2 47              ; 
             rlca                          ; $c2c3 07              ; 
             add      a,b                  ; $c2c4 80              ; 
             ld       c,a                  ; $c2c5 4f              ; 
             ld       b,$00                ; $c2c6 06 00           ; 
             ld       hl,($0006)           ; $c2c8 2a 06 00        ; 
             add      hl,bc                ; $c2cb 09              ; 
             ret                           ; $c2cc c9              ; 

;
; inst_beep — BEEP statement
; BEEP pitch, duration
; callfe51: evaluate first arg → D:E (pitch / note value).
; RST $08 / $2C: require `,`.
; callfe5e: evaluate second arg → A:E (duration count).
; The pitch is decomposed into octave (D bits) and semitone (E mod 12).
; A lookup table at $C36F maps semitone → base timer value.
; DJNZ loop at $C30A shifts D:E right by B positions (octave scaler).
; The derived divisor is converted into a hardware counter, multiplied by
; the duration count, then armed through the interrupt-driven buzzer path.
; 
; BEEP statement.  Evaluate pitch / note (callfe51 → D:E) and duration
; (callfe5e → A).  Decompose the first argument into octave and semitone,
; look up the semitone period in the table at $C36F, shift it by octave,
; convert that into the hardware counter value, then multiply by the
; second argument to get the IRQ countdown length.  A zero pitch takes
; the silent/rest path by marking bit 7 in C before the final hardware
; latch write.
;
inst_beep:   call     eval_expr_to_int16   ; $c2cd cd 51 fe        ; 
             push     de                   ; $c2d0 d5              ; 
             pop      iy                   ; $c2d1 fd e1           ; 
             rst      rst0008              ; $c2d3 cf              ; 
             inc      l                    ; $c2d4 2c              ; 
             call     eval_expr_to_int8    ; $c2d5 cd 5e fe        ; 
             push     af                   ; $c2d8 f5              ; 
             dec      hl                   ; $c2d9 2b              ; 
             rst      rst0010              ; $c2da d7              ; 
             jp       nz,basic_raise_error_02 ; $c2db c2 aa f1        ; 
             ex       (sp),hl              ; $c2de e3              ; 
             push     hl                   ; $c2df e5              ; 
             push     iy                   ; $c2e0 fd e5           ; 
             pop      de                   ; $c2e2 d1              ; 
             ld       c,$00                ; $c2e3 0e 00           ; 
             ld       a,d                  ; $c2e5 7a              ; 
             and      a,$0f                ; $c2e6 e6 0f           ; 
             ld       d,a                  ; $c2e8 57              ; 
             or       a,e                  ; $c2e9 b3              ; 
             jr       z,beep_rest_note_case ; $c2ea 28 26           ; 
             ld       hl,$ffcf             ; $c2ec 21 cf ff        ; 
             add      hl,de                ; $c2ef 19              ; 
             jr       c,beep_period_ready  ; $c2f0 38 22           ; 
             ld       a,e                  ; $c2f2 7b              ; 
             dec      a                    ; $c2f3 3d              ; 
             ld       b,c                  ; $c2f4 41              ; 
;
; Divide the 1-based pitch value by 12.
; B counts octaves while A is reduced to a 0..11 semitone index for the
; lookup table at $c36f.
;
beep_note_div12_loop: inc      b                    ; $c2f5 04              ; 
             sub      a,$0c                ; $c2f6 d6 0c           ; 
             jr       nc,beep_note_div12_loop ; $c2f8 30 fb           ; 
             add      a,$0c                ; $c2fa c6 0c           ; 
             ld       hl,beep_semitone_period_table ; $c2fc 21 6f c3        ; 
             ld       e,a                  ; $c2ff 5f              ; 
             add      hl,de                ; $c300 19              ; 
             ld       e,(hl)               ; $c301 5e              ; 
             inc      d                    ; $c302 14              ; 
             cp       a,$07                ; $c303 fe 07           ; 
             jr       nc,skipc30e          ; $c305 30 07           ; 
             inc      d                    ; $c307 14              ; 
             jr       skipc30e             ; $c308 18 04           ; 

;
; Apply the octave scaler to the semitone base period.
; Shifts D:E right B times so higher octaves produce smaller divisors.
;
beep_octave_shift_loop: srl      d                    ; $c30a cb 3a           ; 
             rr       e                    ; $c30c cb 1b           ; 
skipc30e:    djnz     beep_octave_shift_loop ; $c30e 10 fa           ; 
             jr       beep_period_ready    ; $c310 18 02           ; 

;
; Special case for pitch 0.
; Marks C as $ff so the later port-$f4 setup clears the tone-enable bit,
; producing a silent delay rather than an audible tone.
;
beep_rest_note_case: dec      c                    ; $c312 0d              ; 
             inc      d                    ; $c313 14              ; 
;
; Common join point once the 16-bit pitch divisor is ready in D:E.
;
beep_period_ready: push     de                   ; $c314 d5              ; 
             pop      iy                   ; $c315 fd e1           ; 
             ld       a,c                  ; $c317 79              ; 
             ld       hl,$4b00             ; $c318 21 00 4b        ; 
             ld       b,l                  ; $c31b 45              ; 
             ld       c,l                  ; $c31c 4d              ; 
;
; Convert the scaled pitch divisor into the hardware counter used for
; ports $f2/$f3.
; Repeatedly subtracts D:E from $4b00 while incrementing BC.
;
beep_counter_divide_loop: inc      bc                   ; $c31d 03              ; 
             sbc      hl,de                ; $c31e ed 52           ; 
             jr       nc,beep_counter_divide_loop ; $c320 30 fb           ; 
             dec      bc                   ; $c322 0b              ; 
             ld       d,b                  ; $c323 50              ; 
             ld       e,c                  ; $c324 59              ; 
             ld       c,a                  ; $c325 4f              ; 
             ld       hl,$0000             ; $c326 21 00 00        ; 
             pop      af                   ; $c329 f1              ; 
             ld       b,a                  ; $c32a 47              ; 
             or       a,a                  ; $c32b b7              ; 
             jr       z,skipc36d           ; $c32c 28 3f           ; 
;
; Multiply the counter value by the BEEP duration argument.
; Accumulates the final IRQ countdown in HL before the buzzer path is armed.
;
beep_duration_accumulate_loop: add      hl,de                ; $c32e 19              ; 
             djnz     beep_duration_accumulate_loop ; $c32f 10 fd           ; 
             push     hl                   ; $c331 e5              ; 
             push     bc                   ; $c332 c5              ; 
             in       a,($f4)              ; $c333 db f4           ; 
             or       a,$f3                ; $c335 f6 f3           ; 
             inc      a                    ; $c337 3c              ; 
             call     nz,buzzer_wait       ; $c338 c4 7b c3        ; 
;
; Foreground half of the interrupt-driven buzzer / timer path used by
; BEEP.  Installs the cassette-ready callback hook, then enters the
; wait loop at $c33e until shared port-$f0 bit 5 drops.  Once the
; hardware slot is free, the surrounding code programs the 16-bit tone
; divisor to ports $f2/$f3, updates the port-$f4 latch, stores the
; remaining countdown at $000e, and commits $026c|$20 to port $f0 so
; the interrupt hook at $c7a3 can clock the tone.
;
buzzer_irq_arm: call     cas_install_callback ; $c33b cd a7 de        ; 
;
; Busy-wait helper for buzzer_irq_arm.
; Repeatedly calls io_event_service, then polls port $f0 bit 5 until
; it clears.  This lets the foreground BEEP code wait for the shared
; hardware service loop to release the audio / timer slot before
; programming the next tone.
;
buzzer_wait_f0_bit5_clear: call     io_event_service     ; $c33e cd 3f c0        ; 
             in       a,($f0)              ; $c341 db f0           ; 
             bit      $05,a                ; $c343 cb 6f           ; 
             jr       nz,buzzer_wait_f0_bit5_clear ; $c345 20 f7           ; 
             push     iy                   ; $c347 fd e5           ; 
             pop      de                   ; $c349 d1              ; 
             ld       a,e                  ; $c34a 7b              ; 
             out      ($f2),a              ; $c34b d3 f2           ; 
             ld       a,d                  ; $c34d 7a              ; 
             out      ($f3),a              ; $c34e d3 f3           ; 
             in       a,($f4)              ; $c350 db f4           ; 
             and      a,$61                ; $c352 e6 61           ; 
             or       a,$ce                ; $c354 f6 ce           ; 
             pop      bc                   ; $c356 c1              ; 
             bit      $07,c                ; $c357 cb 79           ; 
             jr       z,beep_program_f4_latch ; $c359 28 02           ; 
             and      a,$fd                ; $c35b e6 fd           ; 
;
; Final port-$f4 write for the newly prepared tone / rest.
; Uses C bit 7 from beep_rest_note_case to optionally clear the tone
; gate before the countdown is armed.
;
beep_program_f4_latch: out      ($f4),a              ; $c35d d3 f4           ; 
             di                            ; $c35f f3              ; 
             ld       a,($026c)            ; $c360 3a 6c 02        ; 
             or       a,$20                ; $c363 f6 20           ; 
             call     callc3a9             ; $c365 cd a9 c3        ; 
             pop      hl                   ; $c368 e1              ; 
;
; Store the computed 16-bit duration counter into RAM $000e.
; hw_irq_tick_service decrements this value until the tone / rest ends.
;
beep_load_countdown: ld       ($000e),hl           ; $c369 22 0e 00        ; 
             ei                            ; $c36c fb              ; 
skipc36d:    pop      hl                   ; $c36d e1              ; 
             ret                           ; $c36e c9              ; 

;
; 12-byte semitone-to-period table used by inst_beep.
; Indexed by the reduced pitch class after beep_note_div12_loop.
;
beep_semitone_period_table: defb     $dc,$b4,$8c,$68,$48,$24,$08,$e8,$d0,$b4      ; ...hH$.... ; 
             defb     $9c,$84                                      ; ..         ; 
;
; buzzer_wait — wait for buzzer hardware ready, then enable
; ----
; Reads port $F4; if bits 2–3 are both clear (no audio
; device active), jumps directly to buzzer_enable.
; Otherwise loops up to $C8 (200) iterations reading port
; $F6, ORing with $FA and incrementing; exits early on
; overflow (audio already done).  On each iteration calls
; calle106 (timing delay via RST $10).  When the loop
; exhausts or exits early, falls through to buzzer_enable.
; Called by inst_beep to synchronise with the buzzer
; before starting a new tone.
; 
; Wait up to 200 iterations for buzzer idle, then
; fall through to buzzer_enable.
;
buzzer_wait: in       a,($f4)              ; $c37b db f4           ; 
             and      a,$0c                ; $c37d e6 0c           ; 
             jr       z,skipc392           ; $c37f 28 11           ; 
             ld       b,$c8                ; $c381 06 c8           ; 
loopc383:    in       a,($f6)              ; $c383 db f6           ; 
             or       a,$fa                ; $c385 f6 fa           ; 
             inc      a                    ; $c387 3c              ; 
             jr       z,skipc392           ; $c388 28 08           ; 
             ld       de,rst0010           ; $c38a 11 10 00        ; 
             call     io_delay_service_loop ; $c38d cd 06 e1        ; 
             djnz     loopc383             ; $c390 10 f1           ; 
skipc392:    call     buzzer_enable        ; $c392 cd ac c3        ; 
             di                            ; $c395 f3              ; 
             ld       a,($026c)            ; $c396 3a 6c 02        ; 
             and      a,$0c                ; $c399 e6 0c           ; 
             jr       callc3a9             ; $c39b 18 0c           ; 

;
; Conservative low-level reset for the shared audio / serial latch.
; Shifts an $ff postamble through the common $f4/$f5 bit-serial helper
; at $cf0f, waits for the buzzer path to go idle, clears port $f4, and
; commits control byte $04 through io_ctrl_commit.  Called during cold
; start and from higher-level code that needs the mixed buzzer /
; cassette / display control state returned to a known baseline.
;
hw_audio_reset: call     term_shift_ff_postamble ; $c39d cd 0f cf        ; 
             call     buzzer_wait          ; $c3a0 cd 7b c3        ; 
             xor      a,a                  ; $c3a3 af              ; 
             out      ($f4),a              ; $c3a4 d3 f4           ; 
             ld       a,$04                ; $c3a6 3e 04           ; 
             di                            ; $c3a8 f3              ; 
callc3a9:    jp       io_ctrl_commit       ; $c3a9 c3 97 de        ; 

;
; buzzer_enable — enable buzzer output on hardware ports
; ----
; Calls callc3ba ($C3BA): reads port $F4, ANDs with $01
; (isolates bit 0 — cable-detect / active-low enable),
; writes back to port $F4.  Then ORs $0C into the result
; and writes to port $F4 (enables audio bits 2–3).
; Writes $10 to port $F6 (enables audio output).
; Calls callde9f (additional hardware enable).
; Paired with callc3a9 / jumpde97 which disable the same
; bits to silence the buzzer after a tone.
; 
; Enable buzzer: set bits 2–3 on port $F4, $10 on port
; $F6, then call callde9f.
;
buzzer_enable: call     hw_f4_preserve_bit0  ; $c3ac cd ba c3        ; 
             or       a,$0c                ; $c3af f6 0c           ; 
             out      ($f4),a              ; $c3b1 d3 f4           ; 
             ld       a,$10                ; $c3b3 3e 10           ; 
             out      ($f6),a              ; $c3b5 d3 f6           ; 
             call     cas_port_clear       ; $c3b7 cd 9f de        ; 
;
; Tiny port-$f4 helper used by buzzer_enable.
; Reads port $f4, keeps only bit 0, writes the masked value back, and
; returns.  This preserves the base hardware-enable bit while clearing
; the audio-control bits before they are re-applied.
;
hw_f4_preserve_bit0: in       a,($f4)              ; $c3ba db f4           ; 
             and      a,$01                ; $c3bc e6 01           ; 
             out      ($f4),a              ; $c3be d3 f4           ; 
             ret                           ; $c3c0 c9              ; 

             defb     $56,$32                                      ; V2         ; 
;
; ============================================================
; ROM cold-start entry point — $C3C3
; ============================================================
; ROM cold-start / power-on reset entry point.
; Reached via the RST $38 RAM vector installed at $0038
; (JP $C799 → ... → JP $C3C3), or directly at power-on.
;
start:       di                            ; $c3c3 f3              ;   DI — disable interrupts during hardware initialisation
             ld       sp,$01d4             ; $c3c4 31 d4 01        ;   Initialise stack pointer to $01D4
             xor      a,a                  ; $c3c7 af              ;   A = 0
             out      ($f1),a              ; $c3c8 d3 f1           ;   OUT ($F1), 0 — reset I/O control port F1
             out      ($f0),a              ; $c3ca d3 f0           ;   OUT ($F0), 0 — reset I/O control port F0
             dec      a                    ; $c3cc 3d              ;   A = $FF (DEC from 0 wraps)
             out      ($bb),a              ; $c3cd d3 bb           ;   OUT ($BB), $FF — reset I/O port BB
;
; Hardware ready loop: wait until I/O port $F2 bit 0 is clear.
;
loopc3cf:    ld       a,$97                ; $c3cf 3e 97           ;   LD A, $97 — write $97 to port $F5 to trigger I/O check
             out      ($f5),a              ; $c3d1 d3 f5           ;   OUT ($F5), $97
             in       a,($f2)              ; $c3d3 db f2           ;   IN A, ($F2) — read status port
             rrca                          ; $c3d5 0f              ;   RRCA — test bit 0 (carry)
             jr       c,loopc3cf           ; $c3d6 38 f7           ;   JR C, loopc3cf — loop while bit 0 set (hardware not ready)
             ld       hl,rst_init_block    ; $c3d8 21 db c6        ;   HL = $C6DB — source: ROM init data block
             ld       de,$0000             ; $c3db 11 00 00        ;   DE = $0000 — destination: start of RAM (RST vector area)
             ld       bc,$00ae             ; $c3de 01 ae 00        ;   BC = $00AE — length: 174 bytes
;
; ----
; copy_init_vectors — install RAM RST and syscall vectors
; ----
; LDIR copies rst_init_block to $0000-$00ad during power-on.
; This seeds the RAM RST trampolines, low-memory hooks, and the
; syscall table used by the rest of the ROM.
;
copy_init_vectors: ldir                          ; $c3e1 ed b0           ; / LDIR — copy ROM init block to RAM ($0000-$00AD).
                                                                   ; | Installs JP vectors for RST $08/$10/$18/$20/$28/$30/$38
                                                                   ; \ and other system hooks into low RAM.
             call     hw_audio_reset       ; $c3e3 cd 9d c3        ;   First hardware init call
             call     scan_rom_page_0      ; $c3e6 cd 35 c6        ;   Second hardware init call
             call     io_device_reset      ; $c3e9 cd bd c0        ;   Third hardware init call
             call     get_ram_base_addr    ; $c3ec cd 57 c5        ; / get_ram_base_addr: set HL to RAM base address ($2000 or $4000 per
                                                                   ; \ port $F2 bit 5)
             call     test_ram_byte        ; $c3ef cd 2e c6        ;   test_ram_byte: test if address HL is writeable RAM (Z = writable)
;
; ============================================================
; Hardware capabilities detection and warm/cold start decision
; ============================================================
; Probes hardware features and decides whether to perform a warm
; restart (resume saved BASIC session) or a full cold start.
;
hardware:    ld       a,$00                ; $c3f2 3e 00           ;   A = 0 — default: no extended hardware flag
             jr       nz,hardware_probe_expansion ; $c3f4 20 08           ;   Skip port $F2 bit-4 check if RAM test at $2000/$4000 failed (NZ)
             in       a,($f2)              ; $c3f6 db f2           ;   Read hardware status port $F2
             and      a,$10                ; $c3f8 e6 10           ;   Test bit 4 of port $F2
             jr       z,hardware_probe_expansion ; $c3fa 28 02           ;   If bit 4 clear, keep A = 0
             ld       a,$08                ; $c3fc 3e 08           ;   A = $08 — bit-3 flag: port $F2 bit-4 hardware present
;
; hardware_probe_expansion — continue the startup capability probe with
; the stacked port-$F2 flag and a $D000 backup / expansion-memory test.
;
hardware_probe_expansion: push     af                   ; $c3fe f5              ;   Save port $F2 bit-4 flag (A = 0 or $08) on stack
             ld       hl,$d000             ; $c3ff 21 00 d0        ;   HL = $D000 — probe expansion memory area
             call     lcd_cfg_read         ; $c402 cd 48 e3        ;   Probe $D000 via serial-bus I/O (callc92f); result byte returned in A
             and      a,$40                ; $c405 e6 40           ;   Test bit 6 of result — set = $D000 expansion RAM present
             pop      bc                   ; $c407 c1              ;   Recover port $F2 bit-4 flag into B
             jr       z,hardware_store_cap_flags ; $c408 28 02           ;   If expansion not detected, keep A = 0
             ld       a,$02                ; $c40a 3e 02           ;   A = $02 — bit-1 flag: $D000 expansion RAM present
;
; hardware_store_cap_flags — merge the startup probe bits and then query
; the backup-memory controller for a resumable saved session.
;
hardware_store_cap_flags: or       a,b                  ; $c40c b0              ;   OR bit-3 and bit-1 flags to form combined capability byte
             ld       ($002b),a            ; $c40d 32 2b 00        ; / Store hardware capability flags at RAM $002B (bit 3 = extended hw,
                                                                   ; \ bit 1 = expansion RAM)
             ld       c,$01                ; $c410 0e 01           ;   C = $01 — I/O device channel
;
; backup_state_query — submit co-processor command $A2 and inspect the
; reply in $026E; bit 6 selects warm restart versus cold start.
;
backup_state_query: ld       a,$a2                ; $c412 3e a2           ;   A = $A2 — command: query backup memory / warm-start state
             ld       de,$026e             ; $c414 11 6e 02        ;   DE = $026E — response buffer address
             call     lcd_submit           ; $c417 cd 2f c9        ;   Send command $A2 to device channel 1; result stored at ($026E)
             ld       a,($026e)            ; $c41a 3a 6e 02        ;   Load response byte from $026E
             bit      $06,a                ; $c41d cb 77           ;   Test bit 6 — set = valid saved session detected (warm start possible)
             jr       z,cold_start         ; $c41f 28 20           ;   Bit 6 clear: jump to cold_start
;
; ----
; warm_restart_probe — validate saved BASIC session
; ----
; Warm-start path after the backup-memory flag check. Scans ROM
; banks, reinitialises display state, finds RAM top, and compares
; the saved fingerprint at $026c before resuming execution.
;
warm_restart_probe: call     scan_rom_banks       ; $c421 cd 3b c6        ;   Warm-start path: scan ROM banks for installed ROM pages
             call     cas_install_callback ; $c424 cd a7 de        ;   Warm-start path: display setup
             call     find_ram_top         ; $c427 cd 20 c6        ;   Warm-start path: detect top of available RAM (HL = top of RAM)
             ld       de,$fffd             ; $c42a 11 fd ff        ;   DE = $FFFD — offset $-3
             add      hl,de                ; $c42d 19              ;   Advance to saved-state fingerprint area ($026C)
             ld       de,$026c             ; $c42e 11 6c 02        ; 
             call     cmp4_pre             ; $c431 cd 79 c5        ;   Compare 4 bytes at (HL−3)…(HL) against saved fingerprint at $026C
             jr       nz,warm_restart_recover ; $c434 20 08           ;   Mismatch — state corrupt; fall through to partial cold start
;
; ----
; warm_restart_restore_sp — reload saved stack pointer
; ----
; Restores SP from $0266 once the saved-session fingerprint has
; been accepted.
;
warm_restart_restore_sp: ld       sp,($0266)           ; $c436 ed 7b 66 02     ;   Warm restart: restore saved SP from ($0266)
;
; ----
; warm_restart_resume — reload saved return address and RET
; ----
; Loads HL from $0264 and returns to the interrupted BASIC path,
; completing the warm restart.
;
warm_restart_resume: ld       hl,($0264)           ; $c43a 2a 64 02        ;   Warm restart: restore saved HL (return address) from ($0264)
             ret                           ; $c43d c9              ;   RET — resume execution at saved return address (warm restart)

;
; ----
; warm_restart_recover — fall back from failed warm restart
; ----
; Reinitialises the display and drops into cold_start when the
; saved-session fingerprint is stale or corrupt.
;
warm_restart_recover: call     mc_error_prompt      ; $c43e cd fa c5        ; 
;
; Cold start: RRCA rotates device-response bits into carry.
;
cold_start:  rrca                          ; $c441 0f              ; 
             push     af                   ; $c442 f5              ;   Save rotated device flags on stack
             ld       hl,$c789             ; $c443 21 89 c7        ;   HL = $C789 — source of 6 extra bytes for RAM $00AE–$00B3
             ld       de,$00ae             ; $c446 11 ae 00        ;   DE = $00AE — destination just past rst_init_block
             ld       bc,$0006             ; $c449 01 06 00        ;   BC = $0006 — 6 bytes
             ldir                          ; $c44c ed b0           ;   Copy 6-byte extension block to RAM $00AE–$00B3
             jr       c,cold_start_init_display ; $c44e 38 28           ;   Carry set (from earlier operation): skip RAM zero-fill
             call     get_ram_base_addr    ; $c450 cd 57 c5        ;   get_ram_base_addr: HL = RAM base ($2000 or $4000)
             ld       de,$0552             ; $c453 11 52 05        ;   DE = $0552 — start of memory region to zero-fill
loopc456:    xor      a,a                  ; $c456 af              ;   Zero-fill RAM from $0552 upward until RST $20 reports region exhausted
             ld       (de),a               ; $c457 12              ; 
             inc      de                   ; $c458 13              ; 
             rst      rst0020              ; $c459 e7              ; 
             jr       nz,loopc456          ; $c45a 20 fa           ; 
             ld       hl,$c78f             ; $c45c 21 8f c7        ;   HL = $C78F — source of 10 bytes for RAM $00B4–$00BD
             ld       de,$00b4             ; $c45f 11 b4 00        ;   DE = $00B4 — destination
             ld       bc,$000a             ; $c462 01 0a 00        ;   BC = $000A — 10 bytes
             ldir                          ; $c465 ed b0           ;   Copy 10-byte I/O parameter block to RAM $00B4–$00BD
             ld       a,$3a                ; $c467 3e 3a           ;   A = $3A (':') — store at RAM $00D2
             ld       ($00d2),a            ; $c469 32 d2 00        ; 
             ld       a,$2c                ; $c46c 3e 2c           ;   A = $2C (',') — store at RAM $00D4
             ld       ($00d4),a            ; $c46e 32 d4 00        ; 
             inc      a                    ; $c471 3c              ;   A = $2D ('-') — parameter for calle334
             ld       hl,$c01a             ; $c472 21 1a c0        ;   HL = $C01A — string or table pointer
             call     lcd_cfg_write        ; $c475 cd 34 e3        ;   Initialise something at $C01A (calle334)
;
; cold_start_init_display — clear the startup text buffer, initialise the
; display, then probe the RAM-top trailer left by OFF/SLEEP.
;
cold_start_init_display: ld       hl,$0214             ; $c478 21 14 02        ;   HL = $0214 — start of screen line buffer
             ld       b,$50                ; $c47b 06 50           ;   B = $50 — 80 bytes (one screen line)
loopc47d:    ld       (hl),$20             ; $c47d 36 20           ;   Fill 80 bytes from $0214 with $20 (spaces): clear line buffer
             inc      hl                   ; $c47f 23              ; 
             djnz     loopc47d             ; $c480 10 fb           ; 
             call     io_reset_channel_slots ; $c482 cd 78 e8        ;   Initialise display (calle878)
             call     io_close_channel     ; $c485 cd 9e e8        ;   Initialise display (calle89e)
             call     find_ram_top         ; $c488 cd 20 c6        ; / find_ram_top: detect top of writeable RAM; returns HL = last writable
                                                                   ; \ byte
;
; saved_session_probe_topram_trailer — inspect the top-of-RAM sentinel,
; backlink, and trailer fingerprint before accepting a saved session.
;
saved_session_probe_topram_trailer: ld       a,$a5                ; $c48b 3e a5           ;   A = $A5 — magic sentinel value
             cp       a,(hl)               ; $c48d be              ;   Compare (HL) with $A5 — check upper sentinel byte
             jr       nz,saved_session_reseed_trailer ; $c48e 20 3d           ;   Sentinel absent — no previously saved BASIC session
             dec      hl                   ; $c490 2b              ;   Compare (HL−1) with ~$A5 — check lower sentinel byte (complement pair)
             cpl                           ; $c491 2f              ; 
             cp       a,(hl)               ; $c492 be              ; 
             jr       nz,saved_session_reseed_trailer ; $c493 20 38           ;   Sentinel absent — no previously saved BASIC session
             dec      hl                   ; $c495 2b              ;   Load saved-session header bytes D,E from RAM
             ld       d,(hl)               ; $c496 56              ; 
             dec      hl                   ; $c497 2b              ; 
             ld       e,(hl)               ; $c498 5e              ; 
             push     de                   ; $c499 d5              ;   Save DE (saved-session pointer) and HL (end-of-program) on stack
             push     hl                   ; $c49a e5              ; 
             call     cmp4_pre             ; $c49b cd 79 c5        ;   Compare 4 bytes at (HL) against saved fingerprint (validate session)
             pop      hl                   ; $c49e e1              ;   Restore HL and DE
             pop      de                   ; $c49f d1              ; 
             push     de                   ; $c4a0 d5              ;   Re-save for subsequent processing
             push     hl                   ; $c4a1 e5              ; 
             jr       z,saved_session_validate_ranges ; $c4a2 28 07           ;   Comparison passed: saved session is valid — set up boundaries
             call     fs_error_prompt      ; $c4a4 cd 04 c6        ;   Session mismatch: clear boundaries (callc604)
             pop      hl                   ; $c4a7 e1              ;   Discard stacked pointers
             pop      hl                   ; $c4a8 e1              ; 
             jr       saved_session_create_empty_image ; $c4a9 18 2c           ;   Jump to finish init

;
; saved_session_validate_ranges — compare recovered trailer bounds
; Uses the saved start-of-BASIC backlink recovered from the
; top-of-RAM trailer and checks that the implied BASIC/file range
; still matches the live $0210/$0212 pointers.  If the range no
; longer matches, the caller falls back to rewriting the bounds.
;
saved_session_validate_ranges: call     cmp_mem_ranges       ; $c4ab cd 83 c5        ; / compare_mem_ranges: check memory range against saved ($0210)/($0212)
                                                                   ; \ boundaries
             pop      hl                   ; $c4ae e1              ;   Restore HL, DE from stack
             pop      de                   ; $c4af d1              ; 
             jr       z,saved_session_finish_init ; $c4b0 28 41           ;   Ranges match — jump to final init
             pop      af                   ; $c4b2 f1              ;   Recover rotated device flags
             push     af                   ; $c4b3 f5              ; 
             jr       nc,saved_session_commit_bounds ; $c4b4 30 0a           ;   Carry clear: skip memory extension save
             push     de                   ; $c4b6 d5              ;   Save DE/HL for update_range_bounds
             push     hl                   ; $c4b7 e5              ; 
             call     cls_and_prompt       ; $c4b8 cd 19 c6        ;   CLS + create-system prompt (callc619)
             call     update_range_bounds  ; $c4bb cd 61 c5        ;   update_range_bounds: check/mark memory range boundaries
             pop      hl                   ; $c4be e1              ;   Restore HL, DE
             pop      de                   ; $c4bf d1              ; 
;
; saved_session_commit_bounds — accept restored BASIC/file limits
; Commits the recovered start pointer from DE into $0210, derives
; the matching end pointer as trailer_base-5, and stores that in
; $0212 so the current session layout matches the saved trailer.
;
saved_session_commit_bounds: ld       ($0210),de           ; $c4c0 ed 53 10 02     ;   Store start-of-BASIC-area ($0210) from DE
             ld       de,$fffb             ; $c4c4 11 fb ff        ;   DE = $FFFB — offset $−5
             add      hl,de                ; $c4c7 19              ;   Compute end-of-free-area pointer
             ld       ($0212),hl           ; $c4c8 22 12 02        ;   Store end-of-BASIC-area ($0212)
             jr       saved_session_finish_init ; $c4cb 18 26           ; 

;
; saved_session_reseed_trailer — rebuild an empty resume trailer
; Path taken when the sentinel pair is absent or when validation
; has already been rejected.  Optionally prompts on the expansion-
; RAM path, then drops into the common code that recreates the
; top-of-RAM marker block from scratch.
;
saved_session_reseed_trailer: pop      af                   ; $c4cd f1              ;   Recover device flags; re-save
             push     af                   ; $c4ce f5              ; 
             jr       nc,saved_session_create_empty_image ; $c4cf 30 06           ;   Carry clear: skip memory extension save
             call     cls_and_prompt       ; $c4d1 cd 19 c6        ;   CLS + create-system prompt
             call     update_range_bounds  ; $c4d4 cd 61 c5        ;   update_range_bounds: mark memory range boundaries
;
; saved_session_create_empty_image — seed sentinel and empty bounds
; Finds the writable RAM ceiling, writes the $A5/~$A5 sentinel pair,
; initialises both $0210 and $0212 to the empty BASIC/file boundary
; just below the trailer, clears the first BASIC word, and leaves a
; provisional backlink word beside the sentinel for later OFF save.
;
saved_session_create_empty_image: call     find_ram_top         ; $c4d7 cd 20 c6        ;   find_ram_top: refresh top of RAM (HL = last writable byte)
             ld       a,$a5                ; $c4da 3e a5           ;   A = $A5 — write upper sentinel byte
             ld       (hl),a               ; $c4dc 77              ;   Store $A5 at (HL)
             cpl                           ; $c4dd 2f              ;   Complement to ~$A5
             dec      hl                   ; $c4de 2b              ;   Store ~$A5 at (HL−1)
             ld       (hl),a               ; $c4df 77              ; 
             push     hl                   ; $c4e0 e5              ;   Save HL (end-of-RAM sentinel address) on stack
             ld       de,$fff9             ; $c4e1 11 f9 ff        ;   DE = $FFF9 — offset $−7
             add      hl,de                ; $c4e4 19              ;   Compute start-of-free-area pointer
             ld       ($0210),hl           ; $c4e5 22 10 02        ;   Store as start-of-BASIC-area at $0210
             ld       ($0212),hl           ; $c4e8 22 12 02        ;   Store as end-of-BASIC-area at $0212
             xor      a,a                  ; $c4eb af              ;   A = 0 — null word at start of BASIC area
             ld       (hl),a               ; $c4ec 77              ;   Write null word
             pop      de                   ; $c4ed d1              ;   Recover sentinel pointer into DE then HL
             ex       de,hl                ; $c4ee eb              ; 
             dec      hl                   ; $c4ef 2b              ;   HL = end-of-RAM − 2
             ld       (hl),d               ; $c4f0 72              ;   Store D at (HL) — high byte of sentinel address
             dec      hl                   ; $c4f1 2b              ; 
             ld       (hl),e               ; $c4f2 73              ;   Store E at (HL+1) — low byte of sentinel address
;
; saved_session_finish_init — common post-restore initialiser
; Shared tail for both accepted warm-session layouts and freshly
; seeded empty images.  Rebuilds the BASIC start pointer, clears
; resume flags, recomputes stack watermarks from $0210, rescans
; page-2 ROM banks, restores tape/I/O setup if needed, prints the
; banner/free-space message, then enters the BASIC main loop.
;
saved_session_finish_init: ld       hl,$0344             ; $c4f3 21 44 03        ;   HL = $0344 — BASIC program start address
             ld       ($03ac),hl           ; $c4f6 22 ac 03        ;   Store HL at $03AC (top-of-program pointer)
             xor      a,a                  ; $c4f9 af              ;   A = 0
             ld       ($01d7),a            ; $c4fa 32 d7 01        ;   Clear warm-start flag at $01D7
             ld       ($0552),a            ; $c4fd 32 52 05        ;   Clear byte at $0552
             ld       hl,($0210)           ; $c500 2a 10 02        ;   HL = ($0210) — start of BASIC area
             ld       de,$fffa             ; $c503 11 fa ff        ;   DE = $FFFA — offset $−6
             add      hl,de                ; $c506 19              ;   Compute pointer to end-of-stack area
             ld       ($01df),hl           ; $c507 22 df 01        ;   Store at $01DF (stack high water mark)
             ld       bc,$ffce             ; $c50a 01 ce ff        ;   BC = $FFCE — offset $−50
             add      hl,bc                ; $c50d 09              ;   Compute pointer to start-of-stack area
             ld       ($01dd),hl           ; $c50e 22 dd 01        ;   Store at $01DD (stack low water mark)
             push     hl                   ; $c511 e5              ;   Save HL on stack
             call     scan_rom_page_2      ; $c512 cd 38 c6        ;   callc638: ROM-bank scan with parameter C=2
             pop      hl                   ; $c515 e1              ;   Restore HL
             pop      af                   ; $c516 f1              ;   Recover device flags
             jr       nc,saved_session_restore_tape ; $c517 30 0c           ;   Carry clear: skip tape-drive restore
             ld       de,($0322)           ; $c519 ed 5b 22 03     ;   DE = ($0322) — tape data pointer
             ex       de,hl                ; $c51d eb              ;   HL = DE
             ld       bc,$0050             ; $c51e 01 50 00        ;   BC = $0050 — 80 bytes
             add      hl,bc                ; $c521 09              ;   Add 80 to HL; test memory region via RST $20
             rst      rst0020              ; $c522 e7              ;   Carry set: skip to calld215
             jr       c,saved_session_restore_runtime_env ; $c523 38 03           ; 
;
; saved_session_restore_tape — optional tape-driver reinitialisation for a
; restored startup path whose saved channel state still points into RAM.
;
saved_session_restore_tape: call     new_reset            ; $c525 cd 15 d2        ;   calld215: initialise tape drive
;
; saved_session_restore_runtime_env — common post-startup I/O / runtime
; environment restore entered after the optional tape setup.
;
saved_session_restore_runtime_env: call     run_env_reset        ; $c528 cd 2d d2        ;   calld22d: further tape/I/O init
             ld       hl,($01dd)           ; $c52b 2a dd 01        ;   HL = ($01DD) — stack low water mark
             ld       de,$ffef             ; $c52e 11 ef ff        ;   DE = $FFEF — offset $−17
             add      hl,de                ; $c531 19              ;   Compute something relative to stack base
             ld       de,$0552             ; $c532 11 52 05        ;   DE = $0552 — region pointer
             xor      a,a                  ; $c535 af              ;   A = 0
             sbc      hl,de                ; $c536 ed 52           ;   SBC HL,DE — compute free space
             push     hl                   ; $c538 e5              ;   Save free space on stack
             ld       hl,$c6b1             ; $c539 21 b1 c6        ;   HL = $C6B1 — copyright/startup banner string
             call     print_c_string       ; $c53c cd f7 fe        ;   Print banner string (callfef7)
             pop      hl                   ; $c53f e1              ;   Restore free-space value
             call     print_uint16_decimal ; $c540 cd 98 bb        ;   Print free-space number (callbb98)
             ld       hl,$c6a3             ; $c543 21 a3 c6        ;   HL = $C6A3 — " Bytes free\r\n" string
             call     print_c_string       ; $c546 cd f7 fe        ;   Print " Bytes free" string
             ld       a,($00b4)            ; $c549 3a b4 00        ;   A = ($00B4) — display column parameter
             add      a,$1f                ; $c54c c6 1f           ;   Add $1F (31)
             call     lcd_cmd_simple       ; $c54e cd 28 e4        ;   Set cursor position (calle428)
             call     warm_restart_env     ; $c551 cd 5f d2        ;   calld25f: further I/O / tape init
             jp       jumpf23d             ; $c554 c3 3d f2        ;   JP to BASIC main loop (jumpf23d)

;
; ============================================================
; Helper functions — RAM detection and comparison
; ============================================================
; Reads port $F2 and tests bit 5 to determine RAM size.
; Returns HL = $2000 if bit 5 set (8 KB), $4000 if clear (16 KB).
; A = $20 / NZ if 8 KB mode; A = 0 / Z if 16 KB mode.
;
get_ram_base_addr: in       a,($f2)              ; $c557 db f2           ; 
             ld       hl,$2000             ; $c559 21 00 20        ; 
             and      a,h                  ; $c55c a4              ; 
             ret      nz                   ; $c55d c0              ; 

             sla      h                    ; $c55e cb 24           ; 
             ret                           ; $c560 c9              ; 

;
; Tests whether the memory boundaries stored at $0210 (start) and
; $0212 (end) are actually in writeable RAM.
; Marks the byte just before the start as $FF if writable,
; and writes into the byte 8 past the end if writable.
; Uses get_ram_base_addr to determine the valid RAM window.
;
update_range_bounds: call     get_ram_base_addr    ; $c561 cd 57 c5        ; 
             ex       de,hl                ; $c564 eb              ; 
             ld       hl,($0210)           ; $c565 2a 10 02        ; 
             dec      hl                   ; $c568 2b              ; 
             rst      rst0020              ; $c569 e7              ; 
             jr       nc,skipc56e          ; $c56a 30 02           ; 
             ld       (hl),$ff             ; $c56c 36 ff           ; 
skipc56e:    ld       hl,($0212)           ; $c56e 2a 12 02        ; 
             ld       bc,rst0008           ; $c571 01 08 00        ; 
             add      hl,bc                ; $c574 09              ; 
             rst      rst0020              ; $c575 e7              ; 
             ret      nc                   ; $c576 d0              ; 

             ld       (hl),d               ; $c577 72              ; 
             ret                           ; $c578 c9              ; 

;
; Compares 4 bytes ending at (HL−1) against 4 bytes ending at (DE−1),
; stepping backwards (B=4 iterations).
; Returns Z if all 4 bytes match, NZ otherwise.
;
cmp4_pre:    ld       b,$04                ; $c579 06 04           ; 
loopc57b:    dec      hl                   ; $c57b 2b              ; 
             dec      de                   ; $c57c 1b              ; 
             ld       a,(de)               ; $c57d 1a              ; 
             cp       a,(hl)               ; $c57e be              ; 
             ret      nz                   ; $c57f c0              ; 

             djnz     loopc57b             ; $c580 10 f9           ; 
;
; disp_noop_6 — RST $20 syscall slot 6 (RAM $0069)
; ----
; Empty stub — immediately returns.  Reserved slot; no
; functionality installed in the base ROM.
; 
; Syscall slot 6: unimplemented — RET.
;
disp_noop_6: ret                           ; $c582 c9              ; 

;
; Compares the address pair (HL, HL−5) against the saved
; memory boundaries ($0210, $0212).
; Falls through to cmp_addr for the comparison.
; Returns Z if both boundaries match.
;
cmp_mem_ranges: ld       bc,($0210)           ; $c583 ed 4b 10 02     ; 
             call     cmp_addr             ; $c587 cd 94 c5        ; 
             ret      nz                   ; $c58a c0              ; 

             ld       de,$fffb             ; $c58b 11 fb ff        ; 
             add      hl,de                ; $c58e 19              ; 
             ex       de,hl                ; $c58f eb              ; 
             ld       bc,($0212)           ; $c590 ed 4b 12 02     ; 
;
; Compares BC (B:C) against DE (D:E) as a 16-bit address.
; Returns Z if equal, NZ otherwise.
;
cmp_addr:    ld       a,c                  ; $c594 79              ; 
             cp       a,e                  ; $c595 bb              ; 
             ret      nz                   ; $c596 c0              ; 

             ld       a,b                  ; $c597 78              ; 
             cp       a,d                  ; $c598 ba              ; 
             ret                           ; $c599 c9              ; 

;
; inst_sleep — SLEEP statement (suspend / power-save)
; SLEEP
; Saves the complete machine state and suspends the CPU.
; The 12 bytes at $C59B are an embedded save-state trampoline template:
; RET NZ / LD ($0266),SP / LD ($0264),HL / LD A,$BF / JR skipc5c5
; Execution continues at skipc5c5:
; push AF ($BF); call call0069 (I/O shutdown); call calldb0b (LCD off
; or display sleep command); save graphics cursor ($0271→$0272); save
; $0210 (program pointer) and $0268 block via callca45; then enter the
; infinite loop at loopc5f8 — machine is suspended until power-cycle
; or interrupt.
; 
; SLEEP statement.  Saves machine state: SP → $0266, HL → $0264.
; Shuts down I/O (call0069) and LCD (calldb0b).  Snapshots key
; RAM registers.  Enters infinite loop (loopc5f8) — CPU halts
; until hardware reset.
;
inst_sleep:  ret      nz                   ; $c59a c0              ; / 12 bytes of embedded code template (RET NZ / LD ($0266),SP /
                                                                   ; | LD ($0264),HL / LD A,$BF / JR ...) — save-state trampoline;
                                                                   ; \ not reachable from the normal code path in ROM.

;
; saved_session_store_resume_regs — persist SP/HL resume registers
; Shared entry reached after the trampoline's initial RET NZ test.
; Stores the interrupted stack pointer at $0266 and the warm-resume
; return address in HL at $0264 before falling into the common
; OFF/SLEEP persistence backend.
;
saved_session_store_resume_regs: ld       ($0266),sp           ; $c59b ed 73 66 02     ; 
             ld       ($0264),hl           ; $c59f 22 64 02        ; 
             ld       a,$bf                ; $c5a2 3e bf           ; 
;
; powerdown_commit_from_sleep — SLEEP's merge point: command byte already
; in A and resume SP/HL already saved, so execution jumps straight into
; saved_session_powerdown_commit.
;
powerdown_commit_from_sleep: jr       saved_session_powerdown_commit ; $c5a4 18 1f           ; 

;
; Checks the hardware event flag at $002B and processes any
; pending event.  Called after I/O operations.
; If $002B ≥ 0 (bit 7 clear), returns immediately.
; Otherwise clears $002B, enables interrupts, and dispatches
; based on the flag value:
; bit 3 set → print message from $C0A6
; bit 1 set → print message from $C0AA
; After printing, continues into cold-start save-state path.
;
io_flag_handler: di                            ; $c5a6 f3              ; 
             ld       a,($002b)            ; $c5a7 3a 2b 00        ; 
callc5aa:    or       a,a                  ; $c5aa b7              ; 
             ret      p                    ; $c5ab f0              ; 

             xor      a,a                  ; $c5ac af              ; 
             ld       ($002b),a            ; $c5ad 32 2b 00        ; 
             ei                            ; $c5b0 fb              ; 
;
; inst_off — OFF statement (power off / auto-poweroff control)
; OFF [mode]
; Without argument (Z on entry): immediate power-off (skipc5c3 path).
; With argument 0: immediate power-off.
; With argument 1: store 1 in $00B4 (enable auto-poweroff, short timeout).
; With argument 2: store 2 in $00B4 (enable auto-poweroff, long timeout?).
; Any other argument → error $F1AA.
; All paths then write $A3 to A and fall through to the shared sleep code
; at skipc5c5 (call0069, calldb0b, state save, infinite loop).
; 
; OFF statement.
; No arg or arg=0: power off immediately (save state + halt).
; OFF 1 or OFF 2: set auto-poweroff mode byte ($00B4) to 1 or 2,
; then power off. Mode byte consulted on wake-up to restore state.
;
inst_off:    jr       z,power_cmd_off      ; $c5b1 28 10           ; 
             call     eval_expr_to_int8    ; $c5b3 cd 5e fe        ; 
             jr       nz,off_mode_validate ; $c5b6 20 04           ; 
             dec      a                    ; $c5b8 3d              ; 
             jr       z,off_mode_store     ; $c5b9 28 05           ; 
             dec      a                    ; $c5bb 3d              ; 
;
; off_mode_validate — reject OFF arguments other than 0, 1, or 2 before
; storing the mode byte and issuing the shared powerdown command.
;
off_mode_validate: jp       nz,basic_raise_error_02 ; $c5bc c2 aa f1        ; 
             inc      a                    ; $c5bf 3c              ; 
;
; off_mode_store — persist OFF mode in $00B4 so the next wake/startup
; path can distinguish plain OFF from timed / auto-poweroff cases.
;
off_mode_store: ld       ($00b4),a            ; $c5c0 32 b4 00        ; 
;
; power_cmd_off — load co-processor power command $A3 and fall through to
; the common OFF/SLEEP save-state + shutdown sequence.
;
power_cmd_off: ld       a,$a3                ; $c5c3 3e a3           ; 
;
; saved_session_powerdown_commit — write resume image then halt
; Common backend for SLEEP and OFF.  Shuts down I/O/LCD state,
; snapshots the cursor byte into the 4-byte fingerprint source at
; $0272..., duplicates that fingerprint before $0210, into
; $0268-$026b, and after $0212, then appends the current $0210
; backlink word after the trailer fingerprint and finally enters
; the infinite suspended loop.
;
saved_session_powerdown_commit: push     af                   ; $c5c5 f5              ; 
             call     call0069             ; $c5c6 cd 69 00        ; 
             call     lcd_submit_tile_mode ; $c5c9 cd 0b db        ; 
             ld       de,$0271             ; $c5cc 11 71 02        ; 
             ld       a,(de)               ; $c5cf 1a              ; 
             inc      de                   ; $c5d0 13              ; 
             ld       (de),a               ; $c5d1 12              ; 
             push     de                   ; $c5d2 d5              ; 
;
; saved_session_store_lead_fingerprint — copy fingerprint before $0210
; Copies the 4-byte fingerprint block sourced from $0272-$0275 to
; ($0210-4)-($0210-1), giving the saved BASIC start boundary its
; matching leading marker.
;
saved_session_store_lead_fingerprint: ld       hl,($0210)           ; $c5d3 2a 10 02        ; 
             dec      hl                   ; $c5d6 2b              ; 
             dec      hl                   ; $c5d7 2b              ; 
             dec      hl                   ; $c5d8 2b              ; 
             dec      hl                   ; $c5d9 2b              ; 
             call     callca45             ; $c5da cd 45 ca        ; 
             pop      de                   ; $c5dd d1              ; 
             push     de                   ; $c5de d5              ; 
;
; saved_session_cache_fingerprint — mirror fingerprint into $0268
; Stores the same 4-byte fingerprint in the fixed RAM header
; $0268-$026b.  warm_restart_probe later compares the trailer copy
; against this cached header fingerprint.
;
saved_session_cache_fingerprint: ld       hl,$0268             ; $c5df 21 68 02        ; 
             call     callca45             ; $c5e2 cd 45 ca        ; 
             pop      de                   ; $c5e5 d1              ; 
;
; saved_session_store_trailer_fingerprint — copy fingerprint after $0212
; Writes the same 4-byte marker to ($0212+1)-($0212+4), building
; the top-of-session trailer that warm-start validation checks.
;
saved_session_store_trailer_fingerprint: ld       hl,($0212)           ; $c5e6 2a 12 02        ; 
             inc      hl                   ; $c5e9 23              ; 
             call     callca45             ; $c5ea cd 45 ca        ; 
;
; saved_session_store_trailer_backlink — append saved $0210 pointer
; Writes the current BASIC/file-area start pointer immediately after
; the trailer fingerprint.  On the next startup, the warm-resume
; probe recovers this backlink and revalidates the saved bounds.
;
saved_session_store_trailer_backlink: ld       de,($0210)           ; $c5ed ed 5b 10 02     ; 
             ld       (hl),e               ; $c5f1 73              ; 
             inc      hl                   ; $c5f2 23              ; 
             ld       (hl),d               ; $c5f3 72              ; 
             pop      af                   ; $c5f4 f1              ; 
             call     lcd_cmd_simple       ; $c5f5 cd 28 e4        ; 
;
; power_suspend_loop — final low-power wait loop after the resume image and
; command byte have been committed; the machine stays here until external
; hardware wakes or resets it.
;
power_suspend_loop: jr       power_suspend_loop   ; $c5f8 18 fe           ; 

;
; Initialises the display (calle878/calle89e) then prints
; the "#MC Error" message ($C688) and loops on the
; "Create system" prompt until the user presses 'Y'.
; Overlapping entry with fs_error_prompt; a four-byte IX
; prefix at $C603 causes callc5fa to use HL=$C688 while
; callc604 uses HL=$C67B.
;
mc_error_prompt: call     io_reset_channel_slots ; $c5fa cd 78 e8        ; 
             call     io_close_channel     ; $c5fd cd 9e e8        ; 
             ld       hl,$c688             ; $c600 21 88 c6        ; 
             defb     $dd                  ; $c603 dd 21 7b c6     ;   As: ld     ix,$c67b   ; dd 21 7b c6 ; Next: $c607
;
; Prints the "#FS Error" message ($C67B) then loops on the
; "Create system" / "Y?" prompt until the user presses 'Y'.
; Returns when 'Y' is received.
;
fs_error_prompt: ld       hl,startup_strings   ; $c604 21 7b c6        ; 
             call     print_c_string       ; $c607 cd f7 fe        ; 
loopc60a:    ld       hl,$c695             ; $c60a 21 95 c6        ; 
             call     print_c_string       ; $c60d cd f7 fe        ; 
             call     kbd_readline_prompt  ; $c610 cd f2 eb        ;   loop body: print "Create system", read key, wait for 'Y'
             rst      rst0010              ; $c613 d7              ; 
             cp       a,$59                ; $c614 fe 59           ; 
             jr       nz,loopc60a          ; $c616 20 f2           ; 
             ret                           ; $c618 c9              ; 

;
; Sends form-feed ($0C) via system call $009F (CLS), then
; falls into the fs_error_prompt loop.
;
cls_and_prompt: ld       a,$0c                ; $c619 3e 0c           ; 
             call     jump009f             ; $c61b cd 9f 00        ; 
             jr       loopc60a             ; $c61e 18 ea           ; 

;
; Scans upward from $2000 in $800-byte steps testing each
; address with test_ram_byte, until a non-writeable address
; is found.  Returns HL = last writable byte address.
;
find_ram_top: ld       de,$0800             ; $c620 11 00 08        ; 
             ld       hl,$1800             ; $c623 21 00 18        ; 
loopc626:    add      hl,de                ; $c626 19              ; 
             call     test_ram_byte        ; $c627 cd 2e c6        ; 
             jr       z,loopc626           ; $c62a 28 fa           ; 
             dec      hl                   ; $c62c 2b              ; 
             ret                           ; $c62d c9              ; 

;
; Writes the complement of (HL) into (HL), reads it back,
; and restores the original.
; Returns Z if the write was retained (address is RAM),
; NZ if not (ROM or absent).
;
test_ram_byte: ld       a,(hl)               ; $c62e 7e              ; 
             ld       b,a                  ; $c62f 47              ; 
             cpl                           ; $c630 2f              ; 
             ld       (hl),a               ; $c631 77              ; 
             cp       a,(hl)               ; $c632 be              ; 
             ld       (hl),b               ; $c633 70              ; 
             ret                           ; $c634 c9              ; 

;
; Entry with C=0: scans ROM page banks starting at $1800.
; Falls through to scan_rom_banks after skipping two LD DE entries.
;
scan_rom_page_0: ld       c,$00                ; $c635 0e 00           ; 
             defb     $11                  ; $c637 11 0e 02        ;   As: ld     de,$020e   ; 11 0e 02   ; Next: $c63a
;
; Entry with C=2: scans ROM page banks starting at $2000.
; Falls through to scan_rom_banks.
;
scan_rom_page_2: ld       c,$02                ; $c638 0e 02           ; 
             defb     $11                  ; $c63a 11 0e 04        ;   As: ld     de,$040e   ; 11 0e 04   ; Next: $c63d
;
; Entry with C=4: scans all 2-KB-aligned ROM page slots from
; $1800 to $B000 looking for a "love" signature ($C677).
; For each slot at H=$98 (the $9800 range), calls calle917.
; When a matching signature is found, executes RST $38 to
; register the page, with C as the bank-index parameter.
;
scan_rom_banks: ld       c,$04                ; $c63b 0e 04           ; 
             ld       hl,$1004             ; $c63d 21 04 10        ; 
             ld       b,$04                ; $c640 06 04           ; 
loopc642:    ld       de,$0800             ; $c642 11 00 08        ; 
             add      hl,de                ; $c645 19              ; 
;
; Inner scan_rom_banks slot walker.  HL steps through each 2-KB candidate
; bank header, DE points at rom_page_signature, and the $9800 window gets
; port-selected before the 4-byte compare.
;
scan_rom_bank_candidate: ld       de,startup_strings   ; $c646 11 7b c6        ; 
             ld       a,$98                ; $c649 3e 98           ; 
             cp       a,h                  ; $c64b bc              ; 
             jr       nz,skipc652          ; $c64c 20 04           ; 
             ld       a,b                  ; $c64e 78              ; 
             call     calle917             ; $c64f cd 17 e9        ; 
skipc652:    push     bc                   ; $c652 c5              ; 
             push     hl                   ; $c653 e5              ; 
             call     cmp4_pre             ; $c654 cd 79 c5        ; 
             jr       nz,scan_rom_bank_advance ; $c657 20 0f           ; 
             pop      hl                   ; $c659 e1              ; 
             pop      bc                   ; $c65a c1              ; 
;
; Match path inside scan_rom_banks.  Re-biases HL by the page selector in C
; and enters the RST $38 registration helper so the discovered ROM/option
; bank gets published into the live catalog-pointer table.
;
scan_rom_bank_register: push     bc                   ; $c65b c5              ; 
             push     hl                   ; $c65c e5              ; 
             ld       b,$00                ; $c65d 06 00           ; 
             add      hl,bc                ; $c65f 09              ; 
             ld       de,scan_rom_bank_advance ; $c660 11 68 c6        ; 
             push     de                   ; $c663 d5              ; 
             rst      rst0038              ; $c664 ff              ; 
             nop                           ; $c665 00              ; 
             push     de                   ; $c666 d5              ; 
             ret                           ; $c667 c9              ; 

;
; Failed-compare / continue path for scan_rom_banks.  Restores HL and BC,
; checks whether the current 8-KB page window has more candidate slots, then
; either advances within the page or moves on to the next bank region.
;
scan_rom_bank_advance: pop      hl                   ; $c668 e1              ; 
             pop      bc                   ; $c669 c1              ; 
             ld       a,$98                ; $c66a 3e 98           ; 
             cp       a,h                  ; $c66c bc              ; 
             jr       nz,skipc671          ; $c66d 20 02           ; 
             djnz     scan_rom_bank_candidate ; $c66f 10 d5           ; 
skipc671:    ld       a,$b0                ; $c671 3e b0           ; 
             cp       a,h                  ; $c673 bc              ; 
             jr       nz,loopc642          ; $c674 20 cc           ; 
             ret                           ; $c676 c9              ; 

;
; ============================================================
; Startup string data — $C677–$C6DA
; ============================================================
; 4-byte ROM-page magic tag: "love" (6C 6F 76 65).
; Compared by scan_rom_banks against each candidate bank slot.
;
rom_page_signature: defm     "love"                                                    ;
;
; Null-terminated strings used during startup.
; Each string begins with $0C (form-feed / CLS) except
; "Create system" and " Bytes free".
; Addresses:
; $C67B — $0C + "#FS Error\r\n" + $00
; $C688 — $0C + "#MC Error\r\n" + $00
; $C695 — "Create system" + $00
; $C6A3 — " Bytes free\r\n" + $00
; $C6B1 — $0C + "Copyright(c) 1983 by Microsoft & Canon\r\n" + $00
;
startup_strings: defb     $0c                                          ; .          ; 
             defm     "#FS Error"                                               ;
             defb     $0d,$0a,$00,$0c                              ; ....       ; 
             defm     "#MC Error"                                               ;
             defb     $0d,$0a,$00                                  ; ...        ; 
             defm     "Create system",0                                         ;
             defm     " Bytes free"                                             ;
             defb     $0d,$0a,$00,$0c                              ; ....       ; 
             defm     "Copyright(c) 1983 by Microsoft & Canon"                  ;
             defb     $0d,$0a,$00                                  ; ...        ; 
;
; ============================================================
; RAM init block — $C6DB–$C788
; ============================================================
; 174 bytes ($AE) copied to RAM $0000–$00AD at startup by LDIR.
; Structure:
; $0000–$003B : RST vector slots (8 bytes each).
; Each occupied slot has JP <handler> at the slot start
; followed by 5 padding bytes. Unoccupied slots hold
; RET or other data.
; $003C–$004F : Extra hook vectors (indirect trampolines, placeholders).
; $0050–$0056 : Uninitialised placeholder RETs.
; $0057–$00AD : 3-byte-per-slot system-call dispatch table.
; Each slot is JP <routine> or C9 00 00 (unimplemented).
;
rst_init_block: ret                           ; $c6db c9              ;   RST $00 placeholder (RET) — RAM $0000

             defb     $00,$00,$00,$50,$02,$77,$02                  ; ...P.w.    ; 
             jp       rst08_match_token    ; $c6e3 c3 2f f5        ;   RST $08 — JP $F52F — RAM $0008

             defb     $64,$00,$00,$00,$00                          ; d....      ; 
             jp       rst10_fetch_token    ; $c6eb c3 37 f5        ;   RST $10 — JP $F537 — RAM $0010

             defb     $00,$00,$00,$00,$00                          ; .....      ; 
             jp       rst18_io_channel_status ; $c6f3 c3 c7 c9        ;   RST $18 — JP $C9C7 — RAM $0018

             defb     $3a,$00,$00,$00,$00                          ; :....      ; 
             jp       rst20_cmp_hl_de      ; $c6fb c3 45 ee        ;   RST $20 — JP $EE45 — RAM $0020

             defb     $00,$00,$00,$00,$00                          ; .....      ; 
             jp       rst28_print_char     ; $c703 c3 8f e8        ;   RST $28 — JP $E88F — RAM $0028

             defb     $00,$c9,$00,$00,$00                          ; .....      ; 
             jp       rst30_device_mode    ; $c70b c3 2f fc        ;   RST $30 — JP $FC2F — RAM $0030

             defb     $00                                          ; .          ; 
             jp       hw_irq_tick_service  ; $c70f c3 a3 c7        ;   RAM $0034 hook — JP $C7A3

             defb     $00                                          ; .          ; 
             jp       rst38_device_dispatch ; $c713 c3 06 e9        ;   RST $38 — JP $E906 — RAM $0038

             defb     $00                                          ; .          ; 
             jp       hw_irq_f0_dispatch   ; $c717 c3 99 c7        ;   RAM $003C hook — JP $C799

             jp       jump009f             ; $c71a c3 9f 00        ;   RAM $003F indirect — JP $009F (installed target: JP $C1BE)

             jp       jump00a2             ; $c71d c3 a2 00        ;   RAM $0042 indirect — JP $00A2 (installed target: JP $C90A)

             defb     $0c,$e8,$00                                  ; ...        ; 
             ret                           ; $c723 c9              ;   RAM $0048 placeholder (RET)

             defb     $00,$00,$00                                  ; ...        ; 
             ret                           ; $c727 c9              ;   RAM $004C placeholder (RET)

             defb     $00,$00,$00                                  ; ...        ; 
             ret                           ; $c72b c9              ;   RAM $0050 placeholder (RET)

             defb     $00,$00,$00                                  ; ...        ; 
             ret                           ; $c72f c9              ;   RAM $0054 placeholder (RET)

             defb     $00,$00                                      ; ..         ; 
;
; System-call dispatch table — RAM $0057–$00AD
; Each slot 3 bytes: JP <routine> or C9 00 00 (unimplemented).
; Copied to RAM at startup (LDIR from $C732, 174 bytes → $0057–$00AD).
; Callers use CALL $00xx to invoke a slot; this jumps through the
; installed JP stub to the ROM handler (or a RET if unimplemented).
; 
; Slot  RAM     ROM handler      Name
; ----  ------  ---------------  --------------------------------
; 0   $0057   $E327            disp_reset
; 1   $005A   $C16C            (noop — RET)
; 2   $005D   $C1FA            disp_set_col
; 3   $0060   $C181            disp_read_char
; 4   $0063   $C219            disp_send_row
; 5   $0066   (RET placeholder)
; 6   $0069   $C582            (noop — RET)
; 7   $006C   $C0A1            error_translate
; 8   $006F   $C210            disp_write_char
; 9   $0072   $C231            disp_set_cursor
; 10   $0075   $C250            disp_row_addr
; 11   $0078   $C154            disp_fill_spaces
; 12   $007B   $C138            disp_scroll_down
; 13   $007E   $C120            disp_scroll_up
; 14   $0081   $C24B            error_beep8
; 15   $0084   $F1AA            lcd_cmd_dispatch
; 16   $0087   $E403            inst_locate_exec
; 17   $008A   $F1AA            lcd_cmd_dispatch (alias)
; 18   $008D   $CDF4            pset_handler
; 19   $0090   $CDF7            preset_handler
; 20   $0093   $CE05            inst_draw_exec
; 21   $0096   $CE19            inst_line_exec
; 22   $0099   $F1AA            lcd_cmd_dispatch (alias)
; 23   $009C   $CE32            inst_circle_exec
; 24   $009F   $C1BE            disp_put_char
; 25   $00A2   $C90A            key_scan
; 26   $00A5   $C16D            disp_ctrl_char
; 27   $00A8   (RET placeholder)
; 28   $00AB   (RET placeholder)
;
sys_call_table: jp       disp_reset           ; $c732 c3 27 e3        ;   RAM $0057 — JP $E327

             jp       disp_noop_1          ; $c735 c3 6c c1        ;   RAM $005A — JP $C16C

             jp       disp_set_col         ; $c738 c3 fa c1        ;   RAM $005D — JP $C1FA

             jp       disp_read_char       ; $c73b c3 81 c1        ;   RAM $0060 — JP $C181

             jp       disp_send_row        ; $c73e c3 19 c2        ;   RAM $0063 — JP $C219

             ret                           ; $c741 c9              ;   RAM $0066 placeholder (RET)

             defb     $00,$00                                      ; ..         ; 
             jp       disp_noop_6          ; $c744 c3 82 c5        ;   RAM $0069 — JP $C582

             jp       error_translate      ; $c747 c3 a1 c0        ;   RAM $006C — JP $C0A1

             jp       disp_write_char      ; $c74a c3 10 c2        ;   RAM $006F — JP $C210

             jp       disp_set_cursor      ; $c74d c3 31 c2        ;   RAM $0072 — JP $C231

             jp       disp_row_addr        ; $c750 c3 50 c2        ;   RAM $0075 — JP $C250

             jp       disp_fill_spaces     ; $c753 c3 54 c1        ;   RAM $0078 — JP $C154

             jp       disp_scroll_down     ; $c756 c3 38 c1        ;   RAM $007B — JP $C138

             jp       disp_scroll_up       ; $c759 c3 20 c1        ;   RAM $007E — JP $C120

             jp       error_beep8          ; $c75c c3 4b c2        ;   RAM $0081 — JP $C24B

             jp       basic_raise_error_02 ; $c75f c3 aa f1        ;   RAM $0084 — JP $F1AA

             jp       inst_locate_exec     ; $c762 c3 03 e4        ;   RAM $0087 — JP $E403

             jp       basic_raise_error_02 ; $c765 c3 aa f1        ;   RAM $008A — JP $F1AA

             jp       pset_handler         ; $c768 c3 f4 cd        ;   RAM $008D — JP $CDF4

             jp       preset_handler       ; $c76b c3 f7 cd        ;   RAM $0090 — JP $CDF7

             jp       inst_draw_exec       ; $c76e c3 05 ce        ;   RAM $0093 — JP $CE05

             jp       inst_line_exec       ; $c771 c3 19 ce        ;   RAM $0096 — JP $CE19

             jp       basic_raise_error_02 ; $c774 c3 aa f1        ;   RAM $0099 — JP $F1AA

             jp       inst_circle_exec     ; $c777 c3 32 ce        ;   RAM $009C — JP $CE32

             jp       disp_put_char        ; $c77a c3 be c1        ;   RAM $009F — JP $C1BE

             jp       key_scan             ; $c77d c3 0a c9        ;   RAM $00A2 — JP $C90A

             jp       disp_ctrl_char       ; $c780 c3 6d c1        ;   RAM $00A5 — JP $C16D

             ret                           ; $c783 c9              ;   RAM $00A8 placeholder (RET)

             defb     $00,$00                                      ; ..         ; 
             ret                           ; $c786 c9              ;   RAM $00AB placeholder (RET)

             defb     $00,$00                                      ; ..         ; 
             nop                           ; $c789 00              ; 
             nop                           ; $c78a 00              ; 
             nop                           ; $c78b 00              ; 
             nop                           ; $c78c 00              ; 
             ld       d,e                  ; $c78d 53              ; 
             dec      b                    ; $c78e 05              ; 
             ld       bc,$0000             ; $c78f 01 00 00        ; 
             ld       bc,$0101             ; $c792 01 01 01        ; 
             inc      d                    ; $c795 14              ; 
             ld       bc,$0404             ; $c796 01 04 04        ; 
;
; RAM $003c interrupt-hook body.
; Swaps to the alternate register set, tests port $f2 bit 0, and only
; enters the heavy service logic when that status bit is asserted.
; Active interrupts branch into the shared port-$f0/$f1 dispatcher at
; $c802; otherwise the routine returns through the common tail.
;
hw_irq_f0_dispatch: exx                           ; $c799 d9              ; 
             ex       af,af'               ; $c79a 08              ; 
             in       a,($f2)              ; $c79b db f2           ; 
             and      a,$01                ; $c79d e6 01           ; 
             jr       nz,hw_process_f0_flags ; $c79f 20 61           ; 
             jr       skipc7ff             ; $c7a1 18 5c           ; 

;
; RAM $0034 interrupt-hook body for the periodic low-level service
; path.  If port $f6 bit 1 is clear and port $f2 bit 2 is set, it
; decrements the countdown at $000e.  When the countdown reaches zero,
; it clears bit 5 in the shared port-$f0 shadow ($026c), drops the
; paired audio bits on port $f4, and strobes $10 to port $f5.  If that
; timer path is not active, it falls into the key / cassette-status
; poll at $c7d1.
;
hw_irq_tick_service: exx                           ; $c7a3 d9              ; 
             ex       af,af'               ; $c7a4 08              ; 
             in       a,($f6)              ; $c7a5 db f6           ; 
             and      a,$02                ; $c7a7 e6 02           ; 
             jr       nz,hw_irq_f7_keyscan ; $c7a9 20 26           ; 
             in       a,($f2)              ; $c7ab db f2           ; 
             and      a,$04                ; $c7ad e6 04           ; 
             jr       z,skipc7ff           ; $c7af 28 4e           ; 
;
; Active buzzer/rest tick path.
; Decrements the shared countdown in RAM $000e and branches to
; audio_countdown_expire when the 16-bit counter reaches zero.
;
audio_countdown_tick: ld       hl,($000e)           ; $c7b1 2a 0e 00        ; 
             dec      hl                   ; $c7b4 2b              ; 
             ld       ($000e),hl           ; $c7b5 22 0e 00        ; 
             ld       a,h                  ; $c7b8 7c              ; 
             or       a,l                  ; $c7b9 b5              ; 
             jr       nz,audio_tick_ack_strobe ; $c7ba 20 0f           ; 
;
; Tone/rest completion handler for hw_irq_tick_service.
; Clears bit 5 in the shared port-$f0 shadow, drops the audio-enable
; bits on port $f4, then falls into the standard $f5 strobe.
;
audio_countdown_expire: ld       hl,$026c             ; $c7bc 21 6c 02        ; 
             ld       a,(hl)               ; $c7bf 7e              ; 
             and      a,$df                ; $c7c0 e6 df           ; 
             ld       (hl),a               ; $c7c2 77              ; 
             out      ($f0),a              ; $c7c3 d3 f0           ; 
             in       a,($f4)              ; $c7c5 db f4           ; 
             and      a,$21                ; $c7c7 e6 21           ; 
             out      ($f4),a              ; $c7c9 d3 f4           ; 
;
; Common tick-side acknowledge strobe for the buzzer countdown path.
; Writes $10 to port $f5 before returning to the shared interrupt tail.
;
audio_tick_ack_strobe: ld       a,$10                ; $c7cb 3e 10           ; 
             out      ($f5),a              ; $c7cd d3 f5           ; 
             jr       skipc7ff             ; $c7cf 18 2e           ; 

;
; Tick-side helper used by hw_irq_tick_service.
; Samples port $f7 and the $38 status bits from port $f6, mirrors any
; non-zero $f6 status into $030c, raises bit 4 in the port-$f6 shadow
; at $030b, then updates keyboard state via callc262 and
; key_matrix_scan with scan slot 1.  If a fresh event is recognised
; (result < 6), it clears bit 4 in $030b and rewrites port $f6 before
; finishing with the standard $f5=$04 strobe.
;
hw_irq_f7_keyscan: in       a,($f7)              ; $c7d1 db f7           ; 
             ld       e,a                  ; $c7d3 5f              ; 
             in       a,($f6)              ; $c7d4 db f6           ; 
             and      a,$38                ; $c7d6 e6 38           ; 
             jr       z,hw_irq_f7_keyscan_slot1 ; $c7d8 28 0a           ; 
             ld       ($030c),a            ; $c7da 32 0c 03        ; 
             ld       a,($030b)            ; $c7dd 3a 0b 03        ; 
             or       a,$10                ; $c7e0 f6 10           ; 
             out      ($f6),a              ; $c7e2 d3 f6           ; 
;
; Slot-1 keyscan body inside hw_irq_f7_keyscan.
; Selects scan slot 1 via callc262/key_matrix_scan, then checks whether
; the returned event code is below 6.
;
hw_irq_f7_keyscan_slot1: ld       a,$01                ; $c7e4 3e 01           ; 
             call     callc262             ; $c7e6 cd 62 c2        ; 
             ld       a,$01                ; $c7e9 3e 01           ; 
             call     key_matrix_scan      ; $c7eb cd aa c2        ; 
             cp       a,$06                ; $c7ee fe 06           ; 
             jr       nc,hw_irq_f7_ack_strobe ; $c7f0 30 09           ; 
;
; Success path from hw_irq_f7_keyscan_slot1.
; Clears bit 5 in the shared $030b port-$f6 shadow and rewrites the
; port so the freshly handled slot-1 event is acknowledged.
;
hw_irq_f7_clear_slot1_flag: ld       hl,$030b             ; $c7f2 21 0b 03        ; 
             ld       a,(hl)               ; $c7f5 7e              ; 
             and      a,$df                ; $c7f6 e6 df           ; 
             ld       (hl),a               ; $c7f8 77              ; 
             out      ($f6),a              ; $c7f9 d3 f6           ; 
;
; Final port-$f5 acknowledge used by the slot-1 keyboard scan path.
; Writes $04 to port $f5 before joining the common IRQ exit.
;
hw_irq_f7_ack_strobe: ld       a,$04                ; $c7fb 3e 04           ; 
             out      ($f5),a              ; $c7fd d3 f5           ; 
skipc7ff:    jp       hw_irq_restore_exit  ; $c7ff c3 c1 c8        ; 

;
; Main interrupt-side dispatcher once port $f2 bit 0 says work is
; pending.  Reads the high status bits of shared control port $f0:
; bit 7 selects the port-$f1 event-to-$002b flag path, bit 6 selects
; LCD receive handling through $026d mode dispatch, and neither bit
; set falls through to the special-key / LCD-refresh path at $c87e.
;
hw_process_f0_flags: in       a,($f0)              ; $c802 db f0           ; 
             and      a,$c0                ; $c804 e6 c0           ; 
             jr       z,hw_special_key_event ; $c806 28 76           ; 
             and      a,$80                ; $c808 e6 80           ; 
             jr       z,hw_lcd_rx_dispatch ; $c80a 28 29           ; 
;
; Port-$f1 event decoder used when hw_process_f0_flags sees port-$f0
; bit 7 set.  Maps incoming codes $04..$08 onto flag bits
; $80/$01/$02/$40/$04 and merges the selected bit into the pending
; event/status byte at $002b.
;
hw_f1_event_flag_dispatch: in       a,($f1)              ; $c80c db f1           ; 
             sub      a,$04                ; $c80e d6 04           ; 
             jr       z,hw_f1_event_flag_bit80 ; $c810 28 19           ; 
             dec      a                    ; $c812 3d              ; 
             jr       z,hw_f1_event_flag_bit01 ; $c813 28 0d           ; 
             dec      a                    ; $c815 3d              ; 
             jr       z,hw_f1_event_flag_bit02 ; $c816 28 0d           ; 
             dec      a                    ; $c818 3d              ; 
             jr       z,hw_f1_event_flag_bit40 ; $c819 28 0d           ; 
             dec      a                    ; $c81b 3d              ; 
             jr       nz,skipc84e          ; $c81c 20 30           ; 
;
; Case for port-$f1 event code $08: load mask $04 and join the shared
; event-flag store tail at $c82d.
;
hw_f1_event_flag_bit04: ld       b,$04                ; $c81e 06 04           ; 
             jr       hw_f1_event_flag_store ; $c820 18 0b           ; 

;
; Case for port-$f1 event code $05: select pending event bit $01.
;
hw_f1_event_flag_bit01: ld       b,$01                ; $c822 06 01           ; 
             defb     $11                  ; $c824 11 06 02        ;   As: ld     de,$0206   ; 11 06 02   ; Next: $c827
;
; Case for port-$f1 event code $06: select pending event bit $02.
;
hw_f1_event_flag_bit02: ld       b,$02                ; $c825 06 02           ; 
             defb     $11                  ; $c827 11 06 40        ;   As: ld     de,$4006   ; 11 06 40   ; Next: $c82a
;
; Case for port-$f1 event code $07: select pending event bit $40.
;
hw_f1_event_flag_bit40: ld       b,$40                ; $c828 06 40           ; 
             defb     $11                  ; $c82a 11 06 80        ;   As: ld     de,$8006   ; 11 06 80   ; Next: $c82d
;
; Case for port-$f1 event code $04: select pending event bit $80.
;
hw_f1_event_flag_bit80: ld       b,$80                ; $c82b 06 80           ; 
;
; Shared tail for the port-$f1 event decoder.
; ORs the mask from B into $002b, then returns through the common IRQ
; acknowledge path.
;
hw_f1_event_flag_store: ld       hl,$002b             ; $c82d 21 2b 00        ; 
             ld       a,(hl)               ; $c830 7e              ; 
             or       a,b                  ; $c831 b0              ; 
             ld       (hl),a               ; $c832 77              ; 
             jr       skipc84e             ; $c833 18 19           ; 

;
; Interrupt-side LCD receive mode dispatcher.
; Uses $026d as a reply-mode byte.  Normal counted replies read a byte
; from port $f1, store it through pointer $0016, and decrement $020f.
; Mode $fe counts non-zero bytes without storing them; mode $ff stores
; non-zero bytes and increments $020f.  A zero byte ends the framed
; modes by clearing $026d at $c879.
;
hw_lcd_rx_dispatch: ld       a,($026d)            ; $c835 3a 6d 02        ; 
             cp       a,$ff                ; $c838 fe ff           ; 
             jr       z,hw_lcd_rx_store_nonzero ; $c83a 28 22           ; 
             cp       a,$fe                ; $c83c fe fe           ; 
             jr       z,hw_lcd_rx_count_nonzero ; $c83e 28 10           ; 
             in       a,($f1)              ; $c840 db f1           ; 
;
; Interrupt-side LCD receive helper.
; Reads one byte from port $f1, stores it at the transfer pointer in
; $0016, advances that pointer, then falls into lcd_rx_count_down to
; consume one byte from the outstanding reply count at $020f.
;
lcd_rx_store_byte: ld       hl,($0016)           ; $c842 2a 16 00        ; 
             ld       (hl),a               ; $c845 77              ; 
             inc      hl                   ; $c846 23              ; 
             ld       ($0016),hl           ; $c847 22 16 00        ; 
;
; Internal receive tail for fixed-length LCD replies.
; Decrements $020f after a byte has been copied from port $f1 into
; the reply buffer addressed by $0016.
;
lcd_rx_count_down: ld       hl,$020f             ; $c84a 21 0f 02        ; 
             dec      (hl)                 ; $c84d 35              ; 
skipc84e:    jr       hw_irq_f5_ack        ; $c84e 18 6d           ; 

;
; Mode-$fe branch of hw_lcd_rx_dispatch.
; Reads port $f1, treats zero as end-of-frame, and otherwise bumps the
; software byte counter at $020f (unless it is already saturated at
; $ff).  This is the interrupt path for reply modes that only need a
; running non-zero byte count.
;
hw_lcd_rx_count_nonzero: in       a,($f1)              ; $c850 db f1           ; 
             or       a,a                  ; $c852 b7              ; 
             jr       z,lcd_rx_frame_terminator ; $c853 28 24           ; 
             ld       a,($020f)            ; $c855 3a 0f 02        ; 
             cp       a,$ff                ; $c858 fe ff           ; 
             jr       z,hw_irq_f5_ack      ; $c85a 28 61           ; 
             jr       lcd_rx_count_up      ; $c85c 18 15           ; 

;
; Mode-$ff branch of hw_lcd_rx_dispatch.
; Reads a non-zero byte from port $f1, stores it through the transfer
; pointer at $0016, advances that pointer, and then increments the
; software receive counter at $020f.  Zero clears $026d and terminates
; the framed transfer.
;
hw_lcd_rx_store_nonzero: in       a,($f1)              ; $c85e db f1           ; 
             or       a,a                  ; $c860 b7              ; 
             jr       z,lcd_rx_frame_terminator ; $c861 28 16           ; 
             ld       b,a                  ; $c863 47              ; 
             ld       a,($020f)            ; $c864 3a 0f 02        ; 
             cp       a,$ff                ; $c867 fe ff           ; 
             jr       z,hw_irq_f5_ack      ; $c869 28 52           ; 
             ld       hl,($0016)           ; $c86b 2a 16 00        ; 
             ld       (hl),b               ; $c86e 70              ; 
             inc      hl                   ; $c86f 23              ; 
             ld       ($0016),hl           ; $c870 22 16 00        ; 
;
; Internal receive tail for framed/status LCD replies.
; Increments $020f after a byte has been accepted, matching the
; $fe/$ff reply modes handled in the surrounding interrupt code.
;
lcd_rx_count_up: ld       hl,$020f             ; $c873 21 0f 02        ; 
             inc      (hl)                 ; $c876 34              ; 
             jr       hw_irq_f5_ack        ; $c877 18 44           ; 

;
; Shared zero-byte terminator for the framed LCD reply modes
; ($fe / $ff in $026d).  Clears the reply-mode byte and returns
; through the common interrupt tail.
;
lcd_rx_frame_terminator: ld       ($026d),a            ; $c879 32 6d 02        ; 
             jr       hw_irq_f5_ack        ; $c87c 18 3f           ; 

;
; Fallback interrupt path when hw_process_f0_flags sees no active high
; bits in port $f0.  Reads a status / event byte from port $f1,
; normalises a few special cases ($03, $13, $7f→$16), updates
; keyboard-matrix slot 0 via callc262 and key_matrix_scan, and stores
; a recognised event code in $0037.  If the LCD is idle ($0033=0), it
; immediately asserts bit 7 in $026c and sends command $bc to the LCD;
; otherwise it raises $0023 so the foreground LCD submit path will
; retry the refresh later.
;
hw_special_key_event: in       a,($f1)              ; $c87e db f1           ; 
             cp       a,$03                ; $c880 fe 03           ; 
             jr       z,hw_f1_event_flag_bit01 ; $c882 28 9e           ; 
             cp       a,$13                ; $c884 fe 13           ; 
             jr       z,hw_f1_event_flag_bit04 ; $c886 28 96           ; 
             cp       a,$7f                ; $c888 fe 7f           ; 
             jr       nz,skipc88e          ; $c88a 20 02           ; 
             ld       a,$16                ; $c88c 3e 16           ; 
skipc88e:    ld       e,a                  ; $c88e 5f              ; 
             xor      a,a                  ; $c88f af              ; 
             call     callc262             ; $c890 cd 62 c2        ; 
             xor      a,a                  ; $c893 af              ; 
             call     key_matrix_scan      ; $c894 cd aa c2        ; 
             cp       a,$06                ; $c897 fe 06           ; 
             jr       nc,hw_irq_f5_ack     ; $c899 30 22           ; 
             ld       ($0037),a            ; $c89b 32 37 00        ; 
             ld       a,($0033)            ; $c89e 3a 33 00        ; 
             or       a,a                  ; $c8a1 b7              ; 
             jr       nz,hw_special_key_defer_refresh ; $c8a2 20 14           ; 
             ld       a,($026c)            ; $c8a4 3a 6c 02        ; 
             or       a,$80                ; $c8a7 f6 80           ; 
             ld       ($026c),a            ; $c8a9 32 6c 02        ; 
             out      ($f0),a              ; $c8ac d3 f0           ; 
             ld       a,$bc                ; $c8ae 3e bc           ; 
             out      ($f1),a              ; $c8b0 d3 f1           ; 
             ld       a,$02                ; $c8b2 3e 02           ; 
             out      ($f5),a              ; $c8b4 d3 f5           ; 
             jr       hw_irq_f5_ack        ; $c8b6 18 05           ; 

;
; Deferred-refresh path from hw_special_key_event.
; Stores $0f in $0023 so the foreground LCD submit wrapper resends
; command $bc after the current transfer completes.
;
hw_special_key_defer_refresh: ld       a,$0f                ; $c8b8 3e 0f           ; 
             ld       ($0023),a            ; $c8ba 32 23 00        ; 
;
; Common interrupt-side acknowledge strobe.
; Writes $01 to port $f5, then falls into the restore / ei / ret
; epilogue at $c8c1.
;
hw_irq_f5_ack: ld       a,$01                ; $c8bd 3e 01           ; 
             out      ($f5),a              ; $c8bf d3 f5           ; 
;
; Common interrupt exit used by the low-level port-$f0/$f1 service
; paths.  Restores the alternate register set, reenables interrupts,
; and returns.
;
hw_irq_restore_exit: ex       af,af'               ; $c8c1 08              ; 
             exx                           ; $c8c2 d9              ; 
             ei                            ; $c8c3 fb              ; 
             ret                           ; $c8c4 c9              ; 

;
; kbd_read_char — blocking keyboard read with background LCD/I/O servicing
; Waits in a loop until a key is pressed, while servicing display
; updates and I/O on each iteration:
; - io_flag_handler: process pending output-device flags.
; - callc5aa / callc06c: service printer / display output queues.
; - callc02d: check abort / error status (carry → SCF exit).
; - callc097 + key_scan (jump00a2): scan the keyboard matrix.
; When the LCD-pending flag ($002B) is clear and no key has
; arrived, pokes the LCD controller ($026C | $40 → port $F0)
; to keep the display refresh alive before looping again.
; Returns: A = ASCII key code, NZ set, carry clear (key pressed).
; Returns carry set (skipc8fd) on error or break-abort.
;
kbd_read_char: push     bc                   ; $c8c5 c5              ; 
             push     de                   ; $c8c6 d5              ; 
             push     hl                   ; $c8c7 e5              ; 
             xor      a,a                  ; $c8c8 af              ; 
             call     call006c             ; $c8c9 cd 6c 00        ; 
;
; Main wait loop inside kbd_read_char.
; While no key is available it services output queues, checks abort
; state, scans the keyboard through RAM $00A2, and only then decides
; whether to return or poke the LCD refresh path.
;
kbd_read_service_loop: call     io_flag_handler      ; $c8cc cd a6 c5        ; 
             rla                           ; $c8cf 17              ; 
             call     callc5aa             ; $c8d0 cd aa c5        ; 
             call     output_queue_dispatch ; $c8d3 cd 6c c0        ; 
             jr       nz,skipc8fb          ; $c8d6 20 23           ; 
             call     abort_flag_handler   ; $c8d8 cd 2d c0        ; 
             jr       nz,kbd_read_error_exit ; $c8db 20 20           ; 
             ld       b,$fb                ; $c8dd 06 fb           ; 
             call     hw_flags_mask        ; $c8df cd 97 c0        ; 
             call     jump00a2             ; $c8e2 cd a2 00        ; 
             jp       c,jumpe8b6           ; $c8e5 da b6 e8        ; 
             jr       nz,kbd_read_restore_device_state ; $c8e8 20 14           ; 
;
; LCD-refresh keepalive path used by kbd_read_service_loop.
; When no key event is pending and $002b is clear, it ORs bit 6 into
; the port-$f0 shadow at $026c, writes that value to port $f0, and
; loops back so the co-processor keeps refreshing during blocking
; keyboard waits.
;
kbd_read_refresh_poke: di                            ; $c8ea f3              ; 
             ld       a,($002b)            ; $c8eb 3a 2b 00        ; 
             or       a,a                  ; $c8ee b7              ; 
             jr       nz,kbd_read_service_loop ; $c8ef 20 db           ; 
             ld       a,($026c)            ; $c8f1 3a 6c 02        ; 
             or       a,$40                ; $c8f4 f6 40           ; 
             out      ($f0),a              ; $c8f6 d3 f0           ; 
             ei                            ; $c8f8 fb              ; 
             jr       kbd_read_service_loop ; $c8f9 18 d1           ; 

skipc8fb:    xor      a,a                  ; $c8fb af              ; 
             defb     $06                  ; $c8fc 06 37           ;   As: ld     b,$37      ; 06 37      ; Next: $c8fe
;
; Carry-set early exit from kbd_read_char.
; Used when the abort/error path reports failure before a key is
; returned.
;
kbd_read_error_exit: scf                           ; $c8fd 37              ; 
;
; Common unwind path for kbd_read_char.
; Reenables interrupts, calls call006c with A=$01 to restore the
; previous device state, then falls into the shared register-pop tail.
;
kbd_read_restore_device_state: ei                            ; $c8fe fb              ; 
             push     af                   ; $c8ff f5              ; 
             ld       a,$01                ; $c900 3e 01           ; 
             call     call006c             ; $c902 cd 6c 00        ; 
             pop      af                   ; $c905 f1              ; 
;
; Shared register-restore tail for kbd_read_char and key_scan.
; Pops HL/DE/BC and returns to the caller.
;
kbd_read_epilogue: pop      hl                   ; $c906 e1              ; 
             pop      de                   ; $c907 d1              ; 
             pop      bc                   ; $c908 c1              ; 
             ret                           ; $c909 c9              ; 

;
; key_scan — RST $20 syscall slot 25 (RAM $00A2)
; ----
; Scan the keyboard and return the pressed key code.
; Calls callc2aa (with DI/EI) to read the raw key matrix.
; If the result is ≥ $0F, checks the break flag at $0037;
; if set, clears it and signals error $BB (break) via
; calle428.  Calls callc27d for secondary key processing,
; clears carry, and returns the key code.
; 
; Scan keyboard; handle break key; return key code.
;
key_scan:    push     bc                   ; $c90a c5              ; 
             push     de                   ; $c90b d5              ; 
             push     hl                   ; $c90c e5              ; 
             xor      a,a                  ; $c90d af              ; 
             di                            ; $c90e f3              ; 
             call     key_matrix_scan      ; $c90f cd aa c2        ; 
             ei                            ; $c912 fb              ; 
             cp       a,$0f                ; $c913 fe 0f           ; 
             jr       c,skipc925           ; $c915 38 0e           ; 
             ld       hl,$0037             ; $c917 21 37 00        ; 
             ld       a,(hl)               ; $c91a 7e              ; 
             or       a,a                  ; $c91b b7              ; 
             jr       z,skipc925           ; $c91c 28 07           ; 
             xor      a,a                  ; $c91e af              ; 
             ld       (hl),a               ; $c91f 77              ; 
             ld       a,$bb                ; $c920 3e bb           ; 
             call     lcd_cmd_simple       ; $c922 cd 28 e4        ; 
skipc925:    xor      a,a                  ; $c925 af              ; 
             di                            ; $c926 f3              ; 
             call     key_translate        ; $c927 cd 7d c2        ; 
             ei                            ; $c92a fb              ; 
             scf                           ; $c92b 37              ; 
             ccf                           ; $c92c 3f              ; 
             jr       kbd_read_epilogue    ; $c92d 18 d7           ; 

;
; Top-level LCD co-processor submit.  Stores C to $026D, calls
; lcd_trigger (sends parameter block start + $026C|$80 to hardware),
; then calls lcd_send_data (sends draw mode byte and X/Y payload).
; Waits for $020F to become 0 (cleared by interrupt when done).
; Also checks $0023 (pending redraw flag); if set, resubmits.
;
lcd_submit:  push     af                   ; $c92f f5              ; 
             ld       a,c                  ; $c930 79              ; 
             ld       ($026d),a            ; $c931 32 6d 02        ; 
             call     lcd_trigger          ; $c934 cd 77 c9        ; 
             pop      af                   ; $c937 f1              ; 
             call     lcd_send_data        ; $c938 cd 8f c9        ; 
             ld       a,($0023)            ; $c93b 3a 23 00        ; 
             or       a,a                  ; $c93e b7              ; 
             jr       z,lcd_submit_wait_reply_done ; $c93f 28 09           ; 
;
; Deferred-refresh retry path inside lcd_submit.
; Clears $0023, forces C=0, loads command $bc, and jumps back to the
; main submit entry so a postponed LCD refresh command is resent after
; the current fixed-length transaction finishes.
;
lcd_submit_refresh_retry: xor      a,a                  ; $c941 af              ; 
             ld       ($0023),a            ; $c942 32 23 00        ; 
             ld       c,a                  ; $c945 4f              ; 
             ld       a,$bc                ; $c946 3e bc           ; 
             jr       lcd_submit           ; $c948 18 e5           ; 

;
; Busy-wait tail for lcd_submit.
; Polls $020f until the interrupt-side fixed-length reply path has
; consumed the expected byte count.
;
lcd_submit_wait_reply_done: ld       a,($020f)            ; $c94a 3a 0f 02        ; 
             or       a,a                  ; $c94d b7              ; 
             jr       nz,lcd_submit_wait_reply_done ; $c94e 20 fa           ; 
             ret                           ; $c950 c9              ; 

;
; Alternate LCD submit path.
; Same transfer setup as lcd_submit, but after lcd_send_data it waits
; for the software counter at $026d to return to zero instead of
; waiting on $020f.  Used by command/reply transfers that count bytes
; through the interrupt-side receive paths.
;
lcd_submit_counted: push     af                   ; $c951 f5              ; 
             ld       a,c                  ; $c952 79              ; 
             ld       ($026d),a            ; $c953 32 6d 02        ; 
             xor      a,a                  ; $c956 af              ; 
             call     lcd_trigger          ; $c957 cd 77 c9        ; 
             pop      af                   ; $c95a f1              ; 
             call     lcd_send_data        ; $c95b cd 8f c9        ; 
;
; Busy-wait tail for lcd_submit_counted.
; Spins until the interrupt-side framed reply path clears $026d.
;
lcd_submit_counted_wait_frame_done: ld       a,($026d)            ; $c95e 3a 6d 02        ; 
             or       a,a                  ; $c961 b7              ; 
             jr       nz,lcd_submit_counted_wait_frame_done ; $c962 20 fa           ; 
;
; Post-frame refresh test inside lcd_submit_counted.
; Once the framed reply is complete it checks $0023, and if a refresh
; was deferred it clears the flag and sends command $bc through the
; simple LCD command wrapper before returning the accumulated count.
;
lcd_submit_counted_refresh_check: ld       a,($0023)            ; $c964 3a 23 00        ; 
             or       a,a                  ; $c967 b7              ; 
             jr       z,lcd_submit_counted_reply_count ; $c968 28 09           ; 
             xor      a,a                  ; $c96a af              ; 
             ld       ($0023),a            ; $c96b 32 23 00        ; 
             ld       a,$bc                ; $c96e 3e bc           ; 
             call     lcd_cmd_simple       ; $c970 cd 28 e4        ; 
;
; Return-value fetch for lcd_submit_counted.
; Loads A from $020f so callers can read the byte count accumulated by
; the $fe / $ff framed reply modes.
;
lcd_submit_counted_reply_count: ld       a,($020f)            ; $c973 3a 0f 02        ; 
             ret                           ; $c976 c9              ; 

;
; Initialise a graphics command transfer:
; store A to $020F (command ID),
; store DE to $0016 (parameter block pointer),
; set $0033 = $80 (transfer-in-progress flag),
; wait for LCD ready (lcd_wait_ready),
; load $026C, OR with $80, jump to jumpde97 (hardware trigger).
;
lcd_trigger: ld       ($020f),a            ; $c977 32 0f 02        ; 
             ld       ($0016),de           ; $c97a ed 53 16 00     ; 
             ld       a,$80                ; $c97e 3e 80           ; 
             ld       ($0033),a            ; $c980 32 33 00        ; 
             call     lcd_wait_ready       ; $c983 cd c0 c9        ; 
;
; Port-control commit inside lcd_trigger.
; Disables interrupts, reloads the shared $026c control byte, sets bit
; 7, and hands the updated value to io_ctrl_commit so the co-processor
; sees the foreground transfer request.
;
lcd_trigger_assert_busy: di                            ; $c986 f3              ; 
             ld       a,($026c)            ; $c987 3a 6c 02        ; 
             or       a,$80                ; $c98a f6 80           ; 
             jp       io_ctrl_commit       ; $c98c c3 97 de        ; 

;
; Send draw mode byte (in A) and coordinate payload to LCD:
; call lcd_out_byte (OUT $F1 ← A, OUT $F5 ← $02),
; wait ready, trigger again ($026C & $7F → jumpde97),
; if bit 7 of mode clear: loop B times outputting bytes from HL
; (streams X and Y from the parameter block at $026E),
; final wait, clear $0033.
;
lcd_send_data: call     lcd_out_byte         ; $c98f cd b2 c9        ; 
             push     af                   ; $c992 f5              ; 
             call     lcd_wait_ready       ; $c993 cd c0 c9        ; 
;
; Second port-control commit inside lcd_send_data.
; After the command byte has been written it reloads $026c, clears bit
; 7, and commits the value through io_ctrl_commit before deciding
; whether a parameter block still needs to be streamed.
;
lcd_send_clear_busy_bit: di                            ; $c996 f3              ; 
             ld       a,($026c)            ; $c997 3a 6c 02        ; 
             and      a,$7f                ; $c99a e6 7f           ; 
             call     io_ctrl_commit       ; $c99c cd 97 de        ; 
;
; Mode-byte test inside lcd_send_data.
; Restores the original command/mode byte, rotates bit 7 into carry,
; and either skips the payload stream or drops into
; lcd_send_param_block for the staged parameter bytes.
;
lcd_send_mode_dispatch: pop      af                   ; $c99f f1              ; 
             rlca                          ; $c9a0 07              ; 
             jr       c,lcd_send_release_busy ; $c9a1 38 07           ; 
;
; Parameter streaming loop inside lcd_send_data.
; Sends B bytes from HL (normally the staged block at $026e+) when
; the command mode byte does not suppress payload transfer.
;
lcd_send_param_block: ld       a,(hl)               ; $c9a3 7e              ; 
             call     lcd_out_byte         ; $c9a4 cd b2 c9        ; 
             inc      hl                   ; $c9a7 23              ; 
             djnz     lcd_send_param_block ; $c9a8 10 f9           ; 
;
; Final handshake tail for lcd_send_data.
; Waits for controller ready once more, then clears the
; transfer-in-progress flag at $0033.
;
lcd_send_release_busy: call     lcd_wait_ready       ; $c9aa cd c0 c9        ; 
             xor      a,a                  ; $c9ad af              ; 
             ld       ($0033),a            ; $c9ae 32 33 00        ; 
             ret                           ; $c9b1 c9              ; 

;
; Wait for LCD controller ready (lcd_wait_ready),
; OUT ($F1), A  — write data byte,
; OUT ($F5), $02 — write command byte $02.
;
lcd_out_byte: push     af                   ; $c9b2 f5              ; 
             call     lcd_wait_ready       ; $c9b3 cd c0 c9        ; 
             pop      af                   ; $c9b6 f1              ; 
             push     af                   ; $c9b7 f5              ; 
             out      ($f1),a              ; $c9b8 d3 f1           ; 
             ld       a,$02                ; $c9ba 3e 02           ; 
             out      ($f5),a              ; $c9bc d3 f5           ; 
             pop      af                   ; $c9be f1              ; 
             ret                           ; $c9bf c9              ; 

;
; Spin-wait: IN A,($F2); AND $02; JR Z,loop — polls bit 1 of
; LCD status port $F2 until the controller signals ready.
;
lcd_wait_ready: in       a,($f2)              ; $c9c0 db f2           ; 
             and      a,$02                ; $c9c2 e6 02           ; 
             jr       z,lcd_wait_ready     ; $c9c4 28 fa           ; 
             ret                           ; $c9c6 c9              ; 

;
; ============================================================
; RST handler routines
; ============================================================
; RST $18 handler — test I/O channel status byte at $044E.
; Returns Z if $044E is zero (channel idle / not active).
; Returns NZ with A = $FF if bit 7 of $044E is set.
; Returns NZ with A = 1 if $044E is non-zero but bit 7 is clear.
; The $2F byte at $C9D1 (CPL opcode) is dead; it is skipped by the
; JR at $C9CF and was left from an earlier variant of the function.
;
rst18_io_channel_status: ld       a,($044e)            ; $c9c7 3a 4e 04        ; 
             or       a,a                  ; $c9ca b7              ; 
             ret      z                    ; $c9cb c8              ; 

             ld       a,($044e)            ; $c9cc 3a 4e 04        ; 
             jr       skipc9d2             ; $c9cf 18 01           ; 

             defb     $2f                                          ; /          ; 
skipc9d2:    rla                           ; $c9d2 17              ; 
jumpc9d3:    sbc      a,a                  ; $c9d3 9f              ; 
             ret      nz                   ; $c9d4 c0              ; 

             inc      a                    ; $c9d5 3c              ; 
             ret                           ; $c9d6 c9              ; 

jumpc9d7:    xor      a,a                  ; $c9d7 af              ; 
             ld       ($044e),a            ; $c9d8 32 4e 04        ; 
             ret                           ; $c9db c9              ; 

;
; fn_abs — ABS function
; ABS(expr) — returns the absolute value of expr.
; Calls callc9fb (RST $30: evaluate float; error on
; zero); RET P: returns immediately if already positive.
; If negative, falls into callc9e0 then jumpc9e7 which
; flips bit 7 of the sign/exponent byte at $044e
; (XOR $80), converting the negative value to positive.
;
fn_abs:      call     callc9fb             ; $c9dc cd fb c9        ; 
             ret      p                    ; $c9df f0              ; 

jumpc9e0:    rst      rst0030              ; $c9e0 f7              ; 
             jp       m,num_negate_current_int_or_flag_minint ; $c9e1 fa 86 cd        ; 
             jp       z,basic_raise_error_0d ; $c9e4 ca c5 f1        ; 
callc9e7:    ld       hl,$044e             ; $c9e7 21 4e 04        ; 
             ld       a,(hl)               ; $c9ea 7e              ; 
             or       a,a                  ; $c9eb b7              ; 
             ret      z                    ; $c9ec c8              ; 

             xor      a,$80                ; $c9ed ee 80           ; 
             ld       (hl),a               ; $c9ef 77              ; 
             ret                           ; $c9f0 c9              ; 

;
; fn_sgn — SGN function
; SGN(expr) — returns the sign of expr as an integer:
; −1 if expr < 0, 0 if expr = 0, +1 if expr > 0.
; Calls callc9fb (RST $30: evaluate float).  On return,
; A contains the sign/exponent byte.  Falls into
; callc9f4: LD L,A; RLA; SBC A,A; LD H,A.
; The RLA/SBC pattern sign-extends the sign bit: if A
; had bit 7 set (negative), HL = $FFFF (−1); if A = 0,
; HL = $0000 (0).  JP callcaef returns HL as integer.
; The +1 case for positive non-zero is handled inside
; callc9fb which jumps directly into the RST $18 result
; channel.
; 
; ; ============================================================
; ; CINT and INT handlers
; ; ============================================================
;
fn_sgn:      call     callc9fb             ; $c9f1 cd fb c9        ; 
callc9f4:    ld       l,a                  ; $c9f4 6f              ; 
             rla                           ; $c9f5 17              ; 
             sbc      a,a                  ; $c9f6 9f              ; 
             ld       h,a                  ; $c9f7 67              ; 
             jp       num_store_int_result ; $c9f8 c3 ef ca        ; 

callc9fb:    rst      rst0030              ; $c9fb f7              ; 
             jp       z,basic_raise_error_0d ; $c9fc ca c5 f1        ; 
             jp       p,rst18_io_channel_status ; $c9ff f2 c7 c9        ; 
             ld       hl,($0450)           ; $ca02 2a 50 04        ; 
callca05:    ld       a,h                  ; $ca05 7c              ; 
             or       a,l                  ; $ca06 b5              ; 
             ret      z                    ; $ca07 c8              ; 

             ld       a,h                  ; $ca08 7c              ; 
             jr       skipc9d2             ; $ca09 18 c7           ; 

callca0b:    ex       de,hl                ; $ca0b eb              ; 
             ld       hl,($0450)           ; $ca0c 2a 50 04        ; 
             ex       (sp),hl              ; $ca0f e3              ; 
             push     hl                   ; $ca10 e5              ; 
             ld       hl,($044e)           ; $ca11 2a 4e 04        ; 
             ex       (sp),hl              ; $ca14 e3              ; 
             push     hl                   ; $ca15 e5              ; 
             ex       de,hl                ; $ca16 eb              ; 
             ret                           ; $ca17 c9              ; 

             defb     $cd,$39,$ca                                  ; .9.        ; 
callca1b:    ex       de,hl                ; $ca1b eb              ; 
             ld       ($0450),hl           ; $ca1c 22 50 04        ; 
             ld       h,b                  ; $ca1f 60              ; 
             ld       l,c                  ; $ca20 69              ; 
             ld       ($044e),hl           ; $ca21 22 4e 04        ; 
             ex       de,hl                ; $ca24 eb              ; 
             ret                           ; $ca25 c9              ; 

callca26:    ld       hl,($0450)           ; $ca26 2a 50 04        ; 
             ex       de,hl                ; $ca29 eb              ; 
             ld       hl,($044e)           ; $ca2a 2a 4e 04        ; 
             ld       c,l                  ; $ca2d 4d              ; 
             ld       b,h                  ; $ca2e 44              ; 
             ret                           ; $ca2f c9              ; 

callca30:    ld       c,(hl)               ; $ca30 4e              ; 
             inc      hl                   ; $ca31 23              ; 
callca32:    ld       b,(hl)               ; $ca32 46              ; 
             inc      hl                   ; $ca33 23              ; 
             ld       e,(hl)               ; $ca34 5e              ; 
             inc      hl                   ; $ca35 23              ; 
             ld       d,(hl)               ; $ca36 56              ; 
             inc      hl                   ; $ca37 23              ; 
             ret                           ; $ca38 c9              ; 

callca39:    ld       e,(hl)               ; $ca39 5e              ; 
             inc      hl                   ; $ca3a 23              ; 
callca3b:    ld       d,(hl)               ; $ca3b 56              ; 
             inc      hl                   ; $ca3c 23              ; 
             ld       c,(hl)               ; $ca3d 4e              ; 
             inc      hl                   ; $ca3e 23              ; 
             ld       b,(hl)               ; $ca3f 46              ; 
callca40:    inc      hl                   ; $ca40 23              ; 
             ret                           ; $ca41 c9              ; 

callca42:    ld       de,$044e             ; $ca42 11 4e 04        ; 
callca45:    ld       b,$04                ; $ca45 06 04           ; 
             jr       callca51             ; $ca47 18 08           ; 

callca49:    ld       de,$049f             ; $ca49 11 9f 04        ; 
             ex       de,hl                ; $ca4c eb              ; 
callca4d:    ld       a,($01d9)            ; $ca4d 3a d9 01        ; 
             ld       b,a                  ; $ca50 47              ; 
callca51:    ld       a,(de)               ; $ca51 1a              ; 
             ld       (hl),a               ; $ca52 77              ; 
             inc      de                   ; $ca53 13              ; 
             inc      hl                   ; $ca54 23              ; 
             djnz     callca51             ; $ca55 10 fa           ; 
             ret                           ; $ca57 c9              ; 

callca58:    ld       a,(de)               ; $ca58 1a              ; 
             ld       (hl),a               ; $ca59 77              ; 
             dec      de                   ; $ca5a 1b              ; 
             dec      hl                   ; $ca5b 2b              ; 
             djnz     callca58             ; $ca5c 10 fa           ; 
             ret                           ; $ca5e c9              ; 

jumpca5f:    ld       hl,$049f             ; $ca5f 21 9f 04        ; 
callca62:    ld       de,$ca4c             ; $ca62 11 4c ca        ; 
             jr       skipca6d             ; $ca65 18 06           ; 

callca67:    ld       hl,$049f             ; $ca67 21 9f 04        ; 
callca6a:    ld       de,callca4d          ; $ca6a 11 4d ca        ; 
skipca6d:    push     de                   ; $ca6d d5              ; 
             ld       de,$044e             ; $ca6e 11 4e 04        ; 
             ld       a,($01d9)            ; $ca71 3a d9 01        ; 
             cp       a,$02                ; $ca74 fe 02           ; 
             ret      nz                   ; $ca76 c0              ; 

             ld       de,$0450             ; $ca77 11 50 04        ; 
             ret                           ; $ca7a c9              ; 

callca7b:    ld       a,c                  ; $ca7b 79              ; 
             or       a,a                  ; $ca7c b7              ; 
             jp       z,rst18_io_channel_status ; $ca7d ca c7 c9        ; 
             ld       hl,$c9d1             ; $ca80 21 d1 c9        ; 
             push     hl                   ; $ca83 e5              ; 
             rst      rst0018              ; $ca84 df              ; 
             ld       a,c                  ; $ca85 79              ; 
             ret      z                    ; $ca86 c8              ; 

             ld       hl,$044e             ; $ca87 21 4e 04        ; 
             xor      a,(hl)               ; $ca8a ae              ; 
             ld       a,c                  ; $ca8b 79              ; 
             ret      m                    ; $ca8c f8              ; 

             call     callca93             ; $ca8d cd 93 ca        ; 
             rra                           ; $ca90 1f              ; 
             xor      a,c                  ; $ca91 a9              ; 
             ret                           ; $ca92 c9              ; 

callca93:    ld       a,c                  ; $ca93 79              ; 
             cp       a,(hl)               ; $ca94 be              ; 
             ret      nz                   ; $ca95 c0              ; 

             inc      hl                   ; $ca96 23              ; 
             ld       a,b                  ; $ca97 78              ; 
             cp       a,(hl)               ; $ca98 be              ; 
             ret      nz                   ; $ca99 c0              ; 

             inc      hl                   ; $ca9a 23              ; 
             ld       a,e                  ; $ca9b 7b              ; 
             cp       a,(hl)               ; $ca9c be              ; 
             ret      nz                   ; $ca9d c0              ; 

             inc      hl                   ; $ca9e 23              ; 
             ld       a,d                  ; $ca9f 7a              ; 
             sub      a,(hl)               ; $caa0 96              ; 
             ret      nz                   ; $caa1 c0              ; 

             pop      hl                   ; $caa2 e1              ; 
             pop      hl                   ; $caa3 e1              ; 
             ret                           ; $caa4 c9              ; 

;
; Shared signed 16-bit compare helper.  Compares HL against DE and
; returns through the common $C9D3 compare-result tail: Z if equal,
; otherwise the usual signed non-zero result in A.  Used by integer
; FOR/NEXT limit checks and other integer comparison paths.
;
int16_compare_hl_de: ld       a,d                  ; $caa5 7a              ; 
             xor      a,h                  ; $caa6 ac              ; 
             ld       a,h                  ; $caa7 7c              ; 
             jp       m,skipc9d2           ; $caa8 fa d2 c9        ; 
             cp       a,d                  ; $caab ba              ; 
             jr       nz,skipcab1          ; $caac 20 03           ; 
             ld       a,l                  ; $caae 7d              ; 
             sub      a,e                  ; $caaf 93              ; 
             ret      z                    ; $cab0 c8              ; 

skipcab1:    jp       jumpc9d3             ; $cab1 c3 d3 c9        ; 

;
; Shared floating-point compare helper.  Compares the work FP value
; at $049f against the active accumulator at $044e, first handling
; zero/sign cases and then comparing the mantissa bytes.  Returns by
; the same compare convention as $C9D3 / RST $18.
;
fp_compare_work_and_main: ld       de,$049f             ; $cab4 11 9f 04        ; 
             ld       a,(de)               ; $cab7 1a              ; 
             or       a,a                  ; $cab8 b7              ; 
             jp       z,rst18_io_channel_status ; $cab9 ca c7 c9        ; 
             ld       hl,$c9d1             ; $cabc 21 d1 c9        ; 
             push     hl                   ; $cabf e5              ; 
             rst      rst0018              ; $cac0 df              ; 
             ld       a,(de)               ; $cac1 1a              ; 
             ld       c,a                  ; $cac2 4f              ; 
             ret      z                    ; $cac3 c8              ; 

             ld       hl,$044e             ; $cac4 21 4e 04        ; 
             xor      a,(hl)               ; $cac7 ae              ; 
             ld       a,c                  ; $cac8 79              ; 
             ret      m                    ; $cac9 f8              ; 

             ld       b,$08                ; $caca 06 08           ; 
loopcacc:    ld       a,(de)               ; $cacc 1a              ; 
             sub      a,(hl)               ; $cacd 96              ; 
             jr       nz,skipcad6          ; $cace 20 06           ; 
             inc      de                   ; $cad0 13              ; 
             inc      hl                   ; $cad1 23              ; 
             djnz     loopcacc             ; $cad2 10 f8           ; 
             pop      bc                   ; $cad4 c1              ; 
             ret                           ; $cad5 c9              ; 

skipcad6:    rra                           ; $cad6 1f              ; 
             xor      a,c                  ; $cad7 a9              ; 
             ret                           ; $cad8 c9              ; 

             defb     $cd,$b4,$ca,$c2,$d1,$c9,$c9                  ; .......    ; 
;
; fn_cint — CINT function
; CINT(expr) — converts expr to the nearest 16-bit
; integer (rounds half away from zero).
; RST $30: evaluates expr as a floating-point number.
; Loads HL = ($0450) (FP accumulator).  RET M on
; overflow.  Calls callcbb3 to round and convert to a
; 16-bit signed integer.  JP C to $F1BC on overflow
; (result out of −32768..32767 range).
; Stores result via callcaef and sets device mode
; $01D9 = $02 (integer) before returning.
;
fn_cint:     rst      rst0030              ; $cae0 f7              ; 
             ld       hl,($0450)           ; $cae1 2a 50 04        ; 
             ret      m                    ; $cae4 f8              ; 

             jp       z,basic_raise_error_0d ; $cae5 ca c5 f1        ; 
             call     fp_to_int16          ; $cae8 cd b3 cb        ; 
             jp       c,basic_raise_error_06 ; $caeb da bc f1        ; 
             ex       de,hl                ; $caee eb              ; 
;
; Common integer-result tail.  Stores HL into the integer slot at
; $0450, then falls through to the shared result-type updater.
;
num_store_int_result: ld       ($0450),hl           ; $caef 22 50 04        ; 
;
; Loads type code $02 for an integer result before falling into the
; generic result-type store helper.
;
num_set_integer_type: ld       a,$02                ; $caf2 3e 02           ; 
;
; Shared type finaliser.  Stores A to the active result-type byte at
; $01d9 and returns.
;
num_store_result_type: ld       ($01d9),a            ; $caf4 32 d9 01        ; 
             ret                           ; $caf7 c9              ; 

;
; Numeric-literal `%` suffix edge-case helper.  Tests whether the
; parsed value is exactly the special integer constant −32768.  If
; so, loads HL = $8000 and routes straight to the integer-result
; store tail; otherwise returns NZ so the generic path can continue.
;
num_parse_minint_edge: ld       bc,$32c5             ; $caf8 01 c5 32        ; 
             ld       de,$8076             ; $cafb 11 76 80        ; 
             call     callca7b             ; $cafe cd 7b ca        ; 
             ret      nz                   ; $cb01 c0              ; 

             ld       hl,$8000             ; $cb02 21 00 80        ; 
;
; Small shared tail that discards one saved word from the stack and
; then jumps to num_store_int_result.  Used by integer fast paths
; that keep a temporary operand on the stack while computing HL.
;
num_pop_and_store_int_result: pop      de                   ; $cb05 d1              ; 
             jr       num_store_int_result ; $cb06 18 e7           ; 

;
; fn_csng — CSNG function
; CSNG(expr) — convert numeric value to single-precision float.
; RST $30: evaluate expr as floating-point value.
; RET PO: return immediately if overflow flag not set (no
; conversion needed; value already single-precision).
; JP M, callcb1e: if the exponent indicates very small
; magnitude, load the FP accumulator from ($0450).
; JP Z, jumpf1c5: error on zero exponent.
; CALL callcba9: set precision byte to $04 (single).
; CALL callbee1: normalise mantissa to 4-byte single
; precision format.
; Adjusts the exponent and mantissa via INC HL / RRA;
; JP jumpb2b6 to complete the conversion.
;
fn_csng:     rst      rst0030              ; $cb08 f7              ; 
             ret      po                   ; $cb09 e0              ; 

             jp       m,fp_load_int_accumulator ; $cb0a fa 1e cb        ; 
             jp       z,basic_raise_error_0d ; $cb0d ca c5 f1        ; 
             call     fp_set_single_precision ; $cb10 cd a9 cb        ; 
             call     callbee1             ; $cb13 cd e1 be        ; 
             inc      hl                   ; $cb16 23              ; 
             ld       a,b                  ; $cb17 78              ; 
             or       a,a                  ; $cb18 b7              ; 
             rra                           ; $cb19 1f              ; 
             ld       b,a                  ; $cb1a 47              ; 
             jp       jumpb2b6             ; $cb1b c3 b6 b2        ; 

;
; Load the signed 16-bit integer cached at $0450 and convert it into
; the floating accumulator layout.  Shared by CSNG/CDBL promotion and
; by numeric-literal paths that overflow the inline integer builder.
;
fp_load_int_accumulator: ld       hl,($0450)           ; $cb1e 2a 50 04        ; 
callcb21:    ld       a,h                  ; $cb21 7c              ; 
jumpcb22:    or       a,a                  ; $cb22 b7              ; 
             push     af                   ; $cb23 f5              ; 
             call     m,num_negate_hl_store_int ; $cb24 fc 7c cd        ; 
             call     fp_set_single_precision ; $cb27 cd a9 cb        ; 
             ex       de,hl                ; $cb2a eb              ; 
             ld       hl,$0000             ; $cb2b 21 00 00        ; 
             ld       ($044e),hl           ; $cb2e 22 4e 04        ; 
             ld       ($0450),hl           ; $cb31 22 50 04        ; 
             ld       a,d                  ; $cb34 7a              ; 
             or       a,e                  ; $cb35 b3              ; 
             jp       z,jumpd5db           ; $cb36 ca db d5        ; 
             ld       bc,$0500             ; $cb39 01 00 05        ; 
             ld       hl,$044f             ; $cb3c 21 4f 04        ; 
             push     hl                   ; $cb3f e5              ; 
             ld       hl,$cb86             ; $cb40 21 86 cb        ; 
loopcb43:    ld       a,$ff                ; $cb43 3e ff           ; 
             push     de                   ; $cb45 d5              ; 
             ld       e,(hl)               ; $cb46 5e              ; 
             inc      hl                   ; $cb47 23              ; 
             ld       d,(hl)               ; $cb48 56              ; 
             inc      hl                   ; $cb49 23              ; 
             ex       (sp),hl              ; $cb4a e3              ; 
             push     bc                   ; $cb4b c5              ; 
loopcb4c:    ld       b,h                  ; $cb4c 44              ; 
             ld       c,l                  ; $cb4d 4d              ; 
             add      hl,de                ; $cb4e 19              ; 
             inc      a                    ; $cb4f 3c              ; 
             jr       c,loopcb4c           ; $cb50 38 fa           ; 
             ld       h,b                  ; $cb52 60              ; 
             ld       l,c                  ; $cb53 69              ; 
             pop      bc                   ; $cb54 c1              ; 
             pop      de                   ; $cb55 d1              ; 
             ex       de,hl                ; $cb56 eb              ; 
             inc      c                    ; $cb57 0c              ; 
             dec      c                    ; $cb58 0d              ; 
             jr       nz,skipcb66          ; $cb59 20 0b           ; 
             or       a,a                  ; $cb5b b7              ; 
             jr       z,skipcb7a           ; $cb5c 28 1c           ; 
             push     af                   ; $cb5e f5              ; 
             ld       a,$40                ; $cb5f 3e 40           ; 
             add      a,b                  ; $cb61 80              ; 
             ld       ($044e),a            ; $cb62 32 4e 04        ; 
             pop      af                   ; $cb65 f1              ; 
skipcb66:    inc      c                    ; $cb66 0c              ; 
             ex       (sp),hl              ; $cb67 e3              ; 
             push     af                   ; $cb68 f5              ; 
             ld       a,c                  ; $cb69 79              ; 
             rra                           ; $cb6a 1f              ; 
             jr       nc,skipcb75          ; $cb6b 30 08           ; 
             pop      af                   ; $cb6d f1              ; 
             add      a,a                  ; $cb6e 87              ; 
             add      a,a                  ; $cb6f 87              ; 
             add      a,a                  ; $cb70 87              ; 
             add      a,a                  ; $cb71 87              ; 
             ld       (hl),a               ; $cb72 77              ; 
             jr       skipcb79             ; $cb73 18 04           ; 

skipcb75:    pop      af                   ; $cb75 f1              ; 
             or       a,(hl)               ; $cb76 b6              ; 
             ld       (hl),a               ; $cb77 77              ; 
             inc      hl                   ; $cb78 23              ; 
skipcb79:    ex       (sp),hl              ; $cb79 e3              ; 
skipcb7a:    ld       a,d                  ; $cb7a 7a              ; 
             or       a,e                  ; $cb7b b3              ; 
             jr       z,skipcb80           ; $cb7c 28 02           ; 
             djnz     loopcb43             ; $cb7e 10 c3           ; 
skipcb80:    pop      hl                   ; $cb80 e1              ; 
             pop      af                   ; $cb81 f1              ; 
             ret      p                    ; $cb82 f0              ; 

             jp       callc9e7             ; $cb83 c3 e7 c9        ; 

             defb     $f0,$d8,$18,$fc,$9c,$ff,$f6,$ff,$ff,$ff      ; .......... ; 
;
; fn_cdbl — CDBL function
; CDBL(expr) — convert numeric value to double-precision float.
; RST $30: evaluate expr as floating-point value.
; RET NC: return if no carry (already double-precision).
; JP Z, jumpf1c5: error on zero exponent.
; CALL M, callcb1e: load FP accumulator if negative exponent.
; Zeroes the three extra mantissa words at $0452, $0454,
; and $0456 (extending single-precision mantissa to double)
; via LD HL,$0000; LD ($0452),HL; LD ($0454),HL; LD ($0456),A.
; Continues into callcba5 to set precision byte to $08
; (double) and jump to jumpcaf4 to finalise.
; 
; ; ============================================================
; ; FIX handler ($CC14)
; ; ============================================================
;
fn_cdbl:     rst      rst0030              ; $cb90 f7              ; 
             ret      nc                   ; $cb91 d0              ; 

             jp       z,basic_raise_error_0d ; $cb92 ca c5 f1        ; 
             call     m,fp_load_int_accumulator ; $cb95 fc 1e cb        ; 
;
; Clears the extension words at $0452-$0456 before building or
; promoting a floating-point result.
;
fp_clear_extended_mantissa: ld       hl,$0000             ; $cb98 21 00 00        ; 
             ld       ($0452),hl           ; $cb9b 22 52 04        ; 
             ld       ($0454),hl           ; $cb9e 22 54 04        ; 
             ld       a,h                  ; $cba1 7c              ; 
             ld       ($0456),a            ; $cba2 32 56 04        ; 
;
; Loads type code $08 and falls into jumpcaf4 so the current
; accumulator is tagged as double precision.
;
fp_set_double_precision: ld       a,$08                ; $cba5 3e 08           ; 
             jr       skipcbab             ; $cba7 18 02           ; 

;
; Loads type code $04 and falls into jumpcaf4 so the current
; accumulator is tagged as single precision.
; 
; ; ============================================================
; ; CDBL handler ($CB90)
; ; ============================================================
;
fp_set_single_precision: ld       a,$04                ; $cba9 3e 04           ; 
skipcbab:    jp       num_store_result_type ; $cbab c3 f4 ca        ; 

;
; ----
; str_require_string — evaluate expression and require string type
; ----
; RST $30 expression bridge used by LEN, ASC, VAL, MID$, and related
; helpers. Returns only when the current expression result is a string
; descriptor in $0450; otherwise raises type mismatch.
;
str_require_string: rst      rst0030              ; $cbae f7              ; 
             ret      z                    ; $cbaf c8              ; 

             jp       basic_raise_error_0d ; $cbb0 c3 c5 f1        ; 

;
; ----
; fp_to_int16 — convert floating-point accumulator to signed 16-bit integer
; ----
; Shared integer bridge used by CINT and parsing helpers. Validates the
; exponent range, shifts the mantissa down to integer form, and returns
; DE = converted value.
;
fp_to_int16: ld       hl,$cc10             ; $cbb3 21 10 cc        ; 
             push     hl                   ; $cbb6 e5              ; 
             ld       hl,$044e             ; $cbb7 21 4e 04        ; 
             ld       a,(hl)               ; $cbba 7e              ; 
             and      a,$7f                ; $cbbb e6 7f           ; 
             cp       a,$46                ; $cbbd fe 46           ; 
             ret      nc                   ; $cbbf d0              ; 

             sub      a,$41                ; $cbc0 d6 41           ; 
             jr       nc,skipcbca          ; $cbc2 30 06           ; 
             or       a,a                  ; $cbc4 b7              ; 
             pop      de                   ; $cbc5 d1              ; 
             ld       de,$0000             ; $cbc6 11 00 00        ; 
             ret                           ; $cbc9 c9              ; 

skipcbca:    inc      a                    ; $cbca 3c              ; 
             ld       b,a                  ; $cbcb 47              ; 
             ld       de,$0000             ; $cbcc 11 00 00        ; 
             ld       c,d                  ; $cbcf 4a              ; 
             inc      hl                   ; $cbd0 23              ; 
loopcbd1:    ld       a,c                  ; $cbd1 79              ; 
             inc      c                    ; $cbd2 0c              ; 
             rra                           ; $cbd3 1f              ; 
             ld       a,(hl)               ; $cbd4 7e              ; 
             jr       c,skipcbdd           ; $cbd5 38 06           ; 
             rra                           ; $cbd7 1f              ; 
             rra                           ; $cbd8 1f              ; 
             rra                           ; $cbd9 1f              ; 
             rra                           ; $cbda 1f              ; 
             jr       skipcbde             ; $cbdb 18 01           ; 

skipcbdd:    inc      hl                   ; $cbdd 23              ; 
skipcbde:    and      a,$0f                ; $cbde e6 0f           ; 
             ld       ($0448),hl           ; $cbe0 22 48 04        ; 
             ld       h,d                  ; $cbe3 62              ; 
             ld       l,e                  ; $cbe4 6b              ; 
             add      hl,hl                ; $cbe5 29              ; 
             ret      c                    ; $cbe6 d8              ; 

             add      hl,hl                ; $cbe7 29              ; 
             ret      c                    ; $cbe8 d8              ; 

             add      hl,de                ; $cbe9 19              ; 
             ret      c                    ; $cbea d8              ; 

             add      hl,hl                ; $cbeb 29              ; 
             ret      c                    ; $cbec d8              ; 

             ld       e,a                  ; $cbed 5f              ; 
             ld       d,$00                ; $cbee 16 00           ; 
             add      hl,de                ; $cbf0 19              ; 
             ret      c                    ; $cbf1 d8              ; 

             ex       de,hl                ; $cbf2 eb              ; 
             ld       hl,($0448)           ; $cbf3 2a 48 04        ; 
             djnz     loopcbd1             ; $cbf6 10 d9           ; 
             ld       hl,$8000             ; $cbf8 21 00 80        ; 
             rst      rst0020              ; $cbfb e7              ; 
             ld       a,($044e)            ; $cbfc 3a 4e 04        ; 
             ret      c                    ; $cbff d8              ; 

             jr       z,skipcc0c           ; $cc00 28 0a           ; 
             pop      hl                   ; $cc02 e1              ; 
             or       a,a                  ; $cc03 b7              ; 
             ret      p                    ; $cc04 f0              ; 

             ex       de,hl                ; $cc05 eb              ; 
             call     num_negate_hl_store_int ; $cc06 cd 7c cd        ; 
             ex       de,hl                ; $cc09 eb              ; 
             or       a,a                  ; $cc0a b7              ; 
             ret                           ; $cc0b c9              ; 

skipcc0c:    or       a,a                  ; $cc0c b7              ; 
             ret      p                    ; $cc0d f0              ; 

             pop      hl                   ; $cc0e e1              ; 
             ret                           ; $cc0f c9              ; 

             defb     $37,$c9                                      ; 7.         ; 
callcc12:    dec      bc                   ; $cc12 0b              ; 
             ret                           ; $cc13 c9              ; 

;
; fn_fix — FIX function
; FIX(expr) — truncate toward zero (unlike INT which
; truncates toward negative infinity).
; RST $30: evaluate expr as floating-point.
; RET M: return if already a pure integer (zero fraction).
; RST $18: test the sign of the value.
; JP P, fn_int: if positive (or zero), FIX equals INT —
; jump directly to the INT handler.
; For negative values: CALL $C9E7 (negate), CALL fn_int
; (truncate toward −∞ on the now-positive value), then
; JP $C9E0 (negate back), yielding −INT(−x) = FIX(x).
; 
; ; ============================================================
; ; CSRLIN handler ($CEAF)
; ; ============================================================
;
fn_fix:      rst      rst0030              ; $cc14 f7              ; 
             ret      m                    ; $cc15 f8              ; 

             rst      rst0018              ; $cc16 df              ; 
             jp       p,fn_int             ; $cc17 f2 23 cc        ; 
             call     callc9e7             ; $cc1a cd e7 c9        ; 
             call     fn_int               ; $cc1d cd 23 cc        ; 
             jp       jumpc9e0             ; $cc20 c3 e0 c9        ; 

;
; fn_int — INT function
; INT(expr) — returns the largest integer ≤ expr
; (floor toward negative infinity).
; RST $30: evaluates expr as floating point; RET M if
; the exponent already indicates a pure integer (no
; fractional part).  Selects the mantissa region
; ($0452–$0455 for double, or $0456–$0458 for single
; precision) and zeroes the fractional mantissa
; nibbles/bytes, truncating toward −∞.
; The result is left as a floating-point integer.
;
fn_int:      rst      rst0030              ; $cc23 f7              ; 
             ret      m                    ; $cc24 f8              ; 

             ld       hl,$0456             ; $cc25 21 56 04        ; 
             ld       c,$0e                ; $cc28 0e 0e           ; 
             jr       nc,skipcc34          ; $cc2a 30 08           ; 
             jp       z,basic_raise_error_0d ; $cc2c ca c5 f1        ; 
             ld       hl,$0452             ; $cc2f 21 52 04        ; 
             ld       c,$06                ; $cc32 0e 06           ; 
skipcc34:    ld       a,($044e)            ; $cc34 3a 4e 04        ; 
             or       a,a                  ; $cc37 b7              ; 
             jp       m,jumpcc54           ; $cc38 fa 54 cc        ; 
             and      a,$7f                ; $cc3b e6 7f           ; 
             sub      a,$41                ; $cc3d d6 41           ; 
             jp       c,jumpc9d7           ; $cc3f da d7 c9        ; 
             inc      a                    ; $cc42 3c              ; 
             sub      a,c                  ; $cc43 91              ; 
             ret      nc                   ; $cc44 d0              ; 

             cpl                           ; $cc45 2f              ; 
             inc      a                    ; $cc46 3c              ; 
             ld       b,a                  ; $cc47 47              ; 
loopcc48:    dec      hl                   ; $cc48 2b              ; 
             ld       a,(hl)               ; $cc49 7e              ; 
             and      a,$f0                ; $cc4a e6 f0           ; 
             ld       (hl),a               ; $cc4c 77              ; 
             dec      b                    ; $cc4d 05              ; 
             ret      z                    ; $cc4e c8              ; 

             xor      a,a                  ; $cc4f af              ; 
             ld       (hl),a               ; $cc50 77              ; 
             djnz     loopcc48             ; $cc51 10 f5           ; 
             ret                           ; $cc53 c9              ; 

jumpcc54:    and      a,$7f                ; $cc54 e6 7f           ; 
             sub      a,$41                ; $cc56 d6 41           ; 
             jr       nc,skipcc60          ; $cc58 30 06           ; 
             ld       hl,$ffff             ; $cc5a 21 ff ff        ; 
             jp       num_store_int_result ; $cc5d c3 ef ca        ; 

skipcc60:    inc      a                    ; $cc60 3c              ; 
             sub      a,c                  ; $cc61 91              ; 
             ret      nc                   ; $cc62 d0              ; 

             cpl                           ; $cc63 2f              ; 
             inc      a                    ; $cc64 3c              ; 
             ld       b,a                  ; $cc65 47              ; 
             ld       e,$00                ; $cc66 1e 00           ; 
loopcc68:    dec      hl                   ; $cc68 2b              ; 
             ld       a,(hl)               ; $cc69 7e              ; 
             ld       d,a                  ; $cc6a 57              ; 
             and      a,$f0                ; $cc6b e6 f0           ; 
             ld       (hl),a               ; $cc6d 77              ; 
             cp       a,d                  ; $cc6e ba              ; 
             jr       z,skipcc72           ; $cc6f 28 01           ; 
             inc      e                    ; $cc71 1c              ; 
skipcc72:    dec      b                    ; $cc72 05              ; 
             jr       z,skipcc7d           ; $cc73 28 08           ; 
             xor      a,a                  ; $cc75 af              ; 
             ld       (hl),a               ; $cc76 77              ; 
             cp       a,d                  ; $cc77 ba              ; 
             jr       z,skipcc7b           ; $cc78 28 01           ; 
             inc      e                    ; $cc7a 1c              ; 
skipcc7b:    djnz     loopcc68             ; $cc7b 10 eb           ; 
skipcc7d:    inc      e                    ; $cc7d 1c              ; 
             dec      e                    ; $cc7e 1d              ; 
             ret      z                    ; $cc7f c8              ; 

             ld       a,c                  ; $cc80 79              ; 
             cp       a,$06                ; $cc81 fe 06           ; 
             ld       bc,$10c1             ; $cc83 01 c1 10        ; 
             ld       de,$0000             ; $cc86 11 00 00        ; 
             jp       z,fp_add_int_work_operands ; $cc89 ca a9 cd        ; 
             ex       de,hl                ; $cc8c eb              ; 
             ld       ($04a5),hl           ; $cc8d 22 a5 04        ; 
             ld       ($04a3),hl           ; $cc90 22 a3 04        ; 
             ld       ($04a1),hl           ; $cc93 22 a1 04        ; 
             ld       h,b                  ; $cc96 60              ; 
             ld       l,c                  ; $cc97 69              ; 
             ld       ($049f),hl           ; $cc98 22 9f 04        ; 
             jp       fp_add_work          ; $cc9b c3 0e b2        ; 

;
; Unsigned 16-bit shift/add multiply core.  Multiplies BC by DE into
; HL, raising overflow through the standard numeric-overflow path if
; the partial product carries out.  Used by the integer arithmetic
; bridge after sign handling has already been separated.
;
uint16_mul_bc_de: push     hl                   ; $cc9e e5              ; 
             ld       hl,$0000             ; $cc9f 21 00 00        ; 
             ld       a,b                  ; $cca2 78              ; 
             or       a,c                  ; $cca3 b1              ; 
             jr       z,skipccb8           ; $cca4 28 12           ; 
             ld       a,$10                ; $cca6 3e 10           ; 
loopcca8:    add      hl,hl                ; $cca8 29              ; 
             jp       c,loopb16d           ; $cca9 da 6d b1        ; 
             ex       de,hl                ; $ccac eb              ; 
             add      hl,hl                ; $ccad 29              ; 
             ex       de,hl                ; $ccae eb              ; 
             jr       nc,skipccb5          ; $ccaf 30 04           ; 
             add      hl,bc                ; $ccb1 09              ; 
             jp       c,loopb16d           ; $ccb2 da 6d b1        ; 
skipccb5:    dec      a                    ; $ccb5 3d              ; 
             jr       nz,loopcca8          ; $ccb6 20 f0           ; 
skipccb8:    ex       de,hl                ; $ccb8 eb              ; 
             pop      hl                   ; $ccb9 e1              ; 
             ret                           ; $ccba c9              ; 

             defb     $7c,$17,$9f,$47,$cd,$7c,$cd,$79,$98,$18      ; |..G.|.y.. ; 
             defb     $03                                          ; .          ; 
;
; Signed integer add helper.  Adds HL and DE, keeps the result as an
; integer when the signed sum fits in 16 bits, and otherwise promotes
; the operands through the floating-point bridge before continuing in
; the generic numeric add path.
;
num_add_int_or_promote: ld       a,h                  ; $ccc6 7c              ; 
             rla                           ; $ccc7 17              ; 
             sbc      a,a                  ; $ccc8 9f              ; 
             ld       b,a                  ; $ccc9 47              ; 
             push     hl                   ; $ccca e5              ; 
             ld       a,d                  ; $cccb 7a              ; 
             rla                           ; $cccc 17              ; 
             sbc      a,a                  ; $cccd 9f              ; 
             add      hl,de                ; $ccce 19              ; 
             adc      a,b                  ; $cccf 88              ; 
             rrca                          ; $ccd0 0f              ; 
             xor      a,h                  ; $ccd1 ac              ; 
             jp       p,num_pop_and_store_int_result ; $ccd2 f2 05 cb        ; 
             push     bc                   ; $ccd5 c5              ; 
             ex       de,hl                ; $ccd6 eb              ; 
             call     callcb21             ; $ccd7 cd 21 cb        ; 
             pop      af                   ; $ccda f1              ; 
             pop      hl                   ; $ccdb e1              ; 
             call     callca0b             ; $ccdc cd 0b ca        ; 
             call     callcb21             ; $ccdf cd 21 cb        ; 
             pop      bc                   ; $cce2 c1              ; 
             pop      de                   ; $cce3 d1              ; 
             jp       fp_add_int_work_operands ; $cce4 c3 a9 cd        ; 

;
; Signed integer multiply helper.  Handles the zero fast path, then
; converts both operands to absolute values, runs the shared integer
; multiply core, and reapplies the final sign.  If the exact product
; does not fit in 16 bits it promotes the operation to floating
; point.
;
num_mul_int_or_promote: ld       a,h                  ; $cce7 7c              ; 
             or       a,l                  ; $cce8 b5              ; 
             jp       z,num_store_int_result ; $cce9 ca ef ca        ; 
             push     hl                   ; $ccec e5              ; 
             push     de                   ; $cced d5              ; 
             call     num_separate_operand_signs ; $ccee cd 70 cd        ; 
             push     bc                   ; $ccf1 c5              ; 
             ld       b,h                  ; $ccf2 44              ; 
             ld       c,l                  ; $ccf3 4d              ; 
             ld       hl,$0000             ; $ccf4 21 00 00        ; 
             ld       a,$10                ; $ccf7 3e 10           ; 
loopccf9:    add      hl,hl                ; $ccf9 29              ; 
             jr       c,skipcd1a           ; $ccfa 38 1e           ; 
             ex       de,hl                ; $ccfc eb              ; 
             add      hl,hl                ; $ccfd 29              ; 
             ex       de,hl                ; $ccfe eb              ; 
             jr       nc,skipcd04          ; $ccff 30 03           ; 
             add      hl,bc                ; $cd01 09              ; 
             jr       c,skipcd1a           ; $cd02 38 16           ; 
skipcd04:    dec      a                    ; $cd04 3d              ; 
             jr       nz,loopccf9          ; $cd05 20 f2           ; 
             pop      bc                   ; $cd07 c1              ; 
             pop      de                   ; $cd08 d1              ; 
loopcd09:    ld       a,h                  ; $cd09 7c              ; 
             or       a,a                  ; $cd0a b7              ; 
             jp       m,jumpcd12           ; $cd0b fa 12 cd        ; 
             pop      de                   ; $cd0e d1              ; 
             ld       a,b                  ; $cd0f 78              ; 
             jr       loopcd78             ; $cd10 18 66           ; 

jumpcd12:    xor      a,$80                ; $cd12 ee 80           ; 
             or       a,l                  ; $cd14 b5              ; 
             jr       z,skipcd2b           ; $cd15 28 14           ; 
             ex       de,hl                ; $cd17 eb              ; 
             jr       skipcd1c             ; $cd18 18 02           ; 

skipcd1a:    pop      bc                   ; $cd1a c1              ; 
             pop      hl                   ; $cd1b e1              ; 
skipcd1c:    call     callcb21             ; $cd1c cd 21 cb        ; 
             pop      hl                   ; $cd1f e1              ; 
             call     callca0b             ; $cd20 cd 0b ca        ; 
             call     callcb21             ; $cd23 cd 21 cb        ; 
             pop      bc                   ; $cd26 c1              ; 
             pop      de                   ; $cd27 d1              ; 
             jp       fp_multiply_int_work_operands ; $cd28 c3 b7 cd        ; 

skipcd2b:    ld       a,b                  ; $cd2b 78              ; 
             or       a,a                  ; $cd2c b7              ; 
             pop      bc                   ; $cd2d c1              ; 
             jp       m,num_store_int_result ; $cd2e fa ef ca        ; 
             push     de                   ; $cd31 d5              ; 
             call     callcb21             ; $cd32 cd 21 cb        ; 
             pop      de                   ; $cd35 d1              ; 
             jp       callc9e7             ; $cd36 c3 e7 c9        ; 

;
; Signed integer divide helper.  Raises divide-by-zero when HL = 0,
; otherwise performs the integer long-division core with sign
; bookkeeping.  Exact in-range results return as integers; cases that
; need wider precision fall through to the floating-point divide path.
;
num_div_int_or_promote: ld       a,h                  ; $cd39 7c              ; 
             or       a,l                  ; $cd3a b5              ; 
             jp       z,basic_raise_error_0b ; $cd3b ca ad f1        ; 
             call     num_separate_operand_signs ; $cd3e cd 70 cd        ; 
             push     bc                   ; $cd41 c5              ; 
             ex       de,hl                ; $cd42 eb              ; 
             call     num_negate_hl_store_int ; $cd43 cd 7c cd        ; 
             ld       b,h                  ; $cd46 44              ; 
             ld       c,l                  ; $cd47 4d              ; 
             ld       hl,$0000             ; $cd48 21 00 00        ; 
             ld       a,$11                ; $cd4b 3e 11           ; 
             push     af                   ; $cd4d f5              ; 
             or       a,a                  ; $cd4e b7              ; 
             jr       skipcd5b             ; $cd4f 18 0a           ; 

loopcd51:    push     af                   ; $cd51 f5              ; 
             push     hl                   ; $cd52 e5              ; 
             add      hl,bc                ; $cd53 09              ; 
             jr       nc,skipcd5a          ; $cd54 30 04           ; 
             pop      af                   ; $cd56 f1              ; 
             scf                           ; $cd57 37              ; 
             jr       skipcd5b             ; $cd58 18 01           ; 

skipcd5a:    pop      hl                   ; $cd5a e1              ; 
skipcd5b:    ld       a,e                  ; $cd5b 7b              ; 
             rla                           ; $cd5c 17              ; 
             ld       e,a                  ; $cd5d 5f              ; 
             ld       a,d                  ; $cd5e 7a              ; 
             rla                           ; $cd5f 17              ; 
             ld       d,a                  ; $cd60 57              ; 
             ld       a,l                  ; $cd61 7d              ; 
             rla                           ; $cd62 17              ; 
             ld       l,a                  ; $cd63 6f              ; 
             ld       a,h                  ; $cd64 7c              ; 
             rla                           ; $cd65 17              ; 
             ld       h,a                  ; $cd66 67              ; 
             pop      af                   ; $cd67 f1              ; 
             dec      a                    ; $cd68 3d              ; 
             jr       nz,loopcd51          ; $cd69 20 e6           ; 
             ex       de,hl                ; $cd6b eb              ; 
             pop      bc                   ; $cd6c c1              ; 
             push     de                   ; $cd6d d5              ; 
             jr       loopcd09             ; $cd6e 18 99           ; 

;
; Shared signed-integer prep helper.  Captures the combined sign of HL
; and DE in B, then normalises both operands to positive magnitudes via
; the negation tail at $cd77/$cd7c so the multiply/divide cores can run
; on unsigned values.
;
num_separate_operand_signs: ld       a,h                  ; $cd70 7c              ; 
             xor      a,d                  ; $cd71 aa              ; 
             ld       b,a                  ; $cd72 47              ; 
             call     num_negate_hl_if_negative ; $cd73 cd 77 cd        ; 
             ex       de,hl                ; $cd76 eb              ; 
;
; Tail entry used by num_separate_operand_signs.  If HL is already
; non-negative it returns immediately; otherwise it falls into the
; shared two's-complement negation helper at $cd7c and stores the
; absolute value back as the current integer result.
;
num_negate_hl_if_negative: ld       a,h                  ; $cd77 7c              ; 
loopcd78:    or       a,a                  ; $cd78 b7              ; 
             jp       p,num_store_int_result ; $cd79 f2 ef ca        ; 
;
; Shared 16-bit integer negation helper.  Replaces HL with `-HL`,
; stores the result through num_store_int_result, and returns.
;
num_negate_hl_store_int: xor      a,a                  ; $cd7c af              ; 
             ld       c,a                  ; $cd7d 4f              ; 
             sub      a,l                  ; $cd7e 95              ; 
             ld       l,a                  ; $cd7f 6f              ; 
             ld       a,c                  ; $cd80 79              ; 
             sbc      a,h                  ; $cd81 9c              ; 
             ld       h,a                  ; $cd82 67              ; 
             jp       num_store_int_result ; $cd83 c3 ef ca        ; 

;
; Negate the current integer accumulator at $0450 and report whether
; the value was the un-negatable edge case $8000.  Returns Z only for
; that minimum-integer case; otherwise leaves the negated integer in HL.
;
num_negate_current_int_or_flag_minint: ld       hl,($0450)           ; $cd86 2a 50 04        ; 
             call     num_negate_hl_store_int ; $cd89 cd 7c cd        ; 
             ld       a,h                  ; $cd8c 7c              ; 
             xor      a,$80                ; $cd8d ee 80           ; 
             or       a,l                  ; $cd8f b5              ; 
             ret      nz                   ; $cd90 c0              ; 

;
; Small integer-to-floating bridge for known non-negative values in HL.
; Clears A before entering the shared converter at $cb22 so callers
; such as FRE can return an integer magnitude as a floating result.
;
fp_from_positive_int_hl: xor      a,a                  ; $cd91 af              ; 
             jp       jumpcb22             ; $cd92 c3 22 cb        ; 

;
; Integer remainder helper paired with num_div_int_or_promote.  Runs the
; shared signed division core, keeps the remainder side of the result,
; normalises it back into HL, tags the value as integer, then reapplies
; the saved sign convention before returning.
;
num_mod_int_or_promote: push     de                   ; $cd95 d5              ; 
             call     num_div_int_or_promote ; $cd96 cd 39 cd        ; 
             xor      a,a                  ; $cd99 af              ; 
             add      a,d                  ; $cd9a 82              ; 
             rra                           ; $cd9b 1f              ; 
             ld       h,a                  ; $cd9c 67              ; 
             ld       a,e                  ; $cd9d 7b              ; 
             rra                           ; $cd9e 1f              ; 
             ld       l,a                  ; $cd9f 6f              ; 
             call     num_set_integer_type ; $cda0 cd f2 ca        ; 
             pop      af                   ; $cda3 f1              ; 
             jr       loopcd78             ; $cda4 18 d2           ; 

             defb     $cd,$39,$ca                                  ; .9.        ; 
;
; Promote the integer work/main operands at $049f/$04a1 into the
; floating-point work area, clear the extended mantissa bytes, then jump
; into the generic floating add path.
;
fp_add_int_work_operands: call     fp_store_int_operands_to_work ; $cda9 cd db cd        ; 
             call     fp_clear_extended_mantissa ; $cdac cd 98 cb        ; 
             jp       fp_add_work          ; $cdaf c3 0e b2        ; 

             defb     $cd,$e7,$c9,$18,$f2                          ; .....      ; 
;
; Multiply counterpart to fp_add_int_work_operands.  Materialises the
; integer operands into the floating-point work slots, clears the extra
; mantissa bytes, and jumps into the generic floating multiply worker.
;
fp_multiply_int_work_operands: call     fp_store_int_operands_to_work ; $cdb7 cd db cd        ; 
             call     fp_clear_extended_mantissa ; $cdba cd 98 cb        ; 
             jp       fp_multiply_main_work ; $cdbd c3 76 b3        ; 

             defb     $c1,$d1,$2a,$50,$04,$eb,$22,$50,$04,$c5      ; ..*P.."P.. ; 
             defb     $2a,$4e,$04,$e3,$22,$4e,$04,$c1,$cd,$db      ; *N.."N.... ; 
             defb     $cd,$cd,$98,$cb,$c3,$2f,$b4                  ; ...../.    ; 
;
; Shared bridge that writes BC/DE into the floating-point work slots at
; $049f/$04a1 and zeroes the remaining extension words at $04a3/$04a5.
; Used before promoting integer arithmetic into the generic FP engine.
;
fp_store_int_operands_to_work: ex       de,hl                ; $cddb eb              ; 
             ld       ($04a1),hl           ; $cddc 22 a1 04        ; 
             ld       h,b                  ; $cddf 60              ; 
             ld       l,c                  ; $cde0 69              ; 
             ld       ($049f),hl           ; $cde1 22 9f 04        ; 
             ld       hl,$0000             ; $cde4 21 00 00        ; 
             ld       ($04a3),hl           ; $cde7 22 a3 04        ; 
             ld       ($04a5),hl           ; $cdea 22 a5 04        ; 
             ret                           ; $cded c9              ; 

;
; One-byte arithmetic helper: `DEC A ; RET`.  Reused by number-formatting
; code as a compact decrement tail.
;
dec_a:       dec      a                    ; $cdee 3d              ; 
             ret                           ; $cdef c9              ; 

;
; One-byte arithmetic helper: `DEC HL ; RET`.  Used by string/number
; formatting paths that need to back up a cursor pointer by one byte.
;
dec_hl:      dec      hl                   ; $cdf0 2b              ; 
             ret                           ; $cdf1 c9              ; 

;
; Stack-cleanup tail used as a synthetic return target.  Pops one saved
; HL value from the stack and returns immediately.
; 
; ; ============================================================
; ; FRE handler ($DDD7)
; ; ============================================================
;
pop_hl_and_return: pop      hl                   ; $cdf2 e1              ; 
             ret                           ; $cdf3 c9              ; 

;
; ---------------------------------------------------------------------------
; PSET / PRESET instruction handlers and graphics sub-system
; ---------------------------------------------------------------------------
; PSET [STEP] (X,Y) — set a pixel (mode $11)
; PRESET [STEP] (X,Y) — clear a pixel (mode $12)
; Screen: 120 × 32 pixels.  X in [0..119], Y in [0..31].
; Call chain:
; RAM $008D → pset_handler ($CDF4)   or
; RAM $0090 → preset_handler ($CDF7) → parse_pset_coords ($CE56)
; → pset_plot ($CE68)
; → store_gfx_params ($CE91)
; → gfx_dispatch ($DB0F)
; → lcd_submit ($C92F)
; → lcd_trigger ($C977) — port I/O
; → lcd_send_data ($C98F) — port I/O
; Graphics cursor RAM: $04C6 = current X, $04C8 = current Y
; Graphics parameter block: $026E = X, $026F = Y, $0270 = sub-cmd, $0271 = count
; Hardware ports: $F1 = data, $F2 = status (bit1=ready), $F5 = command
; 
; PSET statement entry point (dispatched from RAM syscall at $008D).
; Loads mode $11 (set pixel). The LD BC,$123E at $CDF6 is a dummy
; instruction that absorbs the PRESET "LD A,$12" opcode, so PSET
; falls through to the shared parse/draw code at $CDF9.
;
pset_handler: ld       a,$11                ; $cdf4 3e 11           ; 
             defb     $01                  ; $cdf6 01 3e 12        ;   As: ld     bc,$123e   ; 01 3e 12   ; Next: $cdf9
;
; PRESET statement entry point (dispatched from RAM syscall at $0090).
; Loads mode $12 (clear pixel). Falls through to shared code.
;
preset_handler: ld       a,$12                ; $cdf7 3e 12           ; 
             push     af                   ; $cdf9 f5              ; 
             call     parse_pset_coords    ; $cdfa cd 56 ce        ; 
             pop      af                   ; $cdfd f1              ; 
             push     hl                   ; $cdfe e5              ; 
             push     af                   ; $cdff f5              ; 
             call     pset_plot            ; $ce00 cd 68 ce        ; 
             pop      hl                   ; $ce03 e1              ; 
             ret                           ; $ce04 c9              ; 

;
; inst_draw_exec — RST $20 syscall slot 20 (RAM $0093)
; ----
; Shared single-pixel graphics query entry.
; BASIC function POINT reaches this ROM body through the RAM vector at
; $0093.  The routine polls I/O, parses one (x,y) pair via
; parse_pset_coords, submits LCD command $10 with a 2-byte graphics
; parameter block, then falls into gfx_reply_to_basic_int to invert
; and package the returned status byte as a BASIC integer.
; The same public RAM slot is also exposed through the syscall table.
; 
; POINT(x,y): poll I/O, parse coords, dispatch LCD command $10,
; return the read-back pixel state.
;
inst_draw_exec: rst      rst0010              ; $ce05 d7              ; 
             call     parse_pset_coords    ; $ce06 cd 56 ce        ; 
             push     hl                   ; $ce09 e5              ; 
             ld       bc,$fb30             ; $ce0a 01 30 fb        ; 
             push     bc                   ; $ce0d c5              ; 
             ld       bc,$0201             ; $ce0e 01 01 02        ; 
             ld       a,$10                ; $ce11 3e 10           ; 
             call     store_gfx_and_dispatch ; $ce13 cd 6f ce        ; 
             jp       gfx_reply_to_basic_int ; $ce16 c3 dd d7        ; 

;
; inst_line_exec — RST $20 syscall slot 21 (RAM $0096)
; ----
; LINE statement handler (also used as LCD display callback).
; Calls calle1ce to evaluate the first endpoint expression,
; callce79 to check for the `-` separator token ($D2 via
; RST $08), then eval_xy_expression for the second endpoint.
; Validates bounds via check_screen_bounds, stores LCD
; command $14 with count 4, then dispatches.
; 
; LINE (x1,y1)-(x2,y2): evaluate both endpoints, draw line (cmd $14).
;
inst_line_exec: call     calle1ce             ; $ce19 cd ce e1        ; 
             call     gfx_require_8bit_xy  ; $ce1c cd 79 ce        ; 
             ld       d,c                  ; $ce1f 51              ; 
             push     de                   ; $ce20 d5              ; 
             rst      rst0008              ; $ce21 cf              ; 
             defb     $d2                                          ; .          ; RST $08 literal parameter bytes — each byte is consumed as the token
                                                                                ; to match, not an instruction. DATASKIP marks it as data and resumes
                                                                                ; code
                                                                                ; analysis at the following address.
             call     eval_xy_expression   ; $ce23 cd 76 ce        ; 
             ld       b,e                  ; $ce26 43              ; 
             pop      de                   ; $ce27 d1              ; 
             push     hl                   ; $ce28 e5              ; 
             call     check_screen_bounds  ; $ce29 cd 82 ce        ; 
             ld       a,$14                ; $ce2c 3e 14           ; 
             ld       b,$04                ; $ce2e 06 04           ; 
             jr       gfx_dispatch_subcmd0 ; $ce30 18 14           ; 

;
; inst_circle_exec — RST $20 syscall slot 23 (RAM $009C)
; ----
; CIRCLE statement handler.
; Calls eval_xy_expression to parse the centre coordinates
; (C=X, E=Y), requires a `,` separator (RST $08), evaluates
; the radius as an 8-bit integer, validates all three via
; check_screen_bounds, then stores LCD command $15 with
; count 3 and dispatches.
; 
; CIRCLE (x,y), r: parse centre and radius, draw circle (cmd $15).
;
inst_circle_exec: call     eval_xy_expression   ; $ce32 cd 76 ce        ; 
             ld       d,c                  ; $ce35 51              ; 
             push     de                   ; $ce36 d5              ; 
             rst      rst0008              ; $ce37 cf              ; 
             defb     $2c                                          ; ,          ; 
             call     eval_expr_to_int8    ; $ce39 cd 5e fe        ; 
             pop      de                   ; $ce3c d1              ; 
             ld       c,a                  ; $ce3d 4f              ; 
             push     hl                   ; $ce3e e5              ; 
             call     check_screen_bounds  ; $ce3f cd 82 ce        ; 
             ld       a,$15                ; $ce42 3e 15           ; 
             ld       b,$03                ; $ce44 06 03           ; 
;
; Common LINE/CIRCLE dispatch setup.
; Loads C=$00 as the graphics sub-command selector, calls the shared
; gfx dispatch tail, then falls into the post-submit cleanup shared by
; those higher-level drawing statements.
;
gfx_dispatch_subcmd0: ld       c,$00                ; $ce46 0e 00           ; 
             call     gfx_dispatch_tail    ; $ce48 cd 72 ce        ; 
;
; Optional post-submit device reset used by LINE/CIRCLE.
; Checks $00b5 and calls io_device_reset when the current output
; device/mode requires cleanup after the graphics co-processor command
; has completed.
;
gfx_post_dispatch_device_reset: ld       a,($00b5)            ; $ce4b 3a b5 00        ; 
             or       a,a                  ; $ce4e b7              ; 
             jr       z,skipce54           ; $ce4f 28 03           ; 
             call     io_device_reset      ; $ce51 cd bd c0        ; 
skipce54:    pop      hl                   ; $ce54 e1              ; 
             ret                           ; $ce55 c9              ; 

;
; Wrapper for PSET/PRESET: call parse_coord_pair, then range-check
; X < 120 ($78) and Y < 32 ($20).  Jumps to error handler ($F590)
; if out of range.  Returns D = X, E = Y.
;
parse_pset_coords: call     eval_xy_expression   ; $ce56 cd 76 ce        ; 
             ld       a,c                  ; $ce59 79              ; 
             cp       a,$78                ; $ce5a fe 78           ; 
             jr       nc,skipce62          ; $ce5c 30 04           ; 
             push     af                   ; $ce5e f5              ; 
             ld       a,e                  ; $ce5f 7b              ; 
             cp       a,$20                ; $ce60 fe 20           ; 
skipce62:    jp       nc,jumpf590          ; $ce62 d2 90 f5        ; 
             pop      de                   ; $ce65 d1              ; 
             ld       e,a                  ; $ce66 5f              ; 
             ret                           ; $ce67 c9              ; 

;
; Execute the pixel plot.  Called with D = X, E = Y, and the draw
; mode ($11/$12) already on the stack.  Pops mode into A, sets
; B = $02, C = $00, then calls store_gfx_params + gfx_dispatch.
;
pset_plot:   pop      bc                   ; $ce68 c1              ; 
             pop      af                   ; $ce69 f1              ; 
             push     bc                   ; $ce6a c5              ; 
             ld       b,$02                ; $ce6b 06 02           ; 
             ld       c,$00                ; $ce6d 0e 00           ; 
;
; Store graphics parameters (D=X, E=Y, C=sub-cmd, B=count) to the
; graphics parameter block at $026E–$0271, then call gfx_dispatch.
; Also used as the inner dispatch by the LINE handler.
;
store_gfx_and_dispatch: call     store_gfx_params     ; $ce6f cd 91 ce        ; 
;
; Shared tail used once the graphics parameter block is ready.
; Calls gfx_dispatch and returns.  This is the common join point for
; POINT/PSET/PRESET/LINE/CIRCLE-style command submission.
;
gfx_dispatch_tail: call     gfx_dispatch         ; $ce72 cd 0f db        ; 
             ret                           ; $ce75 c9              ; 

;
; Evaluate a (X,Y) coordinate expression.  Calls parse_coord_pair
; then checks high bytes: if B ≠ 0 or D ≠ 0 (coordinates exceed
; 255), jumps to error ($F590).  Returns C = X, E = Y (low bytes).
;
eval_xy_expression: call     parse_coord_pair     ; $ce76 cd d8 e1        ; 
;
; Shared high-byte check for coordinate pairs.
; Clears A, ORs in B then D, and raises error $f590 if either high
; byte is non-zero.  eval_xy_expression falls through here after
; parse_coord_pair, and LINE reuses it before parsing the second
; endpoint.
;
gfx_require_8bit_xy: xor      a,a                  ; $ce79 af              ; 
             or       a,b                  ; $ce7a b0              ; 
             jr       nz,skipce7e          ; $ce7b 20 01           ; 
             or       a,d                  ; $ce7d b2              ; 
skipce7e:    jp       nz,jumpf590          ; $ce7e c2 90 f5        ; 
             ret                           ; $ce81 c9              ; 

;
; Error if any of D, E, B, C exceeds $7F (127).  Used by CIRCLE
; and LINE to validate that the endpoint coordinates are within the
; signed-byte range used by the LCD graphics co-processor.
;
check_screen_bounds: ld       a,$7f                ; $ce82 3e 7f           ; 
             cp       a,d                  ; $ce84 ba              ; 
             jr       c,skipce8e           ; $ce85 38 07           ; 
             cp       a,e                  ; $ce87 bb              ; 
             jr       c,skipce8e           ; $ce88 38 04           ; 
             cp       a,b                  ; $ce8a b8              ; 
             jr       c,skipce8e           ; $ce8b 38 01           ; 
             cp       a,c                  ; $ce8d b9              ; 
skipce8e:    jp       c,jumpf590           ; $ce8e da 90 f5        ; 
;
; Store D → $026E (X), E → $026F (Y), C → $0270 (sub-command),
; B → $0271 (byte count).  Restores HL to $026E on return.
; This is the graphics parameter block consumed by gfx_dispatch.
;
store_gfx_params: ld       hl,$026e             ; $ce91 21 6e 02        ; 
             push     hl                   ; $ce94 e5              ; 
             ld       (hl),d               ; $ce95 72              ; 
             inc      hl                   ; $ce96 23              ; 
             ld       (hl),e               ; $ce97 73              ; 
             inc      hl                   ; $ce98 23              ; 
             ld       (hl),c               ; $ce99 71              ; 
             inc      hl                   ; $ce9a 23              ; 
             ld       (hl),b               ; $ce9b 70              ; 
             pop      hl                   ; $ce9c e1              ; 
             ret                           ; $ce9d c9              ; 

;
; inst_cls — CLS statement
; Send form-feed character ($0C) via the output hook at RAM $009F.
; Then clear the current cursor position variables: $04C6 = $0000 (X),
; $04C8 = $0000 (Y) — reset the graphics cursor to the top-left corner.
; 
; CLS statement.  Output form-feed ($0C) via jump009f hook.
; Reset graphics cursor: $04C6 (X) = $04C8 (Y) = $0000.
;
inst_cls:    push     hl                   ; $ce9e e5              ; 
             ld       a,$0c                ; $ce9f 3e 0c           ; 
             call     jump009f             ; $cea1 cd 9f 00        ; 
             ld       hl,$0000             ; $cea4 21 00 00        ; 
             ld       ($04c6),hl           ; $cea7 22 c6 04        ; 
             ld       ($04c8),hl           ; $ceaa 22 c8 04        ; 
             pop      hl                   ; $cead e1              ; 
             ret                           ; $ceae c9              ; 

;
; fn_csrlin — CSRLIN function
; CSRLIN — return the current cursor row (line number).
; No argument.  RST $10: poll I/O / sync display.
; PUSH HL: preserve HL.
; LD A,($00B8): read cursor row counter from RAM $00B8
; (1-based internal value).
; DEC A: convert to 0-based row index.
; JP jumpd7f2: store DE = $FB30 (return path), push DE,
; and fall into loopd7df which calls callfc15 to
; convert A to a float and return the result.
;
fn_csrlin:   rst      rst0010              ; $ceaf d7              ; 
             push     hl                   ; $ceb0 e5              ; 
             ld       a,($00b8)            ; $ceb1 3a b8 00        ; 
             dec      a                    ; $ceb4 3d              ; 
             jp       jumpd7f2             ; $ceb5 c3 f2 d7        ; 

;
; inst_exec — EXEC statement (call machine-code subroutine)
; EXEC addr
; eval_expr_to_addr → DE (address of user machine-code routine).
; Push all registers on the BASIC stack: AF, BC, DE, HL, IX, IY.
; Compute return address = $CEC3 + 10 = $CECD (the pop-all stub).
; Push the return address as if it were the top-of-stack return,
; then JP (HL) — jump to user code.
; The stub at $CECD: POP IY, POP IX, POP DE, POP BC, POP AF, POP HL,
; RET — restores all registers and returns normally to BASIC.
; Immediately after the return stub begins a hidden device-driver
; block used indirectly from the ROM device tables; it is not part
; of the EXEC statement itself.
; 
; EXEC statement.  Call machine-code at eval_expr_to_addr → DE.
; Saves all registers (AF,BC,DE,HL,IX,IY), pushes return stub
; address ($CECD), then JP (HL).  The return stub pops all
; registers and resumes BASIC normally.
;
inst_exec:   call     eval_expr_to_addr    ; $ceb8 cd cc ff        ; 
             push     hl                   ; $cebb e5              ; 
             push     af                   ; $cebc f5              ; 
             push     bc                   ; $cebd c5              ; 
             push     de                   ; $cebe d5              ; 
             push     ix                   ; $cebf dd e5           ; 
             push     iy                   ; $cec1 fd e5           ; 
             ld       hl,$cec3             ; $cec3 21 c3 ce        ; 
             ld       bc,$000a             ; $cec6 01 0a 00        ; 
             add      hl,bc                ; $cec9 09              ; 
             push     hl                   ; $ceca e5              ; 
             ex       de,hl                ; $cecb eb              ; 
             jp       (hl)                 ; $cecc e9              ; 

             defb     $fd,$e1,$dd,$e1,$d1,$c1,$f1,$e1,$c9          ; .........  ; 
;
; gpr_put_char — GPR device character output routine
; Hidden code block reached indirectly through the `GPR:` entry in
; io_device_driver_table: the record at $e7b0-$e7b8 contains the
; little-endian pointer $ced6, so opening the GPR device installs
; this routine through the low-RAM I/O hooks rather than by direct
; CALL/JP instructions in ROM.
; 
; The entry initialises HL=$0003 and BC=($0004), then falls into the
; main character-processing path at $cedd.  That path handles CR and
; backspace specially, ignores other control characters below space,
; updates the cursor/column state in RAM, waits for the hardware
; handshake at io_wait_f2_bit7, services pending I/O, shifts the
; output byte bit-by-bit through the port-$f4/$f5 interface, then
; waits again and flushes with a fixed postamble.
; 
; No direct absolute callers were found in ROM.  Static evidence
; points to indirect use only, via the GPR device descriptor and the
; channel vectors installed by io_open_channel.
;
gpr_put_char: ld       hl,gpr_cursor_state  ; $ced6 21 03 00        ; 
             ld       bc,(gpr_line_span)   ; $ced9 ed 4b 04 00     ; 
;
; gpr_handle_char_or_control — shared GPR control-char gate
; Entry reached after gpr_put_char seeds HL/BC from gpr_cursor_state,
; gpr_line_span, and gpr_char_step.  Handles backspace and CR
; specially, ignores other control codes below space, advances the
; horizontal state for printable bytes, then falls into lpt_put_char
; for the actual port-$f4/$f5 serial transfer.
;
gpr_handle_char_or_control: push     af                   ; $cedd f5              ; 
             cp       a,$08                ; $cede fe 08           ; 
             jr       z,gpr_apply_backspace ; $cee0 28 52           ; 
             cp       a,$0d                ; $cee2 fe 0d           ; 
             jr       z,gpr_reset_column   ; $cee4 28 0e           ; 
             and      a,$7f                ; $cee6 e6 7f           ; 
             cp       a,$20                ; $cee8 fe 20           ; 
             jr       c,skipcef6           ; $ceea 38 0a           ; 
             ld       a,b                  ; $ceec 78              ; 
             inc      c                    ; $ceed 0c              ; 
             add      a,(hl)               ; $ceee 86              ; 
             ld       (hl),a               ; $ceef 77              ; 
             add      a,b                  ; $cef0 80              ; 
             cp       a,c                  ; $cef1 b9              ; 
             jr       c,skipcef6           ; $cef2 38 02           ; 
;
; gpr_reset_column — clear the GPR horizontal offset at line start
; Used for carriage return and for wrap after the printable-character
; update crosses the configured line span.
;
gpr_reset_column: ld       (hl),$00             ; $cef4 36 00           ; 
skipcef6:    pop      af                   ; $cef6 f1              ; 
;
; lpt_put_char — hidden LPT device character-output routine
; Primary driver block for the `LPT:` record in io_device_driver_table.
; Waits for the shared port-$f2 bit-7 handshake (io_wait_f2_bit7),
; services pending I/O, shifts the outgoing byte through the same
; port-$f4/$f5 serial bit loop used by the graphics-printer path,
; then writes a fixed $40 strobe and a trailing all-ones postamble.
; 
; No direct absolute CALL/JP reaches this block; it is installed
; indirectly by io_open_channel when the `LPT:` device is selected.
;
lpt_put_char: push     af                   ; $cef7 f5              ; 
             call     io_wait_f2_bit7      ; $cef8 cd 2a cf        ; 
             call     io_event_service     ; $cefb cd 3f c0        ; 
             pop      af                   ; $cefe f1              ; 
             call     term_shift_serial_byte ; $ceff cd 11 cf        ; 
             ld       a,$40                ; $cf02 3e 40           ; 
             out      ($f5),a              ; $cf04 d3 f5           ; 
             call     io_wait_f2_bit7      ; $cf06 cd 2a cf        ; 
             call     term_shift_ff_postamble ; $cf09 cd 0f cf        ; 
             jp       io_event_service     ; $cf0c c3 3f c0        ; 

;
; term_shift_ff_postamble — emit an all-ones serial postamble
; Tiny wrapper used both here and by hw_audio_reset.  Loads A=$ff and
; falls into the generic 8-bit serial shifter at $cf11.
;
term_shift_ff_postamble: ld       a,$ff                ; $cf0f 3e ff           ; 
;
; term_shift_serial_byte — shift A out through the shared $f4/$f5 port pair
; Rotates the byte one bit at a time, mirrors bit 5 into port $f4,
; and pulses port $f5 with $20 for each bit.  Shared by GPR/LPT
; output and the cold-start latch reset path.
;
term_shift_serial_byte: ld       b,$08                ; $cf11 06 08           ; 
             rrca                          ; $cf13 0f              ; 
             rrca                          ; $cf14 0f              ; 
loopcf15:    rrca                          ; $cf15 0f              ; 
             push     af                   ; $cf16 f5              ; 
             cpl                           ; $cf17 2f              ; 
             and      a,$20                ; $cf18 e6 20           ; 
             ld       e,a                  ; $cf1a 5f              ; 
             in       a,($f4)              ; $cf1b db f4           ; 
             and      a,$5f                ; $cf1d e6 5f           ; 
             or       a,e                  ; $cf1f b3              ; 
             out      ($f4),a              ; $cf20 d3 f4           ; 
             ld       a,$20                ; $cf22 3e 20           ; 
             out      ($f5),a              ; $cf24 d3 f5           ; 
             pop      af                   ; $cf26 f1              ; 
             djnz     loopcf15             ; $cf27 10 ec           ; 
             ret                           ; $cf29 c9              ; 

;
; io_wait_f2_bit7 — wait for port $F2 bit 7 to assert
; Calls calle8e8 first to test the shared I/O status byte at
; $002B (masked with $83).  If any of those status bits are set,
; it returns immediately with NZ.
; 
; Otherwise it repeatedly reads port $F2, rotates bit 7 into
; carry with RLA, and loops until that bit becomes 1.  The
; routine is therefore a low-level hardware handshake wait, not
; a standalone callable service.
; 
; It is only called from the hidden helper block at $CEDD-$CF0C,
; via calls at $CEF8 and $CF06, where it brackets port-$F5
; command writes and an io_event_service call.
;
io_wait_f2_bit7: call     calle8e8             ; $cf2a cd e8 e8        ; 
             ret      nz                   ; $cf2d c0              ; 

             in       a,($f2)              ; $cf2e db f2           ; 
             rla                           ; $cf30 17              ; 
             jr       nc,io_wait_f2_bit7   ; $cf31 30 f7           ; 
             ret                           ; $cf33 c9              ; 

;
; gpr_apply_backspace — backspace handler for gpr_handle_char_or_control
; Subtracts gpr_char_step from the current horizontal offset, clamping
; at zero via the shared gpr_reset_column path.
;
gpr_apply_backspace: ld       a,(hl)               ; $cf34 7e              ; 
             sub      a,b                  ; $cf35 90              ; 
             jr       c,gpr_reset_column   ; $cf36 38 bc           ; 
             ld       (hl),a               ; $cf38 77              ; 
             jr       skipcef6             ; $cf39 18 bb           ; 

;
; gpr_driver_dispatch — hidden GPR current-channel command hook
; RST $38 high-bit commands for the active `GPR:` channel arrive here
; with A already masked to the command byte.  The body handles at
; least command $01 (branching into the helper at $CF91 to derive a
; cursor / geometry value from the state words at $0003/$0005) and
; command $0C (printing a short status report through RST $28 while
; updating the same state bytes).
; 
; Conservative name: a device-specific dispatcher layered above the
; already-labeled gpr_put_char byte-output path.
;
gpr_driver_dispatch: cp       a,$01                ; $cf3b fe 01           ; 
             jr       z,gpr_driver_cmd_01_get_column ; $cf3d 28 52           ; 
             cp       a,$0c                ; $cf3f fe 0c           ; 
             ret      nz                   ; $cf41 c0              ; 

;
; gpr_emit_status_report — GPR command $0c status/control emitter
; Prints a short control sequence through rst0028.  It preserves the
; live horizontal offset in gpr_cursor_state while emitting setup
; fields derived from B and C.
;
gpr_emit_status_report: ld       a,(gpr_cursor_state) ; $cf42 3a 03 00        ; 
             push     af                   ; $cf45 f5              ; 
             ld       a,b                  ; $cf46 78              ; 
             inc      a                    ; $cf47 3c              ; 
             jr       z,skipcf50           ; $cf48 28 06           ; 
             ld       a,b                  ; $cf4a 78              ; 
             dec      a                    ; $cf4b 3d              ; 
             cp       a,$10                ; $cf4c fe 10           ; 
             jr       nc,skipcf54          ; $cf4e 30 04           ; 
skipcf50:    ld       a,c                  ; $cf50 79              ; 
             inc      a                    ; $cf51 3c              ; 
             cp       a,$05                ; $cf52 fe 05           ; 
skipcf54:    jp       nc,jumpf590          ; $cf54 d2 90 f5        ; 
             xor      a,a                  ; $cf57 af              ; 
             rst      rst0028              ; $cf58 ef              ; 
             ld       a,$12                ; $cf59 3e 12           ; 
             rst      rst0028              ; $cf5b ef              ; 
             ld       a,$0d                ; $cf5c 3e 0d           ; 
             rst      rst0028              ; $cf5e ef              ; 
             ld       a,b                  ; $cf5f 78              ; 
             inc      a                    ; $cf60 3c              ; 
             jr       z,gpr_emit_c_parameter ; $cf61 28 18           ; 
;
; gpr_emit_s_parameter — emit `S<n>` and store gpr_char_step
; Command-$0c sub-block.  Prints the literal `S`, stores B to
; gpr_char_step, then emits the corresponding decimal parameter.
;
gpr_emit_s_parameter: ld       a,$53                ; $cf63 3e 53           ; 
             rst      rst0028              ; $cf65 ef              ; 
             ld       a,b                  ; $cf66 78              ; 
             ld       (gpr_char_step),a    ; $cf67 32 05 00        ; 
             dec      a                    ; $cf6a 3d              ; 
             cp       a,$0a                ; $cf6b fe 0a           ; 
             jr       c,skipcf75           ; $cf6d 38 06           ; 
             ld       a,$31                ; $cf6f 3e 31           ; 
             rst      rst0028              ; $cf71 ef              ; 
             ld       a,b                  ; $cf72 78              ; 
             sub      a,$0b                ; $cf73 d6 0b           ; 
skipcf75:    add      a,$30                ; $cf75 c6 30           ; 
             rst      rst0028              ; $cf77 ef              ; 
             ld       a,$0d                ; $cf78 3e 0d           ; 
             rst      rst0028              ; $cf7a ef              ; 
;
; gpr_emit_c_parameter — emit optional `C<n>` GPR control field
; Command-$0c sub-block.  When C is in range, prints the literal `C`
; and a single decimal digit before returning to the shared trailer.
;
gpr_emit_c_parameter: ld       a,c                  ; $cf7b 79              ; 
             inc      a                    ; $cf7c 3c              ; 
             jr       z,skipcf89           ; $cf7d 28 0a           ; 
             ld       a,$43                ; $cf7f 3e 43           ; 
             rst      rst0028              ; $cf81 ef              ; 
             ld       a,c                  ; $cf82 79              ; 
             add      a,$30                ; $cf83 c6 30           ; 
             rst      rst0028              ; $cf85 ef              ; 
             ld       a,$0d                ; $cf86 3e 0d           ; 
             rst      rst0028              ; $cf88 ef              ; 
skipcf89:    ld       a,$11                ; $cf89 3e 11           ; 
             rst      rst0028              ; $cf8b ef              ; 
             pop      af                   ; $cf8c f1              ; 
             ld       (gpr_cursor_state),a ; $cf8d 32 03 00        ; 
             ret                           ; $cf90 c9              ; 

;
; gpr_driver_cmd_01_get_column — derive current column from GPR state
; Command-$01 helper.  Uses gpr_cursor_state, gpr_line_span, and
; gpr_char_step to convert the packed horizontal state into a logical
; column count returned in C.
;
gpr_driver_cmd_01_get_column: push     hl                   ; $cf91 e5              ; 
             ld       hl,(gpr_cursor_state) ; $cf92 2a 03 00        ; 
             ld       a,h                  ; $cf95 7c              ; 
             ld       bc,(gpr_char_step)   ; $cf96 ed 4b 05 00     ; 
             ld       b,$ff                ; $cf9a 06 ff           ; 
loopcf9c:    inc      b                    ; $cf9c 04              ; 
             jp       m,jumpe8b6           ; $cf9d fa b6 e8        ; 
             sub      a,c                  ; $cfa0 91              ; 
             jr       nc,loopcf9c          ; $cfa1 30 f9           ; 
             ld       a,h                  ; $cfa3 7c              ; 
             sub      a,l                  ; $cfa4 95              ; 
             ld       h,$ff                ; $cfa5 26 ff           ; 
loopcfa7:    inc      h                    ; $cfa7 24              ; 
             sub      a,c                  ; $cfa8 91              ; 
             jr       nc,loopcfa7          ; $cfa9 30 fc           ; 
             ld       a,b                  ; $cfab 78              ; 
             sub      a,h                  ; $cfac 94              ; 
             ld       c,a                  ; $cfad 4f              ; 
             pop      hl                   ; $cfae e1              ; 
             ret                           ; $cfaf c9              ; 

;
; lpt_open_channel — hidden open/setup vector for `LPT:`
; Reached indirectly by io_init_descriptor through the `LPT:` record's
; +6 pointer.  Loads HL=$CFD9 and B=$02, then emits the two-byte CR/LF
; sequence stored there through lpt_put_char.
;
lpt_open_channel: ld       hl,lpt_open_sequence_data ; $cfb0 21 d9 cf        ; 
             ld       b,$02                ; $cfb3 06 02           ; 
             jr       term_emit_open_sequence ; $cfb5 18 10           ; 

;
; gpr_open_channel — hidden open/setup vector for `GPR:`
; Reached indirectly by io_init_descriptor through the `GPR:` record's
; +6 pointer.  Seeds the state words at $0003/$0005 with $5000 and $02,
; then streams the 10-byte setup script at $CFD1 through lpt_put_char.
;
gpr_open_channel: ld       hl,$5000             ; $cfb7 21 00 50        ; 
             ld       (gpr_cursor_state),hl ; $cfba 22 03 00        ; 
             ld       a,$02                ; $cfbd 3e 02           ; 
             ld       (gpr_char_step),a    ; $cfbf 32 05 00        ; 
             ld       hl,gpr_open_sequence_data ; $cfc2 21 d1 cf        ; 
             ld       b,$0a                ; $cfc5 06 0a           ; 
;
; term_emit_open_sequence — shared byte-stream emitter for GPR/LPT open
; Walks the setup bytes pointed to by HL for B entries and sends each
; one through lpt_put_char.
;
term_emit_open_sequence: ld       a,(hl)               ; $cfc7 7e              ; 
             inc      hl                   ; $cfc8 23              ; 
             push     bc                   ; $cfc9 c5              ; 
             call     lpt_put_char         ; $cfca cd f7 ce        ; 
             pop      bc                   ; $cfcd c1              ; 
             djnz     term_emit_open_sequence ; $cfce 10 f7           ; 
             ret                           ; $cfd0 c9              ; 

;
; gpr_open_sequence_data — default GPR open/setup script
; Ten-byte sequence emitted by gpr_open_channel:
; CR, CR, NUL, DC2, `S1`, CR, DC1, CR, LF.
;
gpr_open_sequence_data: defb     $0d,$0d,$00,$12,$53,$31,$0d,$11              ; ....S1..   ; 
;
; lpt_open_sequence_data — default LPT open/setup script
; Two-byte CR/LF sequence emitted by lpt_open_channel.
;
lpt_open_sequence_data: defb     $0d,$0a                                      ; ..         ; 
;
; PRINT/LPRINT USING dispatcher.  Evaluates the format expression as a
; string, requires the following `;`, then walks the format template
; and the remaining argument list to emit each formatted field.
;
print_using_dispatch: call     callf92e             ; $cfdb cd 2e f9        ; 
             call     str_require_string   ; $cfde cd ae cb        ; 
             rst      rst0008              ; $cfe1 cf              ; 
             dec      sp                   ; $cfe2 3b              ; 
             ex       de,hl                ; $cfe3 eb              ; 
             ld       hl,($0450)           ; $cfe4 2a 50 04        ; 
             jr       skipcff1             ; $cfe7 18 08           ; 

;
; Resume PRINT USING after one formatted field.  Checks the deferred
; separator token saved in $030E and either continues with the same
; format context or restarts the next pass through the template.
;
print_using_resume: ld       a,($030e)            ; $cfe9 3a 0e 03        ; 
             or       a,a                  ; $cfec b7              ; 
             jr       z,skipcffc           ; $cfed 28 0d           ; 
             pop      de                   ; $cfef d1              ; 
             ex       de,hl                ; $cff0 eb              ; 
skipcff1:    push     hl                   ; $cff1 e5              ; 
             xor      a,a                  ; $cff2 af              ; 
             ld       ($030e),a            ; $cff3 32 0e 03        ; 
             inc      a                    ; $cff6 3c              ; 
             push     af                   ; $cff7 f5              ; 
             push     de                   ; $cff8 d5              ; 
             ld       b,(hl)               ; $cff9 46              ; 
             inc      b                    ; $cffa 04              ; 
             dec      b                    ; $cffb 05              ; 
skipcffc:    jp       z,jumpf590           ; $cffc ca 90 f5        ; 
             inc      hl                   ; $cfff 23              ; 
             ld       a,(hl)               ; $d000 7e              ; 
             inc      hl                   ; $d001 23              ; 
             ld       h,(hl)               ; $d002 66              ; 
             ld       l,a                  ; $d003 6f              ; 
             jr       skipd020             ; $d004 18 1a           ; 

;
; Inner USING-format scanner.  Walks the current format field, counts
; padding, and interprets metacharacters such as `#`, `.`, `,`, `+`,
; `-`, `*`, `!`, `&`, and `^` before dispatching to an emitter.
;
print_using_scan_format: ld       e,b                  ; $d006 58              ; 
             push     hl                   ; $d007 e5              ; 
             ld       c,$02                ; $d008 0e 02           ; 
loopd00a:    ld       a,(hl)               ; $d00a 7e              ; 
             inc      hl                   ; $d00b 23              ; 
             cp       a,$26                ; $d00c fe 26           ; 
             jp       z,jumpd130           ; $d00e ca 30 d1        ; 
             cp       a,$20                ; $d011 fe 20           ; 
             jr       nz,skipd018          ; $d013 20 03           ; 
             inc      c                    ; $d015 0c              ; 
             djnz     loopd00a             ; $d016 10 f2           ; 
skipd018:    pop      hl                   ; $d018 e1              ; 
             ld       b,e                  ; $d019 43              ; 
             ld       a,$26                ; $d01a 3e 26           ; 
loopd01c:    call     print_using_emit_sign ; $d01c cd 60 d1        ; 
             rst      rst0028              ; $d01f ef              ; 
skipd020:    xor      a,a                  ; $d020 af              ; 
             ld       e,a                  ; $d021 5f              ; 
             ld       d,a                  ; $d022 57              ; 
loopd023:    call     print_using_emit_sign ; $d023 cd 60 d1        ; 
             ld       d,a                  ; $d026 57              ; 
             ld       a,(hl)               ; $d027 7e              ; 
             inc      hl                   ; $d028 23              ; 
             cp       a,$21                ; $d029 fe 21           ; 
             jp       z,print_using_string_item ; $d02b ca 2d d1        ; 
             cp       a,$23                ; $d02e fe 23           ; 
             jr       z,loopd069           ; $d030 28 37           ; 
             dec      b                    ; $d032 05              ; 
             jp       z,jumpd119           ; $d033 ca 19 d1        ; 
             cp       a,$2b                ; $d036 fe 2b           ; 
             ld       a,$08                ; $d038 3e 08           ; 
             jr       z,loopd023           ; $d03a 28 e7           ; 
             dec      hl                   ; $d03c 2b              ; 
             ld       a,(hl)               ; $d03d 7e              ; 
             inc      hl                   ; $d03e 23              ; 
             cp       a,$2e                ; $d03f fe 2e           ; 
             jr       z,skipd083           ; $d041 28 40           ; 
             cp       a,$26                ; $d043 fe 26           ; 
             jr       z,print_using_scan_format ; $d045 28 bf           ; 
             cp       a,(hl)               ; $d047 be              ; 
             jr       nz,loopd01c          ; $d048 20 d2           ; 
             cp       a,$24                ; $d04a fe 24           ; 
             jr       z,skipd062           ; $d04c 28 14           ; 
             cp       a,$2a                ; $d04e fe 2a           ; 
             jr       nz,loopd01c          ; $d050 20 ca           ; 
             inc      hl                   ; $d052 23              ; 
             ld       a,b                  ; $d053 78              ; 
             cp       a,$02                ; $d054 fe 02           ; 
             jr       c,skipd05b           ; $d056 38 03           ; 
             ld       a,(hl)               ; $d058 7e              ; 
             cp       a,$24                ; $d059 fe 24           ; 
skipd05b:    ld       a,$20                ; $d05b 3e 20           ; 
             jr       nz,skipd066          ; $d05d 20 07           ; 
             dec      b                    ; $d05f 05              ; 
             inc      e                    ; $d060 1c              ; 
             defb     $fe                  ; $d061 fe af           ;   As: cp     a,$af      ; fe af      ; Next: $d063
skipd062:    xor      a,a                  ; $d062 af              ; 
             add      a,$10                ; $d063 c6 10           ; 
             inc      hl                   ; $d065 23              ; 
skipd066:    inc      e                    ; $d066 1c              ; 
             add      a,d                  ; $d067 82              ; 
             ld       d,a                  ; $d068 57              ; 
loopd069:    inc      e                    ; $d069 1c              ; 
             ld       c,$00                ; $d06a 0e 00           ; 
             dec      b                    ; $d06c 05              ; 
             jr       z,skipd0b6           ; $d06d 28 47           ; 
             ld       a,(hl)               ; $d06f 7e              ; 
             inc      hl                   ; $d070 23              ; 
             cp       a,$2e                ; $d071 fe 2e           ; 
             jr       z,skipd08d           ; $d073 28 18           ; 
             cp       a,$23                ; $d075 fe 23           ; 
             jr       z,loopd069           ; $d077 28 f0           ; 
             cp       a,$2c                ; $d079 fe 2c           ; 
             jr       nz,skipd097          ; $d07b 20 1a           ; 
             ld       a,d                  ; $d07d 7a              ; 
             or       a,$40                ; $d07e f6 40           ; 
             ld       d,a                  ; $d080 57              ; 
             jr       loopd069             ; $d081 18 e6           ; 

skipd083:    ld       a,(hl)               ; $d083 7e              ; 
             cp       a,$23                ; $d084 fe 23           ; 
             ld       a,$2e                ; $d086 3e 2e           ; 
             jr       nz,loopd01c          ; $d088 20 92           ; 
             ld       c,$01                ; $d08a 0e 01           ; 
             inc      hl                   ; $d08c 23              ; 
skipd08d:    inc      c                    ; $d08d 0c              ; 
             dec      b                    ; $d08e 05              ; 
             jr       z,skipd0b6           ; $d08f 28 25           ; 
             ld       a,(hl)               ; $d091 7e              ; 
             inc      hl                   ; $d092 23              ; 
             cp       a,$23                ; $d093 fe 23           ; 
             jr       z,skipd08d           ; $d095 28 f6           ; 
skipd097:    push     de                   ; $d097 d5              ; 
             ld       de,$d0b4             ; $d098 11 b4 d0        ; 
             push     de                   ; $d09b d5              ; 
             ld       d,h                  ; $d09c 54              ; 
             ld       e,l                  ; $d09d 5d              ; 
             cp       a,$5e                ; $d09e fe 5e           ; 
             ret      nz                   ; $d0a0 c0              ; 

             cp       a,(hl)               ; $d0a1 be              ; 
             ret      nz                   ; $d0a2 c0              ; 

             inc      hl                   ; $d0a3 23              ; 
             cp       a,(hl)               ; $d0a4 be              ; 
             ret      nz                   ; $d0a5 c0              ; 

             inc      hl                   ; $d0a6 23              ; 
             cp       a,(hl)               ; $d0a7 be              ; 
             ret      nz                   ; $d0a8 c0              ; 

             inc      hl                   ; $d0a9 23              ; 
             ld       a,b                  ; $d0aa 78              ; 
             sub      a,$04                ; $d0ab d6 04           ; 
             ret      c                    ; $d0ad d8              ; 

             pop      de                   ; $d0ae d1              ; 
             pop      de                   ; $d0af d1              ; 
             ld       b,a                  ; $d0b0 47              ; 
             inc      d                    ; $d0b1 14              ; 
             inc      hl                   ; $d0b2 23              ; 
             jp       z,clear_validate_new_memory_layout ; $d0b3 ca eb d1        ; 
skipd0b6:    ld       a,d                  ; $d0b6 7a              ; 
             dec      hl                   ; $d0b7 2b              ; 
             inc      e                    ; $d0b8 1c              ; 
             and      a,$08                ; $d0b9 e6 08           ; 
             jr       nz,skipd0d2          ; $d0bb 20 15           ; 
             dec      e                    ; $d0bd 1d              ; 
             ld       a,b                  ; $d0be 78              ; 
             or       a,a                  ; $d0bf b7              ; 
             jr       z,skipd0d2           ; $d0c0 28 10           ; 
             ld       a,(hl)               ; $d0c2 7e              ; 
             sub      a,$2d                ; $d0c3 d6 2d           ; 
             jr       z,skipd0cd           ; $d0c5 28 06           ; 
             cp       a,$fe                ; $d0c7 fe fe           ; 
             jr       nz,skipd0d2          ; $d0c9 20 07           ; 
             ld       a,$08                ; $d0cb 3e 08           ; 
skipd0cd:    add      a,$04                ; $d0cd c6 04           ; 
             add      a,d                  ; $d0cf 82              ; 
             ld       d,a                  ; $d0d0 57              ; 
             dec      b                    ; $d0d1 05              ; 
skipd0d2:    pop      hl                   ; $d0d2 e1              ; 
             pop      af                   ; $d0d3 f1              ; 
             jr       z,print_using_finish ; $d0d4 28 4c           ; 
             push     bc                   ; $d0d6 c5              ; 
             push     de                   ; $d0d7 d5              ; 
             call     eval_expression      ; $d0d8 cd 2d f9        ; 
             pop      de                   ; $d0db d1              ; 
             pop      bc                   ; $d0dc c1              ; 
             push     bc                   ; $d0dd c5              ; 
             push     hl                   ; $d0de e5              ; 
             ld       b,e                  ; $d0df 43              ; 
             ld       a,b                  ; $d0e0 78              ; 
             add      a,c                  ; $d0e1 81              ; 
             cp       a,$19                ; $d0e2 fe 19           ; 
             jp       nc,jumpf590          ; $d0e4 d2 90 f5        ; 
             ld       a,d                  ; $d0e7 7a              ; 
             or       a,$80                ; $d0e8 f6 80           ; 
             call     callbbac             ; $d0ea cd ac bb        ; 
             call     print_prepare_string_item ; $d0ed cd b1 d5        ; 
;
; After emitting one USING field, fetch the next BASIC token.
; Accepts `;` as a same-clause continuation; otherwise records the
; separator in $030E so the next argument pass can resume correctly.
;
print_using_read_separator: pop      hl                   ; $d0f0 e1              ; 
             dec      hl                   ; $d0f1 2b              ; 
             rst      rst0010              ; $d0f2 d7              ; 
             scf                           ; $d0f3 37              ; 
             jr       z,skipd101           ; $d0f4 28 0b           ; 
             ld       ($030e),a            ; $d0f6 32 0e 03        ; 
             cp       a,$3b                ; $d0f9 fe 3b           ; 
             jr       z,skipd100           ; $d0fb 28 03           ; 
             rst      rst0008              ; $d0fd cf              ; 
             inc      l                    ; $d0fe 2c              ; 
             defb     $06                  ; $d0ff 06 d7           ;   As: ld     b,$d7      ; 06 d7      ; Next: $d101
skipd100:    rst      rst0010              ; $d100 d7              ; 
skipd101:    pop      bc                   ; $d101 c1              ; 
             ex       de,hl                ; $d102 eb              ; 
             pop      hl                   ; $d103 e1              ; 
             push     hl                   ; $d104 e5              ; 
             push     af                   ; $d105 f5              ; 
             push     de                   ; $d106 d5              ; 
             ld       a,(hl)               ; $d107 7e              ; 
             sub      a,b                  ; $d108 90              ; 
             inc      hl                   ; $d109 23              ; 
             ld       d,$00                ; $d10a 16 00           ; 
             ld       e,a                  ; $d10c 5f              ; 
             ld       a,(hl)               ; $d10d 7e              ; 
             inc      hl                   ; $d10e 23              ; 
             ld       h,(hl)               ; $d10f 66              ; 
             ld       l,a                  ; $d110 6f              ; 
             add      hl,de                ; $d111 19              ; 
             ld       a,b                  ; $d112 78              ; 
             or       a,a                  ; $d113 b7              ; 
             jp       nz,skipd020          ; $d114 c2 20 d0        ; 
             jr       skipd11d             ; $d117 18 04           ; 

jumpd119:    call     print_using_emit_sign ; $d119 cd 60 d1        ; 
             rst      rst0028              ; $d11c ef              ; 
skipd11d:    pop      hl                   ; $d11d e1              ; 
             pop      af                   ; $d11e f1              ; 
             jp       nz,print_using_resume ; $d11f c2 e9 cf        ; 
;
; Final PRINT USING exit.  Emits a CRLF when the clause did not end in
; `;`, releases the saved string argument state, and returns through
; fs_dir_close like the normal PRINT path.
;
print_using_finish: call     c,print_emit_crlf    ; $d122 dc 29 e9        ; 
             ex       (sp),hl              ; $d125 e3              ; 
             call     str_swap_result_descriptor_to_de ; $d126 cd 07 d7        ; 
             pop      hl                   ; $d129 e1              ; 
             jp       fs_dir_close         ; $d12a c3 2e e6        ; 

;
; USING string-field emitter.  Evaluates the next argument as a
; string, outputs it via calld5b4, then pads the field with spaces to
; the width computed by print_using_scan_format.
;
print_using_string_item: ld       c,$01                ; $d12d 0e 01           ; 
             defb     $3e                  ; $d12f 3e f1           ;   As: ld     a,$f1      ; 3e f1      ; Next: $d131
jumpd130:    pop      af                   ; $d130 f1              ; 
             dec      b                    ; $d131 05              ; 
             call     print_using_emit_sign ; $d132 cd 60 d1        ; 
             pop      hl                   ; $d135 e1              ; 
             pop      af                   ; $d136 f1              ; 
             jr       z,print_using_finish ; $d137 28 e9           ; 
             push     bc                   ; $d139 c5              ; 
             call     eval_expression      ; $d13a cd 2d f9        ; 
             call     str_require_string   ; $d13d cd ae cb        ; 
             pop      bc                   ; $d140 c1              ; 
             push     bc                   ; $d141 c5              ; 
             push     hl                   ; $d142 e5              ; 
             ld       hl,($0450)           ; $d143 2a 50 04        ; 
             ld       b,c                  ; $d146 41              ; 
             ld       c,$00                ; $d147 0e 00           ; 
             ld       a,b                  ; $d149 78              ; 
             push     af                   ; $d14a f5              ; 
             call     calldc61             ; $d14b cd 61 dc        ; 
             call     print_emit_string_item ; $d14e cd b4 d5        ; 
             ld       hl,($0450)           ; $d151 2a 50 04        ; 
             pop      af                   ; $d154 f1              ; 
             sub      a,(hl)               ; $d155 96              ; 
             ld       b,a                  ; $d156 47              ; 
             ld       a,$20                ; $d157 3e 20           ; 
             inc      b                    ; $d159 04              ; 
loopd15a:    dec      b                    ; $d15a 05              ; 
             jr       z,print_using_read_separator ; $d15b 28 93           ; 
             rst      rst0028              ; $d15d ef              ; 
             jr       loopd15a             ; $d15e 18 fa           ; 

;
; Small USING helper: if the format flags in D request an explicit
; sign position, output `+` before the formatted field.
; 
; ; ============================================================
; ; HEX$ handler ($D538)
; ; ============================================================
;
print_using_emit_sign: push     af                   ; $d160 f5              ; 
             ld       a,d                  ; $d161 7a              ; 
             or       a,a                  ; $d162 b7              ; 
             ld       a,$2b                ; $d163 3e 2b           ; 
             call     nz,rst28_print_char  ; $d165 c4 8f e8        ; 
             pop      af                   ; $d168 f1              ; 
             ret                           ; $d169 c9              ; 

;
; move_block_up_checked — open space by shifting a zero-terminated block upward
; Takes HL = new end address, BC = old end address, and DE = lowest byte that
; must stay in the block.  First checks that the requested upward move still
; leaves headroom above the current variable/string/stack area, then falls into
; the backward copy loop at $d16d.
;
move_block_up_checked: call     check_move_target_space ; $d16a cd 94 d1        ; 
;
; move_block_up_backward_until — backward byte move used to open a gap
; Copies bytes from HL down to DE into the destination ending at BC, moving the
; trailing program/variable text upward without self-overlap corruption.  Used
; by BASIC line insertion and by variable-space growth paths that need the same
; "open a hole" behaviour.
;
move_block_up_backward_until: push     bc                   ; $d16d c5              ; 
             ex       (sp),hl              ; $d16e e3              ; 
             pop      bc                   ; $d16f c1              ; 
loopd170:    rst      rst0020              ; $d170 e7              ; 
             ld       a,(hl)               ; $d171 7e              ; 
             ld       (bc),a               ; $d172 02              ; 
             ret      z                    ; $d173 c8              ; 

             dec      bc                   ; $d174 0b              ; 
             dec      hl                   ; $d175 2b              ; 
             jr       loopd170             ; $d176 18 f8           ; 

;
; ---------------------------------------------------------------------------
; inst_cont — CONT statement
; ---------------------------------------------------------------------------
; Resumes execution after STOP or END.
; Loads $0320 (last-line address); if zero, execution address is not
; available: jump to error (skipd1a8 → $F1C7, "Can't continue").
; Otherwise: load $031E (saved CONT address) into $01DB (execution pointer)
; and return — the main interpreter loop will pick up from there.
; 
; CONT statement.  Loads last-line address from $0320.
; If zero: error "Can't continue" (no prior STOP/END in this run).
; Otherwise: restore execution pointer $01DB from $031E and return.
;
inst_cont:   ld       hl,($0320)           ; $d178 2a 20 03        ; 
             ld       a,h                  ; $d17b 7c              ; 
             or       a,l                  ; $d17c b5              ; 
             ld       de,$0011             ; $d17d 11 11 00        ; 
             jr       z,skipd1a8           ; $d180 28 26           ; 
             ld       de,($031e)           ; $d182 ed 5b 1e 03     ; 
             ld       ($01db),de           ; $d186 ed 53 db 01     ; 
             ret                           ; $d18a c9              ; 

;
; Check that there is room for at least C×22 bytes of GOSUB/FOR
; stack between SP and the current top-of-stack ($0326).
; Jumps to "Out of memory" error if not enough room.
;
check_stack_space: push     hl                   ; $d18b e5              ; 
             ld       hl,($0326)           ; $d18c 2a 26 03        ; 
             ld       b,$00                ; $d18f 06 00           ; 
             add      hl,bc                ; $d191 09              ; 
             add      hl,bc                ; $d192 09              ; 
             defb     $3e                  ; $d193 3e e5           ;   As: ld     a,$e5      ; 3e e5      ; Next: $d195
;
; check_move_target_space — validate that a prospective upper bound fits below stack space
; Shared memory-growth guard used before opening gaps.  Preserves HL, checks the
; requested target against the live variable/string/stack boundary, and returns
; with carry set when the move would collide with reserved space.
;
check_move_target_space: push     hl                   ; $d194 e5              ; 
             call     compute_move_headroom ; $d195 cd ab d1        ; 
             pop      hl                   ; $d198 e1              ; 
             ret      c                    ; $d199 d8              ; 

;
; Shared failure tail for memory-resizing paths such as CLEAR.  Rebuilds
; the BASIC line links from the program base, refreshes the saved stack
; ceiling snapshot at $0313 from $01DD-2, then falls into the common
; BASIC error-$07 path.
;
basic_relink_and_raise_oom: call     basic_relink_from_start ; $d19a cd d9 f2        ; 
             ld       hl,($01dd)           ; $d19d 2a dd 01        ; 
             dec      hl                   ; $d1a0 2b              ; 
             dec      hl                   ; $d1a1 2b              ; 
             ld       ($0313),hl           ; $d1a2 22 13 03        ; 
;
; Shared runtime-error shim for BASIC error $07.  Loads DE = $0007 and
; jumps to the common basic_raise_error entry.
;
basic_raise_error_07: ld       de,$0007             ; $d1a5 11 07 00        ; 
skipd1a8:    jp       basic_raise_error    ; $d1a8 c3 c7 f1        ; 

;
; compute_move_headroom — derive SP-relative headroom for move/stack checks
; Helper for check_stack_space and move_block_up_checked.  Converts HL into the
; remaining headroom between the current stack pointer and the protected RAM
; region below it, letting callers test whether a move or frame allocation fits.
;
compute_move_headroom: push     hl                   ; $d1ab e5              ; 
             ld       a,$b4                ; $d1ac 3e b4           ; 
             sub      a,l                  ; $d1ae 95              ; 
             ld       l,a                  ; $d1af 6f              ; 
             ld       a,$ff                ; $d1b0 3e ff           ; 
             sbc      a,h                  ; $d1b2 9c              ; 
             ld       h,a                  ; $d1b3 67              ; 
             add      hl,sp                ; $d1b4 39              ; 
             pop      hl                   ; $d1b5 e1              ; 
             ret                           ; $d1b6 c9              ; 

;
; inst_tr — TR (TRON / TROFF) statement
; TR ON | TR OFF
; Controls the BASIC line-number trace mode.
; Token $AC (TROFF): XOR A → LD ($041C),A — clear trace flag.
; Token $9B (TRON): call calle850 (open trace output channel); store DE
; to $02C3 (trace output descriptor); then set $041C = 0 via the
; overlapping `LD A,$AF; XOR A` sequence.
; TR OFF: trace disabled ($041C = 0, channel closed).
; TR ON:  trace enabled; line numbers will be printed to the trace channel.
; (Note: the byte at $D1CA is `3E` = LD A,_ opcode prefix that absorbs
; the `AF` operand of the XOR A that follows — classic overlapping trick.)
; 
; TR statement.  TR ON ($9B): open trace channel, store to $02C3,
; enable trace mode ($041C = 0).  TR OFF ($AC): disable trace mode
; ($041C = 0, channel not re-opened).
;
inst_tr:     ld       a,(hl)               ; $d1b7 7e              ; 
             inc      hl                   ; $d1b8 23              ; 
             cp       a,$ac                ; $d1b9 fe ac           ; 
             jr       z,skipd1cb           ; $d1bb 28 0e           ; 
             cp       a,$9b                ; $d1bd fe 9b           ; 
             jr       nz,skipd1e6          ; $d1bf 20 25           ; 
             dec      hl                   ; $d1c1 2b              ; 
             rst      rst0010              ; $d1c2 d7              ; 
             call     fs_parse_device_name ; $d1c3 cd 50 e8        ; 
             ld       ($02c3),de           ; $d1c6 ed 53 c3 02     ; 
             defb     $3e                  ; $d1ca 3e af           ;   As: ld     a,$af      ; 3e af      ; Next: $d1cc
skipd1cb:    xor      a,a                  ; $d1cb af              ; 
             ld       ($041c),a            ; $d1cc 32 1c 04        ; 
             ret                           ; $d1cf c9              ; 

;
; ---------------------------------------------------------------------------
; inst_clear — CLEAR statement
; ---------------------------------------------------------------------------
; CLEAR [size[, top]]
; Without arguments (Z on entry): jump to ctrl_reset_runtime_state — same as
; re-running
; the variable-clear phase of RUN (clears all variables/arrays).
; With one argument (size): evaluate integer; resize string space.
; With two arguments (size, top): also resize the top of available memory.
; Validates: new top ≥ current program end + 100 bytes.
; Updates: $01DD (stack/memory top), $01DF (string space start).
; 
; CLEAR statement.  No args: reinitialise variable area only.
; CLEAR size: resize string storage to <size> bytes.
; CLEAR size,top: also move top-of-memory to <top>.
; Validates new top against program+variables+100-byte minimum.
;
inst_clear:  jr       z,ctrl_reset_runtime_state ; $d1d0 28 5f           ; 
             call     callf58c             ; $d1d2 cd 8c f5        ; 
             dec      hl                   ; $d1d5 2b              ; 
             rst      rst0010              ; $d1d6 d7              ; 
             push     hl                   ; $d1d7 e5              ; 
             ld       hl,($01df)           ; $d1d8 2a df 01        ; 
             jr       z,skipd1f7           ; $d1db 28 1a           ; 
             pop      hl                   ; $d1dd e1              ; 
             rst      rst0008              ; $d1de cf              ; 
             inc      l                    ; $d1df 2c              ; 
             push     de                   ; $d1e0 d5              ; 
             call     eval_expr_to_addr    ; $d1e1 cd cc ff        ; 
             dec      hl                   ; $d1e4 2b              ; 
             rst      rst0010              ; $d1e5 d7              ; 
skipd1e6:    jp       nz,basic_raise_error_02 ; $d1e6 c2 aa f1        ; 
             ex       (sp),hl              ; $d1e9 e3              ; 
             push     hl                   ; $d1ea e5              ; 
;
; Shared CLEAR(size[,top]) validation block.  Checks the requested top
; of free memory against the RAM file area at $0210, validates the
; requested string-space start against that top via $d305, then enforces
; a 100-byte safety margin above the current program end before storing
; the new $01DD / $01DF limits and re-entering ctrl_reset_runtime_state.
;
clear_validate_new_memory_layout: ld       hl,($0210)           ; $d1eb 2a 10 02        ; 
             ld       bc,$fffa             ; $d1ee 01 fa ff        ; 
             add      hl,bc                ; $d1f1 09              ; 
             rst      rst0020              ; $d1f2 e7              ; 
             pop      hl                   ; $d1f3 e1              ; 
             jr       c,skipd1fa           ; $d1f4 38 04           ; 
             ex       de,hl                ; $d1f6 eb              ; 
skipd1f7:    call     calld305             ; $d1f7 cd 05 d3        ; 
skipd1fa:    jp       c,basic_relink_and_raise_oom ; $d1fa da 9a d1        ; 
             push     hl                   ; $d1fd e5              ; 
             ld       hl,($0322)           ; $d1fe 2a 22 03        ; 
             ld       bc,$0064             ; $d201 01 64 00        ; 
             add      hl,bc                ; $d204 09              ; 
             rst      rst0020              ; $d205 e7              ; 
             jp       nc,basic_relink_and_raise_oom ; $d206 d2 9a d1        ; 
             ex       de,hl                ; $d209 eb              ; 
             ld       ($01dd),hl           ; $d20a 22 dd 01        ; 
             pop      hl                   ; $d20d e1              ; 
             ld       ($01df),hl           ; $d20e 22 df 01        ; 
             pop      hl                   ; $d211 e1              ; 
             jr       ctrl_reset_runtime_state ; $d212 18 1d           ; 

;
; ---------------------------------------------------------------------------
; inst_new — NEW statement
; ---------------------------------------------------------------------------
; NEW erases the program and resets all runtime state.
; Guard: RET NZ if not in run mode (direct input only).
; calld215: clears $002F (NEW-in-progress flag), checks $00B0 (mode flag):
; if non-zero (running), jumps to error $F1C2 ("Illegal in run").
; Erases the program by writing two zero bytes at the program start
; address ($00B2), making the first "next-line" pointer $0000.
; Resets: variable pointer $0322, fills the 26-byte DEFTYPE table at $032A
; with $08 (DEFDBL default), clears arithmetic state ($031B, $0319,
; $0320), resets DATA pointer via inst_restore, and zeroes all runtime
; flags ($0344, $0346, $03AE, $041A, $020E, $0417).
; jumpd22d: shared with RUN — sets program-start pointer $030F and resets
; the execution environment but does NOT erase the program.
; 
; NEW statement.  Guard: RET NZ if not in direct mode.
; Clears $002F, rejects if $00B0 ≠ 0 (cannot NEW while running).
;
inst_new:    ret      nz                   ; $d214 c0              ; / 
                                                                   ; | BASIC statement keyword handler labels
                                                                   ; \ Note: ELSE (keyword index 16) shares the inst_rem handler ($f666).

;
; Core NEW/RESET sequence:
; write $0000 to ($00B2) to erase the program;
; init variable area pointer ($0322);
; fill the DEFTYPE table ($032A..$0343) with $08;
; zero error record ($031B), GOTO/CONT pointers, DATA pointer;
; fall through into the run-environment reset (loopd25f).
;
new_reset:   xor      a,a                  ; $d215 af              ; 
calld216:    ld       ($002f),a            ; $d216 32 2f 00        ; 
             ld       a,($00b0)            ; $d219 3a b0 00        ; 
             and      a,a                  ; $d21c a7              ; 
             jp       nz,basic_raise_error_1b ; $d21d c2 c2 f1        ; 
             ld       hl,($00b2)           ; $d220 2a b2 00        ; 
             call     skipd1cb             ; $d223 cd cb d1        ; 
             ld       (hl),a               ; $d226 77              ; 
             inc      hl                   ; $d227 23              ; 
             ld       (hl),a               ; $d228 77              ; 
             inc      hl                   ; $d229 23              ; 
             ld       ($0322),hl           ; $d22a 22 22 03        ; 
;
; Shared by RUN: set $030F = program start − 1 (so the first
; RST $10 fetch lands on the first token).
;
run_env_reset: ld       hl,($00b2)           ; $d22d 2a b2 00        ; 
             dec      hl                   ; $d230 2b              ; 
;
; Shared CLEAR/RUN/FSET entry that stores the current program pointer in $030F,
; reinitialises the DEFTYPE table at $032A..$0343 to $08, clears CONT / ON ERROR
; bookkeeping, and resets the READ/DATA pointer.
;
ctrl_reset_runtime_state: ld       ($030f),hl           ; $d231 22 0f 03        ; 
             ld       b,$1a                ; $d234 06 1a           ; 
             ld       hl,$032a             ; $d236 21 2a 03        ; 
;
; Inner NEW/RUN reset loop that fills the 26 DEFTYPE slots (A..Z) with $08.
;
deftype_fill_default_double: ld       (hl),$08             ; $d239 36 08           ; 
             inc      hl                   ; $d23b 23              ; 
             djnz     deftype_fill_default_double ; $d23c 10 fb           ; 
             call     fp_load_rnd_seed_constant ; $d23e cd b5 b7        ; 
             xor      a,a                  ; $d241 af              ; 
             ld       ($031b),a            ; $d242 32 1b 03        ; 
             ld       l,a                  ; $d245 6f              ; 
             ld       h,a                  ; $d246 67              ; 
             ld       ($0319),hl           ; $d247 22 19 03        ; 
             ld       ($0320),hl           ; $d24a 22 20 03        ; 
             ld       hl,($01df)           ; $d24d 2a df 01        ; 
             ld       ($0204),hl           ; $d250 22 04 02        ; 
             call     inst_restore         ; $d253 cd 96 d2        ; 
             ld       hl,($0322)           ; $d256 2a 22 03        ; 
             ld       ($0324),hl           ; $d259 22 24 03        ; 
             ld       ($0326),hl           ; $d25c 22 26 03        ; 
;
; Shared warm-restart entry: restore SP from $01DD − 2,
; set stack ceiling ($0313), reset execution pointer $01E1,
; clear $002F (scroll flag), zero string/array housekeeping
; variables, then return HL = $030F (program pointer).
;
warm_restart_env: pop      bc                   ; $d25f c1              ; 
             ld       hl,($01dd)           ; $d260 2a dd 01        ; 
             dec      hl                   ; $d263 2b              ; 
             dec      hl                   ; $d264 2b              ; 
             ld       ($0313),hl           ; $d265 22 13 03        ; 
             inc      hl                   ; $d268 23              ; 
             inc      hl                   ; $d269 23              ; 
jumpd26a:    ld       sp,hl                ; $d26a f9              ; 
             ld       hl,$01e3             ; $d26b 21 e3 01        ; 
             ld       ($01e1),hl           ; $d26e 22 e1 01        ; 
             ld       a,($002f)            ; $d271 3a 2f 00        ; 
             and      a,a                  ; $d274 a7              ; 
             call     z,io_close_channel   ; $d275 cc 9e e8        ; 
             xor      a,a                  ; $d278 af              ; 
             ld       ($002f),a            ; $d279 32 2f 00        ; 
             ld       h,a                  ; $d27c 67              ; 
             ld       l,a                  ; $d27d 6f              ; 
             ld       ($0346),hl           ; $d27e 22 46 03        ; 
             ld       ($0417),a            ; $d281 32 17 04        ; 
             ld       ($03ae),hl           ; $d284 22 ae 03        ; 
             ld       ($041a),hl           ; $d287 22 1a 04        ; 
             ld       ($0344),hl           ; $d28a 22 44 03        ; 
             ld       ($020e),a            ; $d28d 32 0e 02        ; 
             push     hl                   ; $d290 e5              ; 
             push     bc                   ; $d291 c5              ; 
             ld       hl,($030f)           ; $d292 2a 0f 03        ; 
             ret                           ; $d295 c9              ; 

;
; ---------------------------------------------------------------------------
; inst_restore — RESTORE statement
; ---------------------------------------------------------------------------
; RESTORE [line]
; Resets the READ pointer ($0328) so subsequent READs start from the
; beginning of all DATA statements, or from a specific line.
; With no argument (Z set on entry from warm_restart_env): reset to
; program start ($00B2) − 1.
; With a line number: parse with parse_line_number, search backward
; with callf30d (backward line scan), then set $0328 = found_addr − 1.
; Error $08 if the specified line does not exist.
; 
; RESTORE statement.  With no argument: reset DATA pointer ($0328)
; to program start ($00B2) − 1.  With line argument: scan backward
; for that line, error $08 if not found.
;
inst_restore: ex       de,hl                ; $d296 eb              ; 
             ld       hl,($00b2)           ; $d297 2a b2 00        ; 
             jr       z,skipd2aa           ; $d29a 28 0e           ; 
             ex       de,hl                ; $d29c eb              ; 
             call     parse_line_number    ; $d29d cd 95 f5        ; 
             push     hl                   ; $d2a0 e5              ; 
             call     basic_find_line      ; $d2a1 cd 0d f3        ; 
             ld       h,b                  ; $d2a4 60              ; 
             ld       l,c                  ; $d2a5 69              ; 
             pop      de                   ; $d2a6 d1              ; 
             jp       nc,goto_line_not_found ; $d2a7 d2 38 f6        ; 
skipd2aa:    dec      hl                   ; $d2aa 2b              ; 
             ld       ($0328),hl           ; $d2ab 22 28 03        ; 
             ex       de,hl                ; $d2ae eb              ; 
             ret                           ; $d2af c9              ; 

;
; ---------------------------------------------------------------------------
; inst_end / inst_stop — END and STOP statements
; ---------------------------------------------------------------------------
; Both return immediately (RET NZ) if the interpreter is not running in
; direct (line-execute) mode; NZ means "currently parsing, not executing".
; END:  saves the current execution address for CONT, closes any open files
; ($C39D, $E878), resets output channel ($C0F4), pushes a dummy
; return address (jumpd2d7) and falls into the STOP cleanup code.
; STOP: saves HL → $0311 (current execution address), stores $01E3 to $01E1
; (error-line table reset), calls the output-channel-close hook ($E0CC),
; checks flag $00B0 (direct/program mode), prints " STOP " if running,
; then jumps to jumpd2d7.
; 
; jumpd2d7:  the common "program halted" path:
; • Loads $01DB (execution pointer) into HL; saves it.
; • If $01DB ≠ $FFFF, stores it to $031E (CONT address) and saves current
; HL to $0320 (last-line address), enabling a later CONT to resume.
; • Calls $E91D (display "Break in line N" or similar).
; • Branches to BASIC warm-restart via $F16C (STOP) or $F231/$F23C (END).
; 
; END statement.
; Returns immediately (RET NZ) if not in run mode.
; Closes files ($C39D), resets I/O ($E878, $C0F4), then pushes
; jumpd2d7 as return address and falls into the STOP cleanup path
; to save the CONT address and enter the warm-restart loop.
;
inst_end:    ret      nz                   ; $d2b0 c0              ; / ============================================================
                                                                   ; | BASIC statement keyword dispatch table — %CODE targets
                                                                   ; | One 16-bit handler address per keyword (END=0..NEW=57)
                                                                   ; \ ============================================================

             call     hw_audio_reset       ; $d2b1 cd 9d c3        ; 
             call     io_reset_channel_slots ; $d2b4 cd 78 e8        ; 
             call     print_cursor_reset   ; $d2b7 cd f4 c0        ; 
             ld       bc,stop_save_cont_and_restart ; $d2ba 01 d7 d2        ; 
             push     bc                   ; $d2bd c5              ; 
             jr       warm_restart_env     ; $d2be 18 9f           ; 

inst_stop:   ret      nz                   ; $d2c0 c0              ; 

;
; Common END/STOP entry after mode check.
; Saves the current execution position HL to $0311 (temp) and
; stores $01E3 to $01E1 (reset error pointer).
;
stop_save_cont: ld       ($0311),hl           ; $d2c1 22 11 03        ; 
             ld       hl,$01e3             ; $d2c4 21 e3 01        ; 
             ld       ($01e1),hl           ; $d2c7 22 e1 01        ; 
;
; Close any open I/O channel ($E0CC hook), check $00B0:
; if non-zero (running in a program) call $C0EE to print the
; break message, then OR A,$FF (set A = $FF = program-break flag).
;
stop_cleanup: call     cassette_clear_f4_transfer_bits ; $d2ca cd cc e0        ; 
             ld       a,($00b0)            ; $d2cd 3a b0 00        ; 
             or       a,a                  ; $d2d0 b7              ; 
             call     nz,print_pos_clear   ; $d2d1 c4 ee c0        ; 
             or       a,$ff                ; $d2d4 f6 ff           ; 
             pop      bc                   ; $d2d6 c1              ; 
;
; Common halt finalisation: load $01DB (execution pointer).
; If HL ≠ $FFFF, record current position in $031E (CONT address)
; and last-line pointer in $0320.  Calls $E91D to display the
; break/error message, then branches to warm restart.
;
stop_save_cont_and_restart: ld       hl,($01db)           ; $d2d7 2a db 01        ; 
             push     hl                   ; $d2da e5              ; 
             push     af                   ; $d2db f5              ; 
             ld       a,l                  ; $d2dc 7d              ; 
             and      a,h                  ; $d2dd a4              ; 
             inc      a                    ; $d2de 3c              ; 
             jr       z,skipd2ea           ; $d2df 28 09           ; 
             ld       ($031e),hl           ; $d2e1 22 1e 03        ; 
             ld       hl,($0311)           ; $d2e4 2a 11 03        ; 
             ld       ($0320),hl           ; $d2e7 22 20 03        ; 
skipd2ea:    call     io_close_reset_and_crlf ; $d2ea cd 1d e9        ; 
             pop      af                   ; $d2ed f1              ; 
             ld       hl,basic_msg_break   ; $d2ee 21 6c f1        ; 
             jp       nz,basic_break_ready ; $d2f1 c2 31 f2        ; 
             jp       basic_command_loop   ; $d2f4 c3 3c f2        ; 

             defb     $c3,$90,$f5,$f1,$e1,$c9                      ; ......     ; 
calld2fd:    ld       a,(hl)               ; $d2fd 7e              ; 
calld2fe:    cp       a,$41                ; $d2fe fe 41           ; 
             ret      c                    ; $d300 d8              ; 

             cp       a,$5b                ; $d301 fe 5b           ; 
             ccf                           ; $d303 3f              ; 
             ret                           ; $d304 c9              ; 

calld305:    push     hl                   ; $d305 e5              ; 
             and      a,a                  ; $d306 a7              ; 
             sbc      hl,de                ; $d307 ed 52           ; 
             ex       de,hl                ; $d309 eb              ; 
             pop      hl                   ; $d30a e1              ; 
             ret                           ; $d30b c9              ; 

;
; inst_next — NEXT statement
; NEXT [var[, var...]]
; 1. With variable: callb00a to resolve variable → address in DE.
; Without variable (Z): DE = $0000 (match any FOR frame).
; 2. Save HL ($030F = current position); scan the FOR control records on the
; CPU stack (ctrl_scan_for_frames with D:E = variable address).
; If not found: error $01 "NEXT without FOR".
; 3. Restore SP from HL (frame found).
; 4. Read STEP value from frame (offset +1, 1 byte type marker):
; - If type = $81 (integer/integer STEP): use the integer path.
; - If type = float: use the floating-point add/compare path.
; 5. Add STEP to loop variable (callca62 or callcb90).
; 6. Compare updated value against LIMIT:
; - If exit condition reached: pop frame off the stack, continue.
; - Otherwise: restore $01DB from the frame's body address → loop back.
; 7. NEXT var, var2: after exiting the first loop, recurse (calld30f).
; 
; NEXT statement.  Resolves optional variable (DE = address or 0).
; Scans FOR stack; error $01 if no matching frame.
; Adds STEP to loop variable; if exit condition: pop frame and
; continue.  Otherwise jump back to loop body.
;
inst_next:   ld       de,$0000             ; $d30c 11 00 00        ; 
;
; Shared NEXT entry used both for the first variable and for chained
; `NEXT i,j,...`.  Resolves the optional variable name, saves the token
; pointer, and locates the matching FOR frame on the CPU stack.
;
next_resolve_var_and_find_for: call     nz,lookup_or_create_var ; $d30f c4 0a b0        ; 
             ld       ($030f),hl           ; $d312 22 0f 03        ; 
             call     ctrl_scan_for_frames ; $d315 cd 72 f1        ; 
             jp       nz,basic_raise_error_01 ; $d318 c2 b0 f1        ; 
             ld       sp,hl                ; $d31b f9              ; 
             push     de                   ; $d31c d5              ; 
             ld       a,(hl)               ; $d31d 7e              ; 
             push     af                   ; $d31e f5              ; 
             inc      hl                   ; $d31f 23              ; 
             push     de                   ; $d320 d5              ; 
             ld       a,(hl)               ; $d321 7e              ; 
             inc      hl                   ; $d322 23              ; 
             or       a,a                  ; $d323 b7              ; 
             jp       m,next_float_step_and_compare ; $d324 fa 50 d3        ; 
             dec      a                    ; $d327 3d              ; 
             jr       nz,skipd32e          ; $d328 20 04           ; 
             ld       bc,rst0008           ; $d32a 01 08 00        ; 
             add      hl,bc                ; $d32d 09              ; 
skipd32e:    add      a,$04                ; $d32e c6 04           ; 
             ld       ($01d9),a            ; $d330 32 d9 01        ; 
             call     callca62             ; $d333 cd 62 ca        ; 
             ex       de,hl                ; $d336 eb              ; 
             ex       (sp),hl              ; $d337 e3              ; 
             push     hl                   ; $d338 e5              ; 
             rst      rst0030              ; $d339 f7              ; 
             jr       nc,next_int_step_and_compare ; $d33a 30 4e           ; 
             call     callca30             ; $d33c cd 30 ca        ; 
             call     fp_add_int_work_operands ; $d33f cd a9 cd        ; 
             pop      hl                   ; $d342 e1              ; 
             call     callca42             ; $d343 cd 42 ca        ; 
             pop      hl                   ; $d346 e1              ; 
             call     callca39             ; $d347 cd 39 ca        ; 
             push     hl                   ; $d34a e5              ; 
             call     callca7b             ; $d34b cd 7b ca        ; 
             jr       next_test_loop_continue ; $d34e 18 29           ; 

;
; Floating-point NEXT path.  Loads the saved loop limit and body pointer from
; the FOR frame, adds the floating STEP to the control variable, writes the
; updated value back, then compares it against the loop limit.
;
next_float_step_and_compare: ld       bc,$000c             ; $d350 01 0c 00        ; 
             add      hl,bc                ; $d353 09              ; 
             ld       c,(hl)               ; $d354 4e              ; 
             inc      hl                   ; $d355 23              ; 
             ld       b,(hl)               ; $d356 46              ; 
             inc      hl                   ; $d357 23              ; 
             ex       (sp),hl              ; $d358 e3              ; 
             ld       e,(hl)               ; $d359 5e              ; 
             inc      hl                   ; $d35a 23              ; 
             ld       d,(hl)               ; $d35b 56              ; 
             push     hl                   ; $d35c e5              ; 
             ld       l,c                  ; $d35d 69              ; 
             ld       h,b                  ; $d35e 60              ; 
             call     num_add_int_or_promote ; $d35f cd c6 cc        ; 
             ld       a,($01d9)            ; $d362 3a d9 01        ; 
             cp       a,$04                ; $d365 fe 04           ; 
             jp       z,basic_raise_error_06 ; $d367 ca bc f1        ; 
             ex       de,hl                ; $d36a eb              ; 
             pop      hl                   ; $d36b e1              ; 
             ld       (hl),d               ; $d36c 72              ; 
             dec      hl                   ; $d36d 2b              ; 
             ld       (hl),e               ; $d36e 73              ; 
             pop      hl                   ; $d36f e1              ; 
             push     de                   ; $d370 d5              ; 
             ld       e,(hl)               ; $d371 5e              ; 
             inc      hl                   ; $d372 23              ; 
             ld       d,(hl)               ; $d373 56              ; 
             inc      hl                   ; $d374 23              ; 
             ex       (sp),hl              ; $d375 e3              ; 
             call     int16_compare_hl_de  ; $d376 cd a5 ca        ; 
;
; Shared NEXT decision tail.  Uses the comparison result to decide whether
; to loop again (restore $01DB from the frame's body pointer) or to fall
; through to frame removal.
;
next_test_loop_continue: pop      hl                   ; $d379 e1              ; 
             pop      bc                   ; $d37a c1              ; 
             sub      a,b                  ; $d37b 90              ; 
             call     callca39             ; $d37c cd 39 ca        ; 
             jr       z,next_pop_for_frame ; $d37f 28 1a           ; 
             ex       de,hl                ; $d381 eb              ; 
             ld       ($01db),hl           ; $d382 22 db 01        ; 
             ld       l,c                  ; $d385 69              ; 
             ld       h,b                  ; $d386 60              ; 
             jp       for_push_frame_tag   ; $d387 c3 cd f4        ; 

;
; Integer NEXT path.  Adds the saved integer STEP to the loop variable,
; compares the updated value against the integer limit, then rejoins the
; common loop/exit decision code at next_test_loop_continue.
;
next_int_step_and_compare: call     callb20b             ; $d38a cd 0b b2        ; 
             pop      hl                   ; $d38d e1              ; 
             call     callca6a             ; $d38e cd 6a ca        ; 
             pop      hl                   ; $d391 e1              ; 
             call     callca49             ; $d392 cd 49 ca        ; 
             push     de                   ; $d395 d5              ; 
             call     fp_compare_work_and_main ; $d396 cd b4 ca        ; 
             jr       next_test_loop_continue ; $d399 18 de           ; 

;
; NEXT loop-exit cleanup.  Drops the matched FOR frame by restoring SP / $0313,
; then checks for a trailing comma so `NEXT i,j` can continue with the next
; control variable.
;
next_pop_for_frame: ld       sp,hl                ; $d39b f9              ; 
             ld       ($0313),hl           ; $d39c 22 13 03        ; 
             ex       de,hl                ; $d39f eb              ; 
             ld       hl,($030f)           ; $d3a0 2a 0f 03        ; 
             ld       a,(hl)               ; $d3a3 7e              ; 
             cp       a,$2c                ; $d3a4 fe 2c           ; 
             jp       nz,basic_exec_statement_loop ; $d3a6 c2 d1 f4        ; 
             rst      rst0010              ; $d3a9 d7              ; 
             call     next_resolve_var_and_find_for ; $d3aa cd 0f d3        ; 
             call     fp_store_int_operands_to_work ; $d3ad cd db cd        ; 
             call     fp_clear_extended_mantissa ; $d3b0 cd 98 cb        ; 
             call     fp_push_extended_tail ; $d3b3 cd 76 b8        ; 
             call     fp_with_saved_operand ; $d3b6 cd 1c b8        ; 
             call     fp_push_work         ; $d3b9 cd 8b b8        ; 
             ld       a,($049f)            ; $d3bc 3a 9f 04        ; 
             or       a,a                  ; $d3bf b7              ; 
             jr       z,skipd424           ; $d3c0 28 62           ; 
             ld       h,a                  ; $d3c2 67              ; 
             ld       a,($044e)            ; $d3c3 3a 4e 04        ; 
             or       a,a                  ; $d3c6 b7              ; 
             jr       z,skipd42d           ; $d3c7 28 64           ; 
             call     fp_push_main         ; $d3c9 cd 7b b8        ; 
             call     calld4f7             ; $d3cc cd f7 d4        ; 
             jr       c,skipd40b           ; $d3cf 38 3a           ; 
             ex       de,hl                ; $d3d1 eb              ; 
             ld       ($0208),hl           ; $d3d2 22 08 02        ; 
             call     fp_set_double_precision ; $d3d5 cd a5 cb        ; 
             call     fp_push_work         ; $d3d8 cd 8b b8        ; 
             call     calld4f7             ; $d3db cd f7 d4        ; 
             call     fp_set_double_precision ; $d3de cd a5 cb        ; 
             ld       hl,($0208)           ; $d3e1 2a 08 02        ; 
             jr       nc,skipd43a          ; $d3e4 30 54           ; 
             ld       a,($049f)            ; $d3e6 3a 9f 04        ; 
             push     af                   ; $d3e9 f5              ; 
             push     hl                   ; $d3ea e5              ; 
             call     jumpb807             ; $d3eb cd 07 b8        ; 
             ld       hl,$041d             ; $d3ee 21 1d 04        ; 
             call     callb814             ; $d3f1 cd 14 b8        ; 
             ld       hl,$b8cb             ; $d3f4 21 cb b8        ; 
             call     callb80a             ; $d3f7 cd 0a b8        ; 
             pop      hl                   ; $d3fa e1              ; 
             ld       a,h                  ; $d3fb 7c              ; 
             or       a,a                  ; $d3fc b7              ; 
             push     af                   ; $d3fd f5              ; 
             jp       p,jumpd408           ; $d3fe f2 08 d4        ; 
             xor      a,a                  ; $d401 af              ; 
             ld       c,a                  ; $d402 4f              ; 
             sub      a,l                  ; $d403 95              ; 
             ld       l,a                  ; $d404 6f              ; 
             ld       a,c                  ; $d405 79              ; 
             sbc      a,h                  ; $d406 9c              ; 
             ld       h,a                  ; $d407 67              ; 
jumpd408:    push     hl                   ; $d408 e5              ; 
             jr       skipd474             ; $d409 18 69           ; 

skipd40b:    call     fp_set_double_precision ; $d40b cd a5 cb        ; 
             call     jumpb807             ; $d40e cd 07 b8        ; 
             call     fp_with_saved_operand ; $d411 cd 1c b8        ; 
             call     fn_log               ; $d414 cd 09 b6        ; 
             call     fp_push_work         ; $d417 cd 8b b8        ; 
             call     fp_multiply_main_work ; $d41a cd 76 b3        ; 
             jp       fn_exp               ; $d41d c3 dd b6        ; 

             defb     $7c,$b5,$20,$05                              ; |...       ; 
skipd424:    ld       hl,$0001             ; $d424 21 01 00        ; 
             jr       skipd437             ; $d427 18 0e           ; 

             defb     $7a,$b3,$20,$0d                              ; z...       ; 
skipd42d:    ld       a,h                  ; $d42d 7c              ; 
             rla                           ; $d42e 17              ; 
             jr       nc,skipd434          ; $d42f 30 03           ; 
             jp       basic_raise_error_0b ; $d431 c3 ad f1        ; 

skipd434:    ld       hl,$0000             ; $d434 21 00 00        ; 
skipd437:    jp       num_store_int_result ; $d437 c3 ef ca        ; 

skipd43a:    ld       ($0208),hl           ; $d43a 22 08 02        ; 
             push     de                   ; $d43d d5              ; 
             ld       a,h                  ; $d43e 7c              ; 
             or       a,a                  ; $d43f b7              ; 
             push     af                   ; $d440 f5              ; 
             call     m,num_negate_hl_store_int ; $d441 fc 7c cd        ; 
             ld       b,h                  ; $d444 44              ; 
             ld       c,l                  ; $d445 4d              ; 
             ld       hl,$0001             ; $d446 21 01 00        ; 
loopd449:    or       a,a                  ; $d449 b7              ; 
             ld       a,b                  ; $d44a 78              ; 
             rra                           ; $d44b 1f              ; 
             ld       b,a                  ; $d44c 47              ; 
             ld       a,c                  ; $d44d 79              ; 
             rra                           ; $d44e 1f              ; 
             ld       c,a                  ; $d44f 4f              ; 
             jr       nc,skipd457          ; $d450 30 05           ; 
             call     calld4ea             ; $d452 cd ea d4        ; 
             jr       nz,skipd4a3          ; $d455 20 4c           ; 
skipd457:    ld       a,b                  ; $d457 78              ; 
             or       a,c                  ; $d458 b1              ; 
             jr       z,skipd4bb           ; $d459 28 60           ; 
             push     hl                   ; $d45b e5              ; 
             ld       h,d                  ; $d45c 62              ; 
             ld       l,e                  ; $d45d 6b              ; 
             call     calld4ea             ; $d45e cd ea d4        ; 
             ex       de,hl                ; $d461 eb              ; 
             pop      hl                   ; $d462 e1              ; 
             jr       z,loopd449           ; $d463 28 e4           ; 
             push     bc                   ; $d465 c5              ; 
             push     hl                   ; $d466 e5              ; 
             ld       hl,$041d             ; $d467 21 1d 04        ; 
             call     callb814             ; $d46a cd 14 b8        ; 
             pop      hl                   ; $d46d e1              ; 
             call     callcb21             ; $d46e cd 21 cb        ; 
             call     fp_clear_extended_mantissa ; $d471 cd 98 cb        ; 
skipd474:    pop      bc                   ; $d474 c1              ; 
             ld       a,b                  ; $d475 78              ; 
             or       a,a                  ; $d476 b7              ; 
             rra                           ; $d477 1f              ; 
             ld       b,a                  ; $d478 47              ; 
             ld       a,c                  ; $d479 79              ; 
             rra                           ; $d47a 1f              ; 
             ld       c,a                  ; $d47b 4f              ; 
             jr       nc,skipd486          ; $d47c 30 08           ; 
             push     bc                   ; $d47e c5              ; 
             ld       hl,$041d             ; $d47f 21 1d 04        ; 
             call     fp_mul_with_operand  ; $d482 cd d4 b7        ; 
             pop      bc                   ; $d485 c1              ; 
skipd486:    ld       a,b                  ; $d486 78              ; 
             or       a,c                  ; $d487 b1              ; 
             jr       z,skipd4bb           ; $d488 28 31           ; 
             push     bc                   ; $d48a c5              ; 
             call     fp_push_main         ; $d48b cd 7b b8        ; 
             ld       hl,$041d             ; $d48e 21 1d 04        ; 
             push     hl                   ; $d491 e5              ; 
             call     callb80a             ; $d492 cd 0a b8        ; 
             pop      hl                   ; $d495 e1              ; 
             push     hl                   ; $d496 e5              ; 
             call     fp_mul_with_operand  ; $d497 cd d4 b7        ; 
             pop      hl                   ; $d49a e1              ; 
             call     callb814             ; $d49b cd 14 b8        ; 
             call     fp_pop_main          ; $d49e cd 91 b8        ; 
             jr       skipd474             ; $d4a1 18 d1           ; 

skipd4a3:    push     bc                   ; $d4a3 c5              ; 
             push     de                   ; $d4a4 d5              ; 
             call     callb7fb             ; $d4a5 cd fb b7        ; 
             pop      hl                   ; $d4a8 e1              ; 
             call     callcb21             ; $d4a9 cd 21 cb        ; 
             call     fp_clear_extended_mantissa ; $d4ac cd 98 cb        ; 
             ld       hl,$041d             ; $d4af 21 1d 04        ; 
             call     callb814             ; $d4b2 cd 14 b8        ; 
             call     jumpb807             ; $d4b5 cd 07 b8        ; 
             pop      bc                   ; $d4b8 c1              ; 
             jr       skipd486             ; $d4b9 18 cb           ; 

skipd4bb:    pop      af                   ; $d4bb f1              ; 
             pop      bc                   ; $d4bc c1              ; 
             ret      p                    ; $d4bd f0              ; 

             ld       a,($01d9)            ; $d4be 3a d9 01        ; 
             cp       a,$02                ; $d4c1 fe 02           ; 
             jr       nz,skipd4cd          ; $d4c3 20 08           ; 
             push     bc                   ; $d4c5 c5              ; 
             call     callcb21             ; $d4c6 cd 21 cb        ; 
             call     fp_clear_extended_mantissa ; $d4c9 cd 98 cb        ; 
             pop      bc                   ; $d4cc c1              ; 
skipd4cd:    ld       a,($044e)            ; $d4cd 3a 4e 04        ; 
             or       a,a                  ; $d4d0 b7              ; 
             jr       nz,skipd4de          ; $d4d1 20 0b           ; 
             ld       hl,($0208)           ; $d4d3 2a 08 02        ; 
             or       a,h                  ; $d4d6 b4              ; 
             ret      p                    ; $d4d7 f0              ; 

             ld       a,l                  ; $d4d8 7d              ; 
             rrca                          ; $d4d9 0f              ; 
             and      a,b                  ; $d4da a0              ; 
             jp       basic_raise_error_06 ; $d4db c3 bc f1        ; 

skipd4de:    call     callb7fb             ; $d4de cd fb b7        ; 
             ld       hl,$b8cb             ; $d4e1 21 cb b8        ; 
             call     callb80a             ; $d4e4 cd 0a b8        ; 
             jp       jumpb42f             ; $d4e7 c3 2f b4        ; 

calld4ea:    push     bc                   ; $d4ea c5              ; 
             push     de                   ; $d4eb d5              ; 
             call     num_mul_int_or_promote ; $d4ec cd e7 cc        ; 
             ld       a,($01d9)            ; $d4ef 3a d9 01        ; 
             cp       a,$02                ; $d4f2 fe 02           ; 
             pop      de                   ; $d4f4 d1              ; 
             pop      bc                   ; $d4f5 c1              ; 
             ret                           ; $d4f6 c9              ; 

calld4f7:    call     jumpb807             ; $d4f7 cd 07 b8        ; 
             call     fp_push_extended_tail ; $d4fa cd 76 b8        ; 
             call     fn_int               ; $d4fd cd 23 cc        ; 
             call     fp_push_work         ; $d500 cd 8b b8        ; 
             call     fp_compare_work_and_main ; $d503 cd b4 ca        ; 
             scf                           ; $d506 37              ; 
             ret      nz                   ; $d507 c0              ; 

             jp       fp_to_int16          ; $d508 c3 b3 cb        ; 

             defb     $cd,$01,$d7                                  ; ...        ; 
             defm     "~#N#F"                                                   ;
             defb     $d1,$c5,$f5,$cd,$08,$d7,$f1                  ; .......    ; 
             defm     "W^#N#F"                                                  ;
             defb     $e1,$7b,$b2,$c8,$7a,$d6,$01,$d8,$af,$bb      ; .{..z..... ; 
             defb     $3c,$d0,$15,$1d,$0a,$03,$be,$23,$28,$ed      ; <......#(. ; 
             defb     $3f,$c3,$d3,$c9                              ; ?...       ; 
;
; fn_hex — HEX$ function
; HEX$(expr) — return the hexadecimal string representation
; of the integer value of expr (e.g. HEX$(255) → "FF").
; CALL $BEA1: convert the integer in the FP accumulator to
; a hex-ASCII string in the output buffer.
; JR +3: skip the STR$ decimal-conversion call at fn_str
; and jump directly to the shared string-allocation and
; descriptor-build code (common with STR$).
; 
; ; ============================================================
; ; STR$ handler ($D53D)
; ; ============================================================
;
fn_hex:      call     callbea1             ; $d538 cd a1 be        ; 
             jr       skipd540             ; $d53b 18 03           ; 

;
; fn_str — STR$ function
; STR$(expr) — return the decimal string representation of
; a numeric value (e.g. STR$(3.14) → " 3.14").
; CALL callbbab: convert the FP accumulator to a decimal
; ASCII string in the output buffer.
; Falls through to shared string-allocation code (also
; used by HEX$) that calls calld56e and calld704 to build
; the string descriptor and return it.
;
fn_str:      call     str_format_number    ; $d53d cd ab bb        ; 
skipd540:    call     str_scan_literal     ; $d540 cd 6e d5        ; 
             call     str_load_result_descriptor ; $d543 cd 04 d7        ; 
             ld       bc,loopd832          ; $d546 01 32 d8        ; 
             push     bc                   ; $d549 c5              ; 
calld54a:    ld       a,(hl)               ; $d54a 7e              ; 
             inc      hl                   ; $d54b 23              ; 
             push     hl                   ; $d54c e5              ; 
             call     str_alloc_temp       ; $d54d cd c2 d5        ; 
             pop      hl                   ; $d550 e1              ; 
             ld       c,(hl)               ; $d551 4e              ; 
             inc      hl                   ; $d552 23              ; 
             ld       b,(hl)               ; $d553 46              ; 
             call     str_set_temp_descriptor ; $d554 cd 63 d5        ; 
             push     hl                   ; $d557 e5              ; 
             ld       l,a                  ; $d558 6f              ; 
             call     str_copy_chars       ; $d559 cd f8 d6        ; 
             pop      de                   ; $d55c d1              ; 
             ret                           ; $d55d c9              ; 

;
; ----
; str_make_char — allocate a one-character temporary string
; ----
; Sets A=1 and reuses the generic temporary-string allocator so CHR$
; and related code can materialise a single-byte string result.
;
str_make_char: ld       a,$01                ; $d55e 3e 01           ; 
calld560:    call     str_alloc_temp       ; $d560 cd c2 d5        ; 
;
; ----
; str_set_temp_descriptor — write length/pointer descriptor at $0201
; ----
; Stores the current string length in A and the heap pointer in DE into
; the standard temporary-string descriptor used by BASIC string results.
;
str_set_temp_descriptor: ld       hl,$0201             ; $d563 21 01 02        ; 
             push     hl                   ; $d566 e5              ; 
             ld       (hl),a               ; $d567 77              ; 
             inc      hl                   ; $d568 23              ; 
             ld       (hl),e               ; $d569 73              ; 
             inc      hl                   ; $d56a 23              ; 
             ld       (hl),d               ; $d56b 72              ; 
             pop      hl                   ; $d56c e1              ; 
             ret                           ; $d56d c9              ; 

;
; ----
; str_scan_literal — measure inline string text and build descriptor
; ----
; Scans forward until NUL or a quote delimiter, counts the byte length,
; then returns a descriptor for the literal text without copying it yet.
;
str_scan_literal: dec      hl                   ; $d56e 2b              ; 
calld56f:    ld       b,$22                ; $d56f 06 22           ; 
calld571:    ld       d,b                  ; $d571 50              ; 
calld572:    push     hl                   ; $d572 e5              ; 
             ld       c,$ff                ; $d573 0e ff           ; 
loopd575:    inc      hl                   ; $d575 23              ; 
             ld       a,(hl)               ; $d576 7e              ; 
             inc      c                    ; $d577 0c              ; 
             or       a,a                  ; $d578 b7              ; 
             jr       z,skipd581           ; $d579 28 06           ; 
             cp       a,d                  ; $d57b ba              ; 
             jr       z,skipd581           ; $d57c 28 03           ; 
             cp       a,b                  ; $d57e b8              ; 
             jr       nz,loopd575          ; $d57f 20 f4           ; 
skipd581:    cp       a,$22                ; $d581 fe 22           ; 
             call     z,rst10_fetch_token  ; $d583 cc 37 f5        ; 
             ex       (sp),hl              ; $d586 e3              ; 
             inc      hl                   ; $d587 23              ; 
             ex       de,hl                ; $d588 eb              ; 
             ld       a,c                  ; $d589 79              ; 
             call     str_set_temp_descriptor ; $d58a cd 63 d5        ; 
jumpd58d:    ld       de,$0201             ; $d58d 11 01 02        ; 
             defb     $3e                  ; $d590 3e d5           ;   As: ld     a,$d5      ; 3e d5      ; Next: $d592
calld591:    push     de                   ; $d591 d5              ; 
             ld       hl,($01e1)           ; $d592 2a e1 01        ; 
             ld       ($0450),hl           ; $d595 22 50 04        ; 
             ld       a,$03                ; $d598 3e 03           ; 
             ld       ($01d9),a            ; $d59a 32 d9 01        ; 
             call     callca4d             ; $d59d cd 4d ca        ; 
             ld       de,$0204             ; $d5a0 11 04 02        ; 
             rst      rst0020              ; $d5a3 e7              ; 
             ld       ($01e1),hl           ; $d5a4 22 e1 01        ; 
             pop      hl                   ; $d5a7 e1              ; 
             ld       a,(hl)               ; $d5a8 7e              ; 
             ret      nz                   ; $d5a9 c0              ; 

             ld       de,rst0010           ; $d5aa 11 10 00        ; 
             jp       basic_raise_error    ; $d5ad c3 c7 f1        ; 

             defb     $23                                          ; #          ; 
;
; PRINT helper: run str_scan_literal, then fall through to the common
; descriptor-output path so inline literals and prebuilt buffers can be
; emitted by the same character loop.
;
print_prepare_string_item: call     str_scan_literal     ; $d5b1 cd 6e d5        ; 
;
; Common string-descriptor emitter for PRINT-family code.  Loads the
; descriptor from $0450 / BC and outputs D bytes through RST $28.
; Used by plain PRINT, PRINT USING string fields, and READY/break text.
;
print_emit_string_item: call     str_load_result_descriptor ; $d5b4 cd 04 d7        ; 
             call     callca3b             ; $d5b7 cd 3b ca        ; 
             inc      d                    ; $d5ba 14              ; 
loopd5bb:    dec      d                    ; $d5bb 15              ; 
             ret      z                    ; $d5bc c8              ; 

             ld       a,(bc)               ; $d5bd 0a              ; 
             rst      rst0028              ; $d5be ef              ; 
             inc      bc                   ; $d5bf 03              ; 
             jr       loopd5bb             ; $d5c0 18 f9           ; 

;
; ----
; str_alloc_temp — allocate temporary string space from the string heap
; ----
; Reserves A bytes from the temporary-string area tracked by $0204,
; checks for heap/stack collision via RST $20, and returns DE pointing
; at the allocated payload.
;
str_alloc_temp: or       a,a                  ; $d5c2 b7              ; 
             ld       c,$f1                ; $d5c3 0e f1           ; 
             push     af                   ; $d5c5 f5              ; 
             ld       hl,($01dd)           ; $d5c6 2a dd 01        ; 
             ex       de,hl                ; $d5c9 eb              ; 
             ld       hl,($0204)           ; $d5ca 2a 04 02        ; 
             cpl                           ; $d5cd 2f              ; 
             ld       c,a                  ; $d5ce 4f              ; 
             ld       b,$ff                ; $d5cf 06 ff           ; 
             add      hl,bc                ; $d5d1 09              ; 
             inc      hl                   ; $d5d2 23              ; 
             rst      rst0020              ; $d5d3 e7              ; 
             jr       c,str_gc_raise_oom   ; $d5d4 38 07           ; 
             ld       ($0204),hl           ; $d5d6 22 04 02        ; 
             inc      hl                   ; $d5d9 23              ; 
             ex       de,hl                ; $d5da eb              ; 
jumpd5db:    pop      af                   ; $d5db f1              ; 
             ret                           ; $d5dc c9              ; 

;
; Allocation-failure tail for str_alloc_temp.
; Restores the saved request length/flags and raises BASIC error $000E
; if the temp-string collector still cannot make enough room.
;
str_gc_raise_oom: pop      af                   ; $d5dd f1              ; 
             ld       de,$000e             ; $d5de 11 0e 00        ; 
             jp       z,basic_raise_error  ; $d5e1 ca c7 f1        ; 
             cp       a,a                  ; $d5e4 bf              ; 
             push     af                   ; $d5e5 f5              ; 
             ld       bc,$d5c4             ; $d5e6 01 c4 d5        ; 
             push     bc                   ; $d5e9 c5              ; 
;
; ----
; str_gc_collect — compact the temporary-string arena
; ----
; Resets the temp frontier to the base at $01DF, then walks the live
; descriptor roots used by the evaluator, variables, arrays, and the
; variable/string area, relocating any temp-string payloads that still
; fall in the old arena and rewriting their descriptors in place.
;
str_gc_collect: ld       hl,($01df)           ; $d5ea 2a df 01        ; 
;
; Shared entry used by the collector and relocation tail.
; Stores HL into $0204 so the temp-string arena starts compacting from
; the current destination pointer.
;
str_gc_reset_temp_frontier: ld       ($0204),hl           ; $d5ed 22 04 02        ; 
             ld       hl,$0000             ; $d5f0 21 00 00        ; 
             push     hl                   ; $d5f3 e5              ; 
             ld       hl,($0326)           ; $d5f4 2a 26 03        ; 
             push     hl                   ; $d5f7 e5              ; 
;
; Collector root-scan entry for the temporary descriptor stack rooted at
; $01E1/$01E3.  If descriptors are present, falls into the common
; relocation test; otherwise skips ahead to variable-root scanning.
;
str_gc_scan_temp_descriptors: ld       hl,$01e3             ; $d5f8 21 e3 01        ; 
             ld       de,($01e1)           ; $d5fb ed 5b e1 01     ; 
             rst      rst0020              ; $d5ff e7              ; 
             ld       bc,$d5fb             ; $d600 01 fb d5        ; 
             jr       nz,skipd674          ; $d603 20 6f           ; 
;
; Initialise the GC walk across scalar variables.
; Seeds the work pointers at $0418/$0415 from $0324, then starts
; scanning variable records from $0322 for string descriptors.
;
str_gc_scan_scalar_vars: ld       hl,$03ac             ; $d605 21 ac 03        ; 
             ld       ($0418),hl           ; $d608 22 18 04        ; 
             ld       hl,($0324)           ; $d60b 2a 24 03        ; 
             ld       ($0415),hl           ; $d60e 22 15 04        ; 
             ld       hl,($0322)           ; $d611 2a 22 03        ; 
;
; Main scalar-variable GC loop.
; Walks each variable record, and when the type byte is $03, dispatches
; the embedded string descriptor through the common relocation helper.
;
str_gc_scan_scalar_loop: ld       de,($0415)           ; $d614 ed 5b 15 04     ; 
             rst      rst0020              ; $d618 e7              ; 
             jr       z,str_gc_scan_array_descriptors ; $d619 28 12           ; 
             ld       a,(hl)               ; $d61b 7e              ; 
             inc      hl                   ; $d61c 23              ; 
             inc      hl                   ; $d61d 23              ; 
             inc      hl                   ; $d61e 23              ; 
             cp       a,$03                ; $d61f fe 03           ; 
             jr       nz,skipd627          ; $d621 20 04           ; 
             call     str_gc_relocate_if_temp ; $d623 cd 75 d6        ; 
             xor      a,a                  ; $d626 af              ; 
skipd627:    ld       e,a                  ; $d627 5f              ; 
             ld       d,$00                ; $d628 16 00           ; 
             add      hl,de                ; $d62a 19              ; 
             jr       str_gc_scan_scalar_loop ; $d62b 18 e7           ; 

;
; Continue the GC pass through the array/string-descriptor chains above
; the scalar table.  Follows the linked records via $0418/$0415 and
; feeds string entries into the same relocation path.
;
str_gc_scan_array_descriptors: ld       hl,($0418)           ; $d62d 2a 18 04        ; 
             ld       e,(hl)               ; $d630 5e              ; 
             inc      hl                   ; $d631 23              ; 
             ld       d,(hl)               ; $d632 56              ; 
             ld       a,d                  ; $d633 7a              ; 
             or       a,e                  ; $d634 b3              ; 
             ld       hl,($0324)           ; $d635 2a 24 03        ; 
             jr       z,str_gc_scan_var_string_area ; $d638 28 13           ; 
             ex       de,hl                ; $d63a eb              ; 
             ld       ($0418),hl           ; $d63b 22 18 04        ; 
             inc      hl                   ; $d63e 23              ; 
             inc      hl                   ; $d63f 23              ; 
             ld       e,(hl)               ; $d640 5e              ; 
             inc      hl                   ; $d641 23              ; 
             ld       d,(hl)               ; $d642 56              ; 
             inc      hl                   ; $d643 23              ; 
             ex       de,hl                ; $d644 eb              ; 
             add      hl,de                ; $d645 19              ; 
             ld       ($0415),hl           ; $d646 22 15 04        ; 
             ex       de,hl                ; $d649 eb              ; 
             jr       str_gc_scan_scalar_loop ; $d64a 18 c8           ; 

loopd64c:    pop      bc                   ; $d64c c1              ; 
;
; Final collector scan over the variable/string arena up to $0326.
; Reads descriptor-shaped entries, checks whether they point into the
; old temp arena, and compacts live strings when needed.
;
str_gc_scan_var_string_area: ld       de,($0326)           ; $d64d ed 5b 26 03     ; 
             rst      rst0020              ; $d651 e7              ; 
             jr       z,skipd695           ; $d652 28 41           ; 
             ld       a,(hl)               ; $d654 7e              ; 
             inc      hl                   ; $d655 23              ; 
             call     callca39             ; $d656 cd 39 ca        ; 
             push     hl                   ; $d659 e5              ; 
             add      hl,bc                ; $d65a 09              ; 
             cp       a,$03                ; $d65b fe 03           ; 
             jr       nz,loopd64c          ; $d65d 20 ed           ; 
             ld       ($0208),hl           ; $d65f 22 08 02        ; 
             pop      hl                   ; $d662 e1              ; 
             ld       c,(hl)               ; $d663 4e              ; 
             ld       b,$00                ; $d664 06 00           ; 
             add      hl,bc                ; $d666 09              ; 
             add      hl,bc                ; $d667 09              ; 
             inc      hl                   ; $d668 23              ; 
             ex       de,hl                ; $d669 eb              ; 
             ld       hl,($0208)           ; $d66a 2a 08 02        ; 
             ex       de,hl                ; $d66d eb              ; 
             rst      rst0020              ; $d66e e7              ; 
             jr       z,str_gc_scan_var_string_area ; $d66f 28 dc           ; 
             ld       bc,$d669             ; $d671 01 69 d6        ; 
skipd674:    push     bc                   ; $d674 c5              ; 
;
; Shared descriptor test for the collector.
; Given HL at a 3-byte string descriptor, returns immediately for empty
; strings or payloads already outside the temp arena; otherwise rewrites
; the descriptor so its payload is copied to the new compacted frontier.
;
str_gc_relocate_if_temp: xor      a,a                  ; $d675 af              ; 
             or       a,(hl)               ; $d676 b6              ; 
             inc      hl                   ; $d677 23              ; 
             ld       e,(hl)               ; $d678 5e              ; 
             inc      hl                   ; $d679 23              ; 
             ld       d,(hl)               ; $d67a 56              ; 
             inc      hl                   ; $d67b 23              ; 
             ret      z                    ; $d67c c8              ; 

             ld       b,h                  ; $d67d 44              ; 
             ld       c,l                  ; $d67e 4d              ; 
             ld       hl,($0204)           ; $d67f 2a 04 02        ; 
             rst      rst0020              ; $d682 e7              ; 
             ld       h,b                  ; $d683 60              ; 
             ld       l,c                  ; $d684 69              ; 
             ret      c                    ; $d685 d8              ; 

             pop      hl                   ; $d686 e1              ; 
             ex       (sp),hl              ; $d687 e3              ; 
             rst      rst0020              ; $d688 e7              ; 
             ex       (sp),hl              ; $d689 e3              ; 
             push     hl                   ; $d68a e5              ; 
             ld       h,b                  ; $d68b 60              ; 
             ld       l,c                  ; $d68c 69              ; 
             ret      nc                   ; $d68d d0              ; 

             pop      bc                   ; $d68e c1              ; 
             pop      af                   ; $d68f f1              ; 
             pop      af                   ; $d690 f1              ; 
             push     hl                   ; $d691 e5              ; 
             push     de                   ; $d692 d5              ; 
             push     bc                   ; $d693 c5              ; 
             ret                           ; $d694 c9              ; 

skipd695:    pop      de                   ; $d695 d1              ; 
             pop      hl                   ; $d696 e1              ; 
             ld       a,h                  ; $d697 7c              ; 
             or       a,l                  ; $d698 b5              ; 
             ret      z                    ; $d699 c8              ; 

             dec      hl                   ; $d69a 2b              ; 
             ld       b,(hl)               ; $d69b 46              ; 
             dec      hl                   ; $d69c 2b              ; 
             ld       c,(hl)               ; $d69d 4e              ; 
             push     hl                   ; $d69e e5              ; 
             dec      hl                   ; $d69f 2b              ; 
;
; Low-level relocation tail used by str_gc_relocate_if_temp.
; Recomputes the new end pointer, backward-copies the live payload into
; the compacted temp arena, stores the new descriptor address, then
; jumps back through str_gc_reset_temp_frontier.
;
str_gc_move_temp_string: ld       l,(hl)               ; $d6a0 6e              ; 
             ld       h,$00                ; $d6a1 26 00           ; 
             add      hl,bc                ; $d6a3 09              ; 
             ld       d,b                  ; $d6a4 50              ; 
             ld       e,c                  ; $d6a5 59              ; 
             dec      hl                   ; $d6a6 2b              ; 
             ld       b,h                  ; $d6a7 44              ; 
             ld       c,l                  ; $d6a8 4d              ; 
             ld       hl,($0204)           ; $d6a9 2a 04 02        ; 
             call     move_block_up_backward_until ; $d6ac cd 6d d1        ; 
             pop      hl                   ; $d6af e1              ; 
             ld       (hl),c               ; $d6b0 71              ; 
             inc      hl                   ; $d6b1 23              ; 
             ld       (hl),b               ; $d6b2 70              ; 
             ld       h,b                  ; $d6b3 60              ; 
             ld       l,c                  ; $d6b4 69              ; 
             dec      hl                   ; $d6b5 2b              ; 
             jp       str_gc_reset_temp_frontier ; $d6b6 c3 ed d5        ; 

;
; expr_concat_strings — string-concatenation path for the `+` operator
; Selected by the expression evaluator when token $d1 (`+`) is applied to
; a string-typed left operand ($01d9 = $03).
; Evaluates the right operand as a string, checks the combined length
; against BASIC's 255-byte limit, allocates a new result string, releases
; any temporary input descriptors, unpacks both source descriptors, and
; copies their payloads into the fresh result buffer.
;
expr_concat_strings: push     bc                   ; $d6b9 c5              ; 
             push     hl                   ; $d6ba e5              ; 
             ld       hl,($0450)           ; $d6bb 2a 50 04        ; 
             ex       (sp),hl              ; $d6be e3              ; 
             call     expr_parse_primary   ; $d6bf cd 88 fa        ; 
             ex       (sp),hl              ; $d6c2 e3              ; 
             call     str_require_string   ; $d6c3 cd ae cb        ; 
             ld       a,(hl)               ; $d6c6 7e              ; 
             push     hl                   ; $d6c7 e5              ; 
             ld       hl,($0450)           ; $d6c8 2a 50 04        ; 
             push     hl                   ; $d6cb e5              ; 
             add      a,(hl)               ; $d6cc 86              ; 
             ld       de,$000f             ; $d6cd 11 0f 00        ; 
             jp       c,basic_raise_error  ; $d6d0 da c7 f1        ; 
             call     calld560             ; $d6d3 cd 60 d5        ; 
             pop      de                   ; $d6d6 d1              ; 
             call     str_release_arg      ; $d6d7 cd 08 d7        ; 
             ex       (sp),hl              ; $d6da e3              ; 
             call     str_swap_result_descriptor_to_de ; $d6db cd 07 d7        ; 
             push     hl                   ; $d6de e5              ; 
             ld       hl,($0202)           ; $d6df 2a 02 02        ; 
             ex       de,hl                ; $d6e2 eb              ; 
             call     str_unpack_descriptor ; $d6e3 cd f0 d6        ; 
             call     str_unpack_descriptor ; $d6e6 cd f0 d6        ; 
             ld       hl,$f939             ; $d6e9 21 39 f9        ; 
             ex       (sp),hl              ; $d6ec e3              ; 
             push     hl                   ; $d6ed e5              ; 
             jr       skipd76e             ; $d6ee 18 7e           ; 

;
; Helper that unpacks a 3-byte string descriptor into L = length and
; BC = character-data pointer.  Used by concatenation and substring
; builders before they call str_copy_chars.
;
str_unpack_descriptor: pop      hl                   ; $d6f0 e1              ; 
             ex       (sp),hl              ; $d6f1 e3              ; 
             ld       a,(hl)               ; $d6f2 7e              ; 
             inc      hl                   ; $d6f3 23              ; 
             ld       c,(hl)               ; $d6f4 4e              ; 
             inc      hl                   ; $d6f5 23              ; 
             ld       b,(hl)               ; $d6f6 46              ; 
             ld       l,a                  ; $d6f7 6f              ; 
;
; ----
; str_copy_chars — copy L characters from BC to DE
; ----
; Tight byte-copy helper used by STR$, LEFT$, RIGHT$, MID$, INPUT, and
; other routines that materialise or slice string payloads.
;
str_copy_chars: inc      l                    ; $d6f8 2c              ; 
loopd6f9:    dec      l                    ; $d6f9 2d              ; 
             ret      z                    ; $d6fa c8              ; 

             ld       a,(bc)               ; $d6fb 0a              ; 
             ld       (de),a               ; $d6fc 12              ; 
             inc      bc                   ; $d6fd 03              ; 
             inc      de                   ; $d6fe 13              ; 
             jr       loopd6f9             ; $d6ff 18 f8           ; 

;
; ----
; str_eval_string_arg — evaluate expression and fetch its string descriptor
; ----
; Calls str_require_string, loads HL from the descriptor register at
; $0450, and returns the descriptor address for downstream string helpers.
;
str_eval_string_arg: call     str_require_string   ; $d701 cd ae cb        ; 
;
; Shared tail for string evaluators: load HL from the current result
; descriptor register at $0450, then swap it to DE when the caller falls
; through to $d707.
;
str_load_result_descriptor: ld       hl,($0450)           ; $d704 2a 50 04        ; 
;
; str_swap_result_descriptor_to_de — move the current string descriptor
; from HL into DE
; Tiny shared tail used after str_load_result_descriptor and by string
; concatenation helpers that want DE = descriptor pointer.
;
str_swap_result_descriptor_to_de: ex       de,hl                ; $d707 eb              ; 
;
; ----
; str_release_arg — release temporary string argument if needed
; ----
; Shared cleanup tail for string functions. Adjusts the temporary-string
; heap pointer at $0204/$01e1 when the consumed argument came from the
; current temp-string area.
;
str_release_arg: call     str_pop_temp_descriptor_if_top ; $d708 cd 1f d7        ; 
             ex       de,hl                ; $d70b eb              ; 
             ret      nz                   ; $d70c c0              ; 

             push     de                   ; $d70d d5              ; 
             ld       d,b                  ; $d70e 50              ; 
             ld       e,c                  ; $d70f 59              ; 
             dec      de                   ; $d710 1b              ; 
             ld       c,(hl)               ; $d711 4e              ; 
             ld       hl,($0204)           ; $d712 2a 04 02        ; 
             rst      rst0020              ; $d715 e7              ; 
             jr       nz,skipd71d          ; $d716 20 05           ; 
             ld       b,a                  ; $d718 47              ; 
             add      hl,bc                ; $d719 09              ; 
             ld       ($0204),hl           ; $d71a 22 04 02        ; 
skipd71d:    pop      hl                   ; $d71d e1              ; 
             ret                           ; $d71e c9              ; 

;
; Checks whether the descriptor in DE is the current top entry of the
; temporary-descriptor stack rooted at $01E1.  If so, drops the stack
; pointer back by one descriptor so callers can reclaim the associated
; temp-string payload.
; 
; 
; ; ============================================================
; ; LEN handler ($D72D)
; ; ============================================================
;
str_pop_temp_descriptor_if_top: ld       hl,($01e1)           ; $d71f 2a e1 01        ; 
             dec      hl                   ; $d722 2b              ; 
             ld       b,(hl)               ; $d723 46              ; 
             dec      hl                   ; $d724 2b              ; 
             ld       c,(hl)               ; $d725 4e              ; 
             dec      hl                   ; $d726 2b              ; 
             rst      rst0020              ; $d727 e7              ; 
             ret      nz                   ; $d728 c0              ; 

             ld       ($01e1),hl           ; $d729 22 e1 01        ; 
             ret                           ; $d72c c9              ; 

;
; fn_len — LEN function
; LEN(str$) — return the number of characters in a string.
; LD BC,$FC90; PUSH BC: push $FC90 as a synthetic return
; address on the stack.
; Falls into calld731: CALL calld701 (evaluate expr as
; string, HL → descriptor); XOR A; LD D,A; LD A,(HL)
; (A = length byte from string descriptor); RET.
; The RET pops the synthetic return address $FC90 which
; zero-extends A into HL and returns via JP callcaef,
; delivering the string length as an integer.
;
fn_len:      ld       bc,skipfc90          ; $d72d 01 90 fc        ; 
             push     bc                   ; $d730 c5              ; 
;
; str_eval_len_byte — evaluate a string expression and return its length
; in A
; Shared LEN/ASC prelude: evaluates the current expression as a string,
; clears D, loads the descriptor length byte into A, and returns with the
; usual zero/nonzero flags reflecting whether the string is empty.
; 
; ; ============================================================
; ; TKEY handler ($D7CC)
; ; ============================================================
;
str_eval_len_byte: call     str_eval_string_arg  ; $d731 cd 01 d7        ; 
             xor      a,a                  ; $d734 af              ; 
             ld       d,a                  ; $d735 57              ; 
             ld       a,(hl)               ; $d736 7e              ; 
             or       a,a                  ; $d737 b7              ; 
             ret                           ; $d738 c9              ; 

;
; fn_font — FONT$ function
; FONT$(code) — fetch one character's editable 8-byte font pattern and
; return it as a bracketed comma-separated string.
; Parses one byte argument via gfx_parse_byte_arg, rejects out-of-range
; character codes, submits LCD/system command $1b, then formats the
; eight returned bytes into a printable `[n,n,...]` result.
;
fn_font:     call     gfx_parse_byte_arg   ; $d739 cd c1 d7        ; 
             cp       a,$20                ; $d73c fe 20           ; 
             jr       c,skipd77e           ; $d73e 38 3e           ; 
             cp       a,$00                ; $d740 fe 00           ; 
             jr       c,skipd77e           ; $d742 38 3a           ; 
             ld       bc,$0108             ; $d744 01 08 01        ; 
             ld       a,$1b                ; $d747 3e 1b           ; 
             call     gfx_dispatch         ; $d749 cd 0f db        ; 
             push     de                   ; $d74c d5              ; 
             ld       a,$19                ; $d74d 3e 19           ; 
             call     alloc_sysstr_result  ; $d74f cd 58 db        ; 
             ld       (hl),$5b             ; $d752 36 5b           ; 
             inc      hl                   ; $d754 23              ; 
             pop      de                   ; $d755 d1              ; 
             ld       b,$08                ; $d756 06 08           ; 
loopd758:    push     bc                   ; $d758 c5              ; 
             push     de                   ; $d759 d5              ; 
             ld       a,(de)               ; $d75a 1a              ; 
             ld       d,a                  ; $d75b 57              ; 
             call     render_two_digit_value ; $d75c cd 7e db        ; 
             pop      de                   ; $d75f d1              ; 
             inc      de                   ; $d760 13              ; 
             pop      bc                   ; $d761 c1              ; 
             ld       a,b                  ; $d762 78              ; 
             cp       a,$01                ; $d763 fe 01           ; 
             jr       z,skipd76c           ; $d765 28 05           ; 
             ld       (hl),$2c             ; $d767 36 2c           ; 
             inc      hl                   ; $d769 23              ; 
             djnz     loopd758             ; $d76a 10 ec           ; 
skipd76c:    ld       (hl),$5d             ; $d76c 36 5d           ; 
skipd76e:    jp       jumpd58d             ; $d76e c3 8d d5        ; 

;
; inst_font — FONT statement / font-pattern setter
; FONT code,(b0,b1,b2,b3,b4,b5,b6,b7) — replace one editable 8-byte
; font pattern.
; Uses calld80f to parse the target character code, accepts only the
; editable range $80-$df, stores that code in $0276, resolves the
; current record with sysstr_fetch_indexed_record, then parses eight
; byte expressions separated by commas into the staging block at $026e.
; Command $1a submits the resulting 9-byte payload (code + 8 rows) to
; the co-processor/font service and returns the status via $02fc.
;
inst_font:   call     parse_parenthesized_int8 ; $d771 cd 0f d8        ; 
             cp       a,$80                ; $d774 fe 80           ; 
             jr       c,skipd77e           ; $d776 38 06           ; 
             cp       a,$a0                ; $d778 fe a0           ; 
             jr       c,skipd781           ; $d77a 38 05           ; 
             cp       a,$e0                ; $d77c fe e0           ; 
skipd77e:    jp       c,jumpf590           ; $d77e da 90 f5        ; 
skipd781:    ld       ($0276),a            ; $d781 32 76 02        ; 
             dec      hl                   ; $d784 2b              ; 
             call     sysstr_fetch_indexed_record ; $d785 cd 33 db        ; 
             push     de                   ; $d788 d5              ; 
             ld       de,$026e             ; $d789 11 6e 02        ; 
             ld       a,($0276)            ; $d78c 3a 76 02        ; 
             ld       (de),a               ; $d78f 12              ; 
             inc      de                   ; $d790 13              ; 
             push     de                   ; $d791 d5              ; 
             ld       c,$08                ; $d792 0e 08           ; 
loopd794:    push     bc                   ; $d794 c5              ; 
             call     eval_expr_to_int16   ; $d795 cd 51 fe        ; 
             ld       a,d                  ; $d798 7a              ; 
             or       a,a                  ; $d799 b7              ; 
             jp       nz,jumpdbd7          ; $d79a c2 d7 db        ; 
             pop      bc                   ; $d79d c1              ; 
             ex       (sp),hl              ; $d79e e3              ; 
             ld       (hl),e               ; $d79f 73              ; 
             inc      hl                   ; $d7a0 23              ; 
             ex       (sp),hl              ; $d7a1 e3              ; 
             ld       a,c                  ; $d7a2 79              ; 
             cp       a,$01                ; $d7a3 fe 01           ; 
             jr       z,skipd7ac           ; $d7a5 28 05           ; 
             rst      rst0008              ; $d7a7 cf              ; 
             defb     $2c                                          ; ,          ; 
             dec      c                    ; $d7a9 0d              ; 
             jr       nz,loopd794          ; $d7aa 20 e8           ; 
skipd7ac:    ld       a,(hl)               ; $d7ac 7e              ; 
             or       a,a                  ; $d7ad b7              ; 
             jp       nz,jumpdbc8          ; $d7ae c2 c8 db        ; 
             ld       a,($02fc)            ; $d7b1 3a fc 02        ; 
             ld       (iy+$00),a           ; $d7b4 fd 77 00        ; 
             ld       a,$1a                ; $d7b7 3e 1a           ; 
             ld       b,$09                ; $d7b9 06 09           ; 
             call     gfx_dispatch_from_hl ; $d7bb cd 1c db        ; 
             pop      bc                   ; $d7be c1              ; 
             pop      hl                   ; $d7bf e1              ; 
             ret                           ; $d7c0 c9              ; 

;
; Shared parser for one parenthesised byte argument.
; Calls calld80f to read '(expr)' as an 8-bit value, rewrites the
; stacked return so HL is preserved for the caller, and stores the
; resulting byte into $026e — the first byte of the graphics/LCD
; parameter block.
;
gfx_parse_byte_arg: call     parse_parenthesized_int8 ; $d7c1 cd 0f d8        ; 
             pop      bc                   ; $d7c4 c1              ; 
             push     hl                   ; $d7c5 e5              ; 
             push     bc                   ; $d7c6 c5              ; 
             ld       hl,$026e             ; $d7c7 21 6e 02        ; 
             ld       (hl),a               ; $d7ca 77              ; 
             ret                           ; $d7cb c9              ; 

;
; fn_tkey — TKEY function (Canon X-07 extension)
; TKEY(str$) — wait until a key matching the first character
; of str$ is pressed, then return.
; CALL calld81e: evaluate str$ and extract its first
; character into A (like ASC, using the string/char-eval
; path via calld731).
; LD HL,$026F; LD (HL),A: store the target character code
; at RAM $026F (keyboard match register).
; LD A,$28; LD B,1: set up I/O parameters.
; Falls into loopd7d7: polls the keyboard via calldb18 and
; callc0bd in a tight loop; compares incoming keycode against
; the stored target via callfc15 until a match is found.
; 
; ; ============================================================
; ; STICK handler ($D7E3)
; ; ============================================================
;
fn_tkey:     call     str_eval_first_char  ; $d7cc cd 1e d8        ; 
             ld       hl,$026f             ; $d7cf 21 6f 02        ; 
             ld       (hl),a               ; $d7d2 77              ; 
             ld       a,$28                ; $d7d3 3e 28           ; 
             ld       b,$01                ; $d7d5 06 01           ; 
loopd7d7:    call     gfx_dispatch_poll    ; $d7d7 cd 18 db        ; 
             call     io_device_reset      ; $d7da cd bd c0        ; 
;
; Shared read-back tail for active-low LCD/I/O replies.
; Loads the reply byte from (DE), complements it, then calls callfc15
; to return the value as a BASIC integer.  POINT uses this path after
; LCD command $10, and the same tail is reused by the joystick/TKEY
; polling helpers.
;
gfx_reply_to_basic_int: ld       a,(de)               ; $d7dd 1a              ; 
             cpl                           ; $d7de 2f              ; 
loopd7df:    call     callfc15             ; $d7df cd 15 fc        ; 
             ret                           ; $d7e2 c9              ; 

;
; fn_stick — STICK function
; STICK(n) — return joystick axis value for joystick n
; (0 = up/neutral, other values encode direction).
; CALL calld80f: evaluate 1 numeric argument → A = joystick
; index (0 or 1); PUSH HL preserves HL.
; LD A,$82; CALL calldb18: issue I/O command $82 to the
; joystick hardware.
; CALL callc0bd: complete I/O read; (DE) = raw joystick byte.
; LD A,(DE); AND $0F: extract 4-bit direction code.
; JP jumpd7f2: convert A to a floating-point integer and
; return via the standard integer-return path.
; 
; ; ============================================================
; ; STRIG handler ($D7F8)
; ; ============================================================
;
fn_stick:    call     parse_parenthesized_int8 ; $d7e3 cd 0f d8        ; 
             push     hl                   ; $d7e6 e5              ; 
             ld       a,$82                ; $d7e7 3e 82           ; 
             call     gfx_dispatch_poll    ; $d7e9 cd 18 db        ; 
             call     io_device_reset      ; $d7ec cd bd c0        ; 
             ld       a,(de)               ; $d7ef 1a              ; 
             and      a,$0f                ; $d7f0 e6 0f           ; 
jumpd7f2:    ld       de,$fb30             ; $d7f2 11 30 fb        ; 
             push     de                   ; $d7f5 d5              ; 
             jr       loopd7df             ; $d7f6 18 e7           ; 

;
; fn_strig — STRIG function
; STRIG(n) — return joystick trigger state for trigger n
; (0 = not pressed, −1 = pressed).
; CALL calld80f: evaluate 1 numeric argument → A = trigger
; index; validate 0 ≤ A < 2 (JP NC, jumpf1aa if out of range).
; OR A; JR Z: if A = 0 use register byte $84; else $83.
; Selects the appropriate I/O status byte for trigger 0 or 1.
; LD DE,$FB30; PUSH DE; JR loopd7d7: falls into the shared
; keyboard/I/O polling loop (same tail as STICK) to read the
; trigger byte, test it, and return −1 or 0.
; 
; ; ============================================================
; ; ASC handler ($D81A)
; ; ============================================================
;
fn_strig:    call     parse_parenthesized_int8 ; $d7f8 cd 0f d8        ; 
             push     hl                   ; $d7fb e5              ; 
             cp       a,$02                ; $d7fc fe 02           ; 
             jp       nc,basic_raise_error_02 ; $d7fe d2 aa f1        ; 
             or       a,a                  ; $d801 b7              ; 
             jr       z,skipd807           ; $d802 28 03           ; 
             ld       a,$83                ; $d804 3e 83           ; 
             defb     $01                  ; $d806 01 3e 84        ;   As: ld     bc,$843e   ; 01 3e 84   ; Next: $d809
skipd807:    ld       a,$84                ; $d807 3e 84           ; 
             ld       de,$fb30             ; $d809 11 30 fb        ; 
             push     de                   ; $d80c d5              ; 
             jr       loopd7d7             ; $d80d 18 c8           ; 

;
; parse_parenthesized_int8 — parse `(expr)` and return an 8-bit value in A
; Shared parser used by FONT, STICK, STRIG, and gfx_parse_byte_arg.
; Requires `(`, evaluates the expression through eval_expr_to_int8,
; requires `)`, then returns the resulting byte in A.
;
parse_parenthesized_int8: rst      rst0010              ; $d80f d7              ; 
             rst      rst0008              ; $d810 cf              ; 
             defb     $28                                          ; (          ; 
             call     eval_expr_to_int8    ; $d812 cd 5e fe        ; 
             push     af                   ; $d815 f5              ; 
             rst      rst0008              ; $d816 cf              ; 
             defb     $29                                          ; )          ; 
             pop      af                   ; $d818 f1              ; 
             ret                           ; $d819 c9              ; 

;
; fn_asc — ASC function
; ASC(str$) — return the ASCII code of the first character
; of str$.  A type-mismatch error is raised if the argument
; is not a string; an empty-string error if str$ has zero
; length.
; LD BC,$FC90; PUSH BC: push $FC90 as a synthetic return
; address (same pattern as fn_len).
; Falls into calld81e: CALL calld731 (evaluate str$, set up
; descriptor, HL → first char); JP Z, jumpf590 if empty;
; RST $38 (error if still empty).
; LD BC,$C91A; CALL calld55e; CALL callfe61: extract and
; package the first byte of the string.
; Returns via $FC90 → callfc90 → callcaef as an integer.
;
fn_asc:      ld       bc,skipfc90          ; $d81a 01 90 fc        ; 
             push     bc                   ; $d81d c5              ; 
;
; str_eval_first_char — evaluate a string expression and return its first
; character in A
; Shared ASC/TKEY/STRING$ helper.  Evaluates the current argument as a
; string, raises the empty-string error path if needed, then extracts the
; first byte through the normal string-to-char worker.
; 
; ; ============================================================
; ; CHR$ handler ($D828)
; ; ============================================================
;
str_eval_first_char: call     str_eval_len_byte    ; $d81e cd 31 d7        ; 
             jp       z,jumpf590           ; $d821 ca 90 f5        ; 
             rst      rst0038              ; $d824 ff              ; 
             ld       bc,$c91a             ; $d825 01 1a c9        ; 
;
; fn_chr — CHR$ function
; CHR$(n) — return a one-character string whose single byte
; has ASCII value n (0–255).
; Entry point in the middle of the ASC/calld81e routine.
; CALL calld55e: allocate a 1-character string in the heap.
; CALL callfe61: store the numeric argument (A) as the sole
; byte of the new string.
; Continues into calld82e to finalise the string descriptor
; and return the string reference.
;
fn_chr:      call     str_make_char        ; $d828 cd 5e d5        ; 
             call     eval_result_to_int8  ; $d82b cd 61 fe        ; 
;
; str_return_single_char — finalise and return a 1-character string result
; Loads the writable payload pointer from $0202, stores E as the single
; character byte, then rejoins the common string-result return tail.
;
str_return_single_char: ld       hl,($0202)           ; $d82e 2a 02 02        ; 
             ld       (hl),e               ; $d831 73              ; 
loopd832:    pop      bc                   ; $d832 c1              ; 
             jr       skipd87e             ; $d833 18 49           ; 

;
; fn_string — STRING$ function
; STRING$(count, value) — build a string of length `count` filled with
; the requested character.
; The first argument is taken as an 8-bit repeat count.  The second
; argument may be numeric (use its byte value directly) or string
; (reuse the first character via the ASC-style helper at $d81e).
; The routine allocates a temporary string and fills it byte-by-byte.
;
fn_string:   rst      rst0010              ; $d835 d7              ; 
             rst      rst0008              ; $d836 cf              ; 
             defb     $28                                          ; (          ; 
             call     eval_expr_to_int8    ; $d838 cd 5e fe        ; 
             push     de                   ; $d83b d5              ; 
             rst      rst0008              ; $d83c cf              ; 
             defb     $2c                                          ; ,          ; 
             call     eval_expression      ; $d83e cd 2d f9        ; 
             rst      rst0008              ; $d841 cf              ; 
             defb     $29                                          ; )          ; 
             ex       (sp),hl              ; $d843 e3              ; 
             push     hl                   ; $d844 e5              ; 
             rst      rst0030              ; $d845 f7              ; 
             jr       z,skipd84d           ; $d846 28 05           ; 
             call     eval_result_to_int8  ; $d848 cd 61 fe        ; 
             jr       skipd850             ; $d84b 18 03           ; 

skipd84d:    call     str_eval_first_char  ; $d84d cd 1e d8        ; 
skipd850:    pop      de                   ; $d850 d1              ; 
             call     str_fill_repeated_char ; $d851 cd 54 d8        ; 
;
; str_fill_repeated_char — allocate and fill a repeated-character string
; Shared STRING$ tail.  Takes the fill byte in A and count in E, allocates
; the destination string, then writes the same byte B times into the new
; payload before returning it as the active string result.
;
str_fill_repeated_char: push     af                   ; $d854 f5              ; 
             ld       a,e                  ; $d855 7b              ; 
             call     calld560             ; $d856 cd 60 d5        ; 
             ld       b,a                  ; $d859 47              ; 
             pop      af                   ; $d85a f1              ; 
             inc      b                    ; $d85b 04              ; 
             dec      b                    ; $d85c 05              ; 
             jr       z,loopd832           ; $d85d 28 d3           ; 
             ld       hl,($0202)           ; $d85f 2a 02 02        ; 
loopd862:    ld       (hl),a               ; $d862 77              ; 
             inc      hl                   ; $d863 23              ; 
             djnz     loopd862             ; $d864 10 fc           ; 
             jr       loopd832             ; $d866 18 ca           ; 

;
; fn_time — TIME$ function
; TIME$ — read the current clock value and return the formatted time
; string.
; Uses the fixed-width system-string formatter path: queries the clock
; block, allocates an 8-byte result, then inserts the standard time
; separators through the shared punctuation helpers before returning.
;
fn_time:     rst      rst0010              ; $d868 d7              ; 
             push     hl                   ; $d869 e5              ; 
             call     lcd_submit_tile_mode ; $d86a cd 0b db        ; 
             call     sysstr_result_fields_ptr ; $d86d cd 5f db        ; 
             ld       a,$08                ; $d870 3e 08           ; 
             call     alloc_sysstr_result  ; $d872 cd 58 db        ; 
             call     sysstr_format_field_colon ; $d875 cd f1 db        ; 
             call     sysstr_format_field_colon ; $d878 cd f1 db        ; 
             call     sysstr_format_field_end ; $d87b cd f9 db        ; 
skipd87e:    jp       jumpd58d             ; $d87e c3 8d d5        ; 

;
; sysstr_fetch_time_record — fetch and format a time-style system record
; Shared TIME$/clock-record entry used by the token dispatcher.
; Resolves the indexed record with sysstr_fetch_indexed_record, issues the
; standard clock query setup, parses a 3-byte field block through
; sysstr_parse_field_list, then joins the common render/refresh tail.
;
sysstr_fetch_time_record: call     sysstr_fetch_indexed_record ; $d881 cd 33 db        ; 
             push     de                   ; $d884 d5              ; 
             call     lcd_submit_tile_mode ; $d885 cd 0b db        ; 
             call     sysstr_result_fields_ptr ; $d888 cd 5f db        ; 
             ld       bc,$3a00             ; $d88b 01 00 3a        ; 
             call     sysstr_parse_field_list ; $d88e cd 94 db        ; 
;
; sysstr_finish_query_render — common post-format render / status path
; Clears the display-status byte at $02fd, copies the prepared 8-byte
; block into the LCD staging area, submits the tile block, polls the
; follow-up status command, and finally returns the temporary string
; descriptor unless the LCD-side status reports an error.
;
sysstr_finish_query_render: xor      a,a                  ; $d891 af              ; 
             ld       ($02fd),a            ; $d892 32 fd 02        ; 
             call     gfx_copy_8byte_block ; $d895 cd 68 db        ; 
             ld       a,$81                ; $d898 3e 81           ; 
             call     lcd_submit_tile_block ; $d89a cd 24 db        ; 
             ld       a,$0a                ; $d89d 3e 0a           ; 
             ld       b,$08                ; $d89f 06 08           ; 
             call     gfx_dispatch_from_hl ; $d8a1 cd 1c db        ; 
             ld       a,$c5                ; $d8a4 3e c5           ; 
             call     gfx_dispatch_poll    ; $d8a6 cd 18 db        ; 
             ld       a,(de)               ; $d8a9 1a              ; 
             or       a,a                  ; $d8aa b7              ; 
             jr       z,skipd8c0           ; $d8ab 28 13           ; 
             ld       ($02fd),a            ; $d8ad 32 fd 02        ; 
             ld       de,$d8bb             ; $d8b0 11 bb d8        ; 
jumpd8b3:    push     de                   ; $d8b3 d5              ; 
             push     hl                   ; $d8b4 e5              ; 
             ld       hl,$0507             ; $d8b5 21 07 05        ; 
             jp       jumpdb6c             ; $d8b8 c3 6c db        ; 

             defb     $3e,$0a,$cd,$2b,$db                          ; >..+.      ; 
skipd8c0:    ld       a,$8b                ; $d8c0 3e 8b           ; 
             call     gfx_dispatch_from_hl ; $d8c2 cd 1c db        ; 
             ld       a,($02fd)            ; $d8c5 3a fd 02        ; 
             or       a,a                  ; $d8c8 b7              ; 
             jp       nz,jumpf590          ; $d8c9 c2 90 f5        ; 
             pop      hl                   ; $d8cc e1              ; 
             ret                           ; $d8cd c9              ; 

;
; fn_date — DATE$ function
; DATE$ — read the current date block and return the formatted date
; string.
; Queries the date record, formats the returned BCD fields through the
; shared system-string worker, and expands the weekday bits through the
; `SUNMONTUEWEDTHUFRISAT` table at $dc45.
;
fn_date:     rst      rst0010              ; $d8ce d7              ; 
             push     hl                   ; $d8cf e5              ; 
             call     lcd_submit_tile_mode ; $d8d0 cd 0b db        ; 
             xor      a,a                  ; $d8d3 af              ; 
             ld       ($02f8),a            ; $d8d4 32 f8 02        ; 
             push     de                   ; $d8d7 d5              ; 
             pop      ix                   ; $d8d8 dd e1           ; 
             ld       a,$0c                ; $d8da 3e 0c           ; 
             call     alloc_sysstr_result  ; $d8dc cd 58 db        ; 
loopd8df:    ld       a,$01                ; $d8df 3e 01           ; 
             ld       d,(ix+$00)           ; $d8e1 dd 56 00        ; 
             inc      ix                   ; $d8e4 dd 23           ; 
             call     sysstr_format_bcd_field ; $d8e6 cd fd db        ; 
             ld       a,($02f8)            ; $d8e9 3a f8 02        ; 
             or       a,a                  ; $d8ec b7              ; 
             jr       nz,alm_store_query_fields ; $d8ed 20 64           ; 
             call     sysstr_format_field_slash ; $d8ef cd f3 db        ; 
             call     sysstr_format_field_comma ; $d8f2 cd f6 db        ; 
             ld       a,(ix+$00)           ; $d8f5 dd 7e 00        ; 
             ld       bc,$08ff             ; $d8f8 01 ff 08        ; 
loopd8fb:    rla                           ; $d8fb 17              ; 
             jr       nc,skipd901          ; $d8fc 30 03           ; 
             inc      c                    ; $d8fe 0c              ; 
             djnz     loopd8fb             ; $d8ff 10 fa           ; 
skipd901:    push     hl                   ; $d901 e5              ; 
             ld       hl,$dc45             ; $d902 21 45 dc        ; 
             ld       b,$00                ; $d905 06 00           ; 
             ld       a,c                  ; $d907 79              ; 
             rla                           ; $d908 17              ; 
             add      a,c                  ; $d909 81              ; 
             ld       c,a                  ; $d90a 4f              ; 
             add      hl,bc                ; $d90b 09              ; 
             pop      de                   ; $d90c d1              ; 
             ex       de,hl                ; $d90d eb              ; 
             ld       b,$03                ; $d90e 06 03           ; 
             call     callca51             ; $d910 cd 51 ca        ; 
             jr       skipd97e             ; $d913 18 69           ; 

;
; sysstr_fetch_date_record — fetch and render an indexed date-style record
; Companion to sysstr_fetch_time_record for the date-oriented path.
; Resolves the selected record, runs the shared $81 query setup, parses
; the returned field list with sysstr_parse_field_list using the
; date-format control word in BC, then rejoins sysstr_finish_query_render.
;
sysstr_fetch_date_record: call     sysstr_fetch_indexed_record ; $d915 cd 33 db        ; 
             push     de                   ; $d918 d5              ; 
             call     lcd_submit_tile_mode ; $d919 cd 0b db        ; 
             push     de                   ; $d91c d5              ; 
             pop      ix                   ; $d91d dd e1           ; 
             ld       bc,$2f01             ; $d91f 01 01 2f        ; 
             call     sysstr_parse_field_list ; $d922 cd 94 db        ; 
             jp       sysstr_finish_query_render ; $d925 c3 91 d8        ; 

;
; fn_alm — ALM$ function
; ALM$ — return the current alarm / schedule string.
; Fetches the alarm block with command $b6, seeds a 13-character
; temporary buffer with `*`, then overlays day-name fragments and other
; returned fields to materialise the alarm description string.
;
fn_alm:      rst      rst0010              ; $d928 d7              ; 
             push     hl                   ; $d929 e5              ; 
             ld       a,$b6                ; $d92a 3e b6           ; 
             ld       c,$08                ; $d92c 0e 08           ; 
             call     gfx_dispatch         ; $d92e cd 0f db        ; 
             ld       a,$01                ; $d931 3e 01           ; 
             ld       ($02f8),a            ; $d933 32 f8 02        ; 
             push     de                   ; $d936 d5              ; 
             pop      ix                   ; $d937 dd e1           ; 
             ld       a,$13                ; $d939 3e 13           ; 
             call     alloc_sysstr_result  ; $d93b cd 58 db        ; 
             push     hl                   ; $d93e e5              ; 
             ld       b,a                  ; $d93f 47              ; 
;
; alarm_fill_wildcards — initialise the ALM$ output image with `*`
; Fills the freshly allocated 13-character temporary string with asterisks
; before the later alarm helpers selectively overwrite weekday and time
; slots for enabled alarm fields.
;
alarm_fill_wildcards: ld       (hl),$2a             ; $d940 36 2a           ; 
             inc      hl                   ; $d942 23              ; 
             djnz     alarm_fill_wildcards ; $d943 10 fb           ; 
             pop      hl                   ; $d945 e1              ; 
             bit      $07,(ix+$00)         ; $d946 dd cb 00 7e     ; 
             jr       z,loopd8df           ; $d94a 28 93           ; 
             ld       a,$01                ; $d94c 3e 01           ; 
             call     sysstr_skip_rendered_field ; $d94e cd 36 dc        ; 
             inc      ix                   ; $d951 dd 23           ; 
;
; alm_store_query_fields — continue rendering parsed ALM$ fields
; Internal ALM$ worker entered after the wildcard image has been
; initialised.  It skips masked fields, overlays enabled time/date
; fragments, inserts separators through the shared system-string helpers,
; and then rejoins the common string-return path at jumpd58d.
;
alm_store_query_fields: call     alarm_skip_masked_field ; $d953 cd 30 dc        ; 
             ld       a,$02                ; $d956 3e 02           ; 
             call     alarm_skip_masked_field ; $d958 cd 30 dc        ; 
             ld       d,(ix+$00)           ; $d95b dd 56 00        ; 
             ld       a,d                  ; $d95e 7a              ; 
             cp       a,$80                ; $d95f fe 80           ; 
             jr       z,skipd96e           ; $d961 28 0b           ; 
             ld       (hl),$26             ; $d963 36 26           ; 
             inc      hl                   ; $d965 23              ; 
             ld       (hl),$68             ; $d966 36 68           ; 
             inc      hl                   ; $d968 23              ; 
             call     render_two_digit_value ; $d969 cd 7e db        ; 
             jr       skipd972             ; $d96c 18 04           ; 

skipd96e:    inc      hl                   ; $d96e 23              ; 
             inc      hl                   ; $d96f 23              ; 
             inc      hl                   ; $d970 23              ; 
             inc      hl                   ; $d971 23              ; 
skipd972:    call     sysstr_emit_comma_separator ; $d972 cd 24 dc        ; 
             xor      a,a                  ; $d975 af              ; 
             call     alarm_skip_masked_field ; $d976 cd 30 dc        ; 
             ld       a,$ff                ; $d979 3e ff           ; 
             call     alarm_skip_masked_field ; $d97b cd 30 dc        ; 
skipd97e:    jp       jumpd58d             ; $d97e c3 8d d5        ; 

;
; inst_alm — ALM$ assignment / alarm editor
; ALM$(selector)=... — parse a field-oriented alarm specification and
; submit the rewritten 8-byte alarm block.
; Resolves the selected alarm record with sysstr_fetch_indexed_record,
; seeds the temporary block at $026e with $80 sentinels, parses a
; slash/comma/colon-separated field list, stores 1-byte and 2-byte
; numeric fields through the shared IX writers at $dbe0/$dc3a, updates
; enable bits in the packed flag byte, then sends command $b6 and polls
; command $c6 to verify the co-processor accepted the new alarm data.
;
inst_alm:    call     sysstr_fetch_indexed_record ; $d981 cd 33 db        ; 
             push     de                   ; $d984 d5              ; 
             push     hl                   ; $d985 e5              ; 
             ld       hl,$026e             ; $d986 21 6e 02        ; 
             push     hl                   ; $d989 e5              ; 
             ld       b,$08                ; $d98a 06 08           ; 
loopd98c:    ld       (hl),$80             ; $d98c 36 80           ; 
             inc      hl                   ; $d98e 23              ; 
             djnz     loopd98c             ; $d98f 10 fb           ; 
             pop      ix                   ; $d991 dd e1           ; 
             pop      hl                   ; $d993 e1              ; 
             ld       bc,$003e             ; $d994 01 3e 00        ; 
             push     bc                   ; $d997 c5              ; 
             push     bc                   ; $d998 c5              ; 
             dec      hl                   ; $d999 2b              ; 
             rst      rst0010              ; $d99a d7              ; 
loopd99b:    or       a,a                  ; $d99b b7              ; 
             jr       z,skipda08           ; $d99c 28 6a           ; 
             cp       a,$2f                ; $d99e fe 2f           ; 
             jr       z,skipd9fe           ; $d9a0 28 5c           ; 
             cp       a,$2c                ; $d9a2 fe 2c           ; 
             jr       z,skipd9fe           ; $d9a4 28 58           ; 
             cp       a,$3a                ; $d9a6 fe 3a           ; 
             jr       z,skipd9fe           ; $d9a8 28 54           ; 
             call     eval_expr_to_int16   ; $d9aa cd 51 fe        ; 
             pop      af                   ; $d9ad f1              ; 
             or       a,a                  ; $d9ae b7              ; 
             jr       z,skipd9bd           ; $d9af 28 0c           ; 
             push     af                   ; $d9b1 f5              ; 
             ld       a,d                  ; $d9b2 7a              ; 
             or       a,a                  ; $d9b3 b7              ; 
             jp       nz,jumpdbd7          ; $d9b4 c2 d7 db        ; 
             pop      af                   ; $d9b7 f1              ; 
             call     sysstr_store_byte_field ; $d9b8 cd e0 db        ; 
             jr       skipd9c4             ; $d9bb 18 07           ; 

skipd9bd:    call     sysstr_store_word_field ; $d9bd cd 3a dc        ; 
             pop      de                   ; $d9c0 d1              ; 
             res      $05,e                ; $d9c1 cb ab           ; 
             push     de                   ; $d9c3 d5              ; 
skipd9c4:    pop      de                   ; $d9c4 d1              ; 
             push     af                   ; $d9c5 f5              ; 
             cp       a,$01                ; $d9c6 fe 01           ; 
             jr       z,skipd9df           ; $d9c8 28 15           ; 
             cp       a,$02                ; $d9ca fe 02           ; 
             jr       z,skipd9dc           ; $d9cc 28 0e           ; 
             cp       a,$04                ; $d9ce fe 04           ; 
             jr       z,skipd9d9           ; $d9d0 28 07           ; 
             cp       a,$05                ; $d9d2 fe 05           ; 
             jr       nz,skipd9e1          ; $d9d4 20 0b           ; 
             res      $01,e                ; $d9d6 cb 8b           ; 
             defb     $01                  ; $d9d8 01 cb 93        ;   As: ld     bc,$93cb   ; 01 cb 93   ; Next: $d9db
skipd9d9:    res      $02,e                ; $d9d9 cb 93           ; 
             defb     $01                  ; $d9db 01 cb 9b        ;   As: ld     bc,$9bcb   ; 01 cb 9b   ; Next: $d9de
skipd9dc:    res      $03,e                ; $d9dc cb 9b           ; 
             defb     $01                  ; $d9de 01 cb a3        ;   As: ld     bc,$a3cb   ; 01 cb a3   ; Next: $d9e1
skipd9df:    res      $04,e                ; $d9df cb a3           ; 
skipd9e1:    ld       a,(hl)               ; $d9e1 7e              ; 
             or       a,a                  ; $d9e2 b7              ; 
             jr       z,skipda0a           ; $d9e3 28 25           ; 
             cp       a,$2f                ; $d9e5 fe 2f           ; 
             jr       z,skipd9f2           ; $d9e7 28 09           ; 
             cp       a,$3a                ; $d9e9 fe 3a           ; 
             jr       z,skipd9f2           ; $d9eb 28 05           ; 
             cp       a,$2c                ; $d9ed fe 2c           ; 
             jp       nz,jumpdbc8          ; $d9ef c2 c8 db        ; 
skipd9f2:    pop      af                   ; $d9f2 f1              ; 
             push     de                   ; $d9f3 d5              ; 
loopd9f4:    inc      a                    ; $d9f4 3c              ; 
             cp       a,$06                ; $d9f5 fe 06           ; 
             jp       nc,skipdbdc          ; $d9f7 d2 dc db        ; 
             push     af                   ; $d9fa f5              ; 
             rst      rst0010              ; $d9fb d7              ; 
             jr       loopd99b             ; $d9fc 18 9d           ; 

skipd9fe:    pop      af                   ; $d9fe f1              ; 
             or       a,a                  ; $d9ff b7              ; 
             jr       nz,skipda04          ; $da00 20 02           ; 
             inc      ix                   ; $da02 dd 23           ; 
skipda04:    inc      ix                   ; $da04 dd 23           ; 
             jr       loopd9f4             ; $da06 18 ec           ; 

skipda08:    pop      af                   ; $da08 f1              ; 
             defb     $01                  ; $da09 01 f1 d5        ;   As: ld     bc,$d5f1   ; 01 f1 d5   ; Next: $da0c
skipda0a:    pop      af                   ; $da0a f1              ; 
             push     de                   ; $da0b d5              ; 
             ld       a,($02fc)            ; $da0c 3a fc 02        ; 
             ld       (iy+$00),a           ; $da0f fd 77 00        ; 
             call     gfx_copy_8byte_block ; $da12 cd 68 db        ; 
             ld       a,$b6                ; $da15 3e b6           ; 
             call     lcd_submit_tile_block ; $da17 cd 24 db        ; 
             ld       a,$0c                ; $da1a 3e 0c           ; 
             ld       b,$08                ; $da1c 06 08           ; 
             call     gfx_dispatch_from_hl ; $da1e cd 1c db        ; 
             ld       a,$c6                ; $da21 3e c6           ; 
             call     gfx_dispatch_poll    ; $da23 cd 18 db        ; 
             ld       a,(de)               ; $da26 1a              ; 
             pop      de                   ; $da27 d1              ; 
             xor      a,e                  ; $da28 ab              ; 
             pop      hl                   ; $da29 e1              ; 
             ret      z                    ; $da2a c8              ; 

             ld       de,$da31             ; $da2b 11 31 da        ; 
             jp       jumpd8b3             ; $da2e c3 b3 d8        ; 

             defb     $3e,$0c,$cd,$2b,$db,$c3,$90,$f5              ; >..+....   ; 
;
; fn_key — KEY$ function
; KEY$(n) — fetch the user-defined string attached to function key `n`.
; Validates the 1-based key index with the shared helper at $da8a,
; issues query command $17, allocates the reported length, then copies
; the returned bytes into a BASIC temporary string.
;
fn_key:      call     parse_fn_key_index   ; $da39 cd 8a da        ; 
             push     de                   ; $da3c d5              ; 
             push     hl                   ; $da3d e5              ; 
             ld       a,$17                ; $da3e 3e 17           ; 
             ld       bc,$01fe             ; $da40 01 fe 01        ; 
             call     lcd_submit_counted   ; $da43 cd 51 c9        ; 
             call     alloc_sysstr_result  ; $da46 cd 58 db        ; 
             ld       b,$01                ; $da49 06 01           ; 
             ld       a,$17                ; $da4b 3e 17           ; 
             pop      de                   ; $da4d d1              ; 
             jr       skipdaa7             ; $da4e 18 57           ; 

;
; inst_key — KEY$ assignment / function-key definition
; KEY$(n)=text$ — program the string attached to function key `n`.
; Clears the left-pad count at $02fb, forces the copy-mode flag at
; $02fa, parses the key index, stores it in $026f, requires `=`, then
; uses parse_sysstr_source_string / build_sysstr_copy_payload to copy the
; source string into a temporary buffer.  Short strings are padded with
; spaces up to 5 characters before command $16 submits the definition.
;
inst_key:    xor      a,a                  ; $da50 af              ; 
             ld       ($02fb),a            ; $da51 32 fb 02        ; 
             ld       a,$01                ; $da54 3e 01           ; 
             ld       ($02fa),a            ; $da56 32 fa 02        ; 
             call     parse_fn_key_index   ; $da59 cd 8a da        ; 
             ld       ($026f),a            ; $da5c 32 6f 02        ; 
             ex       de,hl                ; $da5f eb              ; 
             rst      rst0008              ; $da60 cf              ; 
             defb     $dd                                          ; .          ; 
             call     parse_sysstr_source_string ; $da62 cd e3 da        ; 
             push     hl                   ; $da65 e5              ; 
             inc      b                    ; $da66 04              ; 
             cp       a,$05                ; $da67 fe 05           ; 
             jr       nc,skipda73          ; $da69 30 08           ; 
             ld       a,$05                ; $da6b 3e 05           ; 
             sub      a,b                  ; $da6d 90              ; 
             ld       ($02fb),a            ; $da6e 32 fb 02        ; 
             add      a,b                  ; $da71 80              ; 
             ld       b,a                  ; $da72 47              ; 
skipda73:    call     build_sysstr_copy_payload ; $da73 cd e9 da        ; 
             ld       a,($02fb)            ; $da76 3a fb 02        ; 
             or       a,a                  ; $da79 b7              ; 
             jr       z,skipda86           ; $da7a 28 0a           ; 
             push     hl                   ; $da7c e5              ; 
             push     bc                   ; $da7d c5              ; 
             ld       b,a                  ; $da7e 47              ; 
loopda7f:    inc      hl                   ; $da7f 23              ; 
             ld       (hl),$20             ; $da80 36 20           ; 
             djnz     loopda7f             ; $da82 10 fb           ; 
             pop      bc                   ; $da84 c1              ; 
             pop      hl                   ; $da85 e1              ; 
skipda86:    ld       a,$16                ; $da86 3e 16           ; 
             jr       skipdad8             ; $da88 18 4e           ; 

;
; parse_fn_key_index — parse a 1..12 slot index for KEY$-family helpers
; Shared `(expr)` parser used by KEY$ and nearby setup code.
; Stores the validated byte in the standard query block at $026e and
; raises syntax/range errors unless 1 ≤ index ≤ 12.
;
parse_fn_key_index: call     gfx_parse_byte_arg   ; $da8a cd c1 d7        ; 
             cp       a,$0d                ; $da8d fe 0d           ; 
             jp       nc,basic_raise_error_02 ; $da8f d2 aa f1        ; 
             cp       a,$01                ; $da92 fe 01           ; 
             jp       c,basic_raise_error_02 ; $da94 da aa f1        ; 
             pop      de                   ; $da97 d1              ; 
             ret                           ; $da98 c9              ; 

;
; fn_start — START$ function
; START$ — fetch the stored OFF/ON startup string.
; Queries the firmware service behind command $a1, allocates a temporary
; string of the returned length, copies the payload, and returns the
; descriptor through the normal string-result path.
;
fn_start:    rst      rst0010              ; $da99 d7              ; 
             push     hl                   ; $da9a e5              ; 
             ld       a,$a1                ; $da9b 3e a1           ; 
             ld       c,$fe                ; $da9d 0e fe           ; 
             call     lcd_submit_counted   ; $da9f cd 51 c9        ; 
             call     alloc_sysstr_result  ; $daa2 cd 58 db        ; 
             ld       a,$a1                ; $daa5 3e a1           ; 
skipdaa7:    ex       de,hl                ; $daa7 eb              ; 
             ld       c,$ff                ; $daa8 0e ff           ; 
             call     lcd_submit_counted   ; $daaa cd 51 c9        ; 
             jp       jumpd58d             ; $daad c3 8d d5        ; 

;
; inst_start — START$ assignment / startup-string setter
; START$=text$ or START$(ON)=text$ — update the stored startup string.
; Optionally accepts the special ON-selector token after `(`...`)` to set
; the variant flag in $02f9, then parses the source string through
; parse_sysstr_source_string, materialises a counted copy with
; build_sysstr_copy_payload, and submits command $1d or $1e depending on
; the selected startup-string variant.
;
inst_start:  rst      rst0010              ; $dab0 d7              ; 
             rst      rst0008              ; $dab1 cf              ; 
             defb     $dd                                          ; .          ; 
             cp       a,$d1                ; $dab3 fe d1           ; 
             jr       nz,skipdabd          ; $dab5 20 06           ; 
             ld       a,$01                ; $dab7 3e 01           ; 
             ld       ($02f9),a            ; $dab9 32 f9 02        ; 
             inc      hl                   ; $dabc 23              ; 
skipdabd:    call     parse_sysstr_source_string ; $dabd cd e3 da        ; 
             jr       nz,skipdac8          ; $dac0 20 06           ; 
             ld       de,$000f             ; $dac2 11 0f 00        ; 
             jp       basic_raise_error    ; $dac5 c3 c7 f1        ; 

skipdac8:    push     hl                   ; $dac8 e5              ; 
             call     build_sysstr_copy_payload ; $dac9 cd e9 da        ; 
             ld       a,($02f9)            ; $dacc 3a f9 02        ; 
             dec      a                    ; $dacf 3d              ; 
             jr       z,skipdad6           ; $dad0 28 04           ; 
             ld       a,$1d                ; $dad2 3e 1d           ; 
             jr       skipdad8             ; $dad4 18 02           ; 

skipdad6:    ld       a,$1e                ; $dad6 3e 1e           ; 
skipdad8:    ld       c,$00                ; $dad8 0e 00           ; 
             call     lcd_submit           ; $dada cd 2f c9        ; 
             xor      a,a                  ; $dadd af              ; 
             ld       ($02f9),a            ; $dade 32 f9 02        ; 
             pop      hl                   ; $dae1 e1              ; 
             ret                           ; $dae2 c9              ; 

;
; parse_sysstr_source_string — evaluate a source string and return its
; internal copy length
; Calls calldb4c to evaluate the current string expression, then
; increments B and mirrors the result in A so callers can allocate room
; for the copied bytes plus the trailing NUL used by the payload builder.
;
parse_sysstr_source_string: call     calldb4c             ; $dae3 cd 4c db        ; 
             inc      b                    ; $dae6 04              ; 
             ld       a,b                  ; $dae7 78              ; 
             ret                           ; $dae8 c9              ; 

;
; build_sysstr_copy_payload — allocate and build a NUL-terminated copy of
; the current source string
; Allocates a temporary string buffer of B bytes, optionally prefixes the
; first byte from $026f when the copy-mode flag at $02fa requests it,
; copies the source bytes from DE, then appends a terminating zero.
;
build_sysstr_copy_payload: push     bc                   ; $dae9 c5              ; 
             push     de                   ; $daea d5              ; 
             ld       a,b                  ; $daeb 78              ; 
             call     alloc_sysstr_result  ; $daec cd 58 db        ; 
             pop      de                   ; $daef d1              ; 
             pop      bc                   ; $daf0 c1              ; 
             push     bc                   ; $daf1 c5              ; 
             push     hl                   ; $daf2 e5              ; 
             ld       a,($02fa)            ; $daf3 3a fa 02        ; 
             dec      a                    ; $daf6 3d              ; 
             jr       nz,skipdb02          ; $daf7 20 09           ; 
             ld       ($02fa),a            ; $daf9 32 fa 02        ; 
             ld       a,($026f)            ; $dafc 3a 6f 02        ; 
             ld       (hl),a               ; $daff 77              ; 
             inc      hl                   ; $db00 23              ; 
             dec      b                    ; $db01 05              ; 
skipdb02:    call     callca51             ; $db02 cd 51 ca        ; 
             dec      hl                   ; $db05 2b              ; 
             ld       (hl),$00             ; $db06 36 00           ; 
             pop      hl                   ; $db08 e1              ; 
             pop      bc                   ; $db09 c1              ; 
             ret                           ; $db0a c9              ; 

;
; Small text/tile-submit setup helper.
; Preloads A=$81 and C=$08 before falling through to gfx_dispatch, so
; callers can reuse the normal LCD submit path with the fixed 8-byte
; tile/text block protocol.
;
lcd_submit_tile_mode: ld       a,$81                ; $db0b 3e 81           ; 
             ld       c,$08                ; $db0d 0e 08           ; 
;
; Set DE = $026E (graphics parameter block base address), then
; call lcd_submit.  Variants: calldb18 (C=1), calldb1c (explicit ptr),
; calldb24 (C=8, DE=$0507 — used by text/tile rendering).
;
gfx_dispatch: ld       de,$026e             ; $db0f 11 6e 02        ; 
loopdb12:    push     hl                   ; $db12 e5              ; 
loopdb13:    call     lcd_submit           ; $db13 cd 2f c9        ; 
             pop      hl                   ; $db16 e1              ; 
             ret                           ; $db17 c9              ; 

;
; gfx_dispatch variant with C = 1.
; Used for command/reply transactions where the LCD-side bookkeeping
; needs the alternate poll/count mode recorded in $026d.
;
gfx_dispatch_poll: ld       c,$01                ; $db18 0e 01           ; 
             jr       gfx_dispatch         ; $db1a 18 f3           ; 

;
; Submit the standard graphics parameter block with C = 0 while
; preserving the caller's HL on the stack.
; Used by higher-level helpers that finish preparing $026e..$0275 and
; then tail-call the LCD transfer layer.
;
gfx_dispatch_from_hl: push     hl                   ; $db1c e5              ; 
             ld       hl,$026e             ; $db1d 21 6e 02        ; 
             ld       c,$00                ; $db20 0e 00           ; 
             jr       loopdb13             ; $db22 18 ef           ; 

;
; LCD submit variant for the fixed 8-byte block at $0507.
; Loads C = 8 and DE = $0507 before reusing the gfx_dispatch path.
; Used by text/tile oriented display helpers that share the same LCD
; transport as the graphics commands.
;
lcd_submit_tile_block: ld       c,$08                ; $db24 0e 08           ; 
             ld       de,$0507             ; $db26 11 07 05        ; 
             jr       loopdb12             ; $db29 18 e7           ; 

             defb     $48,$06,$08,$21,$07,$05,$18,$df              ; H..!....   ; 
;
; sysstr_fetch_indexed_record — resolve an indexed system-string record
; Shared helper for the DATE$/ALM$/KEY$ family.
; Parses the parenthesised selector, resolves the underlying string or
; record through calldb4c, positions IY at the payload, and saves the
; returned status byte in $02fc for the formatting code that follows.
; 
; ; ============================================================
; ; LEFT$ handler ($DC5A)
; ; ============================================================
;
sysstr_fetch_indexed_record: rst      rst0010              ; $db33 d7              ; 
             rst      rst0008              ; $db34 cf              ; 
             defb     $dd                                          ; .          ; 
             call     calldb4c             ; $db36 cd 4c db        ; 
             ex       de,hl                ; $db39 eb              ; 
             push     de                   ; $db3a d5              ; 
             push     hl                   ; $db3b e5              ; 
             ld       c,b                  ; $db3c 48              ; 
             ld       b,$00                ; $db3d 06 00           ; 
             add      hl,bc                ; $db3f 09              ; 
             push     hl                   ; $db40 e5              ; 
             pop      iy                   ; $db41 fd e1           ; 
             ld       a,(hl)               ; $db43 7e              ; 
             ld       ($02fc),a            ; $db44 32 fc 02        ; 
             xor      a,a                  ; $db47 af              ; 
             ld       (hl),a               ; $db48 77              ; 
             pop      hl                   ; $db49 e1              ; 
             pop      de                   ; $db4a d1              ; 
             ret                           ; $db4b c9              ; 

calldb4c:    call     eval_expression      ; $db4c cd 2d f9        ; 
             push     hl                   ; $db4f e5              ; 
             call     str_eval_string_arg  ; $db50 cd 01 d7        ; 
             call     callca32             ; $db53 cd 32 ca        ; 
             pop      hl                   ; $db56 e1              ; 
             ret                           ; $db57 c9              ; 

;
; alloc_sysstr_result — allocate a temporary result string buffer
; Shared helper for fixed-width system-string functions such as TIME$,
; DATE$, and ALM$.
; Takes the requested length in A, calls the normal temporary-string
; allocator, then returns HL = ($0202), the writable character buffer.
;
alloc_sysstr_result: call     calld560             ; $db58 cd 60 d5        ; 
             ld       hl,($0202)           ; $db5b 2a 02 02        ; 
             ret                           ; $db5e c9              ; 

;
; sysstr_result_fields_ptr — point at the field bytes inside a query block
; Adds 5 to DE and leaves the result in IX.
; Used by the time/date/alarm formatters after the LCD/query command has
; filled the standard block so the byte-oriented helpers can walk the
; returned BCD fields directly.
;
sysstr_result_fields_ptr: ld       bc,gpr_char_step     ; $db5f 01 05 00        ; 
             push     de                   ; $db62 d5              ; 
             pop      ix                   ; $db63 dd e1           ; 
             add      ix,bc                ; $db65 dd 09           ; 
             ret                           ; $db67 c9              ; 

;
; Copy eight bytes from DE to HL via the stack.
; Used to stage or clone LCD parameter blocks before a submit/readback
; cycle without needing a dedicated block-copy helper.
;
gfx_copy_8byte_block: push     hl                   ; $db68 e5              ; 
             ld       hl,$026e             ; $db69 21 6e 02        ; 
jumpdb6c:    push     hl                   ; $db6c e5              ; 
             pop      de                   ; $db6d d1              ; 
             ld       b,$08                ; $db6e 06 08           ; 
loopdb70:    ld       a,(de)               ; $db70 1a              ; 
             push     af                   ; $db71 f5              ; 
             inc      de                   ; $db72 13              ; 
             djnz     loopdb70             ; $db73 10 fb           ; 
             ld       b,$08                ; $db75 06 08           ; 
loopdb77:    pop      af                   ; $db77 f1              ; 
             ld       (hl),a               ; $db78 77              ; 
             inc      hl                   ; $db79 23              ; 
             djnz     loopdb77             ; $db7a 10 fb           ; 
             pop      hl                   ; $db7c e1              ; 
             ret                           ; $db7d c9              ; 

;
; render_two_digit_value — render one numeric byte as two display digits
; Converts the value in D through the standard decimal conversion scratch
; block at $0507, then copies the resulting two characters into the
; caller's output buffer.
;
render_two_digit_value: push     hl                   ; $db7e e5              ; 
             xor      a,a                  ; $db7f af              ; 
             ld       e,a                  ; $db80 5f              ; 
             ex       de,hl                ; $db81 eb              ; 
             ld       de,$0507             ; $db82 11 07 05        ; 
             ld       bc,$0102             ; $db85 01 02 01        ; 
             call     callbe9e             ; $db88 cd 9e be        ; 
             pop      hl                   ; $db8b e1              ; 
             ld       b,$02                ; $db8c 06 02           ; 
             dec      de                   ; $db8e 1b              ; 
             dec      de                   ; $db8f 1b              ; 
             call     callca51             ; $db90 cd 51 ca        ; 
             ret                           ; $db93 c9              ; 

;
; sysstr_parse_field_list — parse / fetch a packed field list into IX
; Shared worker behind the clock/date/alarm string helpers.
; Walks the current record or indexed selector, evaluates any numeric
; fields, stores byte or two-byte results through IX, and reports status
; back through $02fc / the caller-provided status slot.
;
sysstr_parse_field_list: xor      a,a                  ; $db94 af              ; 
             push     af                   ; $db95 f5              ; 
             push     bc                   ; $db96 c5              ; 
             dec      hl                   ; $db97 2b              ; 
loopdb98:    rst      rst0010              ; $db98 d7              ; 
             or       a,a                  ; $db99 b7              ; 
             jr       z,loopdbcb           ; $db9a 28 2f           ; 
             pop      bc                   ; $db9c c1              ; 
             pop      de                   ; $db9d d1              ; 
             push     af                   ; $db9e f5              ; 
             ld       a,$03                ; $db9f 3e 03           ; 
             inc      d                    ; $dba1 14              ; 
             cp       a,d                  ; $dba2 ba              ; 
             jr       c,skipdbdc           ; $dba3 38 37           ; 
             pop      af                   ; $dba5 f1              ; 
             push     de                   ; $dba6 d5              ; 
             push     bc                   ; $dba7 c5              ; 
             cp       a,b                  ; $dba8 b8              ; 
             jr       z,skipdbe6           ; $dba9 28 3b           ; 
             call     eval_expr_to_int16   ; $dbab cd 51 fe        ; 
             pop      bc                   ; $dbae c1              ; 
             dec      c                    ; $dbaf 0d              ; 
             push     bc                   ; $dbb0 c5              ; 
             jr       z,skipdbbc           ; $dbb1 28 09           ; 
             ld       a,d                  ; $dbb3 7a              ; 
             or       a,a                  ; $dbb4 b7              ; 
             jr       nz,jumpdbd7          ; $dbb5 20 20           ; 
             call     sysstr_store_byte_field ; $dbb7 cd e0 db        ; 
             jr       skipdbbf             ; $dbba 18 03           ; 

skipdbbc:    call     sysstr_store_word_field ; $dbbc cd 3a dc        ; 
skipdbbf:    ld       a,(hl)               ; $dbbf 7e              ; 
             or       a,a                  ; $dbc0 b7              ; 
             jr       z,loopdbcb           ; $dbc1 28 08           ; 
             pop      bc                   ; $dbc3 c1              ; 
             push     bc                   ; $dbc4 c5              ; 
             cp       a,b                  ; $dbc5 b8              ; 
             jr       z,loopdb98           ; $dbc6 28 d0           ; 
jumpdbc8:    ld       de,$0002             ; $dbc8 11 02 00        ; 
loopdbcb:    ld       a,($02fc)            ; $dbcb 3a fc 02        ; 
             ld       (iy+$00),a           ; $dbce fd 77 00        ; 
             jp       nz,basic_raise_error ; $dbd1 c2 c7 f1        ; 
             pop      bc                   ; $dbd4 c1              ; 
             pop      af                   ; $dbd5 f1              ; 
             ret                           ; $dbd6 c9              ; 

jumpdbd7:    ld       de,gpr_char_step     ; $dbd7 11 05 00        ; 
             jr       nz,loopdbcb          ; $dbda 20 ef           ; 
skipdbdc:    xor      a,a                  ; $dbdc af              ; 
             inc      a                    ; $dbdd 3c              ; 
             jr       jumpdbc8             ; $dbde 18 e8           ; 

;
; sysstr_store_byte_field — store one parsed byte field through IX
; Writes E to the current IX slot and advances IX by one.
;
sysstr_store_byte_field: ld       (ix+$00),e           ; $dbe0 dd 73 00        ; 
             inc      ix                   ; $dbe3 dd 23           ; 
             ret                           ; $dbe5 c9              ; 

skipdbe6:    pop      bc                   ; $dbe6 c1              ; 
             dec      c                    ; $dbe7 0d              ; 
             push     bc                   ; $dbe8 c5              ; 
             jr       nz,skipdbed          ; $dbe9 20 02           ; 
             inc      ix                   ; $dbeb dd 23           ; 
skipdbed:    inc      ix                   ; $dbed dd 23           ; 
             jr       loopdb98             ; $dbef 18 a7           ; 

;
; sysstr_format_field_colon — format one BCD field and append `:`
; Entry into the shared BCD-to-ASCII formatter with separator mode 0.
;
sysstr_format_field_colon: xor      a,a                  ; $dbf1 af              ; 
             defb     $01                  ; $dbf2 01 3e 01        ;   As: ld     bc,$013e   ; 01 3e 01   ; Next: $dbf5
;
; sysstr_format_field_slash — format one BCD field and append `/`
; Entry into the shared BCD-to-ASCII formatter with separator mode 1.
;
sysstr_format_field_slash: ld       a,$01                ; $dbf3 3e 01           ; 
             defb     $01                  ; $dbf5 01 3e 02        ;   As: ld     bc,$023e   ; 01 3e 02   ; Next: $dbf8
;
; sysstr_format_field_comma — format one BCD field and append `,`
; Entry into the shared BCD-to-ASCII formatter with separator mode 2.
;
sysstr_format_field_comma: ld       a,$02                ; $dbf6 3e 02           ; 
             defb     $01                  ; $dbf8 01 3e ff        ;   As: ld     bc,$ff3e   ; 01 3e ff   ; Next: $dbfb
;
; sysstr_format_field_end — format one BCD field with no trailing separator
; Terminator entry into the shared BCD-to-ASCII formatter with separator
; mode $ff.
;
sysstr_format_field_end: ld       a,$ff                ; $dbf9 3e ff           ; 
loopdbfb:    ld       d,$00                ; $dbfb 16 00           ; 
;
; sysstr_format_bcd_field — render the current IX byte as two ASCII digits
; Loads the source byte from the current field pointer, converts it to a
; two-character decimal/BCD fragment through the shared numeric worker,
; copies the pair into the result string, then applies the separator mode
; selected by sysstr_format_field_colon/slash/comma/end.
;
sysstr_format_bcd_field: push     af                   ; $dbfd f5              ; 
             push     hl                   ; $dbfe e5              ; 
             ld       bc,$0000             ; $dbff 01 00 00        ; 
             ld       e,(ix+$00)           ; $dc02 dd 5e 00        ; 
             ld       ($0450),de           ; $dc05 ed 53 50 04     ; 
             ld       hl,$0507             ; $dc09 21 07 05        ; 
             call     callbe5f             ; $dc0c cd 5f be        ; 
             dec      hl                   ; $dc0f 2b              ; 
             dec      hl                   ; $dc10 2b              ; 
             ex       de,hl                ; $dc11 eb              ; 
             pop      hl                   ; $dc12 e1              ; 
             ld       b,$02                ; $dc13 06 02           ; 
             call     callca51             ; $dc15 cd 51 ca        ; 
             pop      af                   ; $dc18 f1              ; 
loopdc19:    cp       a,$ff                ; $dc19 fe ff           ; 
             ret      z                    ; $dc1b c8              ; 

             cp       a,$00                ; $dc1c fe 00           ; 
             jr       z,skipdc27           ; $dc1e 28 07           ; 
             cp       a,$01                ; $dc20 fe 01           ; 
             jr       z,skipdc2a           ; $dc22 28 06           ; 
;
; sysstr_emit_comma_separator — emit the punctuation byte for a field break
; Direct comma-entry used by ALM$.
; The shared chain falls through to sibling cases at $dc27 (`:`) and
; $dc2a (`/`), then advances HL and IX past the inserted separator slot.
;
sysstr_emit_comma_separator: ld       (hl),$2c             ; $dc24 36 2c           ; 
             defb     $01                  ; $dc26 01 36 3a        ;   As: ld     bc,$3a36   ; 01 36 3a   ; Next: $dc29
skipdc27:    ld       (hl),$3a             ; $dc27 36 3a           ; 
             defb     $01                  ; $dc29 01 36 2f        ;   As: ld     bc,$2f36   ; 01 36 2f   ; Next: $dc2c
skipdc2a:    ld       (hl),$2f             ; $dc2a 36 2f           ; 
             inc      hl                   ; $dc2c 23              ; 
             inc      ix                   ; $dc2d dd 23           ; 
             ret                           ; $dc2f c9              ; 

;
; alarm_skip_masked_field — skip an ALM$ field whose high bit marks it absent
; Tests bit 7 of the current alarm byte.  If the field is enabled it drops
; into the normal separator path; otherwise it skips the matching output
; character positions instead of rendering digits.
;
alarm_skip_masked_field: bit      $07,(ix+$00)         ; $dc30 dd cb 00 7e     ; 
             jr       z,loopdbfb           ; $dc34 28 c5           ; 
;
; sysstr_skip_rendered_field — skip one 2-character field in the output image
; Advances HL by two output positions, then rejoins the shared separator
; tail used by the BCD-formatting helpers.
;
sysstr_skip_rendered_field: inc      hl                   ; $dc36 23              ; 
             inc      hl                   ; $dc37 23              ; 
             jr       loopdc19             ; $dc38 18 df           ; 

;
; sysstr_store_word_field — store one parsed 16-bit field through IX
; Writes D then E to successive IX slots and advances IX by two.
;
sysstr_store_word_field: ld       (ix+$00),d           ; $dc3a dd 72 00        ; 
             inc      ix                   ; $dc3d dd 23           ; 
             ld       (ix+$00),e           ; $dc3f dd 73 00        ; 
             inc      ix                   ; $dc42 dd 23           ; 
             ret                           ; $dc44 c9              ; 

             defm     "SUNMONTUEWEDTHUFRISAT"                                   ;
;
; fn_left — LEFT$ function
; LEFT$(str$, n) — return the leftmost n characters of str$.
; CALL $DCCE: evaluate the two arguments (str$ and count n),
; adjust the effective length to min(n, LEN(str$)), and set
; up the source string descriptor.
; XOR A: clear A (start offset = 0 for left-hand substring).
; EX (SP),HL; LD C,A: save HL and put start offset in C.
; Falls into calldc61: shared substring-copy routine that
; allocates a new string of the requested length, copies the
; characters from the source, and returns the string reference.
; 
; ; ============================================================
; ; RIGHT$ handler ($DC8A)
; ; ============================================================
;
fn_left:     call     str_parse_slice_args ; $dc5a cd ce dc        ; 
             xor      a,a                  ; $dc5d af              ; 
loopdc5e:    ex       (sp),hl              ; $dc5e e3              ; 
             ld       c,a                  ; $dc5f 4f              ; 
             defb     $3e                  ; $dc60 3e e5           ;   As: ld     a,$e5      ; 3e e5      ; Next: $dc62
calldc61:    push     hl                   ; $dc61 e5              ; 
             push     hl                   ; $dc62 e5              ; 
             ld       a,(hl)               ; $dc63 7e              ; 
             cp       a,b                  ; $dc64 b8              ; 
             jr       c,skipdc69           ; $dc65 38 02           ; 
             ld       a,b                  ; $dc67 78              ; 
             defb     $11                  ; $dc68 11 0e 00        ;   As: ld     de,$000e   ; 11 0e 00   ; Next: $dc6b
skipdc69:    ld       c,$00                ; $dc69 0e 00           ; 
             push     bc                   ; $dc6b c5              ; 
             call     str_alloc_temp       ; $dc6c cd c2 d5        ; 
             pop      bc                   ; $dc6f c1              ; 
             pop      hl                   ; $dc70 e1              ; 
             push     hl                   ; $dc71 e5              ; 
             inc      hl                   ; $dc72 23              ; 
             ld       b,(hl)               ; $dc73 46              ; 
             inc      hl                   ; $dc74 23              ; 
             ld       h,(hl)               ; $dc75 66              ; 
             ld       l,b                  ; $dc76 68              ; 
             ld       b,$00                ; $dc77 06 00           ; 
             add      hl,bc                ; $dc79 09              ; 
             ld       b,h                  ; $dc7a 44              ; 
             ld       c,l                  ; $dc7b 4d              ; 
             call     str_set_temp_descriptor ; $dc7c cd 63 d5        ; 
             ld       l,a                  ; $dc7f 6f              ; 
             call     str_copy_chars       ; $dc80 cd f8 d6        ; 
             pop      de                   ; $dc83 d1              ; 
             call     str_release_arg      ; $dc84 cd 08 d7        ; 
             jp       jumpd58d             ; $dc87 c3 8d d5        ; 

;
; fn_right — RIGHT$ function
; RIGHT$(str$, n) — return the rightmost n characters of str$.
; CALL $DCCE: evaluate str$ and n; B = min(n, LEN(str$)).
; POP DE; PUSH DE: restore string pointer into DE.
; LD A,(DE); SUB B: compute the start offset =
; LEN(str$) − n (number of characters to skip from left).
; JR −53: jump into fn_left at the EX (SP),HL instruction
; ($DC5E), reusing the shared LEFT$/RIGHT$ copy tail with
; C = start offset instead of 0.
; 
; ; ============================================================
; ; MID$ handler ($DC93)
; ; ============================================================
;
fn_right:    call     str_parse_slice_args ; $dc8a cd ce dc        ; 
             pop      de                   ; $dc8d d1              ; 
             push     de                   ; $dc8e d5              ; 
             ld       a,(de)               ; $dc8f 1a              ; 
             sub      a,b                  ; $dc90 90              ; 
             jr       loopdc5e             ; $dc91 18 cb           ; 

;
; fn_mid — MID$ function
; MID$(str$, start[, len]) — return a substring of str$
; beginning at position start (1-based), with optional
; maximum length len.
; EX DE,HL; LD A,(HL): exchange DE↔HL and read the start
; parameter.
; CALL $DCD1: internal string-argument setup; if len is
; omitted, defaults to the remaining length.
; Complex index arithmetic: DEC A; CP (HL) tests whether
; start exceeds string length (RET NC if so → empty string);
; adjusts the source pointer by the start offset and clamps
; the copy count to the available characters.
; PUSH BC,$DC62: sets up calldc61 (shared copy tail) as the
; return path; falls through to the shared substring
; extraction and string-allocation code.
;
fn_mid:      ex       de,hl                ; $dc93 eb              ; 
             ld       a,(hl)               ; $dc94 7e              ; 
             call     str_parse_mid_args   ; $dc95 cd d1 dc        ; 
             inc      b                    ; $dc98 04              ; 
             dec      b                    ; $dc99 05              ; 
             jr       z,skipdce5           ; $dc9a 28 49           ; 
             push     bc                   ; $dc9c c5              ; 
             call     callddc9             ; $dc9d cd c9 dd        ; 
             pop      af                   ; $dca0 f1              ; 
             ex       (sp),hl              ; $dca1 e3              ; 
             ld       bc,$dc62             ; $dca2 01 62 dc        ; 
             push     bc                   ; $dca5 c5              ; 
             dec      a                    ; $dca6 3d              ; 
             cp       a,(hl)               ; $dca7 be              ; 
             ld       b,$00                ; $dca8 06 00           ; 
             ret      nc                   ; $dcaa d0              ; 

             ld       c,a                  ; $dcab 4f              ; 
             ld       a,(hl)               ; $dcac 7e              ; 
             sub      a,c                  ; $dcad 91              ; 
             cp       a,e                  ; $dcae bb              ; 
             ld       b,a                  ; $dcaf 47              ; 
             ret      c                    ; $dcb0 d8              ; 

             ld       b,e                  ; $dcb1 43              ; 
             ret                           ; $dcb2 c9              ; 

;
; fn_val — VAL function
; VAL(str$) — convert the string str$ to its numeric value
; (e.g. VAL("3.14") → 3.14, VAL("FF") → 0 for non-numeric).
; CALL calld731: evaluate str$, load string descriptor;
; A = length byte, HL → descriptor.
; JP Z, $FC90: if string is empty, return 0 immediately.
; Falls into the numeric-parsing code: loads the string
; start address and length from the descriptor, then scans
; the character sequence as a BASIC numeric literal
; (integer or floating-point), storing the result in the
; FP accumulator and returning via the standard float-return
; path.
; 
; ; ============================================================
; ; POINT handler ($0093 — RAM vector)
; ; ============================================================
;
fn_val:      call     str_eval_len_byte    ; $dcb3 cd 31 d7        ; 
             jp       z,skipfc90           ; $dcb6 ca 90 fc        ; 
             ld       e,a                  ; $dcb9 5f              ; 
             inc      hl                   ; $dcba 23              ; 
             ld       a,(hl)               ; $dcbb 7e              ; 
             inc      hl                   ; $dcbc 23              ; 
             ld       h,(hl)               ; $dcbd 66              ; 
             ld       l,a                  ; $dcbe 6f              ; 
             push     hl                   ; $dcbf e5              ; 
             add      hl,de                ; $dcc0 19              ; 
             ld       b,(hl)               ; $dcc1 46              ; 
             ld       (hl),d               ; $dcc2 72              ; 
             ex       (sp),hl              ; $dcc3 e3              ; 
             push     bc                   ; $dcc4 c5              ; 
             dec      hl                   ; $dcc5 2b              ; 
             rst      rst0010              ; $dcc6 d7              ; 
             call     parse_numeric_literal ; $dcc7 cd 21 ba        ; 
             pop      bc                   ; $dcca c1              ; 
             pop      hl                   ; $dccb e1              ; 
             ld       (hl),b               ; $dccc 70              ; 
             ret                           ; $dccd c9              ; 

;
; ----
; str_parse_slice_args — parse LEFT$/RIGHT$ string and length arguments
; ----
; Shared argument setup for LEFT$ and RIGHT$. Evaluates the source string
; plus count parameter, then returns with B = requested slice length and
; the string descriptor parked on the stack for the common copy tail.
;
str_parse_slice_args: ex       de,hl                ; $dcce eb              ; 
             rst      rst0008              ; $dccf cf              ; 
             add      hl,hl                ; $dcd0 29              ; 
;
; ----
; str_parse_mid_args — parse MID$ start/length argument pair
; ----
; Shared MID$ setup helper. Pulls the already-parsed start position from
; the stack, fetches the source descriptor and optional length argument,
; and leaves the substring bounds ready for the copy routine at $dc61.
;
str_parse_mid_args: pop      bc                   ; $dcd1 c1              ; 
             pop      de                   ; $dcd2 d1              ; 
             push     bc                   ; $dcd3 c5              ; 
             ld       b,e                  ; $dcd4 43              ; 
             ret                           ; $dcd5 c9              ; 

;
; fn_instr — INSTR function
; INSTR([start,] needle$, haystack$) — return the 1-based position of
; `needle$` inside `haystack$`, or 0 if no match is found.
; Accepts the optional numeric start position, evaluates both string
; arguments, then runs the nested byte-compare loop at $dd34-$dd57 to
; search forward from the requested offset.
; 
; ; ============================================================
; ; VAL handler ($DCB3)
; ; ============================================================
;
fn_instr:    rst      rst0010              ; $dcd6 d7              ; 
             call     expr_require_open_paren ; $dcd7 cd 2b f9        ; 
             rst      rst0030              ; $dcda f7              ; 
             ld       a,$01                ; $dcdb 3e 01           ; 
             push     af                   ; $dcdd f5              ; 
             jr       z,skipdcf1           ; $dcde 28 11           ; 
             pop      af                   ; $dce0 f1              ; 
             call     eval_result_to_int8  ; $dce1 cd 61 fe        ; 
             or       a,a                  ; $dce4 b7              ; 
skipdce5:    jp       z,jumpf590           ; $dce5 ca 90 f5        ; 
             push     af                   ; $dce8 f5              ; 
             rst      rst0008              ; $dce9 cf              ; 
             defb     $2c                                          ; ,          ; 
             call     eval_expression      ; $dceb cd 2d f9        ; 
             call     str_require_string   ; $dcee cd ae cb        ; 
skipdcf1:    rst      rst0008              ; $dcf1 cf              ; 
             defb     $2c                                          ; ,          ; 
             push     hl                   ; $dcf3 e5              ; 
             ld       hl,($0450)           ; $dcf4 2a 50 04        ; 
             ex       (sp),hl              ; $dcf7 e3              ; 
             call     eval_expression      ; $dcf8 cd 2d f9        ; 
             rst      rst0008              ; $dcfb cf              ; 
             defb     $29                                          ; )          ; 
             push     hl                   ; $dcfd e5              ; 
             call     str_eval_string_arg  ; $dcfe cd 01 d7        ; 
             ex       de,hl                ; $dd01 eb              ; 
             pop      bc                   ; $dd02 c1              ; 
             pop      hl                   ; $dd03 e1              ; 
             pop      af                   ; $dd04 f1              ; 
             push     bc                   ; $dd05 c5              ; 
             ld       bc,pop_hl_and_return ; $dd06 01 f2 cd        ; 
             push     bc                   ; $dd09 c5              ; 
             ld       bc,skipfc90          ; $dd0a 01 90 fc        ; 
             push     bc                   ; $dd0d c5              ; 
             push     af                   ; $dd0e f5              ; 
             push     de                   ; $dd0f d5              ; 
             call     str_swap_result_descriptor_to_de ; $dd10 cd 07 d7        ; 
             pop      de                   ; $dd13 d1              ; 
             pop      af                   ; $dd14 f1              ; 
             ld       b,a                  ; $dd15 47              ; 
             dec      a                    ; $dd16 3d              ; 
             ld       c,a                  ; $dd17 4f              ; 
             cp       a,(hl)               ; $dd18 be              ; 
             ld       a,$00                ; $dd19 3e 00           ; 
             ret      nc                   ; $dd1b d0              ; 

             ld       a,(de)               ; $dd1c 1a              ; 
             or       a,a                  ; $dd1d b7              ; 
             ld       a,b                  ; $dd1e 78              ; 
             ret      z                    ; $dd1f c8              ; 

             ld       a,(hl)               ; $dd20 7e              ; 
             inc      hl                   ; $dd21 23              ; 
             ld       b,(hl)               ; $dd22 46              ; 
             inc      hl                   ; $dd23 23              ; 
             ld       h,(hl)               ; $dd24 66              ; 
             ld       l,b                  ; $dd25 68              ; 
             ld       b,$00                ; $dd26 06 00           ; 
             add      hl,bc                ; $dd28 09              ; 
             sub      a,c                  ; $dd29 91              ; 
             ld       b,a                  ; $dd2a 47              ; 
             push     bc                   ; $dd2b c5              ; 
             push     de                   ; $dd2c d5              ; 
             ex       (sp),hl              ; $dd2d e3              ; 
             ld       c,(hl)               ; $dd2e 4e              ; 
             inc      hl                   ; $dd2f 23              ; 
             ld       e,(hl)               ; $dd30 5e              ; 
             inc      hl                   ; $dd31 23              ; 
             ld       d,(hl)               ; $dd32 56              ; 
             pop      hl                   ; $dd33 e1              ; 
loopdd34:    push     hl                   ; $dd34 e5              ; 
             push     de                   ; $dd35 d5              ; 
             push     bc                   ; $dd36 c5              ; 
loopdd37:    ld       a,(de)               ; $dd37 1a              ; 
             cp       a,(hl)               ; $dd38 be              ; 
             jr       nz,skipdd51          ; $dd39 20 16           ; 
             inc      de                   ; $dd3b 13              ; 
             dec      c                    ; $dd3c 0d              ; 
             jr       z,skipdd48           ; $dd3d 28 09           ; 
             inc      hl                   ; $dd3f 23              ; 
             djnz     loopdd37             ; $dd40 10 f5           ; 
             pop      de                   ; $dd42 d1              ; 
             pop      de                   ; $dd43 d1              ; 
             pop      bc                   ; $dd44 c1              ; 
loopdd45:    pop      de                   ; $dd45 d1              ; 
             xor      a,a                  ; $dd46 af              ; 
             ret                           ; $dd47 c9              ; 

skipdd48:    pop      hl                   ; $dd48 e1              ; 
             pop      de                   ; $dd49 d1              ; 
             pop      de                   ; $dd4a d1              ; 
             pop      bc                   ; $dd4b c1              ; 
             ld       a,b                  ; $dd4c 78              ; 
             sub      a,h                  ; $dd4d 94              ; 
             add      a,c                  ; $dd4e 81              ; 
             inc      a                    ; $dd4f 3c              ; 
             ret                           ; $dd50 c9              ; 

skipdd51:    pop      bc                   ; $dd51 c1              ; 
             pop      de                   ; $dd52 d1              ; 
             pop      hl                   ; $dd53 e1              ; 
             inc      hl                   ; $dd54 23              ; 
             djnz     loopdd34             ; $dd55 10 dd           ; 
             jr       loopdd45             ; $dd57 18 ec           ; 

jumpdd59:    rst      rst0008              ; $dd59 cf              ; 
             defb     $28                                          ; (          ; 
             call     lookup_or_create_var ; $dd5b cd 0a b0        ; 
             call     str_require_string   ; $dd5e cd ae cb        ; 
             push     hl                   ; $dd61 e5              ; 
             push     de                   ; $dd62 d5              ; 
             ex       de,hl                ; $dd63 eb              ; 
             inc      hl                   ; $dd64 23              ; 
             ld       e,(hl)               ; $dd65 5e              ; 
             inc      hl                   ; $dd66 23              ; 
             ld       d,(hl)               ; $dd67 56              ; 
             ld       hl,($0326)           ; $dd68 2a 26 03        ; 
             rst      rst0020              ; $dd6b e7              ; 
             jr       c,skipdd78           ; $dd6c 38 0a           ; 
             pop      hl                   ; $dd6e e1              ; 
             push     hl                   ; $dd6f e5              ; 
             call     calld54a             ; $dd70 cd 4a d5        ; 
             pop      hl                   ; $dd73 e1              ; 
             push     hl                   ; $dd74 e5              ; 
             call     callca4d             ; $dd75 cd 4d ca        ; 
skipdd78:    pop      hl                   ; $dd78 e1              ; 
             ex       (sp),hl              ; $dd79 e3              ; 
             rst      rst0008              ; $dd7a cf              ; 
             defb     $2c                                          ; ,          ; 
             call     eval_expr_to_int8    ; $dd7c cd 5e fe        ; 
             or       a,a                  ; $dd7f b7              ; 
             jp       z,jumpf590           ; $dd80 ca 90 f5        ; 
             push     af                   ; $dd83 f5              ; 
             ld       a,(hl)               ; $dd84 7e              ; 
             call     callddc9             ; $dd85 cd c9 dd        ; 
             push     de                   ; $dd88 d5              ; 
             call     expr_require_equals  ; $dd89 cd 28 f9        ; 
             push     hl                   ; $dd8c e5              ; 
             call     str_eval_string_arg  ; $dd8d cd 01 d7        ; 
             ex       de,hl                ; $dd90 eb              ; 
             pop      hl                   ; $dd91 e1              ; 
             pop      bc                   ; $dd92 c1              ; 
             pop      af                   ; $dd93 f1              ; 
             ld       b,a                  ; $dd94 47              ; 
             ex       (sp),hl              ; $dd95 e3              ; 
             push     hl                   ; $dd96 e5              ; 
             ld       hl,pop_hl_and_return ; $dd97 21 f2 cd        ; 
             ex       (sp),hl              ; $dd9a e3              ; 
             ld       a,c                  ; $dd9b 79              ; 
             or       a,a                  ; $dd9c b7              ; 
             ret      z                    ; $dd9d c8              ; 

             ld       a,(hl)               ; $dd9e 7e              ; 
             sub      a,b                  ; $dd9f 90              ; 
             jp       c,jumpf590           ; $dda0 da 90 f5        ; 
             inc      a                    ; $dda3 3c              ; 
             cp       a,c                  ; $dda4 b9              ; 
             jr       c,skipdda8           ; $dda5 38 01           ; 
             ld       a,c                  ; $dda7 79              ; 
skipdda8:    ld       c,b                  ; $dda8 48              ; 
             dec      c                    ; $dda9 0d              ; 
             ld       b,$00                ; $ddaa 06 00           ; 
             push     de                   ; $ddac d5              ; 
             inc      hl                   ; $ddad 23              ; 
             ld       e,(hl)               ; $ddae 5e              ; 
             inc      hl                   ; $ddaf 23              ; 
             ld       h,(hl)               ; $ddb0 66              ; 
             ld       l,e                  ; $ddb1 6b              ; 
             add      hl,bc                ; $ddb2 09              ; 
             ld       b,a                  ; $ddb3 47              ; 
             pop      de                   ; $ddb4 d1              ; 
             ex       de,hl                ; $ddb5 eb              ; 
             ld       c,(hl)               ; $ddb6 4e              ; 
             inc      hl                   ; $ddb7 23              ; 
             ld       a,(hl)               ; $ddb8 7e              ; 
             inc      hl                   ; $ddb9 23              ; 
             ld       h,(hl)               ; $ddba 66              ; 
             ld       l,a                  ; $ddbb 6f              ; 
             ex       de,hl                ; $ddbc eb              ; 
             ld       a,c                  ; $ddbd 79              ; 
             or       a,a                  ; $ddbe b7              ; 
             ret      z                    ; $ddbf c8              ; 

loopddc0:    ld       a,(de)               ; $ddc0 1a              ; 
             ld       (hl),a               ; $ddc1 77              ; 
             inc      de                   ; $ddc2 13              ; 
             inc      hl                   ; $ddc3 23              ; 
             dec      c                    ; $ddc4 0d              ; 
             ret      z                    ; $ddc5 c8              ; 

             djnz     loopddc0             ; $ddc6 10 f8           ; 
             ret                           ; $ddc8 c9              ; 

callddc9:    ld       e,$ff                ; $ddc9 1e ff           ; 
             cp       a,$29                ; $ddcb fe 29           ; 
             jr       z,skipddd4           ; $ddcd 28 05           ; 
             rst      rst0008              ; $ddcf cf              ; 
             defb     $2c                                          ; ,          ; 
             call     eval_expr_to_int8    ; $ddd1 cd 5e fe        ; 
skipddd4:    rst      rst0008              ; $ddd4 cf              ; 
             defb     $29                                          ; )          ; 
             ret                           ; $ddd6 c9              ; 

;
; fn_fre — FRE function
; FRE(expr) — returns the number of free bytes of RAM.
; The argument is evaluated but ignored.
; LD HL,($0326): loads the heap-top pointer.
; EX DE,HL; LD HL,$0000; ADD HL,SP: computes current SP.
; RST $30 + further code subtracts DE from HL (via
; SBC HL,DE, opcode ED 52) to get the gap between the
; heap top and the current stack — the free RAM.
; Returns the result as a floating-point number.
; 
; ; ============================================================
; ; PEEK handler ($FC7A)
; ; ============================================================
;
fn_fre:      ld       hl,($0326)           ; $ddd7 2a 26 03        ; 
             ex       de,hl                ; $ddda eb              ; 
             ld       hl,$0000             ; $dddb 21 00 00        ; 
             add      hl,sp                ; $ddde 39              ; 
             rst      rst0030              ; $dddf f7              ; 
             jr       nz,skipddef          ; $dde0 20 0d           ; 
             call     str_load_result_descriptor ; $dde2 cd 04 d7        ; 
             call     str_gc_collect       ; $dde5 cd ea d5        ; 
             ld       de,($01dd)           ; $dde8 ed 5b dd 01     ; 
             ld       hl,($0204)           ; $ddec 2a 04 02        ; 
skipddef:    or       a,a                  ; $ddef b7              ; 
             sbc      hl,de                ; $ddf0 ed 52           ; 
             jp       fp_from_positive_int_hl ; $ddf2 c3 91 cd        ; 

;
; cas_parse_open — parse filename and open device for SAVE/LOAD (mode=1)
; Called by inst_save and inst_load with A=1 (RAM file mode).
; Saves AF, then calls io_parse_filename (calle6cb) to parse the quoted
; filename and resolve the storage device, storing type to $02F5 and
; descriptor to $02F6.  Inspects the device-type byte at DE+1: if it
; equals $07 and B=0, sets B=$50 as a default transfer block size.
; Restores AF and falls through into cas_device_setup.
; 
; Parse filename (io_parse_filename); set default block size if
; needed; fall through to cas_device_setup.
;
cas_parse_open: push     af                   ; $ddf5 f5              ; 
             call     io_parse_filename    ; $ddf6 cd cb e6        ; 
             inc      de                   ; $ddf9 13              ; 
             ld       a,(de)               ; $ddfa 1a              ; 
             dec      de                   ; $ddfb 1b              ; 
             cp       a,$07                ; $ddfc fe 07           ; 
             jr       nz,skipde06          ; $ddfe 20 06           ; 
             ld       a,b                  ; $de00 78              ; 
             or       a,a                  ; $de01 b7              ; 
             jr       nz,skipde06          ; $de02 20 02           ; 
             ld       b,$50                ; $de04 06 50           ; 
skipde06:    pop      af                   ; $de06 f1              ; 
;
; cas_device_setup — shared device initialisation entry point
; Loads IY=$02ED (the load/save destination buffer pointer).
; Calls io_init_descriptor (calle6a8) to populate the I/O control
; block, then jumps to io_open_channel (calle827) to patch the
; output-hook JP vectors and activate the device.
; Fallen into from cas_open_read, cas_open_write, and cas_parse_open.
; 
; IY=$02ED; call io_init_descriptor; jp io_open_channel.
;
cas_device_setup: ld       iy,$02ed             ; $de07 fd 21 ed 02     ; 
             call     io_init_descriptor   ; $de0b cd a8 e6        ; 
             jp       io_open_channel      ; $de0e c3 27 e8        ; 

;
; cas_open_read — open cassette device for reading
; Stores A to $02F5 (device-type byte) and points DE to the cassette
; read descriptor ($E787).  If called with Z set (no filename supplied),
; jumps directly to cas_device_setup.  Otherwise calls io_parse_filename
; (calle6cb) to parse the optional filename, errors if no cassette
; device is attached (jp nc,jumpf590), reloads DE=$E787 and falls
; into cas_device_setup.
; Called by inst_cload.
; 
; Store device type; parse optional filename; DE=$E787 (read
; descriptor); fall to cas_device_setup.
;
cas_open_read: ld       ($02f5),a            ; $de11 32 f5 02        ; 
             ld       de,$e787             ; $de14 11 87 e7        ; 
             jr       z,cas_device_setup   ; $de17 28 ee           ; 
             call     io_parse_filename    ; $de19 cd cb e6        ; 
             jp       nc,jumpf590          ; $de1c d2 90 f5        ; 
             ld       de,$e787             ; $de1f 11 87 e7        ; 
             jr       cas_device_setup     ; $de22 18 e3           ; 

;
; cas_open_write — open cassette device for writing
; Calls io_parse_filename (calle6cb) to parse the quoted filename
; argument and store it in $0305–$030A.  Errors (jp nc,jumpf590) if
; no cassette device is present.  Points DE to the cassette write
; descriptor ($E796) and falls into cas_device_setup.
; Called by inst_csave.
; 
; Parse filename (io_parse_filename); error if no cassette;
; DE=$E796 (write descriptor); fall to cas_device_setup.
;
cas_open_write: call     io_parse_filename    ; $de24 cd cb e6        ; 
             jp       nc,jumpf590          ; $de27 d2 90 f5        ; 
             ld       de,$e796             ; $de2a 11 96 e7        ; 
             jr       cas_device_setup     ; $de2d 18 d8           ; 

;
; cassette_output_open_channel — hidden CASO open/setup vector
; Reached indirectly through the `CASO:` descriptor's +6 pointer when
; io_init_descriptor installs the cassette-output channel.  Loads
; A=$11 / B=$C8 and falls into the shared setup tail at $DE39, which
; validates the requested parameters and then programs ports $F3, $F2,
; and $F4 for the active cassette-output transfer.
;
cassette_output_open_channel: ld       a,$11                ; $de2f 3e 11           ; 
             ld       b,$c8                ; $de31 06 c8           ; 
             jr       skipde39             ; $de33 18 04           ; 

;
; cassette_input_open_channel — hidden CASI open/setup vector
; Reached indirectly through the `CASI:` descriptor's +6 pointer.
; Sets up A=$14, B=$CA, C=$84, and DE=$013F before entering the same
; shared setup tail used by the cassette / external-device open code.
;
cassette_input_open_channel: ld       a,$14                ; $de35 3e 14           ; 
             ld       b,$ca                ; $de37 06 ca           ; 
skipde39:    ld       c,$84                ; $de39 0e 84           ; 
             ld       de,$013f             ; $de3b 11 3f 01        ; 
             jr       skipde66             ; $de3e 18 26           ; 

;
; com_open_channel — hidden COM open/setup vector
; Open/install path reached indirectly through the `COM:` descriptor's
; +6 pointer.  Loads HL=$1F40 and DE=$12C0, calls the parameter /
; range checker at $DEBD, then drops into the common port-programming
; tail that commits the derived control bytes to the external I/O ports.
;
com_open_channel: ld       hl,$1f40             ; $de40 21 40 1f        ; 
             ld       de,$12c0             ; $de43 11 c0 12        ; 
             call     calldebd             ; $de46 cd bd de        ; 
             ld       b,$c4                ; $de49 06 c4           ; 
             ld       a,$35                ; $de4b 3e 35           ; 
             jr       skipde66             ; $de4d 18 17           ; 

             defb     $21,$60,$09,$11,$b0,$04,$cd,$bd,$de,$06      ; !`........ ; 
             defb     $d4,$3e,$14,$18,$08                          ; .>...      ; 
;
; printer_open_channel — hidden PRT open/setup vector
; Open/install path reached indirectly through the `PRT:` descriptor's
; +6 pointer.  Loads BC=$C486 and DE=$004F, then enters the same
; shared setup tail used by the cassette / COM open vectors to prepare
; the active printer transfer parameters.
;
printer_open_channel: ld       bc,$c486             ; $de5e 01 86 c4        ; 
             ld       de,$004f             ; $de61 11 4f 00        ; 
             ld       a,$11                ; $de64 3e 11           ; 
skipde66:    push     af                   ; $de66 f5              ; 
             push     de                   ; $de67 d5              ; 
             push     bc                   ; $de68 c5              ; 
             call     buzzer_wait          ; $de69 cd 7b c3        ; 
             call     calle1c3             ; $de6c cd c3 e1        ; 
             pop      bc                   ; $de6f c1              ; 
             pop      de                   ; $de70 d1              ; 
             xor      a,a                  ; $de71 af              ; 
             ld       ($030c),a            ; $de72 32 0c 03        ; 
             ld       a,d                  ; $de75 7a              ; 
             out      ($f3),a              ; $de76 d3 f3           ; 
             ld       a,e                  ; $de78 7b              ; 
             out      ($f2),a              ; $de79 d3 f2           ; 
             in       a,($f4)              ; $de7b db f4           ; 
             or       a,b                  ; $de7d b0              ; 
             out      ($f4),a              ; $de7e d3 f4           ; 
             ld       a,c                  ; $de80 79              ; 
             out      ($f6),a              ; $de81 d3 f6           ; 
             ld       a,$04                ; $de83 3e 04           ; 
             out      ($f5),a              ; $de85 d3 f5           ; 
             call     cas_install_callback ; $de87 cd a7 de        ; 
             ld       ($00ae),iy           ; $de8a fd 22 ae 00     ; 
             pop      af                   ; $de8e f1              ; 
             call     callde9e             ; $de8f cd 9e de        ; 
             ld       a,($026c)            ; $de92 3a 6c 02        ; 
             or       a,$01                ; $de95 f6 01           ; 
;
; io_ctrl_commit — write shadowed I/O control byte to port $F0
; Stores A into the port-$F0 shadow byte at $026C, writes the
; same value to hardware port $F0, then re-enables interrupts
; and returns.
; 
; Despite first being noticed from the cassette path, its call
; sites show it is a generic control-port commit helper:
; lcd_char_write and lcd_send_data call it after masking bit 7,
; lcd_trigger jumps to it with bit 7 set, and the buzzer path
; jumps to it with only the audio-control bits preserved.
; The routine therefore commits the current mixed LCD / audio /
; cassette control state, not just the cassette motor.
; 
; Commit A to the shared I/O control shadow ($026C) and port $F0.
;
io_ctrl_commit: ld       ($026c),a            ; $de97 32 6c 02        ; 
             out      ($f0),a              ; $de9a d3 f0           ; 
             ei                            ; $de9c fb              ; 
             ret                           ; $de9d c9              ; 

callde9e:    di                            ; $de9e f3              ; 
;
; cas_port_clear — write cassette port $F6 and clear bit 4 of $030B
; Writes A to port $F6 (cassette I/O control register).  Clears
; bit 4 of A (AND $EF) and stores the result to $030B.  Used to
; de-assert a cassette control line after an operation.
; 
; OUT ($F6),A; AND $EF; LD ($030B),A; RET.
;
cas_port_clear: out      ($f6),a              ; $de9f d3 f6           ; 
             and      a,$ef                ; $dea1 e6 ef           ; 
             ld       ($030b),a            ; $dea3 32 0b 03        ; 
             ret                           ; $dea6 c9              ; 

;
; cas_install_callback — patch JP vector at ($00AE) to $E802
; If $00AE is non-zero, treats it as the address of a two-byte JP
; operand and overwrites the destination with $E802 (the cassette
; hardware-ready callback), then zeroes $00AE to prevent re-patching.
; Used to hook the cassette hardware-ready signal into the I/O driver
; at the point where it becomes active.
; 
; If $00AE ≠ 0: patch JP@($00AE) → $E802; clear $00AE.
;
cas_install_callback: push     hl                   ; $dea7 e5              ; 
             ld       hl,($00ae)           ; $dea8 2a ae 00        ; 
             ld       a,h                  ; $deab 7c              ; 
             or       a,l                  ; $deac b5              ; 
             jr       z,skipdebb           ; $dead 28 0c           ; 
             ld       de,io_unconfigured_driver_block ; $deaf 11 02 e8        ; 
             ld       (hl),e               ; $deb2 73              ; 
             inc      hl                   ; $deb3 23              ; 
             ld       (hl),d               ; $deb4 72              ; 
             ld       hl,$0000             ; $deb5 21 00 00        ; 
             ld       ($00ae),hl           ; $deb8 22 ae 00        ; 
skipdebb:    pop      hl                   ; $debb e1              ; 
             ret                           ; $debc c9              ; 

calldebd:    push     bc                   ; $debd c5              ; 
             push     ix                   ; $debe dd e5           ; 
             pop      bc                   ; $dec0 c1              ; 
             ld       a,b                  ; $dec1 78              ; 
             or       a,c                  ; $dec2 b1              ; 
             jr       nz,skipdec7          ; $dec3 20 02           ; 
             push     de                   ; $dec5 d5              ; 
             pop      bc                   ; $dec6 c1              ; 
skipdec7:    and      a,a                  ; $dec7 a7              ; 
             sbc      hl,bc                ; $dec8 ed 42           ; 
             jp       c,jumpf590           ; $deca da 90 f5        ; 
             ld       hl,$0063             ; $decd 21 63 00        ; 
             sbc      hl,bc                ; $ded0 ed 42           ; 
             jp       nc,jumpf590          ; $ded2 d2 90 f5        ; 
             xor      a,a                  ; $ded5 af              ; 
             ld       hl,$5dc0             ; $ded6 21 c0 5d        ; 
             ld       de,$fffe             ; $ded9 11 fe ff        ; 
loopdedc:    inc      de                   ; $dedc 13              ; 
             sbc      hl,bc                ; $dedd ed 42           ; 
             jr       nc,loopdedc          ; $dedf 30 fb           ; 
             pop      bc                   ; $dee1 c1              ; 
             ld       a,b                  ; $dee2 78              ; 
             or       a,a                  ; $dee3 b7              ; 
             jr       nz,skipdee8          ; $dee4 20 02           ; 
             ld       a,$42                ; $dee6 3e 42           ; 
skipdee8:    sub      a,$41                ; $dee8 d6 41           ; 
             cp       a,$08                ; $deea fe 08           ; 
             jp       nc,jumpf590          ; $deec d2 90 f5        ; 
             ld       b,a                  ; $deef 47              ; 
             and      a,$06                ; $def0 e6 06           ; 
             add      a,b                  ; $def2 80              ; 
             add      a,a                  ; $def3 87              ; 
             add      a,a                  ; $def4 87              ; 
             or       a,$82                ; $def5 f6 82           ; 
             ld       c,a                  ; $def7 4f              ; 
             ret                           ; $def8 c9              ; 

;
; inst_csave / inst_save — CSAVE / SAVE statements
; CSAVE "name" — save BASIC program to cassette.
; callde24: parse quoted filename; prepare cassette I/O descriptor.
; Falls into the shared save loop (skipdf03).
; 
; SAVE "name" — save BASIC program to RAM file storage.
; ld a,$01; callddf5: set save mode = 1 (RAM, not cassette); parse name.
; Falls into the shared save loop (skipdf03).
; 
; Shared loop (skipdf03):
; RST $38: write file header block.
; callf2d9: advance past the header (HL = first program byte).
; Loop (loopdf0e): read byte from $00B2 (program start); write via
; RST $28 (output byte); compare with RST $20 to detect end; repeat.
; Write two trailer bytes via RST $38 ($8D / $86).
; Close device (jumpe89e).
; 
; CSAVE statement.  Parse filename (callde24); write header via
; RST $38; stream program bytes from $00B2 via RST $28 until
; done; write trailer; close cassette.
;
inst_csave:  call     cas_open_write       ; $def9 cd 24 de        ; 
             jr       cas_save_loop        ; $defc 18 05           ; 

;
; SAVE statement.  Set mode=1 (callddf5); write header via
; RST $38; stream program bytes from $00B2 via RST $28 until
; done; write trailer; close device.
;
inst_save:   ld       a,$01                ; $defe 3e 01           ; 
             call     cas_parse_open       ; $df00 cd f5 dd        ; 
;
; cas_save_loop — shared save body for CSAVE and SAVE
; Fallen into from inst_csave (via cas_open_write) and inst_save
; (via cas_parse_open).  Pushes HL; issues RST $38+$82 (write file
; header block); calls callf2d9 to skip past the header and set HL
; to the first program byte.  Enters loopdf0e: reads successive bytes
; from ($00B2) (program-start pointer), outputs each byte via RST $28
; (print-byte dispatcher) and tests end-of-program via RST $20; loops
; with carry set until end reached.  Writes two trailer bytes via
; RST $38+$8D and RST $38+$86 (close/confirm), then calls cas_close
; (calldfe1) and returns.
; 
; Write header (RST $38+$82); stream bytes from $00B2 via
; RST $28; RST $20 end-test; write trailer; close channel.
;
cas_save_loop: push     hl                   ; $df03 e5              ; 
             rst      rst0038              ; $df04 ff              ; 
             add      a,d                  ; $df05 82              ; 
             call     basic_relink_from_start ; $df06 cd d9 f2        ; 
             inc      hl                   ; $df09 23              ; 
             ex       de,hl                ; $df0a eb              ; 
             ld       hl,($00b2)           ; $df0b 2a b2 00        ; 
loopdf0e:    ld       a,(hl)               ; $df0e 7e              ; 
             inc      hl                   ; $df0f 23              ; 
             rst      rst0028              ; $df10 ef              ; 
             rst      rst0020              ; $df11 e7              ; 
             jr       c,loopdf0e           ; $df12 38 fa           ; 
             xor      a,a                  ; $df14 af              ; 
             call     cassette_emit_repeat_byte_10 ; $df15 cd e4 e0        ; 
             rst      rst0038              ; $df18 ff              ; 
             adc      a,l                  ; $df19 8d              ; 
             rst      rst0038              ; $df1a ff              ; 
             add      a,(hl)               ; $df1b 86              ; 
             call     io_close_channel     ; $df1c cd 9e e8        ; 
             pop      hl                   ; $df1f e1              ; 
             ret                           ; $df20 c9              ; 

;
; cas_check_print_token — detect and consume optional $9F PRINT prefix
; Called first by both inst_cload and inst_load to disambiguate the
; CLOAD/LOAD operand.  Subtracts $9F from the current byte: if zero
; (PRINT token present), clears $02FE to 0 (cassette mode) and
; advances past the token; otherwise backs up HL and sets $02FE=1
; (RAM file mode).  Performs RST $10 (I/O-ready read) and returns A=0.
; 
; If token=$9F: $02FE=0 (cassette); else $02FE=1 (RAM);
; RST $10; return A=0.
;
cas_check_print_token: sub      a,$9f                ; $df21 d6 9f           ; 
             jr       z,skipdf28           ; $df23 28 03           ; 
             ld       a,$01                ; $df25 3e 01           ; 
             dec      hl                   ; $df27 2b              ; 
skipdf28:    dec      a                    ; $df28 3d              ; 
             ld       ($02fe),a            ; $df29 32 fe 02        ; 
             rst      rst0010              ; $df2c d7              ; 
             ld       a,$00                ; $df2d 3e 00           ; 
             ret                           ; $df2f c9              ; 

;
; inst_cload / inst_load — CLOAD / LOAD statements
; calldf21: consume optional `$9F` (PRINT) token that can prefix both;
; sets $02FE = 0 (CLOAD) or 1 (LOAD).
; 
; CLOAD ["name"] — load BASIC program from cassette.
; callde11: open cassette for reading.
; Falls into shared load loop (skipdf42).
; 
; LOAD "name" — load BASIC program from RAM file storage.
; ld ix,$0000; callddf5: set load mode; parse filename.
; Falls into shared load loop (skipdf42).
; 
; Shared load loop (skipdf42):
; Set $02FF = 0.  RST $38 ($89): read file header.
; loopdf48: RST $38 ($84): scan for matching file.
; If not found (jr z,skipdf68): print "Skip:" and loop.
; When found (skipdf68): print "Found:"; clear variable area
; (callf2d9 if $02FE=0); open load buffer ($02ED); load bytes
; (loopdf82/loopdf84); on success: reset $0322, call calldfe1,
; then jump to skipf2b3 (warm restart into the new program).
; 
; CLOAD statement.  Open cassette (callde11); scan for matching
; filename; load BASIC program into RAM; restart interpreter.
;
inst_cload:  call     cas_check_print_token ; $df30 cd 21 df        ; 
             call     cas_open_read        ; $df33 cd 11 de        ; 
             jr       cas_load_entry       ; $df36 18 0a           ; 

;
; LOAD statement.  Open RAM file storage (callddf5); locate named
; file; load BASIC program into RAM; restart interpreter.
;
inst_load:   call     cas_check_print_token ; $df38 cd 21 df        ; 
             ld       ix,$0000             ; $df3b dd 21 00 00     ; 
             call     cas_parse_open       ; $df3f cd f5 dd        ; 
;
; cas_load_entry — shared load body entry for CLOAD and LOAD
; Fallen into from inst_cload (via cas_open_read) and inst_load
; (via cas_parse_open).  Clears $02FF (filename match state) to zero,
; then issues RST $38+$89 to open the device for reading (read and
; discard the current file header, positioning the tape).  Falls
; into cas_scan_loop.
; 
; Clear $02FF; RST $38+$89 (open read); fall to cas_scan_loop.
;
cas_load_entry: xor      a,a                  ; $df42 af              ; 
             ld       ($02ff),a            ; $df43 32 ff 02        ; 
             rst      rst0038              ; $df46 ff              ; 
             adc      a,c                  ; $df47 89              ; 
;
; cas_scan_loop — scan cassette blocks for a filename match
; Issues RST $38+$84 (scan: read one block header from tape and store
; the 6-byte filename at $0305).  Calls cas_filename_match (calldff4)
; to compare $0305 against $02FF; if Z (match or wildcard), jumps to
; cas_file_found.  Otherwise prints "Skip:" (DE=$DF5B; RST $38+$88;
; calle15a) and loops back to scan the next block.
; 
; RST $38+$84 scan; compare name (cas_filename_match); if Z →
; cas_file_found; else print "Skip:" and loop.
;
cas_scan_loop: rst      rst0038              ; $df48 ff              ; 
             add      a,h                  ; $df49 84              ; 
             call     cas_filename_match   ; $df4a cd f4 df        ; 
             jr       z,cas_file_found     ; $df4d 28 19           ; 
             ld       de,$df5b             ; $df4f 11 5b df        ; 
             rst      rst0038              ; $df52 ff              ; 
             adc      a,b                  ; $df53 88              ; 
             ld       c,$00                ; $df54 0e 00           ; 
             call     cassette_wait_repeat_byte_10 ; $df56 cd 5a e1        ; 
             jr       cas_scan_loop        ; $df59 18 ed           ; 

             defm     "Skip:",0                                                 ;
             defm     "Found:",0                                                ;
;
; cas_file_found — process a matched cassette file
; Prints "Found:" (DE=$DF61; RST $38+$88).  If $02FE=0 (CLOAD mode),
; calls calld216 with A=$FF to wipe the BASIC variable area.  Opens
; the load destination buffer ($02ED) as the active I/O channel via
; io_open_channel (calle827).  Enters the byte-load loop (cas_load_loop)
; with HL=$00B2 (program-start pointer).  On successful load resets
; $0322 to the end-of-program address, calls cas_close, prints the
; loaded-program message and warm-restarts into the new program
; (jp skipf2b3).
; 
; Print "Found:"; clear vars if CLOAD; open buffer; load bytes;
; close; warm-restart.
;
cas_file_found: ld       de,$df61             ; $df68 11 61 df        ; 
             rst      rst0038              ; $df6b ff              ; 
             adc      a,b                  ; $df6c 88              ; 
             ld       a,($02fe)            ; $df6d 3a fe 02        ; 
             and      a,a                  ; $df70 a7              ; 
             push     af                   ; $df71 f5              ; 
             ld       a,$ff                ; $df72 3e ff           ; 
             call     z,calld216           ; $df74 cc 16 d2        ; 
             ld       de,$02ed             ; $df77 11 ed 02        ; 
             call     io_open_channel      ; $df7a cd 27 e8        ; 
             pop      af                   ; $df7d f1              ; 
             ld       d,a                  ; $df7e 57              ; 
             ld       hl,($00b2)           ; $df7f 2a b2 00        ; 
;
; cas_load_loop / cas_load_loop_inner — inner byte load loop with retry
; Outer entry (loopdf82): sets B=$0A (retry count).
; Inner entry (loopdf84): calls calle8d4 (single-byte device read).
; On Z (end-of-stream marker): jumps to error/close path (skipdfc7).
; On C (read error): jumps to retry/abort path (skipdfbd).
; Otherwise: stores byte to (HL), calls calld1ab (advance BASIC line
; pointer), retries on carry clear (nc → skipdfb4).  Advances HL;
; if byte is non-zero, DJNZ retries inner loop; when NZ byte found,
; outer loop restarts.  On clean end, calls cas_close and warm-restarts.
; 
; Retry loop (B=$0A): read byte via calle8d4; store; advance;
; retry on error; close and restart on success.
;
cas_load_loop: ld       b,$0a                ; $df82 06 0a           ; 
loopdf84:    call     calle8d4             ; $df84 cd d4 e8        ; 
             jr       z,skipdfc7           ; $df87 28 3e           ; 
             jr       c,skipdfbd           ; $df89 38 32           ; 
             ld       e,a                  ; $df8b 5f              ; 
             sub      a,(hl)               ; $df8c 96              ; 
             and      a,d                  ; $df8d a2              ; 
             jr       nz,skipdfc7          ; $df8e 20 37           ; 
             ld       (hl),e               ; $df90 73              ; 
             call     compute_move_headroom ; $df91 cd ab d1        ; 
             jr       nc,skipdfb4          ; $df94 30 1e           ; 
             ld       a,(hl)               ; $df96 7e              ; 
             or       a,a                  ; $df97 b7              ; 
             inc      hl                   ; $df98 23              ; 
             jr       nz,cas_load_loop     ; $df99 20 e7           ; 
             djnz     loopdf84             ; $df9b 10 e7           ; 
             call     basic_relink_from_start ; $df9d cd d9 f2        ; 
             inc      hl                   ; $dfa0 23              ; 
             ld       ($0322),hl           ; $dfa1 22 22 03        ; 
             call     cas_close            ; $dfa4 cd e1 df        ; 
loopdfa7:    ld       hl,$f169             ; $dfa7 21 69 f1        ; 
             call     calle199             ; $dfaa cd 99 e1        ; 
             ld       hl,($00b2)           ; $dfad 2a b2 00        ; 
             push     hl                   ; $dfb0 e5              ; 
             jp       basic_line_entry     ; $dfb1 c3 b3 f2        ; 

skipdfb4:    call     cas_close            ; $dfb4 cd e1 df        ; 
             call     new_reset            ; $dfb7 cd 15 d2        ; 
             jp       basic_raise_error_07 ; $dfba c3 a5 d1        ; 

skipdfbd:    ld       a,($02fe)            ; $dfbd 3a fe 02        ; 
             or       a,a                  ; $dfc0 b7              ; 
             call     z,new_reset          ; $dfc1 cc 15 d2        ; 
             jp       io_event_service     ; $dfc4 c3 3f c0        ; 

skipdfc7:    call     cas_close            ; $dfc7 cd e1 df        ; 
             ld       a,($02fe)            ; $dfca 3a fe 02        ; 
             or       a,a                  ; $dfcd b7              ; 
             jr       z,skipdfee           ; $dfce 28 1e           ; 
             inc      hl                   ; $dfd0 23              ; 
             ex       de,hl                ; $dfd1 eb              ; 
             ld       hl,($0322)           ; $dfd2 2a 22 03        ; 
             rst      rst0020              ; $dfd5 e7              ; 
             jr       c,loopdfa7           ; $dfd6 38 cf           ; 
             ld       hl,$dfe8             ; $dfd8 21 e8 df        ; 
             call     calle199             ; $dfdb cd 99 e1        ; 
             jp       basic_command_loop   ; $dfde c3 3c f2        ; 

;
; cas_close — close cassette channel after load or save
; Issues RST $38+$8D then RST $38+$87 to write the two cassette
; trailer/confirm bytes, then jumps to io_close_channel (jumpe89e) to
; restore the default I/O channel.  Called at the end of both save
; and load operations, and on error paths that require a clean shutdown.
; 
; RST $38+$8D; RST $38+$87; jp io_close_channel.
;
cas_close:   rst      rst0038              ; $dfe1 ff              ; 
             adc      a,l                  ; $dfe2 8d              ; 
             rst      rst0038              ; $dfe3 ff              ; 
             add      a,a                  ; $dfe4 87              ; 
             jp       io_close_channel     ; $dfe5 c3 9e e8        ; 

             defb     $42,$61,$64,$0d,$0a,$00                      ; Bad...     ; 
skipdfee:    call     new_reset            ; $dfee cd 15 d2        ; 
             jp       jumpe8b6             ; $dff1 c3 b6 e8        ; 

;
; cas_filename_match — compare 6-byte filename at $0305 against $02FF
; If $02FF=0 (wildcard / no target name stored), returns immediately
; with Z set (matches any file).  Otherwise compares each of the 6 bytes
; of the received filename (at $02FF) with the target stored at $0305,
; using CPI; returns Z if all 6 bytes match, NZ at the first mismatch.
; Called from cas_scan_loop after every RST $38+$84 block scan.
; 
; If $02FF=0: ret Z (wildcard match).  Else compare 6 bytes
; of $02FF against $0305; ret Z on full match, NZ on mismatch.
;
cas_filename_match: ld       hl,$0305             ; $dff4 21 05 03        ; 
             ld       de,$02ff             ; $dff7 11 ff 02        ; 
             ld       a,(de)               ; $dffa 1a              ; 
             or       a,a                  ; $dffb b7              ; 
             ret      z                    ; $dffc c8              ; 

             ld       bc,$0006             ; $dffd 01 06 00        ; 
loope000:    ld       a,(de)               ; $e000 1a              ; 
             cpi                           ; $e001 ed a1           ; 
             inc      de                   ; $e003 13              ; 
             ret      nz                   ; $e004 c0              ; 

             ld       a,c                  ; $e005 79              ; 
             or       a,b                  ; $e006 b0              ; 
             jr       nz,loope000          ; $e007 20 f7           ; 
             ret                           ; $e009 c9              ; 

             defb     $3e,$01,$f3,$cd,$7d,$c2,$37,$f5,$3a,$0c      ; >...}.7.:. ; 
             defb     $03,$b7,$28,$07,$af,$32,$0c,$03,$f1,$18      ; ..(..2.... ; 
             defb     $02,$f1,$3f,$f5,$28,$17,$3e,$01,$cd,$aa      ; ..?.(.>... ; 
             defb     $c2,$fe,$07,$38,$0e,$db,$f4,$e6,$18,$20      ; ...8...... ; 
             defb     $08,$3a,$0b,$03,$f6,$20,$cd,$9e,$de,$fb      ; .:........ ; 
loope03c:    pop      af                   ; $e03c f1              ; 
             ret                           ; $e03d c9              ; 

;
; serial_wait_tx_ready — shared COM / cassette transmit-ready handshake
; Polls port $F6 bit 0 until the transmitter can accept a byte.  If the
; bit is still clear, returns with carry set so the caller can retry.
; Once ready, writes A to port $F7 and strobes $08 to port $F5, then
; returns with carry clear.
;
serial_wait_tx_ready: scf                           ; $e03e 37              ; 
             push     af                   ; $e03f f5              ; 
             in       a,($f6)              ; $e040 db f6           ; 
             rra                           ; $e042 1f              ; 
             jr       nc,loope03c          ; $e043 30 f7           ; 
             pop      af                   ; $e045 f1              ; 
             ccf                           ; $e046 3f              ; 
             out      ($f7),a              ; $e047 d3 f7           ; 
             ld       a,$08                ; $e049 3e 08           ; 
             out      ($f5),a              ; $e04b d3 f5           ; 
             ret                           ; $e04d c9              ; 

;
; serial_write_byte — shared byte transmitter with retry / status checks
; Saves the byte in B, first checks calle8e8 for pending abort/status in
; $002B, then loops on serial_wait_tx_ready until the COM / cassette path
; accepts the byte.  After the strobe it waits for port $F6 bits 0 and 2
; to read back as $05 before returning.
;
serial_write_byte: ld       b,a                  ; $e04e 47              ; 
             call     calle8e8             ; $e04f cd e8 e8        ; 
             ld       a,b                  ; $e052 78              ; 
             ret      nz                   ; $e053 c0              ; 

             call     serial_wait_tx_ready ; $e054 cd 3e e0        ; 
             jr       c,serial_write_byte  ; $e057 38 f5           ; 
loope059:    call     calle8e8             ; $e059 cd e8 e8        ; 
             ret      nz                   ; $e05c c0              ; 

             in       a,($f6)              ; $e05d db f6           ; 
             and      a,$05                ; $e05f e6 05           ; 
             cp       a,$05                ; $e061 fe 05           ; 
             jr       nz,loope059          ; $e063 20 f4           ; 
             ret                           ; $e065 c9              ; 

;
; com_printer_put_char — shared COM / PRT character-output routine
; Hidden primary driver block used by both the `COM:` and `PRT:` records
; in io_device_driver_table.  Calls io_event_service, then uses the
; shared transmit helper serial_wait_tx_ready to present the byte through
; the external port-$f6/$f7/$f5 path before returning to the caller.
;
com_printer_put_char: call     io_event_service     ; $e066 cd 3f c0        ; 
             call     serial_wait_tx_ready ; $e069 cd 3e e0        ; 
             ret      nc                   ; $e06c d0              ; 

             jr       com_printer_put_char ; $e06d 18 f7           ; 

;
; cassette_output_put_char — hidden CASO character-output routine
; Primary output block for the `CASO:` record.  Saves A, asserts the
; cassette-output bit on port $F4, runs the shared serial_write_byte
; helper, then clears that bit again before exiting through the common
; OUT ($F4),A tail at $E0D4.
;
cassette_output_put_char: push     af                   ; $e06f f5              ; 
             in       a,($f4)              ; $e070 db f4           ; 
             and      a,$7f                ; $e072 e6 7f           ; 
             or       a,$02                ; $e074 f6 02           ; 
             out      ($f4),a              ; $e076 d3 f4           ; 
             pop      af                   ; $e078 f1              ; 
             call     serial_write_byte    ; $e079 cd 4e e0        ; 
             in       a,($f4)              ; $e07c db f4           ; 
             and      a,$7d                ; $e07e e6 7d           ; 
             jr       skipe0d4             ; $e080 18 52           ; 

             defb     $f3,$f5,$3e,$01,$cd,$9e,$de,$fb,$f1,$cd      ; ..>....... ; 
             defb     $4e,$e0,$3e,$04,$d3,$f5,$3a,$0b,$03,$f6      ; N.>...:... ; 
             defb     $10,$d3,$f6,$3e,$04,$cd,$9e,$de,$fb,$c3      ; ...>...... ; 
             defb     $3f,$c0                                      ; ?.         ; 
loope0a2:    push     af                   ; $e0a2 f5              ; 
             rst      rst0010              ; $e0a3 d7              ; 
             jp       nz,jumpf590          ; $e0a4 c2 90 f5        ; 
             pop      af                   ; $e0a7 f1              ; 
             cp       a,$ac                ; $e0a8 fe ac           ; 
             jr       z,skipe0c0           ; $e0aa 28 14           ; 
             cp       a,$9b                ; $e0ac fe 9b           ; 
             jp       nz,jumpf590          ; $e0ae c2 90 f5        ; 
loope0b1:    in       a,($f4)              ; $e0b1 db f4           ; 
             and      a,$7f                ; $e0b3 e6 7f           ; 
             or       a,$03                ; $e0b5 f6 03           ; 
             jr       skipe0d4             ; $e0b7 18 1b           ; 

;
; inst_motor — MOTOR statement (cassette motor control)
; MOTOR ON | MOTOR OFF
; Controls the cassette motor via port $F4.
; Token $AC → skipe0c0: IN A,($F4); AND $7C (clear bits 0–1) → motor OFF.
; Token $9B → loope0b1: IN A,($F4); AND $7F; OR $03 (set bits 0–1) → motor ON.
; MOTOR (no arg): reads current motor state from port; if already running,
; fall through to the ON/OFF test; otherwise toggles on.
; Result written back via OUT ($F4),A.
; 
; MOTOR statement.  MOTOR ON ($9B): set bits 0–1 of port $F4.
; MOTOR OFF ($AC): clear bits 0–1 of port $F4.
; No argument: toggle based on current state from port $F4.
;
inst_motor:  jr       nz,loope0a2          ; $e0b9 20 e7           ; 
             in       a,($f4)              ; $e0bb db f4           ; 
             rra                           ; $e0bd 1f              ; 
             jr       nc,loope0b1          ; $e0be 30 f1           ; 
skipe0c0:    in       a,($f4)              ; $e0c0 db f4           ; 
             and      a,$7c                ; $e0c2 e6 7c           ; 
             jr       skipe0d4             ; $e0c4 18 0e           ; 

;
; cassette_delay_then_clear_f4 — wait, then return the cassette latch to idle
; Delays for $0FA0 service ticks through io_delay_service_loop, then
; falls into cassette_clear_f4_transfer_bits to clear the cassette / motor
; control bits in port $F4.
;
cassette_delay_then_clear_f4: ld       de,$0fa0             ; $e0c6 11 a0 0f        ; 
             call     io_delay_service_loop ; $e0c9 cd 06 e1        ; 
;
; cassette_clear_f4_transfer_bits — mask port $F4 down to the idle cassette bits
; Reads port $F4, keeps only bits 2–6 (AND $7C), then jumps to the common
; OUT ($F4),A tail.  Used when the CASI/CASO transfer core leaves the line idle.
;
cassette_clear_f4_transfer_bits: in       a,($f4)              ; $e0cc db f4           ; 
             and      a,$7c                ; $e0ce e6 7c           ; 
             jr       skipe0d4             ; $e0d0 18 02           ; 

;
; cassette_set_f4_transfer_mode — force the cassette transfer mask on port $F4
; Loads A=$CB and falls into the shared OUT ($F4),A tail at $E0D4.
; Used before the framed-byte helpers emit leaders and headers.
;
cassette_set_f4_transfer_mode: ld       a,$cb                ; $e0d2 3e cb           ; 
skipe0d4:    out      ($f4),a              ; $e0d4 d3 f4           ; 
             ret                           ; $e0d6 c9              ; 

;
; cassette_emit_sync_9c — emit the ten-byte $9C sync run
; Loads A=$9C and falls into cassette_emit_repeat_byte.  This is the
; CASO command-$03 path from cassette_output_driver_dispatch.
;
cassette_emit_sync_9c: ld       a,$9c                ; $e0d7 3e 9c           ; 
;
; cassette_emit_repeat_byte — emit the current byte ten times with cassette timing
; Pushes A, forces port $F4 into the transfer mask, waits $5DC0 service
; ticks, restores A, then falls into cassette_emit_repeat_byte_10 to send
; ten copies through the active output channel.
;
cassette_emit_repeat_byte: push     af                   ; $e0d9 f5              ; 
             call     cassette_set_f4_transfer_mode ; $e0da cd d2 e0        ; 
             ld       de,$5dc0             ; $e0dd 11 c0 5d        ; 
             call     io_delay_service_loop ; $e0e0 cd 06 e1        ; 
             pop      af                   ; $e0e3 f1              ; 
;
; cassette_emit_repeat_byte_10 — shared ten-byte RST $28 output loop
; Sets B=$0A and emits A ten times through RST $28.  Used for both the
; `$9C` sync run and the `$D3` header leader.
;
cassette_emit_repeat_byte_10: ld       b,$0a                ; $e0e4 06 0a           ; 
loope0e6:    rst      rst0028              ; $e0e6 ef              ; 
             djnz     loope0e6             ; $e0e7 10 fd           ; 
             ret                           ; $e0e9 c9              ; 

;
; cassette_write_header_block — write the cassette header leader and filename
; Clears / seeds the six-byte buffer at $02FF via cassette_prepare_filename_buffer,
; requires a non-zero first byte, emits the `$D3` leader through
; cassette_emit_repeat_byte, then outputs the six filename bytes from $02FF
; and waits a final $07D0 service ticks before returning.
;
cassette_write_header_block: call     cassette_prepare_filename_buffer ; $e0ea cd 6a e1        ; 
             ld       a,($02ff)            ; $e0ed 3a ff 02        ; 
             or       a,a                  ; $e0f0 b7              ; 
             jp       z,jumpf590           ; $e0f1 ca 90 f5        ; 
             ld       a,$d3                ; $e0f4 3e d3           ; 
             call     cassette_emit_repeat_byte ; $e0f6 cd d9 e0        ; 
             ld       hl,$02ff             ; $e0f9 21 ff 02        ; 
             ld       b,$06                ; $e0fc 06 06           ; 
loope0fe:    ld       a,(hl)               ; $e0fe 7e              ; 
             inc      hl                   ; $e0ff 23              ; 
             rst      rst0028              ; $e100 ef              ; 
             djnz     loope0fe             ; $e101 10 fb           ; 
             ld       de,$07d0             ; $e103 11 d0 07        ; 
;
; io_delay_service_loop — busy delay that still services asynchronous I/O
; Repeatedly calls io_event_service while DE counts down to zero.  The
; cassette framing helpers use it for the long inter-phase timing gaps.
;
io_delay_service_loop: call     io_event_service     ; $e106 cd 3f c0        ; 
             dec      de                   ; $e109 1b              ; 
             ld       a,e                  ; $e10a 7b              ; 
             or       a,d                  ; $e10b b2              ; 
             jr       nz,io_delay_service_loop ; $e10c 20 f8           ; 
             ret                           ; $e10e c9              ; 

;
; cassette_input_driver_dispatch — hidden CASI command dispatcher
; RST $38 high-bit commands for the active `CASI:` channel arrive here
; through the descriptor's +8 vector.  The body recognises command
; bytes $05, $08, $09, $07, and $04, branching to cassette-specific
; helpers including the filename / header paths at $E18A and $E1AC.
; All cases return through the common register-restore stub at $E897.
;
cassette_input_driver_dispatch: push     hl                   ; $e10f e5              ; 
             push     de                   ; $e110 d5              ; 
             push     bc                   ; $e111 c5              ; 
             ld       hl,skipe897          ; $e112 21 97 e8        ; 
             push     hl                   ; $e115 e5              ; 
             cp       a,$05                ; $e116 fe 05           ; 
             jr       z,cassette_wait_sync_9c ; $e118 28 37           ; 
             cp       a,$08                ; $e11a fe 08           ; 
             jp       z,jumpe18a           ; $e11c ca 8a e1        ; 
             cp       a,$09                ; $e11f fe 09           ; 
             jr       z,cassette_prepare_filename_buffer ; $e121 28 47           ; 
             cp       a,$07                ; $e123 fe 07           ; 
             jr       z,cassette_clear_f4_transfer_bits ; $e125 28 a5           ; 
             cp       a,$04                ; $e127 fe 04           ; 
             jp       z,cassette_read_header_block ; $e129 ca ac e1        ; 
             jr       skipe142             ; $e12c 18 14           ; 

;
; cassette_output_driver_dispatch — hidden CASO command dispatcher
; RST $38 high-bit commands for the active `CASO:` channel arrive here
; through the descriptor's +8 vector.  The body recognises command
; bytes $03, $02, $06, and $0D; the $02/$03 paths enter the header / sync
; helpers below, and the $0D path refreshes the cassette control state by
; calling cas_port_clear and then io_ctrl_commit.
;
cassette_output_driver_dispatch: push     hl                   ; $e12e e5              ; 
             push     de                   ; $e12f d5              ; 
             push     bc                   ; $e130 c5              ; 
             ld       hl,skipe897          ; $e131 21 97 e8        ; 
             push     hl                   ; $e134 e5              ; 
             cp       a,$03                ; $e135 fe 03           ; 
             jr       z,cassette_emit_sync_9c ; $e137 28 9e           ; 
             cp       a,$02                ; $e139 fe 02           ; 
             jr       z,cassette_write_header_block ; $e13b 28 ad           ; 
             cp       a,$06                ; $e13d fe 06           ; 
             jp       z,cassette_delay_then_clear_f4 ; $e13f ca c6 e0        ; 
skipe142:    cp       a,$0d                ; $e142 fe 0d           ; 
             ret      nz                   ; $e144 c0              ; 

             xor      a,a                  ; $e145 af              ; 
             call     callde9e             ; $e146 cd 9e de        ; 
             ld       a,($026c)            ; $e149 3a 6c 02        ; 
             and      a,$3c                ; $e14c e6 3c           ; 
             jp       io_ctrl_commit       ; $e14e c3 97 de        ; 

;
; cassette_wait_sync_9c — wait for ten successive `$9C` sync bytes
; Resets the shared key / I/O poll state through calle1c3, enables
; interrupts, loads C=$9C, then falls into cassette_wait_repeat_byte_10.
; This is the CASI command-$05 path.
;
cassette_wait_sync_9c: call     calle1c3             ; $e151 cd c3 e1        ; 
             ei                            ; $e154 fb              ; 
             ld       c,$9c                ; $e155 0e 9c           ; 
calle157:    call     cassette_set_f4_transfer_mode ; $e157 cd d2 e0        ; 
;
; cassette_wait_repeat_byte_10 — generic "read ten matching bytes" helper
; Sets B=$0A and repeatedly calls calle8d4.  Carry errors are handed to
; io_event_service; zero results restart the scan; mismatches restart the
; ten-byte run; ten successful matches return to the caller.
;
cassette_wait_repeat_byte_10: ld       b,$0a                ; $e15a 06 0a           ; 
loope15c:    call     calle8d4             ; $e15c cd d4 e8        ; 
             call     c,io_event_service   ; $e15f dc 3f c0        ; 
             jr       z,cassette_wait_repeat_byte_10 ; $e162 28 f6           ; 
             sub      a,c                  ; $e164 91              ; 
             jr       nz,cassette_wait_repeat_byte_10 ; $e165 20 f3           ; 
             djnz     loope15c             ; $e167 10 f3           ; 
             ret                           ; $e169 c9              ; 

;
; cassette_prepare_filename_buffer — clear $02FF and preload an expected filename
; Zero-fills the six-byte work buffer at $02FF.  If the current cassette
; descriptor in $02F5/$02F6 carries a filename, copies up to six bytes of
; it into $02FF so the header writers / scanners use the same staging area.
;
cassette_prepare_filename_buffer: ld       hl,$02ff             ; $e16a 21 ff 02        ; 
             push     hl                   ; $e16d e5              ; 
             ld       b,$06                ; $e16e 06 06           ; 
loope170:    ld       (hl),$00             ; $e170 36 00           ; 
             inc      hl                   ; $e172 23              ; 
             djnz     loope170             ; $e173 10 fb           ; 
             pop      de                   ; $e175 d1              ; 
             ld       hl,($02f6)           ; $e176 2a f6 02        ; 
             ld       a,($02f5)            ; $e179 3a f5 02        ; 
             or       a,a                  ; $e17c b7              ; 
             ret      z                    ; $e17d c8              ; 

             cp       a,$07                ; $e17e fe 07           ; 
             jr       c,skipe184           ; $e180 38 02           ; 
             ld       a,$06                ; $e182 3e 06           ; 
skipe184:    ld       c,a                  ; $e184 4f              ; 
             ld       b,$00                ; $e185 06 00           ; 
             ldir                          ; $e187 ed b0           ; 
             ret                           ; $e189 c9              ; 

jumpe18a:    ex       de,hl                ; $e18a eb              ; 
             call     calle199             ; $e18b cd 99 e1        ; 
             ld       bc,$0305             ; $e18e 01 05 03        ; 
             ld       d,$07                ; $e191 16 07           ; 
             call     loope1a3             ; $e193 cd a3 e1        ; 
             ld       hl,$dfeb             ; $e196 21 eb df        ; 
calle199:    call     str_scan_literal     ; $e199 cd 6e d5        ; 
             call     str_load_result_descriptor ; $e19c cd 04 d7        ; 
             call     callca3b             ; $e19f cd 3b ca        ; 
             inc      d                    ; $e1a2 14              ; 
loope1a3:    dec      d                    ; $e1a3 15              ; 
             ret      z                    ; $e1a4 c8              ; 

             ld       a,(bc)               ; $e1a5 0a              ; 
             call     jump009f             ; $e1a6 cd 9f 00        ; 
             inc      bc                   ; $e1a9 03              ; 
             jr       loope1a3             ; $e1aa 18 f7           ; 

;
; cassette_read_header_block — detect the `$D3` leader and read six filename bytes
; Loads C=$D3, reuses cassette_wait_repeat_byte_10 to detect the ten-byte
; header leader, then reads six bytes through calle8d4 into $0305-$030A.
; Carry errors dispatch through io_event_service; zero results restart the
; header scan until a full filename block has been collected.
;
cassette_read_header_block: ld       c,$d3                ; $e1ac 0e d3           ; 
             call     calle157             ; $e1ae cd 57 e1        ; 
             ld       hl,$0305             ; $e1b1 21 05 03        ; 
             ld       b,$06                ; $e1b4 06 06           ; 
loope1b6:    call     calle8d4             ; $e1b6 cd d4 e8        ; 
             jp       c,io_event_service   ; $e1b9 da 3f c0        ; 
             jr       z,cassette_read_header_block ; $e1bc 28 ee           ; 
             ld       (hl),a               ; $e1be 77              ; 
             inc      hl                   ; $e1bf 23              ; 
             djnz     loope1b6             ; $e1c0 10 f4           ; 
             ret                           ; $e1c2 c9              ; 

calle1c3:    di                            ; $e1c3 f3              ; 
             ld       de,$02a3             ; $e1c4 11 a3 02        ; 
             ld       b,$1f                ; $e1c7 06 1f           ; 
             ld       a,$01                ; $e1c9 3e 01           ; 
             jp       key_entry_init       ; $e1cb c3 9a c2        ; 

calle1ce:    ld       a,(hl)               ; $e1ce 7e              ; 
             ld       bc,$0000             ; $e1cf 01 00 00        ; 
             ld       d,b                  ; $e1d2 50              ; 
             ld       e,c                  ; $e1d3 59              ; 
             cp       a,$d2                ; $e1d4 fe d2           ; 
             jr       z,skipe1ee           ; $e1d6 28 16           ; 
;
; Parse [STEP] (X,Y) from the BASIC token stream (HL).
; If STEP token ($D0) precedes the pair, coordinates are relative to
; the current graphics cursor ($04C6 = X, $04C8 = Y); otherwise they
; are absolute.  The graphics cursor is updated to the resolved (X,Y).
; Returns BC = final X, DE = final Y.  HL advanced past ')'.
; See also calle1ce: the 'LINE -' variant that omits the coordinate
; pair and defaults to BC = DE = 0 (relative from cursor).
;
parse_coord_pair: ld       a,(hl)               ; $e1d8 7e              ; 
             cp       a,$d0                ; $e1d9 fe d0           ; 
             push     af                   ; $e1db f5              ; 
             call     z,rst10_fetch_token  ; $e1dc cc 37 f5        ; 
             rst      rst0008              ; $e1df cf              ; 
             defb     $28                                          ; (          ; 
             call     eval_expr_to_addr    ; $e1e1 cd cc ff        ; 
             push     de                   ; $e1e4 d5              ; 
             rst      rst0008              ; $e1e5 cf              ; 
             defb     $2c                                          ; ,          ; 
             call     eval_expr_to_addr    ; $e1e7 cd cc ff        ; 
             rst      rst0008              ; $e1ea cf              ; 
             defb     $29                                          ; )          ; 
             pop      bc                   ; $e1ec c1              ; 
             pop      af                   ; $e1ed f1              ; 
skipe1ee:    push     hl                   ; $e1ee e5              ; 
             ld       hl,($04c6)           ; $e1ef 2a c6 04        ; 
             jr       z,skipe1f7           ; $e1f2 28 03           ; 
             ld       hl,$0000             ; $e1f4 21 00 00        ; 
skipe1f7:    add      hl,bc                ; $e1f7 09              ; 
             ld       ($04c6),hl           ; $e1f8 22 c6 04        ; 
             ld       ($04ca),hl           ; $e1fb 22 ca 04        ; 
             ld       b,h                  ; $e1fe 44              ; 
             ld       c,l                  ; $e1ff 4d              ; 
             ld       hl,($04c8)           ; $e200 2a c8 04        ; 
             jr       z,skipe208           ; $e203 28 03           ; 
             ld       hl,$0000             ; $e205 21 00 00        ; 
skipe208:    add      hl,de                ; $e208 19              ; 
             ld       ($04c8),hl           ; $e209 22 c8 04        ; 
             ld       ($04cc),hl           ; $e20c 22 cc 04        ; 
             ex       de,hl                ; $e20f eb              ; 
             pop      hl                   ; $e210 e1              ; 
             ret                           ; $e211 c9              ; 

;
; inst_locate — LOCATE statement (set text cursor position)
; LOCATE col, row
; eval_expr_to_int8 → E (column, 1-based); validate E ≤ $00BA-1 (screen
; width), else error.
; RST $08 / $2C: require comma.
; eval_expr_to_int8 → E (row, 0-based); validate E < ($00BD − $00B5)
; (visible row count), else error.
; callc164: convert (col, row) to absolute cursor offset; update cursor.
; calle3fe: check display mode ($00B6); if scroll needed, call jumpc231.
; 
; LOCATE statement.  LOCATE col,row.
; Validates column (1..screenwidth) and row (0..screenheight−1).
; callc164 updates cursor registers; calle3fe handles scroll.
;
inst_locate: call     eval_expr_to_int8    ; $e212 cd 5e fe        ; 
             ld       a,($00ba)            ; $e215 3a ba 00        ; 
             dec      a                    ; $e218 3d              ; 
             cp       a,e                  ; $e219 bb              ; 
             jp       c,jumpf590           ; $e21a da 90 f5        ; 
             push     de                   ; $e21d d5              ; 
             rst      rst0008              ; $e21e cf              ; 
             inc      l                    ; $e21f 2c              ; 
             call     eval_expr_to_int8    ; $e220 cd 5e fe        ; 
             ld       a,($00b5)            ; $e223 3a b5 00        ; 
             ld       b,a                  ; $e226 47              ; 
             ld       a,($00bd)            ; $e227 3a bd 00        ; 
             sub      a,b                  ; $e22a 90              ; 
             ld       c,a                  ; $e22b 4f              ; 
             ld       a,e                  ; $e22c 7b              ; 
             cp       a,c                  ; $e22d b9              ; 
             jp       nc,jumpf590          ; $e22e d2 90 f5        ; 
             inc      a                    ; $e231 3c              ; 
             ex       (sp),hl              ; $e232 e3              ; 
             inc      l                    ; $e233 2c              ; 
             ld       h,l                  ; $e234 65              ; 
             ld       l,a                  ; $e235 6f              ; 
             call     text_cursor_store_and_sync ; $e236 cd 64 c1        ; 
             call     disp_col_mode_get    ; $e239 cd fe e3        ; 
             ld       c,$00                ; $e23c 0e 00           ; 
             call     z,disp_set_cursor    ; $e23e cc 31 c2        ; 
             pop      hl                   ; $e241 e1              ; 
             ret                           ; $e242 c9              ; 

;
; inst_console — CONSOLE statement (configure display layout)
; CONSOLE [width][,fkey][,mode]
; Sets the terminal console parameters: character width, function-key
; display area size, and line/scroll mode.
; Entry: A = next token.
; With no args (A = $40 = `@`): jump jumpe2e6 (show CONSOLE status).
; With args: parse up to 3 integer arguments separated by commas.
; Arg 1 (width): calle35d → validate ≥ 1; update $00B5 (char width).
; Arg 2 (fkey area): validate ≥ 0; update display scroll region.
; Arg 3 (mode): set $00B6 (scroll/wrap mode flag).
; After setting, update scroll region boundary ($00BD) and redraw as needed.
; 
; CONSOLE statement.  Configure display: width, function-key
; line count, and scroll mode.  Up to 3 comma-separated integer
; arguments.  CONSOLE @ shows current settings.
; Updates $00B5 (width), $00BD (height), $00B6 (mode).
;
inst_console: push     af                   ; $e243 f5              ; 
             ld       de,($00bb)           ; $e244 ed 5b bb 00     ; 
             ld       a,d                  ; $e248 7a              ; 
             sub      a,e                  ; $e249 93              ; 
             ld       d,a                  ; $e24a 57              ; 
             pop      af                   ; $e24b f1              ; 
             cp       a,$2c                ; $e24c fe 2c           ; 
             jr       z,skipe265           ; $e24e 28 15           ; 
             cp       a,$40                ; $e250 fe 40           ; 
             jp       z,console_at_handler ; $e252 ca e6 e2        ; 
             call     eval_int8_preserve   ; $e255 cd 5d e3        ; 
             push     af                   ; $e258 f5              ; 
             inc      a                    ; $e259 3c              ; 
             jp       z,jumpf590           ; $e25a ca 90 f5        ; 
             ld       e,a                  ; $e25d 5f              ; 
             pop      af                   ; $e25e f1              ; 
             jr       nz,skipe265          ; $e25f 20 04           ; 
             push     af                   ; $e261 f5              ; 
loope262:    ld       a,d                  ; $e262 7a              ; 
             jr       skipe272             ; $e263 18 0d           ; 

skipe265:    rst      rst0008              ; $e265 cf              ; 
             inc      l                    ; $e266 2c              ; 
             push     af                   ; $e267 f5              ; 
             cp       a,$2c                ; $e268 fe 2c           ; 
             jr       z,loope262           ; $e26a 28 f6           ; 
             pop      af                   ; $e26c f1              ; 
             call     eval_int8_preserve   ; $e26d cd 5d e3        ; 
             push     af                   ; $e270 f5              ; 
             dec      a                    ; $e271 3d              ; 
skipe272:    add      a,e                  ; $e272 83              ; 
             jr       c,skipe27a           ; $e273 38 05           ; 
             ld       d,a                  ; $e275 57              ; 
             ld       a,($00bd)            ; $e276 3a bd 00        ; 
             cp       a,d                  ; $e279 ba              ; 
skipe27a:    jp       c,jumpf590           ; $e27a da 90 f5        ; 
             pop      af                   ; $e27d f1              ; 
             jr       z,skipe2cc           ; $e27e 28 4c           ; 
             rst      rst0008              ; $e280 cf              ; 
             inc      l                    ; $e281 2c              ; 
             cp       a,$2c                ; $e282 fe 2c           ; 
             jr       z,skipe2a5           ; $e284 28 1f           ; 
             call     eval_int8_preserve   ; $e286 cd 5d e3        ; 
             push     af                   ; $e289 f5              ; 
             cp       a,$02                ; $e28a fe 02           ; 
             jr       nc,skipe2c2          ; $e28c 30 34           ; 
             ld       c,a                  ; $e28e 4f              ; 
             call     disp_col_mode_get    ; $e28f cd fe e3        ; 
             jr       nz,skipe2a2          ; $e292 20 0e           ; 
             ld       a,($00b5)            ; $e294 3a b5 00        ; 
             cp       a,c                  ; $e297 b9              ; 
             ld       a,c                  ; $e298 79              ; 
             set      $06,a                ; $e299 cb f7           ; 
             jr       nz,skipe29f          ; $e29b 20 02           ; 
             and      a,$01                ; $e29d e6 01           ; 
skipe29f:    ld       ($00b5),a            ; $e29f 32 b5 00        ; 
skipe2a2:    pop      af                   ; $e2a2 f1              ; 
             jr       z,skipe2cc           ; $e2a3 28 27           ; 
skipe2a5:    rst      rst0008              ; $e2a5 cf              ; 
             inc      l                    ; $e2a6 2c              ; 
             cp       a,$2c                ; $e2a7 fe 2c           ; 
             jr       z,skipe2bb           ; $e2a9 28 10           ; 
             call     eval_int8_preserve   ; $e2ab cd 5d e3        ; 
             push     af                   ; $e2ae f5              ; 
             cp       a,$02                ; $e2af fe 02           ; 
             jr       nc,skipe2c2          ; $e2b1 30 0f           ; 
             add      a,$38                ; $e2b3 c6 38           ; 
             call     lcd_cmd_simple       ; $e2b5 cd 28 e4        ; 
             pop      af                   ; $e2b8 f1              ; 
             jr       z,skipe2cc           ; $e2b9 28 11           ; 
skipe2bb:    rst      rst0008              ; $e2bb cf              ; 
             inc      l                    ; $e2bc 2c              ; 
             call     eval_int8_preserve   ; $e2bd cd 5d e3        ; 
             cp       a,$02                ; $e2c0 fe 02           ; 
skipe2c2:    jp       nc,jumpf590          ; $e2c2 d2 90 f5        ; 
             defb     $ed,$44,$c6,$33,$cd,$28,$e4                  ; .D.3.(.    ; 
skipe2cc:    push     hl                   ; $e2cc e5              ; 
             call     console_apply_window ; $e2cd cd 65 e3        ; 
             ld       a,($00b8)            ; $e2d0 3a b8 00        ; 
             ld       b,a                  ; $e2d3 47              ; 
             ld       a,($00bc)            ; $e2d4 3a bc 00        ; 
             cp       a,b                  ; $e2d7 b8              ; 
             jr       nc,skipe2e4          ; $e2d8 30 0a           ; 
             ld       hl,($00b8)           ; $e2da 2a b8 00        ; 
             ld       l,a                  ; $e2dd 6f              ; 
             call     text_cursor_store_and_sync ; $e2de cd 64 c1        ; 
             call     text_cursor_sync_from_state ; $e2e1 cd 42 eb        ; 
skipe2e4:    pop      hl                   ; $e2e4 e1              ; 
             ret                           ; $e2e5 c9              ; 

;
; Special CONSOLE `@...` handler.
; Parses up to three small mode arguments and forwards them directly to
; LCD/co-processor commands or register writes, including a final write
; to register $c00c via lcd_cfg_write.
;
console_at_handler: rst      rst0010              ; $e2e6 d7              ; 
             cp       a,$2c                ; $e2e7 fe 2c           ; 
             jr       z,skipe2fc           ; $e2e9 28 11           ; 
             call     eval_int8_preserve   ; $e2eb cd 5d e3        ; 
             push     af                   ; $e2ee f5              ; 
             cp       a,$02                ; $e2ef fe 02           ; 
             jr       nc,skipe2c2          ; $e2f1 30 cf           ; 
             defb     $ed,$44,$c6,$0e,$cd,$28,$e4,$f1,$c8          ; .D...(...  ; 
skipe2fc:    rst      rst0008              ; $e2fc cf              ; 
             inc      l                    ; $e2fd 2c              ; 
             cp       a,$2c                ; $e2fe fe 2c           ; 
             jr       z,skipe315           ; $e300 28 13           ; 
             call     eval_int8_preserve   ; $e302 cd 5d e3        ; 
             push     af                   ; $e305 f5              ; 
             cp       a,$01                ; $e306 fe 01           ; 
             ld       a,$1c                ; $e308 3e 1c           ; 
             jr       z,skipe310           ; $e30a 28 04           ; 
             ld       a,$40                ; $e30c 3e 40           ; 
             jr       nc,skipe2c2          ; $e30e 30 b2           ; 
skipe310:    call     lcd_cmd_simple       ; $e310 cd 28 e4        ; 
             pop      af                   ; $e313 f1              ; 
             ret      z                    ; $e314 c8              ; 

skipe315:    rst      rst0008              ; $e315 cf              ; 
             inc      l                    ; $e316 2c              ; 
             call     eval_int8_preserve   ; $e317 cd 5d e3        ; 
             cp       a,$04                ; $e31a fe 04           ; 
             jr       nc,skipe2c2          ; $e31c 30 a4           ; 
             push     hl                   ; $e31e e5              ; 
             ld       hl,$c00c             ; $e31f 21 0c c0        ; 
loope322:    call     lcd_cfg_write        ; $e322 cd 34 e3        ; 
             pop      hl                   ; $e325 e1              ; 
             ret                           ; $e326 c9              ; 

;
; disp_reset — RST $20 syscall slot 0 (RAM $0057)
; ----
; Reset the display subsystem.
; Clears bit 6 of the hardware-capability flags at $002B
; (AND with $BF via callc097), then sends LCD command $06
; with a 3-byte payload: {$0F, lo($0096), hi($0096)}.
; This configures the LCD co-processor to use the RAM vector
; at $0096 (inst_line_exec) as its callback with parameter $0F.
; Called at warm/cold start to reinitialise display state.
; 
; Reset display subsystem: clear hardware flag, configure LCD
; callback to RAM $0096 (inst_line_exec) with parameter $0F.
;
disp_reset:  push     hl                   ; $e327 e5              ; 
             ld       b,$bf                ; $e328 06 bf           ; 
             call     hw_flags_mask        ; $e32a cd 97 c0        ; 
             ld       hl,jump0096          ; $e32d 21 96 00        ; 
             ld       a,$0f                ; $e330 3e 0f           ; 
             jr       loope322             ; $e332 18 ee           ; 

;
; Write A to the LCD/co-processor configuration register addressed by HL.
; Packages the request in the $0507-$0509 scratch block and submits
; command $06.
;
lcd_cfg_write: push     hl                   ; $e334 e5              ; 
             ld       de,$0509             ; $e335 11 09 05        ; 
             ex       de,hl                ; $e338 eb              ; 
             ld       (hl),d               ; $e339 72              ; 
             dec      hl                   ; $e33a 2b              ; 
             ld       (hl),e               ; $e33b 73              ; 
             dec      hl                   ; $e33c 2b              ; 
             ld       (hl),a               ; $e33d 77              ; 
             ld       bc,$0300             ; $e33e 01 00 03        ; 
             ld       a,$06                ; $e341 3e 06           ; 
             call     lcd_submit           ; $e343 cd 2f c9        ; 
             pop      hl                   ; $e346 e1              ; 
             ret                           ; $e347 c9              ; 

;
; Read one byte from the LCD/co-processor configuration register
; addressed by HL.  Uses the $0508-$0509 scratch block and command $05.
;
lcd_cfg_read: push     hl                   ; $e348 e5              ; 
             ld       de,$0509             ; $e349 11 09 05        ; 
             ex       de,hl                ; $e34c eb              ; 
             ld       (hl),d               ; $e34d 72              ; 
             dec      hl                   ; $e34e 2b              ; 
             ld       (hl),e               ; $e34f 73              ; 
             ld       bc,$0201             ; $e350 01 01 02        ; 
             ld       a,$05                ; $e353 3e 05           ; 
             ld       d,h                  ; $e355 54              ; 
             ld       e,l                  ; $e356 5d              ; 
             call     lcd_submit           ; $e357 cd 2f c9        ; 
             ld       a,(de)               ; $e35a 1a              ; 
             pop      hl                   ; $e35b e1              ; 
             ret                           ; $e35c c9              ; 

;
; eval_int8_preserve — call eval_expr_to_int8 preserving DE and BC
; Saves DE then BC, calls eval_expr_to_int8 (A = 8-bit integer
; result from the BASIC expression under HL), then restores BC
; and DE.  Used by CONSOLE and graphics statement parsers that
; need to evaluate a sub-expression without clobbering their
; own DE/BC working registers.
; 
; Push DE, BC; call eval_expr_to_int8; pop BC, DE; RET.
;
eval_int8_preserve: push     de                   ; $e35d d5              ; 
             push     bc                   ; $e35e c5              ; 
             call     eval_expr_to_int8    ; $e35f cd 5e fe        ; 
             pop      bc                   ; $e362 c1              ; 
             pop      de                   ; $e363 d1              ; 
             ret                           ; $e364 c9              ; 

;
; Clamp and commit the current text-window / console geometry.
; Reconciles the RAM state in $00b5/$00bb/$00bd with the current mode,
; updates cursor bounds, and emits the follow-up LCD register write.
;
console_apply_window: push     bc                   ; $e365 c5              ; 
             push     hl                   ; $e366 e5              ; 
             call     disp_col_mode_get    ; $e367 cd fe e3        ; 
             push     af                   ; $e36a f5              ; 
             ld       a,($00b5)            ; $e36b 3a b5 00        ; 
             res      $06,a                ; $e36e cb b7           ; 
             jr       z,skipe373           ; $e370 28 01           ; 
             xor      a,a                  ; $e372 af              ; 
skipe373:    ld       b,a                  ; $e373 47              ; 
             ld       a,($00bd)            ; $e374 3a bd 00        ; 
             sub      a,b                  ; $e377 90              ; 
             ex       de,hl                ; $e378 eb              ; 
             cp       a,h                  ; $e379 bc              ; 
             jr       nc,skipe37d          ; $e37a 30 01           ; 
             ld       h,a                  ; $e37c 67              ; 
skipe37d:    cp       a,l                  ; $e37d bd              ; 
             jr       nc,skipe38d          ; $e37e 30 0d           ; 
             ld       hl,$00b5             ; $e380 21 b5 00        ; 
             xor      a,a                  ; $e383 af              ; 
             bit      $06,(hl)             ; $e384 cb 76           ; 
             jr       nz,skipe389          ; $e386 20 01           ; 
             inc      a                    ; $e388 3c              ; 
skipe389:    ld       (hl),a               ; $e389 77              ; 
             pop      af                   ; $e38a f1              ; 
             jr       skipe393             ; $e38b 18 06           ; 

skipe38d:    ld       ($00bb),hl           ; $e38d 22 bb 00        ; 
             pop      af                   ; $e390 f1              ; 
             jr       z,skipe396           ; $e391 28 03           ; 
skipe393:    pop      hl                   ; $e393 e1              ; 
             pop      bc                   ; $e394 c1              ; 
             ret                           ; $e395 c9              ; 

skipe396:    ld       a,($00b5)            ; $e396 3a b5 00        ; 
             bit      $06,a                ; $e399 cb 77           ; 
             jr       z,skipe3ba           ; $e39b 28 1d           ; 
             and      a,$01                ; $e39d e6 01           ; 
             ld       ($00b5),a            ; $e39f 32 b5 00        ; 
             defb     $ed,$44,$c6,$31,$f5,$e5,$2e,$04,$cd,$8e      ; .D.1...... ; 
             defb     $eb,$e1,$f1,$01,$30,$00,$10,$fe,$0d,$20      ; ....0..... ; 
             defb     $fb,$cd,$28,$e4                              ; ..(.       ; 
skipe3ba:    ld       de,$0508             ; $e3ba 11 08 05        ; 
             ex       de,hl                ; $e3bd eb              ; 
             ld       a,d                  ; $e3be 7a              ; 
             dec      a                    ; $e3bf 3d              ; 
             ld       (hl),a               ; $e3c0 77              ; 
             dec      hl                   ; $e3c1 2b              ; 
             ld       a,e                  ; $e3c2 7b              ; 
             dec      a                    ; $e3c3 3d              ; 
             ld       (hl),a               ; $e3c4 77              ; 
             ld       a,$07                ; $e3c5 3e 07           ; 
             ld       bc,$0200             ; $e3c7 01 00 02        ; 
             call     lcd_submit           ; $e3ca cd 2f c9        ; 
             jr       skipe393             ; $e3cd 18 c4           ; 

;
; inst_erase — ERASE statement (deallocate array variables)
; ERASE arrname[, arrname...]
; For each array name:
; Set $020E = $01 (ERASE/DIM context flag).
; lookup_or_create_var → DE = variable address, BC = end of array.
; Calculate size = BC − DE − 5 bytes (header overhead).
; LDIR-style compact: move all variables above the array downward.
; Update $0326 (top-of-variables pointer) = new end.
; Loop on comma: repeat for next array name (jr inst_erase).
; 
; ERASE statement.  Deallocate named array(s).  For each array:
; compute array bounds, close the gap via block move (loope3e7),
; update $0326 (top-of-variables pointer).
; Loops on comma for multiple arrays.
;
inst_erase:  ld       a,$01                ; $e3cf 3e 01           ; 
             ld       ($020e),a            ; $e3d1 32 0e 02        ; 
             call     lookup_or_create_var ; $e3d4 cd 0a b0        ; 
             push     hl                   ; $e3d7 e5              ; 
             ld       ($020e),a            ; $e3d8 32 0e 02        ; 
             ld       h,b                  ; $e3db 60              ; 
             ld       l,c                  ; $e3dc 69              ; 
             dec      bc                   ; $e3dd 0b              ; 
             dec      bc                   ; $e3de 0b              ; 
             dec      bc                   ; $e3df 0b              ; 
             dec      bc                   ; $e3e0 0b              ; 
             dec      bc                   ; $e3e1 0b              ; 
             add      hl,de                ; $e3e2 19              ; 
             ex       de,hl                ; $e3e3 eb              ; 
             ld       hl,($0326)           ; $e3e4 2a 26 03        ; 
loope3e7:    rst      rst0020              ; $e3e7 e7              ; 
             ld       a,(de)               ; $e3e8 1a              ; 
             ld       (bc),a               ; $e3e9 02              ; 
             inc      de                   ; $e3ea 13              ; 
             inc      bc                   ; $e3eb 03              ; 
             jr       nz,loope3e7          ; $e3ec 20 f9           ; 
             dec      bc                   ; $e3ee 0b              ; 
             ld       h,b                  ; $e3ef 60              ; 
             ld       l,c                  ; $e3f0 69              ; 
             ld       ($0326),hl           ; $e3f1 22 26 03        ; 
             pop      hl                   ; $e3f4 e1              ; 
             ld       a,(hl)               ; $e3f5 7e              ; 
             cp       a,$2c                ; $e3f6 fe 2c           ; 
             ret      nz                   ; $e3f8 c0              ; 

             call     rst10_fetch_token    ; $e3f9 cd 37 f5        ; 
             jr       inst_erase           ; $e3fc 18 d1           ; 

;
; disp_col_mode_get — read display column/mode flag at $00B6
; Loads A from RAM $00B6 (display scroll/wrap mode flag set
; by CONSOLE arg 3), sets flags with AND A, and returns.
; Called by calle365 (CONSOLE display-geometry update) to
; check whether the display is in wrap or scroll mode before
; computing the new scroll boundary at $00BD.
; 
; LD A,($00B6); AND A; RET.
;
disp_col_mode_get: ld       a,($00b6)            ; $e3fe 3a b6 00        ; 
             and      a,a                  ; $e401 a7              ; 
             ret                           ; $e402 c9              ; 

;
; inst_locate_exec — RST $20 syscall slot 16 (RAM $0087)
; ----
; LOCATE statement handler.
; Parses LOCATE(col, row): validates col < $14 (20) and
; row < $04 (4), increments both to 1-based, stores them
; in D (col) and E (row), reads the current character at
; that position (via disp_read_char / call0060), sends it
; to the skip-character hook ($FC90), then returns.
; Jumps to error handler ($F590) if either argument is
; out of range.
; 
; Expression token SCREEN also reaches this same ROM body through the
; RAM vector at $0087, so it doubles as the SCREEN(col,row) function.
; 
; LOCATE(col, row): validate range, position cursor.
;
inst_locate_exec: rst      rst0010              ; $e403 d7              ; 
             rst      rst0008              ; $e404 cf              ; 
             defb     $28                                          ; (          ; 
             call     eval_expr_to_int8    ; $e406 cd 5e fe        ; 
             cp       a,$14                ; $e409 fe 14           ; 
loope40b:    jp       nc,jumpf590          ; $e40b d2 90 f5        ; 
             inc      a                    ; $e40e 3c              ; 
             ld       d,a                  ; $e40f 57              ; 
             rst      rst0008              ; $e410 cf              ; 
             defb     $2c                                          ; ,          ; 
             call     eval_int8_preserve   ; $e412 cd 5d e3        ; 
             cp       a,$04                ; $e415 fe 04           ; 
             jr       nc,loope40b          ; $e417 30 f2           ; 
             inc      a                    ; $e419 3c              ; 
             ld       e,a                  ; $e41a 5f              ; 
             rst      rst0008              ; $e41b cf              ; 
             defb     $29                                          ; )          ; 
             push     hl                   ; $e41d e5              ; 
             ex       de,hl                ; $e41e eb              ; 
             call     callebe5             ; $e41f cd e5 eb        ; 
             ld       a,(hl)               ; $e422 7e              ; 
             call     skipfc90             ; $e423 cd 90 fc        ; 
             pop      hl                   ; $e426 e1              ; 
             ret                           ; $e427 c9              ; 

;
; Submit a single-byte LCD/co-processor command.
; Forces bit 7 on in A, sends it with zero payload bytes, and returns.
;
lcd_cmd_simple: push     hl                   ; $e428 e5              ; 
             ld       c,$00                ; $e429 0e 00           ; 
             or       a,$80                ; $e42b f6 80           ; 
             call     lcd_submit           ; $e42d cd 2f c9        ; 
             pop      hl                   ; $e430 e1              ; 
             ret                           ; $e431 c9              ; 

;
; fs_setup_scan — load file-area boundary and device descriptor registers
; Reads the RAM file-area start pointer from $0210 into HL and the
; end pointer from $0212 into IY.  If B is zero on entry sets B=$44
; (default entry count / bank selector); otherwise leaves B unchanged.
; Reads the device type byte from $02F5 into C (via DE) and the device
; descriptor pointer from $02F6 into DE.  Returns with HL=start,
; IY=end, DE=descriptor, C=device type; registers ready for fs_file_scan.
; 
; HL=($0210), IY=($0212), DE=($02F6), C=($02F5); default B=$44.
;
fs_setup_scan: ld       hl,($0210)           ; $e432 2a 10 02        ; 
             ld       iy,($0212)           ; $e435 fd 2a 12 02     ; 
             dec      b                    ; $e439 05              ; 
             inc      b                    ; $e43a 04              ; 
             jr       nz,skipe43f          ; $e43b 20 02           ; 
             ld       b,$44                ; $e43d 06 44           ; 
skipe43f:    ld       de,($02f5)           ; $e43f ed 5b f5 02     ; 
             ld       c,e                  ; $e443 4b              ; 
             ld       de,($02f6)           ; $e444 ed 5b f6 02     ; 
             ret                           ; $e448 c9              ; 

             defb     $cd,$32,$e4,$a7,$28,$34,$c5,$d5,$d5,$e5      ; .2..(4.... ; 
             defb     $cd,$d9,$f2,$23,$ed,$5b,$b2,$00,$a7,$ed      ; ...#.[.... ; 
             defb     $52,$11,$0a,$00,$19,$e5,$dd,$e1,$e1,$d1      ; R......... ; 
             defb     $cd,$a6,$e4,$cd,$91,$e4,$d1,$c1,$d4,$17      ; .......... ; 
             defb     $e5,$cd,$85,$e5,$e5,$ff,$07,$19,$2b,$eb      ; ........+. ; 
             defb     $e1,$01,$0e,$00,$09,$44,$4d,$c9,$c5,$d5      ; .....DM... ; 
             defb     $cd,$a6,$e4,$dc,$91,$e4,$d1,$c1,$38,$e3      ; ........8. ; 
             defb     $18,$e4,$f5,$e5,$dd,$e5,$e1,$11,$10,$00      ; .......... ; 
             defb     $e7,$da,$8f,$e6,$37,$ed,$42,$d2,$a5,$d1      ; ....7.B... ; 
             defb     $e1,$f1,$c9                                  ; ...        ; 
;
; fs_file_scan — scan file directory for matching filename
; Iterates over file directory entries (15 bytes each) in the RAM
; file area.  Each entry: 6-byte name, 1-byte type, 2-byte size,
; remaining fields.  Compares up to 6 bytes of the entry name against
; the target filename at $0305 (loop at loope4b7 / loope4c9).
; On match: returns BC=file size + 1, HL=entry pointer, carry clear.
; On end-of-directory (null name byte): sets carry, jumps back to
; loope4dd which stores BC=$0000 (size=0) and carry.
; No match for all entries: error E=$19 (File not found) via jumpf1c7.
; RST $38+$88 (read header) and RST $38+$07 (close/advance) are used
; to step through multi-bank entries.
; 
; Scan file directory; BC=size HL=entry ptr NC on match; carry=not found.
;
fs_file_scan: ld       a,c                  ; $e4a6 79              ; 
             and      a,a                  ; $e4a7 a7              ; 
             jp       z,basic_raise_error_17 ; $e4a8 ca bf f1        ; 
             push     bc                   ; $e4ab c5              ; 
             ld       bc,$000f             ; $e4ac 01 0f 00        ; 
             add      ix,bc                ; $e4af dd 09           ; 
             pop      bc                   ; $e4b1 c1              ; 
;
; Main file-directory scan loop inside fs_file_scan.  Saves the current
; candidate state, compares the requested 6-byte filename against the
; entry at HL, fetches the entry metadata when the name matches, and
; otherwise advances to the next directory slot.  Ends either with a
; successful BC=size+1 / HL=entry result or the standard file-not-found
; error path.
;
fs_file_scan_loop: push     de                   ; $e4b2 d5              ; 
             push     bc                   ; $e4b3 c5              ; 
             push     hl                   ; $e4b4 e5              ; 
             ld       b,$06                ; $e4b5 06 06           ; 
loope4b7:    ld       a,(hl)               ; $e4b7 7e              ; 
             and      a,a                  ; $e4b8 a7              ; 
             jr       z,skipe509           ; $e4b9 28 4e           ; 
             ex       de,hl                ; $e4bb eb              ; 
             cp       a,(hl)               ; $e4bc be              ; 
             jr       nz,skipe4fa          ; $e4bd 20 3b           ; 
             ex       de,hl                ; $e4bf eb              ; 
             inc      hl                   ; $e4c0 23              ; 
             inc      de                   ; $e4c1 13              ; 
             dec      c                    ; $e4c2 0d              ; 
             jr       z,skipe4cf           ; $e4c3 28 0a           ; 
             djnz     loope4b7             ; $e4c5 10 f0           ; 
             jr       skipe4d1             ; $e4c7 18 08           ; 

loope4c9:    ld       a,(hl)               ; $e4c9 7e              ; 
             cp       a,$20                ; $e4ca fe 20           ; 
             jr       nz,skipe4fa          ; $e4cc 20 2c           ; 
             inc      hl                   ; $e4ce 23              ; 
skipe4cf:    djnz     loope4c9             ; $e4cf 10 f8           ; 
skipe4d1:    pop      hl                   ; $e4d1 e1              ; 
             rst      rst0038              ; $e4d2 ff              ; 
             ld       b,$c1                ; $e4d3 06 c1           ; 
             ld       a,b                  ; $e4d5 78              ; 
             cp       a,e                  ; $e4d6 bb              ; 
             jr       nz,skipe4fc          ; $e4d7 20 23           ; 
             pop      de                   ; $e4d9 d1              ; 
             rst      rst0038              ; $e4da ff              ; 
             rlca                          ; $e4db 07              ; 
             and      a,a                  ; $e4dc a7              ; 
loope4dd:    push     af                   ; $e4dd f5              ; 
             push     hl                   ; $e4de e5              ; 
             push     de                   ; $e4df d5              ; 
loope4e0:    ld       a,(hl)               ; $e4e0 7e              ; 
             and      a,a                  ; $e4e1 a7              ; 
             jr       z,skipe4e9           ; $e4e2 28 05           ; 
             rst      rst0038              ; $e4e4 ff              ; 
             rlca                          ; $e4e5 07              ; 
             add      hl,de                ; $e4e6 19              ; 
             jr       loope4e0             ; $e4e7 18 f7           ; 

skipe4e9:    push     iy                   ; $e4e9 fd e5           ; 
             pop      de                   ; $e4eb d1              ; 
             ex       de,hl                ; $e4ec eb              ; 
             and      a,a                  ; $e4ed a7              ; 
             sbc      hl,de                ; $e4ee ed 52           ; 
             jr       c,skipe512           ; $e4f0 38 20           ; 
             pop      de                   ; $e4f2 d1              ; 
             add      hl,de                ; $e4f3 19              ; 
             ld       b,h                  ; $e4f4 44              ; 
             ld       c,l                  ; $e4f5 4d              ; 
             inc      bc                   ; $e4f6 03              ; 
             pop      hl                   ; $e4f7 e1              ; 
             pop      af                   ; $e4f8 f1              ; 
             ret                           ; $e4f9 c9              ; 

skipe4fa:    pop      hl                   ; $e4fa e1              ; 
             pop      bc                   ; $e4fb c1              ; 
skipe4fc:    rst      rst0038              ; $e4fc ff              ; 
             rlca                          ; $e4fd 07              ; 
             add      hl,de                ; $e4fe 19              ; 
             push     iy                   ; $e4ff fd e5           ; 
             pop      de                   ; $e501 d1              ; 
             inc      de                   ; $e502 13              ; 
             rst      rst0020              ; $e503 e7              ; 
             jr       nc,skipe512          ; $e504 30 0c           ; 
             pop      de                   ; $e506 d1              ; 
             jr       fs_file_scan_loop    ; $e507 18 a9           ; 

skipe509:    pop      hl                   ; $e509 e1              ; 
             pop      bc                   ; $e50a c1              ; 
             pop      de                   ; $e50b d1              ; 
             ld       de,$0000             ; $e50c 11 00 00        ; 
             scf                           ; $e50f 37              ; 
             jr       loope4dd             ; $e510 18 cb           ; 

skipe512:    ld       e,$19                ; $e512 1e 19           ; 
             jp       basic_raise_error    ; $e514 c3 c7 f1        ; 

;
; fs_compact_dir — compact directory after file deletion
; Called after a file entry has been removed to close the gap.
; Uses RST $38+$07 (close/advance) to step through the 5 device
; slots, relocating each live entry pointer by the deleted entry's
; size.  Copies entry data with LDIR from the entry after the deleted
; one to the deleted entry's location, effectively sliding all
; subsequent entries down.  Updates the file-area-end pointer at
; $0212 to the new top.  Preserves IX, DE, BC, HL across the call.
; 
; Slide all file entries after the deleted one down; update $0212.
;
fs_compact_dir: push     ix                   ; $e517 dd e5           ; 
             push     de                   ; $e519 d5              ; 
             push     bc                   ; $e51a c5              ; 
             push     hl                   ; $e51b e5              ; 
             rst      rst0038              ; $e51c ff              ; 
             rlca                          ; $e51d 07              ; 
             add      hl,de                ; $e51e 19              ; 
             dec      hl                   ; $e51f 2b              ; 
             push     de                   ; $e520 d5              ; 
             pop      ix                   ; $e521 dd e1           ; 
             push     hl                   ; $e523 e5              ; 
             ld       b,$05                ; $e524 06 05           ; 
             ld       hl,$02c5             ; $e526 21 c5 02        ; 
;
; Inner relocation loop for fs_compact_dir.  Walks the five device/file
; descriptor slots rooted at $02c5, and for each live pointer that lies
; beyond the deleted entry, subtracts the removed record size so the
; descriptor keeps pointing at the same logical file after compaction.
;
fs_compact_relocate_device_ptrs: rst      rst0038              ; $e529 ff              ; 
             nop                           ; $e52a 00              ; 
             inc      de                   ; $e52b 13              ; 
             ld       a,(de)               ; $e52c 1a              ; 
             cp       a,$07                ; $e52d fe 07           ; 
             jr       nz,skipe55c          ; $e52f 20 2b           ; 
             rst      rst0038              ; $e531 ff              ; 
             ld       b,$e3                ; $e532 06 e3           ; 
             rst      rst0020              ; $e534 e7              ; 
             ex       (sp),hl              ; $e535 e3              ; 
             jr       z,skipe555           ; $e536 28 1d           ; 
             jr       nc,skipe55c          ; $e538 30 22           ; 
             push     bc                   ; $e53a c5              ; 
             push     hl                   ; $e53b e5              ; 
             push     ix                   ; $e53c dd e5           ; 
             pop      bc                   ; $e53e c1              ; 
             ld       a,$03                ; $e53f 3e 03           ; 
             inc      hl                   ; $e541 23              ; 
             inc      hl                   ; $e542 23              ; 
loope543:    rst      rst0038              ; $e543 ff              ; 
             nop                           ; $e544 00              ; 
             ex       de,hl                ; $e545 eb              ; 
             and      a,a                  ; $e546 a7              ; 
             sbc      hl,bc                ; $e547 ed 42           ; 
             ex       de,hl                ; $e549 eb              ; 
             ld       (hl),e               ; $e54a 73              ; 
             inc      hl                   ; $e54b 23              ; 
             ld       (hl),d               ; $e54c 72              ; 
             inc      hl                   ; $e54d 23              ; 
             dec      a                    ; $e54e 3d              ; 
             jr       nz,loope543          ; $e54f 20 f2           ; 
             pop      hl                   ; $e551 e1              ; 
             pop      bc                   ; $e552 c1              ; 
             jr       skipe55c             ; $e553 18 07           ; 

skipe555:    ld       de,io_unconfigured_driver_block ; $e555 11 02 e8        ; 
             ld       (hl),e               ; $e558 73              ; 
             inc      hl                   ; $e559 23              ; 
             ld       (hl),d               ; $e55a 72              ; 
             dec      hl                   ; $e55b 2b              ; 
skipe55c:    ld       de,rst0008           ; $e55c 11 08 00        ; 
             add      hl,de                ; $e55f 19              ; 
             djnz     fs_compact_relocate_device_ptrs ; $e560 10 c7           ; 
             pop      hl                   ; $e562 e1              ; 
             pop      hl                   ; $e563 e1              ; 
             push     hl                   ; $e564 e5              ; 
             rst      rst0038              ; $e565 ff              ; 
             rlca                          ; $e566 07              ; 
             add      hl,de                ; $e567 19              ; 
             push     hl                   ; $e568 e5              ; 
;
; Final zero-byte scan used by fs_compact_dir.  Walks forward from the
; post-delete position to find the terminating empty entry, then lets the
; tail compute the byte count for the closing LDIR that slides the file
; area down and updates the new end pointer.
;
fs_compact_find_end: ld       a,(hl)               ; $e569 7e              ; 
             and      a,a                  ; $e56a a7              ; 
             jr       z,skipe572           ; $e56b 28 05           ; 
             rst      rst0038              ; $e56d ff              ; 
             rlca                          ; $e56e 07              ; 
             add      hl,de                ; $e56f 19              ; 
             jr       fs_compact_find_end  ; $e570 18 f7           ; 

skipe572:    pop      de                   ; $e572 d1              ; 
             and      a,a                  ; $e573 a7              ; 
             sbc      hl,de                ; $e574 ed 52           ; 
             ld       b,h                  ; $e576 44              ; 
             ld       c,l                  ; $e577 4d              ; 
             pop      hl                   ; $e578 e1              ; 
             ex       de,hl                ; $e579 eb              ; 
             inc      bc                   ; $e57a 03              ; 
             ldir                          ; $e57b ed b0           ; 
             ld       h,d                  ; $e57d 62              ; 
             ld       l,e                  ; $e57e 6b              ; 
             dec      hl                   ; $e57f 2b              ; 
             pop      bc                   ; $e580 c1              ; 
             pop      de                   ; $e581 d1              ; 
             pop      ix                   ; $e582 dd e1           ; 
             ret                           ; $e584 c9              ; 

             defb     $c5,$d5,$e5,$dd,$e5,$c1,$54,$5d,$13,$0b      ; ......T].. ; 
             defb     $ed,$b0,$e1,$d1,$c1,$e5,$c5,$06,$06,$1a      ; .......... ; 
             defb     $77,$23,$13,$0d,$28,$07,$10,$f7,$18,$05      ; w#..(..... ; 
             defb     $36,$20,$23,$10,$fb,$c1,$70,$23,$dd,$e5      ; 6.#...p#.. ; 
             defb     $d1,$1b,$73,$23,$72,$e1,$c9,$2a,$45,$00      ; ..s#r..*E. ; 
             defb     $ff,$02,$cd,$d9,$e5,$da,$b6,$e8,$12,$13      ; .......... ; 
             defm     "##s#r"                                                   ;
             defb     $a7,$26,$00,$24,$c9,$2a,$45,$00,$ff,$04      ; .&.$.*E... ; 
             defb     $cd,$d9,$e5,$d8,$1a,$23,$23,$18,$e7,$d5      ; .....##... ; 
             defb     $ff,$06,$e3,$eb,$a7,$ed,$52,$e1,$c9          ; ......R..  ; 
;
; inst_dir — DIR statement (directory listing)
; DIR
; Opens output channel (calle81c); RST $38 ($83): system call to
; enumerate file entries.
; Prints headers "ROM1:", "ROM2:", "RAM:" from string table ($E671, $E677,
; $E67D) if corresponding banks are present ($000C ≠ 0, $0024 ≠ 0).
; For each file entry:
; calle633: print filename (up to 6 chars) with padding.
; callbb98: print file size (integer).
; Print `/` separator then display size.
; calle923: print CRLF after each entry.
; RST $38 ($86): close device; jumpe89e.
; 
; DIR statement.  List all files across ROM1, ROM2, and RAM
; storage banks.  Prints "ROM1:"/"ROM2:"/"RAM:" headers for
; present banks, then filename, byte count, and display size
; for each file entry.
;
inst_dir:    call     fs_dir_open          ; $e5e3 cd 1c e8        ; 
             rst      rst0038              ; $e5e6 ff              ; 
             add      a,e                  ; $e5e7 83              ; 
             push     hl                   ; $e5e8 e5              ; 
             ld       hl,($000c)           ; $e5e9 2a 0c 00        ; 
             ld       a,h                  ; $e5ec 7c              ; 
             or       a,l                  ; $e5ed b5              ; 
             ld       de,dir_label_rom1    ; $e5ee 11 71 e6        ; 
             call     nz,fs_dir_bank       ; $e5f1 c4 33 e6        ; 
             ld       hl,($0024)           ; $e5f4 2a 24 00        ; 
             ld       a,h                  ; $e5f7 7c              ; 
             or       a,l                  ; $e5f8 b5              ; 
             ld       de,dir_label_rom2    ; $e5f9 11 77 e6        ; 
             call     nz,fs_dir_bank       ; $e5fc c4 33 e6        ; 
             ld       de,($0210)           ; $e5ff ed 5b 10 02     ; 
             ld       hl,($0212)           ; $e603 2a 12 02        ; 
             or       a,a                  ; $e606 b7              ; 
             sbc      hl,de                ; $e607 ed 52           ; 
             ld       bc,$000d             ; $e609 01 0d 00        ; 
             add      hl,bc                ; $e60c 09              ; 
             push     hl                   ; $e60d e5              ; 
             ex       de,hl                ; $e60e eb              ; 
             ld       de,dir_label_ram     ; $e60f 11 7d e6        ; 
             call     fs_dir_bank          ; $e612 cd 33 e6        ; 
             call     print_emit_crlf      ; $e615 cd 29 e9        ; 
             pop      hl                   ; $e618 e1              ; 
             push     de                   ; $e619 d5              ; 
             call     print_uint16_decimal ; $e61a cd 98 bb        ; 
             ld       a,$2f                ; $e61d 3e 2f           ; 
             rst      rst0028              ; $e61f ef              ; 
             ld       hl,($0212)           ; $e620 2a 12 02        ; 
             pop      de                   ; $e623 d1              ; 
             or       a,a                  ; $e624 b7              ; 
             sbc      hl,de                ; $e625 ed 52           ; 
             call     print_uint16_decimal ; $e627 cd 98 bb        ; 
             call     io_channel_crlf      ; $e62a cd 23 e9        ; 
             pop      hl                   ; $e62d e1              ; 
;
; fs_dir_close — RST $38 $86 file-scan close and exit DIR
; Issues RST $38+$86 (ADD A,(HL) dispatch byte = list-files close)
; then jumps to io_close_channel to restore the default I/O channel.
; This is the tail of inst_dir reached after the file listing loop
; has exhausted all entries in the current bank.
; 
; RST $38+$86; jp io_close_channel.
;
fs_dir_close: rst      rst0038              ; $e62e ff              ; 
             add      a,(hl)               ; $e62f 86              ; 
             jp       io_close_channel     ; $e630 c3 9e e8        ; 

;
; fs_dir_bank — print bank label and list all files in one bank
; Called by inst_dir three times: once for ROM1 ($E671), once for
; ROM2 ($E677), and once for RAM ($E67D).  DE = pointer to the
; null-terminated bank-name string.  Prints a CRLF (calle923) then
; the label string (callfef7), then falls into the file listing loop
; loope63c to iterate and print all entries for that bank.
; 
; Print CRLF + label string (DE); fall into loope63c (file listing).
;
fs_dir_bank: push     hl                   ; $e633 e5              ; 
             ex       de,hl                ; $e634 eb              ; 
             call     io_channel_crlf      ; $e635 cd 23 e9        ; 
             call     print_c_string       ; $e638 cd f7 fe        ; 
             pop      hl                   ; $e63b e1              ; 
;
; fs_dir_loop — inner loop: iterate and print all file entries
; For each file entry at (HL): if the name byte is non-null, prints
; a CRLF; calls fs_dir_entry (calle660) to print name and type byte.
; Advances HL by one file-entry slot using RST $38+$07 (close/advance),
; then calls ctrlc_io_service to allow CTRL-C abort.  Loops back until
; all entries have been printed.  Exit via loope65c.
; 
; Iterate file entries: print name+type (calle660), advance, loop.
;
fs_dir_loop: push     hl                   ; $e63c e5              ; 
             ld       a,(hl)               ; $e63d 7e              ; 
             or       a,a                  ; $e63e b7              ; 
             call     nz,print_emit_crlf   ; $e63f c4 29 e9        ; 
             call     fs_dir_entry         ; $e642 cd 60 e6        ; 
             ld       a,$20                ; $e645 3e 20           ; 
             rst      rst0028              ; $e647 ef              ; 
             rst      rst0028              ; $e648 ef              ; 
             pop      hl                   ; $e649 e1              ; 
             rst      rst0038              ; $e64a ff              ; 
             rlca                          ; $e64b 07              ; 
             add      hl,de                ; $e64c 19              ; 
             push     hl                   ; $e64d e5              ; 
             call     fs_dir_entry         ; $e64e cd 60 e6        ; 
             pop      hl                   ; $e651 e1              ; 
             rst      rst0038              ; $e652 ff              ; 
             rlca                          ; $e653 07              ; 
             add      hl,de                ; $e654 19              ; 
             pop      bc                   ; $e655 c1              ; 
             call     ctrlc_io_service     ; $e656 cd 00 c0        ; 
             push     bc                   ; $e659 c5              ; 
             jr       fs_dir_loop          ; $e65a 18 e0           ; 

loope65c:    ex       de,hl                ; $e65c eb              ; 
             pop      hl                   ; $e65d e1              ; 
             pop      hl                   ; $e65e e1              ; 
             ret                           ; $e65f c9              ; 

;
; fs_dir_entry — print one directory entry (name + type byte)
; If the first byte at (HL) is zero, branches to loope65c (return from
; listing).  Otherwise sets B=6 and falls into fs_name_print to output
; the 6-character fixed-width name.  After the loop, prints a space
; and then the type byte (HL+6).
; 
; If null → exit; else print 6-byte name + 1-byte type.
;
fs_dir_entry: ld       a,(hl)               ; $e660 7e              ; 
             or       a,a                  ; $e661 b7              ; 
             jr       z,loope65c           ; $e662 28 f8           ; 
             ld       b,$06                ; $e664 06 06           ; 
;
; fs_name_print — fixed-width 6-byte filename output loop
; Outputs exactly 6 characters from (HL) via RST $28 (print_char),
; incrementing HL after each character.  DJNZ B counts down from 6.
; Called from fs_dir_entry to print the filename field of a directory
; entry.  Does not stop at a null byte; all 6 bytes are always printed.
; 
; Output 6 bytes from (HL) via RST $28; return.
;
fs_name_print: ld       a,(hl)               ; $e666 7e              ; 
             rst      rst0028              ; $e667 ef              ; 
             inc      hl                   ; $e668 23              ; 
             djnz     fs_name_print        ; $e669 10 fb           ; 
             ld       a,$20                ; $e66b 3e 20           ; 
             rst      rst0028              ; $e66d ef              ; 
             ld       a,(hl)               ; $e66e 7e              ; 
             rst      rst0028              ; $e66f ef              ; 
             ret                           ; $e670 c9              ; 

;
; Null-terminated heading string printed by inst_dir / fs_dir_bank when the
; ROM1 catalog pointer at RAM $000c is non-zero.
;
dir_label_rom1: defm     "ROM1:",0                                                 ;
;
; Null-terminated heading string printed by inst_dir / fs_dir_bank when the
; ROM2 catalog pointer at RAM $0024 is non-zero.
;
dir_label_rom2: defm     "ROM2:",0                                                 ;
;
; Null-terminated heading string printed by inst_dir before listing the RAM
; file area bounded by $0210/$0212.
;
dir_label_ram: defm     "RAM:",0                                                  ;
;
; inst_delete — DELETE statement (delete a file)
; DELETE "name"[-"name"]
; calle6f7: parse filename expression → file descriptor in DE/HL.
; calle71f: parse optional end-of-range filename (for range deletion).
; calle432 + calle4a6: file-system operations — locate and remove the
; file(s) in the RAM/ROM file table.
; Error $18 ("File not found") if the file does not exist (jp c,jumpf1c7).
; calle517: update directory pointers after deletion.
; 
; DELETE statement.  DELETE "file"[-"file"].
; Parses filename (calle6f7) and optional range (calle71f).
; Removes file entry from file system (calle432/calle4a6).
; Error $18 if file not found.  Updates directory (calle517).
;
inst_delete: call     fs_parse_filename    ; $e682 cd f7 e6        ; 
             call     fs_parse_second      ; $e685 cd 1f e7        ; 
             push     hl                   ; $e688 e5              ; 
             call     fs_setup_scan        ; $e689 cd 32 e4        ; 
             call     fs_file_scan         ; $e68c cd a6 e4        ; 
             ld       e,$18                ; $e68f 1e 18           ; 
             jp       c,basic_raise_error  ; $e691 da c7 f1        ; 
             call     fs_compact_dir       ; $e694 cd 17 e5        ; 
             pop      hl                   ; $e697 e1              ; 
             ret                           ; $e698 c9              ; 

;
; inst_init — INIT statement (initialise a storage device)
; INIT device, params
; calle850: parse device name expression → DE (device descriptor).
; Error F1AA if no device found (jp c,jumpf1aa).
; RST $08 / $2C: require comma separator.
; calle6cb: parse and execute device-specific init parameters:
; calle6f7 + calle706: read and validate the parameter list.
; calle6d1: set up the init operation descriptor ($E774 table).
; Fill 4 bytes from $0047 (I/O control block).
; calle6a7: execute the device initialization.
; 
; INIT statement.  Format / initialise a storage device.
; Parses device expression (calle850), comma, and init parameters
; (calle6cb).  Builds I/O control block and calls device driver.
;
inst_init:   call     fs_parse_device_name ; $e699 cd 50 e8        ; 
             jp       c,basic_raise_error_02 ; $e69c da aa f1        ; 
             push     de                   ; $e69f d5              ; 
             rst      rst0008              ; $e6a0 cf              ; 
             inc      l                    ; $e6a1 2c              ; 
             call     io_parse_filename    ; $e6a2 cd cb e6        ; 
             pop      iy                   ; $e6a5 fd e1           ; 
;
; io_init_descriptor_xora — alternate entry: A=0 before io_init_descriptor
; One-byte entry at $E6A7: XOR A (sets A=0) then falls immediately
; into io_init_descriptor at $E6A8.  Called from inst_init after
; popping IY from the stack, so the descriptor is installed with
; A=0 (no pre-set device type byte).
; 
; XOR A; fall into io_init_descriptor.
;
io_init_descriptor_xora: xor      a,a                  ; $e6a7 af              ; 
;
; io_init_descriptor — install I/O descriptor and dispatch
; Called from cas_device_setup (and other device-open paths) with
; IY=$02ED (destination buffer pointer) and DE pointing to a device
; descriptor.  Saves HL, IY, and DE; uses RST $38 low-byte command $06
; to fetch a 16-bit handler from descriptor offset +6; then continues
; with an embedded `ld hl,$e6b5 / ex de,hl / jp (hl)` sequence so the
; fetched vector becomes the actual target.  On return the I/O control
; block at $02ED has been populated for the selected device.
; 
; Save HL/IY/DE; RST $38+$06; jump through fetched init vector.
;
io_init_descriptor: push     hl                   ; $e6a8 e5              ; 
             push     iy                   ; $e6a9 fd e5           ; 
             push     de                   ; $e6ab d5              ; 
             ex       de,hl                ; $e6ac eb              ; 
             rst      rst0038              ; $e6ad ff              ; 
             ld       b,$21                ; $e6ae 06 21           ; 
             or       a,l                  ; $e6b0 b5              ; 
             and      a,$e5                ; $e6b1 e6 e5           ; 
             ex       de,hl                ; $e6b3 eb              ; 
             jp       (hl)                 ; $e6b4 e9              ; 

             defb     $dd,$e1,$d5,$c5,$e5,$dd,$e5,$21,$00,$00      ; .......!.. ; 
             defb     $39,$ff,$08,$01,$08,$00,$ed,$b0,$f9,$d1      ; 9......... ; 
             defb     $e1,$c9                                      ; ..         ; 
;
; io_parse_filename — parse filename expression and resolve device
; Entry point used by cassette open routines, INIT, DELETE, and DIR.
; Calls calle6f7 (validate/select device: if Z dispatch to
; lcd_cmd_dispatch, else call calldb4c to locate the device record
; and store type to $02F5 / descriptor to $02F6).  Calls calle706 to
; parse an optional comma-separated device index (IX = device slot).
; Then parses the filename string from the BASIC source, storing up
; to 6 bytes (null-padded) into $0305–$030A.
; 
; Resolve device (calle6f7/calle706); parse filename into
; $0305–$030A (6 bytes, null-padded).
;
io_parse_filename: call     fs_parse_filename    ; $e6cb cd f7 e6        ; 
             call     fs_parse_range       ; $e6ce cd 06 e7        ; 
;
; fs_init_setup — load device-init table pointer for INIT command
; Loads DE with $E774 (the device initialisation parameter table),
; then calls fs_device_match (calle73c) to find the matching device
; entry.  Falls through to fill 4 bytes into the I/O control block
; at $0047 using calle917, then dispatches through a JP (HL) trampoline
; at $E6EA to the device's own initialisation handler.
; Called from io_parse_filename when processing the INIT statement.
; 
; DE=$E774; call fs_device_match; fill $0047 x4; JP (HL) to handler.
;
fs_init_setup: ld       de,io_device_driver_table ; $e6d1 11 74 e7        ; 
             call     fs_device_match      ; $e6d4 cd 3c e7        ; 
             push     hl                   ; $e6d7 e5              ; 
             push     bc                   ; $e6d8 c5              ; 
             ld       b,$04                ; $e6d9 06 04           ; 
             ld       hl,$0047             ; $e6db 21 47 00        ; 
             push     af                   ; $e6de f5              ; 
             ld       a,(hl)               ; $e6df 7e              ; 
             call     calle917             ; $e6e0 cd 17 e9        ; 
             pop      af                   ; $e6e3 f1              ; 
             inc      hl                   ; $e6e4 23              ; 
             push     hl                   ; $e6e5 e5              ; 
             ld       hl,$e6eb             ; $e6e6 21 eb e6        ; 
             ex       (sp),hl              ; $e6e9 e3              ; 
             jp       (hl)                 ; $e6ea e9              ; 

             defb     $23,$23,$23,$10,$ee,$c1,$e1,$d0,$11,$ce      ; ###....... ; 
             defb     $e7,$c9                                      ; ..         ; 
;
; fs_parse_filename — validate device presence and parse filename string
; If the Z flag is set on entry (no device token found), jumps to
; lcd_cmd_dispatch ($F1AA) to raise a syntax/device error.
; Otherwise falls into fs_parse_device (calle6fa) to evaluate the
; string expression and store the device descriptor.
; 
; Z → jp lcd_cmd_dispatch; else fall into fs_parse_device.
;
fs_parse_filename: jp       z,basic_raise_error_02 ; $e6f7 ca aa f1        ; 
;
; fs_parse_device — evaluate device/filename expression and store descriptor
; Calls calldb4c to evaluate the current string expression, which
; returns the device-record pointer in DE and device type in B.
; Stores the descriptor to $02F6 (LD ($02F6),DE) and the type byte
; to $02F5 (LD ($02F5),A from B).  Returns with device descriptor
; in $02F5/$02F6.
; 
; calldb4c; LD ($02F6),DE; LD ($02F5),B; RET.
;
fs_parse_device: call     calldb4c             ; $e6fa cd 4c db        ; 
             ld       ($02f6),de           ; $e6fd ed 53 f6 02     ; 
             ld       a,b                  ; $e701 78              ; 
             ld       ($02f5),a            ; $e702 32 f5 02        ; 
             ret                           ; $e705 c9              ; 

;
; fs_parse_range — parse optional device-index comma argument
; Initialises IX=$0000 (no device slot).  If the current token is
; not ',' ($2C) falls through to calle71f.  If it is a comma but the
; next char is also ',' (double comma), falls through to calle71f.
; Otherwise calls eval_expr_to_int16 to read the slot number into DE;
; errors if DE=0 (jumpf590).  Stores DE to IX as the device index.
; Falls through to fs_parse_second.
; 
; IX=$0000; if comma+expr: IX=slot; fall into fs_parse_second.
;
fs_parse_range: ld       ix,$0000             ; $e706 dd 21 00 00     ; 
             ld       a,(hl)               ; $e70a 7e              ; 
             cp       a,$2c                ; $e70b fe 2c           ; 
             jr       nz,fs_parse_second   ; $e70d 20 10           ; 
             rst      rst0010              ; $e70f d7              ; 
             cp       a,$2c                ; $e710 fe 2c           ; 
             jr       z,fs_parse_second    ; $e712 28 0b           ; 
             call     eval_expr_to_int16   ; $e714 cd 51 fe        ; 
             ld       a,d                  ; $e717 7a              ; 
             or       a,e                  ; $e718 b3              ; 
             jp       z,jumpf590           ; $e719 ca 90 f5        ; 
             push     de                   ; $e71c d5              ; 
             pop      ix                   ; $e71d dd e1           ; 
;
; fs_parse_second — parse optional second filename for DELETE range
; Sets B=$00 (no range end).  If the current token is not ',' ($2C),
; skips to skipe736 (end parse).  Otherwise advances past comma, calls
; eval_expression then calld81e + calld2fe to convert the result to
; a range-end byte; error ($F590) if out of range.  Stores result
; into B.  Then decrements HL, polls RST $10; if non-zero (more
; tokens) jumps to lcd_cmd_dispatch (syntax error); else returns.
; 
; B=0; if comma: parse range-end into B; validate end-of-statement.
;
fs_parse_second: ld       b,$00                ; $e71f 06 00           ; 
             ld       a,(hl)               ; $e721 7e              ; 
             cp       a,$2c                ; $e722 fe 2c           ; 
             jr       nz,skipe736          ; $e724 20 10           ; 
             rst      rst0010              ; $e726 d7              ; 
             call     eval_expression      ; $e727 cd 2d f9        ; 
             push     hl                   ; $e72a e5              ; 
             call     str_eval_first_char  ; $e72b cd 1e d8        ; 
             call     calld2fe             ; $e72e cd fe d2        ; 
             jp       c,jumpf590           ; $e731 da 90 f5        ; 
             pop      hl                   ; $e734 e1              ; 
             ld       b,a                  ; $e735 47              ; 
skipe736:    dec      hl                   ; $e736 2b              ; 
             rst      rst0010              ; $e737 d7              ; 
             jp       nz,basic_raise_error_02 ; $e738 c2 aa f1        ; 
             ret                           ; $e73b c9              ; 

;
; fs_device_match — scan device table for matching device entry
; Entry: DE = pointer to device table (packed descriptor list).
; Reads device type from $02F5 into B and descriptor pointer from
; $02F6 into HL.  Inner loop (loope745) compares bytes from (DE)
; masked with $7F against (HL) one at a time; if the high bit of
; (DE) is set, the field is a wildcard/end marker.  On match, steps
; DE to the next entry's address field (+$0B offset), updates $02F5
; and $02F6 with the matched device type and descriptor, and sets
; carry.  On no match, advances DE to next record (skip to bit-7 byte
; then +$0B).  Returns with carry set if found (CCF inverts at end),
; carry clear if not found.
; 
; Match $02F5/$02F6 against table at DE; update $02F5/$02F6; NC=found.
;
fs_device_match: push     hl                   ; $e73c e5              ; 
             push     bc                   ; $e73d c5              ; 
loope73e:    ld       a,($02f5)            ; $e73e 3a f5 02        ; 
             ld       b,a                  ; $e741 47              ; 
             ld       hl,($02f6)           ; $e742 2a f6 02        ; 
loope745:    ld       a,(de)               ; $e745 1a              ; 
             and      a,$7f                ; $e746 e6 7f           ; 
             jr       z,skipe770           ; $e748 28 26           ; 
             cp       a,(hl)               ; $e74a be              ; 
             jr       nz,skipe756          ; $e74b 20 09           ; 
             ld       a,(de)               ; $e74d 1a              ; 
             and      a,$80                ; $e74e e6 80           ; 
             jr       nz,skipe765          ; $e750 20 13           ; 
             inc      hl                   ; $e752 23              ; 
             inc      de                   ; $e753 13              ; 
             djnz     loope745             ; $e754 10 ef           ; 
skipe756:    dec      de                   ; $e756 1b              ; 
loope757:    inc      de                   ; $e757 13              ; 
             ld       a,(de)               ; $e758 1a              ; 
             and      a,$80                ; $e759 e6 80           ; 
             jr       z,loope757           ; $e75b 28 fa           ; 
             ex       de,hl                ; $e75d eb              ; 
             ld       de,$000b             ; $e75e 11 0b 00        ; 
             add      hl,de                ; $e761 19              ; 
             ex       de,hl                ; $e762 eb              ; 
             jr       loope73e             ; $e763 18 d9           ; 

skipe765:    dec      b                    ; $e765 05              ; 
             ld       a,b                  ; $e766 78              ; 
             ld       ($02f5),a            ; $e767 32 f5 02        ; 
             inc      hl                   ; $e76a 23              ; 
             ld       ($02f6),hl           ; $e76b 22 f6 02        ; 
             inc      de                   ; $e76e 13              ; 
             scf                           ; $e76f 37              ; 
skipe770:    pop      bc                   ; $e770 c1              ; 
             pop      hl                   ; $e771 e1              ; 
             ccf                           ; $e772 3f              ; 
             ret                           ; $e773 c9              ; 

;
; ----
; io_device_driver_table — packed device-name/driver records
; ----
; Table scanned by fs_device_match.  Each record is:
; - device name bytes, with bit 7 set on the final character
; - 10-byte payload:
; byte 0  selector passed to calle917
; byte 1  channel/type code
; word 0  pointer to the primary driver block used by
; RST $38+$00 channel opening
; word 1-3  additional per-device helper vectors
; 
; The names in ROM are KBD:, CASI:, CASO:, COM:, GPR:, PRT:, RAM:,
; OPT:, CON:, and LPT:.  The CON: record feeds the default descriptor
; at $e80c.
;
io_device_driver_table: defb     $4b,$42,$44,$ba,$00,$01,$12,$e5,$0a,$c9      ; KBD....... ; 
             defb     $bd,$c0,$73,$e7                              ; ..s.       ; 
             defm     "CASI"                                                    ;
             defb     $ba,$00,$02,$12,$e5,$0a,$e0,$35,$de,$0f      ; .......5.. ; 
             defb     $e1                                          ; .          ; 
             defm     "CASO"                                                    ;
             defb     $ba,$00,$03,$6f,$e0,$12,$e5,$2f,$de,$2e      ; ...o.../.. ; 
             defb     $e1,$43,$4f,$4d,$ba,$00,$04,$66,$e0,$0a      ; .COM...f.. ; 
             defb     $e0,$40,$de,$73,$e7,$47,$50,$52,$ba,$00      ; .@.s.GPR.. ; 
             defb     $05,$d6,$ce,$12,$e5,$b7,$cf,$3b,$cf,$50      ; .......;.P ; 
             defb     $52,$54,$ba,$00,$06,$66,$e0,$12,$e5,$5e      ; RT...f...^ ; 
             defb     $de,$73,$e7                                  ; .s.        ; 
;
; Packed `RAM:` descriptor record inside io_device_driver_table.  Its four
; payload words point at the hidden RAM-file helpers around $e5b4, $e5cb,
; $e449, and the no-op init return at $e773.
;
io_device_record_ram: defb     $52,$41,$4d,$ba,$00,$07,$b4,$e5,$cb,$e5      ; RAM....... ; 
             defb     $49,$e4,$73,$e7                              ; I.s.       ; 
;
; Packed `OPT:` descriptor record inside io_device_driver_table.  This is
; the option-bank / external-ROM device descriptor used when OPEN/INIT style
; device resolution selects the OPT: backend.
;
io_device_record_opt: defb     $4f,$50,$54,$ba,$00,$0a,$82,$e0,$0a,$e0      ; OPT....... ; 
             defb     $4f,$de,$42,$e1                              ; O.B.       ; 
;
; Packed `CON:` descriptor record inside io_device_driver_table.  Its
; vectors feed the default console descriptor at $e80c and therefore the
; fallback channel used by DIR and other text I/O paths.
;
io_device_record_con: defb     $43,$4f,$4e,$ba,$00,$00,$9f,$00,$a2,$00      ; CON....... ; 
             defb     $73,$e7,$a5,$00                              ; s...       ; 
;
; Packed `LPT:` descriptor record inside io_device_driver_table.  The
; printer-oriented external-device discovery code matches against this entry
; when a logical line-printer channel is requested.
;
io_device_record_lpt: defb     $4c,$50,$54,$ba,$00,$0b,$f7,$ce,$12,$e5      ; LPT....... ; 
             defb     $b0,$cf,$73,$e7                              ; ..s.       ; 
;
; ----
; io_unconfigured_driver_block — default stub channel vectors
; ----
; Driver block installed into the RAM device-descriptor slots at $02c5
; during reset.  Selector byte = 0, channel flag = $0c, and all four
; vectors point to io_unsupported_operation ($e812), so unopened #n
; channels fail cleanly until INIT/OPEN replaces the slot.
;
io_unconfigured_driver_block: defb     $00,$0c,$12,$e8,$12,$e8,$12,$e8,$12,$e8      ; .......... ; 
;
; ----
; io_default_channel_descriptor — default descriptor used by io_close_channel
; ----
; Descriptor used when no explicit #device is selected and whenever the
; ROM restores the standard console channel.  Its offset +0 word points
; at the CON: driver block, so RST $38+$00 reselects the console path.
; Other low-byte lookups from this descriptor feed the nearby default
; or stub vectors used by the generic I/O helpers.
;
io_default_channel_descriptor: defb     $ea,$e7,$b2,$e7,$02,$e8                      ; ......     ; 
;
; ----
; io_unsupported_operation — common illegal-device-operation stub
; ----
; Shared vector target used by unconfigured/default driver blocks.
; Loads BASIC error code $1a into E and jumps to the generic error
; dispatcher at $f1c7.
;
io_unsupported_operation: defb     $1e,$1a,$c3,$c7,$f1                          ; .....      ; 
;
; fs_open_device — parse device expression and open I/O channel
; Calls fs_parse_device_name (calle850) to evaluate the #n argument
; and return DE = device descriptor.  Then jumps (jr) unconditionally
; into io_open_channel ($E827) to install the device driver.
; Used when a device argument is required (no optional logic).
; 
; call fs_parse_device_name; jr io_open_channel.
;
fs_open_device: call     fs_parse_device_name ; $e817 cd 50 e8        ; 
             jr       io_open_channel      ; $e81a 18 0b           ; 

;
; fs_dir_open — open I/O channel for DIR (optional device argument)
; Calls fs_parse_device_name (calle850) to attempt to parse a '#n'
; device token.  If carry is set (no '#' token = RAM default), jumps
; directly to io_open_channel.  Otherwise decrements HL, polls RST
; $10 (I/O ready); if Z (end of statement / no more tokens) jumps to
; io_open_channel.  Otherwise expects a comma separator (RST $08 +
; ',' byte) and then falls into io_open_channel.
; Called from inst_dir to set up the output channel before listing.
; 
; Parse optional #device; open channel via io_open_channel.
;
fs_dir_open: call     fs_parse_device_name ; $e81c cd 50 e8        ; 
             jr       c,io_open_channel    ; $e81f 38 06           ; 
             dec      hl                   ; $e821 2b              ; 
             rst      rst0010              ; $e822 d7              ; 
             jr       z,io_open_channel    ; $e823 28 02           ; 
             rst      rst0008              ; $e825 cf              ; 
             defb     $2c                                          ; ,          ; 
;
; io_open_channel — install device driver into output-hook JP vectors
; Saves HL and BC.  Stores DE (device descriptor pointer) to $0045.
; Issues RST $38+$00, which treats HL as a descriptor base and fetches
; the 16-bit pointer stored at offset +0.  The resulting driver block
; supplies a selector byte for calle917, the current-channel flag for
; $003B, and four 16-bit vectors which are copied into the low-RAM JP
; hooks at $003F and following.  Called from cas_device_setup,
; cas_file_found, and io_close_channel.
; 
; Store descriptor → $0045; patch JP vectors at $003F; RET.
;
io_open_channel: push     hl                   ; $e827 e5              ; 
             push     bc                   ; $e828 c5              ; 
             ld       ($0045),de           ; $e829 ed 53 45 00     ; 
             ex       de,hl                ; $e82d eb              ; 
             rst      rst0038              ; $e82e ff              ; 
             nop                           ; $e82f 00              ; 
             ld       a,(de)               ; $e830 1a              ; 
             call     calle917             ; $e831 cd 17 e9        ; 
             inc      de                   ; $e834 13              ; 
             ld       a,(de)               ; $e835 1a              ; 
             ld       ($003b),a            ; $e836 32 3b 00        ; 
             inc      de                   ; $e839 13              ; 
             ld       hl,call003f          ; $e83a 21 3f 00        ; 
             ld       a,$c3                ; $e83d 3e c3           ; 
             ex       de,hl                ; $e83f eb              ; 
             ld       (de),a               ; $e840 12              ; 
             inc      de                   ; $e841 13              ; 
             ldi                           ; $e842 ed a0           ; 
             ldi                           ; $e844 ed a0           ; 
             ld       (de),a               ; $e846 12              ; 
             inc      de                   ; $e847 13              ; 
             ldi                           ; $e848 ed a0           ; 
             ldi                           ; $e84a ed a0           ; 
             pop      bc                   ; $e84c c1              ; 
             pop      hl                   ; $e84d e1              ; 
             xor      a,a                  ; $e84e af              ; 
             ret                           ; $e84f c9              ; 

;
; fs_parse_device_name — parse #n device number expression
; If the current token is not '#' ($23), returns with carry set and
; DE=$E80C (default RAM device descriptor) — device not specified.
; Otherwise advances past '#', calls eval_expr_to_int8 to read the
; device number (1–5); errors if out of range ($F590).  Converts
; to zero-based, multiplies by 8 (three SLA A), computes offset into
; the device table at $02C5, and returns with DE = device descriptor
; pointer and carry clear.
; Used by fs_dir_open, fs_open_device, and inst_init to resolve the
; optional '#n' device argument.
; 
; '#' + n (1–5) → DE = device descriptor ptr, NC; else DE=$E80C, C.
;
fs_parse_device_name: cp       a,$23                ; $e850 fe 23           ; 
             jr       nz,fs_parse_device_name_default ; $e852 20 1f           ; 
             rst      rst0010              ; $e854 d7              ; 
             call     eval_expr_to_int8    ; $e855 cd 5e fe        ; 
             cp       a,$06                ; $e858 fe 06           ; 
             jp       nc,jumpf590          ; $e85a d2 90 f5        ; 
             dec      a                    ; $e85d 3d              ; 
             jp       m,jumpf590           ; $e85e fa 90 f5        ; 
             sla      a                    ; $e861 cb 27           ; 
             sla      a                    ; $e863 cb 27           ; 
             sla      a                    ; $e865 cb 27           ; 
             ld       b,$00                ; $e867 06 00           ; 
             ld       c,a                  ; $e869 4f              ; 
             push     hl                   ; $e86a e5              ; 
             ld       hl,$02c5             ; $e86b 21 c5 02        ; 
             add      hl,bc                ; $e86e 09              ; 
             ex       de,hl                ; $e86f eb              ; 
             pop      hl                   ; $e870 e1              ; 
             and      a,a                  ; $e871 a7              ; 
             ret                           ; $e872 c9              ; 

;
; No-`#device` exit from fs_parse_device_name.  Returns DE =
; io_default_channel_descriptor and carry set so callers can keep using the
; console/default channel instead of one of the RAM descriptor slots at $02c5.
;
fs_parse_device_name_default: ld       de,io_default_channel_descriptor ; $e873 11 0c e8        ; 
             scf                           ; $e876 37              ; 
             ret                           ; $e877 c9              ; 

;
; Startup helper that seeds the five RAM channel-descriptor slots at
; $02c5-$02ec with io_unconfigured_driver_block.  Called during cold-start
; and other reset/recovery paths before any INIT/OPEN installs real handlers.
;
io_reset_channel_slots: push     hl                   ; $e878 e5              ; 
             push     de                   ; $e879 d5              ; 
             push     bc                   ; $e87a c5              ; 
             ld       de,$0007             ; $e87b 11 07 00        ; 
             ld       bc,io_unconfigured_driver_block ; $e87e 01 02 e8        ; 
             ld       a,b                  ; $e881 78              ; 
             ld       b,$05                ; $e882 06 05           ; 
             ld       hl,$02c5             ; $e884 21 c5 02        ; 
loope887:    ld       (hl),c               ; $e887 71              ; 
             inc      hl                   ; $e888 23              ; 
             ld       (hl),a               ; $e889 77              ; 
             add      hl,de                ; $e88a 19              ; 
             djnz     loope887             ; $e88b 10 fa           ; 
             jr       skipe897             ; $e88d 18 08           ; 

;
; RST $28 handler — output character in A, preserving all registers.
; Saves HL, DE, BC and AF, then calls the character-output hook at
; RAM $003F (which jumps through $009F to the installed output driver,
; default $C1BE).  All registers are restored after the call.
;
rst28_print_char: push     hl                   ; $e88f e5              ; 
             push     de                   ; $e890 d5              ; 
             push     bc                   ; $e891 c5              ; 
             push     af                   ; $e892 f5              ; 
             call     call003f             ; $e893 cd 3f 00        ; 
             pop      af                   ; $e896 f1              ; 
skipe897:    pop      bc                   ; $e897 c1              ; 
             pop      de                   ; $e898 d1              ; 
             pop      hl                   ; $e899 e1              ; 
             ret                           ; $e89a c9              ; 

calle89b:    call     cassette_clear_f4_transfer_bits ; $e89b cd cc e0        ; 
;
; io_close_channel — restore default I/O channel
; Loads DE with the default device descriptor address ($E80C) and
; calls io_open_channel (calle827) to reinstall the default handler
; into the output-hook JP vectors at $003F.  Used to close the
; cassette (or any device) after a CSAVE/CLOAD/SAVE/LOAD operation
; completes or aborts.  Also called from cas_close and several error
; paths.
; 
; LD DE,$E80C; call io_open_channel; RET.
;
io_close_channel: push     de                   ; $e89e d5              ; 
             ld       de,io_default_channel_descriptor ; $e89f 11 0c e8        ; 
             call     io_open_channel      ; $e8a2 cd 27 e8        ; 
             pop      de                   ; $e8a5 d1              ; 
             ret                           ; $e8a6 c9              ; 

;
; device_read_line — read one line from the current I/O device
; Reads characters one at a time into the buffer at $00D5
; (capacity $FF bytes) via calle8d4 (single-char device read,
; blocking on the I/O-ready flag at $002B via call0042).
; TAB ($09) bytes are stored as `,` ($2C, CSV normalisation).
; Accumulation stops on CR ($0D) or when the buffer is full
; (DJNZ counter exhausts).  The buffer is NUL-terminated.
; The transfer is bracketed by RST $38 high-bit commands $85 and $87,
; i.e. current-channel vector calls dispatched through the central
; RST $38 handler at $e906.
; Called by inst_line_input and inst_input when $003B (channel
; flag) is non-zero (i.e., input comes from a device, not the
; keyboard).
; Returns: buffer at $00D5 filled and NUL-terminated; carry
; set if the device signalled an error.
;
device_read_line: ld       hl,$00d5             ; $e8a7 21 d5 00        ; 
             push     hl                   ; $e8aa e5              ; 
             ld       b,$ff                ; $e8ab 06 ff           ; 
             rst      rst0038              ; $e8ad ff              ; 
             add      a,l                  ; $e8ae 85              ; 
loope8af:    call     calle8d4             ; $e8af cd d4 e8        ; 
             jr       c,skipe8cb           ; $e8b2 38 17           ; 
             jr       nz,skipe8bb          ; $e8b4 20 05           ; 
jumpe8b6:    ld       e,$16                ; $e8b6 1e 16           ; 
             jp       basic_raise_error    ; $e8b8 c3 c7 f1        ; 

skipe8bb:    ld       (hl),a               ; $e8bb 77              ; 
             cp       a,$09                ; $e8bc fe 09           ; 
             jr       nz,skipe8c2          ; $e8be 20 02           ; 
             ld       (hl),$2c             ; $e8c0 36 2c           ; 
skipe8c2:    inc      hl                   ; $e8c2 23              ; 
             cp       a,$0d                ; $e8c3 fe 0d           ; 
             jr       z,skipe8c9           ; $e8c5 28 02           ; 
             djnz     loope8af             ; $e8c7 10 e6           ; 
skipe8c9:    dec      hl                   ; $e8c9 2b              ; 
             and      a,a                  ; $e8ca a7              ; 
skipe8cb:    ld       (hl),$00             ; $e8cb 36 00           ; 
             push     af                   ; $e8cd f5              ; 
             rst      rst0038              ; $e8ce ff              ; 
             add      a,a                  ; $e8cf 87              ; 
             pop      af                   ; $e8d0 f1              ; 
             pop      hl                   ; $e8d1 e1              ; 
             dec      hl                   ; $e8d2 2b              ; 
             ret                           ; $e8d3 c9              ; 

calle8d4:    push     hl                   ; $e8d4 e5              ; 
             push     de                   ; $e8d5 d5              ; 
             push     bc                   ; $e8d6 c5              ; 
loope8d7:    call     calle8e8             ; $e8d7 cd e8 e8        ; 
             scf                           ; $e8da 37              ; 
             jr       nz,skipe8e6          ; $e8db 20 09           ; 
             call     call0042             ; $e8dd cd 42 00        ; 
             jr       c,skipe8e5           ; $e8e0 38 03           ; 
             jr       z,loope8d7           ; $e8e2 28 f3           ; 
             defb     $06                  ; $e8e4 06 af           ;   As: ld     b,$af      ; 06 af      ; Next: $e8e6
skipe8e5:    xor      a,a                  ; $e8e5 af              ; 
skipe8e6:    jr       skipe897             ; $e8e6 18 af           ; 

calle8e8:    ld       a,($002b)            ; $e8e8 3a 2b 00        ; 
             and      a,$83                ; $e8eb e6 83           ; 
             ret                           ; $e8ed c9              ; 

;
; ----
; rst38_call_channel_vector1 — invoke current-channel vector +1
; ----
; Small helper for the bit-7-set RST $38 path.  Executes the inline
; command byte $81, so control is routed through the current channel
; descriptor at $0045 and then through offset +1 in that channel's
; active driver block.
; 
; BC is left available as a parameter register for the handler.
; After the handler returns, A is reloaded from C and the flags are
; normalised from that value.  Used by PRINT/LPRINT spacing logic and
; by the CRLF helper at $e923.
;
rst38_call_channel_vector1: rst      rst0038              ; $e8ee ff              ; 
             add      a,c                  ; $e8ef 81              ; 
             ld       a,c                  ; $e8f0 79              ; 
             and      a,a                  ; $e8f1 a7              ; 
             ret                           ; $e8f2 c9              ; 

;
; ----
; rst38_current_channel_dispatch — bit-7-set RST $38 handler
; ----
; Shared path for RST $38 inline bytes with bit 7 set.  The inline
; byte is masked with $7f, then the dispatcher fetches the current
; device descriptor from $0045, performs a low-byte lookup at offset
; +0 to obtain the active driver block, performs a second low-byte
; lookup inside that block, and tail-calls through the resulting
; vector.
; 
; In effect, commands $80-$ff mean "dispatch through the current I/O
; channel/device vectors", while preserving the caller's return so the
; selected handler returns to the instruction after the inline byte.
;
rst38_current_channel_dispatch: ld       a,(hl)               ; $e8f3 7e              ; 
             and      a,$7f                ; $e8f4 e6 7f           ; 
             inc      hl                   ; $e8f6 23              ; 
             ex       (sp),hl              ; $e8f7 e3              ; 
             push     hl                   ; $e8f8 e5              ; 
             push     de                   ; $e8f9 d5              ; 
             ld       hl,($0045)           ; $e8fa 2a 45 00        ; 
             rst      rst0038              ; $e8fd ff              ; 
             nop                           ; $e8fe 00              ; 
             ex       de,hl                ; $e8ff eb              ; 
             rst      rst0038              ; $e900 ff              ; 
             ex       af,af'               ; $e901 08              ; 
             ex       de,hl                ; $e902 eb              ; 
             pop      de                   ; $e903 d1              ; 
             ex       (sp),hl              ; $e904 e3              ; 
             ret                           ; $e905 c9              ; 

;
; ----
; rst38_device_dispatch — central RST $38 immediate-byte dispatcher
; ----
; This is the ROM target reached through the RAM vector at $0038.
; The return address left by the RST points at the byte immediately
; following the RST instruction, and that byte acts as the command
; selector.
; 
; Bit 7 clear:
; Treat HL as a base pointer, load E from the inline byte, and
; return DE = word[(HL)+E].  Execution resumes after the inline
; byte.  This is a compact "fetch 16-bit pointer at base+offset"
; primitive used by descriptor walkers and table-driven helpers.
; 
; Bit 7 set:
; Branch to rst38_current_channel_dispatch ($e8f3), which resolves
; the request through the current channel/device descriptor at $0045.
; 
; Representative uses:
; $e82e  RST $38+$00  -> fetch driver block from descriptor
; $e6ad  RST $38+$06  -> fetch init/open vector from descriptor
; $e64a  RST $38+$07  -> fetch next-entry pointer from a DIR record
; $df46  RST $38+$89  -> channel-dispatched cassette/file hook
; $ea01  RST $38+$8c  -> channel-dispatched LPRINT/PRINT setup hook
;
rst38_device_dispatch: ex       (sp),hl              ; $e906 e3              ; 
             bit      $07,(hl)             ; $e907 cb 7e           ; 
             jr       nz,rst38_current_channel_dispatch ; $e909 20 e8           ; 
             ld       e,(hl)               ; $e90b 5e              ; 
             inc      hl                   ; $e90c 23              ; 
             ex       (sp),hl              ; $e90d e3              ; 
             push     hl                   ; $e90e e5              ; 
             ld       d,$00                ; $e90f 16 00           ; 
             add      hl,de                ; $e911 19              ; 
             ld       e,(hl)               ; $e912 5e              ; 
             inc      hl                   ; $e913 23              ; 
             ld       d,(hl)               ; $e914 56              ; 
             pop      hl                   ; $e915 e1              ; 
             ret                           ; $e916 c9              ; 

calle917:    and      a,a                  ; $e917 a7              ; 
             ret      z                    ; $e918 c8              ; 

             dec      a                    ; $e919 3d              ; 
             out      ($df),a              ; $e91a d3 df           ; 
             ret                           ; $e91c c9              ; 

;
; ----
; io_close_reset_and_crlf — restore default channel, reset state, CRLF
; ----
; Common post-I/O cleanup used by STOP/READY and other paths that must
; leave the machine back on the default console channel.  Calls
; io_close_channel to reinstall the default descriptor, calls the RAM
; syscall at $0057, then falls through to the newline helper at $e923.
;
io_close_reset_and_crlf: call     io_close_channel     ; $e91d cd 9e e8        ; 
calle920:    call     call0057             ; $e920 cd 57 00        ; 
;
; ----
; io_channel_crlf — issue channel hook then print CR/LF
; ----
; Loads C=$ff and calls rst38_call_channel_vector1 ($e8ee), then emits
; carriage return and line feed through RST $28.  Used by DIR bank
; headers, READY/break handling, and other places that need a channel-
; aware end-of-line sequence.
;
io_channel_crlf: ld       c,$ff                ; $e923 0e ff           ; 
             call     rst38_call_channel_vector1 ; $e925 cd ee e8        ; 
             ret      z                    ; $e928 c8              ; 

;
; Emit CR ($0D) then LF ($0A) through RST $28 and return with A=0.
; Shared newline helper used by PRINT / PRINT USING once the caller
; has decided that the statement should terminate with a fresh line.
;
print_emit_crlf: ld       a,$0d                ; $e929 3e 0d           ; 
             rst      rst0028              ; $e92b ef              ; 
             ld       a,$0a                ; $e92c 3e 0a           ; 
             rst      rst0028              ; $e92e ef              ; 
             xor      a,a                  ; $e92f af              ; 
             ret                           ; $e930 c9              ; 

;
; fn_inp — INP function
; INP(#device) or INP(port) — read one byte either from the current
; device-driver path or directly from a hardware port.
; `#` form: temporarily opens the requested channel, reads one byte via
; callc03c, restores the previous channel, then returns the byte as an
; integer.  Raw form: evaluates a 16-bit port address and executes
; `IN A,(C)` directly.
;
fn_inp:      rst      rst0010              ; $e931 d7              ; 
             rst      rst0008              ; $e932 cf              ; 
             defb     $28                                          ; (          ; 
             cp       a,$23                ; $e934 fe 23           ; 
             jr       nz,skipe952          ; $e936 20 1a           ; 
             ld       de,($0045)           ; $e938 ed 5b 45 00     ; 
             push     de                   ; $e93c d5              ; 
             call     fs_open_device       ; $e93d cd 17 e8        ; 
             rst      rst0008              ; $e940 cf              ; 
             defb     $29                                          ; )          ; 
             ex       (sp),hl              ; $e942 e3              ; 
             push     hl                   ; $e943 e5              ; 
             call     callc03c             ; $e944 cd 3c c0        ; 
             jp       z,jumpe8b6           ; $e947 ca b6 e8        ; 
loope94a:    pop      de                   ; $e94a d1              ; 
             push     af                   ; $e94b f5              ; 
             call     io_open_channel      ; $e94c cd 27 e8        ; 
             pop      af                   ; $e94f f1              ; 
             jr       skipe95c             ; $e950 18 0a           ; 

skipe952:    call     eval_expr_to_addr    ; $e952 cd cc ff        ; 
             rst      rst0008              ; $e955 cf              ; 
             defb     $29                                          ; )          ; 
             push     hl                   ; $e957 e5              ; 
             ld       b,d                  ; $e958 42              ; 
             ld       c,e                  ; $e959 4b              ; 
             in       a,(c)                ; $e95a ed 78           ; 
skipe95c:    call     skipfc90             ; $e95c cd 90 fc        ; 
             pop      hl                   ; $e95f e1              ; 
             ret                           ; $e960 c9              ; 

;
; fn_sns — SNS function
; SNS(#device[,fallback]) — query a device status / sense byte.
; Requires a `#` channel selector, temporarily opens that device, then
; calls the RAM $0042 input/sense hook.  If no live status byte is
; reported, the optional fallback byte in E is returned instead.
;
fn_sns:      rst      rst0010              ; $e961 d7              ; 
             rst      rst0008              ; $e962 cf              ; 
             defb     $28                                          ; (          ; 
             cp       a,$23                ; $e964 fe 23           ; 
             jp       nz,basic_raise_error_02 ; $e966 c2 aa f1        ; 
             ld       de,($0045)           ; $e969 ed 5b 45 00     ; 
             push     de                   ; $e96d d5              ; 
             call     fs_open_device       ; $e96e cd 17 e8        ; 
             ld       e,$00                ; $e971 1e 00           ; 
             ld       a,(hl)               ; $e973 7e              ; 
             cp       a,$2c                ; $e974 fe 2c           ; 
             jr       nz,skipe97b          ; $e976 20 03           ; 
             call     callfe5d             ; $e978 cd 5d fe        ; 
skipe97b:    rst      rst0008              ; $e97b cf              ; 
             defb     $29                                          ; )          ; 
             ex       (sp),hl              ; $e97d e3              ; 
             push     hl                   ; $e97e e5              ; 
             push     de                   ; $e97f d5              ; 
             call     call0042             ; $e980 cd 42 00        ; 
             jp       c,jumpe8b6           ; $e983 da b6 e8        ; 
             pop      de                   ; $e986 d1              ; 
             jr       nz,loope94a          ; $e987 20 c1           ; 
             ld       a,e                  ; $e989 7b              ; 
             jr       loope94a             ; $e98a 18 be           ; 

;
; inst_out — OUT statement
; OUT port, val
; Two forms:
; OUT #n, expr — redirect output to channel n (cp $23 = `#`):
; calle81c opens channel, callfe5e reads channel number → E,
; RST $28 prints it, then close via calle89e.
; OUT port, val — direct hardware I/O:
; eval_expr_to_addr → DE (port number as 16-bit); RST $08/$2C for `,`;
; callfe5e → A (8-bit value); OUT (C),A.
; 
; OUT statement.
; OUT #n,expr: redirect output to channel n.
; OUT port,val: execute Z80 OUT (C),A instruction.
;
inst_out:    cp       a,$23                ; $e98c fe 23           ; 
             jr       nz,skipe99a          ; $e98e 20 0a           ; 
             call     fs_dir_open          ; $e990 cd 1c e8        ; 
             call     eval_expr_to_int8    ; $e993 cd 5e fe        ; 
             rst      rst0028              ; $e996 ef              ; 
             jp       io_close_channel     ; $e997 c3 9e e8        ; 

skipe99a:    call     eval_expr_to_addr    ; $e99a cd cc ff        ; 
             push     de                   ; $e99d d5              ; 
             rst      rst0008              ; $e99e cf              ; 
             defb     $2c                                          ; ,          ; 
             call     eval_expr_to_int8    ; $e9a0 cd 5e fe        ; 
             pop      bc                   ; $e9a3 c1              ; 
             out      (c),a                ; $e9a4 ed 79           ; 
             ret                           ; $e9a6 c9              ; 

;
; fn_varptr — VARPTR function
; VARPTR(var) — return the address of a BASIC variable or array
; descriptor.
; Reuses lookup_or_create_var, rejects the null case, then returns the
; resulting storage pointer through the shared integer packaging path.
;
fn_varptr:   rst      rst0010              ; $e9a7 d7              ; 
             rst      rst0008              ; $e9a8 cf              ; 
             defb     $28                                          ; (          ; 
             call     lookup_or_create_var ; $e9aa cd 0a b0        ; 
             rst      rst0008              ; $e9ad cf              ; 
             defb     $29                                          ; )          ; 
             push     hl                   ; $e9af e5              ; 
             ex       de,hl                ; $e9b0 eb              ; 
             ld       a,h                  ; $e9b1 7c              ; 
             or       a,l                  ; $e9b2 b5              ; 
             jp       z,jumpf590           ; $e9b3 ca 90 f5        ; 
             call     num_store_int_result ; $e9b6 cd ef ca        ; 
             pop      hl                   ; $e9b9 e1              ; 
             ret                           ; $e9ba c9              ; 

;
; fn_usr — USR function
; USR(addr, expr) — call a user-supplied machine-code routine.
; Evaluates the target address, then the argument expression.  String
; arguments are normalised through the string-descriptor path, after
; which the routine leaves DE = target and HL = $044e so the common
; USR trampoline can invoke the external code with the current BASIC
; argument workspace prepared.
;
fn_usr:      rst      rst0010              ; $e9bb d7              ; 
             rst      rst0008              ; $e9bc cf              ; 
             defb     $28                                          ; (          ; 
             call     eval_expr_to_addr    ; $e9be cd cc ff        ; 
             push     de                   ; $e9c1 d5              ; 
             rst      rst0008              ; $e9c2 cf              ; 
             defb     $2c                                          ; ,          ; 
             call     eval_expression      ; $e9c4 cd 2d f9        ; 
             rst      rst0008              ; $e9c7 cf              ; 
             defb     $29                                          ; )          ; 
             ex       (sp),hl              ; $e9c9 e3              ; 
             ld       de,$e9b9             ; $e9ca 11 b9 e9        ; 
             push     de                   ; $e9cd d5              ; 
             push     hl                   ; $e9ce e5              ; 
             ld       a,($01d9)            ; $e9cf 3a d9 01        ; 
             push     af                   ; $e9d2 f5              ; 
             cp       a,$03                ; $e9d3 fe 03           ; 
             call     z,str_load_result_descriptor ; $e9d5 cc 04 d7        ; 
             pop      af                   ; $e9d8 f1              ; 
             ex       de,hl                ; $e9d9 eb              ; 
             ld       hl,$044e             ; $e9da 21 4e 04        ; 
             ret                           ; $e9dd c9              ; 

;
; inst_lprint — LPRINT statement
; LPRINT [#dev,] [item[; | ,] ...]
; LPRINT redirects output to the printer (device $E80E).
; With `[` token: reads optional device and column-width parameters.
; It then issues RST $38+$8c, i.e. a current-channel hook dispatched
; through the central RST $38 handler, before falling into the shared
; PRINT main loop (skipea08).
; 
; LPRINT statement.  Sets output device to printer ($E80E via
; calle827).  Optionally parses `[dev, width]` device specifier,
; calls the current-channel $8c hook, then falls into the PRINT item
; loop (skipea08).
;
inst_lprint: ld       de,$e80e             ; $e9de 11 0e e8        ; 
             call     io_open_channel      ; $e9e1 cd 27 e8        ; 
             ld       a,(hl)               ; $e9e4 7e              ; 
             cp       a,$5b                ; $e9e5 fe 5b           ; 
             jr       nz,skipea08          ; $e9e7 20 1f           ; 
             ld       e,$ff                ; $e9e9 1e ff           ; 
             rst      rst0010              ; $e9eb d7              ; 
             cp       a,$2c                ; $e9ec fe 2c           ; 
             call     nz,eval_expr_to_int8 ; $e9ee c4 5e fe        ; 
             push     de                   ; $e9f1 d5              ; 
             ld       e,$ff                ; $e9f2 1e ff           ; 
             ld       a,(hl)               ; $e9f4 7e              ; 
             cp       a,$2c                ; $e9f5 fe 2c           ; 
             jr       nz,skipe9fc          ; $e9f7 20 03           ; 
             call     callfe5d             ; $e9f9 cd 5d fe        ; 
skipe9fc:    ld       c,e                  ; $e9fc 4b              ; 
             pop      de                   ; $e9fd d1              ; 
             ld       b,e                  ; $e9fe 43              ; 
             rst      rst0008              ; $e9ff cf              ; 
             ld       e,l                  ; $ea00 5d              ; 
             rst      rst0038              ; $ea01 ff              ; 
             adc      a,h                  ; $ea02 8c              ; 
             jr       skipea08             ; $ea03 18 03           ; 

;
; ---------------------------------------------------------------------------
; inst_print — PRINT statement
; ---------------------------------------------------------------------------
; PRINT [expr] [; | ,] [expr] ...
; Entry: calls calle81c to output a hook byte (RST $38 + $83 inline literal —
; calls the output-channel open/prepare hook).
; Main loop (loopea0a):
; • RST $10: fetch next token; if Z (end of line) → done.
; • Token $BD (USING): jump to jumpcfdb (PRINT USING handler).
; • Token $BA (TAB(): jump to TAB handler (skipea81).
; • Token $2C `,`: advance to next tab zone (skipea4d).
; • Token $3B `;`: suppress CRLF / stay on same column (skipea77).
; • Otherwise: pop and evaluate expression (eval_expression).
; Call RST $30 (device-mode test):
; if Z: direct-mode numeric print path (callbbab + calld56e + column tracking).
; else: calld5b4 (convert and output string).
; • After printing: loop back.
; If loop exits normally (Z from RST $10): fall through to end-of-print
; which outputs CRLF (via jumpe62e) unless last separator was `;`.
; 
; PRINT statement.  Opens output channel (calle81c / RST $38 hook).
; Main loop: fetch tokens, dispatch on separator (`,` → tab, `;` →
; no-CRLF), on USING, on TAB(, or evaluate an expression and output it.
; At end of item list, output CRLF unless last separator was `;`.
;
inst_print:  call     fs_dir_open          ; $ea05 cd 1c e8        ; 
skipea08:    rst      rst0038              ; $ea08 ff              ; 
             add      a,e                  ; $ea09 83              ; 
;
; Top of PRINT item loop.  Fetch next token (RST $10).
; Z → end of statement → CRLF and return.
;
print_next_item: dec      hl                   ; $ea0a 2b              ; 
             rst      rst0010              ; $ea0b d7              ; 
             call     z,print_emit_crlf    ; $ea0c cc 29 e9        ; 
;
; Dispatch point inside the PRINT item loop after token fetch.
; Handles USING, TAB(, comma-zone, semicolon, or expression output,
; then loops back for the next item.
;
print_item_dispatch: jp       z,fs_dir_close       ; $ea0f ca 2e e6        ; 
             cp       a,$bd                ; $ea12 fe bd           ; 
             jp       z,print_using_dispatch ; $ea14 ca db cf        ; 
             cp       a,$ba                ; $ea17 fe ba           ; 
             jr       z,print_tab_fn       ; $ea19 28 66           ; 
             push     hl                   ; $ea1b e5              ; 
             cp       a,$2c                ; $ea1c fe 2c           ; 
             jr       z,print_tab_comma    ; $ea1e 28 2d           ; 
             cp       a,$3b                ; $ea20 fe 3b           ; 
             jr       z,print_separator_dispatch ; $ea22 28 53           ; 
             pop      bc                   ; $ea24 c1              ; 
             call     eval_expression      ; $ea25 cd 2d f9        ; 
             push     hl                   ; $ea28 e5              ; 
             rst      rst0030              ; $ea29 f7              ; 
             jr       z,print_emit_item    ; $ea2a 28 1b           ; 
             call     str_format_number    ; $ea2c cd ab bb        ; 
             call     str_scan_literal     ; $ea2f cd 6e d5        ; 
             ld       (hl),$20             ; $ea32 36 20           ; 
             ld       hl,($0450)           ; $ea34 2a 50 04        ; 
             inc      (hl)                 ; $ea37 34              ; 
             ld       bc,$ff00             ; $ea38 01 00 ff        ; 
             call     rst38_call_channel_vector1 ; $ea3b cd ee e8        ; 
             and      a,a                  ; $ea3e a7              ; 
             jr       z,print_emit_item    ; $ea3f 28 06           ; 
             add      a,(hl)               ; $ea41 86              ; 
             dec      a                    ; $ea42 3d              ; 
             cp       a,b                  ; $ea43 b8              ; 
             call     nc,print_emit_crlf   ; $ea44 d4 29 e9        ; 
;
; Shared PRINT item output tail.  Emits the descriptor/string selected
; by the preceding path via calld5b4, restores HL, and returns to
; print_next_item.
;
print_emit_item: call     print_emit_string_item ; $ea47 cd b4 d5        ; 
             pop      hl                   ; $ea4a e1              ; 
             jr       print_next_item      ; $ea4b 18 bd           ; 

;
; `,` separator: advance to next 14-column tab stop.
; Compute column offset via calle8ee; output spaces.
;
print_tab_comma: ld       bc,$0000             ; $ea4d 01 00 00        ; 
             call     rst38_call_channel_vector1 ; $ea50 cd ee e8        ; 
             push     af                   ; $ea53 f5              ; 
             ld       a,b                  ; $ea54 78              ; 
             and      a,a                  ; $ea55 a7              ; 
             jr       z,skipea7b           ; $ea56 28 23           ; 
loopea58:    sub      a,$0e                ; $ea58 d6 0e           ; 
             jr       nc,loopea58          ; $ea5a 30 fc           ; 
             add      a,$1c                ; $ea5c c6 1c           ; 
             defb     $ed,$44,$80,$4f,$f1,$b9,$d4,$29,$e9,$30      ; .D.O...).0 ; 
             defb     $0e,$d6,$0e,$30,$fc,$2f                      ; ...0./     ; 
;
; Emit A spaces through RST $28.  Used by comma-zone alignment, TAB(,
; and the PRINT USING padding paths.
;
print_emit_spaces: inc      a                    ; $ea6e 3c              ; 
             jr       z,print_separator_dispatch ; $ea6f 28 06           ; 
             ld       b,a                  ; $ea71 47              ; 
             ld       a,$20                ; $ea72 3e 20           ; 
loopea74:    rst      rst0028              ; $ea74 ef              ; 
             djnz     loopea74             ; $ea75 10 fd           ; 
;
; Common continuation after `;` and post-spacing handling.  Restores
; HL, fetches the next token, and re-enters print_item_dispatch
; without forcing a CRLF.
;
print_separator_dispatch: pop      hl                   ; $ea77 e1              ; 
             rst      rst0010              ; $ea78 d7              ; 
             jr       print_item_dispatch  ; $ea79 18 94           ; 

skipea7b:    ld       a,$09                ; $ea7b 3e 09           ; 
             rst      rst0028              ; $ea7d ef              ; 
             pop      af                   ; $ea7e f1              ; 
             jr       print_separator_dispatch ; $ea7f 18 f6           ; 

;
; TAB( function in PRINT: evaluate column argument (callfe5d),
; verify `(` token (RST $08/$29).  Output spaces to reach column.
;
print_tab_fn: call     callfe5d             ; $ea81 cd 5d fe        ; 
             rst      rst0008              ; $ea84 cf              ; 
             add      hl,hl                ; $ea85 29              ; 
             dec      hl                   ; $ea86 2b              ; 
             push     hl                   ; $ea87 e5              ; 
             ld       bc,$ffff             ; $ea88 01 ff ff        ; 
             call     rst38_call_channel_vector1 ; $ea8b cd ee e8        ; 
             dec      b                    ; $ea8e 05              ; 
             ld       a,b                  ; $ea8f 78              ; 
             cp       a,e                  ; $ea90 bb              ; 
             jr       nc,skipea94          ; $ea91 30 01           ; 
             ld       e,b                  ; $ea93 58              ; 
skipea94:    ld       l,$00                ; $ea94 2e 00           ; 
             rst      rst0038              ; $ea96 ff              ; 
             adc      a,a                  ; $ea97 8f              ; 
             ld       a,l                  ; $ea98 7d              ; 
             and      a,a                  ; $ea99 a7              ; 
             jr       nz,print_separator_dispatch ; $ea9a 20 db           ; 
             ld       a,c                  ; $ea9c 79              ; 
             cpl                           ; $ea9d 2f              ; 
             add      a,e                  ; $ea9e 83              ; 
             jr       c,print_emit_spaces  ; $ea9f 38 cd           ; 
             ld       a,$0d                ; $eaa1 3e 0d           ; 
             rst      rst0028              ; $eaa3 ef              ; 
             ld       a,e                  ; $eaa4 7b              ; 
             dec      a                    ; $eaa5 3d              ; 
             jr       print_emit_spaces    ; $eaa6 18 c6           ; 

             defb     $4c,$eb,$e6,$ea,$fc,$ea,$f2,$ea,$ff,$ea      ; L......... ; 
             defb     $d9,$ea,$11,$eb,$23,$eb,$73,$ed,$cd,$89      ; ....#.s... ; 
             defb     $ec,$3a,$ba,$00,$67,$cd,$60,$00,$fe,$20      ; .:..g.`... ; 
             defb     $20,$14,$25,$20,$f6,$cd,$0d,$eb,$cd,$2a      ; ..%......* ; 
             defb     $eb,$c8,$2d,$cd,$d1,$eb,$28,$e5,$c9          ; ..-...(..  ; 
;
; Advance the text cursor after storing a printable character.
; Steps right while below the active width in $00ba; on wrap, resets to
; column 1, clears the current row-state byte, and continues via
; text_cursor_next_row.
;
text_cursor_advance_after_write: ld       hl,($00b8)           ; $ead9 2a b8 00        ; 
             call     text_cursor_inc_col  ; $eadc cd 08 eb        ; 
             ret      nz                   ; $eadf c0              ; 

             ld       h,$01                ; $eae0 26 01           ; 
             xor      a,a                  ; $eae2 af              ; 
             call     text_row_state_store_a ; $eae3 cd de eb        ; 
             call     text_cursor_next_row ; $eae6 cd 73 ed        ; 
             ret      nz                   ; $eae9 c0              ; 

             ld       ($00b8),hl           ; $eaea 22 b8 00        ; 
             call     text_window_scroll   ; $eaed cd 60 eb        ; 
             jr       text_cursor_sync_from_state ; $eaf0 18 50           ; 

             defb     $2a,$bb,$00,$cd,$28,$ed,$6c,$22,$be,$00      ; *...(.l".. ; 
             defb     $2a,$bb,$00                                  ; *..        ; 
calleaff:    ld       h,$01                ; $eaff 26 01           ; 
             jr       skipeb0e             ; $eb01 18 0b           ; 

calleb03:    ld       a,($00bc)            ; $eb03 3a bc 00        ; 
             cp       a,l                  ; $eb06 bd              ; 
             ret                           ; $eb07 c9              ; 

;
; Increment the 1-based text column in H and commit it through
; text_cursor_store_and_sync unless the active width in $00ba has
; already been reached.
;
text_cursor_inc_col: ld       a,($00ba)            ; $eb08 3a ba 00        ; 
             cp       a,h                  ; $eb0b bc              ; 
             ret      z                    ; $eb0c c8              ; 

             inc      h                    ; $eb0d 24              ; 
skipeb0e:    jp       text_cursor_store_and_sync ; $eb0e c3 64 c1        ; 

             defb     $25,$20,$fa,$2d,$cd,$d1,$eb                  ; %..-...    ; 
             defm     " 0,$% "                                                  ;
             defb     $ef,$3a,$ba,$00,$67,$cd,$2a,$eb,$c8,$2d      ; .:..g.*..- ; 
             defb     $18,$e4,$3e,$01,$bd,$c8,$3a,$bb,$00,$bd      ; ..>...:... ; 
             defb     $c9                                          ; .          ; 
calleb33:    ld       hl,$ec2c             ; $eb33 21 2c ec        ; 
             ld       c,$0a                ; $eb36 0e 0a           ; 
             call     callec25             ; $eb38 cd 25 ec        ; 
             ret      m                    ; $eb3b f8              ; 

             ld       hl,$ec37             ; $eb3c 21 37 ec        ; 
             call     callee13             ; $eb3f cd 13 ee        ; 
;
; Reload the text cursor pair from $00b8 and push it to disp_set_cursor
; with attribute byte 0.
;
text_cursor_sync_from_state: ld       hl,($00b8)           ; $eb42 2a b8 00        ; 
             ld       c,$00                ; $eb45 0e 00           ; 
             call     call0072             ; $eb47 cd 72 00        ; 
             xor      a,a                  ; $eb4a af              ; 
             ret                           ; $eb4b c9              ; 

             defb     $cd,$7b,$c1,$79,$e6,$f8,$c6,$09,$b8,$38      ; .{.y.....8 ; 
             defb     $01,$78,$32,$b9,$00,$2a,$b8,$00,$18,$ae      ; .x2..*.... ; 
;
; Scroll / rotate the active text window using the per-row state table
; rooted at $00bf.  Uses the window bounds from $00bb and the current
; row marker at $00be before invoking the text scroll syscalls.
;
text_window_scroll: ld       hl,($00bb)           ; $eb60 2a bb 00        ; 
             ld       a,h                  ; $eb63 7c              ; 
             ld       h,l                  ; $eb64 65              ; 
             ld       l,a                  ; $eb65 6f              ; 
             sub      a,h                  ; $eb66 94              ; 
             inc      a                    ; $eb67 3c              ; 
             push     af                   ; $eb68 f5              ; 
             ld       b,a                  ; $eb69 47              ; 
             call     text_row_state_get   ; $eb6a cd d1 eb        ; 
             ld       c,a                  ; $eb6d 4f              ; 
             ld       a,b                  ; $eb6e 78              ; 
             ex       de,hl                ; $eb6f eb              ; 
loopeb70:    ld       (hl),b               ; $eb70 70              ; 
             dec      hl                   ; $eb71 2b              ; 
             ld       b,c                  ; $eb72 41              ; 
             ld       c,(hl)               ; $eb73 4e              ; 
             dec      a                    ; $eb74 3d              ; 
             jr       nz,loopeb70          ; $eb75 20 f9           ; 
             ex       de,hl                ; $eb77 eb              ; 
             ld       a,($00be)            ; $eb78 3a be 00        ; 
             cp       a,h                  ; $eb7b bc              ; 
             jr       nz,skipeb80          ; $eb7c 20 02           ; 
             ld       a,$01                ; $eb7e 3e 01           ; 
skipeb80:    dec      a                    ; $eb80 3d              ; 
             ld       ($00be),a            ; $eb81 32 be 00        ; 
             pop      bc                   ; $eb84 c1              ; 
             dec      b                    ; $eb85 05              ; 
             jr       z,skipeb8e           ; $eb86 28 06           ; 
             call     call007e             ; $eb88 cd 7e 00        ; 
             jp       jump0081             ; $eb8b c3 81 00        ; 

skipeb8e:    call     text_row_state_store_l ; $eb8e cd dd eb        ; 
             call     call0075             ; $eb91 cd 75 00        ; 
             call     call0078             ; $eb94 cd 78 00        ; 
             jp       jump005d             ; $eb97 c3 5d 00        ; 

             defb     $7d,$2a,$bb,$00,$6f,$7c,$95,$d8,$3c,$f5      ; }*..o|..<. ; 
             defb     $47,$cd,$d1,$eb,$4f,$78,$eb                  ; G...Ox.    ; 
             defm     "p#AN= "                                                  ;
             defb     $f9,$2b,$36,$ff,$eb,$c1,$05,$28,$d4,$e5      ; .+6....(.. ; 
             defb     $cd,$7b,$00,$e1,$4d,$e5,$26,$01,$cd,$e5      ; .{..M.&... ; 
             defb     $eb,$59,$cd,$63,$00,$e1,$2c,$7c,$bd,$30      ; .Y.c..,|.0 ; 
             defb     $ef,$c9                                      ; ..         ; 
;
; Read the per-row text-state byte selected by L from the table at
; $00bf+L.  Returns the byte in A and DE pointing at the slot.
;
text_row_state_get: push     hl                   ; $ebd1 e5              ; 
             ld       de,$00bf             ; $ebd2 11 bf 00        ; 
             ld       h,$00                ; $ebd5 26 00           ; 
             add      hl,de                ; $ebd7 19              ; 
             ld       a,(hl)               ; $ebd8 7e              ; 
             ex       de,hl                ; $ebd9 eb              ; 
             pop      hl                   ; $ebda e1              ; 
             and      a,a                  ; $ebdb a7              ; 
             ret                           ; $ebdc c9              ; 

;
; Convenience entry for text_row_state_store_a.
; Loads A from L, then falls through to store that value in the current
; per-row text-state slot.
;
text_row_state_store_l: ld       a,l                  ; $ebdd 7d              ; 
;
; Store A into the per-row text-state slot selected by HL/L.
;
text_row_state_store_a: push     af                   ; $ebde f5              ; 
             call     text_row_state_get   ; $ebdf cd d1 eb        ; 
             pop      af                   ; $ebe2 f1              ; 
             ld       (de),a               ; $ebe3 12              ; 
             ret                           ; $ebe4 c9              ; 

callebe5:    push     de                   ; $ebe5 d5              ; 
             push     af                   ; $ebe6 f5              ; 
             call     call0075             ; $ebe7 cd 75 00        ; 
             ld       l,h                  ; $ebea 6c              ; 
             ld       h,$00                ; $ebeb 26 00           ; 
             dec      l                    ; $ebed 2d              ; 
             add      hl,de                ; $ebee 19              ; 
             pop      af                   ; $ebef f1              ; 
             pop      de                   ; $ebf0 d1              ; 
             ret                           ; $ebf1 c9              ; 

;
; kbd_readline_prompt — keyboard line input with "? " prompt
; Entry point used by INPUT when reading from the keyboard in
; interactive mode.  Calls call0057 (syscall slot 0), then
; outputs "? " ($3F, $20) via jump009f, and falls into
; kbd_readline (callebff).
;
kbd_readline_prompt: call     call0057             ; $ebf2 cd 57 00        ; 
             ld       a,$3f                ; $ebf5 3e 3f           ; 
             call     jump009f             ; $ebf7 cd 9f 00        ; 
             ld       a,$20                ; $ebfa 3e 20           ; 
             call     jump009f             ; $ebfc cd 9f 00        ; 
;
; kbd_readline — keyboard line input without a prompt
; Entry point for LINE INPUT and for callers that supply their
; own prompt.  Calls call0057 (syscall slot 0) then callec1c
; to reset the input-buffer pointer from the cursor register
; at $00B8.  Falls into the line-editor loop (callec05):
; Stores the buffer base to $00BE.  Each iteration calls
; kbd_read_char (callc8c5) to read one key; if carry is
; returned (Enter / line-complete), calls callec7c which
; outputs LF, NUL-terminates the buffer, pops an extra HL,
; and returns carry set.  Otherwise, calleb33 accumulates
; the character and jump009f echoes it; loops while carry
; is clear.
; Returns: carry set, buffer NUL-terminated at ($00BE).
;
kbd_readline: call     call0057             ; $ebff cd 57 00        ; 
             call     text_cursor_mark_row ; $ec02 cd 1c ec        ; 
callec05:    ld       ($00be),hl           ; $ec05 22 be 00        ; 
loopec08:    call     kbd_read_char        ; $ec08 cd c5 c8        ; 
             call     c,callec7c           ; $ec0b dc 7c ec        ; 
             call     calleb33             ; $ec0e cd 33 eb        ; 
             call     nz,jump009f          ; $ec11 c4 9f 00        ; 
             jr       nc,loopec08          ; $ec14 30 f2           ; 
             ld       hl,$00d4             ; $ec16 21 d4 00        ; 
             ret      z                    ; $ec19 c8              ; 

             ccf                           ; $ec1a 3f              ; 
             ret                           ; $ec1b c9              ; 

;
; Update the current row's per-row state from the text cursor in $00b8.
; When the cursor column is non-zero, stores column-1 into the row-state
; table for the active row.
;
text_cursor_mark_row: ld       hl,($00b8)           ; $ec1c 2a b8 00        ; 
             dec      l                    ; $ec1f 2d              ; 
             call     nz,text_row_state_store_l ; $ec20 c4 dd eb        ; 
             inc      l                    ; $ec23 2c              ; 
             ret                           ; $ec24 c9              ; 

callec25:    and      a,a                  ; $ec25 a7              ; 
             inc      hl                   ; $ec26 23              ; 
             dec      c                    ; $ec27 0d              ; 
             ret      m                    ; $ec28 f8              ; 

             cp       a,(hl)               ; $ec29 be              ; 
             jr       nz,callec25          ; $ec2a 20 f9           ; 
             ret                           ; $ec2c c9              ; 

             defb     $08,$12,$02,$06,$05,$0d,$15,$16,$18,$10      ; .......... ; 
             defb     $19,$ed,$ba,$ea,$b2,$ec,$3b,$ed,$4b,$ec      ; ......;.K. ; 
             defb     $41,$ed,$58,$ed,$63,$ed,$8f,$ec,$ee,$ec      ; A.X.c..... ; 
             defb     $cd,$86,$ed,$11,$d5,$00,$06,$fe,$2d,$2c      ; ........-, ; 
             defb     $cd,$9d,$ed,$28,$09,$d5,$cd,$d1,$eb,$d1      ; ...(...... ; 
             defb     $26,$01,$28,$f1,$1b,$1a,$fe,$20,$28,$fa      ; &.(.....(. ; 
             defb     $13,$af,$12,$3e,$0d,$a7                      ; ...>..     ; 
loopec6f:    push     af                   ; $ec6f f5              ; 
             call     calleaff             ; $ec70 cd ff ea        ; 
             ld       a,$0a                ; $ec73 3e 0a           ; 
             call     jump009f             ; $ec75 cd 9f 00        ; 
             pop      af                   ; $ec78 f1              ; 
             scf                           ; $ec79 37              ; 
             pop      hl                   ; $ec7a e1              ; 
             ret                           ; $ec7b c9              ; 

callec7c:    ld       hl,($00b8)           ; $ec7c 2a b8 00        ; 
             call     callec89             ; $ec7f cd 89 ec        ; 
             xor      a,a                  ; $ec82 af              ; 
             ld       ($00d5),a            ; $ec83 32 d5 00        ; 
             jr       loopec6f             ; $ec86 18 e7           ; 

loopec88:    inc      l                    ; $ec88 2c              ; 
callec89:    call     text_row_state_get   ; $ec89 cd d1 eb        ; 
             jr       z,loopec88           ; $ec8c 28 fa           ; 
             ret                           ; $ec8e c9              ; 

             defb     $3e,$20,$4f,$cd,$ae,$ed,$38,$16,$f5,$20      ; >.O...8... ; 
             defb     $08,$3a,$ba,$00,$bc,$28,$02,$f1,$c9,$af      ; .:...(.... ; 
             defb     $cd,$de,$eb,$2c,$cd,$d6,$ed,$f1,$c8,$2d      ; ...,.....- ; 
             defb     $26,$01,$2c,$18,$df,$e5,$3a,$ba,$00,$bc      ; &.,...:... ; 
             defb     $20,$0d,$cd,$d1,$eb,$20,$10,$cd,$03,$eb      ; .......... ; 
             defb     $28,$0b,$2c,$26,$00,$24,$cd,$ee,$ec,$e1      ; (.,&.$.... ; 
             defb     $c3,$64,$c1,$e1,$18,$18,$3a,$ba,$00,$bc      ; .d....:... ; 
             defb     $28,$12,$24,$cd,$60,$00,$25,$cd,$6f,$00      ; (.$.`.%.o. ; 
             defb     $24,$24,$3a,$ba,$00,$3c,$bc,$20,$f0,$25      ; $$:..<...% ; 
             defb     $3e,$20,$c3,$6f,$00,$25,$20,$10,$24,$e5      ; >..o.%..$. ; 
             defb     $2d,$28,$0a,$3a,$ba,$00,$67,$cd,$d1,$eb      ; -(.:..g... ; 
             defb     $20,$01,$e3,$e1,$22,$b8,$00,$cd,$d1,$ec      ; ...."..... ; 
             defb     $cd,$d1,$eb,$c0,$e5,$2c,$26,$01,$cd,$60      ; .....,&..` ; 
             defb     $00,$e3,$cd,$6f,$00,$e1,$18,$eb,$cd,$41      ; ...o.....A ; 
             defb     $ed,$cd,$03,$eb,$c8,$7d,$f5,$2a,$bb,$00      ; .....}.*.. ; 
             defb     $f1,$6f,$2c,$7c,$95,$3c,$2d,$c4,$de,$eb      ; .o,|.<-... ; 
             defb     $2c,$67,$e5,$cd,$8e,$eb,$e1,$2c,$25,$20      ; ,g.....,%. ; 
             defb     $f7,$c9,$cd,$86,$ed,$22,$b8,$00,$cd,$e9      ; .....".... ; 
             defb     $ec,$24,$3a,$ba,$00,$3c,$bc,$20,$f5,$cd      ; .$:..<.... ; 
             defb     $d1,$eb,$c0,$cd,$dd,$eb,$26,$01,$2c,$18      ; ......&.,. ; 
             defb     $e9,$cd,$ef,$ed,$30,$fb,$cd,$ef,$ed,$38      ; ....0....8 ; 
             defb     $fb,$c9,$cd,$f6,$ed,$38,$fb,$cd,$f6,$ed      ; .....8.... ; 
             defb     $30,$fb,$cd,$08,$eb,$c0,$26,$01              ; 0.....&.   ; 
;
; Advance the text cursor to the next row / wrap target used by the
; text output path.  Checks the active bottom-row limit, optionally
; clears the new row-state byte, then commits the updated cursor.
;
text_cursor_next_row: call     calleb03             ; $ed73 cd 03 eb        ; 
             ret      z                    ; $ed76 c8              ; 

             jr       nc,skiped7f          ; $ed77 30 06           ; 
             call     text_row_state_store_a ; $ed79 cd de eb        ; 
             ld       l,a                  ; $ed7c 6f              ; 
             xor      a,a                  ; $ed7d af              ; 
             defb     $06                  ; $ed7e 06 2c           ;   As: ld     b,$2c      ; 06 2c      ; Next: $ed80
skiped7f:    inc      l                    ; $ed7f 2c              ; 
             push     af                   ; $ed80 f5              ; 
             call     text_cursor_store_and_sync ; $ed81 cd 64 c1        ; 
             pop      af                   ; $ed84 f1              ; 
             ret                           ; $ed85 c9              ; 

             defb     $cd,$2a,$eb,$28,$07,$2d,$cd,$d1,$eb,$28      ; .*.(.-...( ; 
             defb     $f5,$2c,$3a,$be,$00,$bd,$26,$01,$c0,$2a      ; .,:...&..* ; 
             defb     $be,$00,$c9,$c5,$cd,$60,$00,$c1,$12,$13      ; .....`.... ; 
             defb     $05,$c8,$24,$3a,$ba,$00,$bc,$d8,$18,$ef      ; ..$:...... ; 
             defb     $cd,$be,$ed,$f5,$cd,$d1,$eb,$d1,$7a,$37      ; ........z7 ; 
             defb     $c8,$fe,$20,$c8,$a7,$c9,$e5,$c5,$cd,$60      ; .........` ; 
             defb     $00,$c1,$f5,$79,$cd,$6f,$00,$f1,$4f,$3a      ; ...y.o..O: ; 
             defb     $ba,$00,$3c,$24,$bc,$20,$ec,$79,$e1,$c9      ; ..<$...y.. ; 
             defb     $e5,$2d,$cd,$03,$eb,$28,$06,$2c,$cd,$9a      ; .-...(.,.. ; 
             defb     $eb,$e1,$c9,$2a,$b8,$00,$cd,$23,$eb,$cd      ; ...*...#.. ; 
             defb     $60,$eb,$e1,$2d,$c9,$cd,$6d,$ed,$20,$07      ; `..-..m... ; 
             defb     $e1,$c9,$cd,$1c,$eb,$28,$f9,$cd,$60,$00      ; .....(..`. ; 
             defb     $fe,$30,$d8,$fe,$3a,$3f,$d0,$fe,$41,$d8      ; .0..:?..A. ; 
             defb     $fe,$5b,$3f,$d0,$fe,$61,$d8,$fe,$7b,$3f      ; .[?..a..{? ; 
             defb     $c9                                          ; .          ; 
callee13:    rlc      c                    ; $ee13 cb 01           ; 
             ld       b,$00                ; $ee15 06 00           ; 
             add      hl,bc                ; $ee17 09              ; 
             rst      rst0038              ; $ee18 ff              ; 
             nop                           ; $ee19 00              ; 
             push     de                   ; $ee1a d5              ; 
             ld       hl,($00b8)           ; $ee1b 2a b8 00        ; 
             ret                           ; $ee1e c9              ; 

             defb     $2a,$e5,$02,$23,$7e,$fe,$0c,$c8,$fe,$07      ; *..#~..... ; 
             defb     $28,$04,$ff,$03,$eb,$dd,$21,$3b,$ee,$dd      ; (.....!;.. ; 
             defb     $21,$0a,$c9,$22,$a3,$00,$af,$c9,$21,$e5      ; !.."....!. ; 
             defb     $02,$cd,$ce,$e5,$d0,$18,$ef,$00              ; ........   ; 
;
; RST $20 handler — 16-bit unsigned comparison of HL with DE.
; Returns Z and carry clear if HL = DE.
; Returns NZ with carry set if HL < DE (unsigned).
; Returns NZ with carry clear if HL > DE.
; Used as a range boundary test (e.g., RAM zero-fill loop termination).
;
rst20_cmp_hl_de: ld       a,h                  ; $ee45 7c              ; 
             sub      a,d                  ; $ee46 92              ; 
             ret      nz                   ; $ee47 c0              ; 

             ld       a,l                  ; $ee48 7d              ; 
             sub      a,e                  ; $ee49 93              ; 
             ret                           ; $ee4a c9              ; 

;
; fn_dispatch_table — BASIC expression function dispatch table
; 28-entry table of 2-byte little-endian handler addresses.
; Covers function tokens $DF (SGN) through $FA (MID$).
; The expression evaluator (dispatch code at $FBA9) subtracts $DF
; from the token byte to get an index into this table, then jumps
; to the corresponding handler.
; Table entries (token → handler address):
; $DF SGN →$C9F1   $E0 INT →$CC23   $E1 ABS →$C9DC   $E2 FRE →$DDD7
; $E3 POS →$FC8C   $E4 SQR →$B694   $E5 RND →$B771   $E6 LOG →$B609
; $E7 EXP →$B6DD   $E8 COS →$B530   $E9 SIN →$B549   $EA TAN →$B593
; $EB ATN →$B5AC   $EC PEEK→$FC7A   $ED CINT→$CAE0   $EE CSNG→$CB08
; $EF CDBL→$CB90   $F0 FIX →$CC14   $F1 LEN →$D72D   $F2 HEX$→$D538
; $F3 STR$→$D53D   $F4 VAL →$DCB3   $F5 ASC →$D81A   $F6 CHR$→$D828
; $F7 TKEY→$D7CC   $F8 LEFT$→$DC5A  $F9 RIGHT$→$DC8A $FA MID$→$DC93
;
fn_dispatch_table: defb     $f1,$c9,$23,$cc,$dc,$c9,$d7,$dd,$8c,$fc      ; ..#....... ; 
             defb     $94,$b6,$71,$b7,$09,$b6,$dd,$b6,$30,$b5      ; ..q.....0. ; 
             defb     $49,$b5,$93,$b5,$ac,$b5,$7a,$fc,$e0,$ca      ; I.....z... ; 
             defb     $08,$cb,$90,$cb,$14,$cc,$2d,$d7,$38,$d5      ; ......-.8. ; 
             defb     $3d,$d5,$b3,$dc,$1a,$d8,$28,$d8,$cc,$d7      ; =.....(... ; 
             defb     $5a,$dc,$8a,$dc,$93,$dc                      ; Z.....     ; 
;
; BASIC statement keyword table.
; Each keyword starts with first-char | $80, rest are plain ASCII.
; 81 keywords from END to STEP.
; NOTE: The address $EE83 is NOT referenced as a 16-bit constant in any
; code reachable from the entry point $C3C3. The BASIC tokeniser likely
; receives the table address via a RAM pointer initialised at startup.
; 
; ============================================================
; BASIC keyword table — $EE83–$F074
; ============================================================
; Two consecutive tables used by the BASIC tokeniser.
; Each keyword has its first character with bit 7 set; the
; remaining characters are plain ASCII.  The table ends with
; a $80 stop byte.
; keywords ($EE83–$EFE5): 81 statement keywords —
; END FOR NEXT DATA INPUT DIM READ LET GOTO RUN IF RESTORE
; GOSUB RETURN REM STOP ELSE TR MOTOR DEFSTR DEFINT DEFSNG
; DEFDBL LINE ERROR RESUME OUT ON LPRINT DEFFN POKE PRINT
; CONT LIST LLIST CLEAR CIRCLE CONSOLE CLS COLOR EXEC
; LOCATE PSET PRESET OFF SLEEP DIR DELETE FSET PAINT LOAD
; SAVE INIT ERASE BEEP CLOAD CSAVE NEW TAB( TO FN USING
; ERL ERR STRING$ INSTR INKEY$ INP VARPTR USR SNS ALM$
; DATE$ TIME$ START$ FONT$ KEY$ SCREEN THEN NOT STEP
; ops_table ($EFE6–$F074): 47 operator/function keywords —
; + - * / ^ AND OR XOR EQV MOD \ > = < SGN INT ABS FRE
; POS SQR RND LOG EXP COS SIN TAN ATN PEEK CINT CSNG CDBL
; FIX LEN HEX$ STR$ VAL ASC CHR$ TKEY LEFT$ RIGHT$ MID$
; CSRLIN STICK STRIG POINT '
;
keywords:    defb     $c5,$4e,$44,$c6,$4f,$52,$ce,$45,$58,$54      ; .ND.OR.EXT ; 
             defb     $c4,$41,$54,$41,$c9,$4e,$50,$55,$54,$c4      ; .ATA.NPUT. ; 
             defb     $49,$4d,$d2,$45,$41,$44,$cc,$45,$54,$c7      ; IM.EAD.ET. ; 
             defb     $4f,$54,$4f,$d2,$55,$4e,$c9,$46,$d2,$45      ; OTO.UN.F.E ; 
             defb     $53,$54,$4f,$52,$45,$c7,$4f,$53,$55,$42      ; STORE.OSUB ; 
             defb     $d2,$45,$54,$55,$52,$4e,$d2,$45,$4d,$d3      ; .ETURN.EM. ; 
             defb     $54,$4f,$50,$c5,$4c,$53,$45,$d4,$52,$cd      ; TOP.LSE.R. ; 
             defb     $4f,$54,$4f,$52,$c4,$45,$46,$53,$54,$52      ; OTOR.EFSTR ; 
             defb     $c4,$45,$46,$49,$4e,$54,$c4,$45,$46,$53      ; .EFINT.EFS ; 
             defb     $4e,$47,$c4,$45,$46,$44,$42,$4c,$cc,$49      ; NG.EFDBL.I ; 
             defb     $4e,$45,$c5,$52,$52,$4f,$52,$d2,$45,$53      ; NE.RROR.ES ; 
             defb     $55,$4d,$45,$cf,$55,$54,$cf,$4e,$cc,$50      ; UME.UT.N.P ; 
             defb     $52,$49,$4e,$54,$c4,$45,$46,$46,$4e,$d0      ; RINT.EFFN. ; 
             defb     $4f,$4b,$45,$d0,$52,$49,$4e,$54,$c3,$4f      ; OKE.RINT.O ; 
             defb     $4e,$54,$cc,$49,$53,$54,$cc,$4c,$49,$53      ; NT.IST.LIS ; 
             defb     $54,$c3,$4c,$45,$41,$52,$c3,$49,$52,$43      ; T.LEAR.IRC ; 
             defb     $4c,$45,$c3,$4f,$4e,$53,$4f,$4c,$45,$c3      ; LE.ONSOLE. ; 
             defb     $4c,$53,$c3,$4f,$4c,$4f,$52,$c5,$58,$45      ; LS.OLOR.XE ; 
             defb     $43,$cc,$4f,$43,$41,$54,$45,$d0,$53,$45      ; C.OCATE.SE ; 
             defb     $54,$d0,$52,$45,$53,$45,$54,$cf,$46,$46      ; T.RESET.FF ; 
             defb     $d3,$4c,$45,$45,$50,$c4,$49,$52,$c4,$45      ; .LEEP.IR.E ; 
             defb     $4c,$45,$54,$45,$c6,$53,$45,$54,$d0,$41      ; LETE.SET.A ; 
             defb     $49,$4e,$54,$cc,$4f,$41,$44,$d3,$41,$56      ; INT.OAD.AV ; 
             defb     $45,$c9,$4e,$49,$54,$c5,$52,$41,$53,$45      ; E.NIT.RASE ; 
             defb     $c2,$45,$45,$50,$c3,$4c,$4f,$41,$44,$c3      ; .EEP.LOAD. ; 
             defb     $53,$41,$56,$45,$ce,$45,$57,$d4,$41,$42      ; SAVE.EW.AB ; 
             defb     $28,$d4,$4f,$c6,$4e,$d5,$53,$49,$4e,$47      ; (.O.N.SING ; 
             defb     $c5,$52,$4c,$c5,$52,$52,$d3,$54,$52,$49      ; .RL.RR.TRI ; 
             defb     $4e,$47,$24,$c9,$4e,$53,$54,$52,$c9,$4e      ; NG$.NSTR.N ; 
             defb     $4b,$45,$59,$24,$c9,$4e,$50,$d6,$41,$52      ; KEY$.NP.AR ; 
             defb     $50,$54,$52,$d5,$53,$52,$d3,$4e,$53,$c1      ; PTR.SR.NS. ; 
             defb     $4c,$4d,$24,$c4,$41,$54,$45,$24,$d4,$49      ; LM$.ATE$.I ; 
             defb     $4d,$45,$24,$d3,$54,$41,$52,$54,$24,$c6      ; ME$.TART$. ; 
             defb     $4f,$4e,$54,$24,$cb,$45,$59,$24,$d3,$43      ; ONT$.EY$.C ; 
             defb     $52,$45,$45,$4e,$d4,$48,$45,$4e,$ce,$4f      ; REEN.HEN.O ; 
             defb     $54,$d3,$54,$45,$50                          ; T.TEP      ; 
;
; BASIC operator and function keyword table.
; 47 entries from + to ' (single-quote).
;
ops_table:   defb     $ab,$ad,$aa,$af,$de,$c1,$4e,$44,$cf,$52      ; ......ND.R ; 
             defb     $d8,$4f,$52,$c5,$51,$56,$cd,$4f,$44,$dc      ; .OR.QV.OD. ; 
             defb     $be,$bd,$bc,$d3,$47,$4e,$c9,$4e,$54,$c1      ; ....GN.NT. ; 
             defb     $42,$53,$c6,$52,$45,$d0,$4f,$53,$d3,$51      ; BS.RE.OS.Q ; 
             defb     $52,$d2,$4e,$44,$cc,$4f,$47,$c5,$58,$50      ; R.ND.OG.XP ; 
             defb     $c3,$4f,$53,$d3,$49,$4e,$d4,$41,$4e,$c1      ; .OS.IN.AN. ; 
             defb     $54,$4e,$d0,$45,$45,$4b,$c3,$49,$4e,$54      ; TN.EEK.INT ; 
             defb     $c3,$53,$4e,$47,$c3,$44,$42,$4c,$c6,$49      ; .SNG.DBL.I ; 
             defb     $58,$cc,$45,$4e,$c8,$45,$58,$24,$d3,$54      ; X.EN.EX$.T ; 
             defb     $52,$24,$d6,$41,$4c,$c1,$53,$43,$c3,$48      ; R$.AL.SC.H ; 
             defb     $52,$24,$d4,$4b,$45,$59,$cc,$45,$46,$54      ; R$.KEY.EFT ; 
             defb     $24,$d2,$49,$47,$48,$54,$24,$cd,$49,$44      ; $.IGHT$.ID ; 
             defb     $24,$c3,$53,$52,$4c,$49,$4e,$d3,$54,$49      ; $.SRLIN.TI ; 
             defb     $43,$4b,$d3,$54,$52,$49,$47,$d0,$4f,$49      ; CK.TRIG.OI ; 
             defb     $4e,$54,$a7                                  ; NT.        ; 
;
; End-of-table marker ($80).
;
keywords_end: defb     $80                                          ; .          ; 
;
; BASIC statement keyword dispatch table.
; 58 entries (2 bytes each, little-endian), one per keyword in the
; keywords table from END (index 0) through NEW (index 57).
; Each entry is the address of the handler routine for that keyword.
; Five entries point into RAM ($008A/$008D/$0090/$0099/$009C) — these
; are system-call slots installed by rst_init_block at boot.
; Table occupies $F076–$F0E9 (116 bytes).
;
keyword_dispatch_table: defb     $b0,$d2,$f7,$f3,$0c,$d3,$64,$f6,$2f,$f8      ; ......d./. ; 
             defb     $05,$b0,$6b,$f8,$85,$f6,$21,$f6,$b7,$f5      ; ..k...!... ; 
             defb     $97,$f7,$96,$d2,$10,$f6,$3d,$f6,$66,$f6      ; ......=.f. ; 
             defb     $c0,$d2,$66,$f6,$b7,$d1,$b9,$e0,$4e,$f5      ; ..f.....N. ; 
             defb     $51,$f5,$54,$f5,$57,$f5,$c6,$f7,$8c,$f7      ; Q.T.W..... ; 
             defb     $34,$f7,$8c,$e9,$f1,$f6,$de,$e9,$96,$fc      ; 4......... ; 
             defb     $80,$fc,$05,$ea,$78,$d1,$75,$fe,$6b,$fe      ; ....x.u.k. ; 
             defb     $d0,$d1,$9c,$00,$43,$e2,$9e,$ce,$8a,$00      ; ....C..... ; 
             defb     $b8,$ce,$12,$e2,$8d,$00,$90,$00,$b1,$c5      ; .......... ; 
             defb     $9a,$c5,$e3,$e5,$82,$e6,$56,$bf,$99,$00      ; ......V... ; 
             defb     $38,$df,$fe,$de,$99,$e6,$cf,$e3,$cd,$c2      ; 8......... ; 
             defb     $30,$df,$f9,$de,$14,$d2                      ; 0.....     ; 
;
; Expression-operator binding-power table for token bytes $d1-$de.
; Indexed by (token - $d1).  expr_operator_loop compares the table
; byte against the current minimum precedence and only recurses for
; a right-hand side when the operator binds more tightly.
;
expr_precedence_table: defm     "yy||"                                                    ;
             defb     $7f                                          ; .          ; 
             defm     "PF<2z{"                                                  ;
             defb     $90,$cb,$ff,$ff,$e0,$ca,$ae,$cb,$08,$cb      ; .......... ; 
             defb     $0e,$b2,$00,$b2,$76,$b3,$2f,$b4,$bc,$d3      ; ....v./... ; 
             defb     $d9,$ca,$a9,$cd,$b2,$cd,$b7,$cd,$c2,$cd      ; .......... ; 
             defb     $ad,$d3,$7b,$ca,$c6,$cc,$bb,$cc,$e7,$cc      ; ..{....... ; 
             defb     $79,$fa,$20,$d4,$a5,$ca                      ; y.....     ; 
;
; Packed 2-character BASIC runtime-error mnemonics indexed by
; (ERR - 1).  Used by the shared runtime-error banner printer at
; $f20b.  Sequence:
; NF SN RG OD FC OV OM UL BS DD /0 ID TM OS LS ST
; CN UF NR RW UE IO MO NE BF NO IR ?? ??
;
basic_error_code_table: defm     "NFSNRGODFCOVOMULBSDD/0IDTMOSLSSTCNUFNRRW"                ;
             defm     "UEIOMONEBFNOIR????"                                      ;
;
; Literal " Error" suffix appended after the 2-character mnemonic.
;
basic_msg_error: defm     " Error",0                                                ;
;
; Literal " in " inserted before the source line number in shared
; BREAK / runtime-error reporting.
;
basic_msg_in: defm     " in ",0                                                  ;
             defb     $3e,$1d,$00                                  ; >..        ; 
;
; Literal "Break" banner text used by STOP/END and other break exits.
;
basic_msg_break: defm     "Break",0                                                 ;
;
; ---------------------------------------------------------------------------
; BASIC statement annotations — key RAM variables
; ---------------------------------------------------------------------------
; $01DB = execution pointer (current HL of the interpreter, i.e. position in
; the tokenised program being run)
; $00B1 = ERR value / current runtime-error code
; $030F = token pointer passed between instruction handlers (current position)
; $0311 = saved current-line / statement address (used by STOP/END and
; by runtime-error bookkeeping)
; $0313 = stack ceiling (top-of-stack after last GOSUB/FOR frame)
; $0315 = saved execution pointer at error entry (RESUME / ERL source)
; $0317 = saved resume-next pointer
; $0319 = ON ERROR GOTO handler line address (0 = no trap handler)
; $031B = runtime error / trap state byte (0 = no active trapped error)
; $031E = saved execution address for CONT / error restart
; $0320 = last executed line address (for CONT and error reporting;
; 0 if not in a running program)
; $0322 = next free address in variable storage
; $0324 = current end-of-variable-area pointer
; $0326 = string storage pointer (grows downward toward variables and is
; checked before pushing FOR/GOSUB control records)
; $0328 = READ/DATA pointer (address of next DATA item to be READ)
; $032A-$0343 = DEFTYPE table for letters A..Z; NEW/RUN fill it with
; $08 so the default numeric type is double precision
; $00B2 = BASIC program start address (RAM)
; $01D9 = current variable / expression type:
; 0 = string placeholder, 2 = integer, 3 = string,
; 4 = single, 8 = double
; 
; ---------------------------------------------------------------------------
; callf172 — scan contiguous FOR frames on the CPU stack
; ---------------------------------------------------------------------------
; Starts at SP+4 and inspects control records on the machine stack.
; A FOR frame begins with marker byte $81 followed by the 2-byte loop-variable
; descriptor address; each FOR frame occupies $16 bytes, so non-matching FOR
; frames are skipped by advancing HL by $0016.
; On entry: D:E = variable address to match (0:0 matches the first FOR frame).
; On exit: Z if a matching FOR frame was found, with HL pointing just past that
; frame.  If the top record is not a FOR frame, the routine returns immediately
; with A = its marker byte (for example $8C for GOSUB), which lets RETURN
; validate the topmost control record without scanning past it.
;
ctrl_scan_for_frames: ld       hl,gpr_line_span     ; $f172 21 04 00        ; 
             add      hl,sp                ; $f175 39              ; 
;
; Inner loop of ctrl_scan_for_frames.  Test the current marker byte for $81,
; load the loop-variable pointer, and compare it against D:E when a specific
; NEXT variable was supplied.
;
ctrl_scan_for_frames_loop: ld       a,(hl)               ; $f176 7e              ; 
             inc      hl                   ; $f177 23              ; 
             cp       a,$81                ; $f178 fe 81           ; 
             ret      nz                   ; $f17a c0              ; 

             ld       c,(hl)               ; $f17b 4e              ; 
             inc      hl                   ; $f17c 23              ; 
             ld       b,(hl)               ; $f17d 46              ; 
             inc      hl                   ; $f17e 23              ; 
             push     hl                   ; $f17f e5              ; 
             ld       h,b                  ; $f180 60              ; 
             ld       l,c                  ; $f181 69              ; 
             ld       a,d                  ; $f182 7a              ; 
             or       a,e                  ; $f183 b3              ; 
             ex       de,hl                ; $f184 eb              ; 
             jr       z,ctrl_scan_for_frames_advance ; $f185 28 02           ; 
             ex       de,hl                ; $f187 eb              ; 
             rst      rst0020              ; $f188 e7              ; 
;
; Advance HL by one $16-byte FOR record and continue the scan.
;
ctrl_scan_for_frames_advance: ld       bc,$0016             ; $f189 01 16 00        ; 
             pop      hl                   ; $f18c e1              ; 
             ret      z                    ; $f18d c8              ; 

             add      hl,bc                ; $f18e 09              ; 
             jr       ctrl_scan_for_frames_loop ; $f18f 18 e5           ; 

jumpf191:    ld       hl,($01db)           ; $f191 2a db 01        ; 
             ld       a,h                  ; $f194 7c              ; 
             and      a,l                  ; $f195 a5              ; 
             inc      a                    ; $f196 3c              ; 
             jr       z,skipf1a1           ; $f197 28 08           ; 
             ld       a,($031b)            ; $f199 3a 1b 03        ; 
             or       a,a                  ; $f19c b7              ; 
             ld       e,$13                ; $f19d 1e 13           ; 
             jr       nz,basic_raise_error ; $f19f 20 26           ; 
skipf1a1:    jp       stop_save_cont_and_restart ; $f1a1 c3 d7 d2        ; 

             defb     $2a,$0c,$02,$22,$db,$01                      ; *.."..     ; 
;
; basic_raise_error_02 — shared runtime-error shim (E = $02)
; ----
; Multi-entry runtime-error shim block.  Each entry loads a fixed
; BASIC error number into E, then falls through to basic_raise_error
; at $f1c7.
;
basic_raise_error_02: ld       e,$02                ; $f1aa 1e 02           ; 
             defb     $01                  ; $f1ac 01 1e 0b        ;   As: ld     bc,$0b1e   ; 01 1e 0b   ; Next: $f1af
;
; Shared runtime-error shim (E = $0b).
;
basic_raise_error_0b: ld       e,$0b                ; $f1ad 1e 0b           ; 
             defb     $01                  ; $f1af 01 1e 01        ;   As: ld     bc,$011e   ; 01 1e 01   ; Next: $f1b2
;
; Shared runtime-error shim (E = $01).
;
basic_raise_error_01: ld       e,$01                ; $f1b0 1e 01           ; 
             defb     $01                  ; $f1b2 01 1e 0a        ;   As: ld     bc,$0a1e   ; 01 1e 0a   ; Next: $f1b5
;
; Shared runtime-error shim (E = $0a).
;
basic_raise_error_0a: ld       e,$0a                ; $f1b3 1e 0a           ; 
             defb     $01                  ; $f1b5 01 1e 12        ;   As: ld     bc,$121e   ; 01 1e 12   ; Next: $f1b8
;
; Shared runtime-error shim (E = $12).
;
basic_raise_error_12: ld       e,$12                ; $f1b6 1e 12           ; 
             defb     $01                  ; $f1b8 01 1e 14        ;   As: ld     bc,$141e   ; 01 1e 14   ; Next: $f1bb
;
; Shared runtime-error shim (E = $14).
;
basic_raise_error_14: ld       e,$14                ; $f1b9 1e 14           ; 
             defb     $01                  ; $f1bb 01 1e 06        ;   As: ld     bc,$061e   ; 01 1e 06   ; Next: $f1be
;
; Shared runtime-error shim (E = $06).
;
basic_raise_error_06: ld       e,$06                ; $f1bc 1e 06           ; 
             defb     $01                  ; $f1be 01 1e 17        ;   As: ld     bc,$171e   ; 01 1e 17   ; Next: $f1c1
;
; Shared runtime-error shim (E = $17).
;
basic_raise_error_17: ld       e,$17                ; $f1bf 1e 17           ; 
             defb     $01                  ; $f1c1 01 1e 1b        ;   As: ld     bc,$1b1e   ; 01 1e 1b   ; Next: $f1c4
;
; Shared runtime-error shim (E = $1b).
;
basic_raise_error_1b: ld       e,$1b                ; $f1c2 1e 1b           ; 
             defb     $01                  ; $f1c4 01 1e 0d        ;   As: ld     bc,$0d1e   ; 01 1e 0d   ; Next: $f1c7
;
; Shared runtime-error shim (E = $0d).
;
basic_raise_error_0d: ld       e,$0d                ; $f1c5 1e 0d           ; 
;
; Common runtime-error entry.  Expects E = BASIC error number,
; calls the RAM hook at $00ab, saves the current execution pointer
; ($01db) to $0315 for ERL / RESUME, then enters basic_error_dispatch.
;
basic_raise_error: call     call00ab             ; $f1c7 cd ab 00        ; 
             ld       hl,($01db)           ; $f1ca 2a db 01        ; 
             ld       ($0315),hl           ; $f1cd 22 15 03        ; 
;
; Close the current device, restore the BASIC stack from $0313
; through jumpd26a, and continue at basic_trap_or_abort.
;
basic_error_dispatch: ld       bc,basic_trap_or_abort ; $f1d0 01 dc f1        ; 
             ld       hl,($0313)           ; $f1d3 2a 13 03        ; 
             call     io_close_channel     ; $f1d6 cd 9e e8        ; 
             jp       jumpd26a             ; $f1d9 c3 6a d2        ; 

;
; Shared runtime-error continuation after jumpd26a.  Stores ERR to
; $00b1, preserves the failing statement pointers ($0315 / $0317),
; checks $0319 for an ON ERROR GOTO handler, and either vectors into
; that trap path or clears the trap state and prints the standard
; runtime-error banner before READY-mode restart.
;
basic_trap_or_abort: pop      bc                   ; $f1dc c1              ; 
             ld       a,e                  ; $f1dd 7b              ; 
             ld       c,e                  ; $f1de 4b              ; 
             ld       ($00b1),a            ; $f1df 32 b1 00        ; 
             ld       hl,($0311)           ; $f1e2 2a 11 03        ; 
             ld       ($0317),hl           ; $f1e5 22 17 03        ; 
             ex       de,hl                ; $f1e8 eb              ; 
             ld       hl,($0315)           ; $f1e9 2a 15 03        ; 
             ld       a,h                  ; $f1ec 7c              ; 
             and      a,l                  ; $f1ed a5              ; 
             inc      a                    ; $f1ee 3c              ; 
             jr       z,skipf1f8           ; $f1ef 28 07           ; 
             ld       ($031e),hl           ; $f1f1 22 1e 03        ; 
             ex       de,hl                ; $f1f4 eb              ; 
             ld       ($0320),hl           ; $f1f5 22 20 03        ; 
skipf1f8:    ld       hl,($0319)           ; $f1f8 2a 19 03        ; 
             ld       a,h                  ; $f1fb 7c              ; 
             or       a,l                  ; $f1fc b5              ; 
             ex       de,hl                ; $f1fd eb              ; 
             ld       hl,$031b             ; $f1fe 21 1b 03        ; 
             jr       z,basic_print_error_banner ; $f201 28 08           ; 
             and      a,(hl)               ; $f203 a6              ; 
             jr       nz,basic_print_error_banner ; $f204 20 05           ; 
             dec      (hl)                 ; $f206 35              ; 
             ex       de,hl                ; $f207 eb              ; 
             jp       basic_advance_to_next_line ; $f208 c3 e5 f4        ; 

;
; Common printer for runtime errors.  Clears shared trap state via
; $c0f4, clamps ERR to the packed mnemonic table at
; basic_error_code_table, prints the 2-character code plus
; basic_msg_error, then leaves the saved execution pointer available
; so the shared "... in <line>" formatter can append location data.
;
basic_print_error_banner: call     print_cursor_reset   ; $f20b cd f4 c0        ; 
             ld       e,c                  ; $f20e 59              ; 
             ld       a,e                  ; $f20f 7b              ; 
             cp       a,$1e                ; $f210 fe 1e           ; 
             jr       c,skipf216           ; $f212 38 02           ; 
             ld       e,$15                ; $f214 1e 15           ; 
skipf216:    ld       d,$00                ; $f216 16 00           ; 
             ld       hl,$f121             ; $f218 21 21 f1        ; 
             add      hl,de                ; $f21b 19              ; 
             add      hl,de                ; $f21c 19              ; 
             push     hl                   ; $f21d e5              ; 
             call     calle920             ; $f21e cd 20 e9        ; 
             call     cassette_clear_f4_transfer_bits ; $f221 cd cc e0        ; 
             pop      hl                   ; $f224 e1              ; 
             ld       a,(hl)               ; $f225 7e              ; 
             rst      rst0028              ; $f226 ef              ; 
             rst      rst0010              ; $f227 d7              ; 
             rst      rst0028              ; $f228 ef              ; 
             ld       hl,basic_msg_error   ; $f229 21 5d f1        ; 
             push     hl                   ; $f22c e5              ; 
             ld       hl,($0315)           ; $f22d 2a 15 03        ; 
             ex       (sp),hl              ; $f230 e3              ; 
;
; ----
; basic_break_ready — STOP/END break banner into READY mode
; ----
; Common restart entry after STOP or END once the CONT address has
; been saved. Prints the current break context when present, then
; falls into the interactive READY loop at $f23c.
;
basic_break_ready: call     print_prepare_string_item ; $f231 cd b1 d5        ; 
             pop      hl                   ; $f234 e1              ; 
             ld       a,h                  ; $f235 7c              ; 
             and      a,l                  ; $f236 a5              ; 
             inc      a                    ; $f237 3c              ; 
             call     nz,print_in_keyword  ; $f238 c4 90 bb        ; 
             defb     $3e                  ; $f23b 3e c1           ;   As: ld     a,$c1      ; 3e c1      ; Next: $f23d
;
; ----
; basic_command_loop — READY prompt and direct-mode loop
; ----
; Prints the READY prompt, clears run-state bookkeeping, reads one
; input line into the edit buffer at $00d5, parses an optional line
; number, tokenizes the text into the scratch area at $00d3, then
; either executes a direct command immediately or updates the stored
; program line with delete/insert and relink helpers below.
;
basic_command_loop: pop      bc                   ; $f23c c1              ; 
jumpf23d:    call     io_close_reset_and_crlf ; $f23d cd 1d e9        ; 
             ld       hl,$f169             ; $f240 21 69 f1        ; 
             call     print_prepare_string_item ; $f243 cd b1 d5        ; 
             call     reset_run_mode_for_ready ; $f246 cd bc f2        ; 
loopf249:    call     clear_exec_for_ready ; $f249 cd cc f2        ; 
             call     kbd_readline         ; $f24c cd ff eb        ; 
jumpf24f:    jr       c,loopf249           ; $f24f 38 f8           ; 
             rst      rst0010              ; $f251 d7              ; 
             inc      a                    ; $f252 3c              ; 
             dec      a                    ; $f253 3d              ; 
             jr       z,loopf249           ; $f254 28 f3           ; 
             push     af                   ; $f256 f5              ; 
             call     parse_line_number    ; $f257 cd 95 f5        ; 
loopf25a:    dec      hl                   ; $f25a 2b              ; 
             ld       a,(hl)               ; $f25b 7e              ; 
             cp       a,$20                ; $f25c fe 20           ; 
             jr       z,loopf25a           ; $f25e 28 fa           ; 
             inc      hl                   ; $f260 23              ; 
             ld       a,(hl)               ; $f261 7e              ; 
             cp       a,$20                ; $f262 fe 20           ; 
             call     z,callca40           ; $f264 cc 40 ca        ; 
             push     de                   ; $f267 d5              ; 
             call     basic_tokenize_line  ; $f268 cd 2a f3        ; 
             pop      de                   ; $f26b d1              ; 
             pop      af                   ; $f26c f1              ; 
             ld       ($0311),hl           ; $f26d 22 11 03        ; 
             jp       nc,skipf50f          ; $f270 d2 0f f5        ; 
             push     de                   ; $f273 d5              ; 
             push     bc                   ; $f274 c5              ; 
             xor      a,a                  ; $f275 af              ; 
             ld       ($030d),a            ; $f276 32 0d 03        ; 
             rst      rst0010              ; $f279 d7              ; 
             or       a,a                  ; $f27a b7              ; 
             push     af                   ; $f27b f5              ; 
             call     basic_find_line      ; $f27c cd 0d f3        ; 
             jr       c,basic_delete_found_line ; $f27f 38 06           ; 
             pop      af                   ; $f281 f1              ; 
             push     af                   ; $f282 f5              ; 
             jp       z,goto_line_not_found ; $f283 ca 38 f6        ; 
             or       a,a                  ; $f286 b7              ; 
;
; basic_delete_found_line — delete the old stored record before replace/erase
; Prepares the insertion point returned by basic_find_line and, when the target
; line already exists, calls basic_delete_line to close that record's gap first.
; The same path therefore handles replacement and "empty numbered line" deletion.
;
basic_delete_found_line: push     bc                   ; $f287 c5              ; 
             call     c,basic_delete_line  ; $f288 dc b5 ff        ; 
             pop      de                   ; $f28b d1              ; 
             pop      af                   ; $f28c f1              ; 
             push     de                   ; $f28d d5              ; 
             jr       z,basic_line_entry   ; $f28e 28 23           ; 
             pop      de                   ; $f290 d1              ; 
;
; basic_insert_line_record — allocate space and build one tokenized BASIC record
; Runs only when the edited line still contains tokenized text.  Uses the current
; end-of-program pointer at $0322 plus the record size returned by
; basic_finish_tokenize_line, opens a gap, updates $0322, seeds the record header,
; and copies the tokenized body from scratch buffer $00d3.
;
basic_insert_line_record: ld       hl,($0322)           ; $f291 2a 22 03        ; 
             ex       (sp),hl              ; $f294 e3              ; 
             pop      bc                   ; $f295 c1              ; 
             add      hl,bc                ; $f296 09              ; 
             push     hl                   ; $f297 e5              ; 
;
; basic_open_program_gap — shift the program tail upward to make room for a line
; Calls move_block_up_checked with the old end-of-program, new end-of-program,
; and insertion point so the trailing program text moves up far enough to admit
; the new line record without colliding with variable/string/stack space.
;
basic_open_program_gap: call     move_block_up_checked ; $f298 cd 6a d1        ; 
             pop      hl                   ; $f29b e1              ; 
             ld       ($0322),hl           ; $f29c 22 22 03        ; 
;
; basic_seed_line_record_header — write the provisional line header before relink
; Starts the new record in place: seeds the leading next-record field with a
; temporary non-zero value, restores the saved BASIC line number into bytes 2-3,
; and leaves the true next-line pointer to the later relink pass at $f2dd.
;
basic_seed_line_record_header: ex       de,hl                ; $f29f eb              ; 
             ld       (hl),h               ; $f2a0 74              ; 
             pop      de                   ; $f2a1 d1              ; 
             push     hl                   ; $f2a2 e5              ; 
             inc      hl                   ; $f2a3 23              ; 
             inc      hl                   ; $f2a4 23              ; 
             ld       (hl),e               ; $f2a5 73              ; 
             inc      hl                   ; $f2a6 23              ; 
             ld       (hl),d               ; $f2a7 72              ; 
             inc      hl                   ; $f2a8 23              ; 
             ld       de,$00d3             ; $f2a9 11 d3 00        ; 
;
; basic_copy_line_record_body — copy tokenized line bytes from the $00d3 scratch buffer
; Copies the tokenized body byte-for-byte into the newly opened record until the
; terminating $00 marker.  After this finishes, basic_line_entry relinks all
; next-line pointers and resets the runtime environment.
;
basic_copy_line_record_body: ld       a,(de)               ; $f2ac 1a              ; 
             ld       (hl),a               ; $f2ad 77              ; 
             inc      hl                   ; $f2ae 23              ; 
             inc      de                   ; $f2af 13              ; 
             or       a,a                  ; $f2b0 b7              ; 
             jr       nz,basic_copy_line_record_body ; $f2b1 20 f9           ; 
;
; ----
; basic_line_entry — commit edited line and restart parser state
; ----
; Shared tail after a line has been inserted, replaced, or deleted.
; Rebuilds line links, resets the RUN environment, and returns to
; the READY loop.
;
basic_line_entry: pop      de                   ; $f2b3 d1              ; 
             call     basic_relink_lines   ; $f2b4 cd dd f2        ; 
             call     run_env_reset        ; $f2b7 cd 2d d2        ; 
             jr       loopf249             ; $f2ba 18 8d           ; 

;
; ----
; reset_run_mode_for_ready — leave RUN mode for READY
; ----
; Clears $00b0 and restores the default program-start pointer at
; $00b2 when the interpreter returns from program execution to READY.
;
reset_run_mode_for_ready: ld       a,($00b0)            ; $f2bc 3a b0 00        ; 
             or       a,a                  ; $f2bf b7              ; 
             ret      z                    ; $f2c0 c8              ; 

             xor      a,a                  ; $f2c1 af              ; 
             ld       ($00b0),a            ; $f2c2 32 b0 00        ; 
             ld       hl,$0553             ; $f2c5 21 53 05        ; 
             ld       ($00b2),hl           ; $f2c8 22 b2 00        ; 
             ret                           ; $f2cb c9              ; 

;
; ----
; clear_exec_for_ready — mark interpreter as direct mode
; ----
; Stores $ffff to the execution pointer at $01db and resets the
; current-line slot at $0311 before the next READY-line input.
;
clear_exec_for_ready: ld       hl,$ffff             ; $f2cc 21 ff ff        ; 
             ld       ($01db),hl           ; $f2cf 22 db 01        ; 
             ld       hl,$001b             ; $f2d2 21 1b 00        ; 
             ld       ($0311),hl           ; $f2d5 22 11 03        ; 
             ret                           ; $f2d8 c9              ; 

;
; basic_relink_from_start — rebuild line links from program base
; Loads DE from the current BASIC program base pointer at $00b2, then
; falls into basic_relink_lines.  Used after line edits and by other
; program-walk paths that need to start from the first stored line.
;
basic_relink_from_start: ld       de,($00b2)           ; $f2d9 ed 5b b2 00     ; 
;
; basic_relink_lines — recompute next-line pointers through the program
; Walks each tokenized BASIC line in memory, scans forward to its
; terminating $00 byte, then writes the address of the following line
; back into the line header.  Stops when the leading next-line pointer
; is $0000, so this is the shared relink pass after insert/replace/delete.
;
basic_relink_lines: ld       h,d                  ; $f2dd 62              ; 
             ld       l,e                  ; $f2de 6b              ; 
             ld       a,(hl)               ; $f2df 7e              ; 
             inc      hl                   ; $f2e0 23              ; 
             or       a,(hl)               ; $f2e1 b6              ; 
             ret      z                    ; $f2e2 c8              ; 

             inc      hl                   ; $f2e3 23              ; 
             inc      hl                   ; $f2e4 23              ; 
             inc      hl                   ; $f2e5 23              ; 
             xor      a,a                  ; $f2e6 af              ; 
loopf2e7:    cp       a,(hl)               ; $f2e7 be              ; 
             inc      hl                   ; $f2e8 23              ; 
             jr       nz,loopf2e7          ; $f2e9 20 fc           ; 
             ex       de,hl                ; $f2eb eb              ; 
             ld       (hl),e               ; $f2ec 73              ; 
             inc      hl                   ; $f2ed 23              ; 
             ld       (hl),d               ; $f2ee 72              ; 
             jr       basic_relink_lines   ; $f2ef 18 ec           ; 

;
; basic_parse_line_range — parse LIST/LLIST start[-end] range
; Helper used by LIST and LLIST.  With no numeric argument it yields
; the default full-program range.  Otherwise it parses the first line
; number into DE, accepts an optional '-' range tail, parses the end
; line into BC, and rejects trailing junk.
;
basic_parse_line_range: ld       de,$0000             ; $f2f1 11 00 00        ; 
             push     de                   ; $f2f4 d5              ; 
             jr       z,skipf300           ; $f2f5 28 09           ; 
             pop      de                   ; $f2f7 d1              ; 
             call     parse_line_number    ; $f2f8 cd 95 f5        ; 
             push     de                   ; $f2fb d5              ; 
             jr       z,skipf309           ; $f2fc 28 0b           ; 
             rst      rst0008              ; $f2fe cf              ; 
             defb     $d2                  ; $f2ff d2 11 fa        ;   As: jp     nc,$fa11   ; d2 11 fa   ; Next: $f302
skipf300:    defb     $11                  ; $f300 11 fa ff        ;   As: ld     de,$fffa   ; 11 fa ff   ; Next: $f303
             defb     $fa                  ; $f301 fa              ; 
             rst      rst0038              ; $f302 ff              ; 
             call     nz,parse_line_number ; $f303 c4 95 f5        ; 
             jp       nz,basic_raise_error_02 ; $f306 c2 aa f1        ; 
skipf309:    ex       de,hl                ; $f309 eb              ; 
             pop      de                   ; $f30a d1              ; 
;
; basic_find_line_from_stack — stack-preserving entry to line search
; Exchanges HL with the top of stack, pushes the old HL back, then
; falls into basic_find_line.  Used by ON ERROR GOTO and similar paths
; that already carry one search operand on the stack.
;
basic_find_line_from_stack: ex       (sp),hl              ; $f30b e3              ; 
             push     hl                   ; $f30c e5              ; 
;
; basic_find_line — scan linked BASIC lines by line number
; Starts at the program base ($00b2), reads each line header, compares
; the stored line number against the requested DE value, and returns
; the current/next-line pointers in BC/HL with flags describing the
; search result.  This is the central lookup used for edit-time line
; replacement/deletion and for statement targets such as RESTORE or
; ON ERROR GOTO.
;
basic_find_line: ld       hl,($00b2)           ; $f30d 2a b2 00        ; 
callf310:    ld       b,h                  ; $f310 44              ; 
             ld       c,l                  ; $f311 4d              ; 
             ld       a,(hl)               ; $f312 7e              ; 
             inc      hl                   ; $f313 23              ; 
             or       a,(hl)               ; $f314 b6              ; 
             dec      hl                   ; $f315 2b              ; 
             ret      z                    ; $f316 c8              ; 

             inc      hl                   ; $f317 23              ; 
             inc      hl                   ; $f318 23              ; 
             ld       a,(hl)               ; $f319 7e              ; 
             inc      hl                   ; $f31a 23              ; 
             ld       h,(hl)               ; $f31b 66              ; 
             ld       l,a                  ; $f31c 6f              ; 
             rst      rst0020              ; $f31d e7              ; 
             ld       h,b                  ; $f31e 60              ; 
             ld       l,c                  ; $f31f 69              ; 
             ld       a,(hl)               ; $f320 7e              ; 
             inc      hl                   ; $f321 23              ; 
             ld       h,(hl)               ; $f322 66              ; 
             ld       l,a                  ; $f323 6f              ; 
             ccf                           ; $f324 3f              ; 
             ret      z                    ; $f325 c8              ; 

             ccf                           ; $f326 3f              ; 
             ret      nc                   ; $f327 d0              ; 

             jr       callf310             ; $f328 18 e6           ; 

;
; basic_tokenize_line — tokenize one edited BASIC source line
; Clears the tokenizer state byte at $01da, sets DE to the temporary
; output buffer at $00d3, then scans the ASCII line under HL.  The
; result is a tokenized line body terminated in the scratch buffer for
; later insertion into program memory or direct execution.
;
basic_tokenize_line: xor      a,a                  ; $f32a af              ; 
             ld       ($01da),a            ; $f32b 32 da 01        ; 
             ld       c,a                  ; $f32e 4f              ; 
             ld       de,$00d3             ; $f32f 11 d3 00        ; 
;
; basic_token_scan — main source-line scanner for the tokenizer
; Reads the next input character, skips spaces, detects quotes and end
; of line, preserves already-tokenized bytes (bit 7 set), and decides
; whether to copy a raw character or attempt keyword lookup.
;
basic_token_scan: ld       a,(hl)               ; $f332 7e              ; 
             cp       a,$20                ; $f333 fe 20           ; 
             jp       z,basic_emit_tokenized_byte ; $f335 ca c1 f3        ; 
             ld       b,a                  ; $f338 47              ; 
             cp       a,$22                ; $f339 fe 22           ; 
             jp       z,basic_copy_string_literal ; $f33b ca e1 f3        ; 
             or       a,a                  ; $f33e b7              ; 
             jp       z,basic_finish_tokenize_line ; $f33f ca e7 f3        ; 
             inc      hl                   ; $f342 23              ; 
             or       a,a                  ; $f343 b7              ; 
             jp       m,basic_token_scan   ; $f344 fa 32 f3        ; 
             dec      hl                   ; $f347 2b              ; 
             ld       a,($01da)            ; $f348 3a da 01        ; 
             or       a,a                  ; $f34b b7              ; 
             ld       a,(hl)               ; $f34c 7e              ; 
             jr       nz,basic_emit_tokenized_byte ; $f34d 20 72           ; 
             cp       a,$3f                ; $f34f fe 3f           ; 
             ld       a,$9f                ; $f351 3e 9f           ; 
             jr       z,basic_emit_tokenized_byte ; $f353 28 6c           ; 
             ld       a,(hl)               ; $f355 7e              ; 
             cp       a,$30                ; $f356 fe 30           ; 
             jr       c,basic_lookup_keyword ; $f358 38 04           ; 
             cp       a,$3c                ; $f35a fe 3c           ; 
             jr       c,basic_emit_tokenized_byte ; $f35c 38 63           ; 
;
; basic_lookup_keyword — case-fold and search keyword tables
; Uppercases ASCII a-z in the source stream, then scans the packed
; keyword table starting at $ee83 (continuing through ops_table) for a
; matching entry.  On success it emits the token byte for the keyword;
; otherwise it falls back to copying the source character literally.
;
basic_lookup_keyword: push     de                   ; $f35e d5              ; 
             ld       de,$ee82             ; $f35f 11 82 ee        ; 
             push     bc                   ; $f362 c5              ; 
             ld       bc,$f3a6             ; $f363 01 a6 f3        ; 
             push     bc                   ; $f366 c5              ; 
             ld       b,$7f                ; $f367 06 7f           ; 
             ld       a,(hl)               ; $f369 7e              ; 
             cp       a,$61                ; $f36a fe 61           ; 
             jr       c,loopf375           ; $f36c 38 07           ; 
             cp       a,$7b                ; $f36e fe 7b           ; 
             jr       nc,loopf375          ; $f370 30 03           ; 
             and      a,$5f                ; $f372 e6 5f           ; 
             ld       (hl),a               ; $f374 77              ; 
loopf375:    ld       c,(hl)               ; $f375 4e              ; 
             ex       de,hl                ; $f376 eb              ; 
loopf377:    inc      hl                   ; $f377 23              ; 
             or       a,(hl)               ; $f378 b6              ; 
             jp       p,loopf377           ; $f379 f2 77 f3        ; 
             inc      b                    ; $f37c 04              ; 
             ld       a,(hl)               ; $f37d 7e              ; 
             and      a,$7f                ; $f37e e6 7f           ; 
             ret      z                    ; $f380 c8              ; 

             cp       a,c                  ; $f381 b9              ; 
             jr       nz,loopf377          ; $f382 20 f3           ; 
             ex       de,hl                ; $f384 eb              ; 
             push     hl                   ; $f385 e5              ; 
loopf386:    inc      de                   ; $f386 13              ; 
             ld       a,(de)               ; $f387 1a              ; 
             or       a,a                  ; $f388 b7              ; 
             jp       m,jumpf3a2           ; $f389 fa a2 f3        ; 
             ld       c,a                  ; $f38c 4f              ; 
             ld       a,b                  ; $f38d 78              ; 
             cp       a,$88                ; $f38e fe 88           ; 
             jr       nz,skipf394          ; $f390 20 02           ; 
             rst      rst0010              ; $f392 d7              ; 
             dec      hl                   ; $f393 2b              ; 
skipf394:    inc      hl                   ; $f394 23              ; 
             ld       a,(hl)               ; $f395 7e              ; 
             cp       a,$61                ; $f396 fe 61           ; 
             jr       c,skipf39c           ; $f398 38 02           ; 
             and      a,$5f                ; $f39a e6 5f           ; 
skipf39c:    cp       a,c                  ; $f39c b9              ; 
             jr       z,loopf386           ; $f39d 28 e7           ; 
             pop      hl                   ; $f39f e1              ; 
             jr       loopf375             ; $f3a0 18 d3           ; 

jumpf3a2:    ld       c,b                  ; $f3a2 48              ; 
             pop      af                   ; $f3a3 f1              ; 
             ex       de,hl                ; $f3a4 eb              ; 
             ret                           ; $f3a5 c9              ; 

             defb     $eb,$79,$c1,$d1,$eb,$fe,$90,$36,$3a,$20      ; .y.....6:. ; 
             defb     $02,$0c,$23,$fe,$ff,$20,$09,$36,$3a,$23      ; ..#....6:# ; 
             defb     $06,$8e,$70,$23,$0c,$0c,$eb                  ; ..p#...    ; 
;
; basic_emit_tokenized_byte — append one byte to the tokenized line
; Stores A into the tokenizer output buffer at DE, advances DE, and
; bumps the byte count in C.  Shared by raw-character copies, emitted
; keyword tokens, and delimiter handling.
;
basic_emit_tokenized_byte: inc      hl                   ; $f3c1 23              ; 
             ld       (de),a               ; $f3c2 12              ; 
             inc      de                   ; $f3c3 13              ; 
             inc      c                    ; $f3c4 0c              ; 
             sub      a,$3a                ; $f3c5 d6 3a           ; 
             jr       z,skipf3cd           ; $f3c7 28 04           ; 
             cp       a,$49                ; $f3c9 fe 49           ; 
             jr       nz,skipf3d0          ; $f3cb 20 03           ; 
skipf3cd:    ld       ($01da),a            ; $f3cd 32 da 01        ; 
skipf3d0:    sub      a,$54                ; $f3d0 d6 54           ; 
             jr       z,skipf3d9           ; $f3d2 28 05           ; 
             sub      a,$71                ; $f3d4 d6 71           ; 
             jp       nz,basic_token_scan  ; $f3d6 c2 32 f3        ; 
skipf3d9:    ld       b,a                  ; $f3d9 47              ; 
loopf3da:    ld       a,(hl)               ; $f3da 7e              ; 
             or       a,a                  ; $f3db b7              ; 
             jr       z,basic_finish_tokenize_line ; $f3dc 28 09           ; 
             cp       a,b                  ; $f3de b8              ; 
             jr       z,basic_emit_tokenized_byte ; $f3df 28 e0           ; 
;
; basic_copy_string_literal — copy quoted text without token lookup
; Once a double quote has been seen, this loop copies successive bytes
; verbatim into the tokenized output until the closing quote or line
; end.  BASIC keywords inside string literals therefore remain plain
; text and are never tokenized.
;
basic_copy_string_literal: inc      hl                   ; $f3e1 23              ; 
             ld       (de),a               ; $f3e2 12              ; 
             inc      c                    ; $f3e3 0c              ; 
             inc      de                   ; $f3e4 13              ; 
             jr       loopf3da             ; $f3e5 18 f3           ; 

;
; basic_finish_tokenize_line — terminate scratch line and compute size
; Finalizes the temporary tokenized record by deriving the total line
; size in BC (5-byte stored-line header plus token bytes), then writes
; trailing zero bytes after the tokenized text in the $00d3 scratch area.
; The caller uses this record-size result to decide whether it must open
; a gap in program memory before storing the line.
;
basic_finish_tokenize_line: ld       hl,gpr_char_step     ; $f3e7 21 05 00        ; 
             ld       b,h                  ; $f3ea 44              ; 
             add      hl,bc                ; $f3eb 09              ; 
             ld       b,h                  ; $f3ec 44              ; 
             ld       c,l                  ; $f3ed 4d              ; 
             ld       hl,$00d2             ; $f3ee 21 d2 00        ; 
             ld       (de),a               ; $f3f1 12              ; 
             inc      de                   ; $f3f2 13              ; 
             ld       (de),a               ; $f3f3 12              ; 
             inc      de                   ; $f3f4 13              ; 
             ld       (de),a               ; $f3f5 12              ; 
             ret                           ; $f3f6 c9              ; 

;
; inst_for — FOR statement
; FOR var = start TO limit [STEP step]
; 1. Save $000B → $020E (FOR nesting counter? context byte).
; 2. Call inst_let to assign the start value to the loop variable
; (evaluates: var = start).
; 3. Skip to end-of-line (inst_data) to find the "body" start address;
; save it to $020A (start-of-loop-body pointer).
; 4. Scan the existing contiguous FOR frames on the CPU stack
; (for_find_previous_frame via ctrl_scan_for_frames_loop) to find a
; previous FOR with the same loop variable; if found, discard the old
; frame (SP = HL, update $0313).
; 5. Check stack space (C = $0C → 12 × 2 bytes minimum).
; 6. Build a FOR frame on the stack:
; - Push loop-body start address (from $020A).
; - Push $01DB (execution address, via EX (SP),HL).
; - RST $08 / $BB: require TO token.
; - RST $30: check device mode; error if not integer context.
; - Evaluate LIMIT expression (eval_expression).
; - Check for optional STEP token ($D0); if present: evaluate STEP.
; Otherwise default STEP = 1 (or −1 if float type).
; - Push: limit value, step value, variable address, marker $81.
; 7. If limit < initial value (STEP positive) or limit > initial value
; (STEP negative), skip the loop body entirely.
; 
; FOR statement.  Assigns loop variable = start (via inst_let).
; Saves loop-body address ($020A).  Discards any existing FOR frame
; for the same variable.  Pushes a 22-byte FOR frame: body address,
; return pointer, limit, step, variable address, marker $81.
; Skips loop body if start already satisfies the exit condition.
;
inst_for:    ld       a,($000b)            ; $f3f7 3a 0b 00        ; 
             ld       ($020e),a            ; $f3fa 32 0e 02        ; 
             call     inst_let             ; $f3fd cd 85 f6        ; 
             pop      bc                   ; $f400 c1              ; 
             push     hl                   ; $f401 e5              ; 
             call     inst_data            ; $f402 cd 64 f6        ; 
             ld       ($020a),hl           ; $f405 22 0a 02        ; 
             ld       hl,$0002             ; $f408 21 02 00        ; 
             add      hl,sp                ; $f40b 39              ; 
;
; Walk the active FOR records already on the CPU stack, looking for an older
; frame for the same loop variable and same loop-body address so it can be
; discarded before the new FOR frame is pushed.
;
for_find_previous_frame: call     ctrl_scan_for_frames_loop ; $f40c cd 76 f1        ; 
             jr       nz,for_push_frame    ; $f40f 20 15           ; 
             add      hl,bc                ; $f411 09              ; 
             push     de                   ; $f412 d5              ; 
             push     hl                   ; $f413 e5              ; 
             dec      hl                   ; $f414 2b              ; 
             ld       d,(hl)               ; $f415 56              ; 
             dec      hl                   ; $f416 2b              ; 
             ld       e,(hl)               ; $f417 5e              ; 
             ld       hl,($020a)           ; $f418 2a 0a 02        ; 
             rst      rst0020              ; $f41b e7              ; 
             pop      hl                   ; $f41c e1              ; 
             pop      de                   ; $f41d d1              ; 
             jr       nz,for_find_previous_frame ; $f41e 20 ec           ; 
             pop      de                   ; $f420 d1              ; 
             ld       sp,hl                ; $f421 f9              ; 
             ld       ($0313),hl           ; $f422 22 13 03        ; 
             defb     $0e                  ; $f425 0e d1           ;   As: ld     c,$d1      ; 0e d1      ; Next: $f427
;
; Start building a new FOR control record on the CPU stack: reserve space,
; save the loop-body resume address and current execution pointer, then parse
; TO / optional STEP before the limit/step values are packed into the frame.
;
for_push_frame: pop      de                   ; $f426 d1              ; 
             ex       de,hl                ; $f427 eb              ; 
             ld       c,$0c                ; $f428 0e 0c           ; 
             call     check_stack_space    ; $f42a cd 8b d1        ; 
             push     hl                   ; $f42d e5              ; 
             ld       hl,($020a)           ; $f42e 2a 0a 02        ; 
             ex       (sp),hl              ; $f431 e3              ; 
             push     hl                   ; $f432 e5              ; 
             ld       hl,($01db)           ; $f433 2a db 01        ; 
             ex       (sp),hl              ; $f436 e3              ; 
             rst      rst0008              ; $f437 cf              ; 
             cp       a,e                  ; $f438 bb              ; 
             rst      rst0030              ; $f439 f7              ; 
             jp       z,basic_raise_error_0d ; $f43a ca c5 f1        ; 
             push     af                   ; $f43d f5              ; 
             call     eval_expression      ; $f43e cd 2d f9        ; 
             pop      af                   ; $f441 f1              ; 
             push     hl                   ; $f442 e5              ; 
             jr       nc,for_build_double_frame ; $f443 30 18           ; 
             jp       p,for_build_single_frame ; $f445 f2 92 f4        ; 
             call     fn_cint              ; $f448 cd e0 ca        ; 
             ex       (sp),hl              ; $f44b e3              ; 
             ld       de,$0001             ; $f44c 11 01 00        ; 
             ld       a,(hl)               ; $f44f 7e              ; 
             cp       a,$d0                ; $f450 fe d0           ; 
             call     z,callfe50           ; $f452 cc 50 fe        ; 
             push     de                   ; $f455 d5              ; 
             push     hl                   ; $f456 e5              ; 
             ex       de,hl                ; $f457 eb              ; 
             call     callca05             ; $f458 cd 05 ca        ; 
             jr       skipf4b3             ; $f45b 18 56           ; 

;
; Floating-point FOR-frame builder for the double-precision path.
; Converts the limit to double, parses optional STEP, defaults STEP to
; +1 when omitted, packs the limit/step values on the control stack, and
; then rejoins the common FOR-frame finaliser at $f4ba.
;
for_build_double_frame: call     fn_cdbl              ; $f45d cd 90 cb        ; 
             pop      de                   ; $f460 d1              ; 
             ld       hl,$fff8             ; $f461 21 f8 ff        ; 
             add      hl,sp                ; $f464 39              ; 
             ld       sp,hl                ; $f465 f9              ; 
             push     de                   ; $f466 d5              ; 
             call     callca6a             ; $f467 cd 6a ca        ; 
             pop      hl                   ; $f46a e1              ; 
             ld       a,(hl)               ; $f46b 7e              ; 
             cp       a,$d0                ; $f46c fe d0           ; 
             ld       de,$b8cb             ; $f46e 11 cb b8        ; 
             ld       a,$01                ; $f471 3e 01           ; 
             jr       nz,skipf482          ; $f473 20 0d           ; 
             rst      rst0010              ; $f475 d7              ; 
             call     eval_expression      ; $f476 cd 2d f9        ; 
             push     hl                   ; $f479 e5              ; 
             call     fn_cdbl              ; $f47a cd 90 cb        ; 
             rst      rst0018              ; $f47d df              ; 
             ld       de,$044e             ; $f47e 11 4e 04        ; 
             pop      hl                   ; $f481 e1              ; 
skipf482:    ld       b,h                  ; $f482 44              ; 
             ld       c,l                  ; $f483 4d              ; 
             ld       hl,$fff8             ; $f484 21 f8 ff        ; 
             add      hl,sp                ; $f487 39              ; 
             ld       sp,hl                ; $f488 f9              ; 
             push     af                   ; $f489 f5              ; 
             push     bc                   ; $f48a c5              ; 
             call     callca4d             ; $f48b cd 4d ca        ; 
             pop      hl                   ; $f48e e1              ; 
             pop      af                   ; $f48f f1              ; 
             jr       skipf4ba             ; $f490 18 28           ; 

;
; Floating-point FOR-frame builder for the single-precision path.
; Converts the limit and optional STEP through fn_csng/callca26, then
; packs the single-precision control values before falling into the same
; shared FOR-frame finaliser used by the double-precision case.
;
for_build_single_frame: call     fn_csng              ; $f492 cd 08 cb        ; 
             call     callca26             ; $f495 cd 26 ca        ; 
             pop      hl                   ; $f498 e1              ; 
             push     bc                   ; $f499 c5              ; 
             push     de                   ; $f49a d5              ; 
             ld       bc,$1041             ; $f49b 01 41 10        ; 
             ld       de,$0000             ; $f49e 11 00 00        ; 
             ld       a,(hl)               ; $f4a1 7e              ; 
             cp       a,$d0                ; $f4a2 fe d0           ; 
             ld       a,$01                ; $f4a4 3e 01           ; 
             jr       nz,skipf4b4          ; $f4a6 20 0c           ; 
             call     callf92e             ; $f4a8 cd 2e f9        ; 
             push     hl                   ; $f4ab e5              ; 
             call     fn_csng              ; $f4ac cd 08 cb        ; 
             call     callca26             ; $f4af cd 26 ca        ; 
             rst      rst0018              ; $f4b2 df              ; 
skipf4b3:    pop      hl                   ; $f4b3 e1              ; 
skipf4b4:    push     de                   ; $f4b4 d5              ; 
             push     bc                   ; $f4b5 c5              ; 
             push     bc                   ; $f4b6 c5              ; 
             push     bc                   ; $f4b7 c5              ; 
             push     bc                   ; $f4b8 c5              ; 
             push     bc                   ; $f4b9 c5              ; 
skipf4ba:    or       a,a                  ; $f4ba b7              ; 
             jr       nz,skipf4bf          ; $f4bb 20 02           ; 
             ld       a,$02                ; $f4bd 3e 02           ; 
skipf4bf:    ld       c,a                  ; $f4bf 4f              ; 
             rst      rst0030              ; $f4c0 f7              ; 
             ld       b,a                  ; $f4c1 47              ; 
             push     bc                   ; $f4c2 c5              ; 
             push     hl                   ; $f4c3 e5              ; 
             ld       hl,($030f)           ; $f4c4 2a 0f 03        ; 
             ex       (sp),hl              ; $f4c7 e3              ; 
             dec      hl                   ; $f4c8 2b              ; 
             rst      rst0010              ; $f4c9 d7              ; 
             jp       nz,basic_raise_error_02 ; $f4ca c2 aa f1        ; 
;
; Final FOR-frame header push.  Stores marker $81 so NEXT can recognise the
; record as a FOR frame when scanning the control stack.
;
for_push_frame_tag: ld       b,$81                ; $f4cd 06 81           ; 
             push     bc                   ; $f4cf c5              ; 
             inc      sp                   ; $f4d0 33              ; 
;
; basic_exec_statement_loop — main BASIC statement dispatcher / re-entry loop
; Shared execution loop entered after RUN/GOTO/GOSUB/RETURN and most other
; control transfers.  Services Ctrl-C / I/O, updates $0311/$0313 with the
; current statement/stack state, advances to the next stored line when the
; current one ends, optionally emits trace brackets through the active
; trace channel, then dispatches ASCII text to LET or tokenised keywords
; through keyword_dispatch_table and the extension switch at $fe22.
;
basic_exec_statement_loop: call     ctrlc_io_service     ; $f4d1 cd 00 c0        ; 
             ld       ($0311),hl           ; $f4d4 22 11 03        ; 
             ld       ($0313),sp           ; $f4d7 ed 73 13 03     ; 
             ld       a,(hl)               ; $f4db 7e              ; 
             cp       a,$3a                ; $f4dc fe 3a           ; 
             jr       z,skipf50f           ; $f4de 28 2f           ; 
             or       a,a                  ; $f4e0 b7              ; 
             jp       nz,basic_raise_error_02 ; $f4e1 c2 aa f1        ; 
             inc      hl                   ; $f4e4 23              ; 
;
; basic_advance_to_next_line — load the next stored BASIC line for execution
; Follows the next-line link from the current stored line, raises the
; end-of-program path at $f191 when the link is zero, and stores the new
; execution pointer in $01db before rejoining the main dispatcher.
;
basic_advance_to_next_line: ld       a,(hl)               ; $f4e5 7e              ; 
             inc      hl                   ; $f4e6 23              ; 
             or       a,(hl)               ; $f4e7 b6              ; 
             jp       z,jumpf191           ; $f4e8 ca 91 f1        ; 
             inc      hl                   ; $f4eb 23              ; 
             ld       e,(hl)               ; $f4ec 5e              ; 
             inc      hl                   ; $f4ed 23              ; 
             ld       d,(hl)               ; $f4ee 56              ; 
             ex       de,hl                ; $f4ef eb              ; 
             ld       ($01db),hl           ; $f4f0 22 db 01        ; 
             ld       a,($041c)            ; $f4f3 3a 1c 04        ; 
             or       a,a                  ; $f4f6 b7              ; 
             jr       z,skipf50e           ; $f4f7 28 15           ; 
             push     de                   ; $f4f9 d5              ; 
             ld       de,($02c3)           ; $f4fa ed 5b c3 02     ; 
             call     io_open_channel      ; $f4fe cd 27 e8        ; 
             ld       a,$5b                ; $f501 3e 5b           ; 
             rst      rst0028              ; $f503 ef              ; 
             call     print_uint16_decimal ; $f504 cd 98 bb        ; 
             ld       a,$5d                ; $f507 3e 5d           ; 
             rst      rst0028              ; $f509 ef              ; 
             call     io_close_channel     ; $f50a cd 9e e8        ; 
             pop      de                   ; $f50d d1              ; 
skipf50e:    ex       de,hl                ; $f50e eb              ; 
skipf50f:    rst      rst0010              ; $f50f d7              ; 
             ld       de,basic_exec_statement_loop ; $f510 11 d1 f4        ; 
             push     de                   ; $f513 d5              ; 
jumpf514:    ret      z                    ; $f514 c8              ; 

;
; basic_dispatch_statement_token — dispatch one current statement token
; ASCII-leading statements fall through to inst_let; token values in the
; main keyword range are indexed through keyword_dispatch_table; higher
; extension tokens are sent to the secondary dispatcher at $fe22.
;
basic_dispatch_statement_token: sub      a,$80                ; $f515 d6 80           ; 
             jp       c,inst_let           ; $f517 da 85 f6        ; 
             cp       a,$3a                ; $f51a fe 3a           ; 
             jp       nc,keyword_extension_dispatch ; $f51c d2 22 fe        ; 
             rlca                          ; $f51f 07              ; 
             ld       c,a                  ; $f520 4f              ; 
             ld       b,$00                ; $f521 06 00           ; 
             ex       de,hl                ; $f523 eb              ; 
             ld       hl,keyword_dispatch_table ; $f524 21 76 f0        ; 
             add      hl,bc                ; $f527 09              ; 
             ld       c,(hl)               ; $f528 4e              ; 
             inc      hl                   ; $f529 23              ; 
             ld       b,(hl)               ; $f52a 46              ; 
             push     bc                   ; $f52b c5              ; 
             ex       de,hl                ; $f52c eb              ; 
             jr       rst10_fetch_token    ; $f52d 18 08           ; 

;
; RST $08 handler — match expected token in the text stream.
; Reads the literal byte immediately following the RST $08 instruction
; in the caller's code stream, and compares it against the current
; character at (HL) (the text/input pointer).
; If they match: falls through into rst10_fetch_token, which advances
; HL and returns the next non-whitespace character.
; If they do not match: jumps to the syntax error handler at jumpf1aa.
; The literal parameter byte is consumed so execution resumes two bytes
; past the RST $08 instruction regardless.
;
rst08_match_token: ld       a,(hl)               ; $f52f 7e              ; 
             ex       (sp),hl              ; $f530 e3              ; 
             cp       a,(hl)               ; $f531 be              ; 
             inc      hl                   ; $f532 23              ; 
             ex       (sp),hl              ; $f533 e3              ; 
             jp       nz,basic_raise_error_02 ; $f534 c2 aa f1        ; 
;
; RST $10 handler — advance text pointer and return next non-whitespace
; character.
; Increments HL and returns the character at (HL) in A, skipping over
; space ($20) and horizontal/vertical tab ($09–$0A).
; Returns carry set if the character is a digit ($30–$39).
; Returns carry clear (NC) immediately for characters $3A (':') and
; above (statement separators, tokenised keywords with bit 7 set).
; Used throughout the BASIC parser and input routines to advance through
; the text stream.
;
rst10_fetch_token: inc      hl                   ; $f537 23              ; 
             ld       a,(hl)               ; $f538 7e              ; 
             cp       a,$3a                ; $f539 fe 3a           ; 
             ret      nc                   ; $f53b d0              ; 

             cp       a,$20                ; $f53c fe 20           ; 
             jr       z,rst10_fetch_token  ; $f53e 28 f7           ; 
             cp       a,$0b                ; $f540 fe 0b           ; 
             jr       nc,skipf548          ; $f542 30 04           ; 
             cp       a,$09                ; $f544 fe 09           ; 
             jr       nc,rst10_fetch_token ; $f546 30 ef           ; 
skipf548:    cp       a,$30                ; $f548 fe 30           ; 
             ccf                           ; $f54a 3f              ; 
             inc      a                    ; $f54b 3c              ; 
             dec      a                    ; $f54c 3d              ; 
             ret                           ; $f54d c9              ; 

;
; inst_defstr / defint / defsng / defdbl — DEFtype statements
; DEFtype letter[-letter][, ...]
; Sets the default type for variables whose names begin with the given
; letter(s).  The four handlers set E = type code:
; DEFSTR → E = 3 (string)
; DEFINT → E = 2 (integer)
; DEFSNG → E = 4 (single-precision)
; DEFDBL → E = 8 (double-precision)
; Shared loop (loopf559): read variable letter from token stream (calld2fd);
; compute index = letter − 'A'; check for a range `-` ($D2 = `-` token);
; fill the DEFTYPE table at $032A[index] = E for each letter in range.
; 
; DEFSTR statement — set default type to string (E=$03) for
; variables starting with the listed letters.
;
inst_defstr: ld       e,$03                ; $f54e 1e 03           ; 
             defb     $01                  ; $f550 01 1e 02        ;   As: ld     bc,$021e   ; 01 1e 02   ; Next: $f553
;
; DEFINT statement — set default type to integer (E=$02).
;
inst_defint: ld       e,$02                ; $f551 1e 02           ; 
             defb     $01                  ; $f553 01 1e 04        ;   As: ld     bc,$041e   ; 01 1e 04   ; Next: $f556
;
; DEFSNG statement — set default type to single-precision (E=$04).
;
inst_defsng: ld       e,$04                ; $f554 1e 04           ; 
             defb     $01                  ; $f556 01 1e 08        ;   As: ld     bc,$081e   ; 01 1e 08   ; Next: $f559
;
; DEFDBL statement — set default type to double-precision (E=$08).
;
inst_defdbl: ld       e,$08                ; $f557 1e 08           ; 
;
; Shared DEFtype loop.  Read letter (calld2fd), compute index
; into DEFTYPE table ($032A).  Handle letter-range (hyphen token
; $D2).  Store E in each entry in the range.
;
deftype_loop: call     calld2fd             ; $f559 cd fd d2        ; 
             ld       bc,basic_raise_error_02 ; $f55c 01 aa f1        ; 
             push     bc                   ; $f55f c5              ; 
             ret      c                    ; $f560 d8              ; 

             sub      a,$41                ; $f561 d6 41           ; 
             ld       c,a                  ; $f563 4f              ; 
             ld       b,a                  ; $f564 47              ; 
             rst      rst0010              ; $f565 d7              ; 
             cp       a,$d2                ; $f566 fe d2           ; 
             jr       nz,skipf573          ; $f568 20 09           ; 
             rst      rst0010              ; $f56a d7              ; 
             call     calld2fd             ; $f56b cd fd d2        ; 
             ret      c                    ; $f56e d8              ; 

             sub      a,$41                ; $f56f d6 41           ; 
             ld       b,a                  ; $f571 47              ; 
             rst      rst0010              ; $f572 d7              ; 
skipf573:    ld       a,b                  ; $f573 78              ; 
             sub      a,c                  ; $f574 91              ; 
             ret      c                    ; $f575 d8              ; 

             inc      a                    ; $f576 3c              ; 
             ex       (sp),hl              ; $f577 e3              ; 
             ld       hl,$032a             ; $f578 21 2a 03        ; 
             ld       b,$00                ; $f57b 06 00           ; 
             add      hl,bc                ; $f57d 09              ; 
loopf57e:    ld       (hl),e               ; $f57e 73              ; 
             inc      hl                   ; $f57f 23              ; 
             dec      a                    ; $f580 3d              ; 
             jr       nz,loopf57e          ; $f581 20 fb           ; 
             pop      hl                   ; $f583 e1              ; 
             ld       a,(hl)               ; $f584 7e              ; 
             cp       a,$2c                ; $f585 fe 2c           ; 
             ret      nz                   ; $f587 c0              ; 

             rst      rst0010              ; $f588 d7              ; 
             jr       deftype_loop         ; $f589 18 ce           ; 

callf58b:    rst      rst0010              ; $f58b d7              ; 
callf58c:    call     eval_expr_to_int16   ; $f58c cd 51 fe        ; 
             ret      p                    ; $f58f f0              ; 

jumpf590:    ld       e,$05                ; $f590 1e 05           ; 
             jp       basic_raise_error    ; $f592 c3 c7 f1        ; 

;
; ---------------------------------------------------------------------------
; callf595 — parse ASCII line number from token stream into DE
; ---------------------------------------------------------------------------
; On entry: HL points to the first digit of an ASCII line number.
; Uses repeated multiply-by-10 plus digit accumulation.
; Returns DE = 16-bit line number, HL advanced past the last digit.
; 
; Parse a decimal line-number string from the token stream.
; Consumes digit characters; returns DE = integer value.
;
parse_line_number: dec      hl                   ; $f595 2b              ; 
callf596:    ld       de,$0000             ; $f596 11 00 00        ; 
loopf599:    rst      rst0010              ; $f599 d7              ; 
             ret      nc                   ; $f59a d0              ; 

             push     hl                   ; $f59b e5              ; 
             push     af                   ; $f59c f5              ; 
             ld       hl,$1998             ; $f59d 21 98 19        ; 
             rst      rst0020              ; $f5a0 e7              ; 
             jr       c,skipf5b4           ; $f5a1 38 11           ; 
             ld       h,d                  ; $f5a3 62              ; 
             ld       l,e                  ; $f5a4 6b              ; 
             add      hl,de                ; $f5a5 19              ; 
             add      hl,hl                ; $f5a6 29              ; 
             add      hl,de                ; $f5a7 19              ; 
             add      hl,hl                ; $f5a8 29              ; 
             pop      af                   ; $f5a9 f1              ; 
             sub      a,$30                ; $f5aa d6 30           ; 
             ld       e,a                  ; $f5ac 5f              ; 
             ld       d,$00                ; $f5ad 16 00           ; 
             add      hl,de                ; $f5af 19              ; 
             ex       de,hl                ; $f5b0 eb              ; 
             pop      hl                   ; $f5b1 e1              ; 
             jr       loopf599             ; $f5b2 18 e5           ; 

skipf5b4:    pop      af                   ; $f5b4 f1              ; 
             pop      hl                   ; $f5b5 e1              ; 
             ret                           ; $f5b6 c9              ; 

;
; inst_run — RUN statement
; RUN [line | filename]
; Without argument (Z set on entry): jump to run_env_reset — re-run the
; currently loaded program from the beginning.
; With a string argument: evaluate it, parse the device / file through
; fs_parse_device + fs_init_setup, initialise the descriptor block at
; $02ED, reload the run-mode pointers from the file header at $02EF,
; relink BASIC from the new start, then jump to run_env_reset.
; With a non-string argument: fall into the shared runtime-reset tail at
; $f607, which reuses the normal dispatcher/GOTO plumbing.
; 
; RUN statement.  No argument: restart the current program.
; Numeric argument: start execution at the specified line number.
; String argument: load and run the named file from cassette/storage.
;
inst_run:    jp       z,run_env_reset      ; $f5b7 ca 2d d2        ; 
             push     hl                   ; $f5ba e5              ; 
             call     eval_expression      ; $f5bb cd 2d f9        ; 
             rst      rst0030              ; $f5be f7              ; 
             jr       nz,run_reset_and_reenter ; $f5bf 20 46           ; 
             call     str_eval_string_arg  ; $f5c1 cd 01 d7        ; 
             pop      hl                   ; $f5c4 e1              ; 
             push     hl                   ; $f5c5 e5              ; 
             call     fs_parse_device      ; $f5c6 cd fa e6        ; 
             call     fs_parse_second      ; $f5c9 cd 1f e7        ; 
             ld       a,b                  ; $f5cc 78              ; 
             or       a,a                  ; $f5cd b7              ; 
             jr       z,skipf5d4           ; $f5ce 28 04           ; 
             cp       a,$50                ; $f5d0 fe 50           ; 
             jr       nz,skipf5e7          ; $f5d2 20 13           ; 
skipf5d4:    ld       a,$50                ; $f5d4 3e 50           ; 
             ld       b,a                  ; $f5d6 47              ; 
             call     fs_init_setup        ; $f5d7 cd d1 e6        ; 
             inc      de                   ; $f5da 13              ; 
             ld       a,(de)               ; $f5db 1a              ; 
             dec      de                   ; $f5dc 1b              ; 
             cp       a,$07                ; $f5dd fe 07           ; 
             jr       z,skipf5ea           ; $f5df 28 09           ; 
             cp       a,$08                ; $f5e1 fe 08           ; 
             jr       z,skipf5ea           ; $f5e3 28 05           ; 
             cp       a,$09                ; $f5e5 fe 09           ; 
skipf5e7:    jp       nz,basic_raise_error_17 ; $f5e7 c2 bf f1        ; 
skipf5ea:    ld       iy,$02ed             ; $f5ea fd 21 ed 02     ; 
             ld       ix,$0000             ; $f5ee dd 21 00 00     ; 
             call     io_init_descriptor_xora ; $f5f2 cd a7 e6        ; 
             ld       a,$0f                ; $f5f5 3e 0f           ; 
             ld       ($00b0),a            ; $f5f7 32 b0 00        ; 
             ld       hl,($02ef)           ; $f5fa 2a ef 02        ; 
             ld       ($00b2),hl           ; $f5fd 22 b2 00        ; 
             call     basic_relink_from_start ; $f600 cd d9 f2        ; 
             pop      hl                   ; $f603 e1              ; 
             jp       run_env_reset        ; $f604 c3 2d d2        ; 

;
; run_reset_and_reenter — shared RUN tail for non-string entry modes
; Restores HL, calls ctrl_reset_runtime_state, installs jumpf4d1 as the
; continuation address, then reuses gosub_push_return_frame so execution
; resumes through the normal statement-dispatch loop.
;
run_reset_and_reenter: pop      hl                   ; $f607 e1              ; 
             call     ctrl_reset_runtime_state ; $f608 cd 31 d2        ; 
             ld       bc,basic_exec_statement_loop ; $f60b 01 d1 f4        ; 
             jr       gosub_push_return_frame ; $f60e 18 10           ; 

;
; ---------------------------------------------------------------------------
; inst_goto / inst_gosub / inst_return — control flow
; ---------------------------------------------------------------------------
; inst_goto ($F621):
; Calls callf595 to parse the destination line number from the token
; stream (ASCII digits → DE).  Calls inst_rem/inst_data to skip to end
; of line.  Pushes the current HL (execution address).  Calls RST $20
; (rst20_cmp_hl_de) to compare current position with target.  Then calls
; callf310 or callf30d (forward/backward line search) to find the target
; line.  Loads HL = BC − 1 and returns; the interpreter will fetch the
; first token of the new line.  If the line is not found: jumpf638 → error
; $08 "Undefined line".
; 
; inst_gosub ($F610):
; Before doing the GOTO: checks there is enough stack for 3×22 bytes
; (C=3 to calld18b).  Pops the return BC (BC = caller's context).
; Builds a GOSUB frame on the stack: pushes HL (twice), saves $01DB
; (return execution address) via EX (SP),HL, pushes marker $8C, then
; INC SP (skips one padding byte), pushes BC.  Then falls into inst_goto.
; 
; inst_return ($F63D):
; Guard: RET NZ (not in run mode).
; Calls ctrl_scan_for_frames with D=$FF so the scan stops at the first
; non-FOR control record.  Restores SP from HL.  Checks frame marker:
; if not $8C, error $03
; "RETURN without GOSUB".  Pops the saved return execution address into
; $01DB.  If $01DB == $FFFF (no live program): check $030D; if non-zero,
; jump to warm-restart, otherwise continue.  Otherwise pushes
; jumpf4d1 (the "execute next statement" re-entry) and returns into
; the normal main loop.
; 
; GOSUB statement.  Checks stack space (C=3 × 22 bytes).
; Builds a GOSUB frame on the stack: saves return address ($01DB)
; with marker $8C, then falls into inst_goto to jump to the target.
;
inst_gosub:  ld       c,$03                ; $f610 0e 03           ; 
             call     check_stack_space    ; $f612 cd 8b d1        ; 
             pop      bc                   ; $f615 c1              ; 
             push     hl                   ; $f616 e5              ; 
             push     hl                   ; $f617 e5              ; 
             ld       hl,($01db)           ; $f618 2a db 01        ; 
             ex       (sp),hl              ; $f61b e3              ; 
             ld       a,$8c                ; $f61c 3e 8c           ; 
             push     af                   ; $f61e f5              ; 
             inc      sp                   ; $f61f 33              ; 
;
; Shared tail used by GOSUB and ON ... GOSUB after the $8C marker byte has
; been prepared.  Pushes the caller continuation address, then falls straight
; into inst_goto to parse the destination line number.
;
gosub_push_return_frame: push     bc                   ; $f620 c5              ; 
;
; GOTO statement.  Parses target line number (→ DE).  Skips rest
; of current line.  Calls RST $20 (HL vs DE compare) for direction,
; then forward ($F310) or backward ($F30D) line-search.
; Error $08 if target line not found.
;
inst_goto:   call     parse_line_number    ; $f621 cd 95 f5        ; 
callf624:    call     inst_rem             ; $f624 cd 66 f6        ; 
             inc      hl                   ; $f627 23              ; 
             push     hl                   ; $f628 e5              ; 
             ld       hl,($01db)           ; $f629 2a db 01        ; 
             rst      rst0020              ; $f62c e7              ; 
             pop      hl                   ; $f62d e1              ; 
             call     c,callf310           ; $f62e dc 10 f3        ; 
             call     nc,basic_find_line   ; $f631 d4 0d f3        ; 
             ld       h,b                  ; $f634 60              ; 
             ld       l,c                  ; $f635 69              ; 
             dec      hl                   ; $f636 2b              ; 
             ret      c                    ; $f637 d8              ; 

;
; GOTO/GOSUB line-number not found — jump to error $08 (Undefined
; line number).
;
goto_line_not_found: ld       e,$08                ; $f638 1e 08           ; 
             jp       basic_raise_error    ; $f63a c3 c7 f1        ; 

;
; RETURN statement.  Guard: RET NZ.
; Uses ctrl_scan_for_frames to stop at the topmost non-FOR control record,
; which must be a GOSUB frame tagged $8C.
; Restores SP, pops saved return execution address into $01DB.
; Error $03 if matching GOSUB frame not found.
;
inst_return: ret      nz                   ; $f63d c0              ; 

             ld       d,$ff                ; $f63e 16 ff           ; 
             call     ctrl_scan_for_frames ; $f640 cd 72 f1        ; 
             ld       sp,hl                ; $f643 f9              ; 
             ld       ($0313),hl           ; $f644 22 13 03        ; 
;
; RETURN verifier: after restoring SP, require the top control-record tag
; byte to be $8C before popping the saved return address.
;
return_require_gosub_frame: cp       a,$8c                ; $f647 fe 8c           ; 
             ld       e,$03                ; $f649 1e 03           ; 
             jp       nz,basic_raise_error ; $f64b c2 c7 f1        ; 
             pop      hl                   ; $f64e e1              ; 
             ld       ($01db),hl           ; $f64f 22 db 01        ; 
             inc      hl                   ; $f652 23              ; 
             ld       a,h                  ; $f653 7c              ; 
             or       a,l                  ; $f654 b5              ; 
             jr       nz,return_resume_dispatch ; $f655 20 07           ; 
             ld       a,($030d)            ; $f657 3a 0d 03        ; 
             or       a,a                  ; $f65a b7              ; 
             jp       nz,basic_command_loop ; $f65b c2 3c f2        ; 
;
; RETURN continuation hook.  Re-enters the normal statement dispatcher by
; planting jumpf4d1 on the stack unless RETURN reached direct mode / command
; loop cleanup.
;
return_resume_dispatch: ld       hl,basic_exec_statement_loop ; $f65e 21 d1 f4        ; 
             ex       (sp),hl              ; $f661 e3              ; 
             defb     $3e                  ; $f662 3e e1           ;   As: ld     a,$e1      ; 3e e1      ; Next: $f664
jumpf663:    pop      hl                   ; $f663 e1              ; 
;
; inst_rem / inst_data — shared skip-to-end-of-line / skip-to-colon
; These two labels sit at overlapping entry points in a single scanner:
; 
; inst_data ($F664): entry byte $01 followed by $3A — the LD BC,nn opcode
; absorbs these bytes.  Effective start: C = $3A (`:` = statement
; separator), B = $0E (next byte = REM token).
; Scans forward in HL looking for null ($00) or C ($3A) delimiter.
; 
; inst_rem ($F666): entry byte $0E — LD C,$00 opcode.  C = $00, B = $00.
; Scans forward until null byte ($00) only (end-of-line); i.e. skips the
; entire rest of the line including `:` sub-statements.
; 
; Both share the scan loop starting at loopf668:
; Skip until A = 0 (end of line) or A = B or A = C (delimiter found).
; Handles string literals correctly (toggle on `"`).
; When A = $8A (`:REM` sub-statement marker), treat rest as comment.
; 
; DATA / skip-to-colon scanner.  Scans HL forward until `:` ($3A)
; or null ($00).  Used by IF (skip to ELSE), FOR (find body), etc.
; Entry: C = $3A (look for colon), B = $0E (REM short-circuit).
;
inst_data:   defb     $01                  ; $f664 01 3a 0e        ;   As: ld     bc,$0e3a   ; 01 3a 0e   ; Next: $f667
             defb     $3a                  ; $f665 3a              ; 
;
; REM / skip-to-end-of-line scanner (also ELSE handler).
; Scans HL forward until null byte ($00) only.
; Shares scan loop with inst_data but C = B = $00 (no colon stop).
;
inst_rem:    defb     $0e                  ; $f666 0e 00           ;   As: ld     c,$00      ; 0e 00      ; Next: $f668
             nop                           ; $f667 00              ; 
             ld       b,$00                ; $f668 06 00           ; 
loopf66a:    ld       a,c                  ; $f66a 79              ; 
             ld       c,b                  ; $f66b 48              ; 
             ld       b,a                  ; $f66c 47              ; 
loopf66d:    ld       a,(hl)               ; $f66d 7e              ; 
             or       a,a                  ; $f66e b7              ; 
             ret      z                    ; $f66f c8              ; 

             cp       a,b                  ; $f670 b8              ; 
             ret      z                    ; $f671 c8              ; 

             inc      hl                   ; $f672 23              ; 
             cp       a,$22                ; $f673 fe 22           ; 
             jr       z,loopf66a           ; $f675 28 f3           ; 
             sub      a,$8a                ; $f677 d6 8a           ; 
             jr       nz,loopf66d          ; $f679 20 f2           ; 
             cp       a,b                  ; $f67b b8              ; 
             adc      a,d                  ; $f67c 8a              ; 
             ld       d,a                  ; $f67d 57              ; 
             jr       loopf66d             ; $f67e 18 ed           ; 

             defb     $f1,$c6,$03,$18,$12                          ; .....      ; 
;
; ---------------------------------------------------------------------------
; inst_let — LET statement
; ---------------------------------------------------------------------------
; LET varname = expression
; 1. callb00a: look up or create the variable; returns DE = variable address,
; type byte returned in A and stored in $01D9.
; 2. RST $08 / $DD: verifies the `=` operator token in the stream.
; 3. Saves DE (variable address) to $030F and on stack.
; 4. Saves current type ($01D9) on stack.
; 5. eval_expression: evaluate the right-hand side.
; 6. jumpf697 (shared with READ/INPUT assignment):
; Compare stored type (B) with result type ($01D9).
; If types differ: call callfdef to coerce/convert the value.
; Determine target channel:
; type=2 → $044E (string channel), type=3 → $0450.
; For type=3 (double): complex assignment involving array/string
; address resolution through $01D9/$0326/$01DF/$0200/$01E2.
; Finally: call callca4d to write the value into the variable.
; 
; LET statement.  Look up/create variable (callb00a → DE = address,
; A = type).  Verify `=` token (RST $08 / $DD).  Evaluate
; right-hand-side expression (eval_expression).  Coerce result type
; if needed (callfdef), then store result into the variable via callca4d.
;
inst_let:    call     lookup_or_create_var ; $f685 cd 0a b0        ; 
             rst      rst0008              ; $f688 cf              ; 
             defb     $dd                                          ; .          ; 
             ld       ($030f),de           ; $f68a ed 53 0f 03     ; 
             push     de                   ; $f68e d5              ; 
             ld       a,($01d9)            ; $f68f 3a d9 01        ; 
             push     af                   ; $f692 f5              ; 
             call     eval_expression      ; $f693 cd 2d f9        ; 
             pop      af                   ; $f696 f1              ; 
;
; Shared assignment finalisation for LET, READ and INPUT.
; B = target type (from stack), $01D9 = result type.
; Coerce if B ≠ $01D9 (callfdef).  Dispatch on type to write
; value into the variable at DE.
;
assign_result_to_var: ex       (sp),hl              ; $f697 e3              ; 
jumpf698:    ld       b,a                  ; $f698 47              ; 
             ld       a,($01d9)            ; $f699 3a d9 01        ; 
             cp       a,b                  ; $f69c b8              ; 
             ld       a,b                  ; $f69d 78              ; 
             jr       z,skipf6a6           ; $f69e 28 06           ; 
             call     coerce_result_to_type ; $f6a0 cd ef fd        ; 
;
; assign_dispatch_by_result_type — choose the active accumulator block for
; variable assignment
; Re-reads the current result type from $01d9, selects $044e or $0450 as
; the source descriptor / accumulator block, handles the temporary-string
; cleanup needed by string assignments, then drops into callca4d to store
; the final value into the destination variable.
;
assign_dispatch_by_result_type: ld       a,($01d9)            ; $f6a3 3a d9 01        ; 
skipf6a6:    ld       de,$044e             ; $f6a6 11 4e 04        ; 
             cp       a,$02                ; $f6a9 fe 02           ; 
             jr       nz,skipf6b0          ; $f6ab 20 03           ; 
             ld       de,$0450             ; $f6ad 11 50 04        ; 
skipf6b0:    push     hl                   ; $f6b0 e5              ; 
             cp       a,$03                ; $f6b1 fe 03           ; 
             jr       nz,skipf6eb          ; $f6b3 20 36           ; 
             ld       hl,($0450)           ; $f6b5 2a 50 04        ; 
             push     hl                   ; $f6b8 e5              ; 
             inc      hl                   ; $f6b9 23              ; 
             ld       e,(hl)               ; $f6ba 5e              ; 
             inc      hl                   ; $f6bb 23              ; 
             ld       d,(hl)               ; $f6bc 56              ; 
             ld       hl,$01d9             ; $f6bd 21 d9 01        ; 
             rst      rst0020              ; $f6c0 e7              ; 
             jr       nc,skipf6dd          ; $f6c1 30 1a           ; 
             ld       hl,($0326)           ; $f6c3 2a 26 03        ; 
             rst      rst0020              ; $f6c6 e7              ; 
             jr       nc,skipf6e6          ; $f6c7 30 1d           ; 
             ld       hl,($01df)           ; $f6c9 2a df 01        ; 
             rst      rst0020              ; $f6cc e7              ; 
             pop      de                   ; $f6cd d1              ; 
             jr       c,skipf6e7           ; $f6ce 38 17           ; 
             ld       hl,$0200             ; $f6d0 21 00 02        ; 
             rst      rst0020              ; $f6d3 e7              ; 
             jr       c,skipf6dc           ; $f6d4 38 06           ; 
             ld       hl,$01e2             ; $f6d6 21 e2 01        ; 
             rst      rst0020              ; $f6d9 e7              ; 
             jr       c,skipf6e7           ; $f6da 38 0b           ; 
skipf6dc:    defb     $3e                  ; $f6dc 3e d1           ;   As: ld     a,$d1      ; 3e d1      ; Next: $f6de
skipf6dd:    pop      de                   ; $f6dd d1              ; 
             call     str_pop_temp_descriptor_if_top ; $f6de cd 1f d7        ; 
             ex       de,hl                ; $f6e1 eb              ; 
             call     calld54a             ; $f6e2 cd 4a d5        ; 
             defb     $3e                  ; $f6e5 3e d1           ;   As: ld     a,$d1      ; 3e d1      ; Next: $f6e7
skipf6e6:    pop      de                   ; $f6e6 d1              ; 
skipf6e7:    call     str_pop_temp_descriptor_if_top ; $f6e7 cd 1f d7        ; 
             ex       (sp),hl              ; $f6ea e3              ; 
skipf6eb:    call     callca4d             ; $f6eb cd 4d ca        ; 
             pop      de                   ; $f6ee d1              ; 
             pop      hl                   ; $f6ef e1              ; 
             ret                           ; $f6f0 c9              ; 

;
; inst_on — ON statement (ON GOTO / ON GOSUB / ON ERROR)
; ON ERROR GOTO line:  token $98 (ERROR) detected; parse target line
; number into DE; if DE = 0: clear error handler ($0319 = 0).
; Otherwise: find the line (callf30b), save it to $0319 (error handler
; address).  If currently in run mode and there is an active error
; ($031B ≠ 0), immediately trigger an error dispatch via $F1D0.
; 
; ON expr GOTO/GOSUB line[,line,...]:
; Evaluate expression via callfe5e → integer in E (1-based index).
; Expect GOTO ($88) or GOSUB ($8C) token.
; Loop: scan the line-number list, decrementing E for each comma.
; When E reaches 0, execute the GOTO or GOSUB to that line number.
; If E > number of entries: fall through (do nothing) per BASIC standard.
; 
; ON statement.
; ON ERROR GOTO: register error handler address at $0319.
; ON expr GOTO/GOSUB: branch to the N-th listed line number
; (1-based).  Falls through if N exceeds the list length.
;
inst_on:     cp       a,$98                ; $f6f1 fe 98           ; 
             jr       nz,on_expr_branch    ; $f6f3 20 25           ; 
             rst      rst0010              ; $f6f5 d7              ; 
             rst      rst0008              ; $f6f6 cf              ; 
             adc      a,b                  ; $f6f7 88              ; 
             call     parse_line_number    ; $f6f8 cd 95 f5        ; 
             ld       a,d                  ; $f6fb 7a              ; 
             or       a,e                  ; $f6fc b3              ; 
             jr       z,on_error_goto_set  ; $f6fd 28 09           ; 
             call     basic_find_line_from_stack ; $f6ff cd 0b f3        ; 
             ld       d,b                  ; $f702 50              ; 
             ld       e,c                  ; $f703 59              ; 
             pop      hl                   ; $f704 e1              ; 
             jp       nc,goto_line_not_found ; $f705 d2 38 f6        ; 
;
; Store error-handler line address → $0319.  If in run mode and
; $031B ≠ 0 (pending error), redirect to error dispatch ($F1D0).
;
on_error_goto_set: ld       ($0319),de           ; $f708 ed 53 19 03     ; 
             ret      c                    ; $f70c d8              ; 

             ld       a,($031b)            ; $f70d 3a 1b 03        ; 
             or       a,a                  ; $f710 b7              ; 
             ld       a,e                  ; $f711 7b              ; 
             ret      z                    ; $f712 c8              ; 

             ld       a,($00b1)            ; $f713 3a b1 00        ; 
             ld       e,a                  ; $f716 5f              ; 
             jp       basic_error_dispatch ; $f717 c3 d0 f1        ; 

;
; ON expr GOTO/GOSUB: evaluate index (callfe5e → E), skip GOTO/
; GOSUB token, walk comma-delimited line-number list decrementing
; E.  At E=0: execute the jump.
;
on_expr_branch: call     eval_expr_to_int8    ; $f71a cd 5e fe        ; 
             ld       a,(hl)               ; $f71d 7e              ; 
             ld       b,a                  ; $f71e 47              ; 
             cp       a,$8c                ; $f71f fe 8c           ; 
             jr       z,skipf726           ; $f721 28 03           ; 
             rst      rst0008              ; $f723 cf              ; 
             adc      a,b                  ; $f724 88              ; 
             dec      hl                   ; $f725 2b              ; 
skipf726:    ld       c,e                  ; $f726 4b              ; 
loopf727:    dec      c                    ; $f727 0d              ; 
             ld       a,b                  ; $f728 78              ; 
             jp       z,basic_dispatch_statement_token ; $f729 ca 15 f5        ; 
             call     callf596             ; $f72c cd 96 f5        ; 
             cp       a,$2c                ; $f72f fe 2c           ; 
             ret      nz                   ; $f731 c0              ; 

             jr       loopf727             ; $f732 18 f3           ; 

;
; inst_resume — RESUME statement
; RESUME [0 | NEXT | line]
; Used inside an ON ERROR handler to resume after an error.
; $031B = 0 → no active error: error $1A ("RESUME without error").
; Set $00B1 = $031B + 1 (error-resume mode flag).
; NEXT token ($82) → resume at the statement after the one that errored
; (skipf75c path, carries flag in SCF).
; Line number → parse and search for the line; clear $031B and jump there.
; No argument (or 0) → resume at the statement that caused the error:
; restore $01DB from $0315 (saved execution pointer at error time).
; If $01DB points to a line with zero next-pointer: skip to the following
; statement.  Finally clear $031B and jump to the statement.
; 
; RESUME statement.  Error if no active error ($031B = 0).
; RESUME: re-execute the erroring statement ($0315).
; RESUME NEXT: resume at the statement after the error ($0317).
; RESUME line: jump to the given line number.
;
inst_resume: ld       a,($031b)            ; $f734 3a 1b 03        ; 
             or       a,a                  ; $f737 b7              ; 
             jr       nz,skipf743          ; $f738 20 09           ; 
             ld       ($0319),a            ; $f73a 32 19 03        ; 
             ld       ($031a),a            ; $f73d 32 1a 03        ; 
             jp       basic_raise_error_14 ; $f740 c3 b9 f1        ; 

skipf743:    inc      a                    ; $f743 3c              ; 
             ld       ($00b1),a            ; $f744 32 b1 00        ; 
             ld       a,(hl)               ; $f747 7e              ; 
             cp       a,$82                ; $f748 fe 82           ; 
             jr       z,skipf75c           ; $f74a 28 10           ; 
             call     parse_line_number    ; $f74c cd 95 f5        ; 
             ret      nz                   ; $f74f c0              ; 

             ld       a,d                  ; $f750 7a              ; 
             or       a,e                  ; $f751 b3              ; 
             jr       z,skipf760           ; $f752 28 0c           ; 
             call     callf624             ; $f754 cd 24 f6        ; 
             xor      a,a                  ; $f757 af              ; 
             ld       ($031b),a            ; $f758 32 1b 03        ; 
             ret                           ; $f75b c9              ; 

skipf75c:    rst      rst0010              ; $f75c d7              ; 
             ret      nz                   ; $f75d c0              ; 

             xor      a,a                  ; $f75e af              ; 
             scf                           ; $f75f 37              ; 
skipf760:    ld       ($031b),a            ; $f760 32 1b 03        ; 
             ld       hl,($0317)           ; $f763 2a 17 03        ; 
             ex       de,hl                ; $f766 eb              ; 
             ld       hl,($0315)           ; $f767 2a 15 03        ; 
             ld       ($01db),hl           ; $f76a 22 db 01        ; 
             ex       de,hl                ; $f76d eb              ; 
             ret      nc                   ; $f76e d0              ; 

             ld       a,(hl)               ; $f76f 7e              ; 
             or       a,a                  ; $f770 b7              ; 
             jr       nz,skipf777          ; $f771 20 04           ; 
             inc      hl                   ; $f773 23              ; 
             inc      hl                   ; $f774 23              ; 
             inc      hl                   ; $f775 23              ; 
             inc      hl                   ; $f776 23              ; 
skipf777:    inc      hl                   ; $f777 23              ; 
             ld       a,d                  ; $f778 7a              ; 
             and      a,e                  ; $f779 a3              ; 
             inc      a                    ; $f77a 3c              ; 
             jp       nz,inst_data         ; $f77b c2 64 f6        ; 
             ld       a,($030d)            ; $f77e 3a 0d 03        ; 
             dec      a                    ; $f781 3d              ; 
             jp       z,stop_cleanup       ; $f782 ca ca d2        ; 
             xor      a,a                  ; $f785 af              ; 
             ld       ($031b),a            ; $f786 32 1b 03        ; 
             jp       inst_data            ; $f789 c3 64 f6        ; 

;
; inst_error — ERROR statement
; ERROR expr
; Trigger a user-defined error with a given error code.
; callfe5e evaluates the expression → signed integer in E (= error code).
; RET NZ: guard — error if not in run mode and E = 0.
; E = 0 → error $F590 ("Illegal function call").
; Otherwise: jump to error dispatch $F1C7 with E = error code.
; 
; ERROR statement.  Evaluate error number (callfe5e → E).
; E = 0: error "Illegal function call".
; Otherwise: trigger run-time error E via $F1C7.
;
inst_error:  call     eval_expr_to_int8    ; $f78c cd 5e fe        ; 
             ret      nz                   ; $f78f c0              ; 

             or       a,a                  ; $f790 b7              ; 
             jp       z,jumpf590           ; $f791 ca 90 f5        ; 
             jp       basic_raise_error    ; $f794 c3 c7 f1        ; 

;
; ---------------------------------------------------------------------------
; inst_if — IF statement
; ---------------------------------------------------------------------------
; Evaluates the expression after IF (via eval_expression).
; Checks for optional comma after the expression (some BASIC dialects).
; Expects GOTO ($88) or THEN ($CE) token:
; - GOTO token: falls directly into inst_goto.
; - THEN token: RST $08 checks for $CE literal; the byte after THEN can
; be a line number (token stream numeric) or a statement.
; If the expression result is non-zero (true): RST $10 + inst_goto handles
; the jump, or execution continues past THEN normally.
; If false (zero): scan forward to find the matching ELSE token ($90).
; The scan loop (loopf7b7) calls inst_data (skip-to-colon) and watches
; for $90 (ELSE), honouring nested IF depth (D counter).  When ELSE is
; found, execution resumes there.
; 
; IF statement.  Evaluate the condition expression (eval_expression).
; Check for comma (optional) then require GOTO ($88) or THEN ($CE).
; If condition is non-zero (true): advance past THEN and continue
; execution (RST $10 and jp inst_goto for GOTO form).
; If condition is zero (false): scan forward for ELSE ($90), honouring
; nested IF depth (D counter); resume at ELSE clause if found,
; otherwise skip to end of statement.
;
inst_if:     call     eval_expression      ; $f797 cd 2d f9        ; 
             ld       a,(hl)               ; $f79a 7e              ; 
             cp       a,$2c                ; $f79b fe 2c           ; 
             call     z,rst10_fetch_token  ; $f79d cc 37 f5        ; 
             cp       a,$88                ; $f7a0 fe 88           ; 
             jr       z,skipf7a7           ; $f7a2 28 03           ; 
             rst      rst0008              ; $f7a4 cf              ; 
             adc      a,$2b                ; $f7a5 ce 2b           ; 
skipf7a7:    push     hl                   ; $f7a7 e5              ; 
             call     callc9fb             ; $f7a8 cd fb c9        ; 
             pop      hl                   ; $f7ab e1              ; 
             jr       z,if_false_scan_else ; $f7ac 28 07           ; 
loopf7ae:    rst      rst0010              ; $f7ae d7              ; 
             jp       c,inst_goto          ; $f7af da 21 f6        ; 
             jp       jumpf514             ; $f7b2 c3 14 f5        ; 

;
; IF condition was false: scan the token stream for ELSE ($90).
; D = nesting depth counter.  inst_data skip-to-colon at each `:`.
; When ELSE found at D=0, resume execution there.
;
if_false_scan_else: ld       d,$01                ; $f7b5 16 01           ; 
loopf7b7:    call     inst_data            ; $f7b7 cd 64 f6        ; 
             or       a,a                  ; $f7ba b7              ; 
             ret      z                    ; $f7bb c8              ; 

             rst      rst0010              ; $f7bc d7              ; 
             cp       a,$90                ; $f7bd fe 90           ; 
             jr       nz,loopf7b7          ; $f7bf 20 f6           ; 
             dec      d                    ; $f7c1 15              ; 
             jr       nz,loopf7b7          ; $f7c2 20 f3           ; 
             jr       loopf7ae             ; $f7c4 18 e8           ; 

;
; inst_line — LINE INPUT statement
; LINE INPUT [#channel,] ["prompt";] var$
; Checks that the next token is $84 (INPUT); if not, dispatches via $0096
; (RST vector — used for LINE graphics command which is handled elsewhere).
; guard_direct_mode_only: error if in direct mode.
; Advance HL; RST $10; open I/O channel (calle81c).
; callf83c: check if next char is `"` → read and print optional prompt string.
; lookup_or_create_var: resolve target string variable → DE.
; callcbae: allocate string storage.
; Read line: if channel ($003B) non-zero: calle8a7 (read from device);
; otherwise: callebff (read from keyboard/stdin).
; calld571: copy input buffer to string variable.
; assign_result_to_var ($F697) with type=3 (string).
; 
; LINE INPUT statement.  Reads an entire line (no tokenisation) into
; a string variable.  Supports optional #channel and "prompt"; string.
; Uses calle8a7 (device) or callebff (keyboard) to read input.
;
inst_line:   cp       a,$84                ; $f7c6 fe 84           ; 
             jp       nz,jump0096          ; $f7c8 c2 96 00        ; 
             call     guard_direct_mode_only ; $f7cb cd 08 fe        ; 
             ld       a,(hl)               ; $f7ce 7e              ; 
             rst      rst0010              ; $f7cf d7              ; 
             call     fs_dir_open          ; $f7d0 cd 1c e8        ; 
             dec      hl                   ; $f7d3 2b              ; 
             rst      rst0010              ; $f7d4 d7              ; 
             call     callf83c             ; $f7d5 cd 3c f8        ; 
             call     lookup_or_create_var ; $f7d8 cd 0a b0        ; 
             call     str_require_string   ; $f7db cd ae cb        ; 
             push     de                   ; $f7de d5              ; 
             push     hl                   ; $f7df e5              ; 
             ld       a,($003b)            ; $f7e0 3a 3b 00        ; 
             and      a,a                  ; $f7e3 a7              ; 
             jr       z,skipf7eb           ; $f7e4 28 05           ; 
             call     device_read_line     ; $f7e6 cd a7 e8        ; 
             jr       skipf7ee             ; $f7e9 18 03           ; 

skipf7eb:    call     kbd_readline         ; $f7eb cd ff eb        ; 
skipf7ee:    pop      de                   ; $f7ee d1              ; 
             pop      bc                   ; $f7ef c1              ; 
             jp       c,stop_cleanup       ; $f7f0 da ca d2        ; 
             call     io_close_channel     ; $f7f3 cd 9e e8        ; 
             push     bc                   ; $f7f6 c5              ; 
             push     de                   ; $f7f7 d5              ; 
             ld       b,$00                ; $f7f8 06 00           ; 
             call     calld571             ; $f7fa cd 71 d5        ; 
             pop      hl                   ; $f7fd e1              ; 
             ld       a,$03                ; $f7fe 3e 03           ; 
             jp       assign_result_to_var ; $f800 c3 97 f6        ; 

             defm     "?Redo from start"                                        ;
             defb     $0d,$0a,$00,$3a,$0e,$03,$b7,$c2,$a4,$f1      ; ...:...... ; 
             defb     $3a,$3b,$00,$a7,$c2,$c5,$f1,$c1,$21,$03      ; :;......!. ; 
             defb     $f8,$cd,$b1,$d5,$2a,$11,$03,$c9              ; ....*...   ; 
;
; inst_input — INPUT statement
; INPUT [#channel,] ["prompt";] var[,var...]
; guard_direct_mode_only: allowed only inside a running program.
; calle81c: open/select I/O channel; RST $10 to advance.
; Push return address $F84C (variable assignment loop in defb block).
; callf83c: check for optional prompt string starting with `"`.
; Variable assignment loop (embedded at $F84C):
; Read channel flag ($003B); if set: calle8a7 (device input).
; Otherwise: callebf2 (keyboard readline).
; Abort if error (jp c,stop_cleanup).
; For each comma-separated variable: lookup_or_create_var → DE;
; if var$ (string type): set next-ptr; else parse numeric token at HL.
; Assign value to each variable via jumpf698.
; 
; INPUT statement.  Reads user input into one or more variables.
; Supports optional #channel and "prompt"; string.
; Uses callebf2 (keyboard) or calle8a7 (device) for raw input,
; then assigns parsed values to each variable via jumpf698.
;
inst_input:  call     guard_direct_mode_only ; $f82f cd 08 fe        ; 
             ld       a,(hl)               ; $f832 7e              ; 
             call     fs_dir_open          ; $f833 cd 1c e8        ; 
             dec      hl                   ; $f836 2b              ; 
             rst      rst0010              ; $f837 d7              ; 
             ld       bc,$f84c             ; $f838 01 4c f8        ; 
             push     bc                   ; $f83b c5              ; 
callf83c:    cp       a,$22                ; $f83c fe 22           ; 
             ld       a,$00                ; $f83e 3e 00           ; 
             ret      nz                   ; $f840 c0              ; 

             call     calld56f             ; $f841 cd 6f d5        ; 
             rst      rst0008              ; $f844 cf              ; 
             dec      sp                   ; $f845 3b              ; 
             push     hl                   ; $f846 e5              ; 
             call     print_emit_string_item ; $f847 cd b4 d5        ; 
             pop      hl                   ; $f84a e1              ; 
             ret                           ; $f84b c9              ; 

             defb     $e5,$3a,$3b,$00,$a7,$28,$05,$cd,$a7,$e8      ; .:;..(.... ; 
             defb     $18,$03,$cd,$f2,$eb,$c1,$da,$ca,$d2,$23      ; .........# ; 
             defb     $7e,$b7,$2b,$c5,$ca,$63,$f6,$36,$2c,$18      ; ~.+..c.6,. ; 
             defb     $05                                          ; .          ; 
;
; inst_read — READ statement
; READ var[, var...]
; 1. Save HL (current token pointer) and load $0328 (DATA pointer) into HL.
; 2. Set $030E = OR with $AF (marks "currently reading DATA").
; 3. Loop per variable: callb00a → resolve variable (DE = address, type).
; 4. At the DATA pointer position: check for `,` (move to next DATA item).
; If pointer exhausted ($030E ≠ 0 after scan): print `?` prompt and ask
; for input (direct mode fallback via callebf2) or error $04
; ("Out of DATA").
; 5. For string variables: read up to the next `,` or end-of-DATA-line.
; For numeric variables: evaluate the DATA item token as an expression
; and store via jumpf698 (assign_result_to_var).
; 6. Update $0328 to the current DATA position.
; 7. Comma after variable name: loop for next variable.
; 
; READ statement.  Reads values from DATA statements ($0328
; tracks position).  For each variable: read next item, coerce
; type if needed, and store.  Error $04 if no more DATA.
;
inst_read:   push     hl                   ; $f86b e5              ; 
             ld       hl,($0328)           ; $f86c 2a 28 03        ; 
             or       a,$af                ; $f86f f6 af           ; 
             ld       ($030e),a            ; $f871 32 0e 03        ; 
             ex       (sp),hl              ; $f874 e3              ; 
             ld       bc,$2ccf             ; $f875 01 cf 2c        ; 
             call     lookup_or_create_var ; $f878 cd 0a b0        ; 
             ex       (sp),hl              ; $f87b e3              ; 
             push     de                   ; $f87c d5              ; 
             ld       a,(hl)               ; $f87d 7e              ; 
             cp       a,$2c                ; $f87e fe 2c           ; 
             jr       z,read_parse_data_item ; $f880 28 24           ; 
             ld       a,($030e)            ; $f882 3a 0e 03        ; 
             or       a,a                  ; $f885 b7              ; 
             jp       nz,read_seek_next_data_statement ; $f886 c2 09 f9        ; 
             ld       a,($003b)            ; $f889 3a 3b 00        ; 
             and      a,a                  ; $f88c a7              ; 
             ld       e,$04                ; $f88d 1e 04           ; 
             jp       nz,basic_raise_error ; $f88f c2 c7 f1        ; 
             ld       a,$3f                ; $f892 3e 3f           ; 
             rst      rst0028              ; $f894 ef              ; 
             call     kbd_readline_prompt  ; $f895 cd f2 eb        ; 
             pop      de                   ; $f898 d1              ; 
             pop      bc                   ; $f899 c1              ; 
             jp       c,stop_cleanup       ; $f89a da ca d2        ; 
             inc      hl                   ; $f89d 23              ; 
             ld       a,(hl)               ; $f89e 7e              ; 
             dec      hl                   ; $f89f 2b              ; 
             or       a,a                  ; $f8a0 b7              ; 
             push     bc                   ; $f8a1 c5              ; 
             jp       z,jumpf663           ; $f8a2 ca 63 f6        ; 
             push     de                   ; $f8a5 d5              ; 
;
; Shared READ-item parser / converter.  Starting at the current DATA text
; pointer, distinguishes numeric versus string items, parses the payload
; accordingly, then tail-calls assign_result_to_var so the converted value
; is stored into the variable descriptor saved by READ.
;
read_parse_data_item: rst      rst0030              ; $f8a6 f7              ; 
             push     af                   ; $f8a7 f5              ; 
             jr       nz,read_parse_numeric_item ; $f8a8 20 22           ; 
             rst      rst0010              ; $f8aa d7              ; 
             ld       d,a                  ; $f8ab 57              ; 
             ld       b,a                  ; $f8ac 47              ; 
             cp       a,$22                ; $f8ad fe 22           ; 
             jr       z,read_parse_string_item ; $f8af 28 0c           ; 
             ld       a,($030e)            ; $f8b1 3a 0e 03        ; 
             or       a,a                  ; $f8b4 b7              ; 
             ld       d,a                  ; $f8b5 57              ; 
             jr       z,skipf8ba           ; $f8b6 28 02           ; 
             ld       d,$3a                ; $f8b8 16 3a           ; 
skipf8ba:    ld       b,$2c                ; $f8ba 06 2c           ; 
             dec      hl                   ; $f8bc 2b              ; 
;
; READ string-item path.  Uses the shared quoted/literal scanner at
; $d572 to measure/copy characters up to the active delimiter, then
; packages the result as a BASIC string before rejoining the assignment
; tail.
;
read_parse_string_item: call     calld572             ; $f8bd cd 72 d5        ; 
             pop      af                   ; $f8c0 f1              ; 
             add      a,$03                ; $f8c1 c6 03           ; 
             ex       de,hl                ; $f8c3 eb              ; 
             ld       hl,read_post_assign_tail ; $f8c4 21 d4 f8        ; 
             ex       (sp),hl              ; $f8c7 e3              ; 
             push     de                   ; $f8c8 d5              ; 
             jp       jumpf698             ; $f8c9 c3 98 f6        ; 

;
; READ numeric-item path.  Advances to the first byte of the DATA field,
; installs the common post-parse return at $f8c0, and jumps into the
; numeric-literal parser so integer / single / double constants are read
; exactly like normal source literals.
;
read_parse_numeric_item: rst      rst0010              ; $f8cc d7              ; 
             ld       bc,$f8c0             ; $f8cd 01 c0 f8        ; 
             push     bc                   ; $f8d0 c5              ; 
             jp       parse_numeric_literal ; $f8d1 c3 21 ba        ; 

;
; Shared READ / INPUT post-assignment tail.  Rechecks the remaining
; variable/input separators after assign_result_to_var returns, updates
; the saved READ / DATA state, closes the temporary input channel when
; needed, and prints the `?Extra ignored` warning if surplus console
; input remains after the variable list has been satisfied.
;
read_post_assign_tail: defb     $2b,$d7,$28,$05,$fe,$2c,$c2,$16,$f8,$e3      ; +.(..,.... ; 
             defb     $2b,$d7,$20,$94,$d1,$3a,$0e,$03,$b7,$eb      ; +....:.... ; 
             defb     $c2,$ab,$d2,$d5,$cd,$9e,$e8,$b6,$21,$f8      ; ........!. ; 
             defb     $f8,$c4,$b1,$d5,$e1,$c9                      ; ......     ; 
;
; Prompt string `?Extra ignored` used when fallback console input supplies
; more comma-separated values than the current READ / INPUT assignment
; list consumes.
;
read_msg_extra_ignored: defm     "?Extra ignored"                                          ;
             defb     $0d,$0a,$00                                  ; ...        ; 
;
; READ out-of-data recovery path.  Scans forward with inst_data until the
; next DATA statement token ($83), validates that a payload is present,
; stores the new DATA pointer in $020c, and then jumps back into the
; shared READ-item parser at $f8a6.
;
read_seek_next_data_statement: call     inst_data            ; $f909 cd 64 f6        ; 
             or       a,a                  ; $f90c b7              ; 
             jr       nz,skipf920          ; $f90d 20 11           ; 
             inc      hl                   ; $f90f 23              ; 
             ld       a,(hl)               ; $f910 7e              ; 
             inc      hl                   ; $f911 23              ; 
             or       a,(hl)               ; $f912 b6              ; 
             ld       e,$04                ; $f913 1e 04           ; 
             jp       z,basic_raise_error  ; $f915 ca c7 f1        ; 
             inc      hl                   ; $f918 23              ; 
             ld       e,(hl)               ; $f919 5e              ; 
             inc      hl                   ; $f91a 23              ; 
             ld       d,(hl)               ; $f91b 56              ; 
             ld       ($020c),de           ; $f91c ed 53 0c 02     ; 
skipf920:    rst      rst0010              ; $f920 d7              ; 
             cp       a,$83                ; $f921 fe 83           ; 
             jr       nz,read_seek_next_data_statement ; $f923 20 e4           ; 
             jp       read_parse_data_item ; $f925 c3 a6 f8        ; 

;
; Small parser helper: `RST $08 ; defb $dd`.  Requires the tokenised `=`
; separator used by FN-related syntax and nearby parser helpers.
;
expr_require_equals: rst      rst0008              ; $f928 cf              ; 
             defb     $dd                                          ; .          ; 
             defb     $01                  ; $f92a 01 cf 28        ;   As: ld     bc,$28cf   ; 01 cf 28   ; Next: $f92d
;
; Small parser helper: `RST $08 ; defb $28`.  Requires an opening `(` and
; returns with HL positioned for the following expression parse.
;
expr_require_open_paren: rst      rst0008              ; $f92b cf              ; 
             defb     $28                  ; $f92c 28 2b           ;   As: jr     z,$f959    ; 28 2b      ; Next: $f92e
;
; ---------------------------------------------------------------------------
; callf92d — expression evaluator
; ---------------------------------------------------------------------------
; Evaluate one expression from the token stream (HL points one byte before
; the first token).  Result is left in the floating-point accumulator.
; Also sets $01D9 = type of the result.  HL advances past the expression.
; 
; Core structure:
; • expr_parse_primary reads one atom / unary form.
; • expr_operator_loop then performs precedence climbing using
; expr_precedence_table.
; • Relation tokens (`<`, `=`, `>`) are collapsed into a compare-mask
; before the RHS is parsed.
; • expr_apply_operator promotes integer/single/double operands as
; needed, then dispatches to the integer or FP operator tables.
; 
; BASIC expression evaluator entry point.  HL points one before
; the first expression token.  Result → float accumulator; type
; (2/3/4/8) → $01D9.  HL advanced past expression.
;
eval_expression: dec      hl                   ; $f92d 2b              ; 
callf92e:    ld       d,$00                ; $f92e 16 00           ; 
;
; Shared recursive entry.  D carries the minimum binding power
; required for the caller.  Saves that threshold, parses one primary
; term, then resumes in expr_operator_loop.
;
expr_recurse_with_precedence: push     de                   ; $f930 d5              ; 
             ld       c,$01                ; $f931 0e 01           ; 
             call     check_stack_space    ; $f933 cd 8b d1        ; 
             call     expr_parse_primary   ; $f936 cd 88 fa        ; 
             ld       ($031c),hl           ; $f939 22 1c 03        ; 
;
; Main precedence-climbing loop.  Peek the next token, stop if it is
; not an infix operator, otherwise compare its precedence against the
; saved threshold and recurse for the right-hand side when required.
;
expr_operator_loop: ld       hl,($031c)           ; $f93c 2a 1c 03        ; 
             pop      bc                   ; $f93f c1              ; 
             ld       a,(hl)               ; $f940 7e              ; 
             ld       ($0206),hl           ; $f941 22 06 02        ; 
             cp       a,$d1                ; $f944 fe d1           ; 
             ret      c                    ; $f946 d8              ; 

             cp       a,$df                ; $f947 fe df           ; 
             ret      nc                   ; $f949 d0              ; 

             cp       a,$dc                ; $f94a fe dc           ; 
             jr       nc,expr_parse_comparison_chain ; $f94c 30 59           ; 
             sub      a,$d1                ; $f94e d6 d1           ; 
             ld       e,a                  ; $f950 5f              ; 
             jr       nz,skipf95c          ; $f951 20 09           ; 
             ld       a,($01d9)            ; $f953 3a d9 01        ; 
             cp       a,$03                ; $f956 fe 03           ; 
             ld       a,e                  ; $f958 7b              ; 
             jp       z,expr_concat_strings ; $f959 ca b9 d6        ; 
skipf95c:    ld       hl,expr_precedence_table ; $f95c 21 ea f0        ; 
             ld       d,$00                ; $f95f 16 00           ; 
             add      hl,de                ; $f961 19              ; 
             ld       a,b                  ; $f962 78              ; 
             ld       d,(hl)               ; $f963 56              ; 
             cp       a,d                  ; $f964 ba              ; 
             ret      nc                   ; $f965 d0              ; 

             push     bc                   ; $f966 c5              ; 
             ld       bc,expr_operator_loop ; $f967 01 3c f9        ; 
             push     bc                   ; $f96a c5              ; 
             ld       a,d                  ; $f96b 7a              ; 
             cp       a,$51                ; $f96c fe 51           ; 
             jr       c,skipf9c0           ; $f96e 38 50           ; 
             and      a,$fe                ; $f970 e6 fe           ; 
             cp       a,$7a                ; $f972 fe 7a           ; 
             jr       z,skipf9c0           ; $f974 28 4a           ; 
loopf976:    ld       hl,$0450             ; $f976 21 50 04        ; 
             ld       a,($01d9)            ; $f979 3a d9 01        ; 
             sub      a,$03                ; $f97c d6 03           ; 
             jp       z,basic_raise_error_0d ; $f97e ca c5 f1        ; 
             or       a,a                  ; $f981 b7              ; 
             ld       hl,($0450)           ; $f982 2a 50 04        ; 
             push     hl                   ; $f985 e5              ; 
             jp       m,jumpf998           ; $f986 fa 98 f9        ; 
             ld       hl,($044e)           ; $f989 2a 4e 04        ; 
             push     hl                   ; $f98c e5              ; 
             jp       po,jumpf998          ; $f98d e2 98 f9        ; 
             ld       hl,($0454)           ; $f990 2a 54 04        ; 
             push     hl                   ; $f993 e5              ; 
             ld       hl,($0452)           ; $f994 2a 52 04        ; 
             push     hl                   ; $f997 e5              ; 
jumpf998:    add      a,$03                ; $f998 c6 03           ; 
             ld       c,e                  ; $f99a 4b              ; 
             ld       b,a                  ; $f99b 47              ; 
             push     bc                   ; $f99c c5              ; 
             ld       bc,expr_apply_operator ; $f99d 01 e4 f9        ; 
loopf9a0:    push     bc                   ; $f9a0 c5              ; 
             ld       hl,($0206)           ; $f9a1 2a 06 02        ; 
             jp       expr_recurse_with_precedence ; $f9a4 c3 30 f9        ; 

;
; Special handling for relation tokens $dc-$de (`>`, `=`, `<` and
; combined forms such as `<=` / `<>`).  Builds a compare mask in D
; while consuming the chain, then leaves HL ready to parse the RHS.
;
expr_parse_comparison_chain: ld       d,$00                ; $f9a7 16 00           ; 
loopf9a9:    sub      a,$dc                ; $f9a9 d6 dc           ; 
             jr       c,skipf9cb           ; $f9ab 38 1e           ; 
             cp       a,$03                ; $f9ad fe 03           ; 
             jr       nc,skipf9cb          ; $f9af 30 1a           ; 
             cp       a,$01                ; $f9b1 fe 01           ; 
             rla                           ; $f9b3 17              ; 
             xor      a,d                  ; $f9b4 aa              ; 
             cp       a,d                  ; $f9b5 ba              ; 
             ld       d,a                  ; $f9b6 57              ; 
             jp       c,basic_raise_error_02 ; $f9b7 da aa f1        ; 
             ld       ($0206),hl           ; $f9ba 22 06 02        ; 
             rst      rst0010              ; $f9bd d7              ; 
             jr       loopf9a9             ; $f9be 18 e9           ; 

skipf9c0:    push     de                   ; $f9c0 d5              ; 
             call     fn_cint              ; $f9c1 cd e0 ca        ; 
             pop      de                   ; $f9c4 d1              ; 
             push     hl                   ; $f9c5 e5              ; 
             ld       bc,expr_apply_int_logic_operator ; $f9c6 01 3f fc        ; 
             jr       loopf9a0             ; $f9c9 18 d5           ; 

skipf9cb:    ld       a,b                  ; $f9cb 78              ; 
             cp       a,$64                ; $f9cc fe 64           ; 
             ret      nc                   ; $f9ce d0              ; 

             push     bc                   ; $f9cf c5              ; 
             push     de                   ; $f9d0 d5              ; 
             ld       de,$6405             ; $f9d1 11 05 64        ; 
             ld       hl,$fc0e             ; $f9d4 21 0e fc        ; 
             push     hl                   ; $f9d7 e5              ; 
             rst      rst0030              ; $f9d8 f7              ; 
             jr       nz,loopf976          ; $f9d9 20 9b           ; 
             ld       hl,($0450)           ; $f9db 2a 50 04        ; 
             push     hl                   ; $f9de e5              ; 
             ld       bc,$d50b             ; $f9df 01 0b d5        ; 
             jr       loopf9a0             ; $f9e2 18 bc           ; 

;
; Return point after a recursive RHS parse.  Restores the pending
; operator from C and the saved left-operand type from B, stores the
; operator code in $01DA, performs type promotion, then dispatches
; to integer, single, or double operator handlers.
;
expr_apply_operator: pop      bc                   ; $f9e4 c1              ; 
             ld       a,c                  ; $f9e5 79              ; 
             ld       ($01da),a            ; $f9e6 32 da 01        ; 
             ld       a,($01d9)            ; $f9e9 3a d9 01        ; 
             cp       a,b                  ; $f9ec b8              ; 
             jr       nz,skipf9f9          ; $f9ed 20 0a           ; 
             cp       a,$02                ; $f9ef fe 02           ; 
             jr       z,expr_prepare_integer_operator_dispatch ; $f9f1 28 1e           ; 
             cp       a,$04                ; $f9f3 fe 04           ; 
             jr       z,expr_apply_single_operator ; $f9f5 28 67           ; 
             jr       nc,expr_restore_left_double_and_dispatch ; $f9f7 30 2b           ; 
skipf9f9:    ld       d,a                  ; $f9f9 57              ; 
             ld       a,b                  ; $f9fa 78              ; 
             cp       a,$08                ; $f9fb fe 08           ; 
             jr       z,expr_apply_double_operator ; $f9fd 28 22           ; 
             ld       a,d                  ; $f9ff 7a              ; 
             cp       a,$08                ; $fa00 fe 08           ; 
             jr       z,expr_promote_stacked_left_to_fp ; $fa02 28 44           ; 
             ld       a,b                  ; $fa04 78              ; 
             cp       a,$04                ; $fa05 fe 04           ; 
             jr       z,expr_promote_rhs_to_single ; $fa07 28 52           ; 
             ld       a,d                  ; $fa09 7a              ; 
             cp       a,$03                ; $fa0a fe 03           ; 
             jp       z,basic_raise_error_0d ; $fa0c ca c5 f1        ; 
             jr       nc,expr_promote_left_integer_to_single ; $fa0f 30 54           ; 
;
; Integer-dispatch leg inside expr_apply_operator.  Uses the operator code
; in BC to select the integer worker from the table at $f117, restores the
; stacked left integer operand into DE, loads the right operand from
; $0450 into HL, and returns into that integer operator routine.
;
expr_prepare_integer_operator_dispatch: ld       hl,$f117             ; $fa11 21 17 f1        ; 
             ld       b,$00                ; $fa14 06 00           ; 
             add      hl,bc                ; $fa16 09              ; 
             add      hl,bc                ; $fa17 09              ; 
             ld       c,(hl)               ; $fa18 4e              ; 
             inc      hl                   ; $fa19 23              ; 
             ld       b,(hl)               ; $fa1a 46              ; 
             pop      de                   ; $fa1b d1              ; 
             ld       hl,($0450)           ; $fa1c 2a 50 04        ; 
             push     bc                   ; $fa1f c5              ; 
             ret                           ; $fa20 c9              ; 

;
; Apply the pending infix operator with both operands in double
; precision.  Restores the stacked left operand into the FP work
; area, then jumps through the operator table at $f0ff.
;
expr_apply_double_operator: call     fn_cdbl              ; $fa21 cd 90 cb        ; 
;
; Shared double-precision restore tail.  Copies the stacked left operand
; back into the FP work area ($049f...$04a5), ensures the current
; accumulator is in double precision, then dispatches through the
; double-operator table.
;
expr_restore_left_double_and_dispatch: call     callca67             ; $fa24 cd 67 ca        ; 
             pop      hl                   ; $fa27 e1              ; 
             ld       ($0452),hl           ; $fa28 22 52 04        ; 
             pop      hl                   ; $fa2b e1              ; 
             ld       ($0454),hl           ; $fa2c 22 54 04        ; 
loopfa2f:    pop      bc                   ; $fa2f c1              ; 
             pop      de                   ; $fa30 d1              ; 
             call     callca1b             ; $fa31 cd 1b ca        ; 
loopfa34:    call     fn_cdbl              ; $fa34 cd 90 cb        ; 
             ld       hl,$f0ff             ; $fa37 21 ff f0        ; 
loopfa3a:    ld       a,($01da)            ; $fa3a 3a da 01        ; 
             rlca                          ; $fa3d 07              ; 
             add      a,l                  ; $fa3e 85              ; 
             ld       l,a                  ; $fa3f 6f              ; 
             adc      a,h                  ; $fa40 8c              ; 
             sub      a,l                  ; $fa41 95              ; 
             ld       h,a                  ; $fa42 67              ; 
             ld       a,(hl)               ; $fa43 7e              ; 
             inc      hl                   ; $fa44 23              ; 
             ld       h,(hl)               ; $fa45 66              ; 
             ld       l,a                  ; $fa46 6f              ; 
             jp       (hl)                 ; $fa47 e9              ; 

;
; Mixed-type promotion leg used when the current RHS is already floating.
; Restores the stacked left operand, updates $01D9 to the chosen target
; precision, and rejoins either the single- or double-operator dispatch.
;
expr_promote_stacked_left_to_fp: ld       a,b                  ; $fa48 78              ; 
             push     af                   ; $fa49 f5              ; 
             call     callca67             ; $fa4a cd 67 ca        ; 
             pop      af                   ; $fa4d f1              ; 
             ld       ($01d9),a            ; $fa4e 32 d9 01        ; 
             cp       a,$04                ; $fa51 fe 04           ; 
             jr       z,loopfa2f           ; $fa53 28 da           ; 
             pop      hl                   ; $fa55 e1              ; 
             ld       ($0450),hl           ; $fa56 22 50 04        ; 
             jr       loopfa34             ; $fa59 18 d9           ; 

;
; Converts the current RHS accumulator to single precision via fn_csng,
; then falls straight into expr_apply_single_operator.
;
expr_promote_rhs_to_single: call     fn_csng              ; $fa5b cd 08 cb        ; 
;
; Apply the pending infix operator with single-precision operands.
; Restores the stacked left operand and dispatches through the
; single-precision operator table at $f10b.
;
expr_apply_single_operator: pop      bc                   ; $fa5e c1              ; 
             pop      de                   ; $fa5f d1              ; 
loopfa60:    ld       hl,$f10b             ; $fa60 21 0b f1        ; 
             jr       loopfa3a             ; $fa63 18 d5           ; 

;
; Mixed integer/single promotion tail.  Converts the stacked left integer
; operand through the integer-to-FP bridge, restores the saved RHS
; floating accumulator, and then rejoins the single-precision operator
; dispatch.
;
expr_promote_left_integer_to_single: pop      hl                   ; $fa65 e1              ; 
             call     callca0b             ; $fa66 cd 0b ca        ; 
             call     callcb21             ; $fa69 cd 21 cb        ; 
             call     callca26             ; $fa6c cd 26 ca        ; 
             pop      hl                   ; $fa6f e1              ; 
             ld       ($044e),hl           ; $fa70 22 4e 04        ; 
             pop      hl                   ; $fa73 e1              ; 
             ld       ($0450),hl           ; $fa74 22 50 04        ; 
             jr       loopfa60             ; $fa77 18 e7           ; 

             defb     $e5,$eb,$cd,$21,$cb,$e1,$cd,$0b,$ca,$cd      ; ...!...... ; 
             defb     $21,$cb,$c3,$c0,$cd                          ; !....      ; 
;
; Primary-term parser.  Accepts numeric literals, quoted strings,
; parenthesised expressions, unary `-`, unary `NOT`, variables /
; arrays, built-in functions, pseudo-variables, and `&H` / `&O`
; literals.
;
expr_parse_primary: rst      rst0010              ; $fa88 d7              ; 
             jp       z,basic_raise_error_17 ; $fa89 ca bf f1        ; 
             jp       c,parse_numeric_literal ; $fa8c da 21 ba        ; 
             call     calld2fe             ; $fa8f cd fe d2        ; 
             jp       nc,expr_parse_variable_ref ; $fa92 d2 32 fb        ; 
             cp       a,$d1                ; $fa95 fe d1           ; 
             jr       z,expr_parse_primary ; $fa97 28 ef           ; 
             cp       a,$2e                ; $fa99 fe 2e           ; 
             jp       z,parse_numeric_literal ; $fa9b ca 21 ba        ; 
             cp       a,$d2                ; $fa9e fe d2           ; 
             jp       z,expr_parse_unary_minus ; $faa0 ca 24 fb        ; 
             cp       a,$22                ; $faa3 fe 22           ; 
             jp       z,calld56f           ; $faa5 ca 6f d5        ; 
             cp       a,$cf                ; $faa8 fe cf           ; 
             jp       z,expr_parse_not     ; $faaa ca 1a fc        ; 
             cp       a,$26                ; $faad fe 26           ; 
             jp       z,expr_parse_hex_octal_literal ; $faaf ca 4f fb        ; 
             cp       a,$bf                ; $fab2 fe bf           ; 
             jr       nz,skipfac0          ; $fab4 20 0a           ; 
             rst      rst0010              ; $fab6 d7              ; 
             ld       a,($00b1)            ; $fab7 3a b1 00        ; 
             push     hl                   ; $faba e5              ; 
             call     skipfc90             ; $fabb cd 90 fc        ; 
             pop      hl                   ; $fabe e1              ; 
             ret                           ; $fabf c9              ; 

skipfac0:    cp       a,$be                ; $fac0 fe be           ; 
             jr       nz,skipface          ; $fac2 20 0a           ; 
             rst      rst0010              ; $fac4 d7              ; 
             push     hl                   ; $fac5 e5              ; 
             ld       hl,($0315)           ; $fac6 2a 15 03        ; 
             call     fp_from_positive_int_hl ; $fac9 cd 91 cd        ; 
             pop      hl                   ; $facc e1              ; 
             ret                           ; $facd c9              ; 

skipface:    cp       a,$c1                ; $face fe c1           ; 
             jp       z,fn_instr           ; $fad0 ca d6 dc        ; 
             cp       a,$c2                ; $fad3 fe c2           ; 
             jp       z,fn_inkey           ; $fad5 ca 03 c1        ; 
             cp       a,$cd                ; $fad8 fe cd           ; 
             jp       z,fn_screen          ; $fada ca 87 00        ; 
             cp       a,$c3                ; $fadd fe c3           ; 
             jp       z,fn_inp             ; $fadf ca 31 e9        ; 
             cp       a,$c4                ; $fae2 fe c4           ; 
             jp       z,fn_varptr          ; $fae4 ca a7 e9        ; 
             cp       a,$c5                ; $fae7 fe c5           ; 
             jp       z,fn_usr             ; $fae9 ca bb e9        ; 
             cp       a,$c6                ; $faec fe c6           ; 
             jp       z,fn_sns             ; $faee ca 61 e9        ; 
             cp       a,$c7                ; $faf1 fe c7           ; 
             jp       z,fn_alm             ; $faf3 ca 28 d9        ; 
             cp       a,$c8                ; $faf6 fe c8           ; 
             jp       z,fn_date            ; $faf8 ca ce d8        ; 
             cp       a,$c9                ; $fafb fe c9           ; 
             jp       z,fn_time            ; $fafd ca 68 d8        ; 
             cp       a,$ca                ; $fb00 fe ca           ; 
             jp       z,fn_start           ; $fb02 ca 99 da        ; 
             cp       a,$cb                ; $fb05 fe cb           ; 
             jp       z,fn_font            ; $fb07 ca 39 d7        ; 
             cp       a,$cc                ; $fb0a fe cc           ; 
             jp       z,fn_key             ; $fb0c ca 39 da        ; 
             cp       a,$c0                ; $fb0f fe c0           ; 
             jp       z,fn_string          ; $fb11 ca 35 d8        ; 
             cp       a,$bc                ; $fb14 fe bc           ; 
             jp       z,fn_invoke          ; $fb16 ca b5 fc        ; 
             sub      a,$df                ; $fb19 d6 df           ; 
             jp       nc,expr_dispatch_function ; $fb1b d2 a9 fb        ; 
;
; Parse `(expr)`: recurse through eval_expression, require the
; closing `)`, then return to the caller with the subexpression value.
;
expr_parse_parenthesized: call     expr_require_open_paren ; $fb1e cd 2b f9        ; 
             rst      rst0008              ; $fb21 cf              ; 
             defb     $29                                          ; )          ; 
             ret                           ; $fb23 c9              ; 

;
; Unary minus handler.  Recurses at a high precedence level, then
; negates the resulting numeric value before resuming the operator
; loop.
;
expr_parse_unary_minus: ld       d,$7d                ; $fb24 16 7d           ; 
             call     expr_recurse_with_precedence ; $fb26 cd 30 f9        ; 
             ld       hl,($031c)           ; $fb29 2a 1c 03        ; 
             push     hl                   ; $fb2c e5              ; 
             call     jumpc9e0             ; $fb2d cd e0 c9        ; 
             pop      hl                   ; $fb30 e1              ; 
             ret                           ; $fb31 c9              ; 

;
; Parse a variable / array / FN reference used as an expression
; primary.  Reuses lookup_or_create_var, loads the referenced value
; into the active accumulator, and leaves $01D9 set to its type.
;
expr_parse_variable_ref: call     lookup_or_create_var ; $fb32 cd 0a b0        ; 
             push     hl                   ; $fb35 e5              ; 
             ex       de,hl                ; $fb36 eb              ; 
             ld       ($0450),hl           ; $fb37 22 50 04        ; 
             rst      rst0030              ; $fb3a f7              ; 
             call     nz,callca62          ; $fb3b c4 62 ca        ; 
             pop      hl                   ; $fb3e e1              ; 
             ret                           ; $fb3f c9              ; 

             defb     $7e                                          ; ~          ; 
;
; Small scanner helper for token and radix parsers.  If A holds an ASCII
; lowercase letter `a`..`z`, folds it to uppercase by masking with $5f;
; otherwise returns A unchanged.
;
ascii_upper_if_lower: cp       a,$61                ; $fb41 fe 61           ; 
             ret      c                    ; $fb43 d8              ; 

             cp       a,$7b                ; $fb44 fe 7b           ; 
             ret      nc                   ; $fb46 d0              ; 

             and      a,$5f                ; $fb47 e6 5f           ; 
             ret                           ; $fb49 c9              ; 

             defb     $fe,$26,$c2,$95,$f5                          ; .&...      ; 
;
; Parse `&H...` or `&O...` integer literals.  Consumes digits,
; accumulates the value with overflow checks, then returns it via the
; normal integer-result path.
;
expr_parse_hex_octal_literal: ld       de,$0000             ; $fb4f 11 00 00        ; 
             rst      rst0010              ; $fb52 d7              ; 
             call     ascii_upper_if_lower ; $fb53 cd 41 fb        ; 
             cp       a,$4f                ; $fb56 fe 4f           ; 
             jr       z,skipfb87           ; $fb58 28 2d           ; 
             cp       a,$48                ; $fb5a fe 48           ; 
             jr       nz,skipfb86          ; $fb5c 20 28           ; 
             ld       b,$05                ; $fb5e 06 05           ; 
loopfb60:    rst      rst0010              ; $fb60 d7              ; 
             call     ascii_upper_if_lower ; $fb61 cd 41 fb        ; 
             call     calld2fe             ; $fb64 cd fe d2        ; 
             ex       de,hl                ; $fb67 eb              ; 
             jr       nc,skipfb74          ; $fb68 30 0a           ; 
             cp       a,$3a                ; $fb6a fe 3a           ; 
             jr       nc,skipfba4          ; $fb6c 30 36           ; 
             sub      a,$30                ; $fb6e d6 30           ; 
             jr       c,skipfba4           ; $fb70 38 32           ; 
             jr       skipfb7a             ; $fb72 18 06           ; 

skipfb74:    cp       a,$47                ; $fb74 fe 47           ; 
             jr       nc,skipfba4          ; $fb76 30 2c           ; 
             sub      a,$37                ; $fb78 d6 37           ; 
skipfb7a:    add      hl,hl                ; $fb7a 29              ; 
             add      hl,hl                ; $fb7b 29              ; 
             add      hl,hl                ; $fb7c 29              ; 
             add      hl,hl                ; $fb7d 29              ; 
             or       a,l                  ; $fb7e b5              ; 
             ld       l,a                  ; $fb7f 6f              ; 
             ex       de,hl                ; $fb80 eb              ; 
             djnz     loopfb60             ; $fb81 10 dd           ; 
             jp       basic_raise_error_06 ; $fb83 c3 bc f1        ; 

skipfb86:    dec      hl                   ; $fb86 2b              ; 
skipfb87:    rst      rst0010              ; $fb87 d7              ; 
             ex       de,hl                ; $fb88 eb              ; 
             jr       nc,skipfba4          ; $fb89 30 19           ; 
             cp       a,$38                ; $fb8b fe 38           ; 
             jp       nc,basic_raise_error_02 ; $fb8d d2 aa f1        ; 
             ld       bc,basic_raise_error_06 ; $fb90 01 bc f1        ; 
             push     bc                   ; $fb93 c5              ; 
             add      hl,hl                ; $fb94 29              ; 
             ret      c                    ; $fb95 d8              ; 

             add      hl,hl                ; $fb96 29              ; 
             ret      c                    ; $fb97 d8              ; 

             add      hl,hl                ; $fb98 29              ; 
             ret      c                    ; $fb99 d8              ; 

             pop      bc                   ; $fb9a c1              ; 
             ld       b,$00                ; $fb9b 06 00           ; 
             sub      a,$30                ; $fb9d d6 30           ; 
             ld       c,a                  ; $fb9f 4f              ; 
             add      hl,bc                ; $fba0 09              ; 
             ex       de,hl                ; $fba1 eb              ; 
             jr       skipfb87             ; $fba2 18 e3           ; 

skipfba4:    call     num_store_int_result ; $fba4 cd ef ca        ; 
             ex       de,hl                ; $fba7 eb              ; 
             ret                           ; $fba8 c9              ; 

;
; Built-in function dispatcher for expression tokens at and above
; `$df`.  Handles a few high-numbered special cases inline, parses
; the argument list, then jumps through fn_dispatch_table.
;
expr_dispatch_function: cp       a,$1c                ; $fba9 fe 1c           ; 
             jp       z,fn_csrlin          ; $fbab ca af ce        ; 
             cp       a,$1d                ; $fbae fe 1d           ; 
             jp       z,fn_stick           ; $fbb0 ca e3 d7        ; 
             cp       a,$1e                ; $fbb3 fe 1e           ; 
             jp       z,fn_strig           ; $fbb5 ca f8 d7        ; 
             cp       a,$1f                ; $fbb8 fe 1f           ; 
             jp       z,fn_point           ; $fbba ca 93 00        ; 
             ld       b,$00                ; $fbbd 06 00           ; 
             rlca                          ; $fbbf 07              ; 
             ld       c,a                  ; $fbc0 4f              ; 
             push     bc                   ; $fbc1 c5              ; 
             rst      rst0010              ; $fbc2 d7              ; 
             ld       a,c                  ; $fbc3 79              ; 
             cp       a,$31                ; $fbc4 fe 31           ; 
             jr       c,skipfbde           ; $fbc6 38 16           ; 
             call     expr_require_open_paren ; $fbc8 cd 2b f9        ; 
             rst      rst0008              ; $fbcb cf              ; 
             defb     $2c                                          ; ,          ; 
             call     str_require_string   ; $fbcd cd ae cb        ; 
             ex       de,hl                ; $fbd0 eb              ; 
             ld       hl,($0450)           ; $fbd1 2a 50 04        ; 
             ex       (sp),hl              ; $fbd4 e3              ; 
             push     hl                   ; $fbd5 e5              ; 
             ex       de,hl                ; $fbd6 eb              ; 
             call     eval_expr_to_int8    ; $fbd7 cd 5e fe        ; 
             ex       de,hl                ; $fbda eb              ; 
             ex       (sp),hl              ; $fbdb e3              ; 
             jr       skipfbf5             ; $fbdc 18 17           ; 

skipfbde:    call     expr_parse_parenthesized ; $fbde cd 1e fb        ; 
             ex       (sp),hl              ; $fbe1 e3              ; 
             ld       a,l                  ; $fbe2 7d              ; 
             cp       a,$0a                ; $fbe3 fe 0a           ; 
             jr       c,skipfbf1           ; $fbe5 38 0a           ; 
             cp       a,$19                ; $fbe7 fe 19           ; 
             jr       nc,skipfbf1          ; $fbe9 30 06           ; 
             rst      rst0030              ; $fbeb f7              ; 
             push     hl                   ; $fbec e5              ; 
             call     c,fn_cdbl            ; $fbed dc 90 cb        ; 
             pop      hl                   ; $fbf0 e1              ; 
skipfbf1:    ld       de,$fb30             ; $fbf1 11 30 fb        ; 
             push     de                   ; $fbf4 d5              ; 
skipfbf5:    ld       bc,fn_dispatch_table ; $fbf5 01 4b ee        ; 
callfbf8:    add      hl,bc                ; $fbf8 09              ; 
             ld       c,(hl)               ; $fbf9 4e              ; 
             inc      hl                   ; $fbfa 23              ; 
             ld       h,(hl)               ; $fbfb 66              ; 
             ld       l,c                  ; $fbfc 69              ; 
             jp       (hl)                 ; $fbfd e9              ; 

;
; Small scanner used by parse_numeric_literal while entering the
; mantissa/exponent loops.  Recognises optional `+` / `-` forms
; (including tokenised variants) and leaves HL on the first real
; digit when no sign is present.
;
num_scan_optional_sign: dec      d                    ; $fbfe 15              ; 
             cp       a,$d2                ; $fbff fe d2           ; 
             ret      z                    ; $fc01 c8              ; 

             cp       a,$2d                ; $fc02 fe 2d           ; 
             ret      z                    ; $fc04 c8              ; 

             inc      d                    ; $fc05 14              ; 
             cp       a,$2b                ; $fc06 fe 2b           ; 
             ret      z                    ; $fc08 c8              ; 

             cp       a,$d1                ; $fc09 fe d1           ; 
             ret      z                    ; $fc0b c8              ; 

             dec      hl                   ; $fc0c 2b              ; 
             ret                           ; $fc0d c9              ; 

             defb     $3c,$8f,$c1,$a0,$c6,$ff,$9f                  ; <......    ; 
callfc15:    call     callc9f4             ; $fc15 cd f4 c9        ; 
             jr       skipfc2c             ; $fc18 18 12           ; 

;
; Unary `NOT`.  Recurses with high precedence, coerces the operand
; to integer, bitwise-complements it, then resumes expr_operator_loop.
;
expr_parse_not: ld       d,$5a                ; $fc1a 16 5a           ; 
             call     expr_recurse_with_precedence ; $fc1c cd 30 f9        ; 
             call     fn_cint              ; $fc1f cd e0 ca        ; 
             ld       a,l                  ; $fc22 7d              ; 
             cpl                           ; $fc23 2f              ; 
             ld       l,a                  ; $fc24 6f              ; 
             ld       a,h                  ; $fc25 7c              ; 
             cpl                           ; $fc26 2f              ; 
             ld       h,a                  ; $fc27 67              ; 
             ld       ($0450),hl           ; $fc28 22 50 04        ; 
             pop      bc                   ; $fc2b c1              ; 
skipfc2c:    jp       expr_operator_loop   ; $fc2c c3 3c f9        ; 

;
; RST $30 handler — query current I/O device mode.
; Reads the device mode byte at $01D9 and subtracts 3, returning the
; result in A with sign, zero and carry flags set.
; Carry is additionally forced set if the original value was less than
; $08.  Sign and zero flags are used by callers to dispatch on device
; type (e.g., jp m / jp z / jp p sequences).
;
rst30_device_mode: ld       a,($01d9)            ; $fc2f 3a d9 01        ; 
             cp       a,$08                ; $fc32 fe 08           ; 
             jr       nc,skipfc3b          ; $fc34 30 05           ; 
             sub      a,$03                ; $fc36 d6 03           ; 
             or       a,a                  ; $fc38 b7              ; 
             scf                           ; $fc39 37              ; 
             ret                           ; $fc3a c9              ; 

skipfc3b:    sub      a,$03                ; $fc3b d6 03           ; 
             or       a,a                  ; $fc3d b7              ; 
             ret                           ; $fc3e c9              ; 

;
; Integer-only operator worker used after operands have been coerced
; to 16-bit integers.  Handles the bitwise/logical operator cases
; and returns through the normal expression fold path.
;
expr_apply_int_logic_operator: ld       a,b                  ; $fc3f 78              ; 
             push     af                   ; $fc40 f5              ; 
             call     fn_cint              ; $fc41 cd e0 ca        ; 
             pop      af                   ; $fc44 f1              ; 
             pop      de                   ; $fc45 d1              ; 
             cp       a,$7a                ; $fc46 fe 7a           ; 
             jp       z,num_mod_int_or_promote ; $fc48 ca 95 cd        ; 
             cp       a,$7b                ; $fc4b fe 7b           ; 
             jp       z,num_div_int_or_promote ; $fc4d ca 39 cd        ; 
             ld       bc,$fc92             ; $fc50 01 92 fc        ; 
             push     bc                   ; $fc53 c5              ; 
             cp       a,$46                ; $fc54 fe 46           ; 
             jr       nz,skipfc5e          ; $fc56 20 06           ; 
             ld       a,e                  ; $fc58 7b              ; 
             or       a,l                  ; $fc59 b5              ; 
             ld       l,a                  ; $fc5a 6f              ; 
             ld       a,h                  ; $fc5b 7c              ; 
             or       a,d                  ; $fc5c b2              ; 
             ret                           ; $fc5d c9              ; 

skipfc5e:    cp       a,$50                ; $fc5e fe 50           ; 
             jr       nz,skipfc68          ; $fc60 20 06           ; 
             ld       a,e                  ; $fc62 7b              ; 
             and      a,l                  ; $fc63 a5              ; 
             ld       l,a                  ; $fc64 6f              ; 
             ld       a,h                  ; $fc65 7c              ; 
             and      a,d                  ; $fc66 a2              ; 
             ret                           ; $fc67 c9              ; 

skipfc68:    cp       a,$3c                ; $fc68 fe 3c           ; 
             jr       nz,skipfc72          ; $fc6a 20 06           ; 
             ld       a,e                  ; $fc6c 7b              ; 
             xor      a,l                  ; $fc6d ad              ; 
             ld       l,a                  ; $fc6e 6f              ; 
             ld       a,h                  ; $fc6f 7c              ; 
             xor      a,d                  ; $fc70 aa              ; 
             ret                           ; $fc71 c9              ; 

skipfc72:    ld       a,e                  ; $fc72 7b              ; 
             xor      a,l                  ; $fc73 ad              ; 
             cpl                           ; $fc74 2f              ; 
             ld       l,a                  ; $fc75 6f              ; 
             ld       a,h                  ; $fc76 7c              ; 
             xor      a,d                  ; $fc77 aa              ; 
             cpl                           ; $fc78 2f              ; 
             ret                           ; $fc79 c9              ; 

;
; fn_peek — PEEK function
; PEEK(addr) — returns the byte stored at memory
; address addr as an integer (0–255).
; Calls $ffd6 to evaluate addr and leave the address
; in HL (or uses eval_expr_to_addr convention).
; LD A,(HL): reads the byte at the computed address.
; JR $fc90: falls into callfc90 which zero-extends A
; into HL (LD L,A; XOR A; LD H,A) and returns via
; JP callcaef.
; 
; ; ============================================================
; ; POS handler ($FC8C)
; ; ============================================================
;
fn_peek:     call     coerce_accumulator_to_addr_word ; $fc7a cd d6 ff        ; 
             ld       a,(hl)               ; $fc7d 7e              ; 
             jr       skipfc90             ; $fc7e 18 10           ; 

;
; inst_poke — POKE statement
; POKE addr, val
; eval_expr_to_addr: evaluate address expression → DE (16-bit).
; RST $08 / $2C: require `,` separator.
; callfe5e: evaluate value expression → E (8-bit integer; error if out
; of range).
; LD (DE),A: write the byte to the address.
; 
; POKE statement.  Evaluate address → DE (eval_expr_to_addr).
; Require `,`.  Evaluate value byte → A (callfe5e).  Write A to (DE).
;
inst_poke:   call     eval_expr_to_addr    ; $fc80 cd cc ff        ; 
             push     de                   ; $fc83 d5              ; 
             rst      rst0008              ; $fc84 cf              ; 
             inc      l                    ; $fc85 2c              ; 
             call     eval_expr_to_int8    ; $fc86 cd 5e fe        ; 
             pop      de                   ; $fc89 d1              ; 
             ld       (de),a               ; $fc8a 12              ; 
             ret                           ; $fc8b c9              ; 

;
; fn_pos — POS function
; POS(expr) — returns the current cursor column
; position (0 = leftmost column).
; The argument is evaluated but ignored.
; LD A,($00b9): reads the cursor column counter from
; RAM $00B9 (1-based internal value).
; DEC A: converts to 0-based column index.
; Falls into callfc90: LD L,A; XOR A; LD H,A;
; JP callcaef — returns A as an unsigned integer.
; 
; ; ============================================================
; ; CSNG handler ($CB08)
; ; ============================================================
;
fn_pos:      ld       a,($00b9)            ; $fc8c 3a b9 00        ; 
             dec      a                    ; $fc8f 3d              ; 
skipfc90:    ld       l,a                  ; $fc90 6f              ; 
             xor      a,a                  ; $fc91 af              ; 
             ld       h,a                  ; $fc92 67              ; 
             jp       num_store_int_result ; $fc93 c3 ef ca        ; 

;
; inst_deffn — DEF FN statement
; DEF FN name[(params)] = expression
; lookup_fn_variable ($FE18): look up or create FN variable entry → HL.
; Sets $020E = $80 (FN-definition mode); calls variable lookup.
; guard_direct_mode_only ($FE08): error $0C if in direct mode.
; ex de,hl: DE = current program-stream address (= start of expression).
; Store DE into the FN variable slot: LD (HL),E; INC HL; LD (HL),D.
; (This records where in the program the expression body starts.)
; If next token is `(` ($28):
; RST $10; loop (loopfca8):
; lookup_or_create_var: register each formal parameter name.
; Until `)` token ($29): RST $08/$2C for comma; repeat.
; Jump to inst_data (skip the `= expression` body — parsed at call time).
; 
; DEF FN statement.  Record user function definition.
; Stores the program address of the expression body in the FN
; variable entry (lookup_fn_variable).  Registers formal parameter
; names (loopfca8).  Expression is not evaluated here — only the
; pointer is saved.
;
inst_deffn:  call     lookup_fn_variable   ; $fc96 cd 18 fe        ; 
             call     guard_direct_mode_only ; $fc99 cd 08 fe        ; 
             ex       de,hl                ; $fc9c eb              ; 
             ld       (hl),e               ; $fc9d 73              ; 
             inc      hl                   ; $fc9e 23              ; 
             ld       (hl),d               ; $fc9f 72              ; 
             ex       de,hl                ; $fca0 eb              ; 
             ld       a,(hl)               ; $fca1 7e              ; 
             cp       a,$28                ; $fca2 fe 28           ; 
             jp       nz,inst_data         ; $fca4 c2 64 f6        ; 
             rst      rst0010              ; $fca7 d7              ; 
loopfca8:    call     lookup_or_create_var ; $fca8 cd 0a b0        ; 
             ld       a,(hl)               ; $fcab 7e              ; 
             cp       a,$29                ; $fcac fe 29           ; 
             jp       z,inst_data          ; $fcae ca 64 f6        ; 
             rst      rst0008              ; $fcb1 cf              ; 
             inc      l                    ; $fcb2 2c              ; 
             jr       loopfca8             ; $fcb3 18 f3           ; 

;
; Expression-side FN call handler.  Looks up the FN descriptor,
; fetches the saved body pointer, and either enters the no-argument
; path or the argument-binding path when a formal list is present.
;
fn_invoke:   call     fn_require_lookup    ; $fcb5 cd 16 fe        ; 
             ld       a,($01d9)            ; $fcb8 3a d9 01        ; 
             or       a,a                  ; $fcbb b7              ; 
             push     af                   ; $fcbc f5              ; 
             ld       ($031c),hl           ; $fcbd 22 1c 03        ; 
             ex       de,hl                ; $fcc0 eb              ; 
             ld       a,(hl)               ; $fcc1 7e              ; 
             inc      hl                   ; $fcc2 23              ; 
             ld       h,(hl)               ; $fcc3 66              ; 
             ld       l,a                  ; $fcc4 6f              ; 
             ld       a,h                  ; $fcc5 7c              ; 
             or       a,l                  ; $fcc6 b5              ; 
             jp       z,basic_raise_error_12 ; $fcc7 ca b6 f1        ; 
             ld       a,(hl)               ; $fcca 7e              ; 
             cp       a,$28                ; $fccb fe 28           ; 
             jp       nz,fn_enter_scope    ; $fccd c2 69 fd        ; 
             rst      rst0010              ; $fcd0 d7              ; 
             ld       ($0206),hl           ; $fcd1 22 06 02        ; 
             ex       de,hl                ; $fcd4 eb              ; 
             ld       hl,($031c)           ; $fcd5 2a 1c 03        ; 
             rst      rst0008              ; $fcd8 cf              ; 
             defb     $28                                          ; (          ; 
             xor      a,a                  ; $fcda af              ; 
             push     af                   ; $fcdb f5              ; 
             push     hl                   ; $fcdc e5              ; 
             ex       de,hl                ; $fcdd eb              ; 
;
; Parse and evaluate the actual argument list for an FN call.
; Each actual parameter is resolved via the normal variable parser,
; evaluated, coerced to the declared type, then pushed into the
; temporary FN-local variable area before the body is executed.
;
fn_bind_arguments: ld       a,$80                ; $fcde 3e 80           ; 
             ld       ($020e),a            ; $fce0 32 0e 02        ; 
             call     lookup_or_create_var ; $fce3 cd 0a b0        ; 
             ex       de,hl                ; $fce6 eb              ; 
             ex       (sp),hl              ; $fce7 e3              ; 
             ld       a,($01d9)            ; $fce8 3a d9 01        ; 
             push     af                   ; $fceb f5              ; 
             push     de                   ; $fcec d5              ; 
             call     eval_expression      ; $fced cd 2d f9        ; 
             ld       ($031c),hl           ; $fcf0 22 1c 03        ; 
             pop      hl                   ; $fcf3 e1              ; 
             ld       ($0206),hl           ; $fcf4 22 06 02        ; 
             pop      af                   ; $fcf7 f1              ; 
             call     coerce_result_to_type ; $fcf8 cd ef fd        ; 
             ld       c,$04                ; $fcfb 0e 04           ; 
             call     check_stack_space    ; $fcfd cd 8b d1        ; 
             ld       hl,$fff8             ; $fd00 21 f8 ff        ; 
             add      hl,sp                ; $fd03 39              ; 
             ld       sp,hl                ; $fd04 f9              ; 
             call     callca6a             ; $fd05 cd 6a ca        ; 
             ld       a,($01d9)            ; $fd08 3a d9 01        ; 
             push     af                   ; $fd0b f5              ; 
             ld       hl,($031c)           ; $fd0c 2a 1c 03        ; 
             ld       a,(hl)               ; $fd0f 7e              ; 
             cp       a,$29                ; $fd10 fe 29           ; 
             jr       z,fn_finish_invocation ; $fd12 28 0e           ; 
             rst      rst0008              ; $fd14 cf              ; 
             defb     $2c                                          ; ,          ; 
             push     hl                   ; $fd16 e5              ; 
             ld       hl,($0206)           ; $fd17 2a 06 02        ; 
             rst      rst0008              ; $fd1a cf              ; 
             defb     $2c                                          ; ,          ; 
             jr       fn_bind_arguments    ; $fd1c 18 c0           ; 

             defb     $f1,$32,$ae,$03                              ; .2..       ; 
;
; FN return/teardown path.  Restores the caller's active type and
; local-variable context, copies the computed return value back to the
; caller's accumulator, then releases the temporary FN frame.
;
fn_finish_invocation: pop      af                   ; $fd22 f1              ; 
             or       a,a                  ; $fd23 b7              ; 
             jr       z,skipfd5e           ; $fd24 28 38           ; 
             ld       ($01d9),a            ; $fd26 32 d9 01        ; 
             ld       hl,$0000             ; $fd29 21 00 00        ; 
             add      hl,sp                ; $fd2c 39              ; 
             call     callca62             ; $fd2d cd 62 ca        ; 
             ld       hl,rst0008           ; $fd30 21 08 00        ; 
             add      hl,sp                ; $fd33 39              ; 
             ld       sp,hl                ; $fd34 f9              ; 
             pop      de                   ; $fd35 d1              ; 
             ld       l,$03                ; $fd36 2e 03           ; 
             dec      de                   ; $fd38 1b              ; 
             dec      de                   ; $fd39 1b              ; 
             dec      de                   ; $fd3a 1b              ; 
             ld       a,($01d9)            ; $fd3b 3a d9 01        ; 
             add      a,l                  ; $fd3e 85              ; 
             ld       b,a                  ; $fd3f 47              ; 
             ld       a,($03ae)            ; $fd40 3a ae 03        ; 
             ld       c,a                  ; $fd43 4f              ; 
             add      a,b                  ; $fd44 80              ; 
             cp       a,$64                ; $fd45 fe 64           ; 
             jp       nc,jumpf590          ; $fd47 d2 90 f5        ; 
             push     af                   ; $fd4a f5              ; 
             ld       a,l                  ; $fd4b 7d              ; 
             ld       b,$00                ; $fd4c 06 00           ; 
             ld       hl,$03b0             ; $fd4e 21 b0 03        ; 
             add      hl,bc                ; $fd51 09              ; 
             ld       c,a                  ; $fd52 4f              ; 
             call     copy_bc_bytes        ; $fd53 cd 03 fe        ; 
             ld       bc,$fd1e             ; $fd56 01 1e fd        ; 
             push     bc                   ; $fd59 c5              ; 
             push     bc                   ; $fd5a c5              ; 
             jp       assign_dispatch_by_result_type ; $fd5b c3 a3 f6        ; 

skipfd5e:    ld       hl,($031c)           ; $fd5e 2a 1c 03        ; 
             rst      rst0010              ; $fd61 d7              ; 
             push     hl                   ; $fd62 e5              ; 
             ld       hl,($0206)           ; $fd63 2a 06 02        ; 
             rst      rst0008              ; $fd66 cf              ; 
             defb     $29                                          ; )          ; 
             defb     $3e                  ; $fd68 3e d5           ;   As: ld     a,$d5      ; 3e d5      ; Next: $fd6a
;
; Enter an FN call scope with no formal-argument loop.  Allocates a
; fresh local-variable work area, saves the caller's $0344/$0346/
; $03AE state, switches descriptor pointers to the FN-local block,
; and starts evaluating the function body.
;
fn_enter_scope: push     de                   ; $fd69 d5              ; 
             ld       ($0206),hl           ; $fd6a 22 06 02        ; 
             ld       a,($0346)            ; $fd6d 3a 46 03        ; 
             add      a,$04                ; $fd70 c6 04           ; 
             push     af                   ; $fd72 f5              ; 
             rrca                          ; $fd73 0f              ; 
             ld       c,a                  ; $fd74 4f              ; 
             call     check_stack_space    ; $fd75 cd 8b d1        ; 
             pop      af                   ; $fd78 f1              ; 
             ld       c,a                  ; $fd79 4f              ; 
             cpl                           ; $fd7a 2f              ; 
             inc      a                    ; $fd7b 3c              ; 
             ld       l,a                  ; $fd7c 6f              ; 
             ld       h,$ff                ; $fd7d 26 ff           ; 
             add      hl,sp                ; $fd7f 39              ; 
             ld       sp,hl                ; $fd80 f9              ; 
             push     hl                   ; $fd81 e5              ; 
             ld       de,$0344             ; $fd82 11 44 03        ; 
             call     copy_bc_bytes        ; $fd85 cd 03 fe        ; 
             pop      hl                   ; $fd88 e1              ; 
             ld       ($0344),hl           ; $fd89 22 44 03        ; 
             ld       hl,($03ae)           ; $fd8c 2a ae 03        ; 
             ld       ($0346),hl           ; $fd8f 22 46 03        ; 
             ld       b,h                  ; $fd92 44              ; 
             ld       c,l                  ; $fd93 4d              ; 
             ld       hl,$0348             ; $fd94 21 48 03        ; 
             ld       de,$03b0             ; $fd97 11 b0 03        ; 
             call     copy_bc_bytes        ; $fd9a cd 03 fe        ; 
             ld       h,a                  ; $fd9d 67              ; 
             ld       l,a                  ; $fd9e 6f              ; 
             ld       ($03ae),hl           ; $fd9f 22 ae 03        ; 
             ld       hl,($041a)           ; $fda2 2a 1a 04        ; 
             inc      hl                   ; $fda5 23              ; 
             ld       ($041a),hl           ; $fda6 22 1a 04        ; 
             ld       a,h                  ; $fda9 7c              ; 
             or       a,l                  ; $fdaa b5              ; 
             ld       ($0417),a            ; $fdab 32 17 04        ; 
             ld       hl,($0206)           ; $fdae 2a 06 02        ; 
             call     expr_require_equals  ; $fdb1 cd 28 f9        ; 
             dec      hl                   ; $fdb4 2b              ; 
             rst      rst0010              ; $fdb5 d7              ; 
             jp       nz,basic_raise_error_02 ; $fdb6 c2 aa f1        ; 
             rst      rst0030              ; $fdb9 f7              ; 
             jr       nz,skipfdcb          ; $fdba 20 0f           ; 
             ld       de,$0201             ; $fdbc 11 01 02        ; 
             ld       hl,($0450)           ; $fdbf 2a 50 04        ; 
             rst      rst0020              ; $fdc2 e7              ; 
             jr       c,skipfdcb           ; $fdc3 38 06           ; 
             call     calld54a             ; $fdc5 cd 4a d5        ; 
             call     calld591             ; $fdc8 cd 91 d5        ; 
skipfdcb:    ld       hl,($0344)           ; $fdcb 2a 44 03        ; 
             ld       d,h                  ; $fdce 54              ; 
             ld       e,l                  ; $fdcf 5d              ; 
             inc      hl                   ; $fdd0 23              ; 
             inc      hl                   ; $fdd1 23              ; 
             ld       c,(hl)               ; $fdd2 4e              ; 
             inc      hl                   ; $fdd3 23              ; 
             ld       b,(hl)               ; $fdd4 46              ; 
             inc      bc                   ; $fdd5 03              ; 
             inc      bc                   ; $fdd6 03              ; 
             inc      bc                   ; $fdd7 03              ; 
             inc      bc                   ; $fdd8 03              ; 
             ld       hl,$0344             ; $fdd9 21 44 03        ; 
             call     copy_bc_bytes        ; $fddc cd 03 fe        ; 
             ex       de,hl                ; $fddf eb              ; 
             ld       sp,hl                ; $fde0 f9              ; 
             ld       hl,($041a)           ; $fde1 2a 1a 04        ; 
             dec      hl                   ; $fde4 2b              ; 
             ld       ($041a),hl           ; $fde5 22 1a 04        ; 
             ld       a,h                  ; $fde8 7c              ; 
             or       a,l                  ; $fde9 b5              ; 
             ld       ($0417),a            ; $fdea 32 17 04        ; 
             pop      hl                   ; $fded e1              ; 
             pop      af                   ; $fdee f1              ; 
;
; coerce_result_to_type — convert the current expression result to a
; requested BASIC type
; Uses the low three bits of A as an index into the conversion-dispatch
; table at $f0f5, then tail-calls the matching conversion helper through
; callfbf8.  Shared by LET/READ/INPUT assignment and FN argument binding.
;
coerce_result_to_type: push     hl                   ; $fdef e5              ; 
             and      a,$07                ; $fdf0 e6 07           ; 
             ld       hl,$f0f5             ; $fdf2 21 f5 f0        ; 
             ld       c,a                  ; $fdf5 4f              ; 
             ld       b,$00                ; $fdf6 06 00           ; 
             add      hl,bc                ; $fdf8 09              ; 
             call     callfbf8             ; $fdf9 cd f8 fb        ; 
             pop      hl                   ; $fdfc e1              ; 
             ret                           ; $fdfd c9              ; 

loopfdfe:    ld       a,(de)               ; $fdfe 1a              ; 
             ld       (hl),a               ; $fdff 77              ; 
             inc      hl                   ; $fe00 23              ; 
             inc      de                   ; $fe01 13              ; 
             dec      bc                   ; $fe02 0b              ; 
;
; copy_bc_bytes — generic BC-byte memory copy from DE to HL
; Straight byte-copy helper used by FN frame setup/teardown and other
; runtime state moves.
;
copy_bc_bytes: ld       a,b                  ; $fe03 78              ; 
             or       a,c                  ; $fe04 b1              ; 
             jr       nz,loopfdfe          ; $fe05 20 f7           ; 
             ret                           ; $fe07 c9              ; 

;
; Error $0C ("Illegal direct") if the interpreter is running in
; direct mode ($01DB == $FFFF+1). Used by INPUT prompt, DEFFN.
;
guard_direct_mode_only: push     hl                   ; $fe08 e5              ; 
             ld       hl,($01db)           ; $fe09 2a db 01        ; 
             inc      hl                   ; $fe0c 23              ; 
             ld       a,h                  ; $fe0d 7c              ; 
             or       a,l                  ; $fe0e b5              ; 
             pop      hl                   ; $fe0f e1              ; 
             ret      nz                   ; $fe10 c0              ; 

             ld       e,$0c                ; $fe11 1e 0c           ; 
             jp       basic_raise_error    ; $fe13 c3 c7 f1        ; 

;
; fn_require_lookup — require the `FN` token and look up the FN descriptor
; Tiny FN-call prelude: consumes the tokenised `FN` marker, then drops
; into lookup_fn_variable so expression-side FN invocation sees the
; correct variable/definition record.
;
fn_require_lookup: rst      rst0008              ; $fe16 cf              ; 
             defb     $bc                                          ; .          ; 
;
; Look up a user-defined FN variable.  Sets $020E = $80 (FN
; context flag) then jumps into the standard variable lookup.
;
lookup_fn_variable: ld       a,$80                ; $fe18 3e 80           ; 
             ld       ($020e),a            ; $fe1a 32 0e 02        ; 
             or       a,(hl)               ; $fe1d b6              ; 
             ld       c,a                  ; $fe1e 4f              ; 
             jp       jumpb00f             ; $fe1f c3 0f b0        ; 

;
; keyword_extension_dispatch — secondary dispatcher for high BASIC tokens
; Handles the token block above the main keyword_dispatch_table range,
; including the system-string assignment forms routed to TIME$/DATE$/ALM$/
; START$/FONT$/KEY$, plus the fallback path to jumpdd59 for the remaining
; extension keyword family.
;
keyword_extension_dispatch: cp       a,$7a                ; $fe22 fe 7a           ; 
             jr       z,skipfe4c           ; $fe24 28 26           ; 
             cp       a,$49                ; $fe26 fe 49           ; 
             jp       z,sysstr_fetch_time_record ; $fe28 ca 81 d8        ; 
             cp       a,$48                ; $fe2b fe 48           ; 
             jp       z,sysstr_fetch_date_record ; $fe2d ca 15 d9        ; 
             cp       a,$47                ; $fe30 fe 47           ; 
             jp       z,inst_alm           ; $fe32 ca 81 d9        ; 
             cp       a,$4a                ; $fe35 fe 4a           ; 
             jp       z,inst_start         ; $fe37 ca b0 da        ; 
             cp       a,$4b                ; $fe3a fe 4b           ; 
             jp       z,inst_font          ; $fe3c ca 71 d7        ; 
             cp       a,$4c                ; $fe3f fe 4c           ; 
             jp       z,inst_key           ; $fe41 ca 50 da        ; 
             cp       a,$4d                ; $fe44 fe 4d           ; 
             jp       z,jump0084           ; $fe46 ca 84 00        ; 
             jp       basic_raise_error_02 ; $fe49 c3 aa f1        ; 

skipfe4c:    inc      hl                   ; $fe4c 23              ; 
             jp       jumpdd59             ; $fe4d c3 59 dd        ; 

callfe50:    rst      rst0010              ; $fe50 d7              ; 
;
; Evaluate expression → convert to signed 16-bit integer.
; Result in D (high) and E (low).
;
eval_expr_to_int16: call     eval_expression      ; $fe51 cd 2d f9        ; 
;
; coerce_accumulator_to_int16 — convert the current accumulator to signed
; 16-bit DE without advancing the source stream
; Shared helper under eval_expr_to_int16 / eval_expr_to_int8.  Calls
; fn_cint, returns the converted integer in DE, restores HL, and leaves
; flags reflecting overflow/sign in D.
;
coerce_accumulator_to_int16: push     hl                   ; $fe54 e5              ; 
             call     fn_cint              ; $fe55 cd e0 ca        ; 
             ex       de,hl                ; $fe58 eb              ; 
             pop      hl                   ; $fe59 e1              ; 
             ld       a,d                  ; $fe5a 7a              ; 
             or       a,a                  ; $fe5b b7              ; 
             ret                           ; $fe5c c9              ; 

callfe5d:    rst      rst0010              ; $fe5d d7              ; 
;
; Evaluate expression → convert to integer; error ($F590) if
; value does not fit in a single byte.  Returns integer in E, A.
;
eval_expr_to_int8: call     eval_expression      ; $fe5e cd 2d f9        ; 
;
; eval_result_to_int8 — finish integer evaluation as a checked 8-bit value
; Reuses coerce_accumulator_to_int16, raises error $05 if the high byte is
; non-zero, then advances HL once more and returns the low byte in A/E.
;
eval_result_to_int8: call     coerce_accumulator_to_int16 ; $fe61 cd 54 fe        ; 
             jp       nz,jumpf590          ; $fe64 c2 90 f5        ; 
             dec      hl                   ; $fe67 2b              ; 
             rst      rst0010              ; $fe68 d7              ; 
             ld       a,e                  ; $fe69 7b              ; 
             ret                           ; $fe6a c9              ; 

;
; inst_list / inst_llist — LIST and LLIST statements
; LLIST: sets output to printer device ($E80E via calle827), then falls
; into the shared LIST logic (skipfe80) with A = 0.
; LIST [start[-end]]:
; Parse optional line-range (callf2f1 → DE=start, BC=end line numbers).
; Main loop (loopfe8b):
; Set $01DB = $FFFF (suppress execution during LIST).
; Fetch next-line pointer; if 0: done.
; Call callc000 (check if Ctrl-C pressed — abort).
; Compare current line number against the requested range (RST $20).
; If within range: print line number (callbb98), detokenise and print
; each token (callfefe), output CRLF.
; Advance to next line.
; 
; LLIST statement.  Direct output to printer device ($E80E),
; then fall into the LIST main loop.
;
inst_llist:  ld       de,$e80e             ; $fe6b 11 0e e8        ; 
             call     io_open_channel      ; $fe6e cd 27 e8        ; 
             xor      a,a                  ; $fe71 af              ; 
             push     af                   ; $fe72 f5              ; 
             jr       skipfe80             ; $fe73 18 0b           ; 

;
; LIST statement.  Parse optional line range.  Walk all lines:
; skip lines before start; print line number + detokenised text
; via callfefe / basic_detokenize_token; stop at end or on Ctrl-C.
;
inst_list:   push     af                   ; $fe75 f5              ; 
             cp       a,$40                ; $fe76 fe 40           ; 
             jr       nz,skipfe7b          ; $fe78 20 01           ; 
             inc      hl                   ; $fe7a 23              ; 
skipfe7b:    dec      hl                   ; $fe7b 2b              ; 
             rst      rst0010              ; $fe7c d7              ; 
             call     fs_dir_open          ; $fe7d cd 1c e8        ; 
skipfe80:    rst      rst0038              ; $fe80 ff              ; 
             add      a,e                  ; $fe81 83              ; 
             pop      iy                   ; $fe82 fd e1           ; 
             dec      hl                   ; $fe84 2b              ; 
             rst      rst0010              ; $fe85 d7              ; 
             pop      bc                   ; $fe86 c1              ; 
             call     basic_parse_line_range ; $fe87 cd f1 f2        ; 
             push     bc                   ; $fe8a c5              ; 
loopfe8b:    ld       hl,$ffff             ; $fe8b 21 ff ff        ; 
             ld       ($01db),hl           ; $fe8e 22 db 01        ; 
             pop      hl                   ; $fe91 e1              ; 
             pop      de                   ; $fe92 d1              ; 
             ld       c,(hl)               ; $fe93 4e              ; 
             inc      hl                   ; $fe94 23              ; 
             ld       b,(hl)               ; $fe95 46              ; 
             inc      hl                   ; $fe96 23              ; 
             ld       a,b                  ; $fe97 78              ; 
             or       a,c                  ; $fe98 b1              ; 
             jr       z,skipfeef           ; $fe99 28 54           ; 
             call     ctrlc_io_service     ; $fe9b cd 00 c0        ; 
             push     bc                   ; $fe9e c5              ; 
             ld       c,(hl)               ; $fe9f 4e              ; 
             inc      hl                   ; $fea0 23              ; 
             ld       b,(hl)               ; $fea1 46              ; 
             inc      hl                   ; $fea2 23              ; 
             push     bc                   ; $fea3 c5              ; 
             ex       (sp),hl              ; $fea4 e3              ; 
             ex       de,hl                ; $fea5 eb              ; 
             rst      rst0020              ; $fea6 e7              ; 
             pop      bc                   ; $fea7 c1              ; 
             jr       c,skipfeee           ; $fea8 38 44           ; 
             ex       (sp),hl              ; $feaa e3              ; 
             push     hl                   ; $feab e5              ; 
             push     bc                   ; $feac c5              ; 
             ex       de,hl                ; $fead eb              ; 
             push     hl                   ; $feae e5              ; 
             call     io_channel_crlf      ; $feaf cd 23 e9        ; 
             rst      rst0038              ; $feb2 ff              ; 
             adc      a,(hl)               ; $feb3 8e              ; 
             pop      hl                   ; $feb4 e1              ; 
             call     print_uint16_decimal ; $feb5 cd 98 bb        ; 
             pop      hl                   ; $feb8 e1              ; 
             ld       a,(hl)               ; $feb9 7e              ; 
             cp       a,$09                ; $feba fe 09           ; 
             jr       z,skipfec1           ; $febc 28 03           ; 
             ld       a,$20                ; $febe 3e 20           ; 
             rst      rst0028              ; $fec0 ef              ; 
skipfec1:    call     detokenize_line      ; $fec1 cd fe fe        ; 
             ld       hl,$00d5             ; $fec4 21 d5 00        ; 
             call     print_c_string       ; $fec7 cd f7 fe        ; 
             push     iy                   ; $feca fd e5           ; 
             pop      af                   ; $fecc f1              ; 
             cp       a,$40                ; $fecd fe 40           ; 
             jr       nz,loopfe8b          ; $fecf 20 ba           ; 
             call     kbd_read_char        ; $fed1 cd c5 c8        ; 
             jr       nc,loopfe8b          ; $fed4 30 b5           ; 
             ld       a,($003b)            ; $fed6 3a 3b 00        ; 
             and      a,a                  ; $fed9 a7              ; 
             jr       nz,skipfeed          ; $feda 20 11           ; 
             call     call0057             ; $fedc cd 57 00        ; 
             call     reset_run_mode_for_ready ; $fedf cd bc f2        ; 
             call     clear_exec_for_ready ; $fee2 cd cc f2        ; 
             ld       l,$00                ; $fee5 2e 00           ; 
             call     callec05             ; $fee7 cd 05 ec        ; 
             jp       jumpf24f             ; $feea c3 4f f2        ; 

skipfeed:    pop      bc                   ; $feed c1              ; 
skipfeee:    pop      bc                   ; $feee c1              ; 
skipfeef:    call     io_channel_crlf      ; $feef cd 23 e9        ; 
             rst      rst0038              ; $fef2 ff              ; 
             add      a,(hl)               ; $fef3 86              ; 
             jp       jumpf23d             ; $fef4 c3 3d f2        ; 

;
; print_c_string — emit a NUL-terminated string through RST $28
; Walks bytes at HL until the terminating zero and outputs each one via
; the active character-output hook.
;
print_c_string: ld       a,(hl)               ; $fef7 7e              ; 
             or       a,a                  ; $fef8 b7              ; 
             ret      z                    ; $fef9 c8              ; 

             rst      rst0028              ; $fefa ef              ; 
             inc      hl                   ; $fefb 23              ; 
             jr       print_c_string       ; $fefc 18 f9           ; 

;
; callfefe — BASIC detokenizer (LIST output formatter)
; Converts one tokenized BASIC line to printable text in a buffer.
; Input: HL = pointer into tokenized program memory.
; BC = output buffer pointer.
; D  = max output bytes ($FF = unlimited).
; $01DA = state flags: bit 0 = inside string literal, bit 1 = after DATA,
; bit 2 = after REM, bit 3 = colon-seen marker.
; 
; Main loop (skipff0c): read byte from HL; if zero → end of line (RET).
; ASCII bytes ($00–$7F):
; `"` ($22): toggle bit 0 of $01DA (in-string).
; `:` ($3A): check in-string flag (bit 0); if not in string → check for
; `:REM` / `:ELSE` patterns (callff6d/callff77).
; Other ASCII: copy as-is to (BC).
; Token bytes ($80–$FF):
; $83 (DATA): set bit 1 of $01DA via callff6d.
; $8E (REM): set bit 2 of $01DA via callff77.
; $90 (ELSE): expand to "ELSE" string (callcc12).
; $FF: two-byte extended token — check if previous 4 chars in buffer are
; `:REM` → output $FF literally and skip; otherwise continue.
; Otherwise (token $80–$FE): compute index = token − $7F; walk the
; keyword table (keywords at $EE83) skipping (index−1) entries;
; output keyword text, masking off the bit-7 start marker.
; 
; callfef7 ($FEF7): print null-terminated string from HL via RST $28.
; 
; Convert one tokenized BASIC line to ASCII.  Token bytes $80–$FE
; are expanded to keyword names from the table at $EE83.  String
; literals are passed through unchanged.  DATA/REM tokens set
; context flags to suppress further token expansion after them.
; Used by inst_list and inst_llist.
;
detokenize_line: ld       bc,$00d5             ; $fefe 01 d5 00        ; 
             ld       d,$ff                ; $ff01 16 ff           ; 
             xor      a,a                  ; $ff03 af              ; 
             ld       ($01da),a            ; $ff04 32 da 01        ; 
             jr       basic_detokenize_next ; $ff07 18 03           ; 

loopff09:    inc      bc                   ; $ff09 03              ; 
             dec      d                    ; $ff0a 15              ; 
             ret      z                    ; $ff0b c8              ; 

;
; basic_detokenize_next — main detokenizer byte loop
; Reads the next stored program byte, copies plain ASCII straight to
; the LIST buffer, toggles the in-string flag on `"`, and dispatches
; token bytes ($80-$ff) to the keyword-expansion path below.  Returns
; when the line's terminating $00 byte has been copied.
;
basic_detokenize_next: ld       a,(hl)               ; $ff0c 7e              ; 
             inc      hl                   ; $ff0d 23              ; 
             or       a,a                  ; $ff0e b7              ; 
             ld       (bc),a               ; $ff0f 02              ; 
             ret      z                    ; $ff10 c8              ; 

             cp       a,$22                ; $ff11 fe 22           ; 
             jr       nz,skipff1f          ; $ff13 20 0a           ; 
             ld       a,($01da)            ; $ff15 3a da 01        ; 
             xor      a,$01                ; $ff18 ee 01           ; 
             ld       ($01da),a            ; $ff1a 32 da 01        ; 
             ld       a,$22                ; $ff1d 3e 22           ; 
skipff1f:    cp       a,$3a                ; $ff1f fe 3a           ; 
             jr       nz,skipff31          ; $ff21 20 0e           ; 
             ld       a,($01da)            ; $ff23 3a da 01        ; 
             rra                           ; $ff26 1f              ; 
             jr       c,skipff2f           ; $ff27 38 06           ; 
             rla                           ; $ff29 17              ; 
             and      a,$fd                ; $ff2a e6 fd           ; 
             ld       ($01da),a            ; $ff2c 32 da 01        ; 
skipff2f:    ld       a,$3a                ; $ff2f 3e 3a           ; 
skipff31:    or       a,a                  ; $ff31 b7              ; 
             jp       p,loopff09           ; $ff32 f2 09 ff        ; 
             ld       a,($01da)            ; $ff35 3a da 01        ; 
             rra                           ; $ff38 1f              ; 
             jr       c,loopff09           ; $ff39 38 ce           ; 
             dec      hl                   ; $ff3b 2b              ; 
             rra                           ; $ff3c 1f              ; 
             rra                           ; $ff3d 1f              ; 
             jr       nc,skipff7e          ; $ff3e 30 3e           ; 
             ld       a,(hl)               ; $ff40 7e              ; 
             cp       a,$ff                ; $ff41 fe ff           ; 
             push     hl                   ; $ff43 e5              ; 
             push     bc                   ; $ff44 c5              ; 
             ld       hl,$ff67             ; $ff45 21 67 ff        ; 
             push     hl                   ; $ff48 e5              ; 
             ret      nz                   ; $ff49 c0              ; 

             dec      bc                   ; $ff4a 0b              ; 
             ld       a,(bc)               ; $ff4b 0a              ; 
             cp       a,$4d                ; $ff4c fe 4d           ; 
             ret      nz                   ; $ff4e c0              ; 

             dec      bc                   ; $ff4f 0b              ; 
             ld       a,(bc)               ; $ff50 0a              ; 
             cp       a,$45                ; $ff51 fe 45           ; 
             ret      nz                   ; $ff53 c0              ; 

             dec      bc                   ; $ff54 0b              ; 
             ld       a,(bc)               ; $ff55 0a              ; 
             cp       a,$52                ; $ff56 fe 52           ; 
             ret      nz                   ; $ff58 c0              ; 

             dec      bc                   ; $ff59 0b              ; 
             ld       a,(bc)               ; $ff5a 0a              ; 
             cp       a,$3a                ; $ff5b fe 3a           ; 
             ret      nz                   ; $ff5d c0              ; 

             pop      af                   ; $ff5e f1              ; 
             pop      af                   ; $ff5f f1              ; 
             pop      hl                   ; $ff60 e1              ; 
             inc      d                    ; $ff61 14              ; 
             inc      d                    ; $ff62 14              ; 
             inc      d                    ; $ff63 14              ; 
             inc      d                    ; $ff64 14              ; 
             jr       basic_detokenize_token ; $ff65 18 25           ; 

             defb     $c1,$e1,$7e                                  ; ..~        ; 
loopff6a:    inc      hl                   ; $ff6a 23              ; 
             jr       loopff09             ; $ff6b 18 9c           ; 

;
; basic_detokenize_after_data — suppress further keyword expansion after DATA
; Sets bit 1 in the shared detokenizer state byte at $01da.  Once DATA
; has been emitted, later bytes on the same line are treated as literal
; text so commas, signs, and names inside DATA items are not re-tokenized.
;
basic_detokenize_after_data: ld       a,($01da)            ; $ff6d 3a da 01        ; 
             or       a,$02                ; $ff70 f6 02           ; 
loopff72:    ld       ($01da),a            ; $ff72 32 da 01        ; 
             xor      a,a                  ; $ff75 af              ; 
             ret                           ; $ff76 c9              ; 

;
; basic_detokenize_after_rem — suppress further keyword expansion after REM
; Sets bit 2 in $01da to mark that the remainder of the line is a REM
; comment.  LIST then copies following bytes literally until end of line.
;
basic_detokenize_after_rem: ld       a,($01da)            ; $ff77 3a da 01        ; 
             or       a,$04                ; $ff7a f6 04           ; 
             jr       loopff72             ; $ff7c 18 f4           ; 

skipff7e:    rla                           ; $ff7e 17              ; 
             jr       c,loopff6a           ; $ff7f 38 e9           ; 
             ld       a,(hl)               ; $ff81 7e              ; 
             cp       a,$83                ; $ff82 fe 83           ; 
             call     z,basic_detokenize_after_data ; $ff84 cc 6d ff        ; 
             cp       a,$8e                ; $ff87 fe 8e           ; 
             call     z,basic_detokenize_after_rem ; $ff89 cc 77 ff        ; 
;
; basic_detokenize_token — expand one stored token to printable text
; Handles special detokenizer cases first (`ELSE`, DATA, REM, and the
; extended $ff escape), then converts ordinary token bytes into keyword
; text by indexing through the packed keyword tables starting at $ee83.
;
basic_detokenize_token: ld       a,(hl)               ; $ff8c 7e              ; 
             inc      hl                   ; $ff8d 23              ; 
             cp       a,$90                ; $ff8e fe 90           ; 
             call     z,callcc12           ; $ff90 cc 12 cc        ; 
             sub      a,$7f                ; $ff93 d6 7f           ; 
             push     hl                   ; $ff95 e5              ; 
             ld       e,a                  ; $ff96 5f              ; 
             ld       hl,keywords          ; $ff97 21 83 ee        ; 
loopff9a:    ld       a,(hl)               ; $ff9a 7e              ; 
             inc      hl                   ; $ff9b 23              ; 
             or       a,a                  ; $ff9c b7              ; 
             jp       p,loopff9a           ; $ff9d f2 9a ff        ; 
             dec      e                    ; $ffa0 1d              ; 
             jr       nz,loopff9a          ; $ffa1 20 f7           ; 
             and      a,$7f                ; $ffa3 e6 7f           ; 
jumpffa5:    ld       (bc),a               ; $ffa5 02              ; 
             inc      bc                   ; $ffa6 03              ; 
             dec      d                    ; $ffa7 15              ; 
             jp       z,jumpd5db           ; $ffa8 ca db d5        ; 
             ld       a,(hl)               ; $ffab 7e              ; 
             inc      hl                   ; $ffac 23              ; 
             or       a,a                  ; $ffad b7              ; 
             jp       p,jumpffa5           ; $ffae f2 a5 ff        ; 
             pop      hl                   ; $ffb1 e1              ; 
             jp       basic_detokenize_next ; $ffb2 c3 0c ff        ; 

;
; basic_delete_line — remove a stored BASIC line and compact program text
; Closes a gap by copying the remainder of program memory downward over
; a line that is being replaced or deleted, then collapses the
; end-of-program / variable-start boundary pointers at $0322/$0324/$0326
; to the new top.  This is the shared compaction helper behind empty
; numbered lines and line replacement from READY mode.
;
basic_delete_line: ex       de,hl                ; $ffb5 eb              ; 
             ld       hl,($0322)           ; $ffb6 2a 22 03        ; 
loopffb9:    ld       a,(de)               ; $ffb9 1a              ; 
             ld       (bc),a               ; $ffba 02              ; 
             inc      bc                   ; $ffbb 03              ; 
             inc      de                   ; $ffbc 13              ; 
             rst      rst0020              ; $ffbd e7              ; 
             jr       nz,loopffb9          ; $ffbe 20 f9           ; 
             ld       h,b                  ; $ffc0 60              ; 
             ld       l,c                  ; $ffc1 69              ; 
             ld       ($0322),hl           ; $ffc2 22 22 03        ; 
             ld       ($0324),hl           ; $ffc5 22 24 03        ; 
             ld       ($0326),hl           ; $ffc8 22 26 03        ; 
             ret                           ; $ffcb c9              ; 

;
; ---------------------------------------------------------------------------
; Shared expression-evaluation helpers used by many instructions
; ---------------------------------------------------------------------------
; callffcc ($FFCC): eval expression → DE = 16-bit integer/address (used by
; POKE addr, OUT port,val, etc.)
; callfe5e ($FE5E): eval expression → A = 8-bit integer in E; error if
; result doesn't fit in a signed byte (used by LOCATE, BEEP, etc.)
; callfe51 ($FE51): eval expression → D:E = 16-bit signed integer
; callfe08 ($FE08): guard — error $0C if $01DB == $FFFF (direct mode only,
; used by DEFFN, INPUT with optional prompt)
; 
; Evaluate expression → convert result to 16-bit integer in DE.
; Used wherever an integer address or port number is needed.
;
eval_expr_to_addr: call     eval_expression      ; $ffcc cd 2d f9        ; 
             push     hl                   ; $ffcf e5              ; 
             call     coerce_accumulator_to_addr_word ; $ffd0 cd d6 ff        ; 
             ex       de,hl                ; $ffd3 eb              ; 
             pop      hl                   ; $ffd4 e1              ; 
             ret                           ; $ffd5 c9              ; 

;
; coerce_accumulator_to_addr_word — convert the current numeric result to a
; 16-bit address / port word
; Accepts integers directly, otherwise normalises single/double values and
; checks they fit the address-range conversion constants before finishing
; through the shared integer-promotion tail at $cda9.
;
coerce_accumulator_to_addr_word: ld       bc,fn_cint           ; $ffd6 01 e0 ca        ; 
             push     bc                   ; $ffd9 c5              ; 
             rst      rst0030              ; $ffda f7              ; 
             ret      m                    ; $ffdb f8              ; 

             rst      rst0018              ; $ffdc df              ; 
             ret      m                    ; $ffdd f8              ; 

             call     fn_csng              ; $ffde cd 08 cb        ; 
             ld       bc,$3245             ; $ffe1 01 45 32        ; 
             ld       de,$8076             ; $ffe4 11 76 80        ; 
             call     callca7b             ; $ffe7 cd 7b ca        ; 
             ret      c                    ; $ffea d8              ; 

             ld       bc,$6545             ; $ffeb 01 45 65        ; 
             ld       de,$6053             ; $ffee 11 53 60        ; 
             call     callca7b             ; $fff1 cd 7b ca        ; 
             jp       nc,basic_raise_error_06 ; $fff4 d2 bc f1        ; 
             ld       bc,$65c5             ; $fff7 01 c5 65        ; 
             ld       de,$6053             ; $fffa 11 53 60        ; 
             jp       fp_add_int_work_operands ; $fffd c3 a9 cd        ; 

gpr_cursor_state EQU      $0003  ; gpr_cursor_state — low-RAM GPR cursor / geometry state word
                             ; The hidden `GPR:` output block at $ced6 treats $0003/$0004
                             ; as one
                             ; packed state word.  The low byte is the current horizontal
                             ; dot /
                             ; column offset within the line; the high byte at $0004 is
                             ; the fixed
                             ; line span used for wrap and geometry calculations
                             ; (initialised to
                             ; $50 by gpr_open_channel).
gpr_line_span EQU      $0004  ; gpr_line_span — high byte of gpr_cursor_state
                             ; Shared with gpr_put_char and gpr_driver_cmd_01_get_column
                             ; as the
                             ; per-line span constant.  In the default open state it is
                             ; $50.
gpr_char_step EQU      $0005  ; gpr_char_step — GPR horizontal step / `S` parameter
                             ; Seeded to $02 by gpr_open_channel and updated by the GPR
                             ; control
                             ; dispatcher when it emits an `S<n>` setup command.
rst0008      EQU      $0008
rst0010      EQU      $0010
rst0018      EQU      $0018
rst0020      EQU      $0020
rst0028      EQU      $0028
rst0030      EQU      $0030
rst0038      EQU      $0038
call003f     EQU      $003f
call0042     EQU      $0042
call0057     EQU      $0057
jump005d     EQU      $005d
call0069     EQU      $0069
call006c     EQU      $006c
call0072     EQU      $0072
call0075     EQU      $0075
call0078     EQU      $0078
call007e     EQU      $007e
jump0081     EQU      $0081
jump0084     EQU      $0084
fn_screen    EQU      $0087  ; fn_screen — SCREEN function (RAM vector)
                             ; SCREEN(col, row) — read the character code at a text-screen
                             ; cell.
                             ; The expression parser routes token $cd here through the RAM
                             ; vector,
                             ; so the shared ROM body at $e403 doubles as the SCREEN()
                             ; function
                             ; implementation as well as syscall slot 16.
fn_point     EQU      $0093  ; fn_point — POINT function
                             ; POINT(x, y) — return the pixel colour at screen coordinate
                             ; (x, y) (0 = off/background, non-zero = on/foreground).
                             ; Dispatched via the RAM vector at $0093 (installed from
                             ; rst_init_block at startup).  The actual implementation
                             ; resides in ROM at $ce05 and is accessed indirectly so that
                             ; different display hardware can be supported by patching
                             ; the RAM vector.
                             ; Two numeric arguments are evaluated before dispatch
                             ; (handled by the expression evaluator upstream of
                             ; jumpfba9).
jump0096     EQU      $0096
inst_paint   EQU      $0099  ; inst_paint — PAINT keyword vector (RAM slot 22)
                             ; The BASIC keyword dispatcher routes PAINT to RAM $0099.
                             ; In this ROM that slot is an alias of lcd_cmd_dispatch
                             ; rather than
                             ; a dedicated BASIC-side seed/fill parser, so the PAINT
                             ; front-end
                             ; appears to be reserved or stubbed out for device-specific
                             ; firmware.
                             ; 
                             ; ;
                             ; ============================================================
                             ; ; Syscall dispatch table — ROM handler annotations
                             ; ; Slots 0–28 of the table at $C732 (RAM $0057–$00AB)
                             ; ;
                             ; ============================================================
jump009f     EQU      $009f
jump00a2     EQU      $00a2
call00a8     EQU      $00a8
call00ab     EQU      $00ab
