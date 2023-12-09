; bank 0 - this houses our init routine and setup stuff
.segment "PRGA0"
init_routine:
  PHK 
  PLB 
  BRA initialize_registers

initialize_registers:
  setAXY16
  setA8

  LDA #$80
  STA INIDISP
  STA INIDISP_STATE
  STZ OBSEL
  STZ OAMADDL
  STZ OAMADDH
  STZ BGMODE  
  STZ MOSAIC  
  STZ BG1SC   
  STZ BG2SC   
  STZ BG3SC   
  STZ BG4SC   
  STZ BG12NBA 
  STZ BG34NBA 
  STZ BG1HOFS 
  STZ BG1HOFS
  STZ BG1VOFS
  STZ BG1VOFS
  STZ BG2HOFS
  STZ BG2HOFS
  STZ BG2VOFS
  STZ BG2VOFS
  STZ BG3HOFS
  STZ BG3HOFS
  STZ BG3VOFS
  STZ BG3VOFS
  STZ BG4HOFS
  STZ BG4HOFS
  STZ BG4VOFS
  STZ BG4VOFS

  STZ ACTIVE_NES_BANK

  LDA #$80
  STA VMAIN
  STZ VMADDL
  STZ VMADDH
  STZ M7SEL
  STZ M7A

  LDA #$01
  STA M7A
  STA MEMSEL
  STZ M7B
  STZ M7B
  STZ M7C
  STZ M7C
  STZ M7D
  STA M7D
  STZ M7X
  STZ M7X
  STZ M7Y
  STZ M7Y
  STZ CGADD
  STZ W12SEL
  STZ W34SEL
  STZ WOBJSEL
  STZ WH0
  STZ WH1     
  STZ WH2     
  STZ WH3     
  STZ WBGLOG  
  STZ WOBJLOG 
  STZ TM      
  STZ TS      
  STZ TMW     

  LDA #$30
  STA CGWSEL
  STZ CGADSUB

  LDA #$E0
  STA COLDATA
  ; STZ SETINI
  STZ NMITIMEN
  STZ NMITIMEN_STATUS

  LDA #$FF
  STA WRIO   
  STZ CHR_BANK_SWITCH_P1
  
  LDA #$01
  STA CHR_BANK_SWITCH_P2
  
  STZ WRMPYA 
  STZ WRMPYB 
  STZ WRDIVL 
  STZ WRDIVH 
  STZ WRDIVB 
  STZ HTIMEL 
  STZ HTIMEH 
  STZ VTIMEL 
  STZ VTIMEH 
  STZ MDMAEN 
  STZ HDMAEN 
  STZ MEMSEL 

  setAXY8
  LDA #$00
  LDY #$0F
; : STA ATTRIBUTE_DMA, Y
  ; STA COLUMN_1_DMA, Y
  ; DEY
  ; BNE :-

  LDY #$40
: DEY
  STA $0900, y
  BNE :-


  ; lda #0000
	; sta BG12NBA
  ; JSR clearvm
  ; JSR zero_oam  
  ; JSR dma_oam_table

  STA OBSEL
  LDA #$11
  STA BG12NBA
  LDA #$77
  STA BG34NBA
  LDA #$01
  STA BGMODE
  LDA #$21
  STA BG1SC
;   LDA #$32
;   STA BG2SC
;   LDA #$28
;   STA BG3SC
;   LDA #$7C
;   STA BG4SC
  LDA #$80
  STA OAMADDH
  LDA #$11
  STA TMW
  LDA #$02
  STA W12SEL
  STA WOBJSEL
  
  lda #%00010001
  STA TM
  LDA #$01
  STA MEMSEL
  ; Enable overscan mode to approximate NES draw positions
  LDA #$04
  STA SETINI


	lda #%0000000
	sta OBSEL

  ; JSR zero_attribute_buffer

  ; STZ ATTR_NES_HAS_VALUES
  ; STZ ATTR_NES_VM_ADDR_HB
  ; STZ ATTR_NES_VM_ADDR_LB
  ; STZ ATTR_NES_VM_ATTR_START
  ; STZ ATTRIBUTE_DMA
  ; STZ COL_ATTR_HAS_VALUES
  ; STZ COLUMN_1_DMA

  ; JSL upload_sound_emulator_to_spc

  ; LDA #$A1
  ; PHA
  ; PLB 
  JSR clearvm
  JSL check_for_chr_bankswap
  JSL check_for_second_table_chr_bankswap


  RTL


