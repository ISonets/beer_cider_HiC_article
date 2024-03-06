import sys
import os

#do with argparse later
hic, wgs, output1, output2 = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
wgs_files = [f for f in os.listdir(wgs) if f.endswith('.fa')]
infile1 = open(hic, 'r', encoding='utf8')
outfile1 = open(output1, 'w', encoding='utf8')
outfile2 = open(output2, 'w', encoding='utf8')

n = 1
for line in infile1:
	words = list(line.split())
	for word in words:
		print(word, n, sep="\t", file=outfile1)
	n += 1


for file in wgs_files:
	infile = open(wgs + '/'+file, 'r')
	for line in infile:
		if line[0] == ">":
			word = line.strip(">").split()
			print(*word, file, sep="\t", file=outfile2)
	
outfile1.close()
outfile2.close()
