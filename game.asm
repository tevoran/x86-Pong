[BITS 16]

[ORG 0x7C00]

;macros
%define YELLOW 0x0E
%define BLACK 0x00

%define RES_X 320
%define RES_Y 200
%define PLAYER_WIDTH 0x06
%define PLAYER_HEIGHT 0x20

%macro CLS 0
	mov di, 0x00
	mov al, BLACK
	mov cx, 0xFA00
	repe stosb 
%endmacro 

%macro DRAW_PLAYER1 0
	mov ax, 0x00
	mov word [i], ax ;reset loop variable
	player1_draw_loop:
		;calculating framebuffer offset
		mov ax, RES_X
		mov word bx, [player1_y]
		add word bx, [i]
		mul bx
		add word ax, [player1_x]
		mov di, ax ;writing the framebuffer offset for the actual writing purposes
		mov al, YELLOW ;color code within the 256 color palette
		mov cx, PLAYER_WIDTH ;number of repitions in x direction
		repe stosb ;write the line of player paddle

	;incrementing loop counting variable
	mov word ax, [i] ;reading loop variable
	inc ax ;incrementing loop variable
	mov word [i], ax ;writing loop variable
	cmp ax, PLAYER_HEIGHT ;check if loop counter is smaller than PLAYER_HEIGHT
	jl player1_draw_loop	;jump if less
%endmacro

%macro DRAW_PLAYER2 0
	mov ax, 0x00
	mov word [i], ax ;reset loop variable
	player2_draw_loop:
		;calculating framebuffer offset
		mov ax, RES_X
		mov word bx, [player2_y]
		add word bx, [i]
		mul bx
		add word ax, [player2_x]
		mov di, ax ;writing the framebuffer offset for the actual writing purposes
		mov al, YELLOW ;color code within the 256 color palette
		mov cx, PLAYER_WIDTH ;number of repitions in x direction
		repe stosb ;write the line of player paddle

	;incrementing loop counting variable
	mov word ax, [i] ;reading loop variable
	inc ax ;incrementing loop variable
	mov word [i], ax ;writing loop variable
	cmp ax, PLAYER_HEIGHT ;check if loop counter is smaller than PLAYER_HEIGHT
	jl player2_draw_loop	;jump if less
%endmacro

%macro WAIT_FOR_RTC 0
	;synchronizing game to real time clock (18.2 ticks per sec)
	.sync:
		mov ah, 0x00
		int 0x1a ;returns the current tick count in dx
		cmp word [timer_current], dx
	je .sync ;reloop until new tick
		mov word [timer_current], dx ;save new tick value
%endmacro
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


	mov word ax, [player1_y]
	inc ax 
	mov word [player1_y], ax
	
	;waiting for the next frame	to start
	WAIT_FOR_RTC
jmp main_loop


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