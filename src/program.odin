package main


//= Imports
import "core:fmt"
import "vendor:sdl2"


//= Structures
Program :: struct {
	window  : ^sdl2.Window,
	surface : ^sdl2.Surface,
	screen  :  sdl2.Rect,

	running :  bool,

	//* CPU
	halt  : bool,
	//- Registers
	regA  :  u8,
	regF  :  u8,

	regXY : u16,
	regLP : u16,

	regPC : u16,
	regSP : u16,

	memory  :  [0x10000]u8,
}
program : ^Program


//= Procedures

//* Initialization
init_prg :: proc() {
	program = new(Program)

	//* Init SDL2
	if sdl2.Init(sdl2.INIT_EVERYTHING) != 0 do fmt.printf("[ERROR]: Failed to init SDL2.")

	//* Create Window
	program.window = sdl2.CreateWindow(
		"TEST",
		sdl2.WINDOWPOS_UNDEFINED,
		sdl2.WINDOWPOS_UNDEFINED,
		1280, 720,
		sdl2.WINDOW_SHOWN,
	)
	if program.window == nil do fmt.printf("[ERROR]: Failed to create window.")

	//* Get surface
	program.surface = sdl2.GetWindowSurface(program.window)
	if program.surface == nil do fmt.printf("[ERROR]: Failed to get Surface")

	//* Set program variables
	program.screen  = sdl2.Rect{0, 0, 896, 704}
	program.running = true

	//* CPU
	init_cpu()
}

//* Closure
close_prg :: proc() {
	sdl2.FreeSurface(program.surface)
	sdl2.DestroyWindow(program.window)
	sdl2.Quit()
}