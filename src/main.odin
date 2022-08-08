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

update :: proc() {
	if program.halt == false {
		for i:=0;i<5;i+=1 do run_cpu()
	}
}