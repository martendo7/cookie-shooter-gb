SECTION "System Routines", ROM0

; Copy a block of memory from one place to another
; @param de Pointer to beginning of block to copy
; @param hl Pointer to destination
; @param bc Number of bytes to copy
Memcopy::
    ld      a, [de]
    ld      [hli], a
    inc     de
    dec     bc
    ld      a, c
    or      a, b
    jr      nz, Memcopy
    ret
; @param de Pointer to beginning of block to copy
; @param hl Pointer to destination
; @param b  Number of bytes to copy
MemcopySmall::
    ld      a, [de]
    ld      [hli], a
    inc     de
    dec     b
    jr      nz, MemcopySmall
    ret

; Copy an arbitrary number of rows of map data to the visible background
; map, even if the LCD is on
; @param de Pointer to map data
; @param hl Pointer to destination
; @param c  Number of rows to copy
LCDMemcopyMap::
    ld      b, SCRN_X_B
.rowLoop
    ldh     a, [rSTAT]
    and     a, STATF_BUSY
    jr      nz, .rowLoop
    
    ld      a, [de]
    ld      [hli], a
    inc     de
    dec     b
    jr      nz, .rowLoop
    
    push    de
    ld      de, SCRN_VX_B - SCRN_X_B
    add     hl, de
    pop     de
    dec     c
    jr      nz, LCDMemcopyMap
    ret

; Set a block of memory to a single byte value
; @param hl Pointer to destination
; @param a  Byte value to use
; @param bc Number of bytes to set
Memset::
    ld      d, a
.loop
    ld      a, d
    ld      [hli], a
    dec     bc
    ld      a, c
    or      a, b
    jr      nz, .loop
    ret
; @param hl Pointer to destination
; @param a  Byte value to use
; @param b  Number of bytes to set
MemsetSmall::
    ld      [hli], a
    dec     b
    jr      nz, MemsetSmall
    ret
