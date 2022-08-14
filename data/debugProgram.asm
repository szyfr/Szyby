

start:
	ld a,1         ;; Sets graphics into Bitmap mode
	ld [$C010],a   ;; 

	ldz            ;;
	ld lp,$C000    ;;
.loop1:            ;;
	ld [lp],a      ;; Clears RAM
	inc lp         ;;
	cmp lp,$C000   ;;
	jmp nz,.loop1  ;;

	ld lp,$C010    ;;
.loop2:            ;;
	ld [lp],a      ;; Clears VRAM
	inc lp         ;;
	jmp nc,.loop2  ;;

	halt