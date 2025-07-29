stm8/

	#include "mapping.inc"
	#include "stm8s105k.inc"
	
	segment 'ram1'
count ds.b 1
	
	segment 'rom'
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
	mov TIM2_CR1, #%00000001
	mov TIM2_IER, #$00
	mov TIM2_PSCR, #$05
	bset TIM2_EGR, #0
	mov TIM2_CCMR1, #%01100000
	mov TIM2_CCER1, #%00000001
	mov TIM2_ARRH, #$02
	mov TIM2_ARRL, #$71
	mov TIM2_CCR1H, #$00
	mov TIM2_CCR1L, #$7D
	
	mov TIM3_CR1, #%00000001
	mov TIM3_PSCR, #$07
	bset TIM3_EGR, #0
	mov TIM3_IER, #01
	mov TIM3_ARRH, #$7A
	mov TIM3_ARRL, #$12
	
	mov PD_ODR, #0
	mov PD_DDR, #$ff
	mov PD_CR1, #$ff
	
	
	mov PE_DDR, #0
	mov PE_CR1, #$ff
	mov PE_CR2, #$ff
	
	mov EXTI_CR2, #1
	rim

infinite_loop.l
	
	jra infinite_loop

	interrupt NonHandledInterrupt
NonHandledInterrupt.l
	iret
	

	
	interrupt portE
portE
	ld a, count
	cp a, #2
	jrne change
	inc a
	ld count, a
	mov TIM2_CCR1H, #$00
	mov TIM2_CCR1L, #$7D
	jp final
change
	dec a
	ld count, a
	mov TIM2_CCR1H, #$01
	mov TIM2_CCR1L, #$F4
final
	iret
	
	interrupt timer3
timer3
	bres TIM3_SR1, #0
	ld a, count
	cp a, #0
	jrne change2
	inc a
	ld count, a
	mov TIM2_CCR1H, #$00
	mov TIM2_CCR1L, #$7D
	jp final2
change2
	dec a
	ld count, a
	mov TIM2_CCR1H, #$01
	mov TIM2_CCR1L, #$F4
final2
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
	dc.l {$82000000+portE}	; irq7
	dc.l {$82000000+NonHandledInterrupt}	; irq8
	dc.l {$82000000+NonHandledInterrupt}	; irq9
	dc.l {$82000000+NonHandledInterrupt}	; irq10
	dc.l {$82000000+NonHandledInterrupt}	; irq11
	dc.l {$82000000+NonHandledInterrupt}	; irq12
	dc.l {$82000000+NonHandledInterrupt}	; irq13
	dc.l {$82000000+NonHandledInterrupt}	; irq14
	dc.l {$82000000+timer3}	; irq15
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
