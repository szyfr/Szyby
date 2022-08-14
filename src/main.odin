package main


//= Imports
import "core:fmt"

//= Main
main :: proc() {
	init_prg()
	
// /	program.debug = true

	for program.running {
		event_handler()

		update()
		draw()
	}

	close_prg()
}

update :: proc() {
	if program.halt == false {
		//! True speed for now
	//	for i:=0;i<10000;i+=int(run_cpu()) {}
		//! Debuging speed
		for i:=0;i<100;i+=int(run_cpu()) {}
	}

}