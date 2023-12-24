convert_audio:
  PHX
  PHY
  JSR detect_changes
  JSR emulate_length_counter
  JSR backup_regs
  JSR update_dsp
  LDA SNDTMP4016
  AND #$20
  STA SNDTMP4016
  PLY
  PLX
  RTL


detect_changes:
	sep #$30 ; All 8b
        lda SNDSQR1CTRL4000
        and #%00100000
        bne decay_disabled0

        lda SNDSQR1LENPH4003
        beq :+
        sta SNDTMP4003
        lda #0
        sta SNDSQR1LENPH4003

        lda SNDTMP4016
        ora #%00000001
        sta SNDTMP4016
        bra end_square0
:
        lda SNDTMP4016
        and #%11111110
        sta SNDTMP4016
        bra end_square0

decay_disabled0:
        lda SNDSQR1LENPH4003
        sta SNDTMP4003

end_square0:

        lda SNDSQR2CTRL4004
        and #%00100000
        bne decay_disabled1

        lda SNDSQR2LENPH4007
        beq :+
        sta SNDTMP4007
        lda #0
        sta SNDSQR2LENPH4007

        lda SNDTMP4016
        ora #00000010
        sta SNDTMP4016
        bra end_square1
:
        lda SNDTMP4016
        and #%11111101
        sta SNDTMP4016
        bra end_square1

decay_disabled1:
        lda SNDSQR2LENPH4007
        sta SNDTMP4007
end_square1:
                        ;       triangle wave
        lda SNDTRIACTRL4008
        and #%10000000
        bne disabled3

        lda SNDNOISECTRL400B
        beq :+
        sta SNDTMP400B
        lda #0
        sta SNDNOISECTRL400B
        lda SNDTMP4016
        ora #%00000100
        sta SNDTMP4016
        bra end_tri
:
        lda SNDTMP4016
        and #%11111011
        sta SNDTMP4016
        bra end_tri

disabled3:
        lda SNDNOISECTRL400B
        sta SNDTMP400B
end_tri:

        lda SNDNOISESHM400C
        and #%00100000
        bne decay_disabled2

        lda SNDDMCDAC400F
        beq :+
        sta SNDTMP400F
        lda #0
        sta SNDDMCDAC400F

        lda SNDTMP4016
        ora #%00001000
        sta SNDTMP4016
        bra end_noise
:
        lda SNDTMP4016
        and #%11110111
        sta SNDTMP4016
        bra end_noise

decay_disabled2:
        lda SNDDMCDAC400F
        sta SNDTMP400F
end_noise:
        ; check freq for sweeps
        lda SNDSQR1E4001
        and #%10000000
        beq sqsw1

        lda SNDSQR1E4001
        and #%00000111
        beq sqsw1x
        lda SNDSQR1PERIOD4002
        beq sqsw1
        sta SNDTMP4002
        lda #0
        sta SNDSQR1PERIOD4002
        lda SNDTMP4016
        ora #%01000000
        sta SNDTMP4016
        bra :+


sqsw1:
        lda SNDSQR1PERIOD4002
        sta SNDTMP4002
:
        bra nextcheck
sqsw1x:
        lda SNDTMP4016
        and #%10111111
        sta SNDTMP4016
        bra sqsw1

nextcheck:

        ; check freq for sweeps
        lda SNDSQR2E4005
        and #%10000000
        beq sqsw12

        lda SNDSQR2E4005
        and #%00000111
        beq sqsw1x2
        lda SNDSQR2PERIOD4006
        beq sqsw12
        sta SNDTMP4006
        lda #0
        sta SNDSQR2PERIOD4006
        lda SNDTMP4016
        ora #%10000000
        sta SNDTMP4016
        bra :+


sqsw12:
        lda SNDSQR2PERIOD4006
        sta SNDTMP4006
:
        bra nextcheck2
sqsw1x2:
        lda SNDTMP4016
        and #%01111111
        sta SNDTMP4016
        bra sqsw12

nextcheck2:

        rts

length_d3_0:
        .byte $06,$0B,$15,$29,$51,$1F,$08,$0F
        .byte $07,$0D,$19,$31,$61,$25,$09,$11

length_d3_1:
        .byte $80,$02,$03,$04,$05,$06,$07,$08
        .byte $09,$0A,$0B,$0C,$0D,$0E,$0F,$10

.byte $EA
emulate_length_counter:
  setAXY8
  lda #0
  sta SNDTMP4015
  ; square 0
  lda SNDTMP4016
  and #%00000001
  beq sq0_not_changed

  lda SNDTMP4013        
  pha
  and #%00001000
  beq sq0_d3_0

  pla
  lsr a
  lsr a
  lsr a
  lsr a

  xba
  lda #0
  xba

  tay
  lda length_d3_1, Y
  sta square0_length
  bra sq0_load_end

sq0_d3_0:
  pla
  lsr a
  lsr a
  lsr a
  lsr a

  tay
  lda length_d3_0, Y
  sta square0_length        

sq0_load_end:

;        lda #0
;        sta $7F4003

sq0_not_changed:

  lda SNDTMP4015
  ora #%00000001
  sta SNDTMP4015

  lda SNDSQR1CTRL4000
  and #%00100000
  bne sq0_counter_disabled


  lda square0_length
  beq blahsq
  dec square0_length
  bra sq0_counter_disabled

