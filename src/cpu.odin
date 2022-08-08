package main


//= Imports
import "core:fmt"

//= Structures

//= Procedures
// TODO: Keybindings to step through instructions

init_cpu :: proc() {
	program.halt  = false
	//* CPU
	program.regA  = 0x00
	program.regF  = 0x00
	program.regX  = 0x00
	program.regY  = 0x00
	program.regLP = 0x0000
	program.regPC = 0x0000
	program.regSP = 0xFEFF
}

run_cpu :: proc() -> u8 {
	opcode : u8 = program.memory[program.regPC]
	cycle  : u8 = 0

	fmt.printf("%X:%X", program.regPC, opcode)

	switch opcode {
		//?  NOP
		case 0x00:
			fmt.printf("\t\t- NOP")
			cycle = 1
			break

		//? LD
		case 0x10: // LD a,0
			fmt.printf("\t\t- LDZ")
			program.regA = 0x00
			cycle = 2
			break
		case 0x11: // LD a,x
			fmt.printf("\t\t- LD A,X")
			var := program.regX
			program.regA = var
			cycle = 2
			break
		case 0x12: // LD a,y
			fmt.printf("\t\t- LD A,Y")
			var := program.regX
			program.regA = var
			cycle = 2
			break

		case 0x20: // LD a,i8
			inc_pc()
			var := program.memory[program.regPC]
			fmt.printf(" %X\t\t- LD A,$%X",var,var)
			program.regA = var
			cycle = 3
			break
		case 0x21: // LD x,i8
			inc_pc()
			var := program.memory[program.regPC]
			fmt.printf(" %X\t\t- LD X,$%X",var,var)
			program.regX = var
			cycle = 3
			break
		case 0x22: // LD y,i8
			inc_pc()
			var := program.memory[program.regPC]
			fmt.printf(" %X\t\t- LD Y,$%X",var,var)
			program.regY = var
			cycle = 3
			break

		case 0x30: // LD a,m8
			inc_pc()
			var : u16 = u16(program.memory[program.regPC])
			inc_pc()
			var += (u16(program.memory[program.regPC]) << 8)
			fmt.printf(" %X\t- LD A,[$%X]",var,var)
			program.regA = program.memory[var]
			cycle = 4
			break
		case 0x31: // LD x,m8
			inc_pc()
			var : u16 = u16(program.memory[program.regPC])
			inc_pc()
			var += (u16(program.memory[program.regPC]) << 8)
			fmt.printf(" %X\t- LD X,[$%X]",var,var)
			program.regX = program.memory[var]
			cycle = 4
			break
		case 0x32: // LD y,m8
			inc_pc()
			var : u16 = u16(program.memory[program.regPC])
			inc_pc()
			var += (u16(program.memory[program.regPC]) << 8)
			fmt.printf(" %X\t- LD Y,[$%X]",var,var)
			program.regY = program.memory[var]
			cycle = 4
			break

		case 0x40: // LD m8,a
			inc_pc()
			var : u16 = u16(program.memory[program.regPC])
			inc_pc()
			var += (u16(program.memory[program.regPC]) << 8)
			fmt.printf(" %X\t- LD [$%X],A",var,var)
			program.memory[var] = program.regA
			cycle = 4
			break
		case 0x41: // LD m8,x
			inc_pc()
			var : u16 = u16(program.memory[program.regPC])
			inc_pc()
			var += (u16(program.memory[program.regPC]) << 8)
			fmt.printf(" %X\t- LD [$%X],X",var,var)
			program.memory[var] = program.regX
			cycle = 4
			break
		case 0x42: // LD m8,y
			inc_pc()
			var : u16 = u16(program.memory[program.regPC])
			inc_pc()
			var += (u16(program.memory[program.regPC]) << 8)
			fmt.printf(" %X\t- LD [$%X],Y",var,var)
			program.memory[var] = program.regY
			cycle = 4
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

	fmt.printf("\n")
	inc_pc()

	return cycle
}

inc_pc :: proc() {
	if program.regPC > 0xFFFE do program.halt = true
	else do program.regPC += 1
}