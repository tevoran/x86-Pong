%include "macros.asm"
[BITS 16]

[ORG 0x7C00]


;	CODE BEGIN
;	
;
jmp start ;setting code segment

start:
xor ax, ax
mov ds, ax; setting data segment to zero
mov ss, ax; setting up stack segment
mov sp, 0x7BFF ;setting up stackpointer (just before the loaded bootsector)
mov ax, 0xA000 ;beginning of the framebuffer
mov es, ax; setting the extra segment for pixel drawing purposes

;setting 320x200 256 colors graphics mode
mov ax, 0x0013
int 0x10

;initializing keyboard
;wait until keyboard is ready
keyboard_check.loop:
xor ax,ax
in al,0x64
bt ax, 1 ;test if buffer is still full
jc keyboard_check.loop

;activating keyboard
	mov al, 0xF4
	out 0x60, al

;initialize FPU
finit

;main game loop
main_loop:
	CLS

	;drawing stuff
	mov si, player1_y
	mov dx, word [player1_x]
	call draw_player

	mov si, player2_y
	mov dx, word [player2_x]
	call draw_player

	DRAW_BALL

	;updates
	UPDATE_BALL_LOCATION

	;get keyboard input
	in al, 0x60 ;reading current keyboard input

	xor cx, cx ;resetting player y-speed variable
	cmp al, 0x11 ;Key W
	je .player1_input_w
	.player1_input_w_continue:

	cmp al, 0x1F ;Key S
	je .player1_input_s
	.player1_input_s_continue:

	mov word [player1_dy], cx

	;collisions
	mov si, player1_y
	call player_screen_collision
	mov si, player2_y
	call player_screen_collision


	;ball outside of screen
	;horizontal
	mov word ax, [ball_x]
	mov bx, RES_X
	cmp ax, bx
	ja .ball_out_of_screen
	.ball_out_of_screen_continue:

	;vertical
	mov word ax, [ball_y]
	mov bx, RES_Y
	cmp ax, bx
	jna .ball_out_of_screen_vertical_continue
		call reflect_ball_y
	.ball_out_of_screen_vertical_continue:

	;player ball collision
	mov cx, 1 
	call player_ball_check ;player 1 paddle collision
	mov cx, 2
	call player_ball_check ;player 2 paddle collision
	
	;waiting for the next frame	to start
	WAIT_FOR_RTC


jmp main_loop

;INPUT IFS
;KEY W
.player1_input_w:
mov word bx, [player1_y]
dec bx
mov word [player1_y], bx
mov cx, -1 ;set player y direction
jmp .player1_input_w_continue

;KEY S
.player1_input_s:
mov word bx, [player1_y]
inc bx
mov word [player1_y], bx
mov cx, 1 ;set player y direction
jmp .player1_input_s_continue

;ball collision ifs
;ball out of screen
.ball_out_of_screen:
mov ax, bx
shr ax,1 ;division by two
mov word [ball_x], ax
jmp .ball_out_of_screen_continue


.data:
timer_current dw 0
i dw 0 ;loop variable
player1_x dw 20
player1_y dw 30
player2_x dw 290
player2_y dw 80
player1_dy dw 0
ball_x dw 100
ball_y dw 100
ball_y_float dd 100.6
ball_dx dw -1
ball_dy_float dd 0.25 ;gradient

.functions:
;drawing player
;si=adress of the player paddle's y-position
;dx=player paddle's x-position
draw_player:
	xor ax,ax
	mov word [i], ax ;reset loop variable
	player_draw_loop:
		;calculating framebuffer offset
		mov ax, RES_X
		mov word bx, [si] ;loading y-position
		add word bx, [i]
			push dx ;save dx because the multiplication breaks it
		mul bx
			pop dx
		add ax, dx ;adding player x-position
		mov di, ax ;writing the framebuffer offset for the actual writing purposes
		mov al, YELLOW ;color code within the 256 color palette
		mov cx, PLAYER_WIDTH ;number of repitions in x direction
		repe stosb ;write the line of player paddle

	;incrementing loop counting variable
	mov word ax, [i] ;reading loop variable
	inc ax ;incrementing loop variable
	mov word [i], ax ;writing loop variable
	cmp ax, PLAYER_HEIGHT ;check if loop counter is smaller than PLAYER_HEIGHT
	jl player_draw_loop	;jump if less
ret

;player screen collision
;si=address of the player1/2 y-value
player_screen_collision:
	;keeping player 1 inside the screen
	mov word ax, [si]
	;if player is too low on the screen set him a bit higher
	cmp ax, PLAYER_LOWEST
	jae .player_screen_collision_too_low
	.player_screen_collision_too_low_continue:

	;if player is too high on the screen set him a bit lower
	cmp ax, 0
	je .player_screen_collision_too_high
	.player_screen_collision_too_high_continue:
	mov word [si], ax
ret

;if player is too low on the screen
.player_screen_collision_too_low:
mov ax, PLAYER_LOWEST
jmp .player_screen_collision_too_low_continue

;if player is too high on the screen
.player_screen_collision_too_high:
mov ax, 1
jmp .player_screen_collision_too_high_continue


;player_ball_collision
;cx=1 player one collision check
;else player two collision check
player_ball_check:
mov word ax, [ball_x]
cmp cx, 1
	cmove word bx, [player1_x]
	cmovne word bx, [player2_x]
add bx, PLAYER_WIDTH_HALF
cmp ax, bx
jne .player_y_ball_check_continue
	;check if ball is below the top edge of the paddle
	mov word ax, [ball_y]
	cmp cx, 1
		cmove word bx, [player1_y]
		cmovne word bx, [player2_y]
	cmp ax, bx
	jl .player_y_ball_check_continue

	;check if ball is above the bottom edge of the paddle
	add bx, PLAYER_HEIGHT
	cmp ax, bx
	jae .player_y_ball_check_continue

		;reflect ball
		mov word ax, [ball_dx]
		mov bx, -1
		mul bx
		mov word [ball_dx], ax

.player_y_ball_check_continue:
ret

reflect_ball_y:
fwait
	fld dword [ball_dy_float]
	fchs ;change sign
	fst dword [ball_dy_float]
ret

;padding to fill up the bootsector
times 510 - ($-$$) db 0

;bootsector marker
dw 0xAA55

; fill up to make a floppy image
times 1474560 - ($-$$) db 0