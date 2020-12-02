;; V4U - Callfar V4 - Best in class
;; V4UB - added movsb instead of movsw (kills better)

%define jumpDist 0x2E00
%define callAmount 0x40

%define callDist 0x4 * callAmount											;;distance the callfar loop will bomb on the board
%define deltaSp jumpDist + callDist										;;the amount sp needs to updated for next loop
%define deltaSp_loc @end_loop_section-@copy                          	;; the location in es where we store deltaSp (2 is for the 2 bytes of rep movsw)

%define MAGIC_SEG_LOC 0xE901
%define FIRST_CALLFARIP_LOC 0x55BC

;; si = ax
mov si,ax

;;write magicseg to the loc afters the label @copy_end
mov cl,0xf
div cx ;; dx = 0<=reminder<=0xe
add dx,0xff6 ;; 0xff6 <= dx <= 0x1004

;#sharing the segment to second survivor
mov [MAGIC_SEG_LOC],dx

mov [si+@copy_end],dx

;;ax = first callfar place
lea ax,[si+jumpDist]
mov al,0xA2
;#sharing the first callfarloc to second survivor
mov [FIRST_CALLFARIP_LOC], ax


;; copy loop code 
add si,@copy 			
push ss
pop es					
mov cl,(@copy_end - @copy)/0x2 	
movsb
rep movsw 				

;; bx = readcallfar adr
mov bx,di

stosw 					;;write to [bx] adr in ax
movsw					;;write to [bx+2] magicseg

push ss
pop ds					;; ds = StackSeg

les di,[bx]								;;es = magicseg, di = first callfar adr
mov word [bx + deltaSp_loc],deltaSp		;; store the value deltaSp in es in some distance after our copied code and callfar loc (according to si so we could do: add sp,[bx+si] in the loop)

push cs
pop ds					;; ds = Arena
			
mov ax,jumpDist			;; ax = jumpDist

movsw					;; write callfar to the address

mov cl,(@end_loop_section - @loop_section)/0x2
dec di					;; di = adr + 0x1
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

add [bx],ax				;; change callfar place (bx += ax)
les di,[bx]				;; di = callfar address				
add sp,[bx+si]			;; change sp adress relative to next callfar address (sp += deltaSp)
mov cl,(@end_loop_section - @loop_section)/0x2			;; reset counter for next time we execute "rep movsw" 
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

@end_loop_section:
call far [bx+si] 		;; being copied by movsw for next callfar cycle
@copy_end:
dw 0xcccc  			;;for movsw in the beginning 
call far [bx+si]		;; will be the first callfar to run 
