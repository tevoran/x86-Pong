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


;main game loop
main_loop:
	CLS

	;drawing the players
	DRAW_PLAYER1
	DRAW_PLAYER2


	;get keyboard input
	in al, 0x60

	cmp al, 0x11 ;Key W
	je .player1_input_w
	.player1_input_w_continue:

	cmp al, 0x1F ;Key S
	je .player1_input_s
	.player1_input_s_continue:

	cmp al, 0x48 ;Key ARROW UP
	je .player2_input_up
	.player2_input_up_continue:

	cmp al, 0x50 ;Key ARROW DOWN
	je .player2_input_down
	.player2_input_down_continue:

	PLAYER1_SCREEN_COLLISION
	PLAYER2_SCREEN_COLLISION
	
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

;KEY ARROW UP
.player2_input_up:
mov word bx, [player2_y]
dec bx
mov word [player2_y], bx
jmp .player2_input_up_continue

;KEY ARROW DOWN
.player2_input_down:
mov word bx, [player2_y]
inc bx
mov word [player2_y], bx
jmp .player2_input_down_continue
.data:
timer_current dw 0
i dw 0 ;loop variable
player1_x dw 20
player1_y dw 30
player2_x dw 290
player2_y dw 60

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

;padding to fill up the bootsector
times 510 - ($-$$) db 0

;bootsector marker
dw 0xAA55

; fill up to make a floppy image
times 1474560 - ($-$$) db 0