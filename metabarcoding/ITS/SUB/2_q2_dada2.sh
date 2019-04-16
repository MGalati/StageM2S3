#!/bin/bash

# JOB BEGIN

IN=~/metab/data/ITS

RUN1=PRIM
RUN2=ITS_mock24

echo 'Import sequences'
for seqs in ${RUN1} ${RUN2}
do
qiime tools import --type SampleData[PairedEndSequencesWithQuality] \
                   --input-path ${IN}/${seqs} \
                   --output-path ${IN}/${seqs}_reads.qza \
                   --input-format CasavaOneEightSingleLanePerSampleDirFmt 

echo 'Check this artifact to make sure that QIIME now recognizes your data'
qiime tools peek ${IN}/${seqs}_reads.qza 

echo 'Initial sequence quality control'
qiime demux summarize \
  --i-data ${IN}/${seqs}_reads.qza  \
  --o-visualization ${IN}/${seqs}_reads.qzv  \
  --verbose
done

echo 'dada2'
for seqs in ${RUN1} ${RUN2}
do

truncF=0
truncL=0
trimF=0
trimL=0
maxee=2
truncq=10
nreadslearn=10000000
chim=consensus

mkdir dada2_output_${seqs}

qiime dada2 denoise-paired --i-demultiplexed-seqs ${IN}/${seqs}_reads.qza \
                           --p-trunc-len-f ${truncF} \
                           --p-trunc-len-r ${truncL} \
                           --p-trim-left-f ${trimF} \
                           --p-trim-left-r ${trimL} \
                           --p-max-ee ${maxee} \
                           --p-trunc-q ${truncq} \
                           --p-n-reads-learn ${nreadslearn} \
                           --p-chimera-method ${chim} \
                           --o-representative-sequences dada2_output_${seqs}/${seqs}_representative_sequences.qza \
                           --o-table dada2_output_${seqs}/${seqs}_table.qza \
                           --o-denoising-stats dada2_output_${seqs}/${seqs}_denoising_stats.qza \
                           --verbose
#                          --output-dir dada2_output \
done

echo 'Viewing denoising stats'
qiime metadata tabulate \
  --m-input-file dada2_output_${seqs}/${seqs}_denoising_stats.qza \
  --o-visualization dada2_output_${seqs}/${seqs}_denoising_stats.qza

echo 'Summarize your filtered/ASV table data'
qiime tools export --input-path dada2_output_${seqs}/${seqs}_denoising_stats.qza --output-path dada2_output_${seqs}/${seqs}

qiime feature-table summarize --i-table dada2_output_${seqs}/${seqs}_table.qza --o-visualization dada2_output_${seqs}/${seqs}_table_summary.qzv --verbose

done


echo 'Merging denoised data'
echo 'ASV table'
qiime feature-table merge \
  --i-tables dada2_output_${RUN1}/${RUN1}_table.qza \
  --i-tables dada2_output_${RUN2}/${RUN2}_table.qza \
  --o-merged-table dada2_output/table.qza

echo 'Representative sequences'
qiime feature-table merge-seqs \
  --i-data dada2_output_${RUN1}/${RUN1}_representative_sequences.qza \
  --i-data dada2_output_${RUN2}/${RUN2}_representative_sequences.qza \
  --o-merged-data dada2_output/representative_sequences.qza

#summarize
qiime feature-table summarize \
  --i-table dada2_output/table.qza \
  --o-visualization dada2_output/table.qzv 
  ##--m-sample-metadata-file sample-metadata.tsv

qiime feature-table tabulate-seqs \
  --i-data dada2_output/representative_sequences.qza\
  --o-visualization dada2_output/representative_sequences.qzv


### Build quick phylogeny with FastTree
#https://github.com/LangilleLab/microbiome_helper/wiki/Amplicon-SOP-v2-(qiime2-2018.8)
#https://docs.qiime2.org/2018.11/tutorials/moving-pictures/

mkdir phylogeny

qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences dada2_output/representative_sequences.qza \
  --o-alignment phylogeny/aligned-rep-seqs.qza \
  --o-masked-alignment phylogeny/masked-aligned-rep-seqs.qza \
  --o-tree phylogeny/unrooted-tree.qza \
  --o-rooted-tree phylogeny/rooted-tree.qza \
  --verbose

#qiime tools export --input-path dada2_output/deblur_table_filt.qza --output-path dada2_output_exported
#qiime tools export --input-path dada2_output/rep_seqs_filt.qza --output-path dada2_output_exported

mkdir taxonomy

qiime feature-classifier classify-sklearn \
  --i-classifier  ~/metab/data/ITS/classifier/unite-ver7-dynamic-classifier-01.12.2017.qza \
  --i-reads dada2_output/representative_sequences.qza \
  --o-classification taxonomy/ITS_taxonomy.qza \
  --verbose

qiime metadata tabulate \
  --m-input-file taxonomy/ITS_taxonomy.qza \
  --o-visualization taxonomy/ITS_taxonomy.qzv

# necessite metadata
# qiime taxa barplot \
#  --i-table dada2_output/table.qza \
#  --i-taxonomy taxonomy/${DB}_taxonomy.qza \
#  --o-visualization taxonomy/${DB}_taxa-bar-plots.qzv \
#  --m-metadata-file metadata.tsv 

qiime tools export --input-path taxonomy/ITS_taxonomy.qza --output-path taxonomy

### Exporting and modifying BIOM tables

#Creating a TSV BIOM table
qiime tools export --input-path dada2_output/table.qza --output-path export
biom convert -i export/feature-table.biom -o export/ASV-table.biom.tsv --to-tsv

cp export/ASV-table.biom.tsv export/feature-table.biom.tsv

#https://askubuntu.com/questions/20414/find-and-replace-text-within-a-file-using-commands
# ASV table for phyloseq

sed -i "s/#OTU ID/OTUID/g" export/ASV-table.biom.tsv
sed -i "1d" export/ASV-table.biom.tsv

sed -i "s/#OTU ID/#OTUID/g" export/feature-table.biom.tsv

#Export Taxonomy
qiime tools export --input-path ~/metab/data/ITS/classifier/unite-ver7-dynamic-classifier-01.12.2017.qza --output-path export

biom add-metadata -i export/ASV-table.biom.tsv  -o export/ASV-table-unite-ver7-taxonomy.biom \
  --observation-metadata-fp export/unite-ver7_taxonomy.tsv \
  --sc-separated taxonomy
biom convert -i export/ASV-table-unite-ver7-taxonomy.biom -o export/ASV-table-unite-ver7-taxonomy.biom.tsv --to-tsv

#Export ASV seqs
qiime tools export --input-path dada2_output/representative_sequences.qza --output-path export

#Export Tree
qiime tools export --input-path phylogeny/unrooted-tree.qza --output-path export
mv export/tree.nwk export/unrooted-tree.nwk
qiime tools export --input-path phylogeny/rooted-tree.qza --output-path export
mv export/tree.nwk export/rooted-tree.nwk


# For phyloseq you will need :
ls export/feature-table.biom.tsv export/taxonomy.tsv export/unrooted-tree.nwk export/rooted-tree.nwk

zip export/export.zip export/* dada2_outpu*/*qzv taxonomy/*.qzv

conda deactivate

# JOB END
date

exit 0
