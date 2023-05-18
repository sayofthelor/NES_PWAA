;**********
; Constants
;**********

;----------
; PPU
;----------
PPU_CTRL   := $2000
PPU_MASK   := $2001
PPU_STATUS := $2002
PPU_SCROLL := $2005
PPU_ADDR   := $2006
PPU_DATA   := $2007

; PPU MASK
PPU_MASK_GREY = %00000001
PPU_MASK_BKG8 = %00000010
PPU_MASK_SPR8 = %00000100
PPU_MASK_BKG  = %00001000
PPU_MASK_SPR  = %00010000
PPU_MASK_R    = %00100000
PPU_MASK_G    = %01000000
PPU_MASK_B    = %10000000

; PPU CTRL
PPU_CTRL_NM_0     = %00000000
PPU_CTRL_NM_1     = %00000001
PPU_CTRL_NM_2     = %00000010
PPU_CTRL_NM_3     = %00000011
PPU_CTRL_INC      = %00000100
PPU_CTRL_SPR      = %00001000
PPU_CTRL_BKG      = %00010000
PPU_CTRL_SPR_SIZE = %00100000
PPU_CTRL_SEL      = %01000000
PPU_CTRL_NMI      = %10000000

; NAMETABLES
PPU_NAMETABLE_0 = $2000
PPU_NAMETABLE_1 = $2400
PPU_NAMETABLE_2 = $2800
PPU_NAMETABLE_3 = $2C00



;----------
; APU
;----------
APU := $4000

APU_SQ1_VOL   := $4000
APU_SQ1_SWEEP := $4001
APU_SQ1_LO    := $4002
APU_SQ1_HI    := $4003

APU_SQ2_VOL   := $4004
APU_SQ2_SWEEP := $4005
APU_SQ2_LO    := $4006
APU_SQ2_HI    := $4007

APU_TRI_LINEAR := $4008
APU_TRI_LO     := $400A
APU_TRI_HI     := $400B

APU_NOISE_VOL := $400C
APU_NOISE_LO  := $400E
APU_NOISE_HI  := $400F

APU_DMC_FREQ  := $4010
APU_DMC_RAW   := $4011
APU_DMC_START := $4012
APU_DMC_LEN   := $4013

APU_SND_CHN := $4015
APU_CTRL    := $4015
APU_STATUS  := $4015
APU_FRAME   := $4017



;----------
; OAM
;----------
OAMDMA := $4014



;----------
; IO
;----------
IO_JOY1 := $4016
IO_JOY2 := $4017

BTN_A      = %10000000
BTN_B      = %01000000
BTN_SELECT = %00100000
BTN_START  = %00010000
BTN_UP     = %00001000
BTN_DOWN   = %00000100
BTN_LEFT   = %00000010
BTN_RIGHT  = %00000001


;----------
; NMI
;----------
NMI_DONE = %10000000
NMI_FORCE= %01000000
NMI_SCRL = %00010000
NMI_PLT  = %00001000
NMI_ATR  = %00000100
NMI_SPR  = %00000010
NMI_BKG  = %00000001


;----------
; MMC5
;----------
; PRG Mode
MMC5_PRG_MODE  := $5100
; CHR Mode
MMC5_CHR_MODE  := $5101
; RAM protection
MMC5_RAM_PRO1  := $5102
MMC5_RAM_PRO2  := $5103
; Extended RAM mode
MMC5_EXT_RAM   := $5104
; Nametable mapping
MMC5_NAMETABLE := $5105
; Fill nametable
MMC5_FILL_TILE := $5106
MMC5_FILL_COL  := $5107
; RAM Bank
MMC5_RAM_BNK   := $5113
; PRG Banks
MMC5_PRG_BNK0  := $5114
MMC5_PRG_BNK1  := $5115
MMC5_PRG_BNK2  := $5116
MMC5_PRG_BNK3  := $5117
; CHR Banks
MMC5_CHR_BNK0  := $5120
MMC5_CHR_BNK1  := $5121
MMC5_CHR_BNK2  := $5122
MMC5_CHR_BNK3  := $5123
MMC5_CHR_BNK4  := $5124
MMC5_CHR_BNK5  := $5125
MMC5_CHR_BNK6  := $5126
MMC5_CHR_BNK7  := $5127
MMC5_CHR_BNK8  := $5128
MMC5_CHR_BNK9  := $5129
MMC5_CHR_BNKA  := $512A
MMC5_CHR_BNKB  := $512B
MMC5_CHR_UPPER := $5130
; Vertical Split
MMC5_SPLT_MODE := $5200
MMC5_SPLT_SCRL := $5201
MMC5_SPLT_BNK  := $5202
; IRQ Scanline counter
MMC5_SCNL_VAL  := $5203
MMC5_SCNL_STAT := $5204
; Unsigned 8x8 to 16 Multiplier
MMC5_MUL_A     := $5205
MMC5_MUL_B     := $5206
; Expansion RAM
MMC5_EXP_RAM   := $5C00
; RAM
MMC5_RAM       := $6000


