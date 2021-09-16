%include "macros.asm"
[BITS 16]

[ORG 0x7C00]


;	CODE BEGIN
;	
;
jmp start ;setting code segment

start:
mov ax, 0x00
mov ds, ax; setting data segment to zero
mov ss, ax; setting up stack segment
mov sp, 0x7BFF ;setting up stackpointer (just before the loaded bootsector)
mov ax, 0xA000 ;beginning of the framebuffer
mov es, ax; setting the extra segment for pixel drawing purposes

;setting 320x200 256 colors graphics mode
mov ax, 0x0013
int 0x10

;initializing keyboard
call keyboard_check

;activating keyboard
	mov al, 0xF4
	out 0x60, al

;initialize FPU
finit

;main game loop
main_loop:
	CLS

	;drawing stuff
	DRAW_PLAYER1
	DRAW_PLAYER2
	DRAW_BALL

	;updates
	UPDATE_BALL_LOCATION

	;get keyboard input
	in al, 0x60 ;reading current keyboard input

	cmp al, 0x11 ;Key W
	je .player1_input_w
	.player1_input_w_continue:

	cmp al, 0x1F ;Key S
	je .player1_input_s
	.player1_input_s_continue:

	;collisions
	PLAYER1_SCREEN_COLLISION
	PLAYER2_SCREEN_COLLISION

	;ball outside of screen
	mov word ax, [ball_x]
	mov bx, RES_X
	cmp ax, bx
	ja .ball_out_of_screen
	.ball_out_of_screen_continue:

	;player 1 ball collision
	mov cx, 1 
	call player_ball_check ;player 1 paddle collision
	mov cx, 2
	call player_ball_check ;player 2 paddle collision
	
	;waiting for the next frame	to start
	WAIT_FOR_RTC


jmp main_loop

;SCREEN COLLISION IFS
;if player 1 is too low on the screen
.player1_too_low:
mov ax, PLAYER_LOWEST
jmp .player1_too_low_continue

;if player 1 is too high on the screen
.player1_too_high:
mov ax, 1
jmp .player1_too_high_continue

;if player 2 is too low on the screen
.player2_too_low:
mov ax, PLAYER_LOWEST
jmp .player2_too_low_continue

;if player 1 is too high on the screen
.player2_too_high:
mov ax, 1
jmp .player2_too_high_continue

;INPUT IFS
;KEY W
.player1_input_w:
mov word bx, [player1_y]
dec bx
mov word [player1_y], bx
jmp .player1_input_w_continue

;KEY S
.player1_input_s:
mov word bx, [player1_y]
inc bx
mov word [player1_y], bx
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
ball_x dw 100
ball_y dw 100
ball_y_float dd 100.6
ball_dx dw -1
ball_dy_float dd 0.1 ;gradient

.functions:
;checking if keyboard controller is ready
keyboard_check:
pusha
	keyboard_check.loop:
	xor ax,ax
	in al,0x64
	bt ax, 1 ;test if buffer is still full
	jc keyboard_check.loop
popa
ret

;player_ball_collision
;cx=1 player one collision check
;else player two collision check
player_ball_check:
pusha
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
popa
ret

;padding to fill up the bootsector
times 510 - ($-$$) db 0

;bootsector marker
dw 0xAA55

; fill up to make a floppy image
times 1474560 - ($-$$) db 0