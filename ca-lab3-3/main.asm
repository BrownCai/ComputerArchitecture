stm8/

	#include "mapping.inc"
	#include "stm8s105k.inc"
	
	segment 'ram1'
data ds.w 1

	segment 'rom'
radar dc.b 	3
			dc.b	6
			dc.b 12
			dc.b 24
			dc.b 48
			dc.b 96
			dc.b 192
			dc.b 96
			dc.b 48
			dc.b 24
			dc.b 12
			dc.b 6
			dc.b 3
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

	mov data, #0
	mov PD_DDR, #$ff
	mov PD_CR1, #$ff
	
	MOV TIM3_CR1,#%00000001 ; TIM3 ON
	MOV TIM3_PSCR,#$06 ; prescaler x128 
	BSET TIM3_EGR,#0 ; force UEV to update prescaler 
	MOV TIM3_IER,#$01 ; TIM3 interrupt on update enabled 
	MOV TIM3_ARRH, #$3d
	MOV TIM3_ARRL, #$09
	
	RIM
infinite_loop.l
	ldw X, data
	ld A, (radar,X)
	ld PD_ODR, A
	jra infinite_loop
	
		interrupt irq_Timer3_OverFlow
irq_Timer3_OverFlow.l
	BRES TIM3_SR1,#0 ; clear flag
	ldw X, data
	incw X
	ldw data, X
	CPW X, #13
	JRNE stop
	ldw X,#0
	ldw data,X
stop.l
	iret
	
		interrupt NonHandledInterrupt
NonHandledInterrupt.l
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
