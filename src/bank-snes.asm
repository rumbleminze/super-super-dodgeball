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
  STZ SNES_OAM_TRANSLATE_NEEDED

  LDA #$80
  STA VMAIN
  STA VMAIN_STATUS
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
  STZ OBJ_CHR_BANK_SWITCH
  
  LDA #$01
  STA BG_CHR_BANK_SWITCH
  
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
  JSR zero_oam  
  JSR dma_oam_table
  jslb zero_all_palette, $a0

  LDA #$04
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
  LDA #$00
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

  jsl upload_sound_emulator_to_spc

  ; LDA #$A1
  ; PHA
  ; PLB   
  LDA #$0C
  STA CHR_BANK_BANK_TO_LOAD
  LDA #$00
  STA CHR_BANK_TARGET_BANK
  jslb load_chr_table_to_vm, $a0
    
  LDA #$0a
  STA CHR_BANK_BANK_TO_LOAD
  LDA #$01
  STA CHR_BANK_TARGET_BANK
  jslb load_chr_table_to_vm, $a0
    
  LDA #$0A
  STA CHR_BANK_BANK_TO_LOAD
  LDA #$03
  STA CHR_BANK_TARGET_BANK
  jslb load_chr_table_to_vm, $a0

  LDA #$0D
  STA CHR_BANK_BANK_TO_LOAD
  LDA #$04
  STA CHR_BANK_TARGET_BANK
  jslb load_chr_table_to_vm, $a0
  
  LDA #$0B
  STA CHR_BANK_BANK_TO_LOAD
  LDA #$05
  STA CHR_BANK_TARGET_BANK
  jslb load_chr_table_to_vm, $a0
  
  LDA #$19
  STA CHR_BANK_BANK_TO_LOAD
  LDA #$06
  STA CHR_BANK_TARGET_BANK
  jslb load_chr_table_to_vm, $a0

  LDA #$1B
  STA CHR_BANK_BANK_TO_LOAD
  STA DATA_CHR_BANK_CURR
  LDA #$07
  STA CHR_BANK_TARGET_BANK
  jslb load_chr_table_to_vm, $a0

  JSR clearvm
  jslb check_for_chr_bankswap, $a0
  jslb check_for_bg_chr_bankswap, $a0

  jslb set_middle_attributes_to_palette_3, $a0

  JSR do_intro

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
  LDA RDNMI
  JSR dma_oam_table  
  jslb hud_hdma_setup, $a0
  ; JSR translate_nes_sprites_to_oam
  RTL

snes_busy_loop:
  PHP
  LDA SNES_OAM_TRANSLATE_NEEDED
  BNE :+
  PLP
  RTL
: 
  SEI
  PHA
  PHX
  PHY
  PHB
  JSR translate_nes_sprites_to_oam

  PLB
  PLY
  PLX
  PLA
  PLP
  CLI
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

  LDA OBJ_CHR_BANK_SWITCH
  CMP #$FF
  BEQ :-
  CMP CHR_BANK_CURR_P1
  BEQ :-

  LDA OBJ_CHR_BANK_SWITCH
  STA CHR_BANK_CURR_P1
  ; LDA #$FF
  ; STA OBJ_CHR_BANK_SWITCH
  
  PHB
  LDA #$A0
  PHA
  PLB

  ; looks like we need to switch CHR Banks
  ; we fake this by DMA'ing tiles from the right tileset
  ; multiply by 3 to get the offset
  LDA CHR_BANK_CURR_P1
  ASL A
  ADC CHR_BANK_CURR_P1
  TAY

  LDA #$80
  STA VMAIN

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


; we'll put the data at $7000 always
swap_data_bg_chr:
  LDA BG_CHR_BANK_SWITCH
  CMP DATA_CHR_BANK_CURR
  BEQ :-
  STA DATA_CHR_BANK_CURR
  LDA #$60
  STA TARGET_BANK_OFFSET
  JMP bankswap_start


check_for_bg_chr_bankswap:
  LDA BG_CHR_BANK_SWITCH
  CMP #$FF
  BEQ :-

  CMP #$1A
  BPL swap_data_bg_chr

  CMP BG_CHR_BANK_CURR
  BEQ :-

bankswap_start:
  LDA NMITIMEN_STATUS
  AND #$7F
  STA NMITIMEN
  
  LDA INIDISP_STATE
  ORA #$80
  STA INIDISP

  ; LDA RDNMI
: LDA RDNMI
  AND #$80
  BEQ :-

  ; LDA #$80
  ; STA INIDISP
  ; STZ TM
  
  LDA BG_CHR_BANK_SWITCH
  STA BG_CHR_BANK_CURR
  ; LDA #$FF
  ; STA OBJ_CHR_BANK_SWITCH

  PHB
  LDA #$A0
  PHA
  PLB

  ; looks like we need to switch CHR Banks
  ; we fake this by DMA'ing tiles from the right tileset
  ; multiply by 3 to get the offset
  LDA BG_CHR_BANK_CURR
  ASL A
  ADC BG_CHR_BANK_CURR
  TAY

  LDA #$80
  STA VMAIN

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

  ; page 2 is at $1000, data bank will add 6000 to that
  LDA #$10
  ADC TARGET_BANK_OFFSET
  STA VMADDH
  STZ VMADDL
  STZ TARGET_BANK_OFFSET

  LDA #$02
  STA MDMAEN
  PLB
  LDA VMAIN_STATUS
  STA VMAIN

  LDA INIDISP_STATE
  STA INIDISP

  LDA NMITIMEN_STATUS
  STA NMITIMEN

  ; LDA #$11
  ; STA TM
  ; LDA INIDISP_STATE
  ; STA INIDISP

  RTL

bankswitch_bg_chr_data:
  PHB
  LDA #$A0
  PHA
  PLB

  ; bgs are on 1000, 3000, 5000, 7000.
  LDY #$01
: LDA CHR_BANK_LOADED_TABLE, y
  CMP CHR_BANK_BANK_TO_LOAD
  BEQ switch_bg_to_y
  CPY #$07
  BEQ new_bg_bank
  INY
  INY
  BRA :-
  RTL

new_bg_bank:

  LDA CHR_BANK_BANK_TO_LOAD
  
  CMP #$19
  BPL new_data_bank
  PLB
  RTL

switch_bg_to_y:
  TYA
  ORA #$10
  STA BG12NBA

  PLB
  RTL
new_data_bank:

  STZ CHR_BANK_TARGET_BANK
  INC CHR_BANK_TARGET_BANK
  jslb load_chr_table_to_vm, $a0

  PLB
  RTL

bankswitch_obj_chr_data:
  ; this is a hack that happens to work most of the time.
  STZ NES_H_SCROLL

  PHB
  PHK
  PLB

  LDY #$00
: CPY #$01
  BEQ skip_bg_vram
  CPY #$02
  BEQ skip_bg_vram

  LDA CHR_BANK_LOADED_TABLE, y
  CMP CHR_BANK_BANK_TO_LOAD
  BEQ switch_to_y
  CPY #$07
  BEQ new_obj_bank
skip_bg_vram:
  INY
  BRA :-

new_obj_bank:
  ; todo load the bank into 0000, 4000, or 6000
  LDA INIDISP_STATE
  ORA #$80
  STA INIDISP

  LDA CHR_BANK_BANK_TO_LOAD
  TAY
  LDA target_obj_banks, Y
  STA CHR_BANK_TARGET_BANK
  PHA
  jslb load_chr_table_to_vm, $a0

  LDA CHR_BANK_BANK_TO_LOAD
  CMP #$0C
  BEQ :+
  SEC
  SBC #$0B
  bmi :+
  SBC #$0F
  bpl :+

  ; this is between 0A and 19, so we load 17 too
  LDA #$17
  STA CHR_BANK_BANK_TO_LOAD
  LDA #$04
  STA CHR_BANK_TARGET_BANK
  jslb load_chr_table_to_vm, $a0

: 
  LDA INIDISP_STATE
  STA INIDISP
  PLA
  TAY
  bra switch_to_y

switch_to_y:
  ; our target bank is loaded at #$y000
  ; so just update our obj definition to use that for sprites
  TYA
  STZ OBJ_CHR_HB
  CLC
  LSR ; for updating obsel, we have to halve y.  
  BCC :+
  INC OBJ_CHR_HB
: STA OBSEL
  PLB
  RTL


