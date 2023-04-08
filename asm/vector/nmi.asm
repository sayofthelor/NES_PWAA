;***********
; NMI vector
;***********


;--------------------
; Cycles notes
;--------------------
; 2273 cycles per VBLANK
; base (before @done) = 13+3+2+3+(2+3)*5
; @sprite = 513+ cycles
; @scroll = 31 cycles
; @attribute = 821 cycles
; @palette = 356 cycless
; @background ~= 16+(38*p+14*p[i].n)
;--------------------


NMI:
    ; save registers
    pushregs

    ; do we need to do stuff ? (E flag)
    BIT nmi_flags
    BPL @start
    JMP @end

    @start:
    LDA #NT_MAPPING_NT1
    STA MMC5_NAMETABLE

    ; load NMI flags
    LDA nmi_flags

    ; is the background flag on ? (B flag)
    LSR
    BCC @background_end
    @background:
        ; save flags
        PHA

        LDX #$00
        @background_loop:
            ; read size
            LDA background, X
            ; if size = 0 then end
            BEQ @background_loop_end

            ; save size to Y
            AND #$7F
            TAY
            ; is vertical flag off ?
            LDA background, X
            ASL
            BCC @background_loop_hor

            ; tell the ppu to inc by 32
            @background_loop_ver:
            LDA ppu_ctrl_val
            ORA #(PPU_CTRL_INC)
            STA PPU_CTRL
            JMP @background_loop_start

            ; tell the ppu to inc by 1
            @background_loop_hor:
            LDA ppu_ctrl_val
            AND #($FF-PPU_CTRL_INC)
            STA PPU_CTRL

            @background_loop_start:
            ; reset latch
            BIT PPU_STATUS
            ; set PPU adr
            INX
            LDA background, X
            STA PPU_ADDR
            INX
            LDA background, X
            STA PPU_ADDR

            ; send data
            @background_loop_data:
                ; send 1 tile
                INX
                LDA background, X
                STA PPU_DATA
                ; loop
                DEY
                BNE @background_loop_data
            INX
            JMP @background_loop
        @background_loop_end:
        ; restore PPU_CTRL
        LDA ppu_ctrl_val
        STA PPU_CTRL

        ; restore flags
        PLA
    @background_end:


    ; is the sprite flag on ? (S flag)
    LSR
    BCC @sprite_end
    @sprite:
        ; Update sprites
        LDX #>OAM
        STX OAMDMA
    @sprite_end:


    ; is the attribute flag on ? (A flag)
    ; /!\ skip this flag because we will never use it
    LSR
    ; BCC @attribute_end
    ; @attribute:
    ;     ; save flags
    ;     PHA

    ;     ; reset latch
    ;     BIT PPU_STATUS
    ;     ; set PPU address
    ;     LDA atr_nametable
    ;     STA PPU_ADDR
    ;     LDA #$C0
    ;     STA PPU_ADDR
 
    ;     ; send data to PPU
    ;     LDX #$00
    ;     @attribute_loop:
    ;         ; send 1 byte
    ;         LDA attributes, X
    ;         STA PPU_DATA
    ;         INX
    ;         ; send another byte
    ;         LDA attributes, X
    ;         STA PPU_DATA
    ;         INX
    ;         ; loop
    ;         CPX #$40
    ;         BNE @attribute_loop
 
    ;     ; restore flags
    ;     PLA
    ; @attribute_end:


    ; is the palette flag on ? (P flag)
    LSR
    BCC @palette_end
    @palette:
        ; save flags
        PHA

        ; reset latch
        BIT PPU_STATUS
        ; set PPU address
        LDA #$3F
        STA PPU_ADDR
        LDX #$01
        STX PPU_ADDR
        LDY #$00
 
        ; send data to PPU
        @palette_loop:
            ; send 3 colors
            LDA palettes, X
            STA PPU_DATA
            INX
            LDA palettes, X
            STA PPU_DATA
            INX
            LDA palettes, X
            STA PPU_DATA
            INX
            ; send dummy background color
            LDA dummy_pal, Y
            STA PPU_DATA
            INY
            ; loop
            CPX #25
            BNE @palette_loop

        ; send transparent color
        LDA #$3F
        STA PPU_ADDR
        LDA #$00
        STA PPU_ADDR
        LDA palettes
        STA PPU_DATA

        ; restore flags
        PLA
    @palette_end:


    ; is the scroll flag on ? (R flag)
    LSR
    BCC @scroll_end
    @scroll:
        ; reset latch
        BIT PPU_STATUS
        ; set scrolling position to scroll_x, scroll_y
        LDX scroll_x
        STX PPU_SCROLL
        LDX scroll_y
        STX PPU_SCROLL

        ; set high order bit of X and Y
        LDA ppu_ctrl_val
        STA PPU_CTRL
    @scroll_end:

    @done:
    ; reset zp background index
    LDA #$00
    STA background_index
    STA background

    @end:

    ; tell that we are done
    BIT nmi_flags
    BVS :+
        LDA #NMI_DONE
        ORA nmi_flags
        STA nmi_flags
        JMP :++
    :
        LDA #($FF-NMI_DONE)
        AND nmi_flags
        STA nmi_flags
    :

    ; set nametable mapping to default
    LDA #DEFAULT_NT_MAPPING
    STA MMC5_NAMETABLE

    ; enable interrupt
    CLI
    ; load music banks
    mov MMC5_PRG_BNK1, #MUS_BNK
    mov MMC5_PRG_BNK2, #MUS_BNK+1
    ; update famistudio
    JSR famistudio_update
    ; restore banks
    mov MMC5_PRG_BNK1, mmc5_banks+2
    mov MMC5_PRG_BNK2, mmc5_banks+3

    ; read text
    JSR read_text
    ; restore ram bank
    LDA mmc5_banks+0
    STA MMC5_RAM_BNK

    ; print_flush if needed
    LDA txt_flags
    AND #TXT_FLAG_PRINT
    BEQ @print_end
        JSR print_flush
        and_adr txt_flags, #($FF-TXT_FLAG_PRINT)
    @print_end:

    ; restore registers
    pullregs
    ; return
    RTI


; pal 1-7
; double because tile background color = sprite background color
; first background color = [palettes+0]
dummy_pal:
.byte      $30, $0F, $0F
.byte $0F, $30, $0F, $0F
