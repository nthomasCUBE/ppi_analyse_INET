import string
import sys
import xlwt

opt=sys.argv[1]

MM={}

fh=file("5_make_kruskal_wallis_test_OVERALL_%s.csv" % (opt))
for line in fh.readlines()[1:]:
	line=line.strip()
	vals=line.split(";")
	if(MM.get(vals[1])==None):
		MM[vals[1]]={}
	MM[vals[1]]["TOTAL"]=[vals[7],vals[8],vals[5]]

fh=file("5_make_kruskal_wallis_test_SINGLE_%s.csv" % (opt))
for line in fh.readlines()[1:]:
        line=line.strip()
        vals=line.split(";")
        if(MM.get(vals[1])==None):
                MM[vals[1]]={}
	if(MM[vals[1]].get("SINGLE")==None):
		MM[vals[1]]["SINGLE"]={}
	MM[vals[1]]["SINGLE"][vals[2]]=[vals[8],vals[9],vals[6]]

c_max=-1
for MM_ in MM:
	my_k=MM[MM_]["SINGLE"].keys()
	if(len(my_k)>c_max):
		c_max=len(my_k)

book=xlwt.Workbook(encoding="utf-8")
sheet1=book.add_sheet("Sheet 1")

x=0
sheet1.write(x,0,"AT id")
sheet1.write(x,1,"Pooled p.value wilcox")
sheet1.write(x,2,"Pooled p.value BH")
sheet1.write(x,3,"Pooled log-fold change")
for y in range(0,3*c_max,3):
	sheet1.write(x,y+4,"%s_%s_%s" % ("Sample",(y+1)/2,"p.value wilcox"))
        sheet1.write(x,y+5,"%s_%s_%s" % ("Sample",(y+1)/2,"p.value BH"))
        sheet1.write(x,y+6,"%s_%s_%s" % ("Sample",(y+1)/2,"log-fold change"))

x=x+1
y=0;
for MM_ in MM:
	arr=[]
	y=0
	sheet1.write(x,y,MM_);
	y=y+1

	sheet1.write(x,y,float(MM[MM_]["TOTAL"][0].replace(",",".")));
	y=y+1

	sheet1.write(x,y,float(MM[MM_]["TOTAL"][1].replace(",",".")));
	y=y+1

        sheet1.write(x,y,float(MM[MM_]["TOTAL"][2].replace(",",".")));
        y=y+1

	my_k=MM[MM_]["SINGLE"].keys()
	for my_k_ in my_k:
		sheet1.write(x,y,float(MM[MM_]["SINGLE"][my_k_][0].replace(",",".")));	y=y+1
		sheet1.write(x,y,float(MM[MM_]["SINGLE"][my_k_][1].replace(",",".")));	y=y+1
                sheet1.write(x,y,float(MM[MM_]["SINGLE"][my_k_][2].replace(",",".")));  y=y+1
	x=x+1
book.save("6_merge_results_%s.xls" % (opt))

