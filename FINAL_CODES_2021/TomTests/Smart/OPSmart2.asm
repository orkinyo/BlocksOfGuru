%define SHARE_LOC 0x9EC4
%define CALL_DI_OPCODE 0x55FF

%define SHL_WRITE_DIST 0x70
%define SHL_CALL_ADDRESS 0xFFE2

%define LOOP_WRITE_DIST 0x72
%define LOOP_CALL_ADDRESS 0x46


push cs
pop ss

xor ax,ax
xchg si,[SHARE_LOC]
lea bx,[si + 0x78]

push si
xor si,si

mov bp,CALL_DI_OPCODE
mov es,bp

mov bp,0xC100

mov cl,0x24

@wait:
loop @wait

mov ch,0x82
mov di,cx

ret