clearvm:
	setAXY16
  ldx #$2000
  stx VMADDL 
	
	lda #$0000
	
	LDY #$0000
	clear_loop:
		sta VMDATAL
		iny
		CPY #(32*64)
		BNE clear_loop
  
  setAXY8
	RTS

snes_nmi:
  ; JSR check_for_chr_bankswap
  ; JSR check_for_second_table_chr_bankswap
  RTL

bankswap_table:
.byte .lobyte(chrom_bank_0_tileset_0),  .hibyte(chrom_bank_0_tileset_0), $A8
.byte .lobyte(chrom_bank_0_tileset_1),  .hibyte(chrom_bank_0_tileset_1), $A8
.byte .lobyte(chrom_bank_0_tileset_2),  .hibyte(chrom_bank_0_tileset_2), $A8
.byte .lobyte(chrom_bank_0_tileset_3),  .hibyte(chrom_bank_0_tileset_3), $A8

.byte .lobyte(chrom_bank_1_tileset_4),  .hibyte(chrom_bank_1_tileset_4), $A9
.byte .lobyte(chrom_bank_1_tileset_5),  .hibyte(chrom_bank_1_tileset_5), $A9
.byte .lobyte(chrom_bank_1_tileset_6),  .hibyte(chrom_bank_1_tileset_6), $A9
.byte .lobyte(chrom_bank_1_tileset_7),  .hibyte(chrom_bank_1_tileset_7), $A9

.byte .lobyte(chrom_bank_2_tileset_8),  .hibyte(chrom_bank_2_tileset_8), $AA
.byte .lobyte(chrom_bank_2_tileset_9),  .hibyte(chrom_bank_2_tileset_9), $AA
.byte .lobyte(chrom_bank_2_tileset_10), .hibyte(chrom_bank_2_tileset_10), $AA
.byte .lobyte(chrom_bank_2_tileset_11), .hibyte(chrom_bank_2_tileset_11), $AA

.byte .lobyte(chrom_bank_3_tileset_12), .hibyte(chrom_bank_3_tileset_12), $AB
.byte .lobyte(chrom_bank_3_tileset_13), .hibyte(chrom_bank_3_tileset_13), $AB
.byte .lobyte(chrom_bank_3_tileset_14), .hibyte(chrom_bank_3_tileset_14), $AB
.byte .lobyte(chrom_bank_3_tileset_15), .hibyte(chrom_bank_3_tileset_15), $AB

.byte .lobyte(chrom_bank_4_tileset_16), .hibyte(chrom_bank_4_tileset_16), $AC
.byte .lobyte(chrom_bank_4_tileset_17), .hibyte(chrom_bank_4_tileset_17), $AC
.byte .lobyte(chrom_bank_4_tileset_18), .hibyte(chrom_bank_4_tileset_18), $AC
.byte .lobyte(chrom_bank_4_tileset_19), .hibyte(chrom_bank_4_tileset_19), $AC

.byte .lobyte(chrom_bank_5_tileset_20), .hibyte(chrom_bank_5_tileset_20), $AD
.byte .lobyte(chrom_bank_5_tileset_21), .hibyte(chrom_bank_5_tileset_21), $AD
.byte .lobyte(chrom_bank_5_tileset_22), .hibyte(chrom_bank_5_tileset_22), $AD
.byte .lobyte(chrom_bank_5_tileset_23), .hibyte(chrom_bank_5_tileset_23), $AD

.byte .lobyte(chrom_bank_6_tileset_24), .hibyte(chrom_bank_6_tileset_24), $AE
.byte .lobyte(chrom_bank_6_tileset_25), .hibyte(chrom_bank_6_tileset_25), $AE
.byte .lobyte(chrom_bank_6_tileset_26), .hibyte(chrom_bank_6_tileset_26), $AE
.byte .lobyte(chrom_bank_6_tileset_27), .hibyte(chrom_bank_6_tileset_27), $AE

.byte .lobyte(chrom_bank_7_tileset_28), .hibyte(chrom_bank_7_tileset_28), $AF
.byte .lobyte(chrom_bank_7_tileset_29), .hibyte(chrom_bank_7_tileset_29), $AF
.byte .lobyte(chrom_bank_7_tileset_30), .hibyte(chrom_bank_7_tileset_30), $AF
.byte .lobyte(chrom_bank_7_tileset_31), .hibyte(chrom_bank_7_tileset_31), $AF

