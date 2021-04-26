INCLUDE "defines.inc"

SECTION "Mode Select Scree", ROM0

LoadModeSelectScreen::
    ld      de, ModeSelectTiles
    ld      hl, _VRAM9000
    ld      bc, ModeSelectTiles.end - ModeSelectTiles
    call    LCDMemcopy
    ld      de, ModeSelectMap
    ld      hl, _SCRN0
    ld      c, SCRN_Y_B
    call    LCDMemcopyMap
    
    ld      a, CART_SRAM_ENABLE
    ld      [rRAMG], a
    
    ld      de, sClassicHighScore.end - 1
    ld      hl, vModeSelectClassicHighScore
    lb      bc, MODE_SELECT_NUMBER_TILES_START, SCORE_BYTE_COUNT
    call    LCDDrawBCDWithOffset
    ld      de, sSuperHighScore.end - 1
    ld      hl, vModeSelectSuperHighScore
    lb      bc, MODE_SELECT_NUMBER_TILES_START, SCORE_BYTE_COUNT
    call    LCDDrawBCDWithOffset
    
    ASSERT CART_SRAM_DISABLE == 0
    xor     a, a
    ld      [rRAMG], a
    
    ; May be coming from exiting a game, hide all objects but the first 2
    call    HideAllActors
    ; Selection cursor - a cookie!
    ; Object 1
    ld      hl, wShadowOAM + 1
    ld      [hl], MODE_SELECT_CURSOR_X
    inc     l
    ld      [hl], COOKIE_TILE
    inc     l
    ld      [hli], a        ; a = 0
    ; Object 2
    inc     l
    ld      [hl], MODE_SELECT_CURSOR_X + 8
    inc     l
    ld      [hl], COOKIE_TILE + 2
    inc     l
    ld      [hl], a         ; a = 0
    
    ; Set cursor position based on previously selected game mode
    ldh     a, [hGameMode]
    and     a, a
    jr      z, MoveSelectionUp.setPos
    jr      MoveSelectionDown.setPos

ModeSelect::
    ldh     a, [hNewKeys]
    bit     PADB_B, a
    jr      z, :+
    
    ; Return to title screen
    ASSERT GAME_STATE_TITLE_SCREEN == 0
    xor     a, a
    ld      hl, LoadTitleScreen
    call    StartFade
    jp      Main
    
:
    ldh     a, [hNewKeys]
    ld      b, a    ; Save in b because a will be overwritten
    bit     PADB_UP, b
    call    nz, MoveSelectionUp
    bit     PADB_DOWN, b
    call    nz, MoveSelectionDown
    ld      a, b
    and     a, PADF_A | PADF_START
    jr      z, :+
    
    ; Start game!
    ld      a, GAME_STATE_IN_GAME
    ld      hl, SetUpGame
    call    StartFade
    jp      Main
    
:
    call    HaltVBlank
    jp      Main

MoveSelectionUp:
    ldh     a, [hGameMode]
    and     a, a    ; Already at top
    ret     z
    
    dec     a
    ldh     [hGameMode], a
    
    ASSERT GAME_MODE_COUNT - 1 == 1
.setPos
    ld      a, MODE_SELECT_CLASSIC_CURSOR_Y
    ld      [wShadowOAM + MODE_SELECT_CURSOR_Y1_OFFSET], a
    ld      [wShadowOAM + MODE_SELECT_CURSOR_Y2_OFFSET], a
    
    ret
MoveSelectionDown:
    ldh     a, [hGameMode]
    ASSERT GAME_MODE_COUNT - 1 == 1
    dec     a   ; Already at bottom
    ret     z
    
    inc     a   ; Undo dec
    inc     a
    ldh     [hGameMode], a
    
    ASSERT GAME_MODE_COUNT - 1 == 1
.setPos
    ld      a, MODE_SELECT_SUPER_CURSOR_Y
    ld      [wShadowOAM + MODE_SELECT_CURSOR_Y1_OFFSET], a
    ld      [wShadowOAM + MODE_SELECT_CURSOR_Y2_OFFSET], a
    
    ret
