.SEGMENT "WRAM_ROUTINES"

; APU Update routines
routines_start:
LoadSFXRegisters:
    lda $e0
    cmp #$00
    beq sq1_r
    cmp #$04
    beq sq2_r
    cmp #$08
    beq tri_r
noise_r:
    lda ($e2), y
    jsr WriteAPUNoiseCtrl0
    iny
    lda ($e2), y
    jsr WriteAPUNoiseCtrl1
    iny
    lda ($e2), y
    jsr WriteAPUNoiseCtrl2
    iny
    lda ($e2), y
    jsr WriteAPUNoiseCtrl3
    iny
    bra end_r
sq1_r:
    lda ($e2), y
    jsr WriteAPUSq0Ctrl0
    iny
    lda ($e2), y
    jsr WriteAPUSq0Ctrl1
    iny
    lda ($e2), y
    jsr WriteAPUSq0Ctrl2
    iny
    lda ($e2), y
    jsr WriteAPUSq0Ctrl3
    iny
    bra end_r
sq2_r:
    lda ($e2), y
    jsr WriteAPUSq1Ctrl0
    iny
    lda ($e2), y
    jsr WriteAPUSq1Ctrl1
    iny
    lda ($e2), y
    jsr WriteAPUSq1Ctrl2
    iny
    lda ($e2), y
    jsr WriteAPUSq1Ctrl3
    iny
    bra end_r
tri_r:
    lda ($e2), y
    jsr WriteAPUTriCtrl0
    iny
    lda ($e2), y
    jsr WriteAPUTriCtrl1
    iny
    lda ($e2), y
    jsr WriteAPUTriCtrl2
    iny
    lda ($e2), y
    jsr WriteAPUTriCtrl3
    iny
    bra end_r
end_r:
    lda #$00
    rts

dynamic_Y:
    CPY #$15
    BNE :+
        jmp WriteAPUControl
    :

    PHA
    TYA
    AND #$03

    BNE :+
        PLA
        BRA WriteAPUSq0Ctrl0_I_Y
:   CMP #$01
    BNE :+
        PLA
        BRA WriteAPUSq0Ctrl1_I_Y_Offset
:   CMP #$02
    BNE :+
        PLA
        BRA WriteAPUSq0Ctrl2_I_Y_Offset
:   PLA
    BRA WriteAPUSq0Ctrl3_I_Y_Offset


WriteAPUSq0Ctrl1_I_Y_Offset:
    cpy #$01
    bne :+
        jsr WriteAPUSq0Ctrl1
        rts
:
    cpy #$05
    bne :+
        jsr WriteAPUSq1Ctrl1
        rts
:
    sta APUBase, y
    rts

WriteAPUSq0Ctrl2_I_Y_Offset:
    sta APUBase, y
    rts

WriteAPUSq0Ctrl3_I_Y_Offset:
    cpy #$03
    bne :+
    jsr WriteAPUSq0Ctrl3
    rts
:
    cpy #$07
    bne :+
    jsr WriteAPUSq1Ctrl3
    rts
:
    cpy #$0B
    bne :+
    jsr WriteAPUTriCtrl3
    rts
:
    jsr WriteAPUNoiseCtrl3    
    rts

WriteAPUSq0Ctrl0:
    sta   APUBase
    rts

WriteAPUSq0Ctrl0_I_Y:
    sta   APUBase, y
    rts

WriteAPUSq0Ctrl0_I_X:
    sta   APUBase, x
    rts

WriteAPUSq0Ctrl0_Y:
    sty   APUBase
    rts

WriteAPUSq0Ctrl0_X:
    stx   APUBase
    rts

WriteAPUSq0Ctrl1:
    xba
    lda #$40
    tsb APUBase+$16
    xba
    sta APUBase+$01
    rts

WriteAPUSq0Ctrl1_Y:
    xba
    lda #$40
    tsb APUBase+$16
    xba
    sty APUBase+$01
    rts    

WriteAPUSq0Ctrl1_I_Y:
    cpy #$00
    bne :+
    jsr WriteAPUSq0Ctrl1
    rts
:
    cpy #$04
    bne :+
    jsr WriteAPUSq1Ctrl1
    rts
:
    sta APUBase+$01, y
    rts

WriteAPUSq0Ctrl1_I_X:
    cpx #$00
    bne :+
    jsr WriteAPUSq0Ctrl1
    rts
:
    cpx #$04
    bne :+
    jsr WriteAPUSq1Ctrl1
    rts
:
    sta APUBase+$01, x
    rts

WriteAPUSq0Ctrl2:
    sta APUBase+$02
    rts

WriteAPUSq0Ctrl2_X:
    stx APUBase+$02
    rts

WriteAPUSq0Ctrl2_I_Y:
    sta APUBase+$02, y
    rts

WriteAPUSq0Ctrl2_I_X:
    sta APUBase+$02, x
    rts


WriteAPUSq0Ctrl3:
    phx
    sta APUBase+$03
    tax
    lda Sound__EmulateLengthCounter_length_d3_mixed, x
    sta APUSq0Length
    xba
    lda #$01
    tsb APUBase+$15
    tsb APUExtraControl
    plx
    xba
    rts

WriteAPUSq0Ctrl3_X:
    pha
    stx APUBase+$03
    lda Sound__EmulateLengthCounter_length_d3_mixed, x
    sta APUSq0Length
    lda #$01
    tsb APUBase+$15
    tsb APUExtraControl   
    pla
    rts

WriteAPUSq0Ctrl3_I_Y:
    cpy #$00
    bne :+
    jsr WriteAPUSq0Ctrl3
    rts
:
    cpy #$04
    bne :+
    jsr WriteAPUSq1Ctrl3
    rts
