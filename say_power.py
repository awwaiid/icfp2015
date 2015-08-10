#!/usr/bin/python 

import sys
import json
import itertools

w = ['p', '\'', '!', '.', '0', '3']
e = ['b', 'c', 'e', 'f', 'y', '2']
sw = ['a', 'g', 'h', 'i', 'j', '4']
se = ['l', 'm', 'n', 'o', ' ', '5']
r = ['d', 'q', 'r', 'v', 'z', '1']
p = ['k', 's', 't', 'u', 'w', 'x']
# \t, \n, \r  (ignored)

json_data = open('power_phrases.json')
phrases = json.load(json_data)

chars_p = []
for k,item in enumerate(phrases):
	chars_p.append([])
	chars = []
	for a in item:
		if a in w:
			chars.append(w)
		if a in e:
			chars.append(e)
		if a in sw:
			chars.append(sw)
		if a in se:
			chars.append(se)
		if a in r:
			chars.append(r)
		if a in p:
			chars.append(p)
	if chars:
		matches = []
		for element in itertools.product(*chars):
			matches.append(''.join(list(element)))
		chars_p[k] = matches

#for (i, item) in enumerate(chars_p):
#	print i, phrases[i], len(item)

#print chars_p[0]

def convert(line):
	phrase_count = 0
	newline = line
	for i,p in enumerate(phrases):
		for a in chars_p[i]:
			newline = newline.replace(a, p);
		phrase_count += newline.count(p);
	return newline + "," + str(phrase_count)

for line in sys.stdin:
	newline = convert(line.strip('\n'))
	print newline





