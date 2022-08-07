package main


//= Imports
import "core:fmt"
import "core:time"
import "core:mem"
import "vendor:sdl2"


//= Constants
MOD :: 8


//= Structures
Color :: struct {
	r,g,b,a : u8,
}


//= Procedures

//* Drawing full screen
draw :: proc() {
	t0 := time.now()
	sdl2.FillRect(program.surface,             nil, sdl2.MapRGB(program.surface.format,200,200,200))
	sdl2.FillRect(program.surface, &program.screen, sdl2.MapRGB(program.surface.format,255,255,255))

	for o:=0;o<11*8;o+=1 {
		for i:=0;i<14*8;i+=1 do draw_pixel_major(i, o, Color{0x00,0x00,0x00,0xFF})
	}

	sdl2.UpdateWindowSurface(program.window)

	t1 := time.duration_milliseconds(time.since(t0))
	fmt.printf("%v ms\n", t1)
}


//* Draw pixel
draw_pixel_major :: proc(x,y : int, c : Color) {
	for o:=0;o<MOD;o+=1 {
		for i:=0;i<MOD;i+=1 {
			draw_pixel_minor(x*MOD+i, y*MOD+o, c)
		}
	}
}
// TODO: Roughly takes 2-3 milliseconds per color to fill screen
draw_pixel_minor :: proc(x,y : int, c : Color) {
	arr := mem.ptr_to_bytes(
		(^u8)(program.surface.pixels),
		int(program.surface.w * program.surface.h) * 4,
	)
	index := (x*4) + (y * int(program.surface.w * 4))

	arr[index+0] = c.b
	arr[index+1] = c.g
	arr[index+2] = c.r
//	arr[index+3] = c.a
}