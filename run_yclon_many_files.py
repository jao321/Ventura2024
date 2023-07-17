import os


path_files = os.getcwd()

root_dir = '/Users/joaogervasio/Documents/projeto_covid_doutorado/covidao'
tsv_files = []

for dirname, dirnames, filenames in os.walk(root_dir):
    for filename in filenames:
        tsv_files.append(os.path.join(dirname, filename))
  
tsv_files = [file for file in tsv_files if file.endswith('.tsv.gz')]

YClon = "/Users/joaogervasio/Documents/YClon/YClon.py"

# files = os.listdir(path_files)


for x in tsv_files:
	if x.find(".tsv.gz") != -1:
		os.system("gzip -d "+os.path.join(path_files,x))
		os.system("python3 "+YClon+" --input "+os.path.join(path_files,x).replace(".gz",""))