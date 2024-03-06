import sys
import os

# do with argparse later
hic, wgs, assembly, output = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
fa_files = [f for f in os.listdir(hic) if f.endswith('.fna')]
wgs_files = [f for f in os.listdir(wgs) if f.endswith('.fa')]
infile2 = open(assembly, 'r', encoding='utf8')
outfile = open(output, 'w', encoding='utf8')
a = set()
h = 0
all_len = 0
no_len = 0
no_bin = False

for file in fa_files:
	infile = open(hic +'/'+file, 'r')
	
	for line in infile:
		h += line.count('>')

w = 0
for file in wgs_files:
	infile = open(wgs + '/'+file, 'r')
	for line in infile:
		w += line.count('>')

a = 0
for line in infile2:
    a += line.count('>')
    
print (100*h/a, 'bin3c', file=outfile)
print (100*w/a, 'metabat', file=outfile)
print(h/w, 'hic/wgs', file=outfile)

outfile.close()
