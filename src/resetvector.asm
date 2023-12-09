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
JSL $A08000
JML $A1FFE8

; below is trash while I tested something
mainloop:
    lda nmi_count
@nmi_check:
	wai
	cmp nmi_count
	beq @nmi_check
	php
    plp
    bra mainloop

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

    JSL snes_nmi
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


    JML [BANK_SWITCH_LB]
    bit RDNMI
    inc nmi_count

_rti:
    rti