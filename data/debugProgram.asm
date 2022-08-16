

;;= BOOT v1.1
;; length: 30 bytes
start: ;; $0000
	ld a,1         ;? | 20 01    | Sets graphics into Bitmap mode
	ld [$C001],a   ;? | 31 01 C0 |
	ld a,$20       ;? | 20 20    | - |
	ld x,a         ;? | 21       |   |
	ldz            ;? | 10       |   | Clear RAM
	ld y,a         ;? | 22       |   |
	ld lp,$A000    ;? | 32 00 A0 |   |
	call memset    ;? | 51 FF 00 | - |
	ld a,$1F       ;? | 20 1F    | - |
	ld x,a         ;? | 21       |   |
	ld a,$EF       ;? | 20 EF    |   | Clear VRAM
	ld y,a         ;? | 22       |   |
	ldz            ;? | 10       |   |
	ld lp,$C010    ;? | 32 10 C0 |   |
	call memset    ;? | 51 FF 00 | - |
	halt           ;? | 01       |

;= Clears memory
;= A = value, LP = ptr, XY = count
;; length: 6 bytes
memset: ;; $0100
	ld [lp],a      ;? | 41       |
	inc lp         ;? | 16       |
	dec xy         ;? | 27       |
	jmp nz,memset  ;? | 72 05    |

	ret            ;? | 50       |


;-----------------------------------------------------------------------


;;= BOOT v1.0
;; length: 24 bytes
start:
	ld a,1         ;? | 20 01    | Sets graphics into Bitmap mode
	ld [$C001],a   ;? | 31 01 C0 |
	ldz            ;? | 10       | -|
	ld lp,$A000    ;? | 32 00 A0 |  |
.loop1:            ;? |          |  |
	ld [lp],a      ;? | 41       |  | Clears RAM
	inc lp         ;? | 16       |  |
	cmp lp,$C000   ;? | 23 00 C0 | -|
	jmp nz,.loop1  ;? | 72 07    | -|
	ld lp,$C010    ;? | 32 10 C0 |  |
.loop2:            ;? |          |  |
	ld [lp],a      ;? | 41       |  | Clears VRAM
	inc lp         ;? | 16       |  |
	jmp nc,.loop2  ;? | 74 04    | -|
	halt           ;? | 01       |