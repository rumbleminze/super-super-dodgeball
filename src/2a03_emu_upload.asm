.segment "SOUND_EMU"

.DEFINE NesAPUEmulatorBinSize $2C00

upload_sound_emulator_to_spc:
  PHP
  setA8

  
  LDA #$8F
  STA INIDISP     ; Turn screen off
  STZ NMITIMEN    ; disable interrupts

  setXY16
  PHB
  LDA #SPC700CodeBank ; #$8C
  PHA
  PLB

  LDX #$BBAA
  WaitSPCEq:
    cpx APUIO0
    bne WaitSPCEq    ; wait for SPC to be ready

		ldy #$0000

		ldx #NesAPUEmulatorBinSize
		stx TEMP_DATA
    ldx #$0400       ; start address for writing
    stx APUIO2

    lda #$01
    sta APUIO1        ; block

		; send the load starter byte: $CC
    lda #$CC
    sta APUIO0
  WaitSPC700Start:
    lda APUIO0
    cmp #$CC
    bne WaitSPC700Start  
  SendAll:
		lda sound_emulator_first_2FBB, Y ; Get the SPC700 binary code from the rom
		sta APUIO1               ; send byte
		tya
		sta APUIO0
  WaitSPCReply:
    cmp APUIO0
    bne WaitSPCReply        ; wait for SPC to reply with # sent
		iny
		cpy TEMP_DATA             ; test if transfer is finished
		bne SendAll
        ; send terminator block
		stz APUIO1
		ldx #$0400
		stx APUIO2
		; send the transfered byte count
		iny
		iny
		tya
		sta APUIO0
  Spc700FwEnd:
		lda #$01
		sta APUInit
		plb ; Restore the bank
    plp
  STZ $00
  STZ $01
  STZ $02
    RTL

;   REP #$18
;   PHB
;   LDA #$8C
;   PHA
;   PLB
;   STZ $02
;   LDX #$BBAA
; : CPX $2140
;   BNE :-
;   LDY #$0000
;   LDX #$8000
;   STX $00
;   LDX #$0200
;   STX $2142
;   LDA #$01
;   STA $2141
;   LDA #$CC
;   STA $2140
; : LDA $2140
;   CMP #$CC
;   BNE :-
; : LDA $8000,Y
;   STA $2141
;   TYA
;   STA $2140
; : CMP $2140
;   BNE :-
;   INY
;   CPY $00
;   BNE :--
;   INC $02
;   LDA $02
;   CMP #$02
;   BEQ :+
;   LDY #$0000
;   LDX #$7DC0
;   STX $00
;   LDA #$8D
;   PHA
;   PLB
;   BRA :--
; : STZ $2141
;   LDX #$0200
;   STX $2142
;   INY
;   INY
;   TYA
;   STA $2140

;   ;   LDA #$00 ; - set to 00 to disable all sound
;   LDA #$01
;   STA $0A18

;   PLB
;   STZ $00
;   STZ $01
;   STZ $02
;   SEP #$30
;   RTL

