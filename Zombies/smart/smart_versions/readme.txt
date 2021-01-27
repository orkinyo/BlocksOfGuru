name notation:
; 57, 58, 59, 60 - is the step number in which the survs do the first xchg
; cx / loop / shl - the method of taking control of the zombie (cx is mov cx,0x1234; call cx, loop is
	writing call [di...] in the loop and shl is writing call [di...] in shl bx,1)
; word / byte - represents if using call [di+byte] or call [di+word] (this notation does not exist
	in the mov cx,0x1234; call cx; method)
; one / full - represents if the survivors does one loop trying to take control of the zombies
	or 'full' loops, which mean three loops at this point in time


;;;;;;;;;;;;;;;;;
NOTE:
ALL BINARY SURVIVORS WERE CORRECTLY ASSEMBLED, THERE IS NO NEED TO ASSEMBLE THE .asm FILES AGAIN!
;;;;;;;;;;;;;;;;;