package main


//= Imports
import "core:fmt"
import "core:time"


// = Globals
program : ^Program
DEBUG   :: false


//= Main
main :: proc() {
	init_prg()
	defer close_prg()

	for program.running {
		// TODO: Keybindings to step through instructions
		event_handler()

		t0 := time.now()

		update()
		draw()

		t1 := time.duration_milliseconds(time.since(t0))
		fmt.printf("%v fps\n", 1 / (t1 / 1000))
	}
}

update :: proc() {
	if program.halt == false {
		//! True speed for now
		for i:=0;i<10000;i+=int(run_cpu()) { if program.halt do break }
		//! Debuging speed
	//	for i:=0;i<100;i+=int(run_cpu()) { if program.halt do break }
	}

}