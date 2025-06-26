.segment "PRGB2"

; Audio Tracks for Super Dodge Ball
; NES value - track


.DEFINE NUM_TRACKS        $14

; Read Flags
.DEFINE MSU_STATUS      $2000
.DEFINE MSU_READ        $2001
.DEFINE MSU_ID          $2002   ; 2002 - 2007

; Write flags
.DEFINE MSU_SEEK        $2000
.DEFINE MSU_TRACK       $2004   ; 2004 - 2005
.DEFINE MSU_VOLUME      $2006
.DEFINE MSU_CONTROL     $2007

; game specific flags, needs to be updated
.DEFINE NSF_STOP        #$00
.DEFINE NSF_PAUSE       #$FD ; 
.DEFINE NSF_RESUME      #$FF ; 
.DEFINE NSF_MUTE        #$00

play_track_hijack:
    STZ MSU_700_OVERWRITE
    STZ MSU_701_OVERWRITE
    STA $0701
    bne :+
    ; 00 is no sound, and the game takes care of stopping
    ; so we can return.  We'll also return 00 if we're going to play
    ; msu-1
      rtl
  :
    PHA
    jsl msu_check
    BEQ :+
    ; non-0 value returned from MSU-check, we're not playing MSU
    ; either it's not a music track or we don't have it.
    ; return the original value
    PLA
    rtl

:   
;   00 returned from msu_check, mute nsf and return the mute value
    jsr set_overwrites_if_needed

    PLA
    STZ $701
    LDA NSF_MUTE

    rtl

; we need to set overwrites only if we have a timer waiting
set_overwrites_if_needed:  
  PHB
  PHK
  PLB

  LDA $00
  PHA
  LDA $01
  PHA

  LDA MSU_TRACK_IDX
  ASL a
  TAY

  LDA track_timers, Y
  STA $00
  INY 
  LDA track_timers, y
  STA $01
  
  LDY #$00
  LDA ($00),Y
  INY
  ORA ($00),Y
  BEQ :+
    LDA CURRENT_NSF
    STA MSU_701_OVERWRITE
    LDA #$02
    STA MSU_700_OVERWRITE
    STZ $0701    
  : 

  PLA
  STA $01
  PLA
  STA $00
  PLB

  rts

wait_a_frame:
  LDA RDNMI
: LDA RDNMI
  BPL :-
  rts


check_for_all_tracks_present:
  PHB
  LDA #$B2
  PHA
  PLB
  LDA MSU_ID		; load first byte of msu-1 identification string
  CMP #$53		    ; is it "M" present from "MSU-1" string?
  BEQ :+
  PLB
  RTL ; no MSU exit early

: STZ MSU_VOLUME
  LDY #NUM_TRACKS
  INY
: 
  jsr wait_a_frame
  STZ MSU_CONTROL

  DEY
  BMI :+
  
  LDA #$00
  STA TRACKS_AVAILABLE, Y
  STA TRACKS_ENABLED, Y

  TYA
  STA MSU_TRACK
  STZ MSU_TRACK + 1 

  msu_status_check:
    LDA MSU_STATUS
    AND #$40
    BNE msu_status_check
  ; LDA #$FF
  ; :		; check msu ready status (required for sd2snes hardware compatibility)
  ;   bit MSU_STATUS
  ;   bvs :-

  LDA MSU_STATUS ; load track STAtus
  AND #$08		; isolate PCM track present byte
        		; is PCM track present after attempting to play using STA $2004?
  
  BNE :-
  LDA #$01
  STA TRACKS_AVAILABLE, Y  
  STA TRACKS_ENABLED, Y
  BRA :-
: 
  LDA #$01
  STA MSU_SELECTED
  PLB
  RTL

;org $E2F5F5
; stop_nsf:
;   LDX #$00		; native code
;   LDY #$00		; native code
;   PHA
;   LDA CURRENT_NSF		; load currently playing msu-1 track
;   CMP #$5B		; is it the Title Screen?
;   BNE skip_mute
;   STZ MSU_CONTROL		; mute msu-1 (from title screen)
; skip_mute:
;   PLA
;   RTL

