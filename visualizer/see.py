import sys
import json

my_data = json.loads(open("outputs/problem_1_initial_board.json").read())

x = len(my_data)
y = len(my_data[0])

print "%d, %d\n" % (x, y)

def convert(val):
	if (val == "E"): return "-"
	if (val == "F"): return "X"
	if (val == "U"): return "$"
	return "-"

def printSeparator(y):
	n = y * 2
	while n > 0:
  		n -= 1
  		sys.stdout.write("-"),
	print ""

def printHeader(y):
	z = 0
	n = y
	while n > 0:
  		n -= 1
  		print z % 10,
  		z += 1 
	print ""
	return

def printMap(map_data):
	for i, val in enumerate(map_data):
		if (i % 2 == 1): 
			sys.stdout.write(" ")
		else: 
			sys.stdout.write("")
		for j, row in enumerate(val):
			sys.stdout.write(convert(row) + " "),
		print ""	

#printHeader(y)
#printSeparator(y)
#printMap(my_data)
#printSeparator(y)

move = 0

def program_logic(line):
    global move,y,my_data
    move += 1
    print str(move) + ': ' + line.rstrip()
    printHeader(y)
    printSeparator(y)
    printMap(my_data)
    printSeparator(y)

    sys.stdout.flush()

def read_from_stdin():
    global line_count
    for line in sys.stdin:
        program_logic(line)

def prompt_user():
    print 'Type "quit" to exit.'
    while (True):
        line = raw_input('PROMPT> ')
        if line == 'quit':
            sys.exit()
        program_logic(line)

if __name__ == "__main__":
    if '-' in sys.argv:
        read_from_stdin()
    else:
        prompt_user()