[BITS 16]

org 0x7C00
start:


times 510 - ($-$$) db 0

dw 0xAA55

; fill up to make a floppy image
times 1474560 - ($-$$) db 0