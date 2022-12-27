;**********
; Main
;**********

.macro MAIN_INIT
    ; render background + palette
    LDA #(NMI_BKG + NMI_SCRL + NMI_PLT)
    STA nmi_flags
    LDA #(PPU_MASK_BKG + PPU_MASK_BKG8)
    STA PPU_MASK

    ; set palette
    LDA #$0F
    STA palettes+0
    LDA #$10
    STA palettes+2
    LDA #$30
    STA palettes+3
    LDA #$26
    STA palettes+6
    LDA #$21
    STA palettes+9
    LDA #$29
    STA palettes+12

    ; rleinc decode
    LDA #IMAGE_BNK
    STA MMC5_PRG_BNK0
    LDA #IMG_BUF_BNK
    STA MMC5_RAM_BNK
    LDA #<img_data
    STA tmp+0
    LDA #>img_data
    STA tmp+1
    LDA #<MMC5_RAM
    STA tmp+2
    LDA #>MMC5_RAM
    STA tmp+3
    JSR rleinc

    JSR img_bkg_draw

    JSR wait_next_frame

    ; load first dialog block
    LDA #DIALOG_BNK
    STA MMC5_PRG_BNK0
    STA lz_in_bnk
    LDA #<TEXT_PTR
    STA lz_in+0
    LDA #>TEXT_PTR
    STA lz_in+1
    JSR lz_decode

    ; init text read pointer
    LDA #<MMC5_RAM
    STA txt_rd_ptr+0
    LDA #>MMC5_RAM
    STA txt_rd_ptr+1

    ; - - - - - - - -
    ; init print variables
    ; - - - - - - - -
    ; ext value = 0
    LDA #$00
    STA print_ext_val
    ; print_counter = 0
    STA print_counter
    ;
    JSR read_next_dailog

    ; draw dialog box
    JSR draw_dialog_box

.endmacro

; use: A
wait_next_frame:
    ; wait for next frame to start
    @wait_vblank:
        BIT nmi_flags
        BPL @wait_vblank

    ; acknowledge nmi
    LDA nmi_flags
    AND #($FF-NMI_DONE)
    STA nmi_flags

    ; reset zp background index
    LDA #$00
    STA background_index

    RTS


MAIN:

    MAIN_INIT

    @main_loop:
    JSR wait_next_frame

    ; update player inputs
    JSR readjoy

    ; update text flags
    LDA buttons_1
    BEQ @no_input
        LDA txt_flags
        ORA #TXT_FLAG_INPUT
        STA txt_flags
        JMP @input_end
    @no_input:
        LDA txt_flags
        AND #($FF - TXT_FLAG_INPUT)
        STA txt_flags
    @input_end:

    ; read text
    JSR read_text

    ; loop back to start of main
    JMP @main_loop
