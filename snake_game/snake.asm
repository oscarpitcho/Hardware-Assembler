.equ HEAD_X, 0x1000 ; snake head's position on x-axis
.equ HEAD_Y, 0x1004 ; snake head's position on y-axis
.equ TAIL_X, 0x1008 ; snake tail's position on x-axis
.equ TAIL_Y, 0x100C ; snake tail's position on y-axis
.equ SCORE, 0x1010 ; score address
.equ GSA, 0x1014 ; game state array
.equ LEDS, 0x2000 ; LED addresses
.equ SEVEN_SEGS, 0x1198 ; 7-segment display addresses
.equ RANDOM_NUM, 0x2010 ; Random number generator address
.equ BUTTONS, 0x2030 ; Button addresses

; BEGIN:main 
main: 
	addi sp, zero, LEDS
	addi s1, zero, 2; Comparaison value for game end 
	addi s2, zero, 1; Comparaison value for food eaten
	;S0 = state of game: 2 = Over, other = Active
	game:
	call restart_game
	beq s0, s1, game
	call get_input
	call hit_test
	call clear_leds
	call draw_array
	addi s0, v0, 0
	bne v0, s2, dont_increment
	increment_score:
	ldw t1, SCORE(zero)
	addi t1, t1, 1
	stw t1, SCORE(zero)
	call create_food

	dont_increment:

	call move_snake
	br game
	

; END:main
; BEGIN:clear_leds
clear_leds: 
	addi t1, zero, 4
	addi t2, zero, 8
	stw zero, LEDS (zero)
	stw zero, LEDS (t1)
	stw zero, LEDS (t2)
	ret 
; END:clear_leds

; BEGIN:set_pixel
; a0 = x
; a1 = y
set_pixel: 
	;Each led has x index ranging from 0 to 3 (2 lsb of x pos)
	or t1, zero, a0  ;to know which array
	;T1 = array index (0, 4 or 8)
	srli t1, t1, 2 ; Clear two LSB and keep the LED identifier
	slli t1, t1, 2 ; 
	;T0 = Initial value of array
	ldw t0, LEDS (t1)
	andi t2, a0, 3 ;Obtain x in led
	slli t2, t2, 3 ; x*8
	;T2 = bit Number in corresponding Array
	add t2, t2, a1 ; Bitnumber is x*8 + y
	ori t3, zero, 1 ; we create the mask 
	sll t3, t3, t2
	or t0, t0, t3 ; 
	stw t0, LEDS (t1)
	ret 
; END:set_pixel

; BEGIN:get_input 
get_input: 
	;loading EDGECAPTURE into t1  
	addi t0, zero, 4
	ldw t1, BUTTONS(t0)

	; and the previous head direction vector in t5
	;we fetch the previous head position
	ldw t2, HEAD_X(zero)
	ldw t3, HEAD_Y(zero)
	; we do 8x + y to get the correct position in the GSA
	slli t4, t2, 3
	add t4, t4, t3 
	; we get the value from the GSA knowing that it is word alligned thus we need to multiply by 4
	slli t4, t4, 4
	ldw t5, GSA(t4)
	add t2, zero, zero

loop:
    beq t1, zero, end
	addi t2, t2, 1
	srli t1, t1, 1
	jmpi loop

testing:
	add t3, t2, t5
	addi t6, zero, 5
	; testing cases
	beq t2, t5, end ;if equal exit
	beq t6, t3, end ; if equal opposite directions exit

	;store new value in GSA
	stw t2, GSA(t4)
	ret
end:
	ret  
; END:get_input


