package main


import (
	"github.com/veandco/go-sdl2/sdl"
)


func init_sdl() *Program {
	program := new(Program)

	if err := sdl.Init(sdl.INIT_EVERYTHING); err != nil { panic(err) }

	window, err := sdl.CreateWindow(
		"TEST",
		sdl.WINDOWPOS_UNDEFINED,
		sdl.WINDOWPOS_UNDEFINED,
		1280, 720,
		sdl.WINDOW_SHOWN,
	)
	if err != nil { panic(err) }
	program.window = window

	surface, err := program.window.GetSurface()
	if err != nil { panic(err) }
	program.surface = surface

	program.running = true

	return program
}

func close_sdl() {
	program.surface.Free()
	program.window.Destroy()
	sdl.Quit()
}