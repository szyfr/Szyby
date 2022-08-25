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
	if !program.halt {
		if !DEBUG do for i:=0;i<100000;i+=int(run_cpu()) { if program.halt do break }
		else      do for i:=0;i<100;i+=int(run_cpu()) { if program.halt do break }
	}

}