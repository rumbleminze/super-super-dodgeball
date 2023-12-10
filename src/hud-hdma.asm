; for the hud we want the HOFFS to be 0 for 40 scan lines
; then we want it to be the stored value for the rest
; but only if we're in the match

hud_hdma_setup:
    LDA #$02
    STA DMAP7

    LDA #.lobyte(BG1HOFS)
    STA BBAD7

    LDA #.lobyte(HUD_HDMA_TABLE)
    STA A1T7L

    LDA #.hibyte(HUD_HDMA_TABLE)
    STA A1T7H

    LDA #$A0
    STA A1B7
    
    LDA #40
    ; 40 scanlines of 0 HOFFS
    STA HUD_HDMA_TABLE

    LDA #$00
    STA HUD_HDMA_TABLE + 1
    STA HUD_HDMA_TABLE + 2

    LDA #$01
    STA HUD_HDMA_TABLE + 3

    LDA NES_H_SCROLL
    STA HUD_HDMA_TABLE + 4
    STZ HUD_HDMA_TABLE + 5
    
    ; end table
    STZ HUD_HDMA_TABLE + 6

    LDA #%10000000
    STA HDMAEN

    RTL

