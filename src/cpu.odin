package main


//= Imports
import "core:fmt"

//= Structures

//= Procedures

init_cpu :: proc() {
	program.halt  = false
	//* CPU
	program.regA  = 0x00
	program.regF  = 0x00
	program.regXY = 0x0000
	program.regLP = 0x0000
	program.regPC = 0x0000
	program.regSP = 0xFEFF //! May not actually be stack?
}

run_cpu :: proc() {
	opcode : u8 = program.memory[program.regPC]

	fmt.printf("%X:%X - \n", program.regPC, opcode)

	switch opcode {
		//?  NOP
		case 0x00:
			break

		//? LD
		case 0x10: // LD a,0
			program.regA = 0x00
			break
		case 0x11: // LD a,x
			var : u8 = u8(program.regXY >> 8)
			program.regA = var
			break
		case 0x12: // LD a,y
			break

		case 0x20: // LD a,i8
			break
		case 0x21: // LD x,i8
			break
		case 0x22: // LD y,i8
			break

		case 0x30: // LD a,m8
			break
		case 0x31: // LD x,m8
			break
		case 0x32: // LD y,m8
			break

		case 0x40: // LD m8,a
			break
		case 0x41: // LD m8,x
			break
		case 0x42: // LD m8,y
			break

		case 0x50: // LD a,[LP]
			break
		case 0x51: // LD x,[LP]
			break
		case 0x52: // LD y,[LP]
			break

		case 0x60: // LD [LP],a
			break
		case 0x61: // LD [LP],x
			break
		case 0x62: // LD [LP],y
			break
	}
	inc_pc()
}

inc_pc :: proc() {
	if program.regPC > 0xFFFE do program.halt = true
	else do program.regPC += 1
}