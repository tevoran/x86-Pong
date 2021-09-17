;macros
;definitions
%define YELLOW 0x0E
%define BLACK 0x00

%define RES_X 320
%define RES_Y 200
%define PLAYER1_X 20
%define PLAYER2_X 290 
%define PLAYER_WIDTH 0x06
%define PLAYER_WIDTH_HALF 0x03
%define PLAYER_HEIGHT 0x20
%define PLAYER_LOWEST 168
%define PLAYER_HIGHEST 0xFFFF
%define BALL_WIDTH 3
%define BALL_HEIGHT 3
%define BALL_Y_RESOLUTION 10


;functions
%macro CLS 0
	xor di,di
	mov al, BLACK
	mov cx, 0xFA00 ;framebuffer size
	repe stosb 
%endmacro 

%macro DRAW_BALL 0
	xor ax,ax
	mov word [i], ax
	ball_draw_loop:
		mov word ax, RES_X
		mov word bx, [ball_y]
		add word bx, [i]
		mul bx
		add word ax, [ball_x]
		mov di, ax
		mov al, YELLOW
		mov cx, BALL_WIDTH
		repe stosb

	mov word ax, [i]
	inc ax 
	mov word [i], ax
	cmp ax, BALL_HEIGHT
	jl ball_draw_loop
%endmacro

%macro UPDATE_BALL_LOCATION 0
	;X - axis
	mov word ax, [ball_x]
	add word ax, [ball_dx]
	mov word [ball_x], ax

	;Y - axis
	fwait
		fld dword [ball_y_float] ;load current ball y-value
		fadd dword [ball_dy_float] ;add delta value
		fst dword [ball_y_float] ;save new ball y-value
		fld dword [ball_y_float] ;load ball y-value again
		fistp word [ball_y] ;convert ball y-value to integer and save it into memory

%endmacro

%macro WAIT_FOR_RTC 0
	;synchronizing game to real time clock (18.2 ticks per sec)
	.sync:
		xor ah,ah
		int 0x1a ;returns the current tick count in dx
		cmp word [timer_current], dx
	je .sync ;reloop until new tick
		mov word [timer_current], dx ;save new tick value
%endmacro