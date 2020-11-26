%define jumpDist 0x2000
%define callAmount 0xE0
%define gap 0x2B
%define calldist ((callAmount * (gap+0x4)) + 0x2)
%define copyloop1 ((@loop_end-@loop)/0x2)
%define copyloop2 ((@loop2_end-@loop2)/0x2) - 0x1 ;; -0x1 because of extra movsw
%define copystart ((@copy2_end-@copy)/0x2)
%define deltaSp_loc1 (@loop_end-@copy) ;; + 0x2 because of rep movsw
%define deltaSp_loc2 (@loop2_end-@copy)


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
xchg ax,[0x9898]


push ss					;; push ss value to stack
pop ds					;; ds = StackSeg

mov al,0xA6				;; ax = closest location ending in 0xA5
nop
nop

mov bx,di		;; bx = location of where we read call far address
stosw 			;; [bx] = address of call far
mov word [di],dx 	;; [bx+0x2] segment of call far
mov word [bx+deltaSp_loc1],(jumpDist-calldist)+0x2-0x1
mov word [bx+deltaSp_loc2],(jumpDist-calldist)+0x2+0x1

les di,[bx]				;; di = ax, es = magicseg

push cs				 	;; put value of cs in stack
pop ds					;; ds = Arena

mov cl,0x4
shl dx,cl

movsw					;; write call far to the address
movsw

mov cl,copyloop1 		;; cx = 0x00words
dec di
xor si,si 				;; si = 0x0000

push ss					;; push ss value to stack
pop ds					;; ds = StackSeg

push cs
pop ss

mov sp,[bx]
add sp,dx
add sp,calldist-gap
;; - 0x2 because we want to write from start of call far, not add sp,dx
;; - 0x4 because call far is first and last to execute

mov ax,0xA5A5
mov dx,gap
call far [bx+si]			;; execute call far

;;;;;;;;;;;;;;;;;;;;;;;;;; END OF REGULAR CODE

@copy:
rep movsw				;; write our code
@loop:
inc byte [bx]

sub word [bx],jumpDist	;; change call far place (bx -= ax)

les di,[bx]				;; di = call far address				

sub sp,[bx+si]
;; - gap because add sp,dx was executed after the call far was overwriten
;; + 0x4 because call far is first and last to act

mov cl,copyloop2			;; reset counter for next time we execute "rep movsw" (cx = 0x00words)

movsw					;; write call far in the next address (address = [bx] = di)

movsw

dec di					;; dx = [bx] + 0x1 (address of call far + 0x1)

dec bp 	
db 0x75 
		
db 0xFF	
		
db 0x1F

db 0xCC

@loop_end:


sub sp,dx

call far [bx]

@copy_end:

@copy2:
rep movsw				;; write our code

@loop2:
dec byte [bx]

sub word [bx],jumpDist	;; change call far place (bx -= ax)

les di,[bx]				;; di = call far address				

sub sp,[bx+si]
;; - gap because add sp,dx was executed after the call far was overwriten
;; + 0x4 because call far is first and last to act

mov cl,copyloop1			;; reset counter for next time we execute "rep movsw" (cx = 0x00words)

movsw					;; write call far in the next address (address = [bx] = di)

movsw

dec di					;; dx = [bx] + 0x1 (address of call far + 0x1)

xor si,si				;; reset si (si = 0x0000)

dec bp 	
db 0x75 
		
db 0xFF	
		
db 0x18

db 0xCC

@loop2_end:

sub sp,dx

call far [bx+si]

@copy2_end:

sub sp,dx
call far [bx+si]			;; will be copied to the call far address
