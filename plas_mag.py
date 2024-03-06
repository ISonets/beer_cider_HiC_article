infile1 = open("B25_clustering.mcl", "r")
infile2 = open("B25_good.csv", "r")
mag_info_file = open("B25_summary_bin3c.txt", "r")
infile3 = open("B25_plasmid_info.txt", "r")

cont_mag = dict()
bins = dict()
n = 1
for line in infile1:
    words = list(line.split())
    for word in words:
        cont_mag[word] = n
    bins[n] = set(words)
    n += 1

plas_dict = dict()
ver_q = set()
plas_names = set()
plasmid_dir = dict()

for line in infile3:
    words = line.split()
    cont = words[1].split("_")
    cont_name = cont[0] + '_' + cont[1]
    plas_dict[cont_name] = list([words[0], words[2], words[3:]])
    if words[0] in plasmid_dir.keys():
        plasmid_dir[words[0]].add(cont_name)
    else:
        plasmid_dir[words[0]] = set()
        plasmid_dir[words[0]].add(cont_name)
    plas_names.add(cont_name)

bin_info = dict()
good_bin = set()
for line in mag_info_file:
    words = line.split()
    if float(words[2]) >= 80 and float(words[3]) <= 5:
        tax = words[6].split(";")
        family = tax[4]
        gener = tax[5]
        num_bin = int(words[0].strip("CL"))
        bin_info[num_bin] = (float(words[2]), float(words[3]), family, gener)
        good_bin.add(num_bin)

mag = set(cont_mag.keys())

link_bin = dict()
n = 0
for line in infile2:
    #if n % 1000 == 0:
     #   print()
    #n += 1
    words = line.split(",")
    #print(cont_mag[words[0]])
    if words[0].strip('"') in mag:
        if words[1].strip('"') in plas_names:
            if words[1].strip('"') not in link_bin.keys():
                link_bin[words[1].strip('"')] = dict()
                link_bin[words[1].strip('"')][cont_mag[words[0].strip('"')]] = float(words[2])
            elif cont_mag[words[0].strip('"')] not in link_bin[words[1].strip('"')].keys():
                link_bin[words[1].strip('"')][cont_mag[words[0].strip('"')]] = float(words[2])
            else:
                link_bin[words[1].strip('"')][cont_mag[words[0].strip('"')]] = max(float(words[2]), link_bin[words[1].strip('"')][cont_mag[words[0].strip('"')]])
    if words[1].strip('"') in mag:
        if words[0].strip('"') in plas_names:
            if words[0].strip('"') not in link_bin.keys():
                link_bin[words[0].strip('"')] = dict()
                link_bin[words[0].strip('"')][cont_mag[words[1].strip('"')]] = float(words[2])
            elif cont_mag[words[1].strip('"')] not in link_bin[words[0].strip('"')].keys():
                link_bin[words[0].strip('"')][cont_mag[words[1].strip('"')]] = float(words[2])
            else:
                link_bin[words[0].strip('"')][cont_mag[words[1].strip('"')]] = max(float(words[2]), link_bin[words[0].strip('"')][cont_mag[words[1].strip('"')]])

outfile = open("B25_plas_mag.txt", "w")

num_bin = 0
num_plas_connect = 0
num_plas_many = 0
plas_f_mag_f = dict()

for key in link_bin.keys():
    num_bin = 0
    for bin in link_bin[key].keys():
        if link_bin[key][bin] >= 0.6 and bin in good_bin:
            num_bin += 1
            print(key, bin, link_bin[key][bin], cont_mag[key] == bin, plas_dict[key][0], plas_dict[key][1], plas_dict[key][2], *bin_info[bin], file=outfile, sep="\t")
            
    if num_bin > 0:
        num_plas_connect += 1
    if num_bin > 1:
        num_plas_many += 1
print('many', num_plas_many, 'only one ', num_plas_connect - num_plas_many)
outfile.close()
