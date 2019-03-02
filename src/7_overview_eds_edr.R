library(xlsx)

options(stringsAsFactors=FALSE)
args = commandArgs(trailingOnly=TRUE)

data=read.csv(paste0("5_make_kruskal_wallis_test_SINGLE_",args[1],".csv"),sep=";",header=T)
u_gene=unique(data[,2])

d1=c(); d2=c(); d3=c(); d4=c()

for(x in 1:length(u_gene)){
	D=subset(data,data[,2]==u_gene[x])

	my_edr=subset(D,D[,"pval_adj_bonferroni"]<0.05 & D[,"phenotype"]=="edr")
        my_eds=subset(D,D[,"pval_adj_bonferroni"]<0.05 & D[,"phenotype"]=="eds")

        my_edr_all=subset(D,D[,"pval_adj_bonferroni"]<=1 & D[,"phenotype"]=="edr")
        my_eds_all=subset(D,D[,"pval_adj_bonferroni"]<=1 & D[,"phenotype"]=="eds")

	d1=c(d1,dim(my_edr)[1])
	d2=c(d2,dim(my_eds)[1])
	d3=c(d3,dim(my_edr_all)[1])
	d4=c(d4,dim(my_eds_all)[1])
}

df=data.frame(u_gene,"edr_sign_diff"=d1,"eds_sign_diff"=d2,"edr_all"=d3,"eds_all"=d4)
write.xlsx(df,paste0("7_overview_eds_edr_",args[1],"_19jan19.xlsx"))
