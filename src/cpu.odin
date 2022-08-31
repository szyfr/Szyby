package main


//= Imports
import "core:fmt"


//= Procedures
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

	if DEBUG do fmt.printf("%4X:%2X", program.regPC, opcode)

	switch opcode {
		//? NOP
		case 0x00:
			if DEBUG do fmt.printf("\t\t- NOP\n")
			cycle = 1
			inc_pc()
		//? HALT
		case 0x01:
			if DEBUG do fmt.printf("\t\t- HALT\n")
			program.halt = true
			cycle = 1
			inc_pc()
		//? CALL & RET
		case 0x50: // RET
			full, lower, upper := pop()
			program.regPC = full

			if DEBUG do fmt.printf(" \t- RET\t\t\t| RET $%4X\n", full)
			cycle = 4
		case 0x51: // CALL i16
			addr, lower, upper := grab_immediate_u16()

			inc_pc()
			push(program.regPC)

			program.regPC = addr

			if DEBUG do fmt.printf(" %2X %2X\t- CALL i16\t\t| CALL $%4X\n", lower, upper, program.regPC)
			cycle = 4
			inc_pc()
		//? LD
		case 0x10: // LDZ
			program.regA = 0x00

			if DEBUG do fmt.printf("\t\t- LDZ\t\t\t| LD A,$00\n")
			cycle = 2
			inc_pc()
		case 0x11: // LD a,x
			program.regA = program.regX

			if DEBUG do fmt.printf("\t\t- LD A,X\t\t| LD A,$%2X\n", program.regX)
			cycle = 2
			inc_pc()
		case 0x12: // LD a,y
			program.regA = program.regY

			if DEBUG do fmt.printf("\t\t- LD A,Y\t\t| LD A,$%2X\n", program.regY)
			cycle = 2
			inc_pc()
		case 0x20: // LD a,i8
			program.regA = grab_immediate_u8()

			if DEBUG do fmt.printf(" %2X\t- LD A,i8\t\t| LD A,$%2X\n", program.memory[program.regPC], program.memory[program.regPC])
			cycle = 3
			inc_pc()
		case 0x21: // LD x,a
			program.regX = program.regA

			if DEBUG do fmt.printf("\t\t- LD X,A\t\t| LD X,$%2X\n", program.regA)
			cycle = 2
			inc_pc()
		case 0x22: // LD y,a
			program.regY = program.regA

			if DEBUG do fmt.printf("\t\t- LD Y,A\t\t| LD Y,$%2X\n", program.regA)
			cycle = 2
			inc_pc()
		case 0x30: // LD a,m8
			full, lower, upper := grab_immediate_u16()
			program.regA        = program.memory[full]
			
			if DEBUG do fmt.printf(" %2X %2X\t- LD A,m8\t\t| LD A,[$%4X]\n", lower, upper, full)
			cycle = 4
			inc_pc()
		case 0x31: // LD m8,a
			full, lower, upper   := grab_immediate_u16()
			program.memory[full]  = program.regA
			
			if DEBUG do fmt.printf(" %2X %2X\t- LD m8,A\t\t| LD [$%4X],$%2X\n", lower, upper, full, program.regA)
			cycle = 4
			inc_pc()
		case 0x32: // LD lp,i16
			full, lower, upper := grab_immediate_u16()
			program.regLP       = full

			if DEBUG do fmt.printf(" %2X %2X\t- LD LP,i16\t\t| LD LP,$%4X\n", lower, upper, program.regLP)
			cycle = 4
			inc_pc()
		case 0x40: // LD a,[lp]
			program.regA = program.memory[program.regLP]

			if DEBUG do fmt.printf(" \t- LD A,[LP]\t\t| LD A,[$%4X]\n", program.regLP)
			cycle = 4
			inc_pc()
		case 0x41: // LD [lp],a
			program.memory[program.regLP] = program.regA

			if DEBUG do fmt.printf(" \t- LD [LP],A\t\t| LD [$%4X],$%2X\n", program.regLP, program.regA)
			cycle = 4
			inc_pc()
		case 0x02: // LD lp,sp
			program.regLP = program.regSP
			
			if DEBUG do fmt.printf(" \t- LD LP,SP\t\t| LD $%4X,$%4X\n", program.regLP, program.regSP)
			cycle = 4
			inc_pc()
		case 0x42: // LD lp,xy
			program.regLP = (u16(program.regX) << 8) | u16(program.regY)
			
			if DEBUG do fmt.printf(" \t- LD LP,XY\t\t| LD LP,$%2X%2X\n", program.regX, program.regY)
			cycle = 4
			inc_pc()
		//? INC
		case 0x05: // INC x
			if program.regX == 0xFF do program.regF = F_INC_OVERFLOW_T
			else do program.regF = F_INC_OVERFLOW_F
			program.regX += 1

			if DEBUG do fmt.printf(" \t- INC X\t\t\t| INC $%2X\n", program.regX-1)
			cycle = 1
			inc_pc()
		case 0x06: // INC y
			if program.regY == 0xFF do program.regF = F_INC_OVERFLOW_T
			else do program.regF = F_INC_OVERFLOW_F
			program.regY += 1

			if DEBUG do fmt.printf(" \t- INC Y\t\t\t| INC $%2X\n", program.regY-1)
			cycle = 1
			inc_pc()
		case 0x07: // INC xy
			comb := (u16(program.regX) << 8) | u16(program.regY)

			if program.regX == 0xFF && program.regY == 0xFF do program.regF = F_INC_OVERFLOW_T
			else do program.regF = F_INC_OVERFLOW_F
			if program.regY == 0xFF do program.regX += 1
			program.regY += 1

			if DEBUG do fmt.printf(" \t- INC XY\t\t| INC $%4X\n", comb)
			cycle = 2
			inc_pc()
		case 0x15: // INC a
			if program.regA == 0xFF do program.regF = F_INC_OVERFLOW_T
			else do program.regF = F_INC_OVERFLOW_F
			program.regA += 1

			if DEBUG do fmt.printf(" \t- INC A\t\t\t| INC $%2X\n", program.regA-1)
			cycle = 1
			inc_pc()
		case 0x16: // INC lp
			if program.regLP == 0xFFFF do program.regF = F_INC_OVERFLOW_T
			else do program.regF = F_INC_OVERFLOW_F
			program.regLP += 1

			if DEBUG do fmt.printf(" \t- INC LP\t\t| INC $%4X\n", program.regLP-1)
			cycle = 1
			inc_pc()
		//? DEC
		case 0x25: // DEC x
			if program.regX == 0x01 do program.regF = F_DEC_ZERO_T
			else do program.regF = F_DEC_ZERO_F
			program.regX -= 1

			if DEBUG do fmt.printf(" \t- DEC X\t\t\t| DEC $%2X\n", program.regX+1)
			cycle = 2
			inc_pc()
		case 0x26: // DEC y
			if program.regY == 0x01 do program.regF = F_DEC_ZERO_T
			else do program.regF = F_DEC_ZERO_F
			program.regY -= 1

			if DEBUG do fmt.printf(" \t- DEC Y\t\t\t| DEC $%2X\n", program.regY+1)
			cycle = 2
			inc_pc()
		case 0x27: // DEC xy
			comb := (u16(program.regX) << 8) | u16(program.regY)

			if program.regX == 0x00 && program.regY == 0x01 do program.regF = F_DEC_ZERO_T
			else do program.regF = F_DEC_ZERO_F
			if program.regY == 0x00 do program.regX -= 1
			program.regY -= 1

			if DEBUG do fmt.printf(" \t- DEC XY\t\t| DEC $%4X\n", comb)
			cycle = 3
			inc_pc()
		case 0x35: // DEC a
			if program.regA == 0x01 do program.regF = F_DEC_ZERO_T
			else do program.regF = F_DEC_ZERO_F
			program.regA -= 1

			if DEBUG do fmt.printf(" \t- DEC A\t\t\t| DEC $%2X\n", program.regA+1+1)
			cycle = 2
			inc_pc()
		case 0x36: // DEC lp
			if program.regLP == 0x0001 do program.regF = F_DEC_ZERO_T
			else do program.regF = F_DEC_ZERO_F
			program.regLP -= 1

			if DEBUG do fmt.printf(" \t- DEC LP\t\t| DEC $%4X\n", program.regLP+1)
			cycle = 2
			inc_pc()
		//? JMP
		case 0x60: // JMP +i8
			var := grab_immediate_u8()
			program.regPC += u16(var)

			if DEBUG do fmt.printf(" %2X\t- JMP +$%X\t\t| JMP $%4X\n", var, var, program.regPC+1)
			cycle = 4
			inc_pc()
		case 0x70: // JMP -i8
			var := grab_immediate_u8()
			program.regPC -= u16(var)

			if DEBUG do fmt.printf(" %2X\t- JMP -$%X\t\t| JMP $%4X\n", var, var, program.regPC+1)
			cycle = 4
			inc_pc()
		case 0x61: // JMP  z,+i8
			var := grab_immediate_u8()
			if ((program.regF & F_ZERO_T) == F_ZERO_T) do program.regPC += u16(var)

			if DEBUG do fmt.printf(" %2X\t- JMP Z,+$%X\t\t| JMP Z,$%4X\n", var, var, program.regPC+1)
			cycle = 4
			inc_pc()
		case 0x71: // JMP  z,-i8
			var := grab_immediate_u8()
			if ((program.regF & F_ZERO_T) == F_ZERO_T) do program.regPC -= u16(var)

			if DEBUG do fmt.printf(" %2X\t- JMP Z,-$%X\t\t| JMP Z,$%4X\n", var, var, program.regPC+1)
			cycle = 4
			inc_pc()
		case 0x62: // JMP nz,+i8
			var := grab_immediate_u8()
			if !((program.regF & F_ZERO_T) == F_ZERO_T) do program.regPC += u16(var)

			if DEBUG do fmt.printf(" %2X\t- JMP NZ,+$%X\t\t| JMP NZ,$%4X\n", var, var, program.regPC+1)
			cycle = 4
			inc_pc()
		case 0x72: // JMP nz,-i8
			var := grab_immediate_u8()
			if !((program.regF & F_ZERO_T) == F_ZERO_T) do program.regPC -= u16(var)

			if DEBUG do fmt.printf(" %2X\t- JMP NZ,-$%X\t\t| JMP NZ,$%4X\n", var, var, program.regPC+1)
			cycle = 4
			inc_pc()
		case 0x63: // JMP  c,+i8
			var := grab_immediate_u8()
			if ((program.regF & F_CARRY_T) == F_CARRY_T) do program.regPC += u16(var)

			if DEBUG do fmt.printf(" %2X\t- JMP C,+$%X\t\t| JMP C,$%4X\n", var, var, program.regPC+1)
			cycle = 4
			inc_pc()
		case 0x73: // JMP  c,-i8
			var := grab_immediate_u8()
			if ((program.regF & F_CARRY_T) == F_CARRY_T) do program.regPC -= u16(var)

			if DEBUG do fmt.printf(" %2X\t- JMP C,-$%X\t\t| JMP C,$%4X\n", var, var, program.regPC+1)
			cycle = 4
			inc_pc()
		case 0x64: // JMP nc,+i8
			var := grab_immediate_u8()
			if !((program.regF & F_CARRY_T) == F_CARRY_T) do program.regPC += u16(var)

			if DEBUG do fmt.printf(" %2X\t- JMP NC,+$%X\t\t| JMP NC,$%4X\n", var, var, program.regPC+1)
			cycle = 4
			inc_pc()
		case 0x74: // JMP nc,-i8
			var := grab_immediate_u8()

			if !((program.regF & F_CARRY_T) == F_CARRY_T) do program.regPC -= u16(var)

			if DEBUG do fmt.printf(" %2X\t- JMP NC,-$%X\t\t| JMP NC,$%4X\n", var, var, program.regPC+1)
			cycle = 4
			inc_pc()
		//? CMP
		case 0x03: // CMP a,i8
			var := grab_immediate_u8()

			if (program.regA - var) == 0 do program.regF = F_ZERO_T
			else do program.regF = F_ZERO_F

			if DEBUG do fmt.printf(" %2X\t- CMP A,i8\t\t| CMP $%2X,$%2X\n", var, program.regA, var)
			cycle = 2
			inc_pc()
		case 0x04: // CMP a,m8
			full, lower, upper := grab_immediate_u16()

			if (program.regA - program.memory[full]) == 0 do program.regF = F_ZERO_T
			else do program.regF = F_ZERO_F

			if DEBUG do fmt.printf(" %2X %2X\t- CMP A,m8\t\t| CMP $%2X,[$%4X]\n", lower, upper, program.regA, full)
			cycle = 4
			inc_pc()
		case 0x13: // CMP a,x
			if (program.regA - program.regX) == 0 do program.regF = F_ZERO_T
			else do program.regF = F_ZERO_F

			if DEBUG do fmt.printf(" \t- CMP A,X\t\t| CMP $%2X,$%2X\n", program.regA, program.regX)
			cycle = 4
			inc_pc()
		case 0x14: // CMP a,y
			if (program.regA - program.regY) == 0 do program.regF = F_ZERO_T
			else do program.regF = F_ZERO_F

			if DEBUG do fmt.printf(" \t- CMP A,Y\t\t| CMP $%2X,$%2X\n", program.regA, program.regY)
			cycle = 4
			inc_pc()
		case 0x23: // CMP lp,i16
			full, lower, upper := grab_immediate_u16()

			if (program.regLP - full) == 0 do program.regF = F_ZERO_T
			else do program.regF = F_ZERO_F

			if DEBUG do fmt.printf(" %2X %2X\t- CMP LP,i8\t\t| CMP $%4X,$%4X\n", lower, upper, program.regLP, full)
			cycle = 6
			inc_pc()
		case 0x24: // CMP xy,i16
			full, lower, upper := grab_immediate_u16()

			if (program.regX - upper) == 0 && (program.regY - lower) == 0 do program.regF = F_ZERO_T
			else do program.regF = F_ZERO_F

			if DEBUG do fmt.printf(" %2X %2X\t- CMP XY,i8\t\t| CMP $%2X%2X,$%2X%2X\n", lower, upper, program.regX, program.regY, upper, lower)
			cycle = 6
			inc_pc()
		//? PUSH
		case 0x08: // PUSH af
			push(program.regF, program.regA)

			if DEBUG do fmt.printf(" \t- PUSH AF\t\t| PUSH $%2X%2X\n", program.regA, program.regF)
			cycle = 2
			inc_pc()
		case 0x18: // PUSH xy
			push(program.regY, program.regX)

			if DEBUG do fmt.printf(" \t- PUSH XY\t\t| PUSH $%2X%2X\n", program.regX, program.regY)
			cycle = 2
			inc_pc()
		case 0x28: // PUSH lp
			push(program.regLP)

			if DEBUG do fmt.printf(" \t- PUSH LP\t\t| PUSH $%4X\n", program.regLP)
			cycle = 2
			inc_pc()
		//? POP
		case 0x09: // POP af
			full, lower, upper := pop()

			program.regA = upper
			program.regF = lower

			if DEBUG do fmt.printf(" \t- POP AF\t\t| POP  $%2X%2X\n", program.regA, program.regF)
			cycle = 2
			inc_pc()
		case 0x19: // POP xy
			full, lower, upper := pop()

			program.regX = upper
			program.regY = lower

			if DEBUG do fmt.printf(" \t- POP XY\t\t| POP  $%2X%2X\n", program.regX, program.regY)
			cycle = 2
			inc_pc()
		case 0x29: // POP lp
			full, lower, upper := pop()

			program.regLP = (u16(upper) << 8) | u16(lower)

			if DEBUG do fmt.printf(" \t- POP LP\t\t| POP  $%4X\n", program.regLP)
			cycle = 2
			inc_pc()
	}

	return cycle
}

