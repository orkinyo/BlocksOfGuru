import sys
import os
import _thread as thread
from sys import argv
import time
import threading
from multiprocessing import Process, Lock, Queue, Pool





def handle_input():
    """ get arguments from command line
    argv[1] = location of corewars engine directory, assumes it includes 'survivors', 'zombies' directory (full path to directory)
    and survivors to tune
    argv[2] = survivor to tune name - if it's two survivors just give the name and the programa will add 1 and 2 else name is withuot 1
    argv[3] = numbers of survivors to tune
    argv[4] = number of threads to run
    argv[5] = how many wars to run
    argv[6] = string to tune
    argv[7] optional - min value to tune
    argv[8] optional - max value to tune
    argv[9] optional - jmp value
    function returns (director of corewars engine, file handle to surv1,file handle to surv2(if needed),threads number,how many wars, string to tune, min value, max value, jmp value,surv_name) """

    dir = r"C:\Users\orkin\Documents\codeguru-cgxrunner\corewars8086-4.0.2" #argv[1] #running directory
    print(dir)
    surv_num = 2 #int(input("please enter num of surv")) #number of survivors per group - 1 or 2
    surv_name = "H" #input("please enter surv name") if its surv1 and surv2 just enter surv
    threads = 1 #int(input("enter num threads"))
    wars = 10 #int(input("enter num wars"))
    val_name = "var" #input("enter var name")
    min = 14 #int(input("enter min val")) in decimal!!!
    max = 15 #int(input("enter max val")) in decimal!!!
    jmp = 1 #int(input("enter jmp val")) in decimal!!!
    if (surv_num == 1):
        surv_1 = open(rf"{dir}\\{surv_name}.asm", "r")
        return dir, rf"{dir}/{surv_name}.asm", None, threads, wars, val_name, min, max, jmp, surv_name
    elif surv_num == 2:
        return dir, rf"{dir}/{surv_name}1.asm", rf"{dir}/{surv_name}2.asm", threads, wars, val_name, min, max, jmp, surv_name

def run_all(directory, surv1, surv2, num_threads, how_many_wars, var_name, min_val, max_val, jmp_val,team_name):
    num_of_runs = int((max_val - min_val) / jmp_val)+1
    print(f"will run {num_of_runs} times")
    counter = 1
    current_val = min_val
    for i in range(num_of_runs):
        create_temps_and_compile_and_run(directory,surv1,surv2,var_name,current_val,team_name,how_many_wars,counter)
        time.sleep(1)
        current_val+=jmp_val
        counter+=1
    sum_score(directory,num_of_runs,team_name,min_val,jmp_val,var_name)










def create_temps_and_compile_and_run(directory, surv_1_path, surv_2_path, var_name, val, team_name, how_many_wars, run_number):
    temp_1 = open(rf'{directory}\temp1.asm', "w+")
    surv_1 = open(surv_1_path,'r')

    if surv_2_path != None:
        temp_2 = open(rf'{directory}\temp2.asm', "w+")
        surv_2 = open(surv_2_path, 'r')
        for line in surv_1:
            if line.startswith(f"%define {var_name}"):
                temp_1.write(f"%define {var_name} {val}\n")
            else:
                temp_1.write(line)
        for line in surv_2:
            if line.startswith(f"%define {var_name}"):
                temp_2.write(f"%define {var_name} {val}\n")
            else:
                temp_2.write(line)
        temp_1.close()
        temp_2.close()
        print(f"will now do - nasm temp1.asm -o ./survivors/{team_name}1")
        os.system("nasm " + rf"temp1.asm" + rf" -o ./survivors/" + team_name + "1")
        time.sleep(1)
        print(f"will now do - nasm temp1.asm -o ./survivors/{team_name}2")
        os.system("nasm " + rf"temp2.asm" + rf" -o ./survivors/" + team_name + "2")

        os.remove(fr"{directory}\temp1.asm")
        os.remove(fr"{directory}\temp2.asm")
        start_cgx_engine(how_many_wars,run_number)


        os.remove(fr"{directory}\survivors\{team_name}1")
        os.remove(fr"{directory}\survivors\{team_name}2")


    else:
        for line in surv_1:
            if line.startswith(f"%define {var_name}"):
                temp_1.write(f"%define {var_name} {val}\n")
            else:
                temp_1.write(line)
        temp_1.close()
        print(f"will now do - nasm temp1.asm -o ./survivors/{team_name}")
        os.system("nasm " + rf"temp1.asm" + rf" -o ./survivors/" + team_name )

        os.remove(fr"{directory}\temp1.asm")

        start_cgx_engine(how_many_wars,run_number)
        os.remove(fr"{directory}\survivors\{team_name}")






def start_cgx_engine(how_many_wars, run_number):
    print(f"run_number: {run_number} started")
    os.system("ByteSilent.bat -fn" +f" {run_number}.csv" + " -wpc 10")
    print(f"run_number: {run_number} finished")

def sum_score(directory,max_num_file,team_name,min_val,jmp_val,var_name):
    best_val = -1
    best_score = -1
    for i in range(1, max_num_file+1):
        try:
            path = rf"{directory}\\{str(i)}.csv"
            file = open(path, 'r')
            result = file.read().split('\n')
            foundteam = 0
            while foundteam == 0:
                for row in result:
                    if row.startswith(team_name):
                        score = float(row.split(',')[1])
                        if (score >= best_score ):
                            best_score = score
                            best_val = min_val+(i-1)*jmp_val
                        foundteam = 1
                        break
            file.close()
            os.remove(str(i) + '.csv')
        except:
            print(f"can't find " + f"{directory}/{str(i)}" + ".csv")
    with open(f"{directory}/results.txt", 'w') as resultsfile:
        resultsfile.write("variable: " + var_name + "\nvalue: " +f"{best_val}"  + "\nscore: " + str(best_score))
        resultsfile.close()
    print("everything finished")


def main():
    parameters = handle_input()
    print("starting")
    run_all(*parameters)


if __name__ == '__main__':
    lock = Lock()
    main()
    exit()



