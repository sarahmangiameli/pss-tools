# Photoselective Sequencing
# Cell Type Decomposition
# Updated 2022-11-27
# Andrew Earl

# Set up -------
# Set working directory

# Libraries
library(data.table)
library(Matrix)
library(chromVAR)
library(GenomicRanges)
library(SummarizedExperiment)
library(cisTopic)
library(ggplot2)
library(umap)
library(BuenColors)
library(dplyr)
library(ggrepel)
library(BSgenome.Mmusculus.UCSC.mm10)
library(pheatmap)
library(olsrr)

# Limit cores
BiocParallel::register(BiocParallel::MulticoreParam(6, progressbar = TRUE))

# Create UMAP -------
# Read in data from GSE123576
brCounts <- fread("data/processed/figure2_public_data/GSE123576_mousebrain_countsData_revision.csv.gz")
brPeaks <- fread("data/processed/figure2_public_data/GSE123576_mousebrain_peaks_revision.bed.gz")

sparseCounts <- sparseMatrix(as.integer(brCounts$peak_idx), as.integer(brCounts$cell_idx), x = brCounts$count)
saveRDS(sparseCounts, "data/processed/figure2_decomposition/sparseCounts.rds")

# Read peak ranges
peak_names <- paste(as.character(brPeaks$V1), 
                    brPeaks$V2,
                    brPeaks$V3,
                    sep = ".")

peak_ranges <- GRanges(seqnames = brPeaks$V1, ranges = IRanges(brPeaks$V2, brPeaks$V3))

# Create RangedSummarizedExperiment object for ATAC data
bioRadBrainCounts <- SummarizedExperiment(list(counts = sparseCounts),
                                          rowRanges = peak_ranges)
rownames(bioRadBrainCounts) <- peak_names
colnames(bioRadBrainCounts) <- paste0("cell", 1:ncol(bioRadBrainCounts))
rownames(bioRadBrainCounts) <- paste(as.character(seqnames(peak_ranges)), 
                                     paste(start(peak_ranges), end(peak_ranges), sep = "-"), 
                                     sep = ":")
saveRDS(bioRadBrainCounts, "data/processed/figure2_decomposition/bioRadBrainCounts.rds")

# Create cisTopic Object from Bio-Rad Mouse scATAC-seq
bioRadCisTopicObject <- createcisTopicObject(count.matrix = assay(bioRadBrainCounts), project.name = "brain")
# (These steps take a very long time to run)
bioRadCisTopicObject <- runWarpLDAModels(bioRadCisTopicObject, topic=c(15, 20, 25, 30, 40), 
                                         seed=2022, nCores=1, iterations = 500, addModels=FALSE)
bioRadCisTopicObject <- runWarpLDAModels(bioRadCisTopicObject, topic=c(200),
                                         seed=2022, nCores=1, iterations = 500, addModels=FALSE)
saveRDS(bioRadCisTopicObject, "data/processed/figure2_decomposition/bioRadCisTopicObject.rds")

# Run UMAP
bioRadCisTopicObject <- selectModel(bioRadCisTopicObject, type = "maximum")
bioRadCisTopicObject <- runUmap(bioRadCisTopicObject, target='cell', 
                                seed=2022, n_neighbors=30, metric="cosine", min_dist=0.3)
saveRDS(bioRadCisTopicObject, "data/processed/figure2_decomposition/bioRadCisTopicObject.rds")

umap.d <- as.data.frame((bioRadCisTopicObject@dr$cell$Umap))
colnames(umap.d) <- paste0("UMAP",1:2,"_cisTopics")

# Get cluster labels from published data
bioRadBrainMeta <- fread("data/processed/figure2_public_data/GSE123576_mousebrain_cellData_revision.tsv.gz")
umap.d$cluster <- bioRadBrainMeta$clusters

# Data located at https://github.com/buenrostrolab/dscATAC_analysis_code/tree/master/mousebrain/data
brGitHubIdents <- fread("data/processed/figure2_public_data/revision-cluster_annotations.tsv")
brGitHubIdents$num <- as.numeric(gsub("V","",brGitHubIdents$old))
brGitHubIdents <- brGitHubIdents[order(num),]

umap.d$clust <- brGitHubIdents$new[umap.d$cluster]
lc.cent = umap.d %>% group_by(clust) %>% summarize_all(mean)

colnames(umap.d) <- c("UMAP1", "UMAP2", "cluster", "clust")
saveRDS(umap.d, "data/processed/figure2_decomposition/umap.d.rds")

# Plot UMAP
pdf("figures/figure2/bioRadMouseBrainCisTopic200Umap.pdf")
plot <- ggplot(umap.d, aes(x=UMAP1,y=UMAP2, color=as.factor(clust))) + 
  geom_point(size=0.3) + theme_bw() +
  scale_color_manual(values=jdb_palette("corona")) + pretty_plot(fontsize = 12) +
  guides(colour = guide_legend(override.aes = list(size=1))) +
  labs(color = "Cell Type", size = 1)
leg <- cowplot::get_legend(plot)
plot <- plot + theme(legend.position="none")
print(plot)
grid::grid.newpage()
grid::grid.draw(leg)
dev.off()

# Create Heatmap -------
# Read in matrix with single cell cluster and bulk counts on peaks called in Bio-Rad scATAC data
allCounts <- readRDS("data/processed/figure2_decomposition/allCounts.rds")

allCounts <- addGCBias(allCounts, genome=BSgenome.Mmusculus.UCSC.mm10)
allCounts <- filterPeaks(allCounts)
bg <- getBackgroundPeaks(allCounts, niterations=250)

cisOut <- getRegionsScores(bioRadCisTopicObject)

cisOut <- binarizecisTopics(
  cisOut,
  method = "GammaFit",
  thrP = 0.995,
  plot = FALSE,
  cutoffs = NULL
)

nTopics <- length(cisOut@binarized.cisTopics)

topic_annot_ix <- Matrix(0,
                         ncol=nTopics,
                         nrow=nrow(allCounts))

rownames(topic_annot_ix) <- Signac::GRangesToString(granges(allCounts),sep = c(":","-"))

for(i in 1:nTopics){
  if(nrow(cisOut@binarized.cisTopics[[i]])==0)
    next
  
  topic_annot_ix[rownames(cisOut@binarized.cisTopics[[i]]),i] <- 1
  
}

colnames(topic_annot_ix) <- paste0("Topic",1:nTopics)

dev_custom <- computeDeviations(object = allCounts, annotations = topic_annot_ix, background_peaks = bg)

saveRDS(dev_custom, "data/processed/figure2_decomposition/deviationsCisTopicOligGranBioRad.rds")

corBioRad <- cor(dev_custom@assays@data$z)
pdf("figures/figure2/PSSPairwiseCorrelationHeatmap.pdf")
pheatmap(corBioRad[28:43,28:43], border_color = NA, show_colnames = FALSE)
dev.off()

corBioRadRectangle <- corBioRad[c(1:2, 24, 28:43), 1:27]

mat_breaks <- seq(0, 1, 0.01)
mycols <- colorRampPalette(colors = jdb_palette("solar_extra", type = "continuous"))(length(mat_breaks)-1)

pdf("figures/figure2/CorrelationHeatmap.pdf")
pheatmap(corBioRadRectangle, show_colnames = TRUE, border_color = NA, 
         color=mycols, scale = "none", breaks = mat_breaks, cluster_rows = TRUE)
dev.off()

corBioRadRectanglePlusPublic <- corBioRad[c(1:2, 24, 28:45), 1:27]
pdf("figures/figure2/CorrelationHeatmapPlusPublic.pdf")
pheatmap(corBioRadRectanglePlusPublic, show_colnames = TRUE, border_color = NA, 
         color=mycols, scale = "none", breaks = mat_breaks, cluster_rows = TRUE)
dev.off()

# Cell Type Decomposition -------
stepwiseWeights <- list()
data <- dev_custom@assays@data$z
# use the most variable topics
data <- data[apply(data,1,sd) > 25,]

