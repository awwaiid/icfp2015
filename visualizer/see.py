import sys
import json
import time

my_data = json.loads(open("outputs/problem_1_initial_board.json").read())
move = 0

x = len(my_data)
y = len(my_data[0])

#print "%d, %d\n" % (x, y)

def convert(val):
	if (val == "E"): return "-"
	if (val == "F"): return "X"
	if (val == "U"): return "$"
	return "-"

def printSeparator(y):
	out = ''
	n = y * 2
	while n > 0:
  		n -= 1
  		out += '-'
	return out

def printHeader(y):
	out = ''
	z = 0
	n = y
	while n > 0:
  		n -= 1
  		out += str(z % 10) + " "
  		z += 1 
	return out

def printMap(map_data):
	out = ''
	for i, val in enumerate(map_data):
		if (i % 2 == 1): 
			out += " "
		for j, row in enumerate(val):
			out += convert(row) + " "
	return out

def program_logic(line):
    global move,y,my_data
    move += 1
    output = ''
    output += "Move: " + str(move) + ': ' + line.rstrip()
    #output += printHeader(y)
    #output += printSeparator(y)
    #output += printMap(my_data)
    #output += printSeparator(y)
    return output

def read_from_stdin():
    for line in sys.stdin:
        return program_logic(line)

def prompt_user():
    #line = raw_input('')
    line = 'test\nfound\nabc'
#    time.sleep(1)
#        if line == 'quit':
#            sys.exit()
    return program_logic(line)

if __name__ == "__main__":
	if '-' in sys.argv:
		out = read_from_stdin()
		sys.stdout.write(out)
	else:
		for i in range(20):
			#time.sleep(.2)
			out = prompt_user()

			sys.stdout.write("%s" % out)
			import subprocess as sp
			sp.call('clear',shell=True)
			#sys.stdout.flush()
			#out = prompt_user()    
	    #	sys.stdout.write("\r%d" % i)
	   # 	sys.stdout.flush()
