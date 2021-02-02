from os import system, path
import sys


if not sys.argv[1].endswith('.asm'):
	exit()

name = sys.argv[1].replace('.asm', '')[:-1]
bool = False


if path.exists(name + '1.asm'):
	system('nasm ' + name + '1.asm')
	bool = True

if path.exists(name + '2.asm'):
	system('nasm ' + name + '2.asm')
	bool = True
	
if path.exists(name + '.asm') and not bool:
	system('nasm ' + name + '.asm')