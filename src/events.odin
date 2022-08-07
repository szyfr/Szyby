package main


//= Imports
import "vendor:sdl2"


//= Procedures

//* Event handler
event_handler :: proc() {
	e : sdl2.Event
	for r := sdl2.PollEvent(&e); r != 0; r = sdl2.PollEvent(&e) {
		#partial switch e.type {
			case .QUIT:
				program.running = false
				return
		}
	}
}