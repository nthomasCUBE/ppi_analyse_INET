library(xlsx)
library(pheatmap)
options(stringsAsFactors=FALSE)

args <- commandArgs(trailingOnly = TRUE)

c_f=args[1]

D=read.xlsx(c_f,1)

u_files=unique(D[,4])
u_files=sort(u_files)
u_pair1=c(); u_pair2=c()
for(x in 1:length(u_files)){
        my_sub=subset(D,D[,4]==u_files[x])
	u_pair2=c(u_pair2,my_sub[,3])
}
u_pair2=unique(u_pair2)
N_a=(length(u_pair2))
N_b=(length(u_files))
M=matrix(rep(NA,N_a*N_b),ncol=N_a,nrow=N_b)
for(x in 1:length(u_files)){
	my_sub=subset(D,D[,4]==u_files[x])
	u_pairs=unique(paste(my_sub[,2],my_sub[,3],sep="_"))
	for(y in 1:length(u_pair2)){
		Dsub=subset(my_sub,my_sub[,3]==u_pair2[y])
		if(dim(Dsub)[1]>0){
			my_val=Dsub[1,"adj_pval_wilcoxon_BH"]
			if(my_val<0.05){				
				if(Dsub[1,"mu.wild.type"]>Dsub[1,"mu.genotype"]){	M[x,y]=1	}
				else{							M[x,y]=-1	}
			}else{								M[x,y]=0	}
		}
	}
}
rownames(M)=u_files; colnames(M)=u_pair2

my_palette <- colorRampPalette(c("forestgreen", "yellow", "red"))(n = 299)

pdf(paste(c_f,"_all.pdf",sep=""),width=30,height=30)


print(M)
pheatmap(as.matrix(M),fontsize=8,cluster_rows=FALSE,col=my_palette, cluster_cols=FALSE)
dev.off()