//* Increments program counter
inc_pc :: proc() {
	if program.regPC > 0xFFFE do program.halt = true
	else do program.regPC += 1
}

//* Grabs immediate value
grab_immediate_u16 :: proc() -> (full : u16, lower, upper : u8) {
	inc_pc()
	lower = program.memory[program.regPC]
	inc_pc()
	upper = program.memory[program.regPC]

	return (u16(upper) << 8) | u16(lower), lower, upper
}
grab_immediate_u8 :: proc() -> u8 {
	inc_pc()
	return program.memory[program.regPC]
}

//* Pops data off of stack
pop :: proc() -> (full : u16, lower, upper : u8) {
	program.regSP += 1
	upper = program.memory[program.regSP]
	program.regSP += 1
	lower = program.memory[program.regSP]
	return (u16(upper) << 8) | u16(lower), lower, upper
}

//* Pushes data onto stack
push :: proc{ push_u8, push_u16, }
push_u8 :: proc(lower, upper : u8) {
	program.memory[program.regSP] = lower
	program.regSP -= 1
	program.memory[program.regSP] = upper
	program.regSP -= 1
}
push_u16 :: proc(input : u16) {
	program.memory[program.regSP] = u8(input)
	program.regSP -= 1
	program.memory[program.regSP] = u8(input >> 8)
	program.regSP -= 1
}