: RTL
check_for_chr_bankswap:
  

  LDA CHR_BANK_SWITCH_P1
  CMP #$FF
  BEQ :-

  PHB
  LDA #$A0
  PHA
  PLB

  ; looks like we need to switch CHR Banks
  ; we fake this by DMA'ing tiles from the right tileset
  ; multiply by 3 to get the offset
  LDA CHR_BANK_SWITCH_P1
  STA CHR_BANK_CURR_P1
  ASL A
  ADC CHR_BANK_SWITCH_P1
  TAY

  LDA #$80
  STA VMAIN

  LDA #$FF
  STA CHR_BANK_SWITCH_P1

  LDA #$01
  STA DMAP0

  LDA #$18
  STA BBAD0

  ; source LB
  LDA bankswap_table, Y
  STA A1T0L

  ; source HB
  INY
  LDA bankswap_table, y
  STA A1T0H

  ; source DB
  INY
  LDA bankswap_table, y
  STA A1B0

  ; 0x2000 bytes
  LDA #$20
  STA DAS0H
  STZ DAS0L

  ; page 1 is at $0000
  LDA #$00
  STZ VMADDH
  STZ VMADDL

  LDA #$01
  STA MDMAEN

  PLB

  LDA VMAIN_STATUS
  STA VMAIN

: RTL

check_for_second_table_chr_bankswap:
  LDA CHR_BANK_SWITCH_P2
  CMP #$FF
  BEQ :-

  PHB
  LDA #$A0
  PHA
  PLB

  ; looks like we need to switch CHR Banks
  ; we fake this by DMA'ing tiles from the right tileset
  ; multiply by 3 to get the offset
  LDA CHR_BANK_SWITCH_P2
  STA CHR_BANK_CURR_P2
  ASL A
  ADC CHR_BANK_SWITCH_P2
  TAY

  LDA #$80
  STA VMAIN

  LDA #$FF
  STA CHR_BANK_SWITCH_P2

  LDA #$01
  STA DMAP1

  LDA #$18
  STA BBAD1

  ; source LB
  LDA bankswap_table, Y
  STA A1T1L

  ; source HB
  INY
  LDA bankswap_table, y
  STA A1T1H

  ; source DB
  INY
  LDA bankswap_table, y
  STA A1B1

  ; 0x2000 bytes
  LDA #$20
  STA DAS1H
  STZ DAS1L

  ; page 2 is at $1000
  LDA #$10
  STA VMADDH
  STZ VMADDL

  LDA #$02
  STA MDMAEN
  PLB
  LDA VMAIN_STATUS
  STA VMAIN

  RTL


; read_chr_data:
;   PHB
;   LDA $56
;   STA CHR_BANK_READ_HB
;   CMP $10
;   BCS :+
;   LDA CHR_BANK_CURR_P1
;   BRA :++
; : LDA CHR_BANK_CURR_P2
; : PHA
;   PLB
;   LDA $55
;   STA CHR_BANK_READ_LB

;   LDY #$00
;   LDA (CHR_BANK_READ_LB), Y
  
  PLB
  RTL

load_palette:
  PHX
  PHY
  PHA
  PHB
  PLA
  STA $04
  PHA

  setAXY8

  LDA #$A0
  PHA
  PLB
  LDY #$00
  STZ CGADD

palette_entry:
  LDA [$02],Y
  ASL A
  TAX
  LDA palette_lookup, X
  STA CGDATA
  LDA palette_lookup + 1, X
  STA CGDATA
  INY

; every 4 we need to write a bunch of empty palette entries
  TYA
  AND #$03
  BNE skip_writing_three_rows
  JSR write_empty_palette_row
  JSR write_empty_palette_row
  JSR write_empty_palette_row
skip_writing_three_rows:
  TYA
  AND #$0F
  CMP #$00
  BNE skip_writing_four_empties
  ; after 16 entries we write an empty set of palettes
  jsr write_empty_palette_set
  jsr write_empty_palette_set
  jsr write_empty_palette_set
  jsr write_empty_palette_set  
skip_writing_four_empties:
  CPY #$20
  BNE palette_entry

  PLB
  PLA
  PLY
  PLX

  RTL

write_empty_palette_set:
  JSR write_empty_palette_row
  JSR write_empty_palette_row
  JSR write_empty_palette_row
  JSR write_empty_palette_row
  RTS

write_empty_palette_row:
  STZ CGDATA
  STZ CGDATA
  STZ CGDATA
  STZ CGDATA
  STZ CGDATA
  STZ CGDATA
  STZ CGDATA
  STZ CGDATA
  RTS
  .include "palette_lookup.asm"
  .include "hardware-status-switches.asm"