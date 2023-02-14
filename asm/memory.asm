;**********
; Memory
;**********

;****************
; ZEROPAGE SEGMENT
;****************
.segment "ZEROPAGE"
    ; NMI Flags to activate graphical update
    ; Note: You cannot activate all updates.
    ;       You need to have a execution time
    ;       < ~2273 cycles (2000 to be sure)
    ; 7  bit  0
    ; ---- ----
    ; EFJR PASB
    ; |||| ||||
    ; |||| |||+- Background tiles update
    ; |||| |||   Execution time depend on data
    ; |||| |||   (cycles ~= 16 + 38*p + for i:p do (14*p[i].n))
    ; |||| |||   (p=packet number, p[i].n = packet data size)
    ; |||| ||+-- Sprites update (513+ cycles)
    ; |||| |+--- Nametables attributes update (821 cycles)
    ; |||| +---- Palettes update (356 cycles)
    ; |||+------ Scroll update (31 cycles)
    ; ||+------- Jump to specific subroutine
    ; |+-------- Force NMI acknowledge
    ; +--------- 1 when NMI has ended, should be set to 0 after reading.
    ;            If let to 1, it means the NMI is disable
    nmi_flags: .res 1

    ; Scroll X position
    scroll_x: .res 1

    ; Scroll Y position
    scroll_y: .res 1

    ; Nametable high adress to update attributes for
    ; $23 = Nametable 1
    ; $27 = Nametable 2
    ; $2B = Nametable 3
    ; $2F = Nametable 4
    atr_nametable: .res 1
    
    ; value of the PPU_MASK (need to be refresh manually)
    ppu_ctrl_val: .res 1

    ; padding
    .res 2

    ; Palettes data to send to PPU during VBLANK
    ;   byte 0   = transparente color
    ;   byte 1-3 = background palette 1
    ;   byte 4-6 = background palette 2
    ;   ...
    ;   byte 13-16 = sprite palette 1
    ;   ...
    palettes: .res 25

    ; Attributes data to send to PPU during VBLANK
    attributes: .res 64

    ; Index for the background data
    ; FIII IIII
    ; |+++-++++-- Index
    ; +---------- A flag to tell that you are currently writing to the background buffer.
    ;             If it is already set, you must wait for it to be cleared.
    background_index: .res 1

    ; Background data to send to PPU during VBLANK
    ; Packet structure:
    ; byte 0   = vsssssss (v= vertical draw, s= size)
    ; byte 1-2 = ppu adress (most significant byte, least significant byte)
    ; byte 3-s = tile data
    ; packet of size 0 means there is no more data to draw
    background: .res 127

    ; temporary variables
    tmp:

;****************
; OAM SEGMENT
;****************
.segment "OAM"
OAM:


;****************
; BSS SEGMENT
;****************
.segment "BSS"

    ; - - - - - - - -
    ; Player input variables
    ; - - - - - - - -
    ; player 1 inputs
    buttons_1: .res 1
    ; timer before processing any input of player 1
    buttons_1_timer: .res 1

    ; - - - - - - - -
    ; Scanline state
    ; - - - - - - - -
    ; WFSS SSSS
    ; ||++-++++-- scanline IRQ state
    ; |+--------- 1 = in frame, 0 = in vblank
    ; |---------- wait for scanline, cleare when scanline IRQ occured
    scanline: .res 1

    ; - - - - - - - -
    ; Music and sound variables
    ; - - - - - - - -
    ; music to play
    music: .res 1
    ; sound effect to play
    sound: .res 1
    ; bip sound to play when text is draw
    bip: .res 1

    ; - - - - - - - -
    ; Visual effect variables
    ; - - - - - - - -
    ; H... ..SF
    ; |      |+-- Fade in (1) or out (0)
    ; |      +--- Scroll position (0=left, 1=right)
    ; +---------- Hide dialog box (1=Hidden)
    effect_flags: .res 1
    ;
    scroll_timer: .res 1
    ;
    fade_timer: .res 1
    ;
    fade_color: .res 1
    ;
    flash_timer: .res 1
    ;
    flash_color: .res 1
    ;
    shake_timer: .res 1

    ; - - - - - - - -
    ; Variables for LZ decoding
    ; - - - - - - - -
    ; pointer to input data
    lz_in: .res 2
    ; bank to use for input data
    lz_in_bnk: .res 1

    ; - - - - - - - -
    ; Variables for text reading
    ; - - - - - - - -
    ; pointer to current text to read
    txt_rd_ptr: .res 2
    ; first byte of flags
    ; D... .FIW
    ; |     ||+-- Wait for user input to continue
    ; |     |+--- Player input
    ; |     +---- Force action (ignore player inputs)
    ; +---------- Disable
    txt_flags: .res 1
    ; speed of text
    txt_speed: .res 1
    ; speed counter
    txt_speed_count: .res 1
    ; delay to wait
    txt_delay: .res 1
    ;
    txt_name: .res 1
    ;
    txt_font: .res 1
    ;
    txt_bck_color: .res 1
    ;
    txt_jump_buf: .res 3
    ;
    txt_jump_flag_buf: .res 1

    ; - - - - - - - -
    ; Variables for text printing
    ; - - - - - - - -
    ; Value to print in ext ram
    ; value to send to MMC5 expansion RAM
    print_ext_val: .res 1
    ; pointer to current printed text in ext ram
    print_ext_ptr: .res 2
    ; pointer to current printed text in ppu
    print_ppu_ptr: .res 2
    ; number of character to print
    print_counter: .res 1
    ; buffer containing text to print to ppu
    print_ppu_buf: .res 16
    ; buffer containing text to print to ext ram
    print_ext_buf: .res 16

    ; - - - - - - - -
    ; Image Variables
    ; - - - - - - - -
    ; photo/evidence toshow
    img_photo: .res 1
    ;
    img_background: .res 1
    ;
    img_anim:
    ;
    img_character: .res 1
    ;
    img_animation: .res 1
    ;
    img_partial_buf_len: .res 1
    ;
    img_partial_buf: .res IMG_PARTIAL_MAX_BUF_LEN

    ; - - - - - - - -
    ; Animation Variables
    ; - - - - - - - -
    ;
    anim_base_adr: .res 2
    ;
    anim_adr: .res 2
    ;
    anim_img_count: .res 1
    ;
    anim_img_counter: .res 1
    ;
    anim_frame_counter: .res 1

    ; - - - - - - - -
    ; Sprites Variables
    ; - - - - - - - -
    ;
    ; img_spr_header:
    ;
    img_header: .res 1
    ;
    img_spr_w: .res 1
    ;
    img_spr_b: .res 1
    ;
    img_spr_x: .res 1
    ;
    img_spr_y: .res 1
    ;
    img_spr_count: .res 1

    ; - - - - - - - -
    ; Palette Variables
    ; - - - - - - - -
    ;
    img_palettes:
    img_palette_bkg: .res 1
    img_palette_0: .res 3
    img_palette_1: .res 3
    img_palette_2: .res 3
    img_palette_3: .res 3

    ; - - - - - - - -
    ; Action/choice variables
    ; - - - - - - - -
    ;
    choice: .res 1
    ;
    max_choice: .res 1
    ;
    choice_jmp_table: .res 3*4

    ; - - - - - - - -
    ; Other variables
    ; - - - - - - - -
    dialog_flag: .res 16
    ; mmc5 banks to restore (ram,bnk0,bnk1,bnk2)
    mmc5_banks: .res 4
    ; tmp variables to restore
    tmp_restore: .res 8

