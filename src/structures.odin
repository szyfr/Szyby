package main


//= Imports
import "vendor:sdl2"


//= Structures
Color :: struct {
	r,g,b,a : u8,
}

Program :: struct {
	window   : ^sdl2.Window,
	renderer : ^sdl2.Renderer,
	surface  : ^sdl2.Surface,
	texture  : ^sdl2.Texture,
	screen   :  sdl2.Rect,

	srfTiles : ^sdl2.Surface, 
	recTiles :  sdl2.Rect,

	running :  bool,

	//* CPU
	halt  : bool,
	//- Registers
	regA  :  u8,
	regX  :  u8,
	regY  :  u8,
	regLP : u16,
	regF  :  u8,
	//? 0 - Z
	//? 1 - C

	regPC : u16,
	regSP : u16,

	memory  :  [0x10000]u8,
	//	$0000 -> $3FFF : Bank 0 ROM
	//	$4000 -> $7FFF : Bank X ROM
	//	$8000 -> $9FFF : Bank X Save RAM
	//	$A000 -> $BFFF : Bank X RAM
	//	$C000 -> $EFFF : Bank X VRAM
	//	$F000 -> $FEFF : Stack
	//	$FF00 -> $FFFF : I/O
}