DEF COOKIE_MIN_SPEED_Y EQU $0C
DEF COOKIE_MAX_SPEED_Y EQU $20
DEF COOKIE_SPEED_Y_MASK EQU %0001_1111
DEF COOKIE_MIN_SPEED_X EQU $00
DEF COOKIE_MAX_SPEED_X EQU $10
DEF COOKIE_SPEED_X_MASK EQU %1111_1111

DEF COOKIE_WIDTH EQU 16
DEF COOKIE_HEIGHT EQU 16

RSRESET
DEF COOKIE_SIZE_16 RB 1
DEF COOKIE_SIZE_14 RB 1
DEF COOKIE_SIZE_12 RB 1
DEF COOKIE_SIZE_10 RB 1
DEF COOKIE_SIZE_8 RB 1
DEF COOKIE_SIZE_COUNT EQU _RS

; COOKIE_SIZE_COUNT - 1 = %100
DEF COOKIE_SIZE_MASK EQU %111

DEF COOKIE_START_Y EQU STATUS_BAR_HEIGHT - COOKIE_HEIGHT

DEF COOKIE_TILE EQU 4
DEF COOKIE_TILES_START EQU COOKIE_TILE
DEF COOKIE_OBJ_COUNT EQU 2
DEF COOKIE_TILE_COUNT EQU COOKIE_OBJ_COUNT * 2
DEF MAX_COOKIE_OBJ_COUNT EQU OAM_COUNT - MAX_LASER_OBJ_COUNT - PLAYER_OBJ_COUNT
DEF MAX_COOKIE_SPRITE_COUNT EQU MAX_COOKIE_OBJ_COUNT / COOKIE_OBJ_COUNT
DEF MAX_COOKIE_COUNT EQU MAX_COOKIE_SPRITE_COUNT

DEF START_TARGET_COOKIE_COUNT EQU 3
DEF ADD_COOKIE_RATE EQU 5000
