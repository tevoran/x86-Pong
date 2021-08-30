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

;main game loop
main_loop:
	CLS

	;drawing the players
	DRAW_PLAYER1
	DRAW_PLAYER2


	;get keyboard input
	mov ah,0x00
	int 16h

	cmp ah, 0x11 ;Key W
	je .player1_input_w
	.player1_input_w_continue:

	cmp ah, 0x1F ;Key S
	je .player1_input_s
	.player1_input_s_continue:

	PLAYER1_SCREEN_COLLISION
	
	;waiting for the next frame	to start
	WAIT_FOR_RTC
jmp main_loop

;SCREEN COLLISION IFS
.player1_too_low:
mov ax, PLAYER_LOWEST
jmp .player1_too_low_continue

.player1_too_high:
mov ax, 1
jmp .player1_too_high_continue

;INPUT IFS
.player1_input_w:
mov word bx, [player1_y]
dec bx
mov word [player1_y], bx
jmp .player1_input_w_continue

.player1_input_s:
mov word bx, [player1_y]
inc bx
mov word [player1_y], bx
jmp .player1_input_s_continue

.data:
timer_current dw 0
i dw 0 ;loop variable
player1_x dw 20
player1_y dw 30
player2_x dw 290
player2_y dw 60

;padding to fill up the bootsector
times 510 - ($-$$) db 0

;bootsector marker
dw 0xAA55

; fill up to make a floppy image
times 1474560 - ($-$$) db 0