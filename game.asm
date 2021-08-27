[BITS 16]

[ORG 0x7C00]

;macros
%define YELLOW 0x0E
%define BLACK 0x00

%define RES_X 320
%define RES_Y 200
%define PLAYER_WIDTH 0x10
%define PLAYER_HEIGHT 0x40

%macro CLS 0
	mov di, 0x00
	mov al, BLACK
	mov cx, 0xFA00
	repe stosb 
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
	mov ax, 0x00
	mov word [i], ax ;reset loop variable
	player_draw_loop:
		;calculating framebuffer offset
		mov ax, RES_X
		mov word bx, [player_y]
		add word bx, [i]
		mul bx
		add word ax, [player_x]
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

	.stop:
	jmp .stop

;jmp main_loop


.data:
i dw 0 ;loop variable
player_x dw 300
player_y dw 0

;padding to fill up the bootsector
times 510 - ($-$$) db 0

;bootsector marker
dw 0xAA55

; fill up to make a floppy image
times 1474560 - ($-$$) db 0