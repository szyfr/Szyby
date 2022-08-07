package main


//= Imports



//= Main
main :: proc() {
	init_prg()

	for program.running {
		event_handler()

		update()
		draw()
	}

	close_prg()
}

update :: proc() {}