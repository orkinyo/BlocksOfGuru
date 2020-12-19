;; V4U - Callfar V4 - Best in class
;; V4UB - added movsb instead of movsw (kills better)

%define jumpDist 0x5200
%define callAmount 0x84

%define callDist 0x4 * callAmount											;;distance the callfar loop will bomb on the board
%define deltaSp jumpDist + callDist										;;the amount sp needs to updated for next loop
%define deltaSp_loc (@end_loop_section-@copy)                          	;; the location in es where we store deltaSp (2 is for the 2 bytes of rep movsw)

;; si = ax
mov si,ax

;;write magicseg to the loc after the label @copy_end
mov cl,0xf
div cx ;; dx = reminder
add dx,0xff6 ;; 0xff6 <= dx <= 0x1004

mov [si+@copy_end],dx	

;;ax = first callfar place
lea ax,[si+jumpDist]
mov al,0xA2

;; copy loop code 
add si,@copy 			
push ss
pop es					
mov cl,(@copy_end - @copy)/0x2 	
movsb
rep movsw 				

mov bx,di
stosw 					;;write to [bx] adr in ax
movsw					;;write to [bx+2] magicseg


mov cl,0x4
shl dx,cl

mov bp,callDist
add bp,dx

push si
add si,0x2
and ah,0x0F
xor al,al
xchg al,ah
add si,ax
mov al,[si]
pop si

push ss
pop ds					;; ds = StackSeg


mov word [bx+0xc6],0xd3
mov word [bx+0xd3],0xeb
mov word [bx+0xeb],0x25
mov word [bx+0x25],0x9d
mov word [bx+0x9d],0xd6
mov word [bx+0xd6],0x3a
mov word [bx+0x3a],0x52
mov word [bx+0x52],0x73
mov word [bx+0x73],0x79
mov word [bx+0x79],0x4b
mov word [bx+0x4b],0x4e
mov word [bx+0x4e],0xf6
mov word [bx+0xf6],0x7b
mov word [bx+0x7b],0xf2
mov word [bx+0xf2],0x27
mov word [bx+0x27],0xc6


les di,[bx]								;;es = magicseg, di = first callfar adr
mov word [bx + deltaSp_loc],deltaSp		;; store the value deltaSp in es in some distance after our copied code and callfar loc (according to si so we could do: add sp,[bx+si] in the loop)

push cs
pop ds					;; ds = Arena
			
movsw					;; write callfar to the address

mov cl,(@end_loop_section - @loop_section)/0x2
dec di
xor si,si 				

push ss					
pop ds					;; ds = StackSeg

push cs
pop ss					;; ss = Arena

mov sp,[bx]				;; sp = ax = callfar adr
add sp,callDist			;; sp = ax + calldist

call far [bx+si]			;; execute callfar

;;;;;;;;;;;;;;;;;;;;;;;;;; END OF REGULAR CODE

@copy:
movsw
rep movsw				;; write our code

@loop_section:

add [bx+0x1],al				;; change callfar place (bx += ax)
xlatb
les di,[bx]				;; di = callfar address
lea sp,[di+bp]
mov cl,(@end_loop_section - @loop_section)/0x2			;; reset counter for next time we execute "rep movsw" 
movsw					;; write callfar in the next address (address = [bx] = di)
dec di
xor si,si				;; reset si (si = 0x0000)
call far [bx+si]
@end_loop_section:
call far [bx+si]
@copy_end:
dw 0xcccc  			;;for movsw in the beginning 
call far [bx+si]		;; will be the first callfar to run

@random_jump:
db 0xd3
db 0xeb
db 0x25
db 0x9d
db 0xd6
db 0x3a
db 0x52
db 0x73
db 0x79
db 0x4b
db 0x4e
db 0xf6
db 0x7b
db 0xf2
db 0x27
db 0xc6