; Checks for MSU track for audio track in Accumulator
msu_check:
  PHB
  PHK
  PLB
  PHY
  PHX
  PHA  

  LDA MSU_SELECTED
  BEQ fall_through


  LDA MSU_ID		; load first byte of msu-1 identification string
  CMP #$53		    ; is it "M" present from "MSU-1" string?
  BNE fall_through  ; No MSU-1 support, fall back to NSF
  
  ; check if we have a track for this value

  PLA
  PHA
      ; CMP NSF_STOP
      ; BEQ stop_msu

      CMP NSF_PAUSE
      BEQ pause_msu

      CMP NSF_RESUME
      BEQ resume_msu
  TAY
  LDA msu_track_lookup, Y
  CMP #$FF
  BEQ fall_through
  
  TAY
  LDA TRACKS_ENABLED, Y
  BEQ fall_back_to_nsf

  PLA
  CMP CURRENT_NSF
  BEQ already_playing
  STA CURRENT_NSF		; store current nsf track-id for later retrieval
  PHA

  TYA

  ; non-FF value means we have an MSU track
  BRA msu_available

fall_back_to_nsf:
  bra stop_msu

stop_msu:
; is msu playing?  if not, just exit
    LDA MSU_PLAYING
    BEQ fall_through
    STZ MSU_CONTROL
    STZ MSU_CURR_CTRL    
    STZ MSU_PLAYING
    BRA fall_through

pause_msu:
    LDA MSU_PLAYING
    BEQ fall_through
    STZ MSU_CONTROL
    STZ MSU_CURR_CTRL
    BRA fall_through

resume_msu:
    LDA MSU_PLAYING
    BEQ fall_through
    LDA MSU_TRACK_IDX
    TAY
    LDA TRACKS_ENABLED, y
    beq fall_through
    LDA msu_track_loops, Y
    STA MSU_CONTROL
    STA MSU_CURR_CTRL

  ; fall through to default
fall_through:
  PLA
  PLX
  PLY
  PLB
  RTL

already_playing:
  PLX
  PLY
  PLB
  LDA NSF_MUTE ; set nsf music to mute since we are playing msu  
  rtl

pause_msu_only:
  PHB
  PHK
  PLB
  PHY
  PHX
  PHA  

  LDA MSU_SELECTED
  BEQ fall_through


  LDA MSU_ID		; load first byte of msu-1 identification string
  CMP #$53		    ; is it "M" present from "MSU-1" string?
  BNE fall_through  ; No MSU-1 support, fall back to NSF
  BRA pause_msu


resume_msu_only:
  PHB
  PHK
  PLB
  PHY
  PHX
  PHA  

  LDA MSU_SELECTED
  BEQ fall_through

  LDA MSU_ID		; load first byte of msu-1 identification string
  CMP #$53		    ; is it "M" present from "MSU-1" string?
  BNE fall_through  ; No MSU-1 support, fall back to NSF
  BRA resume_msu

stop_msu_only:
  PHB
  PHK
  PLB
  PHY
  PHX
  PHA  

  LDA MSU_SELECTED
  BEQ fall_through

  LDA MSU_ID		; load first byte of msu-1 identification string
  CMP #$53		    ; is it "M" present from "MSU-1" string?
  BNE fall_through  ; No MSU-1 support, fall back to NSF
  BRA stop_msu

  ; if msu is present, process msu routine
msu_available:
  TAY
  PLA
  PHY                   ; push the MSU-1 track 
  PHA                   ; repush the NSF track

  LDA #$00		        ; clear disable/enable nsf music flag
  STA MSU_PLAYING		; clear disable/enable nsf music flag

  PLA
  STA CURRENT_NSF		; store current nsf track-id for later retrieval

  LDA #$01
  STA MSU_TRIGGER
  LDA #$02          ; use #$02 for convience so we can ORA with it for "song playing" in DD2 sound engine		       
  STA MSU_PLAYING		; set mute NSF flag (writing 02 in RAM location)

  pla
  STA MSU_TRACK_IDX		; store current re-mapped nsf track-id for later retrieval
  STA MSU_TRACK		    ; store current valid NSF track-ID
  stz MSU_TRACK + 1	    ; must zero out high byte or current msu-1 track will not play !!!

  ; jsl msu_nmi_check
  PLX
  PLY
  PLB
  LDA NSF_MUTE ; set nsf music to mute since we are playing msu  

  RTL

:
  LDA MSU_CURR_VOLUME
  STA MSU_VOLUME
  RTL

msu_nmi_check:

  jsr decrement_timer_if_needed
  
  LDA MSU_TRIGGER
  BEQ :-
  LDA MSU_STATUS
  AND #$40
  BNE :-
  LDA MSU_STATUS

  PHB
  PHK
  PLB
  STZ MSU_TRIGGER

  LDA MSU_TRACK_IDX ; pull the current MSU-1 Track
  TAY
  LDA msu_track_loops, Y
  STA MSU_CONTROL		; write current loop value
  STA MSU_CURR_CTRL
  LDA msu_track_volume, Y
  STA MSU_VOLUME		; write max volume value
  STA MSU_CURR_VOLUME
  
  jsr set_timer_if_needed
  PLB
  RTL


check_if_msu_is_available:
  STZ MSU_AVAILABLE
  LDA MSU_ID
  CMP #$53
  BNE :+
    LDA #$01
    STA MSU_AVAILABLE
  : 
  rtl

  
set_timer_if_needed:  
  PHB
  PHK
  PLB
  LDA $00
  PHA
  LDA $01
  PHA

  LDA MSU_TRACK_IDX
  ASL a
  TAY

  LDA track_timers, Y
  STA $00
  INY 
  LDA track_timers, y
  STA $01
  
  LDY #$00
  LDA ($00),Y
  INY
  ORA ($00),Y
  BEQ :+
    LDA ($00),Y
    STA MSU_TIMER_HB
    DEY
    LDA ($00),Y
    STA MSU_TIMER_LB
    STZ MSU_TIMER_INDX
    INC MSU_TIMER_ON
    
  :

  PLA
  STA $01
  PLA
  STA $00
  PLB
  rts

decrement_timer_if_needed:
  LDA MSU_TIMER_ON
  BEQ :++

  setAXY16
  DEC MSU_TIMER_LB
  setAXY8

  BNE :++

  PHB
  PHK
  PLB

  LDA $00
  PHA
  LDA $01
  PHA

  STZ MSU_TIMER_ON
  LDA $0700
  AND #$FD
  STA $0700
  STZ $0701
  
  INC MSU_TIMER_INDX
  ; LDA #$01
  ; STA $E0
  ; 

  LDA MSU_TRACK_IDX
  ASL
  TAY
  LDA track_timers, Y
  STA $00
  INY 
  LDA track_timers, y
  STA $01

  LDA MSU_TIMER_INDX
  ASL
  INC A
  TAY
  LDA ($00),Y
  beq :+

    STA MSU_TIMER_HB
    DEY
    LDA ($00),Y
    STA MSU_TIMER_LB
    INC MSU_TIMER_ON
  :
  
  PLA
  STA $01
  PLA
  STA $00
  PLB
: 
  rts
; this 0x100 byte lookup table maps the NSF track to the MSU-1 track
; MSU Index	NES Track Id	Track	
; 1	  25	Title	
; 2	  19	USA	
; 3	  15	England	
; 4	  1A	India	
; 5	  16	Iceland	
; 6	  18	China	
; 7	  17	Kenya	
; 8	  14	Japan	
; 9	  1B	USSR	
; A  	1C	Nightmare	
; B 	1F	Intro	
; C 	29	Position Screen	
; D 	1D	Bean Ball	
; E 	1E	Vs.	
; F 	22	Win	
; 10	23	Lost	
; 11	2B	Final Win	
; 12	2C	Credits	
; 13	20	Starting Match

; unused but marked as supported so it shuts off MSU when played


msu_track_lookup:
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $08, $03, $05, $07, $06, $02, $04, $09, $0A, $0D, $0E, $0B
  ; .byte $FF, $FF, $FF, $FF, $08, $03, $05, $07, $06, $02, $04, $09, $0A, $0D, $0E, $FF
.byte $13, $FF, $0F, $10, $FF, $01, $FF, $FF, $FF, $0C, $FF, $11, $12, $FF, $FF, $FF
  ; .byte $FF, $FF, $FF, $FF, $FF, $01, $FF, $FF, $FF, $0C, $FF, $11, $12, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

; this 0x100 byte lookup table maps the NSF track to the if it loops ($03) or no ($01)
msu_track_loops:
.byte $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $01, $01, $03, $03, $01
.byte $01, $01, $03, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

; this 0x100 byte lookup table maps the NSF track to the MSU-1 volume ($FF is max, $4F is half)
.define DV $38
msu_track_volume:
.byte $fF,  DV,  DV,  DV,  DV,  DV,  DV,  DV,  DV,  DV,  DV,  DV,  DV,  DV,  DV,  DV
.byte  DV,  DV,  DV,  DV, $fF, $fF, $fF, $fF, $fF, $4f, $fF, $fF, $fF, $fF, $fF, $fF
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F

track_timers:
.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ;
.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 
.addr flight_screen_jingle_timer            ; 0x0b - Flight screen jingle
.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 
.addr win_timer            ; Win

.addr win_timer            ; Loss
.addr no_timer            ; 
.addr no_timer            ; 
.addr pre_match_timer            ; 0x13 -  Pre-match jingle

no_timer:
.word $0000               ; 

flight_screen_jingle_timer:
.word $015E, $0000

pre_match_timer:
.word $00B0, $0000        ; End of Level         - 0D

win_timer:
.word $016D, $0000