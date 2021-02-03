; AX = GARBAGE
; BX = ARRAY
; CX = CHANGE XCHG ORDER (0x702) / CALL DI OPCODE
; DX = GARBAGE
; SI = GARBAGE
; DI = LOCATION FOR TAKING ZOMBIES
; BP = LOCATION FOR BOMBING / GARBAGE
; SP = INIT BP
; ES = ZOMBIE JUMP LOCATION
; SS = ARENA
; DS = ARENA
; CS = ARENA

;; GENRAL DEFINES
%define SHARE_LOC 0x9EC4
;;
;; ZOMBIE DEFINES
%define CALL_DI_OPCODE 0x95FF

%define SHL_WRITE_DIST 0x70
%define SHL_CALL_ADDRESS 0xF8E2

%define LOOP_WRITE_DIST 0x72
%define LOOP_CALL_ADDRESS 0x8346

%define INIT_BP 0xC7AF
%define DELTA_BP (0xC100 - INIT_BP)
;;

add ax,@init_loop
push ax
xchg si,[SHARE_LOC]
;mov di,0x3FC
;stosw

;xchg si,[SHARE_LOC]
;push ax
jmp si


@init_loop:
push cs
pop ss
mov cx,CALL_DI_OPCODE
mov byte [bp],0xE9
mov [bp + 0x1],es
xor si,si
mov sp,bp

mov [bp + DELTA_BP + 0x700],ds
@loop:
mov [bp + DELTA_BP + 0x400],ds
mov [bp + DELTA_BP + 0x600],ds
mov [bp + DELTA_BP + 0x300],ds
mov [bp + DELTA_BP],ds
mov [bp + DELTA_BP + 0x100],ds
mov [bp + DELTA_BP + 0x200],ds

@xchg1:
xchg dx,[di + 0x270]
@xchg2:
xchg bp,[di + 0x470]
@xchg3:
xchg si,[di + 0x670]
@xchg4:
xchg ax,[di + 0x870]

xlatb
xchg al,ah
xlatb
xor ah,al
xchg si,ax
mov [si + SHL_WRITE_DIST],cx
mov [SHL_CALL_ADDRESS],sp


xlatb
xchg al,ah
xlatb
xor ah,al
xchg bp,ax
mov [bp + LOOP_WRITE_DIST],cx
mov [LOOP_CALL_ADDRESS],sp

xlatb
xchg al,ah
xlatb
xor ah,al
mov si,ax
mov [si + SHL_WRITE_DIST],cx
mov [SHL_CALL_ADDRESS],sp


xchg ax,dx
xlatb
xchg al,ah
xlatb
xor ah,al
mov si,ax
mov [si + LOOP_WRITE_DIST],cx
mov [LOOP_CALL_ADDRESS],sp

inc di
mov [SHL_CALL_ADDRESS],di
mov [LOOP_CALL_ADDRESS],di
jp @exit

mov bp,sp
inc byte [bx - @array + @xchg1 + 0x3]
inc byte [bx - @array + @xchg2 + 0x3]
and byte [bx - @array + @xchg3 + 0x3],0x6
and byte [bx - @array + @xchg4 + 0x3],0x6
inc byte [bx - @array + @xchg3 + 0x3]
inc byte [bx - @array + @xchg4 + 0x3]
mov byte [bp],0xE9
mov [bp + 0x1],es

jmp @loop

@exit:
mov al,0x99
xchg ax,[bx - 0x4]

cmp al,0x99
jnz @skip_seg

mov ax,[bx - 0x2]

@skip_seg:
mov ss,ax

mov sp,0x3FA

ret

