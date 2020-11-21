%define jumpDist 0x0800
%define callAmount 51
%define gap 0x6
%define calldist ((callAmount * (gap+0x4)) + 0x4)
%define addsp jumpDist+calldist
%define copyloop ((@loop_end-@loop)/0x2)
%define copystart ((@copy_end-@copy)/0x2)
%define deltaSp_loc (copyloop*0x2 + 0x2) ;; + 0x2 because of rep movsw


;mov ax,calldist
mov si,ax 				;; si = ax
add si,@copy 			;; si = @copy
push ss 				;; push ss value to stack
pop es					;; es = StackSeg				;; reset di in case of zoms
mov cl,copystart		;; cx = wordsstart
;; +-1
rep movsw

mov cl,0xf
div cx ;; dx
add dx,0xff6
				;; copy code to ES (where SS is)

push ss					;; push ss value to stack
pop ds					;; ds = StackSeg

mov al,0xA1				;; ax = closest location ending in 0xA3

mov bx,di		;; bx = location of where we read call far address
stosw 			;; [bx] = address of call far
mov word [di],dx 	;; [bx+0x2] segment of call far
mov word [bx+deltaSp_loc],(jumpDist-calldist)

les di,[bx]				;; di = ax, es = magicseg

push cs				 	;; put value of cs in stack
pop ds					;; ds = Arena

mov cl,0x4
shl dx,cl

movsw					;; write call far to the address
movsw

mov cl,copyloop 		;; cx = 0x00words
sub di,0x3
xor si,si 				;; si = 0x0000

push ss					;; push ss value to stack
pop ds					;; ds = StackSeg

push cs
pop ss

mov sp,[bx]
add sp,dx
add sp,calldist		
;; - 0x2 because we want to write from start of call far, not add sp,dx
;; - 0x4 because call far is first and last to execute

mov ax,jumpDist
mov dx,gap
call far [bx+si]			;; execute call far

;;;;;;;;;;;;;;;;;;;;;;;;;; END OF REGULAR CODE

@copy:
rep movsw				;; write our code
@loop:
sub [bx],ax	;; change call far place (bx -= ax)

les di,[bx]				;; di = call far address				

sub sp,[bx+si]
;; - gap because add sp,dx was executed after the call far was overwriten
;; + 0x4 because call far is first and last to act

mov cl,copyloop			;; reset counter for next time we execute "rep movsw" (cx = 0x00words)

movsw					;; write call far in the next address (address = [bx] = di)

movsw

sub di,0x3					;; dx = [bx] + 0x1 (address of call far + 0x1)

xor si,si				;; reset si (si = 0x0000)

dec bp 	
db 0x75 
		
db 0xFF	
		
db 0x18

db 0xCC

@loop_end:


sub sp,dx

call far [bx+si]

@copy_end:

sub sp,dx
call far [bx+si]			;; will be copied to the call far address
