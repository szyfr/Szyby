package main


import (
	_"runtime"
	"fmt"
	"time"
	"image/color"
	"github.com/veandco/go-sdl2/sdl"
)


type Program struct {
	window  *sdl.Window
	surface *sdl.Surface
	running  bool
}


const MOD = 8


var program *Program


func main() {
	program = init_sdl()

	for program.running {
		event_handler()

		rect0 := sdl.Rect{896,   0,  384, 720}
		rect1 := sdl.Rect{0  , 704, 1280,  16}
		program.surface.FillRect(nil,    sdl.MapRGB(program.surface.Format,0xFF,0xFF,0xFF))
		program.surface.FillRect(&rect0, sdl.MapRGB(program.surface.Format,200,200,200))
		program.surface.FillRect(&rect1, sdl.MapRGB(program.surface.Format,200,200,200))
	
		t0 := time.Now()
		for o:=0;o<11*8;o+=1 {
			for i:=0;i<14*8;i+=1 { draw_pixel(i, o, color.RGBA{0x00,0x00,0x00,0xFF}) }
		}
		t1 := time.Since(t0).Milliseconds()
		fmt.Printf("%v ms\n", t1)

		program.window.UpdateSurface()
	}

	close_sdl()
}


func event_handler() {
	for e := sdl.PollEvent(); e != nil; e = sdl.PollEvent() {
		switch e.(type) {
		case *sdl.QuitEvent:
			program.running = false
			return
		}
	}
}


func draw_pixel(x,y int, c color.Color) {
	for o:=0;o<MOD;o+=1 {
		for i:=0;i<MOD;i+=1 {
			program.surface.Set(x*MOD+i, y*MOD+o, c)
		}
	}
}