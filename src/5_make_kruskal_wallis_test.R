library(ggplot2)
library(muStat)
library(xlsx)

options(stringsAsFactors=FALSE)
args = commandArgs(trailingOnly=TRUE)

# ---------------------------------------------------------
NORM_METHOD="min_max"
my_opt=args[1]

if(my_opt %in% c("Emwa1","noks")){
	print(paste("We are running now:",my_opt))
}else{
	print(paste("Unsupported value for:",my_opt))
}

# ---------------------------------------------------------

if(!(NORM_METHOD %in% c("min_max","znorm"))){
	print("invalid normalisation method")
	exit(-1)
}

#
#	Mapping of the identifiers and the Arabidopsis thaliana proteins
#
meta_info=read.csv("data/internal_id_gene_name.txt",sep="\t",header=T)
META=list()
META=meta_info[,1]
names(META)=meta_info[,2]
print(paste0("There are in total",length(META),"genes that are analysed"))

#
# p-values overall
#
df=data.frame( WT=c(),mutant=c(),my_p=c())
df2=data.frame(WT=c(),mutant=c(),file=c(),my_p=c())

parse_content=function(my_opt){
	data=read.csv(paste0(my_opt,"/1_restructure_content.txt"),sep="\t",header=F)
	u_f=unique(data[,1])

	#
	#	Get the actual Arabidopsis thaliana gene ids from the probe identifiers
	#
	my_g=data[,2]
	for(x in 1:dim(data)[1]){
		if(!(is.na(META[my_g[x]]))){
			my_g[x]=META[my_g[x]]
		}
	}
	#
	#	some of the identifiers are in lowercase, they might be needed to converted into uppercase to that
	#	matching from the analysis to the metainformation file
	#
	data[,2]=toupper(my_g)

	#
	#	Normalisation per experiment
	#	Depending on the selection, it is either a Z-transformation (X-mean)/sd but can be als
	#	(x-min)/(max-min) called here as the 'min_max' normalisation
	#
	for(x in 1:length(u_f)){
		print(paste0("INFO|Currently processed file is:|",as.character(u_f[x],1,5)))
		ix=which(data[,1]==u_f[x])
		my_v=(data[ix,3:dim(data)[2]])
		my_v=my_v[!is.na(my_v)]
		print(paste0("INFO|Normalisation with:",NORM_METHOD))
		if(NORM_METHOD=="znorm"){
			my_sd=sd(my_v); 
			my_mean=mean(my_v)
			data[ix,3:dim(data)[2]]=(data[ix,3:dim(data)[2]]-my_mean)/my_sd
		}else if(NORM_METHOD=="min_max"){
			my_min=min(my_v); 
			my_max=max(my_v)
			data[ix,3:dim(data)[2]]=(data[ix,3:dim(data)[2]]-my_min)/(my_max-my_min)
		}
	}

	#
	#	Iteration over all genes available
	#

	my_g=(unique(data[,2]))
	my_g=my_g[my_g!="WT"]
	for(x in 1:length(my_g)){
		u_fid=subset(data,data[,2]==my_g[x])[,1]
		u_fid=unique(u_fid)
		for(y in 1:length(u_fid)){
			C=subset(data,data[,2]=="WT" & data[,1]==u_fid[y]); D=subset(data,data[,2]==my_g[x] & data[,1]==u_fid[y])
			C=C[,3:dim(C)[2]]; D=D[,3:dim(D)[2]]
			C=C[!is.na(C)]; D=D[!is.na(D)]
			C=unlist(C); D=unlist(D)
			my_p=(wilcox.test(C,D)$p.value)
			my_l=as.double(log2(mean(C)/mean(D)))
			if(my_l<0){	my_phen="edr"	}
			else{		my_phen="eds"	}
			df2=rbind(df2,c("WT",my_g[x],u_fid[y],my_p,as.double(mean(C)),as.double(mean(D)),my_l,my_phen))
		}
		A=subset(data,data[,2]=="WT" & data[,1]%in%u_fid)
		B=subset(data,data[,2]==my_g[x])
		A=A[,3:dim(A)[2]]; B=B[,3:dim(B)[2]]; A=unlist(A); B=unlist(B)
		A=as.vector(A); B=as.vector(B); A=A[!is.na(A)]; B=B[!is.na(B)]
		my_p=(wilcox.test(A,B)$p.value)
		my_l=as.double(log2(mean(A)/mean(B)))
		if(my_l<0){     my_phen="edr"   }
		else{           my_phen="eds"   }
		df=rbind(df,c("WT",my_g[x],my_p,as.double(mean(A)),as.double(mean(B)),my_l,my_phen))
	}
	L=list()
	L[[1]]=df
	L[[2]]=df2
	return(L)
}

L=parse_content(my_opt)
my_df=L[[1]]
my_df2=L[[2]]

my_df=cbind(my_df,p_val_adj=p.adjust(my_df[,3],"bonferroni"))
my_df=cbind(my_df,p_val_adj=p.adjust(my_df[,3],"BH"))
colnames(my_df)=c("WT","mutant","pval_wilcox","mean_norm_WT","mean_norm_mutant","log2","phenotype","pval_wilcox_bonferroni","pval_adj_wilcox_BH")
for(x in 3:dim(my_df)[2]){
        if(colnames(my_df)[x]!="phenotype"){
                my_df[,x]=as.double(my_df[,x])
        }
}
write.table(my_df,paste0("5_make_kruskal_wallis_test_OVERALL_",args[1],".csv"),sep=";",row.names=FALSE,dec=",")
my_df2=cbind(my_df2,p_val_adj=p.adjust(my_df2[,4],"bonferroni"))
my_df2=cbind(my_df2,p_val_adj=p.adjust(my_df2[,4],"BH"))
colnames(my_df2)=c("WT","mutant","file","pval_wilcox","mean_norm_WT","mean_norm_mutant","log2","phenotype","pval_adj_bonferroni","pval_adj_wilcox_BH")
for(x in 4:dim(my_df2)[2]){
        if(colnames(my_df2)[x]!="phenotype"){
                my_df2[,x]=as.double(my_df2[,x])
        }
}
write.table(my_df2,paste0("5_make_kruskal_wallis_test_SINGLE_",args[1],".csv"),sep=";",row.names=FALSE,dec=",")

