INCLUDE "defines.inc"

SECTION "Save Data Checksum Calculation", ROM0

CalcTopScoresChecksum::
    xor     a, a
    
    ld      hl, sClassicTopScores
    call    .calcChecksum
    
    ld      hl, sSuperTopScores
    ; Fallthrough

.calcChecksum
    ld      b, TOP_SCORE_COUNT * SCORE_BYTE_COUNT
.loop
    add     a, [hl]
    inc     l
    dec     b
    jr      nz, .loop
    ret

SECTION "Save Data Header String", ROM0

SaveDataHeader::
    DB SAVE_DATA_HEADER
.end::

; Save Data

SECTION "Save Data Header", SRAM

sSaveDataHeader::
    DS STRLEN(SAVE_DATA_HEADER)
.end::

SECTION "Classic Mode Top Scores", SRAM, ALIGN[8]

sClassicTopScores::
    DS TOP_SCORE_COUNT * SCORE_BYTE_COUNT
.end::

SECTION "Super Mode Top Scores", SRAM, ALIGN[8]

sSuperTopScores::
    DS TOP_SCORE_COUNT * SCORE_BYTE_COUNT
.end::

SECTION "Save Data Checksum", SRAM

sChecksum::
    DS 1
