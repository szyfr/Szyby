

;;= BOOT v1.2
;; length: 83-bytes
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

.mainloop:

	ld lp,$C010    ;? | 32 10 C0 | - |
.loop1:            ;? |          |   |
	ld a,$40       ;? | 20 80    |   |
	ld x,a         ;? | 21       |   |
	ld a,$33       ;? | 20 33    |   |
	ld [lp],a      ;? | 41       |   | Loop through VRAM and set pattern 1
	ld y,a         ;? | 22       |   |
	call wait      ;? | 51 10 01 |   |
	inc lp         ;? | 16       |   |
	cmp lp,$C9B0   ;? | 23 B0 C9 |   |
	jmp nz,.loop1  ;? | 72 10    | - |

	ld a,10        ;? | 20 10    | - |
	ld x,a         ;? | 21       |   |
.wait:             ;? |          |   |
	ld a,$FF       ;? | 20 FF    |   | wait  a little
	ld y,a         ;? | 22       |   | TODO: Make this longer
	call wait      ;? | 51 10 01 |   |
	dec x          ;? | 05       |   |
	jmp nz,.wait   ;? | 72 09    | - |

	ld lp,$C010    ;? | 32 10 C0 | - |
.loop2:            ;? |          |   |
	ld a,$40       ;? | 20 80    |   |
	ld x,a         ;? | 21       |   |
	ld a,$CC       ;? | 20 CC    |   |
	ld [lp],a      ;? | 41       |   | Loop through VRAM and set pattern 2
	ld y,a         ;? | 22       |   |
	call wait      ;? | 51 10 01 |   |
	inc lp         ;? | 16       |   |
	cmp lp,$C9B0   ;? | 23 B0 C9 |   |
	jmp nz,.loop2  ;? | 72 10    | - |

	call .mainloop ;? | 51 1d 00 |
	halt           ;? | 01       |

;= Clears memory
;= A = value, LP = ptr, XY = count
;; length: 6-bytes
memset: ;; $0100
	ld [lp],a      ;? | 41       |
	inc lp         ;? | 16       |
	dec xy         ;? | 27       |
	jmp nz,memset  ;? | 72 05    |
	ret            ;? | 50       |

;= waits 10 cycles per count
;= Y = count
;; length: 8-bytes
wait: ;; $0110
	nop            ;? | 00       |
	nop            ;? | 00       |
	nop            ;? | 00       |
	nop            ;? | 00       |
	dec y          ;? | 26       |
	jmp nz,wait    ;? | 72 07    |
	ret            ;? | 50       |


;-----------------------------------------------------------------------


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