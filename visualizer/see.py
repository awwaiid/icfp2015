import sys
import json

my_data = json.loads(open("./empty.json").read())

x = len(my_data)
y = len(my_data[0])

print "%d, %d\n" % (x, y)


def convert(val):
	if (val == "E"): return "O"
	if (val == "F"): return "*"
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
  		print z,
  		z += 1 
	print ""
	return

printHeader(y)
printSeparator(y)
for i, val in enumerate(my_data):
	if (i % 2 == 1): 
		sys.stdout.write(" ")
	else: 
		sys.stdout.write("")
	for j, row in enumerate(val):
		sys.stdout.write(convert(row) + " "),
	print ""

printSeparator(y)