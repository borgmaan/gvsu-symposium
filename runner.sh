#!/usr/bin/env bash
# Andrew Borgman
# VARI BBC
# Last second scrambling to get somethign mildly reproducible for my talk...

mkdir raw_reads

# Dad data
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR262/ERR262996/ERR262996_1.fastq.gz -O raw_reads/ERR262996_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR262/ERR262996/ERR262996_2.fastq.gz -O raw_reads/ERR262996_2.fastq.gz

# Mom data
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR262/ERR262997/ERR262997_1.fastq.gz -O raw_reads/ERR262997_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR262/ERR262997/ERR262997_2.fastq.gz -O raw_reads/ERR262997_2.fastq.gz

# Kid data
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR262/ERR262998/ERR262998_1.fastq.gz -O raw_reads/ERR262998_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR262/ERR262998/ERR262998_2.fastq.gz -O raw_reads/ERR262998_2.fastq.gz

# Init directories
mkdir bams; mkdir logs; mkdir sams; mkdir tmp; mkdir vcfs; mkdir annovar_input; mkdir annovar_output; mkdir filtered_vcfs;

# Run sample alignment 
make sample_id=ERR262998
make sample_id=ERR262997
make sample_id=ERR262996

# Do multi-sample variant calling with trio to get pedigree aware variants to feed into PhaseByTransmission
threads=10
ref_fasta="/data/ngs4/reference/hg19/bowtie_indexes/hg19_all.fa"
ped_file="1000G_fam.ped "
app_dir="/data/ngs4/aborgman/apps/tools"
jvm_config="-Xmx16g" 
java_tmpdir="-Djava.io.tmpdir=./tmp "
java $jvm_config $java_tmpdir -jar $app_dir/GenomeAnalysisTK.jar --num_threads $threads -ped $ped_file -I bams/ERR262996_bqsr.bam -I bams/ERR262997_bqsr.bam -I bams/ERR262998_bqsr.bam -R $ref_fasta -T UnifiedGenotyper -glm BOTH --dbsnp /data/ngs4/reference/gatk_data/broad_files/dbsnp_137.hg19.vcf -o trio_variants.vcf -rf BadCigar 

# Run PhaseByTransmission to look for Mendelian violations
java $jvm_config $java_tmpdir -jar $app_dir/GenomeAnalysisTK.jar -R $ref_fasta -T PhaseByTransmission -V trio_variants.vcf -ped $ped_file -o phased_trio.vcf -mvf mendelian_violations.txt
