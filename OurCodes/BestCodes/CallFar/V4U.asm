;; Callfar V4 - Best in class

%define jumpDist 0x2E00
%define callAmount 0x80

%define callDist 0x4 * callAmount											;;distance the callfar loop will bomb on the board
%define deltaSp jumpDist + callDist										;;the amount sp needs to updated for next loop
%define deltaSp_loc @end_loop_section-@copy                          	;; the location in es where we store deltaSp (2 is for the 2 bytes of rep movsw)

;; si = ax
mov si,ax

;;write magicseg to the loc after the label @copy_end
and ax,0xf ;; 0<=ax<=0xf
add ax, 0xff6 ;; 0xff6 <= ax <= 0x1005
mov [si+@copy_end],ax	

;;ax = first callfar place
lea ax,[si+jumpDist]
mov al,0xA3

;; copy loop code 
add si,@copy 			
push ss
pop es					
mov cl,(@copy_end - @copy)/0x2 	
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

mov ax,jumpDist			;; ax = jumpDist

call far [bx+si]			;; execute callfar

;;;;;;;;;;;;;;;;;;;;;;;;;; END OF REGULAR CODE

@copy:
rep movsw				;; write our code

@loop_section:

add [bx],ax				;; change callfar place (bx += ax)

les di,[bx]				;; di = callfar address				

add sp,[bx+si]			;; change sp adress relative to next callfar address (sp += deltaSp)

movsw					;; write callfar in the next address (address = [bx] = di)

dec di					;; dx = [bx] + 0x1 (address of callfar + 0x1)

xor si,si				;; reset si (si = 0x0000)

mov cl,(@end_loop_section - @loop_section)/0x2			;; reset counter for next time we execute "rep movsw" 

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
