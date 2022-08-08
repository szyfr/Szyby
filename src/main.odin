package main


//= Imports
import "core:fmt"

//= Main
main :: proc() {
	init_prg()

	run_cpu()
	run_cpu()
	run_cpu()
	fmt.printf(" - %X",program.regA)

	for program.running {
		event_handler()

		update()
		draw()
	}

	close_prg()
}

update :: proc() {
//	if program.halt == false {
//		for i:=0;i<10;i+=int(run_cpu()) {}
//	}

}