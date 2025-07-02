.SEGMENT "WRAM_ROUTINES"

; APU Update routines (much more simplistic than current version)
routines_start:
setAXY8
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
    sta APUBase+$01
    rts

WriteAPUSq0Ctrl1_Y:
    sty APUBase+$01
    rts    

WriteAPUSq0Ctrl1_I_Y:
    sta APUBase+$01, y
    rts

WriteAPUSq0Ctrl1_I_X:
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
    sta APUSq0Length
    rts

WriteAPUSq0Ctrl3_X:
    stx APUBase+$03
    rts

WriteAPUSq0Ctrl3_I_Y:
    sta APUBase+$03, y
    rts

WriteAPUSq0Ctrl3_I_X:
    sta APUBase+$03, x
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
    sta APUBase+$05
    rts

WriteAPUSq1Ctrl1_X:
    stx APUBase+$05
    rts   

WriteAPUSq1Ctrl1_Y:
    sty APUBase+$05
    rts   

WriteAPUSq1Ctrl2:
    sta APUBase+$06
    rts

WriteAPUSq1Ctrl2_X:
    stx APUBase+$06
    rts

WriteAPUSq1Ctrl3:
    sta APUBase+$07
    rts

WriteAPUSq1Ctrl3_X:
    stx APUBase+$07
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
    sta APUBase+$0B
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
    sta APUBase+$0F
    rts

WriteAPUControl:
    sta APUBase + $15
    rts

routines_end: