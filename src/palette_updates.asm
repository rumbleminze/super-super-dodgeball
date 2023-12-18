load_sprite_palette_from_74:
  PHX
  PHY
  PHA

  LDA #$80
  STA PALETTE_OFFSET

  ; save these values in case they're used by the game
  LDA PALETTE_LOAD_LB
  PHA
  LDA PALETTE_LOAD_HB
  PHA
  LDA PALETTE_LOAD_DB
  PHA

  LDA $74
  STA PALETTE_LOAD_LB
  LDA $75
  STA PALETTE_LOAD_HB
  JMP load_palette_v2

load_palette_v2:
  PHB

  PLA
  STA PALETTE_LOAD_DB
  PHA

  setAXY8

  LDA #$A0
  PHA
  PLB
  LDY #$00
  LDA #$00
  ORA PALETTE_OFFSET
  STA CGADD

palette_entry_v2:
  LDA [PALETTE_LOAD_LB],Y
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
  BNE :+
  JSR write_empty_palette_row
  JSR write_empty_palette_row
  JSR write_empty_palette_row
:
  TYA
  AND #$0F
  CMP #$00
  BNE :+
  ; after 16 entries we write an empty set of palettes
  jsr write_empty_palette_set
  jsr write_empty_palette_set
  jsr write_empty_palette_set
  jsr write_empty_palette_set  
:
  CPY #$10
  BNE palette_entry_v2

  PLB

  PLA
  STA PALETTE_LOAD_DB

  PLA
  STA PALETTE_LOAD_HB

  PLA
  STA PALETTE_LOAD_LB
  
  PLA
  PLY
  PLX

  RTL

load_palette_from_74:
  PHX
  PHY
  PHA

  STZ PALETTE_OFFSET
  ; save these values in case they're used by the game
  LDA PALETTE_LOAD_LB
  PHA
  LDA PALETTE_LOAD_HB
  PHA
  LDA PALETTE_LOAD_DB
  PHA

  LDA $74
  STA PALETTE_LOAD_LB
  LDA $75
  STA PALETTE_LOAD_HB
  JMP load_palette_v2

load_palette_from_51:
  PHX
  PHY
  PHA

  STZ PALETTE_OFFSET
  ; save these values in case they're used by the game
  LDA PALETTE_LOAD_LB
  PHA
  LDA PALETTE_LOAD_HB
  PHA
  LDA PALETTE_LOAD_DB
  PHA

  LDA $51
  STA PALETTE_LOAD_LB
  LDA $52
  STA PALETTE_LOAD_HB
  JMP load_palette_v2

load_palette:
  PHX
  PHY
  PHA

  STZ PALETTE_OFFSET
  ; save these values in case they're used by the game
  LDA PALETTE_LOAD_LB
  PHA
  LDA PALETTE_LOAD_HB
  PHA
  LDA PALETTE_LOAD_DB
  PHA

  LDA $02
  STA PALETTE_LOAD_LB
  LDA $03
  STA PALETTE_LOAD_HB
  JMP load_palette_v2

load_tile_palette_from_4_addresses:
  PHX
  PHY
  PHA
  PHB
  PLA
  STA SPRITE_LOOKUP_DB
  PHA

  setAXY8

  LDA #$A0
  PHA
  PLB
  LDY #$00
  STZ CGADD

  LDA $02
  STA SPRITE_LOOKUP_LB
  LDA $03
  STA SPRITE_LOOKUP_HB

: LDA [SPRITE_LOOKUP_LB],Y
  ASL A
  TAX
  LDA palette_lookup, X
  STA CGDATA
  LDA palette_lookup + 1, X
  STA CGDATA
  INY  
  CPY #$04
  BNE :-
; every 4 we need to write a bunch of empty palette entries
  JSR write_empty_palette_row
  JSR write_empty_palette_row
  JSR write_empty_palette_row

  LDY #$00
  LDA $04
  STA SPRITE_LOOKUP_LB
  LDA $05
  STA SPRITE_LOOKUP_HB

: LDA [SPRITE_LOOKUP_LB],Y
  ASL A
  TAX
  LDA palette_lookup, X
  STA CGDATA
  LDA palette_lookup + 1, X
  STA CGDATA
  INY  
  CPY #$04
  BNE :-

