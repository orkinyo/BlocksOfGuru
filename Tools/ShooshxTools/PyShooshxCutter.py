from pynput.mouse import Button, Controller
import keyboard as k
import pyperclip
import time
import webbrowser

def open_shoosh(arr, name):
    
    #       X             +  | player tag | 2 surv |edit name | focus on code|second surv    
    pos = [(123,211), (23,208), (71,257), (28,231), (221,126), (374,182), (75,282)]
    webbrowser.get("C:/Program Files (x86)/Google/Chrome/Application/chrome.exe %s").open_new(
        "https://shooshx.github.io/corewars8086_js/war/page.html")
    m = Controller()
    m.position = pos[0]  # X
    time.sleep(8)
    for i in range(4):
        m.click(Button.left, 4)
        time.sleep(0.15)
    m.position = pos[1] # +
    m.click(Button.left)
    m.position = pos[2] # Player tag
    m.click(Button.left)
    m.position = pos[3] # 2 survivers checkbox
    m.click(Button.left)
    m.position = pos[4] # edit player name
    m.click(Button.left, 3)
    k.write(f"\b{name}")
    time.sleep(0.3)
    m.position = pos[5] # focus on code section
    m.click(Button.left)
    pyperclip.copy(arr[0])
    k.send("ctrl+v")

    m.position = pos[6] # second surviver tag
    m.click(Button.left)
    m.position = pos[5] # focus on code section
    m.click(Button.left)
    pyperclip.copy(arr[1])
    k.send("ctrl+v")

    print("pressed")


def main_func(path, surv):
    arr = ["", ""]
    for i in range(1, 3):
        if surv == None:
            f = open(f"{path}{i}", 'rb')
        else:
            f = open(f"{path}/{surv}{i}", 'rb')
        barr = bytearray(f.read())
        f.close()

        for j in barr[:512]:
            arr[i - 1] += f"db {hex(j)}\n"

        print("d")

    open_shoosh(arr, surv)
    # print("done")


def main():
    # path = "C:/Users/alond/Documents/בצפר/כיתה יא/codeGuru/corewars8086-survivors-master/corewars8086-survivors-master/cgx2019/phase2"
    # surv = "Mobius"
    print("enter path for surviver (full path to his folder)")
    path = input()
    path = path.replace("\\", '/')
    print("enter surv name (enter 'surv' if it's surv1 and surv2)")
    surv = input()
    if surv == "" or surv == "\n":
        if path.endswith("1"):
            main_func(path[:-1],None)
    else:
        main_func(path, surv)
        
    print("finished")


if __name__ == '__main__':
    main()