dw 0x0000
dw 0x0000
@array:
db 0x00
db 0x2e
db 0x88
db 0xa6
db 0x2b
db 0x05
db 0xa3
db 0x8d
db 0x93
db 0xbd
db 0x1b
db 0x35
db 0xb8
db 0x96
db 0x30
db 0x1e
db 0x4e
db 0x60
db 0xc6
db 0xe8
db 0x65
db 0x4b
db 0xed
db 0xc3
db 0xdd
db 0xf3
db 0x55
db 0x7b
db 0xf6
db 0xd8
db 0x7e
db 0x50
db 0xfa
db 0xd4
db 0x72
db 0x5c
db 0xd1
db 0xff
db 0x59
db 0x77
db 0x69
db 0x47
db 0xe1
db 0xcf
db 0x42
db 0x6c
db 0xca
db 0xe4
db 0xb4
db 0x9a
db 0x3c
db 0x12
db 0x9f
db 0xb1
db 0x17
db 0x39
db 0x27
db 0x09
db 0xaf
db 0x81
db 0x0c
db 0x22
db 0x84
db 0xaa
db 0x6a
db 0x44
db 0xe2
db 0xcc
db 0x41
db 0x6f
db 0xc9
db 0xe7
db 0xf9
db 0xd7
db 0x71
db 0x5f
db 0xd2
db 0xfc
db 0x5a
db 0x74
db 0x24
db 0x0a
db 0xac
db 0x82
db 0x0f
db 0x21
db 0x87
db 0xa9
db 0xb7
db 0x99
db 0x3f
db 0x11
db 0x9c
db 0xb2
db 0x14
db 0x3a
db 0x90
db 0xbe
db 0x18
db 0x36
db 0xbb
db 0x95
db 0x33
db 0x1d
db 0x03
db 0x2d
db 0x8b
db 0xa5
db 0x28
db 0x06
db 0xa0
db 0x8e
db 0xde
db 0xf0
db 0x56
db 0x78
db 0xf5
db 0xdb
db 0x7d
db 0x53
db 0x4d
db 0x63
db 0xc5
db 0xeb
db 0x66
db 0x48
db 0xee
db 0xc0
db 0x80
db 0xae
db 0x08
db 0x26
db 0xab
db 0x85
db 0x23
db 0x0d
db 0x13
db 0x3d
db 0x9b
db 0xb5
db 0x38
db 0x16
db 0xb0
db 0x9e
db 0xce
db 0xe0
db 0x46
db 0x68
db 0xe5
db 0xcb
db 0x6d
db 0x43
db 0x5d
db 0x73
db 0xd5
db 0xfb
db 0x76
db 0x58
db 0xfe
db 0xd0
db 0x7a
db 0x54
db 0xf2
db 0xdc
db 0x51
db 0x7f
db 0xd9
db 0xf7
db 0xe9
db 0xc7
db 0x61
db 0x4f
db 0xc2
db 0xec
db 0x4a
db 0x64
db 0x34
db 0x1a
db 0xbc
db 0x92
db 0x1f
db 0x31
db 0x97
db 0xb9
db 0xa7
db 0x89
db 0x2f
db 0x01
db 0x8c
db 0xa2
db 0x04
db 0x2a
db 0xea
db 0xc4
db 0x62
db 0x4c
db 0xc1
db 0xef
db 0x49
db 0x67
db 0x79
db 0x57
db 0xf1
db 0xdf
db 0x52
db 0x7c
db 0xda
db 0xf4
db 0xa4
db 0x8a
db 0x2c
db 0x02
db 0x8f
db 0xa1
db 0x07
db 0x29
db 0x37
db 0x19
db 0xbf
db 0x91
db 0x1c
db 0x32
db 0x94
db 0xba
db 0x10
db 0x3e
db 0x98
db 0xb6
db 0x3b
db 0x15
db 0xb3
db 0x9d
db 0x83
db 0xad
db 0x0b
db 0x25
db 0xa8
db 0x86
db 0x20
db 0x0e
db 0x5e
db 0x70
db 0xd6
db 0xf8
db 0x75
db 0x5b
db 0xfd
db 0xd3
db 0xcd
db 0xe3
db 0x45
db 0x6b
db 0xe6
db 0xc8
db 0x6e
db 0x40
@zomb_jump:
mov [SHL_CALL_ADDRESS],di
mov [LOOP_CALL_ADDRESS],di
@our_location:
mov ax,0xCCCC
jmp ax
@end: