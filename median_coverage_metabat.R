#!/usr/bin/env Rscript
library(foreach)
library(matrixStats)

ca = commandArgs(TRUE)

depth_file=ca[1]
bins=ca[2]
out=ca[3]

depth <- read.table(depth_file, as.is=T, header=T)
bins <- list.files(bins, pattern='.fa', full.name=T)

depth <- depth[,-which(grepl('var$',colnames(depth)))][,-c(2,3)]
mems <- foreach(f = bins) %do% {
  sub('>','',system(sprintf("grep --only-matching 'k[0-9]*_[0-9]*' %s", f), intern=T))
}
names(mems) <- sub('.fa','',basename(bins)) 

bins.cv <- do.call(rbind, foreach(m=mems) %do% {
  colMedians(as.matrix(depth[match(m, depth$contigName),-1]))
})
dimnames(bins.cv) <- list(names(mems), colnames(depth)[-1])
write.table(bins.cv, file=out, row.names=T, col.names=T, quote=F, sep='\t')