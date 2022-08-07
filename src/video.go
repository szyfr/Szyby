package main


import (
	"fmt"
	"time"
	"image/color"
	"github.com/veandco/go-sdl2/sdl"
)


func draw() {
	t0 := time.Now()
	program.surface.FillRect(nil, sdl.MapRGB(program.surface.Format,200,200,200))
	program.surface.FillRect(&program.screen, sdl.MapRGB(program.surface.Format,0xFF,0xFF,0xFF))
	
	for o:=0;o<11*8;o+=1 {
		for i:=0;i<14*8;i+=1 { draw_pixel(i, o, color.RGBA{0x00,0x00,0x00,0xFF}) }
	}

	program.window.UpdateSurface()
		
	t1 := time.Since(t0).Milliseconds()
	fmt.Printf("%v ms\n", t1)
}


func draw_pixel(x,y int, c color.Color) {
	for o:=0;o<MOD;o+=1 {
		for i:=0;i<MOD;i+=1 {
			program.surface.Set(x*MOD+i, y*MOD+o, c)
		}
	}
}