package main


//= Imports
import "core:fmt"
import "core:math/rand"
import "core:os"
import "core:time"
import "vendor:sdl2"


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
//		1280, 720,
		896, 704,
		sdl2.WINDOW_SHOWN,
	)
	if program.window == nil do fmt.printf("[ERROR]: Failed to create window.")

	//* Get surface
	program.surface = sdl2.GetWindowSurface(program.window)
	if program.surface == nil do fmt.printf("[ERROR]: Failed to get Surface.")

	//* Set program variables
	program.screen  = sdl2.Rect{0, 0, 896, 704}
	program.running = true
	program.debug   = DEBUG
	program.screenMagnification = SCREEN_MAGNIFICATION

	//* CPU
	init_cpu()

	//* Boot ROM
	bootROM, succ := os.read_entire_file_from_filename("data/boot.bin")
	if !succ do fmt.printf("[ERROR]: Failed to load boot ROM.")

	for i:=0; i<0x2000; i+=1 do program.memory[i] = bootROM[i]
	delete(bootROM)

	//* Randomize RAM
	for i:=0xA000;i<0xFEFF;i+=1 {
		if  i != 0xA000 || i != 0xC000 do program.memory[i] = u8(rand.uint32())
	}
}
//* Closure
close_prg :: proc() {
	sdl2.FreeSurface(program.surface)
	sdl2.DestroyWindow(program.window)
	sdl2.Quit()
}