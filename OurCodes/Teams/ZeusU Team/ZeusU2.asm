;; Global
%define jumpDist 0x5200 ;; 0x1500 original
%define copyloop ((@end_loop_v4-@loop_v4)/0x2)
%define copyloop_change ((@end_loop_v4_change-@loop_v4_change)/0x2)
%define copystart ((@copy_end-@copy)/0x2)
%define survivors_dist 0x8000

;; V5
%define callAmount_V5 1051
%define gap 0x27B0
%define callDist_V5 ((callAmount_V5 * (gap+0x4)) + 0x4)
%define deltaSp_loc_V5 (@end_loop_v4_change-@copy)

;; V4
%define deltaSp_loc_V4 (copyloop*0x2 + 0x3) ;; + 0x2 because of rep movsw
%define callAmount_V4 0x84 ;; 0x540 original
%define callDist_V4 (0x4 * callAmount_V4)
	



xchg si,ax 				;; si = ax 


add si,@copy 			;; si = @copy
push ss 				;; push ss value to stack
pop es					;; es = StackSeg				;; reset di in case of zoms
mov cl,copystart		;; cx = wordsstart
;; +-1
movsb
rep movsw

push ss
nop
nop

xchg ax,[0xA8EE]
xchg dx,[0xFFAF]
				;; copy code to ES (where SS is)

add ax,survivors_dist					;; push ss value to stack
pop ds					;; ds = StackSeg

mov al,0xA1				;; ax = closest location ending in 0xA3

mov bx,di		;; bx = location of where we read call far address
stosw 			;; [bx] = address of call far
mov word [di],dx 	;; [bx+0x2] segment of call far
mov word [bx+deltaSp_loc_V4],(jumpDist+callDist_V4)
mov word [bx+deltaSp_loc_V5],(jumpDist+callDist_V4 + 0x1)

les di,[bx]				;; di = ax, es = magicseg

push cs				 	;; put value of cs in stack
pop ds					;; ds = Arena

mov cl,0x4
shl dx,cl

movsw					;; write call far to the address
movsw

 		;; cx = 0x00words
sub di,0x3
mov si,(@change_to_V4-@copy) 				;; si = 0x0000

push ss					;; push ss value to stack
pop ds					;; ds = StackSeg

push cs
pop ss

mov sp,[bx]
add sp,dx
add sp,callDist_V5	
;; - 0x2 because we want to write from start of call far, not add sp,dx
;; - 0x4 because call far is first and last to execute

mov cl,copyloop_change
mov dx,gap

mov ax,jumpDist

call far [bx]

@copy:
movsw
rep movsw

@loop_v4:
add [bx],ax				;; change callfar place (bx += ax)
les di,[bx]				;; di = callfar address				
add sp,[bx+si]
mov cl,copyloop			;; reset counter for next time we execute "rep movsw" 
movsw					;; write callfar in the next address (address = [bx] = di)
dec di					;; dx = [bx] + 0x1 (address of callfar + 0x1)
xor si,si				;; reset si (si = 0x0000)
dec bp 					;;counter for zoms
db 0x75  
						;; 0x75FF -> jnz short 0x1
db 0xFF					;; this byte is the last byte of "jnz" and first of "callfar"
						;; 0xFF18 -> callfar [bx + si]
db 0x18
						;; 0x18 -> sbb ah,cl (if pointer reaches here the code will die after this command)

@end_loop_v4:

call far [bx+si] 		;; being copied by movsw for next callfar cycle

@change_to_V4:
rep movsw

@loop_v4_change:
inc word [bx]
add [bx],ax				;; change callfar place (bx += ax)
les di,[bx]				;; di = callfar address				
add sp,[bx+si]			;; change sp adress relative to next callfar address (sp += deltaSp)
mov cl,copyloop			;; reset counter for next time we execute "rep movsw" 
movsw					;; write callfar in the next address (address = [bx] = di)
dec di					;; dx = [bx] + 0x1 (address of callfar + 0x1)
xor si,si				;; reset si (si = 0x0000)
dec bp 					;;counter for zoms
db 0x75  
						;; 0x75FF -> jnz short 0x1
db 0xFF					;; this byte is the last byte of "jnz" and first of "callfar"
						;; 0xFF18 -> callfar [bx + si]
db 0x18
						;; 0x18 -> sbb ah,cl (if pointer reaches here the code will die after this command)

@end_loop_v4_change:

call far [bx+si] 		;; being copied by movsw for next callfar cycle

@copy_end:

sub sp,dx
call far [bx]
