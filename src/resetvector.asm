start:
SEI
CLC
XCE

setXY16
LDX #$01FF
TXS
LDA #$A0
PHA
PLB
jml $A08000

nmi:
    ; php
    ; setAXY16
    ; PHA
    ; PHX
    ; PHY
    ; setAXY8 

    ; LDA #$A0
    ; PHA
    ; PLB
    PHA
    PHX
    PHY
    setAXY8
    
    jslb snes_nmi, $a0
    jslb msu_nmi_check, $b2

    ; jump to NES NMI
    CLC
    LDA ACTIVE_NES_BANK
    INC
    ADC #$A0
    STA BANK_SWITCH_DB
    
    PHA
    PLB

    LDA #$FF
    STA BANK_SWITCH_HB
    LDA #$3A
    STA BANK_SWITCH_LB

    
    PLY
    PLX
    PLA
    JML [BANK_SWITCH_LB]

_rti:
    rti