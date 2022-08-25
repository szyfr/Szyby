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
		case 0x00: // Screen off
		case 0x01: // Monochrome Bitmap mode
			pixel := 0
			for i:=VRAM_MEM_START;i<VRAM_MEM_START+VRAM_MODE1_LEN;i+=1 {
				for o:u32=0;o<8;o+=2 {
					col : Color
					val := ((program.memory[i] >> o) & COLOR_DEPTH)

					switch val {
						case 0x00: col = COLOR_0
						case 0x01: col = COLOR_1
						case 0x02: col = COLOR_2
						case 0x03: col = COLOR_3
					}

					draw_pixel(pixel%112, pixel/112, col)
					pixel +=1
				}
			}
			sdl2.DestroyTexture(program.texture)
			program.texture = sdl2.CreateTextureFromSurface(program.renderer, program.surface)
			sdl2.RenderCopy(program.renderer, program.texture, nil, &program.screen)
		case 0x02: // Monochrome Tile mode
			program.recTiles = {
				i32(program.memory[VRAM_MODE2_SCROLLX]),
				i32(program.memory[VRAM_MODE2_SCROLLY]),
				896, 704,
			}
		//	1-Copy tiles onto a surface
		//	2-Transfer each tile to srfTiles
		//	3-Turn surface into texture then RenderCopy it to renderer using recTiles
		//	Repeat 1+3 with sprites
	}

	sdl2.RenderPresent(program.renderer)
}

draw_pixel :: proc(x,y : int, c : Color) {
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