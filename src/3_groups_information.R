library(xlsx)
library(pheatmap)

options(stringsAsFactors=FALSE)
args <- commandArgs(trailingOnly = TRUE)

c_f=args[1]

#D=read.xlsx("2_make_stat_tests_21sep18_V5.xlsx",1)
D=read.xlsx(c_f,1)

u_files=unique(D[,4])
u_files=sort(u_files)

max_pairs=c()
for(x in 1:length(u_files)){
        my_sub=subset(D,D[,4]==u_files[x])
        u_pairs=unique(paste(my_sub[,2],my_sub[,3],sep="_"))
	max_pairs=c(max_pairs,length(u_pairs))
}
N_a=(max(max_pairs))
N_b=(length(u_files))

M=matrix(rep(NA,N_a*N_b),ncol=N_a,nrow=N_b)
for(x in 1:length(u_files)){
	my_sub=subset(D,D[,4]==u_files[x])
	u_pairs=unique(paste(my_sub[,2],my_sub[,3],sep="_"))
	for(y in 1:length(u_pairs)){
		up1=strsplit(u_pairs[y],"_")[[1]][1]
		up2=strsplit(u_pairs[y],"_")[[1]][2]
		Dsub=subset(my_sub,my_sub[,2]==up1 & my_sub[,3]==up2)
		if(dim(Dsub)[1]>0){
			my_val=Dsub[1,"adj_pval_wilcoxon_BH"]
			if(my_val<0.05){				
				if(Dsub[1,"mu.wild.type"]>Dsub[1,"mu.genotype"]){	M[x,y]=1	}
				else{							M[x,y]=-1	}
			}else{								M[x,y]=0	}
		}
	}
}

my_palette <- colorRampPalette(c("forestgreen", "yellow", "red"))(n = 299)

rownames(M)=u_files
pdf(paste(c_f,".pdf",sep=""),width=10,height=30)
pheatmap(as.matrix(M),fontsize=8,col=my_palette)
dev.off()

