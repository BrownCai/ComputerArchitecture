stm8/

	#include "mapping.inc"
	#include "stm8s105k.inc"

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

	mov PD_DDR, #$ff
	mov PD_CR1, #$ff
	clr PD_ODR
	
	mov PC_DDR, #0
	mov PC_CR1, #0
	mov PC_CR2, #$ff
	
	
	mov EXTI_CR1, #$20
	mov EXTI_CR2, #$02
	
	mov TIM2_CR1, #%00000001 ;counter enable on
	mov TIM2_IER, #$00 ;no interrupts are required for PWM
	mov TIM2_CCMR1, #%01100000 ;PWM mode 1+CC1 as output
	mov TIM2_CCER1, #%00000000 ;CC output
	mov TIM2_ARRH, #%00000111
	mov TIM2_ARRL, #%11010000
	mov TIM2_CCR1H, #%00000011
	mov TIM2_CCR1L, #%11101000
	
	mov TIM3_CR1, #%00000000
	mov TIM3_PSCR, #$07 ;prescaler x128
	bset TIM3_EGR, #0 ;force UEV to update prescaler
	mov TIM3_IER, #$00 ;tim3 interrupt on update disable
	
	mov TIM3_ARRH, #%00111101
	mov TIM3_ARRL, #%00001001
	
	rim
	
infinite_loop.l
	mov PD_ODR, #0
	jra infinite_loop



	interrupt NonHandledInterrupt
NonHandledInterrupt.l
	iret

	interrupt Exti2_portC
Exti2_portC.l
	mov TIM3_CR1, #%00000001
	mov TIM3_IER, #$01
	;mov TIM2_CCER1, #%00000000
	bcpl TIM2_CCER1, #0
	iret
	
	interrupt timer3
timer3.l
	mov TIM3_CR1, #%00000000
	;mov TIM2_CCER1, #%00000001
	bcpl TIM2_CCER1, #0
	mov TIM3_IER, #$00
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
	dc.l {$82000000+Exti2_portC}	; irq5
	dc.l {$82000000+NonHandledInterrupt}	; irq6
	dc.l {$82000000+NonHandledInterrupt}	; irq7
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
