ASM=nasm
ASM_SRC=game.asm
ASM_FLAGS=-f bin -o game.img
EMU=qemu-system-x86_64
EMU_FLAGS=-fda game.img

game: game.asm

	$(ASM) $(ASM_SRC) $(ASM_FLAGS)

run:
	$(EMU) $(EMU_FLAGS)