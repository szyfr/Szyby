package main


import (
	"github.com/veandco/go-sdl2/sdl"
)


//= Structures
type Program struct {
	window  *sdl.Window
	surface *sdl.Surface
	screen   sdl.Rect

	running  bool
	
	memory   [0xFFFF]uint8


}
var program *Program


//= Procedures
// Initialization
func init_prg() {
	programTemp := new(Program)

	// Init SDL2
	if err := sdl.Init(sdl.INIT_EVERYTHING); err != nil { panic(err) }

	// Create Window
	window, err := sdl.CreateWindow(
		"TEST",
		sdl.WINDOWPOS_UNDEFINED,
		sdl.WINDOWPOS_UNDEFINED,
		1280, 720,
		sdl.WINDOW_SHOWN,
	)
	if err != nil { panic(err) }
	programTemp.window = window

	// Get surface
	surface, err := programTemp.window.GetSurface()
	if err != nil { panic(err) }
	programTemp.surface = surface

	// Set program variables
	programTemp.screen  = sdl.Rect{0, 0, 896, 704}
	programTemp.running = true

	// Set program
	program = programTemp
}

// Closure
func close_prg() {
	program.surface.Free()
	program.window.Destroy()
	sdl.Quit()
}