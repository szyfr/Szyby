package main


//= Imports
import "core:fmt"
import "core:time"
import "core:mem"
import "vendor:sdl2"


//= Constants
MOD   :: 8

COL_0 :: Color{0xE0,0xF8,0xD0,0xFF}
COL_1 :: Color{0x88,0xC0,0x70,0xFF}
COL_2 :: Color{0x34,0x68,0x56,0xFF}
COL_3 :: Color{0x08,0x18,0x20,0xFF}


//= Structures
Color :: struct {
	r,g,b,a : u8,
}

//= Procedures

//* Drawing full screen
draw :: proc() {
//	t0 := time.now()
	sdl2.FillRect(program.surface,             nil, sdl2.MapRGB(program.surface.format,200,200,200))
	sdl2.FillRect(program.surface, &program.screen, sdl2.MapRGB(program.surface.format,255,255,255))

//	for o:=0;o<11*8;o+=1 {
//		for i:=0;i<14*8;i+=1 do draw_pixel_major(i, o, Color{0x00,0x00,0x00,0xFF})
//	}
	switch program.memory[0xC001] {
		case 0x00: // Default
		case 0x01: // Bitmap mode
			pixel := 0
			for i:=0xC010;i<0xC010+0x9A0;i+=1 {
				off : u32 = 0
				for o:=0;o<4;o+=1 {
					col : Color
					val := ((program.memory[i] >> off) & 0x03)

					switch val {
						case 0x00: col = COL_0
						case 0x01: col = COL_1
						case 0x02: col = COL_2
						case 0x03: col = COL_3
					}

					draw_pixel_major(pixel%112, pixel/112, col)
				//	fmt.printf("Drawn (%i,%i) COL:%X\n",pixel%(11*8),pixel/(14*8),val)
					pixel +=1
					off   +=2
				}
			}
		// ...
	}

	sdl2.UpdateWindowSurface(program.window)

//	t1 := time.duration_milliseconds(time.since(t0))
//	fmt.printf("%v ms\n", t1)
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