load_chr_table_to_vm:
  LDA CHR_BANK_TARGET_BANK
  TAY
  LDA CHR_BANK_BANK_TO_LOAD
  STA CHR_BANK_LOADED_TABLE, Y
  
  JSR dma_chr_to_vm

  RTL

dma_chr_to_vm:
  PHB
  LDA #$A0
  PHA
  PLB

  ; looks like we need to switch CHR Banks
  ; we fake this by DMA'ing tiles from the right tileset
  ; multiply by 3 to get the offset
  LDA CHR_BANK_BANK_TO_LOAD
  ASL A
  ADC CHR_BANK_BANK_TO_LOAD
  TAY

  LDA #$80
  STA VMAIN

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

  ; 
  LDA CHR_BANK_TARGET_BANK
  ASL
  ASL
  ASL
  ASL
  STA VMADDH
  STZ VMADDL

  LDA #$02
  STA MDMAEN
  PLB
  LDA VMAIN_STATUS
  STA VMAIN

  RTS

; which bank we should swap the sprite into, 00 - 0A aren't sprites so we set it to 0
; we only use 00, 10, and 11 for sprite locations, which are 00, 04, and 06
target_obj_banks:
.byte $00 ; 00 - Sprites
.byte $00 ; 01 - Sprites
.byte $00 ; 02 - Sprites
.byte $00 ; 03 - Sprites
.byte $00 ; 04 - Sprites
.byte $00 ; 05 - Sprites
.byte $00 ; 06 - Sprites
.byte $00 ; 07 - Sprites
.byte $00 ; 08 - Sprites
.byte $00 ; 09 - Sprites
.byte $00 ; 0A - Sprites
.byte $00 ; 0B - Sprites
.byte $04 ; 0C - Sprites
.byte $06 ; 0D - Sprites / Letters
.byte $06 ; 0E - Sprites / Letters
.byte $06 ; 0F - Sprites / Letters
.byte $00 ; 10 - BG Tiles
.byte $00 ; 11 - BG Tiles
.byte $00 ; 12 - BG Tiles
.byte $00 ; 13 - BG Tiles
.byte $00 ; 14 - BG Tiles
.byte $00 ; 15 - BG Tiles
.byte $00 ; 16 - BG Tiles
.byte $00 ; 17 - BG Tiles
.byte $00 ; 18 - BG Tiles
.byte $00 ; 19 - BG Tiles
.byte $00 ; 1A - BG Tiles
.byte $00 ; 1B - BG Tiles
.byte $00 ; 1C - BG Tiles
.byte $00 ; 1D - BG Tiles
.byte $00 ; 1E - BG Tiles
.byte $00 ; 1F - BG Tiles





handle_arrow_game_type:
  PHB
  PHA
; F53E
  LDA #$A0
  PHA
  PLB

  LDA $06B1
  TAX
  LDY #$00

: LDA game_type_arrow+1,Y
  STA VMADDH ; PpuAddr_2006

  LDA game_type_arrow,Y
  STA VMADDL ; PpuAddr_2006
  INY
  INY

  CPX #$00
  BNE :+
  PLA
  BRA :++
: LDA #$00
: STA VMDATAL ; PpuData_2007
  DEX
  CPY #$06 
  BNE :---

  PLB
  RTL

handle_arrow_difficulty:
  PHB

  PHA
  LDA #$A0
  PHA
  PLB

  ; F555
  LDA $06EA
  TAX
  LDY #$00

: LDA difficulty_arrow+1,Y
  STA VMADDH ; PpuAddr_2006

  LDA difficulty_arrow,Y
  STA VMADDL ; PpuAddr_2006
  INY
  INY

  CPX #$00
  BNE :+
  PLA
  BRA :++
: LDA #$00
: STA VMDATAL ; PpuData_2007
  DEX
  CPY #$06 
  BNE :---

  PLB
  RTL

game_type_arrow:
.byte $E3, $20 ; $28
.byte $23, $21 ; $29
.byte $63, $21 ; $29
difficulty_arrow:
.byte $23, $23 ; $2B
.byte $2A, $23 ; $2B
.byte $33, $23 ; $2B

  .include "intro_screen.asm"
  .include "palette_updates.asm"
  .include "palette_lookup.asm"
  .include "hardware-status-switches.asm"
  .include "sprites.asm"
  .include "hud-hdma.asm"
  .include "attributes.asm"
  .include "2a03_conversion.asm"