:
    cpy #$08
    bne :+
    jsr WriteAPUTriCtrl3
    rts
:
    jsr WriteAPUNoiseCtrl3    
    rts

WriteAPUSq0Ctrl3_I_X:
    cpx #$00
    bne :+
    jsr WriteAPUSq0Ctrl3
    rts
:
    cpx #$04
    bne :+
    jsr WriteAPUSq1Ctrl3
    rts
:
    cpx #$08
    bne :+
    jsr WriteAPUTriCtrl3
    rts
:
    jsr WriteAPUNoiseCtrl3    
    rts

WriteAPUSq1Ctrl0:
    sta APUBase+$04
    rts

WriteAPUSq1Ctrl0_X:
    stx APUBase+$04
    rts

WriteAPUSq1Ctrl0_Y:
    sty APUBase+$04
    rts

WriteAPUSq1Ctrl1:
    xba
    lda #$80
    tsb APUBase+$16
    xba
    sta APUBase+$05
    rts

WriteAPUSq1Ctrl1_X:
    xba
    lda #$80
    tsb APUBase+$16
    xba
    stx APUBase+$05
    rts   

WriteAPUSq1Ctrl1_Y:
    xba
    lda #$80
    tsb APUBase+$16
    xba
    sty APUBase+$05
    rts   

WriteAPUSq1Ctrl2:
    sta APUBase+$06
    rts

WriteAPUSq1Ctrl2_X:
    stx APUBase+$06
    rts

WriteAPUSq1Ctrl3:
    phx
    sta APUBase+$07
    tax
    lda Sound__EmulateLengthCounter_length_d3_mixed, x
    sta APUSq1Length
    xba
    lda #$02
    tsb APUBase+$15
    tsb APUExtraControl
    plx
    xba
    rts

WriteAPUSq1Ctrl3_X:
    pha
    stx APUBase+$07
    lda Sound__EmulateLengthCounter_length_d3_mixed, x
    sta APUSq1Length
    lda #$02
    tsb APUBase+$15
    tsb APUExtraControl   
    pla
    rts

WriteAPUTriCtrl0:
    sta APUBase+$08
    rts

WriteAPUTriCtrl1:
    sta APUBase+$09
    rts

WriteAPUTriCtrl2:
    sta APUBase+$0A
    rts

WriteAPUTriCtrl2_X:
    stx APUBase+$0A
    rts

WriteAPUTriCtrl3:
    phx
    sta APUBase+$0B
    tax
    lda #$04
    tsb APUExtraControl
    tsb APUBase+$15
    lda Sound__EmulateLengthCounter_length_d3_mixed, x
    sta APUTriLength
    txa
    plx
    rts

WriteAPUNoiseCtrl0:
    sta APUBase+$0C
    rts

WriteAPUNoiseCtrl1:
    sta APUBase+$0D
    rts

WriteAPUNoiseCtrl2:
    sta APUBase+$0E
    rts

WriteAPUNoiseCtrl2_X:
    stx APUBase+$0E
    rts

WriteAPUNoiseCtrl3:
    phx
    sta APUBase+$0F
    tax
    lda #$08
    tsb APUExtraControl
    tsb APUBase+$15
    lda Sound__EmulateLengthCounter_length_d3_mixed, x
    sta APUNoiLength
    txa
    plx
    rts

WriteAPUControl:
    sta APUIOTemp
    xba
    lda APUIOTemp
    eor #$ff
    and #$1f
    trb APUBase+$15
    trb APUExtraControl
    lsr APUIOTemp
    bcs :+
        stz APUBase+$03
        stz APUSq0Length
:
    lsr APUIOTemp
    bcs :+
        stz APUBase+$07
        stz APUSq1Length
:
    lsr APUIOTemp
    bcs :+
        stz APUBase+$0B
        stz APUTriLength
:
    lsr APUIOTemp
    bcs :+
        stz APUBase+$0F
        stz APUNoiLength
:
    lsr APUIOTemp
    bcc :+
        lda #$10
        tsb APUBase+$15
        bne :+
            tsb APUExtraControl
:
    xba
    rts

Sound__EmulateLengthCounter_length_d3_mixed:
.byte $06,$06,$06,$06,$06,$06,$06,$06,$80,$80,$80,$80,$80,$80,$80,$80
.byte $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$02,$02,$02,$02,$02,$02,$02,$02
.byte $15,$15,$15,$15,$15,$15,$15,$15,$03,$03,$03,$03,$03,$03,$03,$03
.byte $29,$29,$29,$29,$29,$29,$29,$29,$04,$04,$04,$04,$04,$04,$04,$04
.byte $51,$51,$51,$51,$51,$51,$51,$51,$05,$05,$05,$05,$05,$05,$05,$05
.byte $1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$06,$06,$06,$06,$06,$06,$06,$06
.byte $08,$08,$08,$08,$08,$08,$08,$08,$07,$07,$07,$07,$07,$07,$07,$07
.byte $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$08,$08,$08,$08,$08,$08,$08,$08
.byte $07,$07,$07,$07,$07,$07,$07,$07,$09,$09,$09,$09,$09,$09,$09,$09
.byte $0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
.byte $19,$19,$19,$19,$19,$19,$19,$19,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
.byte $31,$31,$31,$31,$31,$31,$31,$31,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
.byte $61,$61,$61,$61,$61,$61,$61,$61,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D
.byte $25,$25,$25,$25,$25,$25,$25,$25,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $09,$09,$09,$09,$09,$09,$09,$09,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
.byte $11,$11,$11,$11,$11,$11,$11,$11,$10,$10,$10,$10,$10,$10,$10,$10

routines_end: