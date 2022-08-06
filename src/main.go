package main


import (
	_"runtime"
	_"fmt"
	"image/color"
	"github.com/veandco/go-sdl2/sdl"
)


type Program struct {
	window  *sdl.Window
	surface *sdl.Surface
}


func main() {
	program := init_sdl()

	program.surface.FillRect(nil, sdl.MapRGB(program.surface.Format,0xFF,0xFF,0xFF))
	program.window.UpdateSurface()

//	test := program.surface.BytesPerPixel()
//	fmt.Printf("%i\n",test)

	program.surface.Set(0,0,color.Color{0xFFFF,0xFFFF,0xFFFF,0xFFFF})

	sdl.Delay(2000)

	program.window.Destroy()
	sdl.Quit()
}


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

	return program
}