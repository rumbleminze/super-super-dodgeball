; Deal with setting the PPU control to an arbitrary value
; NES PPU Control has the following function:
;
; 7  bit  0
; ---- ----
; VPHB SINN
; |||| ||||
; |||| ||++- Base nametable address
; |||| ||    (0 = $2000; 1 = $2400; 2 = $2800; 3 = $2C00)
; |||| |+--- VRAM address increment per CPU read/write of PPUDATA
; |||| |     (0: add 1, going across; 1: add 32, going down)
; |||| +---- Sprite pattern table address for 8x8 sprites
; ||||       (0: $0000; 1: $1000; ignored in 8x16 mode)
; |||+------ Background pattern table address (0: $0000; 1: $1000)
; ||+------- Sprite size (0: 8x8 pixels; 1: 8x16 pixels – see PPU OAM#Byte 1)
; |+-------- PPU master/slave select
; |          (0: read backdrop from EXT pins; 1: output color on EXT pins)
; +--------- Generate an NMI at the start of the
;            vertical blanking interval (0: off; 1: on)
;
;
; V - handled by NMITIMEN
; P
; H - handled by OBJSEL
; B - handled by BG12NBA - we only deal with BG1 which is the low bits
;
; S - handled by OBJSEL
; I - handled by VMAIN
; NN- handled manually by adjusting the high byte of HOFS and VOFS since we don't have base nametables
handle_ppu_control_value:
    STA PPU_CONTROL_STATUS

    AND #$80
    RTL

update_HV_OFFS:
    RTL
    LDA NES_H_SCROLL 
    STA BG1HOFS   
    STZ BG1HOFS

    LDA NES_V_SCROLL
    STA BG1VOFS ; $2005
    STZ BG1VOFS

    RTL

reset_HV_OFFS_to_0:
    RTL
    STZ BG1HOFS
    STZ BG1HOFS
    STZ BG1VOFS
    STZ BG1VOFS

    ; probably should also set the HB here, but I don't think we'll
    ; actually need it (maybe)
    
    RTL


; Disables vblank
; NES does this often via
;
; LDA PPU_CONTROL_STATUS
; AND #$7F
; STA PPU_CONTROL_STATUS
; STA PpuControl_2000
turn_off_nmi_and_store:
    LDA PPU_CONTROL_STATUS
    AND #$7F
    STA PPU_CONTROL_STATUS
    
    ; on SNES the NMITIMEN ($4200) register
    ; controls if vblank NMI is enabled
    LDA NMITIMEN_STATUS
    AND #$7F
    STA NMITIMEN_STATUS
    STA NMITIMEN

    RTL

turn_off_nmi_dont_store:
    LDA NMITIMEN_STATUS
    AND #$7F     
    STA NMITIMEN
    RTL

turn_on_nmi_and_store:
    LDA PPU_CONTROL_STATUS
    ORA #$80
    STA PPU_CONTROL_STATUS
    
    ; on SNES the NMITIMEN ($4200) register
    ; controls if vblank NMI is enabled
    LDA NMITIMEN_STATUS
    ORA #$80
    STA NMITIMEN_STATUS
    
    RTL

change_ppu_vblank_status:
    STA PPU_CONTROL_STATUS

    ; for vblank we only care about the #$80 bit
    ; so check if it set
    ; then ORA it with our current stored status
    AND #$80
    BEQ :+
    
    LDA NMITIMEN_STATUS
    ORA #$80
    BRA :++

:   LDA NMITIMEN_STATUS
    AND #$7F
    
:   STA NMITIMEN_STATUS
    STA NMITIMEN
    LDA PPU_CONTROL_STATUS
    RTL

handle_ppu_nmi_status_without_storing:
    LDA PPU_CONTROL_STATUS

    ; for vblank we only care about the #$80 bit
    ; so check if it set
    ; then ORA it with our current stored status
    AND #$80
    BEQ :+
    
    LDA NMITIMEN_STATUS
    ORA #$80
    BRA :++

:   LDA NMITIMEN_STATUS
    AND #$7F
    
:   STA NMITIMEN
    LDA PPU_CONTROL_STATUS
    RTL

set_vm_increment_mode_1:
    LDA PPU_CONTROL_STATUS
    AND #$FB
    STA PPU_CONTROL_STATUS
    
    LDA VMAIN_STATUS
    AND #$FC
    STA VMAIN
    STA VMAIN_STATUS

    RTL




; PpuMask controls lots of stuff
; but we almost always only care about
; a few bits.  Specifically 
;
; 7  bit  0
; ---- ----
; BGRs bMmG
; |||| ||||
; |||| |||+- Greyscale (0: normal color, 1: produce a greyscale display)
; |||| ||+-- 1: Show background in leftmost 8 pixels of screen, 0: Hide
; |||| |+--- 1: Show sprites in leftmost 8 pixels of screen, 0: Hide
; |||| +---- 1: Show background
; |||+------ 1: Show sprites
; ||+------- Emphasize red (green on PAL/Dendy)
; |+-------- Emphasize green (red on PAL/Dendy)
; +--------- Emphasize blue
; 
change_ppu_mask_status:
    STA PPU_MASK_STATUS
    ; setting to 0 is common, so optimize for that
    BNE :+
    STZ TM
    LDA #$80
    STA INIDISP
    STA INIDISP_STATE
    RTL

:   
    LDA #$0F
    STA INIDISP
    STA INIDISP_STATE

    LDA PPU_MASK_STATUS
    AND #$18
    BNE :+
    STZ TM
    RTL

:   CMP #$18
    BNE :+
    ; turn on sprites and bgs
    LDA #$11
    STA TM
    RTL

:   CMP #$10
    BNE :+
    ; turn on sprites
    STA TM
    RTL

:   CMP #$08
    BNE :+    
    ; turn on bg1
    LDA #$01
    STA TM
:   RTL

; 
; LDA #$XX
; STA PpuControl_2000
;
; where XX is:
; %00000000 - $2000
; %00000001 - $2400
; %00000010 - $2800
; %00000011 - $2C00
; we simulate this by changing the H or V scroll positions
set_background_addr:



    RTL

; Sets the address of where characters are for the backgrounds
; generally done via 
;
set_background_chr_addr:
    RTL

set_vm_incr_to_1_and_store:
    LDA PPU_CONTROL_STATUS
    AND #$FB
    STA PPU_CONTROL_STATUS

    LDA VMAIN_STATUS
    AND #$FC
    STA VMAIN_STATUS
    STA VMAIN

    RTL

set_vm_incr_to_1_and_reset_nametable_and_store:
    LDA PPU_CONTROL_STATUS
    AND #$FC
    STA PPU_CONTROL_STATUS

    LDA VMAIN_STATUS
    AND #$FC
    STA VMAIN_STATUS
    STA VMAIN

    ; STZ H/V offset HB here if we need to

    RTL