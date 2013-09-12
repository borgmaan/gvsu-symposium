2nd Annual Symposium in Bioinformatics & Computational Biology
==============

This repository contains code for the trio analysis I described in my talk @ the GVSU Bioinformatics Symposium. 

### What I have done for you:
0. Put together a nice trio analysis workflow.
1. Gave you the code for it. 
3. 

### What you need to do:
0. Be on a Unix/Linux box with wget installed. 
1. Download your own hg19 reference file from [here](http://hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/)
	* Update `ref_fasta` variable in Makefile to point at this. 
2. Download and build [GATK](http://www.broadinstitute.org/gatk/), [samtools](), and [bwa](). Put the compiled binaries in one directory
	* Update `app_dir` variable in Makefile and runner.sh to point at this. 

This is pretty terrible in its current state, but it is a step in the right direction. Check out my [xenophobia project](https://github.com/borgmaan/xenophobia) for my musings on reproducibility. 