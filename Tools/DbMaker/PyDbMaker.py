# creates txt files in the form of "db 0x12" of the survivors
import os

path = os.environ['UserProfile'] + "\\codegurumaster\\codegurubyteme\\UsefullShit\\"
surv = "Candiru"

enter_path = False #by default


def funcifunc(path,surv : str):
    last_87 = False
    if surv.endswith("1") or surv.endswith("2"):
        print("survivor name ends with 1/2")
        surv = surv[:-1]
        for i in [1,2]:
            if not os.path.exists(f"{path}/{surv}{i}"):
                continue
            print(f"opening file: {path}/{surv}{i}")
            f = open(f"{path}/{surv}{i}", 'rb')
            barr = bytearray(f.read())
            f.close()

            g = open(f"{path}/{surv}_fix{i}.txt", 'w+')
            # g.write(bytearray([10]))
            barr = barr[:512]
            for idx,j in enumerate(barr):
                if last_87:
                    g.write(f"db {hex(0x87)}\n")
                    g.write(f"db {hex(0xdb)}\n")
                    last_87 = False
                elif j != 0xcd:
                    g.write(f"db {hex(j)}\n")
                    last_87 = False
                elif idx != len(barr) -1 and barr[idx+1] == 0x87:
                    last_87 = True
                else:
                    g.write(f"db {hex(j)}\n")
                    last_87 = False
            # print(surv, i, ':', barr[512])
            g.close()
            print("done", i)

        print("done")
        return 
    
    #arrived here = surv not finished with 1/2
    
    elif os.path.exists(f"{path}//{surv}"):
        f = open(f"{path}/{surv}{i}", 'rb')
        print(f"opening file: {path}/{surv}{i}")
        barr = bytearray(f.read())
        f.close()
        g = open(f"{path}/{surv}_fix{i}.txt", 'w+')
        # g.write(bytearray([10]))
        barr = barr[:512]
        for idx,j in enumerate(barr):
            if last_87:
                g.write(f"db {hex(0x87)}\n")
                g.write(f"db {hex(0xdb)}\n")
                last_87 = False
            elif j != 0xcd:
                g.write(f"db {hex(j)}\n")
                last_87 = False
            elif idx != len(barr) -1 and barr[idx+1] == 0x87:
                last_87 = True
            else:
                g.write(f"db {hex(j)}\n")
                last_87 = False
        # print(surv, i, ':', barr[512])
        g.close()
        return
        
    else:
        for i in [1,2]:
            if not os.path.exists(f"{path}/{surv}{i}"):
                print(f"didnt find file: {path}/{surv}{i}")
                continue
            f = open(f"{path}/{surv}{i}", 'rb')
            print(f"opening file: {path}/{surv}{i}")
            barr = bytearray(f.read())
            f.close()

            g = open(f"{path}/{surv}_fix{i}.txt", 'w+')
            barr = barr[:512]
            for idx,j in enumerate(barr):
                if last_87:
                    g.write(f"db {hex(0x87)}\n")
                    g.write(f"db {hex(0xdb)}\n")
                    last_87 = False
                elif j != 0xcd:
                    g.write(f"db {hex(j)}\n")
                    last_87 = False
                elif idx != len(barr) -1 and barr[idx+1] == 0x87:
                    last_87 = True
                else:
                    g.write(f"db {hex(j)}\n")
                    last_87 = False
            g.close()
            print("done", i)

        print("done")
        return 
    
    
                    

def main():
    global enter_path
    if(enter_path):
        print("enter path for surviver (full path to his folder)")
        path = input()
        path = path.replace("\\", '/')    
    print("enter surv name - if name doesnt end with 1/2 and only one surv - will take 1 and if doesnt exist then 2:")
    surv = input()
    if surv.rfind("\\") == -1:
        print("it appeares you have not entered a path, please enter full path to surv! (y/n)")
        path = input()
        path = path.replace("\\", '/')    
        enter_path = True
    if not enter_path:
        path = surv[:surv.rfind("\\")]
        surv = surv[surv.rfind("\\"):]
    funcifunc(path, surv)


if __name__ == '__main__':
    main()

