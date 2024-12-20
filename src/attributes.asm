handle_ppu_write_as_tile_data:
  LDA $54
  STA VMADDH
  LDA $53
  STA VMADDL
  LDA $57
  STA VMDATAL
  
  RTL

handle_ppu_write_end_credits:
  LDA $54
  AND #$03
  CMP #$03
  BNE handle_ppu_write_as_tile_data

  LDA $53
  CMP #$C0
  BMI handle_ppu_write_as_tile_data
  BNE :+

  LDA $54
  CMP #$23
  BNE :+

  jslb set_middle_attributes_to_palette_3, $a0
  
: RTL

; assumes $54 is VMADDH, $53 is VMADDL, and $57 is VMDATAL
handle_ppu_write:

  LDA $54
  AND #$03
  CMP #$03
  BNE handle_ppu_write_as_tile_data

  LDA $53
  CMP #$C0
  BMI handle_ppu_write_as_tile_data
  BRA handle_ppu_writes_as_attribute

handle_ppu_writes_as_attribute:
  PHB
  PHY
  PHX
  PHA

  LDA #$A0
  PHA
  PLB

  ; lo address determines which hb of memory we start in
  LDA ATTR_LO_ADDR
  PHA
  AND #$30
  LSR
  LSR
  LSR
  LSR
  ORA #$20
  STA ATTR_TARGET_STARTING_HB

  LDA ATTR_HI_ADDR
  CMP #$27
  BNE :+
  LDA ATTR_TARGET_STARTING_HB
  CLC
  ADC #$04
  STA ATTR_TARGET_STARTING_HB

: PLA
  AND #$0F
  TAY
  LDA attr_lo_addr_lookup, Y
  STA ATTR_TARGET_STARTING_LB

;   bits .... ..10
;   controls 4 tiles, upper left quartile
LDA ATTR_TARGET_STARTING_HB
STA ATTR_CURR_VM_WRITE_HB
LDA ATTR_TARGET_STARTING_LB
STA ATTR_CURR_VM_WRITE_LB

LDA ATTR_VALUE
AND #$03

; palettes are bits 2-5 on SNES
ASL
ASL
STA ATTR_CURR_ATTR_VALUE
JSR write_quartile

LDA ATTR_VALUE
AND #$0C
; no need to shift, these are in the right spot
STA ATTR_CURR_ATTR_VALUE
LDA ATTR_TARGET_STARTING_LB
ADC #$02
STA ATTR_CURR_VM_WRITE_LB
; HB should still be fine.
JSR write_quartile

LDA ATTR_VALUE
AND #$30
LSR
LSR
STA ATTR_CURR_ATTR_VALUE
LDA ATTR_TARGET_STARTING_LB
ADC #$40
STA ATTR_CURR_VM_WRITE_LB
; HB should still be fine.
JSR write_quartile

LDA ATTR_VALUE
AND #$C0
LSR
LSR
LSR
LSR
STA ATTR_CURR_ATTR_VALUE
LDA ATTR_TARGET_STARTING_LB
ADC #$42
STA ATTR_CURR_VM_WRITE_LB
; HB should still be fine.
JSR write_quartile

PLA
PLX
PLY
PLB
JMP handle_ppu_write_as_tile_data


write_quartile:
    LDA ATTR_CURR_VM_WRITE_HB
    STA VMADDH
    LDA ATTR_CURR_VM_WRITE_LB
    STA VMADDL
    LDA ATTR_CURR_ATTR_VALUE
    STA VMDATAH

    INC ATTR_CURR_VM_WRITE_LB
    LDA ATTR_CURR_VM_WRITE_HB
    STA VMADDH
    LDA ATTR_CURR_VM_WRITE_LB
    STA VMADDL
    LDA ATTR_CURR_ATTR_VALUE
    STA VMDATAH

    LDA ATTR_CURR_VM_WRITE_LB
    CLC
    ADC #$1F
    STA ATTR_CURR_VM_WRITE_LB
    LDA ATTR_CURR_VM_WRITE_HB
    STA VMADDH
    LDA ATTR_CURR_VM_WRITE_LB
    STA VMADDL
    LDA ATTR_CURR_ATTR_VALUE
    STA VMDATAH

    INC ATTR_CURR_VM_WRITE_LB
    LDA ATTR_CURR_VM_WRITE_HB
    STA VMADDH
    LDA ATTR_CURR_VM_WRITE_LB
    STA VMADDL
    LDA ATTR_CURR_ATTR_VALUE
    STA VMDATAH

    RTS

attr_lo_addr_lookup:
.byte $00, $04, $08, $0C, $10, $14, $18, $1C, $80, $84, $88, $8C, $90, $94, $98, $9C


set_middle_attributes_to_palette_3:
  LDA #$80
  STA VMAIN

  ; fixed A value, increment B
  LDA #$09
  sta DMAP0

  LDA #$21
  STA VMADDH
  LDA #$A0
  STZ VMADDL

  LDA #$19
  STA BBAD0

  LDA #$A0
  STA A1B0

  LDA #>dma_values
  STA A1T0H
  LDA #<dma_values
  STA A1T0L

  LDA #$04
  STA DAS0H  
  STZ DAS0L

  LDA #$01
  STA MDMAEN

  LDA VMAIN_STATUS
  STA VMAIN

  RTL

set_middle_attributes_to_palette_0:
  LDA #$80
  STA VMAIN

  ; fixed A value, increment B
  LDA #$09
  sta DMAP0

  LDA #$20
  STA VMADDH
  LDA #$00
  STZ VMADDL

  LDA #$19
  STA BBAD0

  LDA #$A0
  STA A1B0

  LDA #>(dma_values + 1)
  STA A1T0H
  LDA #<(dma_values + 1)
  STA A1T0L

  LDA #$40
  STA DAS0H  
  STZ DAS0L

  LDA #$01
  STA MDMAEN

  LDA VMAIN_STATUS
  STA VMAIN

  RTL


  dma_values:
  .byte $0C, $00, $02, $03