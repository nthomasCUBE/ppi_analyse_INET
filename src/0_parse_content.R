library(openxlsx)

options(stringsAsFactors=FALSE)

args = commandArgs(trailingOnly=TRUE)
c_f=args[1]
c_dir=args[2]

N=length(getSheetNames(c_f))
for(x in 1:N){
	data=read.xlsx(paste0(c_f),x)
	write.table(data,paste(c_dir,"/",basename(c_f),"_sheet_",x,".txt",sep=""),sep="\t",row.names=F)
}

