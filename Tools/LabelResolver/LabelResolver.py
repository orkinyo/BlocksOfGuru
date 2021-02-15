import os
import sys
import struct #for unpacking from little indian
SURVIVORS = ["",""]
SURVSLINES = [None,None]
nasm_input_file = "LabelResolveFile.asm"
nasm_output_file = "LabelResolveFile"



def backup():

    dir = os.path.dirname(os.path.realpath(__file__))
    for i in (1,2):
        with open(SURVIVORS[i-1],"r") as f:
            d = f.read()
            
        basename = os.path.basename(SURVIVORS[0])
        backup = os.path.join(dir,"Backup",basename)
        with open(backup,"w+") as f:
            f.write(d)
    
    
    
def replace_label(label_name : str, surv_index : int, value: str, line_index: int):
    line = SURVSLINES[surv_index][line_index]
    lines = line.split()

    #DEBUG
    #print(lines,f"{value=}")
    #DEBUG

    if len(lines) == 2:
        lines.append(value + "\n")
    else:
        lines[2] = value + "\n"

    SURVSLINES[surv_index][line_index]  = " ".join(lines)


def resolve_label(label_name : str,surv_index:int ):
    """returns value of label_name
    label_name = LB_actual_label_name"""

    lines = SURVSLINES[surv_index]
    lines.append(f"\nmov ax, @{label_name[3:].lower()}")
    new_file_lines = "".join(lines)
    lines.pop(-1)

    with open(nasm_input_file,"w") as f:
        f.write(new_file_lines)

    os.system(f"nasm {nasm_input_file} -o {nasm_output_file}")
    with open(nasm_output_file,"rb") as f:
        resolve_data = f.read()
    #os.system(f"del {nasm_input_file}")
    #os.system(f"del {nasm_output_file}")
    os.remove(os.path.join(os.getcwd(),nasm_output_file))
    os.remove(os.path.join(os.getcwd(),nasm_input_file))
    value = resolve_data[-3:]

    #DEBUG
    #print(value)
    #DEBUG

    value = struct.unpack("H",value[1:])[0]

    return value







def fix_lables(file_index : int):
    """:parameter index in SURVIVORS list
        fixes LB_ defines in the SURVIVORS[file_index] file"""
    prefix = "define LB"
    define_lables = []
    define_indexes = []
    surv_get_from_index : int = file_index -1



    for idx,line in enumerate(SURVSLINES[file_index]):
        if line.startswith("%define"):
            line = (line.split())
            if line[1].startswith("LB_"):
                define_lables.append(line[1])
                define_indexes.append(idx)

                #DEBUG
                #print(f"found: {' '.join(line)}")
                #DEBUG

    #DEBUG
    #print(f"\n\nFound {len(define_lables)} lables to fix in {SURVIVORS[file_index]}\n\n")
    #DEBUG

    for i,label in enumerate(define_lables):
        line_idx_in_surv_to_fix = define_indexes[i]
        define_value = resolve_label(label,file_index-1)
        replace_label(label,file_index,f"0x{hex(define_value)[2:].upper()}",line_idx_in_surv_to_fix)



def read_files():
    for idx,name in enumerate(SURVIVORS):
        with open(name,"r") as f:
            SURVSLINES[idx] = f.readlines()

def create_survivor_names(surv_name : str):
    """:parameter = name of one of the survivors to be checked
        :returns -> sets the global list SURVIVORS to the correct survivors names"""
    global SURVIVORS
    surv_name_no_file_ext: str = surv_name[:-4] # without ".asm"
    if not os.path.exists(surv_name):
        print(f"CANT FIND FILE {surv_name}")
        sys.exit(1)
    if surv_name_no_file_ext.endswith("1") or surv_name_no_file_ext.endswith("2"):
        
        for i in (1,2):
            
            if not os.path.exists(surv_name_no_file_ext[:-1]+f"{i}.asm"):
                print(f"CANT FIND FILE {surv_name_no_file_ext[:-1]}{i}.asm")
                sys.exit()

            SURVIVORS[i-1] = surv_name_no_file_ext[:-1]+f"{i}.asm"

    else:
        print("Enter a surv name that ends with 1")
        sys.exit()



def write_output():
    for idx, file_name in enumerate(SURVIVORS):
        with open(f"{file_name[:-5]}{file_name[-5]}.asm","w+") as f:
            f.write("".join(SURVSLINES[idx]))


def main():
    # print("drag surv file, either surv1 or surv2 is good, make sure they are at the same directory")
    surv_name = input()
    create_survivor_names(surv_name)
    backup()
    read_files()
    fix_lables(0)
    fix_lables(1)
    write_output()
    print("Label Resolver succeeded!")



if __name__ == '__main__':
    main()


