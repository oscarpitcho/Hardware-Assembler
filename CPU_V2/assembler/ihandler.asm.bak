.equ TIMER, 0x2020
.equ EDGE_CAPTURE, 0x2034
.equ LEDS0, 0x2000
.equ LEDS1, 0x2004
.equ LEDS2, 0x2008
br init

ISR:
addi sp, sp, -20
stw ra, 0 (sp)
stw s0, 4 (sp)
stw t0, 8 (sp)
stw t1, 12 (sp)
stw t2, 16 (sp)


rdctl s0, ipending #Loading pending interrupts


check_irq0:
andi t0, s0, 1 
beq t0, zero, check_irq2
call handle_timer

check_irq2:
andi t0, s0, 4
beq t0, zero, ISR_finish
call handle_buttons

ISR_finish:
ldw ra, 0 (sp)
ldw s0, 4 (sp)
ldw t0, 8 (sp)
ldw t1, 12 (sp)
ldw t2, 16 (sp)
addi sp, sp, 20
addi ea, ea, -4
eret 


init:
addi sp, zero, LEDS0 #Initiating the stack pile
addi t0, zero, 99
stw t0, TIMER + 8(zero) #storing the timer value

#Setting PIE to 1
addi t0, zero, 1 
wrctl status, t0

#Activating interrupts Timer and button
addi t0, zero, 5
wrctl ienable, t0 
addi t0, zero, 7
stw t0, TIMER + 4(zero)


main:

;Incrementing one of the leds registers
ldw t1, LEDS0(zero)
addi t1, t1, 1
stw t1, LEDS0(zero)

br main





handle_buttons: 
ldw t0, EDGE_CAPTURE(zero)
stw zero, EDGE_CAPTURE(zero) #Resetting Edge capture
andi t0, t0, 3 #Filtering
addi t1, zero, 3
beq t0, t1, ISR_finish
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
#Clearing the ipending registers
addi t0, t0, 4
nor t0, t0, t0 #Negating the contents
and t0, s0, t0 #Applying the mask
wrctl ipending, t0
ret


handle_timer:
ldw t1, LEDS1(zero)
addi t1, t1, 1
stw t1, LEDS1(zero)

#Clearing the TO bit
addi t0, t0, 1
nor t0, t0, t0 #Negating the contents
and t1, s0, t0 #Applying the mask

ldw t1, TIMER(zero)
and t1, t0, t1
stw t1, TIMER(zero)

ret