;----------
; Game
;----------
CODE_BNK     = $80
MUS_SFX      = $81
MUS_BNK      = $82
DPCM_BNK     = $84
IMG_BNK      = $85
TXT_BNK      = $C0
TEXT_BUF_BNK = $01
IMG_BUF_BNK  = $00
RAM_MAX_BNK  = 1

BTN_TIMER = 15

TXT_FLAG_WAIT  = %00000001
TXT_FLAG_INPUT = %00000010
TXT_FLAG_FORCE = %00000100
TXT_FLAG_BOX   = %00001000
TXT_FLAG_LZ    = %00010000
TXT_FLAG_PRINT = %00100000
TXT_FLAG_SKIP  = %01000000
TXT_FLAG_READY = %10000000

EFFECT_FLAG_FADE      = %00000001
EFFECT_FLAG_NT        = %00000100
EFFECT_FLAG_BKG       = %00001000
EFFECT_FLAG_DRAW      = %00010000
EFFECT_FLAG_BKG_MMC5  = %00100000
EFFECT_FLAG_PAL_SPLIT = %10000000

BOX_FLAG_HIDE    = %10000000
BOX_FLAG_NAME    = %00000010
BOX_FLAG_REFRESH = %00000001

BOX_TILE_TL = $00F1
BOX_TILE_T  = $00F2
BOX_TILE_TR = $00F3
BOX_TILE_L  = $00F4
BOX_TILE_M  = $00F5
BOX_TILE_R  = $00F6
BOX_TILE_BL = $00F7
BOX_TILE_B  = $00F8
BOX_TILE_BR = $00F9
BOX_UPPER_TILE = $C0

SCANLINE_FLAG_WAIT  = %10000000
SCANLINE_FLAG_FRAME = %01000000

SCANLINE_TOP     = %01000000
SCANLINE_TOP_IMG = %01000001
SCANLINE_MID_IMG = %01000010
SCANLINE_DIALOG  = %01000011
SCANLINE_BOT_IMG = %00000100
SCANLINE_BOT     = %00000101

IMG_HEADER_CHR   = %00000011
IMG_HEADER_SPR   = %00010000
IMG_HEADER_BKG   = %00100000
IMG_HEADER_PAL   = %01000000
IMG_HEADER_FULL  = %10000000

NT_MAPPING_EMPTY   = %11111111
NT_MAPPING_NT1     = %11110100
DEFAULT_NT_MAPPING = NT_MAPPING_EMPTY

FADE_TIME = $3F
FLASH_TIME = $04

IMG_PARTIAL_MAX_BUF_LEN = $40

RES_SPR = 1

SEGMENT_IMGS_START_ADR = $A000

IMG_CHR_BUF_LO  = MMC5_RAM + $000
IMG_CHR_BUF_HI  = MMC5_RAM + $300
IMG_CHR_BUF_SPR = MMC5_RAM + $600
IMG_BKG_BUF_LO  = MMC5_RAM + $900
IMG_BKG_BUF_HI  = MMC5_RAM + $C00

NAME_CHR_BANK = $C0
NAME_PPU_ADR = $2342

SFX_BNK_OFF = 1  ; $8000
MUS_BNK_OFF = 2  ; $A000
DPCM_BNK_OFF = 3 ; $C000
