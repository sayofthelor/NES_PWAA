scanline_irq_handler:
    pushregs

    ; priority to palette change
    LDA scanline
    CMP #SCANLINE_TOP_IMG
    BEQ @scanline_irq_dialog

    ; prepare the jump
    LDA scanline
    AND #$3F
    TAX
    LDA @jump_hi, X
    PHA
    LDA @jump_lo, X
    PHA
    ; set the new scanline state
    LDA @next_state, X
    STA scanline
    ; jump
    RTS

    @scanline_irq_top:
        ; set next scanline
        LDA #23
        STA MMC5_SCNL_VAL
        ; nametable mapping change done at the end of NMI
        ; (because we are too late at scanline 1 and we can't interrupt before without eating NMI time)
        LDA #NT_MAPPING_EMPTY
        STA MMC5_NAMETABLE
        ; return
        JMP @end
    @scanline_irq_top_img:
        ;
        LDA mmc5_upper_chr
        STA MMC5_CHR_UPPER
        ; set next scanline
        LDA #151
        STA MMC5_SCNL_VAL
        ; change nametable mapping
        LDA #NT_MAPPING_NT1
        STA MMC5_NAMETABLE
        ; return
        JMP @end
    @scanline_irq_dialog:
        AND #$3F
        TAX
        LDA @next_state, X
        STA scanline
        ; - - - - - - - -
        ; first scanline (151)
        ; - - - - - - - -
        ; test if we need to change palette
        BIT effect_flags
        BMI @palette_change_start
            LDA #215
            STA MMC5_SCNL_VAL
            JMP @end
        @palette_change_start:
        ; skipping 10 cpu cycles
        ROL 0
        ROR 0
        ; setup registers
        LDX #$16
        LDY #$26
        ; set high byte of address
        LDA #$3F
        STA PPU_ADDR
        ; disable rendering
        LDA #$00
        STA PPU_MASK
        ; set low byte of address
        STA PPU_ADDR
        ; send background color
        LDA #$0F
        STA PPU_DATA
        ; send 3 byte
        LDA #$06
        STA PPU_DATA
        STX PPU_DATA
        STY PPU_DATA
        ;
        LDA #$00
        STA MMC5_CHR_UPPER
        ; wait
        NOP
        LDX #$0F
        @dialog_wait_1:
            DEX
            bnz @dialog_wait_1

        ; - - - - - - - -
        ; second scanline (152)
        ; - - - - - - - -
        LDX #$12
        LDY #$22
        ; send 4 byte
        LDA #$0F
        STA PPU_DATA
        LDA #$02
        STA PPU_DATA
        STX PPU_DATA
        STY PPU_DATA
        ; wait
        LDX #$12
        @dialog_wait_2:
            DEX
            bnz @dialog_wait_2

        ; - - - - - - - -
        ; third scanline (153)
        ; - - - - - - - -
        LDX #$1A
        LDY #$2A
        ; send 4 byte
        LDA #$0F
        STA PPU_DATA
        LDA #$0A
        STA PPU_DATA
        STX PPU_DATA
        STY PPU_DATA
        ; wait
        LDX #$12
        @dialog_wait_3:
            DEX
            bnz @dialog_wait_3

        ; - - - - - - - -
        ; fourth scanline (154)
        ; - - - - - - - -
        LDX #$10
        LDY #$30
        ; send 4 byte
        LDA #$0F
        STA PPU_DATA
        LDA #$00
        STA PPU_DATA
        STX PPU_DATA
        STY PPU_DATA
        ; wait
        LDX #$11
        @dialog_wait_4:
            DEX
            bnz @dialog_wait_4

        ; - - - - - - - -
        ; fifth scanline (155)
        ; - - - - - - - -
        ; setup registers (scroll position)
        ; see NesDev wiki for explaination (https://www.nesdev.org/wiki/PPU_scrolling)
        ;    First      Second
        ; /¯¯¯¯¯¯¯¯¯\ /¯¯¯¯¯¯¯\
        ; 0 0yy NN YY YYY XXXXX
        ;   ||| || || ||| +++++-- coarse X scroll
        ;   ||| || ++-+++-------- coarse Y scroll
        ;   ||| ++--------------- nametable select
        ;   +++------------------ fine Y scroll
        LDX #$32
        LDY #$60
        ; restore ppu addr (scroll position)
        STX PPU_ADDR
        STY PPU_ADDR
        ; re-enable rendering without sprites
        LDA #(PPU_MASK_BKG + PPU_MASK_BKG8)
        STA PPU_MASK
        ; wait the next scanline
        LDX #$14
        @dialog_wait_5:
            DEX
            bnz @dialog_wait_5

        ; - - - - - - - -
        ; sixth scanline (156)
        ; - - - - - - - -
        ; re-enable rendering with sprites
        ; LDA #(PPU_MASK_BKG + PPU_MASK_BKG8 + PPU_MASK_SPR + PPU_MASK_SPR8)
        LDA #(PPU_MASK_BKG + PPU_MASK_BKG8)
        STA PPU_MASK
        ; set next scanline.
        ; Because we have disabled rendering,
        ; MMC5 scanline counter is now at 0 at the scanline where we re-enabled rendering,
        ; Therefore, scanline 60 mean scanline when enable (155) + 60 = 215
        LDA #60
        STA MMC5_SCNL_VAL
        ; return
        JMP @end
    @scanline_irq_bot_img:
        ;
        LDA #$00
        STA MMC5_CHR_UPPER
        ;
        BIT effect_flags
        BMI @botimg_palette_change
            LDA #238
            STA MMC5_SCNL_VAL
            JMP @botimg_next
        @botimg_palette_change:
        ; set next scanline.
        ; Because we have disabled rendering,
        ; MMC5 scanline counter is now at 0 at the scanline where we re-enabled rendering,
        ; Therefore, scanline 82 mean scanline when enable (155) + 83 = 238
        LDA #83
        STA MMC5_SCNL_VAL
        @botimg_next:
        ;
        LDA #(PPU_MASK_BKG + PPU_MASK_BKG8 + PPU_MASK_SPR + PPU_MASK_SPR8)
        STA PPU_MASK
        ; change nametable mapping
        LDA #NT_MAPPING_EMPTY
        STA MMC5_NAMETABLE
        ; return
        JMP @end
    @scanline_irq_bot:
        ; set next scanline.
        LDA #1
        STA MMC5_SCNL_VAL
        ; change nametable mapping
        LDA #NT_MAPPING_NT1
        STA MMC5_NAMETABLE
        ; return
        JMP @end

    @end:
    pullregs
    ; return
    RTI

    @jump_lo:
        .byte <(@scanline_irq_top_img-1)
        .byte <(@scanline_irq_dialog-1)
        .byte <(@scanline_irq_bot_img-1)
        .byte <(@scanline_irq_bot-1)
        .byte <(@scanline_irq_top-1)
    @jump_hi:
        .byte >(@scanline_irq_top_img-1)
        .byte >(@scanline_irq_dialog-1)
        .byte >(@scanline_irq_bot_img-1)
        .byte >(@scanline_irq_bot-1)
        .byte >(@scanline_irq_top-1)
    @next_state:
        .byte SCANLINE_TOP_IMG
        .byte SCANLINE_DIALOG
        .byte SCANLINE_BOT_IMG
        .byte SCANLINE_BOT
        .byte SCANLINE_TOP
