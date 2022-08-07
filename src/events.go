package main


import (
	"github.com/veandco/go-sdl2/sdl"
)


func event_handler() {
	for e := sdl.PollEvent(); e != nil; e = sdl.PollEvent() {
		switch e.(type) {
		case *sdl.QuitEvent:
			program.running = false
			return
		}
	}
}