; case SPD
@SPD:
    ; spd = next_char() - 1
    JSR read_next_char
    SEC
    SBC #$01
    STA txt_speed
    RTS
