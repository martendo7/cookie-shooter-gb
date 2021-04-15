DEF PLAYER_SPEED EQU 1

DEF PLAYER_WIDTH EQU 16
DEF PLAYER_HEIGHT EQU 16

DEF PLAYER_DEFAULT_Y EQU (SCRN_Y - 8 - 16) + 16
DEF PLAYER_DEFAULT_X EQU ((SCRN_X / 2) + 8) - (PLAYER_WIDTH / 2)
DEF PLAYER_TILE EQU 0

DEF PLAYER_OFFSET EQU sizeof_OAM_ATTRS * 0
RSSET PLAYER_OFFSET
DEF PLAYER_Y1_OFFSET RB 1
DEF PLAYER_X1_OFFSET RB 1
RSSET PLAYER_OFFSET + sizeof_OAM_ATTRS
DEF PLAYER_Y2_OFFSET RB 1
DEF PLAYER_X2_OFFSET RB 1

DEF PLAYER_OBJ_COUNT EQU 2
DEF PLAYER_END_OFFSET EQU PLAYER_OFFSET + (sizeof_OAM_ATTRS * PLAYER_OBJ_COUNT)