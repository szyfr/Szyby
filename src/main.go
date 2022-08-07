package main


import (
	_"runtime"
	_"github.com/veandco/go-sdl2/sdl"
)


func main() {
	init_prg()

	for program.running {
		event_handler()

		update()
		draw()
	}

	close_prg()
}

func update() {

}