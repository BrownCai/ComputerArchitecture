stm8/

	#include "mapping.inc"
	#include "stm8s105k.inc"
	
	segment 'ram1'
data1 ds.w 1
count ds.w 1
state ds.b 1

	segment 'rom'
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
	
	mov count, #0
	MOV TIM2_CR1,#%00000001 ; counter enable ON 
	MOV TIM2_IER,#$00 ; no interrupts are required for PWM 
	MOV TIM2_CCMR1,#%01100000 ; PWM mode 1 + CC1 as output 
	MOV TIM2_CCER1,#%00000001 ; CC1 output enabled
	
	MOV TIM3_CR1,#%00000001 ; TIM3 ON
	MOV TIM3_PSCR,#$06 ; prescaler x128 
	BSET TIM3_EGR,#0 ; force UEV to update prescaler 
	MOV TIM3_IER,#$01 ; TIM3 interrupt on update enabled 
	MOV TIM3_ARRH, #$3d
	MOV TIM3_ARRL, #$09
	
	mov state, #0	RIM
infinite_loop.l

	jra infinite_loop
	
config
	ldw X,count
	ld A, (pitch,X)
	ld TIM2_ARRH, A
	ld YH, A
	incw X
	ld A, (pitch,X)
	ld TIM2_ARRL, A
	ld YL, A
	SRLW Y
	ld A, YL
	ld TIM2_CCR1L, A
	ld A, YH
	ld TIM2_CCR1H, A
	ret


	
		interrupt NonHandledInterrupt
NonHandledInterrupt.l
	iret
	
	interrupt irq_Timer3_OverFlow
irq_Timer3_OverFlow.l
	call config
	ld A, state
	cp A, #0
	jreq up
	ldw X, count
	cpw X, #0
	jreq change_to_up
	decw X
	decw X
	jp final
change_to_up
	mov state, #0
	jp final
	
	
up
	ldw X, count
	cpw X, #14
	jreq change_to_down 
	incw X
	incw X
	jp final
change_to_down 
	mov state, #1
final	
	ldw count, X
	BRES TIM3_SR1,#0 ; clear flag
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
	dc.l {$82000000+irq_Timer3_OverFlow}	; irq15
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
