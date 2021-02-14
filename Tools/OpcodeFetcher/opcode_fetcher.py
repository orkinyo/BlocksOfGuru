import os

instruction = None
# instruction = "xor si,si"


def get_instruction_details(instruction):

    with open("code.asm", "w") as f:
        f.write(instruction)

    os.system("nasm code.asm")
    with open("code", "rb") as f:
        opcode = f.read()

    os.system("ndisasm code > code_ndis.asm")
    with open("code_ndis.asm", "r") as f:
        inst = " ".join(" ".join(f.readline().split()).split()[2:])

    os.remove("code_ndis.asm")
    os.remove("code.asm")
    os.remove("code")
    return opcode, inst


def get_all_opcodes(inst):
    ans = []
    with open("all_opcodes.asm", "r") as f:
        for line in f.readlines():
            if inst in line:
                ans.append(line)

    return ans


def main():
    global instruction
    while True:
    
        if instruction is None:
            print("give me an instruction:")
            instruction = input()
        
        if instruction == "exit":
            return
        
        default_opcode, inst = get_instruction_details(instruction)
        # print(f"{inst=}")

        all_opcodes = get_all_opcodes(inst)

        w = "".join([f"{i:02x}".upper() for i in default_opcode])
        # print(w)

        for line in all_opcodes:
            if line.startswith(w):
                print("The default opcode is:")
                print(line)
                default_line = line
                break

        has_alt = False
        for line in all_opcodes:
            if line != default_line:
                
                if not has_alt:
                    print("The alternative opcodes are:")
                    has_alt = True
                opcode = line.split()[0]
                if len(opcode) == 4:
                    opcode = "dw 0x" + opcode[2:4] + opcode[:2]
                else:
                    opcode = "db 0x" + opcode
                print(line.strip() + "\t\t" + opcode)
        if has_alt:
            print("\n")
        instruction = None


if __name__ == "__main__":
    main()