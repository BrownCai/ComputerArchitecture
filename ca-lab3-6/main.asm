stm8/

	#include "mapping.inc"
	#include "stm8s105k.inc"
	
	segment 'ram1'
count ds.w 1

	segment 'rom'
song dc.b 2
		 dc.b 3
		 dc.b 4
		 dc.b 2
		 dc.b 4
		 dc.b 5
		 dc.b 6
		 dc.b 6
pitch dc.w $08e1
			dc.w $07e8
			dc.w $0776
			dc.w $06a6
			dc.w $05ec
			dc.w $0597
			dc.w $04fc
			dc.w $0470
			
main.l
	; initialize SP
	ldw X,#stack_end
	ldw SP,X
	#ifdef RAM0	
	; clear RAM0
ram0_start.b EQU $ram0_segment_start

ram0_end.b EQU $ram0_segment_end
	ldw X,#ram0_start
clear_ram0.l
	clr (X)
	incw X
	cpw X,#ram0_end	
	jrule clear_ram0
	#endif


	#ifdef RAM1
	; clear RAM1
ram1_start.w EQU $ram1_segment_start
ram1_end.w EQU $ram1_segment_end	
	ldw X,#ram1_start
clear_ram1.l
	clr (X)
	incw X
	cpw X,#ram1_end	
	jrule clear_ram1
	#endif

	; clear stack
stack_start.w EQU $stack_segment_start
stack_end.w EQU $stack_segment_end
	ldw X,#stack_start
clear_stack.l
	clr (X)
	incw X
	cpw X,#stack_end	
	jrule clear_stack
	
	mov TIM2_CR1,#%00000001 ; counter enable ON 
	mov TIM2_IER,#$00 ; no interrupts are required for PWM 
	mov TIM2_CCMR1,#%01100000 ; PWM mode 1 + CC1 as output 
	mov TIM2_CCER1,#%00000001 ; CC1 output enabled
	
	mov TIM3_CR1,#%00000001 ; TIM3 ON
	mov TIM3_PSCR,#$07 ; prescaler x128 
	bset TIM3_EGR,#0 ; force UEV to update prescaler 
	mov TIM3_IER,#$01 ; TIM3 interrupt on update enabled 
	mov TIM3_ARRH, #$1e
	mov TIM3_ARRL, #$85	rim
infinite_loop.l

	jra infinite_loop
	


	
		interrupt NonHandledInterrupt
NonHandledInterrupt.l
	iret
	
	interrupt isr_tim3
isr_tim3
	clrw X;or X will be 0x80 when interrupt start
  ldw Y, count
	ld A,(song,Y)
	dec A
	sll A
	ld XL, A
	ld A,(pitch,X)
	ld TIM2_ARRH, A
	ld YH, A
	incw X
	ld A,(pitch,X)
	ld TIM2_ARRL, A
	ld YL, A
  srlw Y
	ld A, YL
	ld TIM2_CCR1L, A
	ld A, YH
	ld TIM2_CCR1H, A
	;inc count no!if inc count then Y and count will be 0x100
	ldw Y, count
	incw Y;Y will be 0x01
	;ldw count, Y;not here
	cpw Y, #8
	;why not #7 but #8??? if #7 the last '6' will not play
	;because I incw Y after play a note
	;so after the last note Y will be #8
	;but if I add tim2&3 off line
	;it needs to be #9 otherwise the last '6' will not play
	jrne final
	;mov TIM3_CR1,#%00000000;timer3 off
	;mov TIM2_CR1,#%00000000;timer2 off
  clrw X
	ldw count, X;if no clear count there will be other noise
final
  ldw count, Y
  bres TIM3_SR1,#0 
	iret

	segment 'vectit'
	dc.l {$82000000+main}									; reset
	dc.l {$82000000+NonHandledInterrupt}	; trap
	dc.l {$82000000+NonHandledInterrupt}	; irq0
	dc.l {$82000000+NonHandledInterrupt}	; irq1
	dc.l {$82000000+NonHandledInterrupt}	; irq2
	dc.l {$82000000+NonHandledInterrupt}	; irq3
	dc.l {$82000000+NonHandledInterrupt}	; irq4
	dc.l {$82000000+NonHandledInterrupt}	; irq5
	dc.l {$82000000+NonHandledInterrupt}	; irq6
	dc.l {$82000000+NonHandledInterrupt}	; irq7
	dc.l {$82000000+NonHandledInterrupt}	; irq8
	dc.l {$82000000+NonHandledInterrupt}	; irq9
	dc.l {$82000000+NonHandledInterrupt}	; irq10
	dc.l {$82000000+NonHandledInterrupt}	; irq11
	dc.l {$82000000+NonHandledInterrupt}	; irq12
	dc.l {$82000000+NonHandledInterrupt}	; irq13
	dc.l {$82000000+NonHandledInterrupt}	; irq14
	dc.l {$82000000+isr_tim3}	; irq15
	dc.l {$82000000+NonHandledInterrupt}	; irq16
	dc.l {$82000000+NonHandledInterrupt}	; irq17
	dc.l {$82000000+NonHandledInterrupt}	; irq18
	dc.l {$82000000+NonHandledInterrupt}	; irq19
	dc.l {$82000000+NonHandledInterrupt}	; irq20
	dc.l {$82000000+NonHandledInterrupt}	; irq21
	dc.l {$82000000+NonHandledInterrupt}	; irq22
	dc.l {$82000000+NonHandledInterrupt}	; irq23
	dc.l {$82000000+NonHandledInterrupt}	; irq24
	dc.l {$82000000+NonHandledInterrupt}	; irq25
	dc.l {$82000000+NonHandledInterrupt}	; irq26
	dc.l {$82000000+NonHandledInterrupt}	; irq27
	dc.l {$82000000+NonHandledInterrupt}	; irq28
	dc.l {$82000000+NonHandledInterrupt}	; irq29

	end
