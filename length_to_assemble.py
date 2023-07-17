path = "/Users/joaogervasio/Documents/projeto_covid_doutorado/LuWerneck_24_01_2023-380046667/FASTQ_Generation_2023-01-26_22_37_54Z-649784140/GV50/"
intersection = open(path+"ID.txt","r")
ID = []
for x in intersection:
    if x.find("M0") != -1:
        ID.append(x.strip())

f = open(path+"R2_len_pass.fastq","r")
out = open(path+"R2_same_sequences.fastq","w")
check = False
for x in f:
    if x.find("@M0") != -1:
        tmp = x.split(" ")[0].replace("@","")
        if tmp in ID:
            check = True
            out.write(x)
            ID.remove(tmp)
            continue
        else:
            check = False
    if check == True:
        out.write(x)