# Run stepwise on each PSS sample
for (x in c(28:45)) {
  inputData <- data[,c(1:27, x)]
  colnames(inputData)[28] <- "test"
  myModel1 <- lm(test ~ 1, data = as.data.frame(inputData))
  myModel2 <- lm(test ~ . + 0, data = as.data.frame(inputData))
  forward <- ols_step_forward_p(myModel2, penter = 1E-12)
  coefficients <- forward$model$coefficients[-1]
  coeff <- coefficients[coefficients>0]
  normCoeff <- coeff/sum(coeff)
  stepwiseWeights[[colnames(data)[x]]] <- normCoeff
}

# Assign weights of 0 to cell types not detected
allTypes <- unique(unlist(sapply(stepwiseWeights, names)))
for (item in 1:length(stepwiseWeights)) {
  for (type in allTypes) {
    if (!type %in% names(stepwiseWeights[[item]])) {
      stepwiseWeights[[item]][type] <- 0
    }
  }
  stepwiseWeights[[item]] <- stepwiseWeights[[item]][allTypes]
}

df <- as.data.frame(stepwiseWeights)

corpusOlig <- apply(df[,colnames(df) %like% "Corpus"],1,mean)
cortexOlig <- apply(df[,colnames(df) %like% "Cortex"],1,mean)
hippoOlig <- apply(df[,colnames(df) %like% "Olig2"][1:3],1,mean)
pfcOlig <- apply(df[,colnames(df) %like% "Olig2"][4:6],1,mean)
gran <- apply(df[,colnames(df) %like% "Granule"],1,mean)
publicOlig <- df[,"Public.Oligodendrocyte"]
publicOpc <- df[,"Public.Oligodendrocyte.Progenitor.Cell"]


shuffledDf <- cbind(hippoOlig,pfcOlig,corpusOlig,cortexOlig,gran)
meltedDf <- melt(shuffledDf)

pdf("figures/figure2/barPlotCellTypesGrouped.pdf")
ggplot(meltedDf, aes(x = Var2, y = value, fill = Var1)) + 
  geom_bar(stat = "identity") + theme_bw()
dev.off()


# With Public Data
shuffledDfWithPublic <- cbind(hippoOlig,pfcOlig,corpusOlig,cortexOlig,gran,publicOlig,publicOpc)
meltedDfWithPublic <- melt(shuffledDfWithPublic)

pdf("figures/figure2/barPlotCellTypesGroupedWithPublic.pdf")
ggplot(meltedDfWithPublic, aes(x = Var2, y = value, fill = Var1)) + 
  geom_bar(stat = "identity") + theme_bw()
dev.off()

# Synthetic Mixing -------
totalNumber <- 500000
# Mix oligodendrocytes and OPCs at the ratio seen in hippocampus PSS data
hippoMixOligNumber <- round(shuffledDfWithPublic["Oligodendrocyte","hippoOlig"]*totalNumber)
hippoMixOpcNumber <- round(shuffledDfWithPublic["`Oligodendrocyte Progenitor Cell`","hippoOlig"]*totalNumber)
hippoMix <- c(sample(rownames(allCounts), hippoMixOligNumber, replace = TRUE, 
                   prob = as.vector(counts(allCounts[,"Public Oligodendrocyte"]))/
                     (colSums(counts(allCounts[,"Public Oligodendrocyte"])))),
            sample(rownames(allCounts), hippoMixOpcNumber, replace = TRUE, 
                   prob = as.vector(counts(allCounts[,"Public Oligodendrocyte Progenitor Cell"]))/
                     (colSums(counts(allCounts[,"Public Oligodendrocyte Progenitor Cell"])))))
hippoMixCounts <- as.matrix(table(factor(hippoMix, levels = rownames(allCounts))))
hippoMixSE <- SummarizedExperiment(list(counts = hippoMixCounts),
                                 rowRanges = rowRanges(allCounts))
hippoMixSE$depth <- sum(hippoMixCounts)

