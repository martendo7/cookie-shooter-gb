INCLUDE "defines.inc"

SECTION "VBlank Interrupt", ROM0[$0040]

    jp      VBlankHandler

SECTION "VBlank Handler", ROM0

VBlankHandler:
    push    af
    push    bc
    push    de
    push    hl
    
    ld      a, HIGH(wShadowOAM)
    lb      bc, (OAM_COUNT * sizeof_OAM_ATTRS) / DMA_LOOP_CYCLES + 1, LOW(rDMA)
    call    hOAMDMA
    
    ; Disable objects for status bar
    ld      hl, rLCDC
    res     LCDCB_OBJ, [hl]
    ld      l, LOW(hVBlankFlag)
    ld      [hl], h         ; Non-zero
    
    ldh     a, [hFadeState]
    ASSERT NOT_FADING == -1
    inc     a       ; a = -1
    ; Currently fading, nothing is changing
    jr      nz, .noStatus
    
    ldh     a, [hGameState]
    cp      a, GAME_STATE_IN_GAME
    jr      c, .noStatus
    jr      nz, .notInGame  ; Only draw hearts + power-ups in-game
    
    ; Draw hearts (player's lives)
    call    DrawHearts
    
    ; Draw power-ups
    ldh     a, [hGameMode]
    ASSERT GAME_MODE_CLASSIC == 0
    and     a, a
    jr      z, .noPowerUps
    
    ASSERT GAME_MODE_COUNT - 1 == 1
    ld      hl, vPowerUps
    ld      de, SCRN_VX_B
    
    ldh     a, [hPowerUps.0]
    ld      b, 0
    call    DrawPowerUp
    ldh     a, [hPowerUps.1]
    ld      b, 1
    call    DrawPowerUp
    ldh     a, [hPowerUps.2]
    ld      b, 2
    call    DrawPowerUp
    
    ld      hl, vCurrentPowerUp
    ldh     a, [hCurrentPowerUp]
    ld      b, -1
    call    DrawPowerUp
    
.noPowerUps
.notInGame
    ; Draw score and cookies blasted
    ld      de, hScore
    ld      hl, vScore
    ld      c, SCORE_BYTE_COUNT
    call    DrawStatusBarBCD
    ASSERT hCookiesBlasted == hScore.end
    ld      hl, vCookiesBlasted
    ld      c, COOKIES_BLASTED_BYTE_COUNT
    call    DrawStatusBarBCD
.noStatus
    
    call    UpdateFade
    
    ; Read joypad
    ld      a, P1F_GET_DPAD
    call    .readPadNibble
    swap    a           ; Move directions to high nibble
    ld      b, a
    
    ld      a, P1F_GET_BTN
    call    .readPadNibble
    xor     a, b        ; Combine buttons and directions + complement
    ld      b, a
    
    ld      a, [hPressedKeys]
    xor     a, b        ; a = keys that changed state
    and     a, b        ; a = keys that changed to pressed
    ld      [hNewKeys], a
    ld      a, b
    ld      [hPressedKeys], a
    
    ld      a, P1F_GET_NONE
    ldh     [rP1], a
    
    call    SoundSystem_Process
    
    pop     hl
    pop     de
    pop     bc
    pop     af
    reti

; @param a  Byte to write to rP1
; @return a  Reading from rP1, ignoring non-input bits
.readPadNibble
    ldh     [rP1], a
    ; Burn 16 cycles between write and read
    call    .ret        ; 10 cycles
    ldh     a, [rP1]    ; 3 cycles
    ldh     a, [rP1]    ; 3 cycles
    ldh     a, [rP1]    ; Read
    or      a, $F0      ; Ignore non-input bits
.ret
    ret

SECTION "STAT Interrupt", ROM0[$0048]

STATHandler:
    push    af
    push    hl
.waitHBL
    ldh     a, [rSTAT]
    and     a, STAT_MODE_MASK
    jr      nz, .waitHBL    ; Mode 0 - HBlank
    
    ld      hl, rLCDC
    ldh     a, [rLY]
    cp      a, STATUS_BAR_HEIGHT - 1
    jr      z, .endOfStatusBar
    cp      a, PAUSED_STRIP_Y - 1
    jr      z, .startOfPausedStrip
    
    ; End of "paused" strip
    ld      a, STATUS_BAR_HEIGHT - 1
    ldh     [rLYC], a
    jr      .enableObj
.endOfStatusBar
    ldh     a, [hGameState]
    cp      a, GAME_STATE_PAUSED
    jr      nz, .enableObj
    ; Game is paused, set rLYC for "paused" strip
    ld      a, PAUSED_STRIP_Y - 1
    ldh     [rLYC], a
.enableObj
    ; Enable objects - end of status bar or "paused" strip
    set     LCDCB_OBJ, [hl]
    jr      .finished
.startOfPausedStrip
    ld      a, PAUSED_STRIP_Y + PAUSED_STRIP_HEIGHT - 1
    ldh     [rLYC], a
    ; Disable objects - start of "paused" strip
    res     LCDCB_OBJ, [hl]
.finished
    pop     hl
    
    ; Return at the start of HBlank for any code that waits for VRAM to
    ; become accessible, since this interrupt handler might be called
    ; while waiting
:
    ; Wait for mode 3, which comes before HBlank
    ldh     a, [rSTAT]
    ; (%11 + 1) & %11 == 0
    inc     a
    and     a, STAT_MODE_MASK
    jr      nz, :-
    
:
    ; Wait for HBlank -> ensured the beginning of HBlank by above
    ldh     a, [rSTAT]
    and     a, STAT_MODE_MASK
    jr      nz, :-
    
    ; This interrupt handler should return with at least 16 cycles left
    ; of accessible VRAM, which is what any VRAM accessibility-waiting
    ; code would assume it has
    
    ; Remaining time = Minimum HBlank time - Loop above + Mode 2 time
    ;                = 21 cycles - 4 cycles + 20 cycles
    ;                = 37 cycles
    
    pop     af  ; 3 cycles
    reti        ; 4 cycles
    
    ; 30 remaining VRAM-accessible cycles
    
    ; Not waiting for specifically the beginning of HBlank (i.e. just
    ; waiting for HBlank) would result in 30 - 21 (HBlank) = only 9
    ; cycles!!!
