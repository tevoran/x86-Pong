;macros
;definitions
%define YELLOW 0x0E
%define BLACK 0x00

%define RES_X 320
%define RES_Y 200
%define PLAYER_WIDTH 0x06
%define PLAYER_HEIGHT 0x20
%define PLAYER_LOWEST 168
%define PLAYER_HIGHEST 0xFFFF


;functions
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

%macro PLAYER1_SCREEN_COLLISION 0
	;keeping player 1 inside the screen
	mov word ax, [player1_y]
	;if player is too low on the screen set him a bit higher
	cmp ax, PLAYER_LOWEST
	jae .player1_too_low
	.player1_too_low_continue:

	;if player is too high on the screen set him a bit lower
	cmp ax, 0
	je .player1_too_high
	.player1_too_high_continue:
	mov word [player1_y], ax
%endmacro