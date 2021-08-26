%define YELLOW 0x0E
%define BLACK 0x00

%macro CLS 0
	mov di, 0x00
	mov al, YELLOW
	mov cx, 0xFA00
	repe stosb 
%endmacro  
[BITS 16]

[ORG 0x7C00]
jmp start ;setting code segment

start:
mov ax, 0x00
mov ds, ax; setting data segment to zero
mov ax, 0xA000
mov es, ax; setting the extra segment for pixel drawing purposes

;setting 320x200 256 colors graphics mode
mov ax, 0x0013
int 0x10

CLS

;drawing shit
mov al, YELLOW
mov di, 0x20
mov byte [di], al

;padding to fill up the bootsector
times 510 - ($-$$) db 0

;bootsector marker
dw 0xAA55

; fill up to make a floppy image
times 1474560 - ($-$$) db 0