import os
import string
import sys

c_dir=sys.argv[1]

# ----------------------------------------------------------------------

my_except={}
my_except["TrayG64_16102017-30000spores4d.xlsx_sheet_1.txt"]=16
my_except["TrayG69_20112017-30000spores4d.xlsx_sheet_1.txt"]=16
my_except["TrayG70_27112017-30000spores4d.xlsx_sheet_1.txt"]=16
my_except["TrayG74_26022017-30000spores4d.xlsx_sheet_1.txt"]=16
my_except["TrayG15_20072015-30000spores4d copy.xlsx_sheet_2.txt"]=12
my_except["TrayG72_11122017-30000spores4d.xlsx_sheet_1.txt"]=16
my_except["TrayG66_30102017-30000spores4d.xlsx_sheet_1.txt"]=16
my_except["TrayG68_13112017-30000spores4d.xlsx_sheet_1.txt"]=16
my_except["TrayG71_04122017-30000spores4d.xlsx_sheet_1.txt"]=16
my_except["TrayG67_06112017-30000spores4d.xlsx_sheet_1.txt"]=16
my_except["TrayG73_11122017-30000spores4d.xlsx_sheet_1.txt"]=16
my_except["TrayG56_11072017-30000spores4d.xlsx_sheet_1.txt"]=11
my_except["TrayG27_02052016_30000Spores_4d.xlsx_sheet_1.txt"]=13
my_except["TrayG65_23102017-30000spores4d.xlsx_sheet_1.txt"]=16
my_except["TrayG63_09102017-30000spores4d.xlsx_sheet_1.txt"]=16

f_elements={}

# ----------------------------------------------------------------------

print(c_dir)
files=os.listdir(c_dir)
#os.system("mkdir "+c_dir+"/PARSED")
fw=file(c_dir+"/1_restructure_content.txt","w")
fw2=file(c_dir+"/1_restructure_content_ignored.txt","w")
for files_ in files:
	cur_f=c_dir+"/"+files_
	fh=file(cur_f)
	has_entry=False
	for line in fh.readlines():
		line=line.strip()
		line=line.replace("\"","")
		vals=line.split("\t")
		if(f_elements.get(files_)==None):
			f_elements[files_]={}
		f_elements[files_][len(vals)]=1
		if(not(vals[0] in ["NA","NA.","Line","lines","seed line","LSD","seed.line","G48"])):
			rr=[]
			rr.append(files_.replace(" ","_"))
			do_ignore=False
                        vals[0]=vals[0].replace("Col-0M","Wt")
                        vals[0]=vals[0].replace("Col-0 (Mix)","Wt")
                        vals[0]=vals[0].replace("Col-0 ","Wt")
                        vals[0]=vals[0].replace("Col-0","Wt")
                        vals[0]=vals[0].replace("col-0 ","Wt")
                        vals[0]=vals[0].replace("col-0","Wt")
                        vals[0]=vals[0].replace("Col","Wt")
			rr.append(vals[0])
			for x in range(1,41):
				if(x<len(vals)):
					rr.append(vals[x])
					try:
						if(vals[x]!="NA"):
							float(vals[x])
					except Exception:
						do_ignore=True
				else:
					rr.append("NA")
			if(do_ignore==False):
				fw.write(string.join(rr,"\t")+"\n")
				has_entry=True
			else:
				fw2.write(line+"\n")
	if(not(has_entry)):
		print(files_),len(vals)

fw.close()
fw2.close()

fw=file(c_dir+"/1_restructure_elements_per_file.txt","w")
for f_element in f_elements:
	nmb=f_elements[f_element].keys()
	fw.write("%s\t%i\t%i\t%i\n" % (f_element,min(nmb),nmb[len(nmb)/2],max(nmb)))
fw.close()
