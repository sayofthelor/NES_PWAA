; description:
;   decode a lz encoded text
;   and save the result into ram.
; param:
; - lz_in: pointer to text block
; - lz_in_bnk: bank of the text block
; use: tmp[0..7]
; /!\ assume to be in bank 0
; /!\ change bank 1, 2 and ram bank
lz_decode:
    pushregs

    ; set output bank
    LDA #TEXT_BUF_BNK
    STA MMC5_RAM_BNK

    ; set input bank
    LDX lz_in_bnk
    STX MMC5_PRG_BNK1
    INX
    STX MMC5_PRG_BNK2

    ; init out pointer
    LDA #<MMC5_RAM   ; low adr
    STA tmp+0
    LDA #>MMC5_RAM   ; high adr
    STA tmp+1

    ; init in pointer
    LDA lz_in+0
    STA tmp+2
    LDA lz_in+1
    AND #$1F
    ORA #$A0
    STA tmp+3

    ; read block size
    LDY #$00
    LDA (tmp+2), Y
    STA tmp+6
    INY
    LDA (tmp+2), Y
    STA tmp+7
    DEY
    LDA #$02
    add_A2ptr tmp+2

    ; while not end_of_block:
    @while:
        LDA #$00
        CMP tmp+6
        BNE @do
        CMP tmp+7
        BEQ @end

        @do:
        ; decrease block size
        dec_16 tmp+6
        ; read next byte from input
        LDA (tmp+2), Y
        TAX
        ; increment input pointer
        inc_16 tmp+2

        ; if bit 7 is clear
        ASL
        BCS @pointer
        @char:
            ; then output the byte as a character
            TXA
            STA (tmp), Y
            ; increment output pointer
            inc_16 tmp
            ;
            JMP @while

        ; else this is a pointer
        @pointer:
            ; get second byte from input
            LDA (tmp+2), Y
            STA tmp+4
            inc_16 tmp+2
            ; get the jump size (high)
            TXA
            AND #$0F
            STA tmp+5
            LDA tmp+1
            SEC
            SBC tmp+5
            STA tmp+5
            ; get the jump size (low)
            LDA tmp+0
            CMP tmp+4
            BCS @dec_end_1
                DEC tmp+5
            @dec_end_1:
            SEC
            SBC tmp+4
            STA tmp+4
            BNE @dec_end_2
                DEC tmp+5
            @dec_end_2:
            DEC tmp+4
            ; get the string length
            TXA
            ASL
            LSR
            LSR
            LSR
            LSR
            LSR
            CLC
            ADC #$03
            TAX
            ; recover the string and output it
            @copy:
                ; read char from buffer
                LDA (tmp+4), Y
                ; save char to output
                STA (tmp), Y
                ; increment buffer pointer
                inc_16 tmp+4
                ; increment output pointer
                inc_16 tmp
                ; next
                DEX
                BNE @copy
            ;
            JMP @while

    @end:
    pullregs
    RTS
