library(ggplot2)
library(xlsx)
library(muStat)
options(stringsAsFactors=FALSE)

meta_info=read.csv("data/internal_id_gene_name.txt",sep="\t",header=T)
META=list()
META=meta_info[,1]
names(META)=meta_info[,2]

median.quartile <- function(x){
  out <- quantile(x, probs = c(0.25,0.5,0.75))
  names(out) <- c("ymin","y","ymax")
  return(out) 
}

#
#	Make plot for each gene
#
make_plot=function(all_df,MY_P){
	colnames(all_df)=c("score","file","mutant","mutant2","gene_name")
	all_df[,1]=as.double(all_df[,1])
	p <- ggplot(all_df, aes(x=file,y=score,fill=as.factor(mutant)))+facet_wrap(~mutant)+geom_violin(scale = "width")+geom_boxplot(width=.1)+ggtitle(paste("p(kruskal unadj.)=",MY_P))+geom_point(aes(colour=as.factor(mutant)))
	print(p)
}

make_reset=function(){
        all_df=data.frame(A=c(),B=c(),C=c(),D=c(),E=c())
	return(all_df)
}

#
#	parse either Emwa1 or Nok1
#
parse_content=function(my_opt){
	data=read.csv(paste0(my_opt,"/1_restructure_content.txt"),sep="\t",header=F)
	u_f=unique(data[,1])
	for(x in 1:length(u_f)){
		ix=which(data[,1]==u_f[x])
		my_v=(data[ix,3:dim(data)[2]])
		my_v=my_v[!is.na(my_v)]
		my_sd=sd(my_v)
		my_mean=mean(my_v)
		data[ix,3:dim(data)[2]]=(data[ix,3:dim(data)[2]]-my_mean)/my_sd
	}
	
	all_df=make_reset()

	my_unique_names=(unique(data[,2]))
	df_ov_output=data.frame(my_unique_names,META[my_unique_names])
	write.table(df_ov_output,"5_make_kruskal_wallis_tests_consistency_gene_names_30nov18.txt")
	u_names=unique(data[,2])
	u_names=u_names[u_names!="Wt"]

	MY_P=c(); MY_NAMES=c(); MY_LOG=c()
	M1=c(); M2=c();

	all_my_vals=c()
	for(x in 3:dim(data)[2]){
		all_my_vals=c(all_my_vals,data[,x])
	}
	all_my_vals=all_my_vals[!is.na(all_my_vals)]
	pdf(paste0("5_make_kruskal_wallis_test_21dec18_",my_opt,"ggplot_V2.pdf"),width=10,height=5)
	for(x in 1:length(u_names)){
#       for(x in 1:10){

		print(u_names[x])
		print(c(x,length(u_names)))
		D=subset(data,data[,2]==u_names[x])
		A=c(); B=c(); C=c();
		for(y in 1:dim(D)[1]){
			for(z in 3:length(D[y,])){
				A=c(A,D[y,z])
				B=c(B,D[y,1])
				C=c(C,as.character(u_names[x]))
			}
		}
        	df=data.frame(A=A,B=B,C=C)
		E=subset(data,data[,2]=="Wt")
		E=subset(E,E[,1]%in%unique(B))
		A=c(); B=c(); C=c();
	        for(y in 1:dim(E)[1]){
	                for(z in 3:length(E[y,])){
	                        A=c(A,E[y,z])
	                        B=c(B,E[y,1])
	                        C=c(C,"Wt")
	                }
	        }
		df2=data.frame(A=A,B=B,C=C)
		df=rbind(df,df2)
		df=na.omit(df)
		for(z in 1:dim(df)[1]){
			all_df=rbind(all_df,c(df[z,1],df[z,2],df[z,3],u_names[x],META[u_names[x]]))
		}

		if(length(unique(df$B))>1){
			df[df[,3]!="Wt",3]="not_Wt"
			my_p=kruskal.test(df$C~df$A)
			MY_P=c(MY_P,my_p$p.value)
			MY_NAMES=c(MY_NAMES,u_names[x])
		}else{
			my_p=kruskal.test(df$C~df$A)
			MY_P=c(MY_P,my_p$p.value)
			MY_NAMES=c(MY_NAMES,u_names[x])
		}
                make_plot(all_df,MY_P[len(MY_P)])

                all_df=make_reset()

		val1=subset(df,df[,3]=="Wt")[,1]
		val2=subset(df,df[,3]!="Wt")[,1]

		M1=c(M1,mean(val1))
                M2=c(M2,mean(val2))
	}
	dev.off()

	MAP=list()
	MAP=p.adjust(MY_P,method="BH")
	names(MAP)=MY_NAMES

	MAP_M1=list()
	MAP_M1=M1
	names(MAP_M1)=MY_NAMES

	MAP_M2=list()
	MAP_M2=M2
	names(MAP_M2)=MY_NAMES

	ret=list()
	ret[[1]]=MAP
	ret[[2]]=MAP_M1
	ret[[3]]=MAP_M2
	return(ret)
}

NOKS=parse_content("noks")
EMWA1=parse_content("Emwa1")

u_n=unique(c(names(EMWA1[[1]]),names(NOKS[[1]])))
print(u_n)

df=data.frame(u_n,EMWA1[[1]][u_n],NOKS[[1]][u_n],EMWA1[[2]][u_n],NOKS[[2]][u_n],EMWA1[[3]][u_n],NOKS[[3]][u_n])
df=cbind(df,META[df[,1]])
colnames(df)=c("mutant","EMWA1_p_val_kruskal","NOKS_p_val_kruskal","EMWA1_wt_mean","NOKS_wt_mean","EMWA1_not_wt_mean","NOKS_not_wt_mean")
write.xlsx(df,"5_make_kruskal_wallis_test_21dec18_V2.xlsx",row.names=FALSE)


