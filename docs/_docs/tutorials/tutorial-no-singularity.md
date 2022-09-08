---
title: Tutorial without Singularity
---

# Data processing without Singularity

This tutorial takes you through the steps of running the MIMA pipeline for data processing of shotgun metagenomics sequenced reads using the assembly-free approach. The pipeline depend on the following setup:


- **Compute environment**
  - OpenPBS system on a high-performance cluster (HPC)
  - You have already setup the environment with the MIMA Conda package as specified in the [Installation guide]({{site.baseurl}}/docs/installation)

- **Reference databases**
  - Many of the data processing steps require access to reference databases that are too big to be included in the Singularity container
  - You will need to have these already installed on your system or HPC environment and tell the pipeline of the location (this will be detailed in the relevant steps)

- **Study data assumptions**
  - Paired-end sequencing with two files _R1 and _R2 files
  - By default the pipeline assumes human-host metagenomics studies and decontamination is done against the human genome, you can provide alternative references (see the tutorial or command usage documentation)

# The pipeline

The pipeline consists of the following components which are shown in the schema and briefly described below.

![]({{site.baseurl}}/assets/img/tutorials/no-singularity/tut_OverallSchema.png)

**Data processing**

1. Quality control (QC) of the sequenced reads
2. Taoxonomy profiling after QC (this step can be run in parallel with step 3)
3. Functional profilinng after QC (this step can be run in parallel with step 2)

In steps 1 to 3, the pipeline generates PBS scripts (currently only supports OpenPBS) which then have to be submitted to the PBS manager to actually process the sequenced reads and generate the output.

**Analysis and visualisation** comes after the data has been processed and is covered in a separate tutorial.

# How this tutorial works

The tutorial have five sub-sections for each of the three steps mentioned above:

Step:
    
a) Brief introduction

b) Command to generate PBS scripts 

c) Command to submit PBS scripts as jobs

d) Expected outputs after PBS job completes

e) Post-processing step (some are optional)

---

# Tutorial data

