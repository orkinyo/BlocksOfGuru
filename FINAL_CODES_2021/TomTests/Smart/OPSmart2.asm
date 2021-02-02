%define SHARE_LOC 0x9EC4
%define CALL_DI_OPCODE 0x95FF

%define SHL_WRITE_DIST 0x70
%define SHL_CALL_ADDRESS 0xF8E2

%define LOOP_WRITE_DIST 0x72
%define LOOP_CALL_ADDRESS 0x8346

%define INIT_BP CALL_DI_OPCODE
%define DELTA_BP (0x4100 - INIT_BP)



push cs
pop ss
mov cl,0x26

xchg [SHARE_LOC],si
lea bx,[si + 0x8B]

lea bp,[bx + 0x100]
mov es,bp

mov bp,INIT_BP
mov sp,bp

mov di,0x7F90

@wait:
loop @wait

mov cx,CALL_DI_OPCODE

jmp si
