
intro_screen_data:
.byte $A3, $20, $FA, $FC, $EB, $F3, $F2, $F3, $FC                       ; (c) 1989 
.byte $e3, $d4, $d2, $d7, $dd, $de, $e2, $fc                            ; Technos
.byte $d9, $d0, $df, $d0, $dd, $fc                                      ; Japan 
.byte $d2, $de, $e1, $df, $ff                                           ; Corp

.byte $A3, $21, $df, $de, $e1, $e3, $d4, $d3, $fc                        ; Ported 
.byte $d1, $e8, $fc                                                     ; by 
.byte $e1, $e4, $dc, $d1, $db, $d4, $dc, $d8, $dd, $e9, $d4, $f7, $fc   ; Rumbleminze, 
.byte $ec, $ea, $ec, $ed, $ff                                           ; 2023

.byte $69, $22, $dc, $e2, $e4, $eb, $fc                 ; MSU1 TRACKS BY
.byte $e3, $e1, $d0, $d2, $da, $e2, $fc
.byte $d1, $e8, $ff                     
.byte $a7, $22, $d0, $d0, $e1, $de, $dd, $fc            ; AARON LEHNEN 'MNG'
.byte $db, $d4, $d7, $dd, $d4, $dd, $fc, $f4, $dc, $dd, $d6, $f4, $ff
            

.byte $05, $23, $EC, $D0, $EA, $ED, $FC                                 ; 2A03
.byte $e2, $de, $e4, $dd, $d3, $fc                                      ; SOUND 
.byte $d4, $dc, $e4, $db, $d0, $e3, $de, $e1, $fc                       ; EMULATOR
.byte $d1, $e8, $fc, $FF                                                ; BY

.byte $4C, $23, $dc, $d4, $dc, $d1, $db, $d4, $e1, $e2, $ff              ; MEMBLERS

.byte $7B, $23, $e1, $d4, $e5, $ec, $ff ; Version (REV0)
.byte $ff, $ff

write_intro_palette:
    STZ CGADD
    LDA #$00
    STA CGDATA
    STA CGDATA

    LDA #$FF
    STA CGDATA
    STA CGDATA
    
    STA CGDATA
    STA CGDATA
    
    STA CGDATA
    STA CGDATA
    RTS

write_intro_tiles:
    LDY #$00

next_line:
    ; get starting address
    LDA intro_screen_data, Y
    CMP #$FF
    BEQ exit_intro_write

    PHA
    INY    
    LDA intro_screen_data, Y
    STA VMADDH
    PLA
    STA VMADDL
    INY

next_tile:
    LDA intro_screen_data, Y
    INY

    CMP #$FF
    BEQ next_line

    STA VMDATAL
    BRA next_tile

exit_intro_write:
    RTS

do_intro:
    LDA #$0a
    STA CHR_BANK_BANK_TO_LOAD
    LDA #$01
    STA CHR_BANK_TARGET_BANK
    jslb load_chr_table_to_vm, $a0

    LDA VMAIN_STATUS
    AND #$0F
    STA VMAIN

    JSR write_intro_palette
    JSR write_intro_tiles
    jslb set_middle_attributes_to_palette_0, $a0
    LDA #$0F
    STA INIDISP

    LDX #$FF
  : LDA RDNMI
  : LDA RDNMI
    AND #$80
    BEQ :-
    DEX
    BNE :--

    LDA INIDISP_STATE
    STA INIDISP

    RTS