# creates txt files in the form of "db 0x12" of the survivors


path = "C:/Users/alond/Documents/בצפר/כיתה יא/codeGuru/corewars8086-survivors-master/corewars8086-survivors-master/cgx2019/phase2"
surv = "Candiru"

def main_func(path,surv):

    for i in [1,2]:
        f = open(f"{path}/{surv}{i}", 'rb')
        barr = bytearray(f.read())
        f.close()

        g = open(f"{surv}_fix{i}.txt", 'w+')
        # g.write(bytearray([10]))
        barr = barr[:512]
        for j in barr:
            #print(j,hex(j))
            g.write(f"db {hex(j)}\n")
        # print(surv, i, ':', barr[512])
        g.close()
        print("done", i)

    print("done")

def main():
    # path = "C:/Users/alond/Documents/בצפר/כיתה יא/codeGuru/corewars8086-survivors-master/corewars8086-survivors-master/cgx2019/phase2"
    # surv = "Mobius"
    print("enter path for surviver (full path to his folder)")
    path = input()
    path = path.replace("\\", '/')
    print("enter surv name (enter 'surv' if it's surv1 and surv2)")
    surv = input()
    main_func(path, surv)


if __name__ == '__main__':
    main()

