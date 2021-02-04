from os import listdir, system


for filename in listdir():
    if filename.endswith(".asm"):
        system(f'nasm {filename}')
