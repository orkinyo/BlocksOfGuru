;; V4U - Callfar V4 - Best in class
;; V4UB - added movsb instead of movsw (kills better)

%define jumpDist 0x5200
%define callAmount 0x84

%define callDist 0x4 * callAmount											;;distance the callfar loop will bomb on the board
%define deltaSp jumpDist + callDist										;;the amount sp needs to updated for next loop
%define deltaSp_loc (@end_loop_section-@copy)                          	;; the location in es where we store deltaSp (2 is for the 2 bytes of rep movsw)

%define cf_offset (@end_loop_section-@copy)


;; si = ax
mov si,ax

;;write magicseg to the loc after the label @copy_end
mov cl,0xf
div cx ;; dx = reminder
add dx,0xff6 ;; 0xff6 <= dx <= 0x1004

mov [si+@copy_end],dx	

;;ax = first callfar place
lea ax,[si+jumpDist]
mov al,0xA1

;; copy loop code 
add si,@copy 			
push ss
pop es					
mov cl,(@copy_end - @copy)/0x2 	
rep movsw 				

;; bx = readcallfar adr
add di,0x10
mov bx,di
add di,cf_offset

stosw 					;;write to [bx] adr in ax
movsw					;;write to [bx+2] magicseg

push ss
pop ds					;; ds = StackSeg

les di,[bx+cf_offset]
mov word [bx],0x2								;;es = magicseg, di = first callfar adr
mov word [bx + deltaSp_loc-0x2],deltaSp		;; store the value deltaSp in es in some distance after our copied code and callfar loc (according to si so we could do: add sp,[bx+si] in the loop)

mov dx,jumpDist			;; ax = jumpDist
mov ax,0xA490
mov bp,callDist

push cs
pop ds					;; ds = Arena
			
movsw					;; write callfar to the address
movsb

mov cl,(@end_loop_section - @loop_section)/0x2
sub di,0x2					;; di = adr + 0x1
xor si,si 				

push ss					
pop ds					;; ds = StackSeg

push cs
pop ss					;; ss = Arena

mov sp,[bx+cf_offset]				;; sp = ax = callfar adr
add sp,callDist			;; sp = ax + calldist

call far [bx+si+cf_offset]			;; execute callfar

;;;;;;;;;;;;;;;;;;;;;;;;;; END OF REGULAR CODE

@copy:
movsw
rep movsw				;; write our code

@loop_section:

add [bx+si],dx				;; change callfar place (bx += ax)
add dh,[bx+si]
les di,[bx+si]				;; di = callfar address
lea sp,[di+bp]
mov cx,(@end_loop_section - @loop_section)/0x2			;; reset counter for next time we execute "rep movsw" 
movsw					;; write callfar in the next address (address = [bx] = di)
movsb
sub di,[bx]					;; dx = [bx] + 0x1 (address of callfar + 0x1)
xor si,si				;; reset si (si = 0x0000)
call far [bx+si+cf_offset]

@end_loop_section:
call far [bx+si+cf_offset] 		;; being copied by movsw for next callfar cycle
@copy_end:
dw 0xcccc  			;;for movsw in the beginning 
call far [bx+si+cf_offset]		;; will be the first callfar to run 
