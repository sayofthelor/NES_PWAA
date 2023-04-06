; params:
; - tmp+0: ppu adr
; - tmp+2: data ptr
; use: A, X, Y
img_bkg_draw_2lines:
    pushregs

    ; wait for the next frame
    JSR wait_next_frame
    ; init packet
    LDX background_index
    LDA #$40
    STA background, X
    INX
    LDA tmp+1
    STA background, X
    INX
    LDA tmp+0
    STA background, X
    INX
    ; fill packet
    for_y @loop, #0
        LDA (tmp+2), Y
        STA background, X
        INX
    to_y_inc @loop, #$40
    ; close packet
    LDA #$00
    STA background, X
    STX background_index

    pullregs
    RTS

; description:
;   draw the background part of the image
; use tmp[0..5]
img_bkg_draw:
    pushregs

    ; set bank
    mov MMC5_RAM_BNK, #IMG_BUF_BNK
    STA mmc5_banks+0
    ; init pointers
    sta_ptr tmp, (PPU_NAMETABLE_0+$60)
    sta_ptr tmp+2, IMG_BKG_BUF_LO
    ;
    LDA effect_flags
    AND #EFFECT_FLAG_DRAW
    BNE @flip_nt_end
        ; flip the nametable to use and set the EFFECT_FLAG_DRAW flag
        LDA effect_flags
        EOR #EFFECT_FLAG_NT
        ORA #EFFECT_FLAG_DRAW
        STA effect_flags
    @flip_nt_end:
    ; and offset the ppu pointer if needed
    LDA effect_flags
    AND #EFFECT_FLAG_NT
    ORA tmp+1
    STA tmp+1

    ; - - - - - - - -
    ; copy buffer to screen
    ; - - - - - - - -
    ; find how many loop we need to do
    BIT box_flags
    BMI @dialog_box_off
    @dialog_box_on:
        LDX #8
        JMP @loop
    @dialog_box_off:
        LDX #12
    ; start the loop
    @loop:
        ; draw 2 lines on the PPU nametable
        JSR img_bkg_draw_2lines

        ; update pointers
        add_A2ptr tmp, #$40
        add_A2ptr tmp+2, #$40

        ; continue
        DEX
        bnz @loop


    ; skip MMC5 update if any character is currently drawn
    ora_adr effect_flags, #EFFECT_FLAG_BKG_MMC5 ; pre-enable flag
    LDA img_character
    BNE @end
    LDA img_animation
    BNE @end
        ;
        sta_ptr tmp, IMG_BKG_BUF_HI
        JSR cp_2_mmc5_exp
        ;
        and_adr effect_flags, #($FF-EFFECT_FLAG_BKG_MMC5) ; reset the flag
        ; clear the EFFECT_FLAG_DRAW flag
        and_adr effect_flags, #($FF - EFFECT_FLAG_DRAW)
        ;
        JSR update_screen_scroll

    @end:
    pullregs
    RTS

; A = nametable high address
img_draw_bot_lo:
    PHA

    ; set ppu pointer
    STA tmp+1
    mov tmp+0, #$60
    ; set data pointer
    sta_ptr tmp+2, (IMG_BKG_BUF_LO+$200)
    ; draw 2 lines
    JSR img_bkg_draw_2lines
    ; draw another 2 lines
    add_A2ptr tmp+0, #$40
    add_A2ptr tmp+2, #$40
    JSR img_bkg_draw_2lines
    ; draw another 2 lines
    add_A2ptr tmp+0, #$40
    add_A2ptr tmp+2, #$40
    JSR img_bkg_draw_2lines
    ; draw last 2 lines
    add_A2ptr tmp+0, #$40
    add_A2ptr tmp+2, #$40
    JSR img_bkg_draw_2lines

    PLA
    RTS

; /!\ need to be in-frame
img_draw_bot_hi:
    PHA

    ; set exp pointer
    sta_ptr tmp+0, (MMC5_EXP_RAM+$260)
    ; set upper tiles pointer
    sta_ptr tmp+2, (IMG_BKG_BUF_HI+$200)

    ; copy upper tiles
    for_y @loop, #0
        LDA (tmp+2), Y
        STA (tmp+0), Y
    to_y_inc @loop, #0    

    PLA
    RTS