; BEGIN:move_snake
move_snake:
	;Pushing a0 and ra to pile
	addi sp , sp, -8
	stw ra, 4(sp)
	stw a0, 0(sp)

	;Loading head position from mem
	ldw a0, HEAD_X(zero)
	ldw a1, HEAD_Y(zero)

	;Obtain gsa index in v0
	call gsa_index
 	
	;Getting head cell content
	slli t2, v0, 2
	ldw t1, GSA(t2)

	
	addi a0, t1, 0
	addi a1, v0, 0
	;v0 = new GSA
	call correct_gsa
	
	;Getting back head content
	add t1, a0, zero 
	
	
	;Saving head content to new head pos
	;Word alignment
	slli t2, v0, 2
	stw t1, GSA(t2)

	addi a0, v0, 0
	call array_coordinates

	stw v0, HEAD_X(zero)
	stw v1, HEAD_Y(zero)
	

	;Tail does not move if something is eaten
	ldw a0, 0(sp)
	beq a0, zero, tail
	ldw ra, 4(sp)
	addi sp, sp, 8
	ret
	
	tail:
	;Loading tail position from mem
	ldw a0, TAIL_X(zero)
	ldw a1, TAIL_Y(zero)
	
	call gsa_index

	;Getting tail cell content + reset
	;Word alignment
	slli t2, v0, 2
	ldw t1, GSA(t2)
	stw zero, GSA(t2)

	;a0 = Tail content
	;a1 = Tail Index
	addi a0, t1, 0
	addi a1, v0, 0

	;v0 = new GSA
	call correct_gsa


	;Saving tail content to new head pos
	slli t1, v0, 2;Word alignment
	stw a0, GSA(t1)
	addi a0, v0, 0

	call array_coordinates
	stw v0, TAIL_X(zero)
	stw v1, TAIL_Y(zero)
	
	ldw a0, 0(sp)
	ldw ra, 4(sp)
	addi sp, sp, 8
	ret
; END:move_snake

	
; BEGIN:correct_gsa
;a0 = gsa content
;a1 = gsa index
;v0 = new Gsa
correct_gsa:
	;Storing comparaison value for vector
	addi t4, zero, 1
	addi t5, zero, 2
	addi t6, zero, 3
	addi t7, zero, 4

	;Branching in correct case
	beq a0, t4, gsa_left
	beq a0, t5, gsa_up
	beq a0, t6, gsa_down
	beq a0, t7, gsa_right

	gsa_left:
	addi v0, t2, -8
	ret 
	gsa_right:
	addi v0, t2, 8
	ret
	gsa_up:
	addi v0, t2, -1
	ret 
	gsa_down:
	addi v0, t2, 1
	ret
; END:correct_gsa

; BEGIN:gsa_index
;a0 = x value
;a1 = y value
; v0 = index 
gsa_index:
	slli v0, a0, 3
	add v0, v0, a1
	ret 
; BEGIN:array_coordinates
;a0 = gsa index
;v0 = x
;v1 = y
array_coordinates:
	srli v0, a0, 3
	srli t1, v0, 3
	sub v1, a0, t1
	ret
; END:array_coordinates


; BEGIN:draw_array
draw_array:
	;Pushing ra, a0, a1, s0, s1
	addi sp, sp, -20
	stw ra, 16(sp)
	stw a0, 12(sp)
	stw a1, 8(sp)
	stw s0, 4(sp)
	stw s1, 0(sp)
	;S0 = Cieling value
	;S1 = Current index * 4
	addi s0, zero, 384
	addi s1, zero, 0
	
	;Drawing all 96 cells
	draw_array_loop:
		;Getting cell content
		ldw t1, GSA(s1)
		;Displaying if non-empty
		bne zero, t1,display_pixel
		
		draw_array_bloop:
		addi s1, s1, 4
		;Continue loop if counter is not at 384 ( 96 * 4 )
		bne s1, s0, draw_array_loop
		
		;Popping save values and returning
		ldw s1, 0(sp)
		ldw s0, 4(sp)
		ldw a1, 8(sp)
		ldw a0, 12(sp)
		ldw ra, 16(sp)
		addi sp, sp, 20
		ret

		display_pixel:
		addi a0, s1, 0
		srli a0, a0, 2; Divding by 4 to get index 
		call array_coordinates
		addi a0, v0, 0
		addi a1, v1, 0
		call set_pixel
		jmpi draw_array_bloop
; END:draw_array

; BEGIN:create_food
create_food:
	ldw t1, RANDOM_NUM(zero)
	;Taking the first byte, T1 = food Index
	slli t1, t1, 24
	srli t1, t1, 24
	;Creating comparaison register
	addi t2, zero, 96
	blt t1, t2, check_free_cell
	ret

	check_free_cell:
	; Gsa is word aligned on Bytes hence to access, index must be * 4 
	slli t1, t1, 2
	ldw t3, GSA(t1)
	;Jump if cell is free
	beq t3, zero, put_food
	ret
	put_food:
	;Creating food value register
	addi t4, zero, 5
	stw t4, GSA(t1)
	ret