; every 4 we need to write a bunch of empty palette entries
  JSR write_empty_palette_row
  JSR write_empty_palette_row
  JSR write_empty_palette_row

  LDY #$00
  LDA $06
  STA SPRITE_LOOKUP_LB
  LDA $07
  STA SPRITE_LOOKUP_HB

: LDA [SPRITE_LOOKUP_LB],Y
  ASL A
  TAX
  LDA palette_lookup, X
  STA CGDATA
  LDA palette_lookup + 1, X
  STA CGDATA
  INY  
  CPY #$04
  BNE :-
  
; every 4 we need to write a bunch of empty palette entries
  JSR write_empty_palette_row
  JSR write_empty_palette_row
  JSR write_empty_palette_row

  LDY #$00
  LDA $08
  STA SPRITE_LOOKUP_LB
  LDA $09
  STA SPRITE_LOOKUP_HB

: LDA [SPRITE_LOOKUP_LB],Y
  ASL A
  TAX
  LDA palette_lookup, X
  STA CGDATA
  LDA palette_lookup + 1, X
  STA CGDATA
  INY  
  CPY #$04
  BNE :-
  
; every 4 we need to write a bunch of empty palette entries
  JSR write_empty_palette_row
  JSR write_empty_palette_row
  JSR write_empty_palette_row

  ; after 16 entries we write an empty set of palettes
  jsr write_empty_palette_set
  jsr write_empty_palette_set
  jsr write_empty_palette_set
  jsr write_empty_palette_set  

  PLB
  PLA
  PLY
  PLX

  RTL


load_sprite_palette:
  PHX
  PHY
  PHA
  PHB
  PLA
  STA SPRITE_LOOKUP_DB
  PHA

  setAXY8

  LDA #$A0
  PHA
  PLB
  LDY #$00
  LDA #$80
  STA CGADD

  LDA $02
  STA SPRITE_LOOKUP_LB
  LDA $03
  STA SPRITE_LOOKUP_HB

: LDA [SPRITE_LOOKUP_LB],Y
  ASL A
  TAX
  LDA palette_lookup, X
  STA CGDATA
  LDA palette_lookup + 1, X
  STA CGDATA
  INY  
  CPY #$04
  BNE :-
; every 4 we need to write a bunch of empty palette entries
  JSR write_empty_palette_row
  JSR write_empty_palette_row
  JSR write_empty_palette_row

  LDY #$00
  LDA $04
  STA SPRITE_LOOKUP_LB
  LDA $05
  STA SPRITE_LOOKUP_HB

: LDA [SPRITE_LOOKUP_LB],Y
  ASL A
  TAX
  LDA palette_lookup, X
  STA CGDATA
  LDA palette_lookup + 1, X
  STA CGDATA
  INY  
  CPY #$04
  BNE :-

; every 4 we need to write a bunch of empty palette entries
  JSR write_empty_palette_row
  JSR write_empty_palette_row
  JSR write_empty_palette_row

  LDY #$00
  LDA $06
  STA SPRITE_LOOKUP_LB
  LDA $07
  STA SPRITE_LOOKUP_HB

: LDA [SPRITE_LOOKUP_LB],Y
  ASL A
  TAX
  LDA palette_lookup, X
  STA CGDATA
  LDA palette_lookup + 1, X
  STA CGDATA
  INY  
  CPY #$04
  BNE :-
  
; every 4 we need to write a bunch of empty palette entries
  JSR write_empty_palette_row
  JSR write_empty_palette_row
  JSR write_empty_palette_row

  LDY #$00
  LDA $08
  STA SPRITE_LOOKUP_LB
  LDA $09
  STA SPRITE_LOOKUP_HB

: LDA [SPRITE_LOOKUP_LB],Y
  ASL A
  TAX
  LDA palette_lookup, X
  STA CGDATA
  LDA palette_lookup + 1, X
  STA CGDATA
  INY  
  CPY #$04
  BNE :-
  
; every 4 we need to write a bunch of empty palette entries
  JSR write_empty_palette_row
  JSR write_empty_palette_row
  JSR write_empty_palette_row

  ; after 16 entries we write an empty set of palettes
  jsr write_empty_palette_set
  jsr write_empty_palette_set
  jsr write_empty_palette_set
  jsr write_empty_palette_set  

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