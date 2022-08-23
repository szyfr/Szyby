package main


//= Imports
import "core:fmt"
import "core:time"
import "core:mem"
import "vendor:sdl2"


//= Procedures
//* Drawing full screen
draw :: proc() {
	switch program.memory[0xC001] {
		case 0x00: // None
		case 0x01: // Monochrome Bitmap mode
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
					pixel +=1
					off   +=2
				}
			}
		case 0x02: // Monochrome Tile mode
		// ...
	}

	sdl2.UpdateWindowSurface(program.window)
}


//* Draw pixel
draw_pixel_major :: proc(x,y : int, c : Color) {
	mag := program.screenMagnification

	for o:=0; o<mag; o+=1 {
		for i:=0; i<mag; i+=1 {
			draw_pixel_minor((x * mag) + i, (y * mag) + o, c)
		}
	}
}
// TODO: Roughly takes 2-3 milliseconds per color to fill screen
draw_pixel_minor :: proc(x,y : int, c : Color) {
	width, height : int = int(program.surface.w), int(program.surface.h)

	arr := mem.ptr_to_bytes(
		(^u8)(program.surface.pixels),
		int(width * height) * 4,
	)
	index := (x*4) + (y * (width * 4))

	arr[index+0] = c.b
	arr[index+1] = c.g
	arr[index+2] = c.r
//	arr[index+3] = c.a
}