In this tutorial we will use data from the study by [*Tourlousse, et al. (2022)*](https://journals.asm.org/doi/10.1128/spectrum.01915-21), **Characterization and Demonstration of Mock Communities as Control Reagents for Accurate Human Microbiome Community Measures**, Microbiology Spectrum.

> This data set consists of two mock communities: *DNA-mock* and *Cell-mock*. The mock communities consists of bacteria that are mainly detected the human gastrointestinal tract ecosystem with a small mixture of some skin microbiota. The data was processed in three different labs: A, B and C. In the previous tutorial, , we only processed a subset of the samples (n=9). In this tutorial we will be working with the full data set which has been pre-processed using the same pipeline. In total there were 56 samples of which 4 samples fell below the abundance threshold and therefore the final taxonomy abundance table has 52 samples. We will train the random forest classifier to distinguish between the three labs.

* The raw reads are available from NCBI SRA [Project PRJNA747117](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA747117)
* There are 56 paired-end samples (112 fastq files)
    * As the data is very big we will work with a smaller subset to speed up processing
    * You can download the fastq files using this script which requires the `sratoolkit`

**Data files**

{% include alert.html type="danger" title="to-do" content="Add script to download fastq files" %}

* [mini-SRA-accession-list]({{ site.baseurl }}/assets/mini-SRA-accession-list) (N=9 samples to download fastq)
* [mini-manifest.csv]({{ site.baseurl }}/assets/mini-manifest.csv) (N=9 samples 18 fastq files)
* [mini-metadata.tsv]({{ site.baseurl }}/assets/mini-metadata.tsv) (N=9 samples with metadata)

**Folder structure**

This tutorial will assume the following folder structure where `Sample_A_1.fastq.gz` is the forward read file for *sample_A* and `Sample_A_2.fastq.gz` is the reverse read file for *sample_A*. The naming may not be exactly the same depending on the sequencing platform but generally follows some format (e.g. *_1/2, *_R1/R2, etc).

```
<PROJECT_PATH>
├── manifest.csv
└── raw_data/
    ├── Sample_A_1.fastq.gz
    ├── Sample_A_2.fastq.gz
    ├── Sample_B_1.fastq.gz
    ├── Sample_B_2.fastq.gz
    └── ...
```

From here on, `<PROJECT_PATH>` will refer to the root directory as depicted above. Replace this with the path to where you downloaded the tutorial data.

---

# Step 1: QC module

## a) QC: introduction

Quality control checks to make sure that the sequenced reads obtained from the sequencing machine is of good quality. Bad quality reads or artefacts due to sequencing error if not removed can lead to spurious results and affect downstream analyses. There are a number of tools available for checking read quality of high-throughput read sequences.

This step must be done before Taxonomy and Function profilng.

This pipeline uses the following tools:

* [BBTool suite](https://jgi.doe.gov/data-and-tools/software-tools/bbtools/)
* [Fastp](https://github.com/OpenGene/fastp)
* [Minimap2](https://github.com/lh3/minimap2)

**Pipeline**

The bash scripts generated by this step performs the following 4 key steps. The module also generates $N$ number of PBS scripts (default=4 using the `--num-pbs-jobs` parameter setting), which calls the bash scripts sequentially.

> In this tutorial, we have 9 samples which we will spread across 3 PBS jobs. The output will consists of 9 bash scripts and 3 PBS scripts, where one PBS will execute quality checking for three samples.

Key steps in the quality control module are shown in the figure below and described as follows:

![QC PBS pipeline]({{site.baseurl}}/assets/img/tutorials/no-singularity/tut_QCpipeline.png)

1. **repair** - uses repair.sh from BBTools/BBMap tool suite - repairs the sequenced reads and outputs any singleton reads (these are orphaned reads that are missing either the forward or reverse partner read)
2. **dereplicate** - uses clumpify.sh from BBTools/BBMap tool suite and removes duplicate reads. It also clusters reads for faster downstream processing
3. **quality check** - uses fastp.sh and checks the quality of the reads and removes any reads that are of low quality, too long or too short
4. **decontamination** - uses minimap2.sh, which maps sequenced reads against a user-specified reference genome (fasta) file (e.g., human) and removes these host-reads from the data. The **cleaned** sequence output then becomes the input for the next steps: taxonomy or function profiling.

There is an optional step in the diagram (QC_report) that generates a summary report *after all* PBS scripts have been run for all samples in the study.

## b) QC: Generate PBS scripts

* In the terminal, type the following command
    * Replace `<your.email@address.com>` with your own email address
    * Replace `<PROJECT_PATH>` with where you created the folder, inside which should have the `raw_data` subfolder with the downloaded *.fastq.gz files
        * Hence forth, we will use `<PROJECT_PATH>` to refer to the root project folder
        * The `output` sub-directory will be automatically created with this step within the `<PROJECT_PATH>`, if you named it something different, just replace every subsequent mention of `<PROJECT_PATH>/output`
    * *Note* full pathnames are required for the input (`-i`) and output (`-o`) parameters

```
$ python3 qc_module.py -i /<PROJECT_PATH>/raw_data/ \
-o /<PROJECT_PATH>/output \
-m <PROJECT_PATH>/manifest.csv \
--num-pbs-jobs 3 \
-e <your.email@address.com>
```

note:* the command above can all be typed on one line without the backslash `\` that is showing at the end of each line. The `\` tells the terminal that the command continues on the next line. We use this notation as limited space if this tutorial was printed.

**Required parameters**

| Parameters | Description |
| ---------- | ----------- |
| `-i <input>` | must be *full path* to where the raw sequenced reads are stored (these files often have the *.fastq.gz or *.fq.gz extension). This path is used to find the *FileID_R1* and *FileID_R2* columns specified in the *manifest.csv* file provided (see below). |
| `-o <output>` | must be the *full path* to where you would like the output files to be saved. The `<output>` path will be created if it does not exists. **Note** if there are already existing subdirectories in the `<output>` path, then this step will fail. |
| `-e <email>` | email address for the PBS script so that you are notified when your PBS jobs complete (note that the current configuration generates one PBS script per sample file, so you will get an alert per job. So, if you have 100 samples in your study, you will have 100 emails) |
| `-m <manifest.csv>` | a comma-seperated file (*.csv) that has three columns with the headers: **Sample_ID, FileID_R1, FileID_R2** see the example below. *Note* the fileID_R1 and fileID_R2 are relative to the `-i <input>` path provided. |

*Manifest.csv* file example

```
Sample_ID,FileID_R1,FileID_R2
SRR17380209,SRR17380209.sra_1.fastq.gz,SRR17380209.sra_2.fastq.gz
SRR17380232,SRR17380232.sra_1.fastq.gz,SRR17380232.sra_2.fastq.gz
SRR17380236,SRR17380236.sra_1.fastq.gz,SRR17380236.sra_2.fastq.gz
SRR17380231,SRR17380231.sra_1.fastq.gz,SRR17380231.sra_2.fastq.gz
SRR17380218,SRR17380218.sra_1.fastq.gz,SRR17380218.sra_2.fastq.gz
...
```

**Expected output**

* After this command you should get a new `output` directory within `<PROJECT_PATH>`
* Within `output/`, there will be a sub-drectory `QC_module`
    * Inside `output/QC_module` should be one PBS script (files with *.pbs extension) for each of the samples specified in the `manifest.csv` file
    * We need these PBS scripts for the next step

```
<PROJECT_PATH>
└── output/
    ├── QC_module
        ├── CleanReads
        ├── QCReport
        ├── qcModule_0.pbs
        ├── qcModule_1.pbs
        ├── qcModule_2.pbs
        ├── SRR17380209.sh
        ├── SRR17380231.sh
        ├── SRR17380232.sh
        ├── SRR17380236.sh
        ├── ...
```

## c) QC: Submit PBS jobs

* Navigate to the `<PROJECT_PATH>/output/QC_module` (replace `<PROJECT_PATH>` with where you created the folder)
* List the files in this directory, you should see one `*.pbs` file for each of your samples that was listed in the *manifest.csv* file
* Submit the job by typing the `qsub` command
* You can check the job has been submitted with `qstat`

```
$ cd <PROJECT_PATH>/output/QC_module
$ ls
$ qsub qcModule_0.pbs
$ qstat -u $USER
```

* Wait until the job is submitted and complete

## d) QC: Outputs

* The output directory structure will look like this (we only show the output of two samples `SRR17380209` and `SRR17380232` in the diagram below, the `...` means *"and others"*)

```
<PROJECT_PATH>
└── output/
    └── QC_module
        ├── CleanReads
        │   ├── SRR17380209_clean_1.fastq.gz
        │   ├── SRR17380209_clean_2.fastq.gz
        │   ├── SRR17380232_clean_1.fastq.gz
        │   ├── SRR17380232_clean_2.fastq.gz
        │   └── ...
        ├── QCReport
        │   ├── SRR17380209.json
        │   ├── SRR17380209.outreport.html
        │   ├── SRR17380232.json
        │   ├── SRR17380232.outreport.html
        │   └── ...
        ├── SRR17380209.sh
        ├── SRR17380209_qc_module.o2806827
        ├── SRR17380209_singletons.fq.gz
        ├── SRR17380232.sh
        ├── SRR17380232_qc_module.o2806830
        ├── SRR17380232_singletons.fq.gz
        └── ...
```

**Output files**

| Directory / Files | Description |
| ----------------- | ----------- |
| output | specified in the `--output-dir <output>` parameter set in step 1b) |
| QC_module | contains all files and output from this step |
| QC_module/*.sh | are all the bash scripts generated by step 1b), there is one bash script per sample |
| QC_module/*.pbs | are all the PBS wrapper scripts generated by step 1b) and calls the bash scripts sequentially. One PBS script will process multiple samples |
| QC_module/CleanReads | saves the cleaned reads after submitting the PBS jobs |
| QC_module/QCReport | output from Fastp tool, one HTML and one json file per sample |

**Log files**

* When the job is done, you should have one log file per sample and (one PBS log file per `qcModule_N.pbs` script). For PBS log files, they will have the `*.o{PBS_JOBID}` file extension and will contain console output from the processes
    * the `{PBS_JOBID}` is often a sequence of numbers that was your PBS job ID
    * if errors occurs, log files are a good place to look to find out what happened
* Check that you have outputs in the `CleanReads` folder before moving onto the next step
* Replace `<PROJECT_PATH>` with where you created the folder

``` bash
$ cd <PROJECT_PATH>/output/QC_module/CleanReads
$ ls -lh
```

## e) (Optional) QC Report

{% include alert.html type="warning" title="Note" content="This step occurs after all the PBS jobs for QC have completed" %}

* You can also generate a summary QC Report after *all samples* have been quality checked
* This step can be run directly from commandline and does not generate a PBS script

> Beware that if you have failed PBS log files (*.o) in your input directory, the qc_report.py module will not give a nice error and may fail. It reads in all PBS log files in the input directory including those that failed.

* In the terminal, type the following command:
    * Replace `<PROJECT_PATH>` with the location of what you saved your project

```
$ python3 qc_report.py -i /<PROJECT_PATH>/output/QC_module \
-o /<PROJECT_PATH>/output \
--manifest <PROJECT_PATH>/manifest.csv
```

* Output is a comma-seperated table file located in `<PATH_PROJECT>/output/QC_module/QC_report.csv`

---

# Step 2) Taxonomy profiling

## a) Taxa: introduction

Taxonomy profiling takes the cleaned sequence reads as input and matches them against a reference database of previously characterised sequences for taxonomy classification. There are many different classification tools, for example: Kraken2, Metaphlan, Clark, Centrifuge, MEGAN, and many more.

This pipeline uses Kraken2, which comes with its own reference database but you can also generate your own. In this pipeline, we will use the [GTDB](https://gtdb.ecogenomic.org/) database (release 95) and have built a Kraken2 database.

**Pipeline**

One bash script per sample is generated and since Kraken requires big memory, there will only be one PBS script that will execute each sample sequentially.

> In this tutorial, we have 9 samples which will be executed within one PBS job. The output will consists of 9 bash scripts and one PBS script.

Key steps in the taxonomy profiling module are shown in the figure below and described as follows:

![Taxonomy PBS script mini-pipeline using Kraken2 classifier]({{site.baseurl}}/assets/img/tutorials/no-singularity/tut_TAXApipeline.png)

1. Kraken2 classifies the reads to taxa
2. Bracken takes the Kraken2 output to estimate abundances for a given taxonomic rank
3. The final step (**generate table**) is performed after *all samples* have been processed. This combines the output and generates a *feature table* for a given taxonomic rank. The feature table contains the count or relative abundances of taxon X occuring in sample Y.

## b) Taxa: Generate PBS scripts

* In the terminal, type the following command
    * Replace `<your.email@address.com>` with your own email address
    * Replace all the `<PROJECT_PATH>` with where you created the folder during setup
    * *Note* full pathnames are required for the input (`-i`), output (`-o`), and reference (`--reference-path`) parameters

```
$ python3 taxa_module.py -i <PROJECT_PATH>/output/QC_module/CleanReads \
-o <PROJECT_PATH>/output \
--fwd-suffix _clean_1.fq.gz \
--rev-suffix _clean_2.fq.gz \
--reference-path /srv/scratch/mrcbio/db/GTDB/GTDB_Kraken2 \
--read-length 150 \
--threshold 100 \
-e <your.email@address.com> 
--walltime 24
--mem 300
```

**Required parameters**

| Parameters | Description |
| ---------- | ----------- |
| `-i <input>` | full path to the `<PROJECT_PATH>/output/QC_module/CleanReads` directory that was generated from Step 1) QC, above. This directory should hold all the `*_clean.fastq` files |
| `-o <output>` | full path to the `<PROJECT_PATH>/output` output directory where you would like the output files to be saved, can be the same as Step 1) QC |
| `--fwd-suffix`/`--rev-suffix` | file suffix for cleaned reads from QC module |
| `--reference-path` | full path to the reference database (this pipeline uses the GTDB release 95 reference database) |
| `--read-length` | read length for Bracken estimation, choose the value closests to your sequenced read length (choose from 50, 75, 100 and 150) |
| `--threshold` | Bracken filtering threshold, features with counts below this value are filtered in the abundance estimation |

**PBS parameters**

| Parameters | Description |
| ---------- | ----------- |
| `-e <email>` | address for the PBS script so that you are notified when your PBS jobs complete (note that the current configuration generates one PBS script per sample file, so you will get an alert per job. So, if you have 100 samples in your study, you will have 100 emails) |
| `--walltime` | number of hours one PBS job needs for one sample. *Note* Kraken2 is very quick but it does need lots of RAM, see next parameter. |
| `--mem` | gigabyte memory (RAM) required by this PBS job. *Note* Kraken2 needs a lot of memory so we set this to 300GB. |

**Expected output**

* After this step you should get the following PBS scripts (again, one for each sample) in the output directory `<PROJECT_PATH>/output/Taxonomy_profiling`
* **braken/** and **kraken2/** are subdirectories created by this step and will store the output files from the processes called in the PBS script

```
<PROJECT_PATH>
└── output/
    └── Taxonomy_profiling/
        ├── bracken/
        ├── featureTables/
        │   └── generate_bracken_feature_table.py
        ├── kraken2/
        ├── run_taxa_profiling.pbs
        ├── SRR17380209.sh
        ├── SRR17380231.sh
        └── ...
```

## c) Taxa: Submit PBS jobs

* Go to `<PROJECT_PATH>/output/Taxonomy_profiling` directory
* Submit PBS script with `qsub`
* You can check the job has been submitted with `qstat`

```
$ cd <PROJECT_PATH>/output/Taxonomy_profiling
$ qsub run_taxa_profiling.pbs
$ qstat -u $USER
```

## d) Taxa: Outputs

* After the PBS jobs have completed, you should get the following files for one sample
* We only show the outputs for **one** sample, *SRR17380209*, in the tree below and `...` means *"and others"*

```
<PROJECT_PATH>
└── output/
    └── Taxonomy_profiling/
        ├── bracken
        │   ├── SRR17380209_class
        │   ├── SRR17380209_family
        │   ├── SRR17380209_genus
        │   ├── SRR17380209.k2_bracken_classes.report
        │   ├── SRR17380209.k2_bracken_families.report
        │   ├── SRR17380209.k2_bracken_genuses.report
        │   ├── SRR17380209.k2_bracken_orders.report
        │   ├── SRR17380209.k2_bracken_phylums.report
        │   ├── SRR17380209.k2_bracken_species.report
        │   ├── SRR17380209_order
        │   ├── SRR17380209_phylum
        │   ├── SRR17380209_species
        │   └── ...
        ├── featureTables
        ├── kraken2
        │   ├── SRR17380209.kraken2.output
        │   ├── SRR17380209.kraken2.report
        │   └── ...
        ├── run_taxa_profiling.pbs
        ├── SRR17380209.sh
        ├── SRR17380209_taxaAnnot.o2807163
        └── ...
```

**Output files**

| Directory / Files | Description |
| ----------------- | ----------- |
| output | specified in the `--output-dir <output>` parameter set in step 1b) |
| Taxonomy_profiling | contains all files and output from this step |
| Taxonomy_profiling/*.sh | are all the bash scripts generated by step 2b) for taxonomy profiling |
| Taxonomy_profiling/run_taxa_profiling.pbs | is the PBS wrapper generated by step 2b) that will execute each sample sequentially |
| Taxonomy_profiling/bracken | consists of the abundance estimation files from Bracken, one per sample, output after PBS submission |
| Taxonomy_profiling/featureTables | consists of the merged abundance tables generated by step 2e) below |
| Taxonomy_profiling/kraken2 | consists of the output from Kraken2 (two files per sample), output after PBS submission |

**Profiler output**

* For details of Kraken2 output files, see their [documentation](https://github.com/DerrickWood/kraken2/wiki/Manual#output-formats)
* For details of Bracken output files, see their [documentation](https://ccb.jhu.edu/software/bracken/index.shtml?t=manual#format)

## e) Taxa: Generate taxonomic feature table(s)

{% include alert.html type="warning" title="Note" content="This step occurs after all the PBS jobs for Taxonomy profiling have completed" %}

* After **all samples** have been taxonomically annotated, we need to combine the estimated abundances into a single feature table
* We will combine the output from Bracken for each taxonomic ranks (Phylum to Species), so we should have 7 output files
* In the terminal, navigate to the `<PROJECT_PATH>/output/Taxonomy_profiling/featureTables` directory and there should be a file named `generate_bracken_feature_table.py` (line 1 below)
* Activate the `mima` conda environment if not already done (line 2)
* Execute this script (line 3)

```
$ cd <PROJECT_PATH>/output/Taxonomy_profiling/featureTables
$ conda activate mima
$ python3 generate_bracken_feature_table.py
```

* Inspect the output directory `featureTables/`, which should resemble the following tree structure
* There will be 4 output files per taxonomic rank
* We have only shown the set of output files for ranks `class` and `species` (with `...` meaning *"and others"*)

```
<PROJECT_PATH>
└── output/
    ├── QC_module/
    └── Taxonomy_profiling/
        ├── ...
        ├── bracken/
        ├── featureTables/
        │   ├── bracken_FT_class
        │   ├── bracken_FT_class_counts
        │   ├── bracken_FT_class_relAbund
        │   ├── ...
        │   ├── bracken_FT_species
        │   ├── bracken_FT_species_counts
        │   ├── bracken_FT_species_relAbund
        │   ├── combine_bracken_class.log
        │   ├── ...
        │   ├── combine_bracken_species.log
        │   └── generate_bracken_feature_table.py
        └── kraken2/
```

| Outputs | Description |
| ------- | ----------- |
| {class}_FT_class | is the combined bracken output for the taxonomic CLASS rank, by default Bracken will estimate discrete read counts (_num columns) and relative abundances (_frac columns). This file contains both columns for each taxon. |
| {class}_FT_class_counts | splits the feature table and extracts the *counts* for the CLASS rank |
| {class}_FT_class_relAbund | splits the feature table and extracts the *relative abundance* for the CLASS rank |
| combine_bracken_{class}.log | log file output from the combine_bracken_table.py script from Bracken tool |
| generate_bracken_feature_table.py | python script to combine and the feature tables from multiple samples and then split into *counts* and *relative abunances* tables |

---

# Step 3) Functional profiling

## a) Function: introduction

Functional profiling, like taxonomy profiling, takes the cleaned sequenced reads as input and matches them against a reference database of previously charactered sequences to annotate as genes. There are different types of functional classification tools available.

This pipeline uses [HUMAnN3](https://huttenhower.sph.harvard.edu/humann/), which comes with its own reference databases. You will need to download these on to the HPC system you are working with if it's not already done so. If it's already downloaded, then you will need to know the paths to the reference databases for this step.

**ADD REFERENCE DATABASE INFO**

**Pipeline**

One PBS script per sample will be generated in this step. The key steps are shown in the figure below and described as follows:

![Function mini-pipeline]({{site.baseurl}}/assets/img/tutorials/no-singularity/tut_function_pipeline.png)

1. HUMAnN3 is used for processing and generates three outputs for each sample: (i) gene families, (ii) pathway abundances and (iii) pathway coverage
2. The final step (**generate table**) is performed after *all samples* have been processed. This combines the output and generates a *feature table*. The feature table contains the abundance of gene/pathway X in sample Y.

## b) Function: Generate PBS scripts

* In the terminal, type the following command
    * Replace `<your.email@address.com>` with your own email address
    * Replace all the `<PROJECT_PATH>` with where you created the folder during setup
    * *Note* full pathnames are required for the input (`-i`), output (`-o`), and reference paths parameters

{% include alert.html type="danger" title="ALERT" content="must provide the `--nucleotide-database` and `--protein-database` paths, while there is a default value set, this is unlikely to be the right location" %}

```
$ python3 func_profiling.py -i /<PROJECT_PATH>/output/QC_module/CleanReads \
-o /<PROJECT_PATH>/output \
--fwd-suffix _clean_1.fq.gz \
--rev-suffix _clean_2.fq.gz \
--nucleotide-database <PATH/to/humann/chocophlan> \
--protein-database <PATH/to/humann/uniref> \
--metaphlan-database <PATH/to/metaphlan_databases> \
-e <your.email@address.csom> \
--walltime 8
```

**Required parameters**

| Parameters | Description |
| ---------- | ----------- |
| `-i <input>` | full path to the `<PROJECT_PATH>/output/QC_module/CleanReads` directory that was generated from Step 1) QC, above. This directory should hold all the `*_clean.fastq` files |
| `-o <output>` | full path to the `<PROJECT_PATH>/output` output directory where you would like the output files to be saved, can be the same as Step 1) QC |
| `--fwd-suffix`/`--rev-suffix` | file suffix for cleaned reads from QC module |
| `--nucleotide-database <path>` | directory containing the nucleotide database, DEFAULT: /refdb/humann/chocophlan |
| `--protein-database <path>` | directory containing the protein database, DEFAULT: /refdb/humann/uniref |
| `--metaphlan-database <path>` | directory containing the metaphlan database, DEFAULT: /refdb/humann/metaphlan_databases |

**PBS parameters**

| Parameters | Description |
| ---------- | ----------- |
| `-e <email>` | address for the PBS script so that you are notified when your PBS jobs complete (note that the current configuration generates one PBS script per sample file, so you will get an alert per job. So, if you have 100 samples in your study, you will have 100 emails) |
| `--walltime` | number of hours one PBS job needs for one sample |

**Expected output**

* After this step you should get the following PBS scripts (one per sample) in the output directory `<PROJECT_PATH>/output/Function_profiling`

```
<PROJECT_PATH>
└── output/
    ├── Function_profiling/
    │   ├──featureTables/
    │   │   └── generate_func_feature_tables.pbs
    │   ├── SRR17380209.pbs
    │   ├── SRR17380232.pbs
    │   ├── ...
    └── ...
```

## c) Function: Submit PBS jobs

* Go to <PROJECT_PATH>/output/Function_profiling directory
* Submit PBS script with `qsub`
* You can check the job has been submitted with `qstat`

```
$ cd <PROJECT_PATH>/output/Function_profiling
$ qsub SRR17380209.pbs
$ qstat -u $USER
```

## d) Function: Outputs

* After the PBS jobs have completed, you should get the following files
* We only show the outputs for **one** sample, *SRR17380209* in the tree view below

```
<PROJECT_PATH>/
└── output/
    ├── Function_profiling
    │   ├── featureTables/
    │   │   └── generate_func_feature_tables.pbs
    │   ├── SRR17380209_combine_genefamilies.tsv
    │   ├── SRR17380209_combine_pathabundance.tsv
    │   ├── SRR17380209_combine_pathcoverage.tsv
    │   ├── SRR17380209_humann.o2807590
    │   ├── SRR17380209.pbs
    │   ├── SRR17380209_combine_humann_temp/
    │   └── ...
    └── ...
```

**Profiler output**

* For details of HUMAnN3 output files, see their [documentation](https://github.com/biobakery/humann#output-files)

## e) Function: Generate function feature table(s)

{% include alert.html type="warning" title="Note" content="This step occurs after all the PBS jobs for Function profiling have completed" %}

* After **all samples** have been functionally annotated, we need to combine the tables together and normalise the abundances
* There will be a table for
    * genefamilies
    * pathabundances
    * pathcoverages
* In the terminal, navigate to the `<PROJECT_PATH>/output/Fuctional_profiling/featureTables` (line 1 below)
* Submit the PBS script named `generate_func_feature_tables.pbs` (line 2)

```
$ cd <PROJECT_PATH>/output/Functional_profiling/featureTables
$ qsub generate_func_feature_tables.pbs
```

**Output**

* Once the job completes you will have 7 output files, those starting with `merge_humann3table_` prefixes

```
<PROJECT_PATH>/
└── output/
    ├── Function_profiling
    │   ├── featureTables
    │   ├── func_table.o2807928
    │   ├── generate_func_feature_tables.pbs
    │   ├── merge_humann3table_genefamilies.cmp_uniref90_KO.txt
    │   ├── merge_humann3table_genefamilies.cpm.txt
    │   ├── merge_humann3table_genefamilies.txt
    │   ├── merge_humann3table_pathabundance.cmp.txt
    │   ├── merge_humann3table_pathabundance.txt
    │   ├── merge_humann3table_pathcoverage.cmp.txt
    │   └── merge_humann3table_pathcoverage.txt
    ├── ...
```

----

# Congratulations !

You have completed processing your metagenomics data and are now ready for further analyses

Analyses usually take in the feature-tables that were created in Step 2e) Taxonomy feature tables and Step 3e) Function feature tables.