; END:create_food
	
; BEGIN:hit_test
hit_test:
	;Pushing aguments and return value
	addi sp, sp, -12
	stw a0, 0(sp)
	stw a1, 4(sp)
	stw ra, 8(sp)
	
	;Getting position of head on GSA
	ldw a0, HEAD_X(zero)
	ldw a1, HEAD_Y(zero)
	call gsa_index
	
	;Loading index in a1 and index content in a0
	addi a1, v0, 0
	
	;Word aligned
	slli t1, a1, 2
	ldw a0, GSA(t1)
	
	call correct_gsa
	addi a0, v0, 0
	
	;a0 = next cell Index
	;v0 = next x
	;v1 = next y
	call array_coordinates
	
	;Creating comparaison registers
	addi t1, zero, 12
	addi t2, zero, 7 
	
	;Checking if in bounds
	blt v0, zero, end_game
	blt v1, zero, end_game
	bge v0, t1, end_game
	bge v1, t2, end_game

	;T7 = NEXT CELL CONTENT
	slli t1, a0, 2
	ldw t7, GSA(t1)
	
	;Creating comparaison registers
	addi t1, zero, 1
	addi t2, zero, 2
	addi t3, zero, 3
	addi t4, zero, 4
	addi t5, zero, 5
	
	;Testing collision with self
	beq t7, t1, end_game
	beq t7, t2, end_game
	beq t7, t3, end_game
	beq t7, t4, end_game
	beq t7, t5, food_eaten
	
	;Nothing happened
	ldw a0, 0(sp)
	ldw a1, 4(sp)
	ldw ra, 8(sp)
	addi sp, sp, 12
	addi v0, zero, 0
	ret

	end_game:
	ldw a0, 0(sp)
	ldw a1, 4(sp)
	ldw ra, 8(sp)
	addi sp, sp, 12
	addi v0, zero, 2
	ret

	food_eaten:
	ldw a0, 0(sp)
	ldw a1, 4(sp)
	ldw ra, 8(sp)
	addi sp, sp, 12
	addi v0, zero, 1
	ret
; END:hit_test

; BEGIN:restart_game
restart_game:
;T1 = edge
	ldw t1, BUTTONS + 4(zero)
	slli t1, t1, 27
	srli t1, t1, 31
	bne t1, zero, reset_activated
	addi v0, zero, 0 ;Return value is 0 as nothing has been done
	stw zero, BUTTONS +4(zero)
	ret

	reset_activated:
	stw zero, SCORE(zero); Resetting score

	;Pushing return address
	addi sp, sp, -4
	stw ra, 0(sp)
	
	call clear_gsa 

	;Initial direction of the snake(rightwards)
	addi t1, zero, 4
	
	;Creating a rightwards snake in the top left corner
	stw t1, GSA(zero)
	stw zero, HEAD_X(zero)
	stw zero, HEAD_Y(zero)

	call create_food
	
	;Popping return address + loading return value
	addi v0, zero, 1;Return value is 1 since button was pressed
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret

	
; END:restart_game

; BEGIN:clear_gsa
clear_gsa:
	;t1 = Cieling
	addi t1, zero, 384
	;t2 = counter
	addi t2, zero, 0

	clear_gsa_loop:
	stw zero, GSA(t2)
	addi t2, t2, 4;Increment counter
	bne t2, t1, clear_gsa_loop ;Go back till we reach 384
	ret

; END:clear_gsa

; BEGIN:display_score
display_score:
	ldw t1, SCORE(zero)
	
	;t2 = division counter
	addi t2, zero, 0

	division_10:
	addi t1, t1, -10
	addi t2, t2, 1
	bge t1, zero, division_10

	;T1 = Remainder of division
	;T2 = Quotient
	addi t1, t1, 10
	addi t2, t2, 1

	;Shifting for word alignment
	slli t1, t1, 2
	slli t2, t2, 2

	;Fetching corresponding values in font_data
	ldw t1, font_data(t1)
	ldw t2, font_data(t2)

	;Storing value in Segment registers
	stw zero, SEVEN_SEGS(zero)
	stw zero, SEVEN_SEGS + 4(zero)
	stw t2, SEVEN_SEGS + 8(zero)
	stw t1, SEVEN_SEGS + 12 (zero)
	ret
; END:display_score

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