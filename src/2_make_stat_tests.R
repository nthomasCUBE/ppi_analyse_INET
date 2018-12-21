library(xlsx)
library(dunn.test)
options(stringsAsFactors=FALSE)
args = commandArgs(trailingOnly=TRUE)

c_id=args[1]
MY_LABEL=args[2]

data=read.csv(paste0(c_id,"/1_restructure_content.txt"),sep="\t",header=T)
u_files=unique(data[,1])

df=data.frame()
df2=data.frame()

f_ign=c()
for(x in 1:length(u_files)){
	D=subset(data,data[,1]==u_files[x])
	D1=subset(D,D[,2]=="Wt")
	if(dim(D1)[1]==0){
		f_ign=c(f_ign,u_files[x])
	}
	unique_species_all=unique(D[,2])
	unique_species=unique_species_all[unique_species_all!="Wt"]
	for(y in 1:length(unique_species)){
		D2=subset(D,D[,2]==unique_species[y])		
		D1_arr=D1[,3:dim(D1)[2]]
		D2_arr=D2[,3:dim(D2)[2]]
		D1_arr=as.vector(as.matrix(D1_arr))
		D2_arr=as.vector(as.matrix(D2_arr))
		D1_arr=D1_arr[!is.na(D1_arr)]
		D2_arr=D2_arr[!is.na(D2_arr)]
		my_mu1=mean(D1_arr)
		my_mu2=mean(D2_arr)
		if(length(D1_arr)>0 & length(D2_arr)>0){
			my_wx_p=wilcox.test(D1_arr,D2_arr)
			my_t_p=t.test(D1_arr,D2_arr)
			my_k_p=kruskal.test(list(x=D1_arr,y=D2_arr))
			if(my_wx_p$p.value<0.05){
				if(my_mu1>my_mu2){	my_type="EDR"	}
				else{			my_type="EDS"	}
				#df=rbind(df,c("Wt",unique_species[y],u_files[x],my_wx_p$p.value,my_t_p$p.value,my_k_p$p.value,my_mu1,my_mu2,length(D1_arr),length(D2_arr),my_type))
			}else{
				my_type="NA"
			}
			df=rbind(df,c("Wt",unique_species[y],u_files[x],my_wx_p$p.value,my_t_p$p.value,my_k_p$p.value,my_mu1,my_mu2,length(D1_arr),length(D2_arr),my_type))
		}
	}
	L=list()
	for(u in 1:length(unique_species_all)){
		my_d=subset(D,D[,2]==unique_species_all[u])
		my_d=my_d[,3:dim(my_d)[2]]
		my_val=as.vector(as.matrix(my_d))
		my_val=my_val[!is.na(my_val)]
		L[[u]]=my_val
	}
	my_d_t=dunn.test(L,table=FALSE,list=FALSE,label=FALSE);
	cur_comp=my_d_t$comparisons
	cur_adj_pval=my_d_t$P.adjusted
	cur_file=u_files[x]
	for(z in 1:length(cur_comp)){
		id1=strsplit(cur_comp[z]," -")[[1]][1]
		id2=strsplit(cur_comp[z],"- ")[[1]][2]
		id1=as.numeric(id1)
		id2=as.numeric(id2)
		id1=unique_species_all[id1]
		id2=unique_species_all[id2]
		df2=rbind(df2,c(cur_comp[z],cur_adj_pval[z],cur_file,id1,id2))
	}
}
df=cbind(df,p.adjust(df[,4],method="BH"))
df=cbind(df,p.adjust(df[,5],method="BH"))
df=cbind(df,p.adjust(df[,6],method="BH"))

colnames(df)=c("wild type","genotype","textfile","pval_wilcoxon","pval_ttest","pval_kruskal","mu wild type","mu genotype","nmb items wild type","nmb items genotype","EDR_or_EDS","adj_pval_wilcoxon_BH","adj_pval_ttest_BH","adj_pval_kruskal_BH")
write.xlsx(df,paste0(c_id,"/2_make_stat_tests_",MY_LABEL,".xlsx"))

colnames(df2)=c("group_cmp","p-value (dunn.test)","file","genotype1","genotype2")
write.xlsx(df2,paste0(c_id,"/2_make_stat_tests_Dunn_test_",MY_LABEL,".xlsx"))

print("--------------------------------------")
for(f_ign_ in f_ign){
	print(f_ign_)
}