# Mix oligodendrocytes and OPCs at the ratio seen in PFC PSS data
pfcMixOligNumber <- round(shuffledDfWithPublic["Oligodendrocyte","pfcOlig"]*totalNumber)
pfcMixOpcNumber <- round(shuffledDfWithPublic["`Oligodendrocyte Progenitor Cell`","pfcOlig"]*totalNumber)
pfcMix <- c(sample(rownames(allCounts), pfcMixOligNumber, replace = TRUE, 
                   prob = as.vector(counts(allCounts[,"Public Oligodendrocyte"]))/
                     (colSums(counts(allCounts[,"Public Oligodendrocyte"])))),
            sample(rownames(allCounts), pfcMixOpcNumber, replace = TRUE, 
                   prob = as.vector(counts(allCounts[,"Public Oligodendrocyte Progenitor Cell"]))/
                     (colSums(counts(allCounts[,"Public Oligodendrocyte Progenitor Cell"])))))
pfcMixCounts <- as.matrix(table(factor(pfcMix, levels = rownames(allCounts))))
pfcMixSE <- SummarizedExperiment(list(counts = pfcMixCounts),
                                 rowRanges = rowRanges(allCounts))
pfcMixSE$depth <- sum(pfcMixCounts)

# Combine count matrices and rerun chromVAR
allCountsWithMix <- cbind(allCounts, hippoMixSE, pfcMixSE)
colnames(allCountsWithMix) <- c(colnames(allCounts), "Mixed Public Data Hippo Ratio", "Mixed Public Data PFC Ratio")

dev_custom_withMix <- computeDeviations(object = allCountsWithMix, annotations = topic_annot_ix, background_peaks = bg)

stepwiseWeights <- list()
data <- dev_custom_withMix@assays@data$z
# use the most variable topics
data <- data[apply(data,1,sd) > 25,]

# Run stepwise on each PSS sample
for (x in c(28:47)) {
  inputData <- data[,c(1:27, x)]
  colnames(inputData)[28] <- "test"
  myModel1 <- lm(test ~ 1, data = as.data.frame(inputData))
  myModel2 <- lm(test ~ . + 0, data = as.data.frame(inputData))
  forward <- ols_step_forward_p(myModel2, penter = 1E-12)
  coefficients <- forward$model$coefficients[-1]
  coeff <- coefficients[coefficients>0]
  normCoeff <- coeff/sum(coeff)
  stepwiseWeights[[colnames(data)[x]]] <- normCoeff
}

# Assign weights of 0 to cell types not detected
allTypes <- unique(unlist(sapply(stepwiseWeights, names)))
for (item in 1:length(stepwiseWeights)) {
  for (type in allTypes) {
    if (!type %in% names(stepwiseWeights[[item]])) {
      stepwiseWeights[[item]][type] <- 0
    }
  }
  stepwiseWeights[[item]] <- stepwiseWeights[[item]][allTypes]
}

df <- as.data.frame(stepwiseWeights)

corpusOlig <- apply(df[,colnames(df) %like% "Corpus"],1,mean)
cortexOlig <- apply(df[,colnames(df) %like% "Cortex"],1,mean)
hippoOlig <- apply(df[,colnames(df) %like% "Olig2"][1:3],1,mean)
pfcOlig <- apply(df[,colnames(df) %like% "Olig2"][4:6],1,mean)
gran <- apply(df[,colnames(df) %like% "Granule"],1,mean)
publicOlig <- df[,"Public.Oligodendrocyte"]
publicOpc <- df[,"Public.Oligodendrocyte.Progenitor.Cell"]
mixedHippo <- df[,"Mixed.Public.Data.Hippo.Ratio"]
mixedPfc <- df[,"Mixed.Public.Data.PFC.Ratio"]

# Combine all samples
shuffledDfWithMixed <- cbind(hippoOlig,pfcOlig,corpusOlig,cortexOlig,gran,publicOlig,publicOpc,mixedHippo,mixedPfc)
meltedDfWithMixed <- melt(shuffledDfWithMixed)

pdf("figures/figure2/barPlotCellTypesGroupedWithMixed.pdf")
ggplot(meltedDfWithMixed, aes(x = Var2, y = value, fill = Var1)) + 
  geom_bar(stat = "identity") + theme_bw()
dev.off()
