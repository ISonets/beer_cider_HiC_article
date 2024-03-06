import sys
import os

infile1 = open(sys.argv[1], "r")
infile2 = open(sys.argv[2], "r")
mag_info_file = open(sys.argv[3], "r")

cont_mag = dict()
bins = dict()
n = 1
for line in infile1:
    words = list(line.split())
    for word in words:
        cont_mag[word] = n
    bins[n] = set(words)
    n += 1

bin_info = dict()
good_bin = set()
for line in mag_info_file:
    words = line.split()
    num_bin = int(words[0].strip("CL"))
    if float(words[2]) >= 80 and float(words[3]) <= 5.5:
        good_bin.add(num_bin)

outfile = open(sys.argv[4], "w")
outfile1 = open(sys.argv[5], "w")
cont = cont_mag.keys()
for line in infile2:
    if n % 1000 == 0:
        print(n)
    words = line.split()
    if words[1] in cont and cont_mag[words[1]] in good_bin and words[2] in cont and cont_mag[words[2]] in good_bin:
        print(words[1], words[2], words[0], sep="\t", file=outfile)
    print(words[1], words[2], words[0], sep="\t", file=outfile1)
outfile.close()
outfile1.close()
