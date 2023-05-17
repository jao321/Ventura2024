def hamming_distance(string1, string2): 
    # Start with a distance of zero, and count up
    distance = 0
    # Loop over the indices of the string
    L = len(string1)
    for i in range(L):
        # Add 1 to the distance if these two characters are not equal
        if string1[i] != string2[i]:
            distance += 1
    # Return the final count of differences
    return distance


index = open("/Users/joaogervasio/Documents/projeto_covid_doutorado/Undetermined_S0/index.csv","r")

sample = {}

for x in index:
	tmp = x.strip().split(",")
	sample[tmp[1]+"+"+tmp[2]] = tmp[0]
	exec(tmp[0] + " = open(\"/Users/joaogervasio/Documents/projeto_covid_doutorado/Undetermined_S0/"+tmp[0]+"R2.fastq\",\"w\")")
index.close()

i7 = ["TAAGGCGA","CGTACTAG","AGGCAGAA","TCCTGAGC","GGACTCCT","TAGGCATG","CGAGGCTG"]
i5 = ["CTCTCTAT","TATCCTCT","AGAGTAGA","GCGTAAGA"]

# for x in sample:
# 	print(x,sample[x])

file = open("/Users/joaogervasio/Documents/projeto_covid_doutorado/Undetermined_S0/Undetermined_S0_L001_R2_001.fastq","r")

ct = 0


for x in file:
	if x.find("@M02832") != -1:
		tmp = x.strip().split(":")
		# tup = tmp[-1].split("+")[0][:-2]
		tmp = tmp[-1].split("+")
		forw = i7[0]
		for i in i7:
			if hamming_distance(tmp[0][:-2],i) < hamming_distance(tmp[0][:-2],forw):
				forw = i

		rev = i5[0]
		for i in i5:
			if hamming_distance(tmp[1][:-2],i) < hamming_distance(tmp[1][:-2],rev):
				rev = i
		if forw+"+"+rev in sample:
			exec(sample[forw+"+"+rev]+".write(x)")
	else:
		if forw+"+"+rev in sample:
			exec(sample[forw+"+"+rev]+".write(x)")


		