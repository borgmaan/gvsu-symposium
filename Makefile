# Andrew Borgman
# VARI BBC
# 6/27/2013
## Run pipeline with: make sample_id=YOUR_BAM_ID

## Config
threads = 10
ref_fasta = /data/ngs4/reference/hg19/bowtie_indexes/hg19_all.fa
ped_file = 1000G_fam.ped 
app_dir = /data/ngs4/aborgman/apps/tools/
jvm_config = -Xmx16g 
java_tmpdir = -Djava.io.tmpdir=./tmp 

# Apply Recal Table
bams/$(sample_id)_bqsr.bam:logs/$(sample_id)_recal_data.grp bams/$(sample_id)_indel_realigned.bam
	java $(jvm_config) $(java_tmpdir) -jar $(app_dir)GenomeAnalysisTK.jar -I bams/$(sample_id)_indel_realigned.bam -R $(ref_fasta) -T PrintReads --filter_mismatching_base_and_quals -rf BadCigar -BQSR logs/$(sample_id)_recal_data.grp -o bams/$(sample_id)_bqsr.bam

# Make Recal table
logs/$(sample_id)_recal_data.grp:bams/$(sample_id)_indel_realigned.bam
	java $(jvm_config) $(java_tmpdir) -jar $(app_dir)GenomeAnalysisTK.jar -I bams/$(sample_id)_indel_realigned.bam -R $(ref_fasta) -T BaseRecalibrator --filter_mismatching_base_and_quals -o logs/$(sample_id)_recal_data.grp -knownSites /data/ngs4/reference/gatk_data/broad_files/Mills_and_1000G_gold_standard.indels.hg19.vcf -knownSites /data/ngs4/reference/gatk_data/broad_files/1000G_phase1.indels.hg19.vcf -knownSites /data/ngs4/reference/gatk_data/broad_files/dbsnp_137.hg19.vcf  --plot_pdf_file logs/$(sample_id).pdf --intermediate_csv_file logs/$(sample_id).csv

# Realign bam around indels
bams/$(sample_id)_indel_realigned.bam:logs/$(sample_id)_gatk_indels.intervals bams/$(sample_id)_rg.bam
	java $(jvm_config) $(java_tmpdir) -jar $(app_dir)GenomeAnalysisTK.jar -I bams/$(sample_id)_rg.bam -R $(ref_fasta) -T IndelRealigner --filter_mismatching_base_and_quals -rf BadCigar -targetIntervals logs/$(sample_id)_gatk_indels.intervals -o bams/$(sample_id)_indel_realigned.bam --maxReadsForRealignment 200000 -known /data/ngs4/reference/gatk_data/broad_files/Mills_and_1000G_gold_standard.indels.hg19.vcf -known /data/ngs4/reference/gatk_data/broad_files/1000G_phase1.indels.hg19.vcf

# Call indels for realignment
logs/$(sample_id)_gatk_indels.intervals:bams/$(sample_id)_rg.bam.bai bams/$(sample_id)_rg.bam
	java $(jvm_config) $(java_tmpdir) -jar $(app_dir)GenomeAnalysisTK.jar --num_threads $(threads) -I bams/$(sample_id)_rg.bam -R $(ref_fasta) -T RealignerTargetCreator --filter_mismatching_base_and_quals -o logs/$(sample_id)_gatk_indels.intervals --known /data/ngs4/reference/gatk_data/broad_files/Mills_and_1000G_gold_standard.indels.hg19.vcf --known /data/ngs4/reference/gatk_data/broad_files/1000G_phase1.indels.hg19.vcf

# Index bam
bams/$(sample_id)_rg.bam.bai:bams/$(sample_id)_rg.bam
	$(app_dir)samtools index bams/$(sample_id)_rg.bam

# Need to add read groups in here, dammit Heng include this in bwasw
bams/$(sample_id)_rg.bam:sams/$(sample_id).sam bams/$(sample_id)_sorted.bam
	java $(jvm_config) $(java_tmpdir) -jar $(app_dir)AddOrReplaceReadGroups.jar I=bams/$(sample_id)_sorted.bam O=bams/$(sample_id)_rg.bam LB="hg19" PL="IlluminaTRIOtest" PU="hiseq2500?" SM="$(sample_id)"

# Combine reads to sam, remove unmapped reads, and sort. 
bams/$(sample_id)_sorted.bam:sams/$(sample_id).sam
	$(app_dir)samtools view -Shbu -F 4 sams/$(sample_id).sam | $(app_dir)samtools sort /dev/stdin bams/$(sample_id)_sorted

## Align paired end reads
sams/$(sample_id).sam:raw_reads/$(sample_id)_1.fastq.gz raw_reads/$(sample_id)_2.fastq.gz
	 $(app_dir)bwa mem -t $(threads) $(ref_fasta) raw_reads/$(sample_id)_1.fastq.gz raw_reads/$(sample_id)_2.fastq.gz > sams/$(sample_id).sam    #MAYBE USE MEM





