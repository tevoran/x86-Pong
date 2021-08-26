[BITS 16]

org 0x7C00
start:

mov ah, 0x0E
mov al, 'L'
mov bx, 0x0 
int 0x10

;padding to fill up the bootsector
times 510 - ($-$$) db 0

;bootsector marker
dw 0xAA55

; fill up to make a floppy image
times 1474560 - ($-$$) db 0