blahsq:
  lda SNDTMP4015
  and #%11111110
  sta SNDTMP4015

sq0_counter_disabled:
  ; square 1
  lda SNDTMP4016
  and #%00000010
  beq sq1_not_changed

  lda SNDTMP4007
  pha
  and #%00001000
  beq sq1_d3_0

  pla
  lsr a
  lsr a
  lsr a
  lsr a

  xba
  lda #0
  xba

  tay
  lda length_d3_1, Y
  sta square1_length
  bra sq1_load_end

sq1_d3_0:
  pla
  lsr a
  lsr a
  lsr a
  lsr a

  tay
  lda length_d3_0, Y
  sta square1_length        

sq1_load_end:

;        lda #0
;        sta $7F4007

sq1_not_changed:

  lda SNDTMP4015
  ora #%00000010
  sta SNDTMP4015

  lda SNDSQR2CTRL4004
  and #%00100000
  bne sq1_counter_disabled

  lda square1_length
  beq sqblah
  dec square1_length
  bra sq1_counter_disabled
sqblah:
  lda SNDTMP4015
  and #%11111101
  sta SNDTMP4015

sq1_counter_disabled:

  ; triangle channel
  lda SNDTMP4016
  and #%00000100
  beq tri_not_changed

  lda SNDTMP400B
  pha
  and #%00001000
  beq tri_d3_0

  pla
  lsr a
  lsr a
  lsr a
  lsr a

  xba
  lda #0
  xba

  tay
  lda length_d3_1, Y
  sta triangle_length
  bra tri_load_end

tri_d3_0:
  pla
  lsr a
  lsr a
  lsr a
  lsr a

  tay
  lda length_d3_0, Y
  sta triangle_length        

tri_load_end:

;        lda #0
;        sta $7F400B

tri_not_changed:

  lda SNDTMP4015
  ora #%00000100
  sta SNDTMP4015

  lda SNDTRIACTRL4008
  and #%10000000
  bne tri_counter_disabled

  lda triangle_length
  beq blah
  dec triangle_length
  bra tri_counter_disabled
blah:
  lda SNDTMP4015
  and #%11111011
  sta SNDTMP4015

tri_counter_disabled:

                          ; noise channel
  lda SNDTMP4016
  and #%00001000          ; get length value (0 if unchanged)
  beq unchanged

  lda SNDTMP400F
  pha
  and #%00001000
  beq d3_0

  pla
  lsr a
  lsr a
  lsr a
  lsr a

  xba
  lda #0
  xba

  tay
  lda length_d3_1, Y
  sta noise_length

  bra load_end

d3_0:
  pla
  lsr a
  lsr a
  lsr a
  lsr a

  tay
  lda length_d3_0, Y
  sta noise_length

load_end:
;        lda #0
;        sta $7F400F

unchanged:

  lda SNDTMP4015
  ora #%00001000
  sta SNDTMP4015

  lda SNDNOISESHM400C
  and #%00100000
  bne noise_counter_disabled

  lda noise_length
  beq pleh

  dec noise_length
  bra noise_counter_disabled

pleh:
  lda SNDTMP4015
  and #%11110111
  sta SNDTMP4015

noise_counter_disabled:

  lda SNDTMP4015
  and SNDCHANSW4015
  sta SNDTMP4015

  rts
  
sound_lookup_table_1:
.byte $06, $0B, $15, $29, $51, $1F, $08, $0F, $07, $0D, $19, $31, $61, $25, $09, $11
sound_lookup_table_2:
.byte $80, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F, $10
.byte $FF


backup_regs:
  lda SNDSQR1CTRL4000
  sta SNDTMP4000
  lda SNDSQR1E4001
  sta SNDTMP4001
  lda SNDSQR2CTRL4004
  sta SNDTMP4004
  lda SNDSQR2E4005
  sta SNDTMP4005
  lda SNDTRIACTRL4008
  sta SNDTMP4008
  lda SNDTRIAPERIOD4009
  sta SNDTMP4009
  lda SNDTRIALENPH400A
  sta SNDTMP400A
  lda SNDNOISESHM400C
  sta SNDTMP400C
  lda SNDNOISELEN400D
  sta SNDTMP400D
  lda SNDDMCCTRL400E
  sta SNDTMP400E
  lda SNDDMCSLEN4011
  sta SNDTMP4011
  rts

update_dsp:
  lda APUInit
  bne ContinueAPUUpdate
  rts
ContinueAPUUpdate:
  php
  setAXY8
  phx
WaitSPC700Ready:
  lda APUIO0
  cmp #$7D                ; wait for SPC ready
  bne WaitSPC700Ready

  lda #$D7
  sta APUIO0               ; tell SPC that CPU is ready
WSPC700Reply:
  cmp APUIO0               ; wait for reply
  bne WSPC700Reply

  ldx #0
  stx APUIO0               ; clear port 0
xfer:
  lda SNDTMP4000, X
  ;lda SNDSQR1CTRL4000, X
  sta APUIO1               ; send data to port 1
WSPC700Reply2:
  cpx APUIO0               ; wait for reply on port 0
  bne WSPC700Reply2
  inx
  cpx #$17
  beq NesRegLoadEnds
  stx APUIO0
  bra xfer
NesRegLoadEnds:
  plx
  plp
  rts