package main


//= Imports
import "core:fmt"


//= Constants
F_ZERO_T  :: 0b00000001
F_ZERO_F  :: 0b00000000
F_CARRY_T :: 0b00000010
F_CARRY_F :: 0b00000000
F_INC_OVERFLOW_T :: 0b00000011
F_INC_OVERFLOW_F :: 0b00000000
F_DEC_ZERO_T     :: 0b00000001
F_DEC_ZERO_F     :: 0b00000000


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

	if program.debug do fmt.printf("%4X:%2X", program.regPC, opcode)

	switch opcode {
		//? NOP
		case 0x00:
			if program.debug do fmt.printf("\t\t- NOP")
			cycle = 10
		//? HALT
		case 0x01:
			if program.debug do fmt.printf("\t\t- HALT")
			program.halt = true
			cycle = 1
		//! CALL & RET
		case 0x50: // RET
			program.regSP += 1
			upper := program.memory[program.regSP]
			program.regSP += 1
			lower := program.memory[program.regSP]
			compl := (u16(upper) << 8) | u16(lower)

			program.regPC = compl
			if program.debug do fmt.printf(" \t- RET\t\t\t| RET $%4X", compl)
			cycle = 4
		case 0x51: // CALL i16
			lower := u8(program.regPC+3)
			upper := u8(program.regPC+3 >> 8)

			program.memory[program.regSP] = lower
			program.regSP -= 1
			program.memory[program.regSP] = upper
			program.regSP -= 1

			inc_pc()
			lower = program.memory[program.regPC]
			inc_pc()
			upper = program.memory[program.regPC]
			program.regPC = (u16(upper) << 8) | u16(lower)
			
			if program.debug do fmt.printf(" %2X %2X\t- CALL i16\t\t| CALL $%4X", lower, upper, program.regPC+1)
			cycle = 4
		//? LD
		case 0x10: // LDZ
			program.regA = 0x00

			if program.debug do fmt.printf("\t\t- LDZ\t\t\t| LD A,$00")
			cycle = 2
		case 0x11: // LD a,x
			program.regA = program.regX

			if program.debug do fmt.printf("\t\t- LD A,X\t\t| LD A,$%2X", program.regX)
			cycle = 2
		case 0x12: // LD a,y
			program.regA = program.regY

			if program.debug do fmt.printf("\t\t- LD A,Y\t\t| LD A,$%2X", program.regY)
			cycle = 2
		case 0x20: // LD a,i8
			inc_pc()
			program.regA = program.memory[program.regPC]

			if program.debug do fmt.printf(" %2X\t- LD A,i8\t\t| LD A,$%2X", program.memory[program.regPC], program.memory[program.regPC])
			cycle = 3
		case 0x21: // LD x,a
			program.regX = program.regA

			if program.debug do fmt.printf("\t\t- LD X,A\t\t| LD X,$%2X", program.regA)
			cycle = 2
		case 0x22: // LD y,a
			program.regY = program.regA

			if program.debug do fmt.printf("\t\t- LD Y,A\t\t| LD Y,$%2X", program.regA)
			cycle = 2
		case 0x30: // LD a,m8
			inc_pc()
			lower := program.memory[program.regPC]
			inc_pc()
			upper := program.memory[program.regPC]
			program.regA = program.memory[(u16(upper) << 8) | u16(lower)]
			
			if program.debug do fmt.printf(" %2X %2X\t- LD A,m8\t\t| LD A,[$%4X]", lower, upper, (u16(upper) << 8) | u16(lower))
			cycle = 4
		case 0x31: // LD m8,a
			inc_pc()
			lower := program.memory[program.regPC]
			inc_pc()
			upper := program.memory[program.regPC]
			program.memory[(u16(upper) << 8) | u16(lower)] = program.regA
			
			if program.debug do fmt.printf(" %2X %2X\t- LD m8,A\t\t| LD [$%4X],$%2X", lower, upper, (u16(upper) << 8) | u16(lower), program.regA)
			cycle = 4
		case 0x32: // LD lp,i16
			inc_pc()
			lower := program.memory[program.regPC]
			inc_pc()
			upper := program.memory[program.regPC]
			program.regLP = (u16(upper) << 8) | u16(lower)

			if program.debug do fmt.printf(" %2X %2X\t- LD LP,i16\t\t| LD LP,$%4X", lower, upper, program.regLP)
			cycle = 4
		case 0x40: // LD a,[lp]
			program.regA = program.memory[program.regLP]

			if program.debug do fmt.printf(" \t- LD A,[LP]\t\t| LD A,[$%4X]", program.regLP)
			cycle = 4
		case 0x41: // LD [lp],a
			program.memory[program.regLP] = program.regA

			if program.debug do fmt.printf(" \t- LD [LP],A\t\t| LD [$%4X],$%2X", program.regLP, program.regA)
			cycle = 4
		case 0x02: // LD lp,sp
			program.regLP = program.regSP
			
			if program.debug do fmt.printf(" \t- LD LP,SP\t\t| LD $%4X,$%4X", program.regLP, program.regSP)
			cycle = 4
		case 0x42: // LD lp,xy
			program.regLP = (u16(program.regX) << 8) | u16(program.regY)
			
			if program.debug do fmt.printf(" \t- LD LP,XY\t\t| LD LP,$%2X%2X", program.regX, program.regY)
			cycle = 4
		//? INC
		case 0x05: // INC x
			if program.regX == 0xFF do program.regF = F_INC_OVERFLOW_T
			else do program.regF = F_INC_OVERFLOW_F
			program.regX += 1

			if program.debug do fmt.printf(" \t- INC X\t\t\t| INC $%2X", program.regX-1)
			cycle = 1
		case 0x06: // INC y
			if program.regY == 0xFF do program.regF = F_INC_OVERFLOW_T
			else do program.regF = F_INC_OVERFLOW_F
			program.regY += 1

			if program.debug do fmt.printf(" \t- INC Y\t\t\t| INC $%2X", program.regY-1)
			cycle = 1
		case 0x07: // INC xy
			comb := (u16(program.regX) << 8) | u16(program.regY)

			if program.regX == 0xFF && program.regY == 0xFF do program.regF = F_INC_OVERFLOW_T
			else do program.regF = F_INC_OVERFLOW_F
			if program.regY == 0xFF do program.regX += 1
			program.regY += 1

			if program.debug do fmt.printf(" \t- INC XY\t\t| INC $%4X", comb)
			cycle = 2
		case 0x15: // INC a
			if program.regA == 0xFF do program.regF = F_INC_OVERFLOW_T
			else do program.regF = F_INC_OVERFLOW_F
			program.regA += 1

			if program.debug do fmt.printf(" \t- INC A\t\t\t| INC $%2X", program.regA-1)
			cycle = 1
		case 0x16: // INC lp
			if program.regLP == 0xFFFF do program.regF = F_INC_OVERFLOW_T
			else do program.regF = F_INC_OVERFLOW_F
			program.regLP += 1

			if program.debug do fmt.printf(" \t- INC LP\t\t| INC $%4X", program.regLP-1)
			cycle = 1
		//? DEC
		case 0x25: // DEC x
			if program.regX == 0x01 do program.regF = F_DEC_ZERO_T
			else do program.regF = F_DEC_ZERO_F
			program.regX -= 1

			if program.debug do fmt.printf(" \t- DEC X\t\t\t| DEC $%2X", program.regX+1)
			cycle = 2
		case 0x26: // DEC y
			if program.regY == 0x01 do program.regF = F_DEC_ZERO_T
			else do program.regF = F_DEC_ZERO_F
			program.regY -= 1

			if program.debug do fmt.printf(" \t- DEC Y\t\t\t| DEC $%2X", program.regY+1)
			cycle = 2
		case 0x27: // DEC xy
			comb := (u16(program.regX) << 8) | u16(program.regY)

			if program.regX == 0x00 && program.regY == 0x01 do program.regF = F_DEC_ZERO_T
			else do program.regF = F_DEC_ZERO_F
			if program.regY == 0x00 do program.regX -= 1
			program.regY -= 1

			if program.debug do fmt.printf(" \t- DEC XY\t\t| DEC $%4X", comb)
			cycle = 3
		case 0x35: // DEC a
			if program.regA == 0x01 do program.regF = F_DEC_ZERO_T
			else do program.regF = F_DEC_ZERO_F
			program.regA -= 1

			if program.debug do fmt.printf(" \t- DEC A\t\t\t| DEC $%2X", program.regA+1+1)
			cycle = 2
		case 0x36: // DEC lp
			if program.regLP == 0x0001 do program.regF = F_DEC_ZERO_T
			else do program.regF = F_DEC_ZERO_F
			program.regLP -= 1

			if program.debug do fmt.printf(" \t- DEC LP\t\t| DEC $%4X", program.regLP+1)
			cycle = 2
		//? JMP
		case 0x60: // JMP +i8
			inc_pc()
			var := program.memory[program.regPC]
			program.regPC += u16(var)

			if program.debug do fmt.printf(" %2X\t- JMP +$%X\t\t| JMP $%4X", var, var, program.regPC+1)
			cycle = 4
		case 0x70: // JMP -i8
			inc_pc()
			var := program.memory[program.regPC]
			program.regPC -= u16(var)

			if program.debug do fmt.printf(" %2X\t- JMP -$%X\t\t| JMP $%4X", var, var, program.regPC+1)
			cycle = 4
		case 0x61: // JMP  z,+i8
			inc_pc()
			var := program.memory[program.regPC]
			if ((program.regF & F_ZERO_T) == F_ZERO_T) do program.regPC += u16(var)

			if program.debug do fmt.printf(" %2X\t- JMP Z,+$%X\t\t| JMP Z,$%4X", var, var, program.regPC+1)
			cycle = 4
		case 0x71: // JMP  z,-i8
			inc_pc()
			var := program.memory[program.regPC]
			if ((program.regF & F_ZERO_T) == F_ZERO_T) do program.regPC -= u16(var)

			if program.debug do fmt.printf(" %2X\t- JMP Z,-$%X\t\t| JMP Z,$%4X", var, var, program.regPC+1)
			cycle = 4
		case 0x62: // JMP nz,+i8
			inc_pc()
			var := program.memory[program.regPC]
			if !((program.regF & F_ZERO_T) == F_ZERO_T) do program.regPC += u16(var)

			if program.debug do fmt.printf(" %2X\t- JMP NZ,+$%X\t\t| JMP NZ,$%4X", var, var, program.regPC+1)
			cycle = 4
		case 0x72: // JMP nz,-i8
			inc_pc()
			var := program.memory[program.regPC]
			if !((program.regF & F_ZERO_T) == F_ZERO_T) do program.regPC -= u16(var)

			if program.debug do fmt.printf(" %2X\t- JMP NZ,-$%X\t\t| JMP NZ,$%4X", var, var, program.regPC+1)
			cycle = 4
		case 0x63: // JMP  c,+i8
			inc_pc()
			var := program.memory[program.regPC]
			if ((program.regF & F_CARRY_T) == F_CARRY_T) do program.regPC += u16(var)

			if program.debug do fmt.printf(" %2X\t- JMP C,+$%X\t\t| JMP C,$%4X", var, var, program.regPC+1)
			cycle = 4
		case 0x73: // JMP  c,-i8
			inc_pc()
			var := program.memory[program.regPC]
			if ((program.regF & F_CARRY_T) == F_CARRY_T) do program.regPC -= u16(var)

			if program.debug do fmt.printf(" %2X\t- JMP C,-$%X\t\t| JMP C,$%4X", var, var, program.regPC+1)
			cycle = 4
		case 0x64: // JMP nc,+i8
			inc_pc()
			var := program.memory[program.regPC]
			if !((program.regF & F_CARRY_T) == F_CARRY_T) do program.regPC += u16(var)

			if program.debug do fmt.printf(" %2X\t- JMP NC,+$%X\t\t| JMP NC,$%4X", var, var, program.regPC+1)
			cycle = 4
		case 0x74: // JMP nc,-i8
			inc_pc()
			var := program.memory[program.regPC]
			if !((program.regF & F_CARRY_T) == F_CARRY_T) do program.regPC -= u16(var)

			if program.debug do fmt.printf(" %2X\t- JMP NC,-$%X\t\t| JMP NC,$%4X", var, var, program.regPC+1)
			cycle = 4
		//? CMP
		case 0x03: // CMP a,i8
			inc_pc()
			val := program.memory[program.regPC]
			if (program.regA - val) == 0 do program.regF = F_ZERO_T
			else do program.regF = F_ZERO_F

			if program.debug do fmt.printf(" %2X\t- CMP A,i8\t\t| CMP $%2X,$%2X", val, program.regA, val)
			cycle = 2
		case 0x04: // CMP a,m8
			inc_pc()
			lower := program.memory[program.regPC]
			inc_pc()
			upper := program.memory[program.regPC]
			complete := (u16(upper) << 8) | u16(lower)
			if (program.regA - program.memory[complete]) == 0 do program.regF = F_ZERO_T
			else do program.regF = F_ZERO_F

			if program.debug do fmt.printf(" %2X %2X\t- CMP A,m8\t\t| CMP $%2X,[$%4X]", lower, upper, program.regA, complete)
			cycle = 4
		case 0x13: // CMP a,x
			if (program.regA - program.regX) == 0 do program.regF = F_ZERO_T
			else do program.regF = F_ZERO_F

			if program.debug do fmt.printf(" \t- CMP A,X\t\t| CMP $%2X,$%2X", program.regA, program.regX)
			cycle = 4
		case 0x14: // CMP a,y
			if (program.regA - program.regY) == 0 do program.regF = F_ZERO_T
			else do program.regF = F_ZERO_F

			if program.debug do fmt.printf(" \t- CMP A,Y\t\t| CMP $%2X,$%2X", program.regA, program.regY)
			cycle = 4
		case 0x23: // CMP lp,i16
			inc_pc()
			lower := program.memory[program.regPC]
			inc_pc()
			upper := program.memory[program.regPC]
			complete := (u16(upper) << 8) | u16(lower)
			if (program.regLP - complete) == 0 do program.regF = F_ZERO_T
			else do program.regF = F_ZERO_F

			if program.debug do fmt.printf(" %2X %2X\t- CMP LP,i8\t\t| CMP $%4X,$%4X", lower, upper, program.regLP, complete)
			cycle = 6
		case 0x24: // CMP xy,i16
			inc_pc()
			lower := program.memory[program.regPC]
			inc_pc()
			upper := program.memory[program.regPC]
			if (program.regX - upper) == 0 && (program.regY - lower) == 0 do program.regF = F_ZERO_T
			else do program.regF = F_ZERO_F

			if program.debug do fmt.printf(" %2X %2X\t- CMP XY,i8\t\t| CMP $%2X%2X,$%2X%2X", lower, upper, program.regX, program.regY, upper, lower)
			cycle = 6
		//? PUSH
		case 0x08: // PUSH af
			program.memory[program.regSP] = program.regF
			program.regSP -= 1
			program.memory[program.regSP] = program.regA
			program.regSP -= 1

			if program.debug do fmt.printf(" \t- PUSH AF\t\t| PUSH $%2X%2X", program.regA, program.regF)
			cycle = 2
		case 0x18: // PUSH xy
			program.memory[program.regSP] = program.regY
			program.regSP -= 1
			program.memory[program.regSP] = program.regX
			program.regSP -= 1

			if program.debug do fmt.printf(" \t- PUSH XY\t\t| PUSH $%2X%2X", program.regX, program.regY)
			cycle = 2
		case 0x28: // PUSH lp
			program.memory[program.regSP] = u8(program.regLP)
			program.regSP -= 1
			program.memory[program.regSP] = u8(program.regLP >> 8)
			program.regSP -= 1

			if program.debug do fmt.printf(" \t- PUSH LP\t\t| PUSH $%4X", program.regLP)
			cycle = 2
		//? POP
		case 0x09: // POP af
			program.regSP += 1
			upper := program.memory[program.regSP]
			program.regSP += 1
			lower := program.memory[program.regSP]

			program.regA = upper
			program.regF = lower

			if program.debug do fmt.printf(" \t- POP AF\t\t| POP  $%2X%2X", program.regA, program.regF)
			cycle = 2
		case 0x19: // POP xy
			program.regSP += 1
			upper := program.memory[program.regSP]
			program.regSP += 1
			lower := program.memory[program.regSP]

			program.regX = upper
			program.regY = lower

			if program.debug do fmt.printf(" \t- POP XY\t\t| POP  $%2X%2X", program.regX, program.regY)
			cycle = 2
		case 0x29: // POP lp
			program.regSP += 1
			upper := program.memory[program.regSP]
			program.regSP += 1
			lower := program.memory[program.regSP]

			program.regLP = (u16(upper) << 8) | u16(lower)

			if program.debug do fmt.printf(" \t- POP LP\t\t| POP  $%4X", program.regLP)
			cycle = 2
	}

	if program.debug do fmt.printf("\n")
	inc_pc()

	return cycle
}

inc_pc :: proc() {
	if program.regPC > 0xFFFE do program.halt = true
	else do program.regPC += 1
}