.equ TIMER, 0x2020
.equ BUTTONS, 0x2030
.equ EDGE_CAPTURE, 0x2034
.equ LEDS0, 0x2000
.equ LEDS1, 0x2004
.equ LEDS2, 0x2008
.equ PULSE_WIDHT, 0x200C

init:
addi sp, zero, LEDS0 #Initiating the stack pile
addi ienable 

main:


;Incrementing one of the leds registers
ldw t1, LEDS0(zero)
addi t1, t1, 1
stw t1, LEDS0(zero)

br main



ISR:
addi sp, sp, -24
stw ra, 0 (sp)
stw s0, 4 (sp)
stw s1, 8 (sp)
stw t0, 12 (sp)
stw t1, 16 (sp)
stw t2, 20 (sp)

addi s0, ipending, 0 #Loading pending interrupts
addi s1, ienable, 0 #Loading enabled interrupts


check_irq0:
andi t0, s0, 1 
and t0, t0, s1 #Equal to 1 iff irq0 pending and enabled
beq t0, zero, check_irq2
call handle_timer

check_irq2:
andi t0, s0, 4
andi t0, t0, s1 #Equal to 4 iff irq2 pending and enabled (0 otherwise)
beq t0, zero, ISR_finish
call handle_buttons


ISR_finish:

#Clearing the ipending registers
addi t0, t0, 5
xor t0, t0, -1 
and ipending, ipending, t0

ldw ra, 0 (sp)
ldw s0, 4 (sp)
ldw s1, 8 (sp)
stw t0, 12 (sp)
stw t1, 16 (sp)
stw t2, 20 (sp)
addi sp, sp, 24
ret 


handle_buttons: 
ldw t0, EDGE_CAPTURE(zero)
stw zero, EDGE_CAPTURE(zero) #Resetting Edge capture
andi t2, t0, 1 #Equal to 1 if first button is pressed
beq t2, zero, check_second_button

handle_first_button: #First button pressed, 3rd counter incremented
ldw t1, LEDS2(zero)
addi t1, t1, 1
stw t1, LEDS2(zero)
br handle_buttons_end


check_second_button:
srli t2, t0, 1 #Shifting right by 1 to check for second button
andi t2, t2, 1 #Equal to 1 if second button is pressed
beq t2, zero, handle_buttons_end

handle_second_button:#Second button pressed, 3rd counter decremented
ldw t1, LEDS2(zero)
addi t1, t1, -1
stw t1, LEDS2(zero)
br handle_buttons_end

handle_buttons_end:
ret


handle_timer:
ldw t1, LEDS1(zero)
addi t1, t1, 1
stw t1, LEDS1(zero)
ret


font_data:
.word 0xFC ; 0
.word 0x60 ; 1
.word 0xDA ; 2
.word 0xF2 ; 3
.word 0x66 ; 4
.word 0xB6 ; 5
.word 0xBE ; 6
.word 0xE0 ; 7
.word 0xFE ; 8
.word 0xF6 ; 9

