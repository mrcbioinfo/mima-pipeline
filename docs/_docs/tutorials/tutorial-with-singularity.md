---
title: Tutorial with Singularity
---

# Data processing with Singularity

This tutorial takes you through the steps of running the MIMA pipeline for data processing of shotgun metagenomics sequenced reads using the assembly-free approach. 

This tutorial depends on the following:

- **Compute environment**
  - OpenPBS system on a high-performance cluster (HPC)
  - You have already setup the environment with the MIMA Conda package as specified in the \[Installation guide\]\(\{\{ site\.baseurl \}\}/docs/installation\)
  - System must have `Singularity` installed

{% include alert.html type="danger" title="to-do" content="The tutorial assumes that you will be running the pipeline one a PBS (or have a queuing management system) system with `Singuarlity` installed via `modules`" %}

- **Reference databases**
  - Many of the data processing steps require access to reference databases that are too big to be included in the Singularity container
  - You will need to have these already installed on your system or HPC environment and tell the pipeline of the location (this will be detailed in the relevant steps)

- **Study data assumptions**
  - Paired-end sequencing with two files \_R1 and \_R2 files
  - By default the pipeline assumes human-host metagenomics studies and decontamination is done against the human genome, you can provide alternative references (see the tutorial or command usage documentation)

# The pipeline

The pipeline consists of the following components which are shown in the schema and briefly described below.

\!\[\]\(\{\{ site\.baseurl\}\}/assets/img/tutorials/no\-singularity/tut\_OverallSchema\.png\)

**Data processing**

1. Quality control (QC) of the sequenced reads
2. Taxonomy profiling after QC (this step can be run in parallel with step 3)
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

# Set up

## MIMA pipeline Singularity container

- Download [mima-pipeline.sif] image
- Download the [pbs\_headers.tar] archive, inside are three PBS configuration files

```
$ mkdir mima_tutorial
$ cd mima_tutorial
$ wget
$ tar -xf pbs_headers.tar
$ ll
```

### Load `Singularity`

```
$ module load singularity
$ singularity --version
```

```
- usually load the latest version that's installed on your system, or you can specify a specific version using `module load singularity/3.6.4`
- at the time of writing this tutorial we were using `singularity version 3.6.4`
```

### Build sandbox and configure environment variables

- Unpack the image into a container for faster running

```
$ module load singularity
$ singularity build --sandbox mima-pipeline mima-pipeline.sif
$ export SANDBOX=`pwd`/mima-pipeline
$ tree -L 1 -d $SANDBOX
```

- the created sandbox `mima-pipeline` is a filesystem that has the following structure

```
mima-pipeline/
├── bin -> usr/bin
├── boot
├── dev
├── etc
├── home
├── lib -> usr/lib
├── lib32 -> usr/lib32
├── lib64 -> usr/lib64
├── libx32 -> usr/libx32
├── media
├── mnt
├── opt
├── proc
├── refdb
├── root
├── run
├── sbin -> usr/sbin
├── scif
├── srv
├── sys
├── tmp
├── usr
└── var
```

### Test MIMA-pipeline

- test that the `SANDBOX` environment variable and the sandbox is working by running the following command

```
$ singularity run $SANDBOX
```

- below is the output
    - ignore the first 4 lines that begin with `source`, this is a known issue resulting from the r-base conda build (third-party tools) but it shouldn't affect the running of this pipeline
    - these 4 lines will continue to appear when interactively using the sandbox for some of the steps in this tutorial

```
source: /opt/miniconda/envs/mima/etc/conda/activate.d/activate-binutils_linux-64.sh:10:40: parameter expansion requires a literal
source: /opt/miniconda/envs/mima/etc/conda/activate.d/activate-gcc_linux-64.sh:10:40: parameter expansion requires a literal
source: /opt/miniconda/envs/mima/etc/conda/activate.d/activate-gfortran_linux-64.sh:10:40: parameter expansion requires a literal
source: /opt/miniconda/envs/mima/etc/conda/activate.d/activate-gxx_linux-64.sh:10:40: parameter expansion requires a literal
----
This singularity container contains MIMA conda environment
v1.0.0 - build: 2022-09-06

     active environment : mima
    active env location : /opt/miniconda/envs/mima
            shell level : 1
       user config file : /home/z3534482/.condarc
 populated config files : /home/z3534482/.condarc
          conda version : 4.12.0
    conda-build version : not installed
         python version : 3.9.12.final.0
       virtual packages : __linux=3.10.0=0
                          __glibc=2.35=0
                          __unix=0=0
                          __archspec=1=x86_64
       base environment : /opt/miniconda  (read only)
      conda av data dir : /opt/miniconda/etc/conda
  conda av metadata url : None
           channel URLs : https://conda.anaconda.org/biobakery/linux-64
                          https://conda.anaconda.org/biobakery/noarch
                          https://conda.anaconda.org/bioconda/linux-64
                          https://conda.anaconda.org/bioconda/noarch
                          https://repo.anaconda.com/pkgs/main/linux-64
                          https://repo.anaconda.com/pkgs/main/noarch
                          https://repo.anaconda.com/pkgs/r/linux-64
                          https://repo.anaconda.com/pkgs/r/noarch
                          https://conda.anaconda.org/conda-forge/linux-64
                          https://conda.anaconda.org/conda-forge/noarch
                          https://conda.anaconda.org/default/linux-64
                          https://conda.anaconda.org/default/noarch
          package cache : /opt/miniconda/pkgs
                          /home/z3534482/.conda/pkgs
       envs directories : /home/z3534482/.conda/envs
                          /opt/miniconda/envs
               platform : linux-64
             user-agent : conda/4.12.0 requests/2.27.1 CPython/3.9.12 Linux/3.10.0-1160.62.1.el7.x86_64 ubuntu/22.04.1 glibc/2.35
                UID:GID : 13534482:40064
             netrc file : None
           offline mode : False

Python 3.10.5
Rscript (R) version 4.2.1 (2022-06-23)
humann v3.1.1
```

# Tutorial data

In this tutorial we will use data from the study by [*Tourlousse, et al. (2022)*](https://journals.asm.org/doi/10.1128/spectrum.01915-21), **Characterization and Demonstration of Mock Communities as Control Reagents for Accurate Human Microbiome Community Measures**, Microbiology Spectrum.

> This data set consists of two mock communities: *DNA-mock* and *Cell-mock*. The mock communities consists of bacteria that are mainly detected the human gastrointestinal tract ecosystem with a small mixture of some skin microbiota. The data was processed in three different labs: A, B and C. In the previous tutorial, , we only processed a subset of the samples (n=9). In this tutorial we will be working with the full data set which has been pre-processed using the same pipeline. In total there were 56 samples of which 4 samples fell below the abundance threshold and therefore the final taxonomy abundance table has 52 samples. We will train the random forest classifier to distinguish between the three labs.

* The raw reads are available from NCBI SRA [Project PRJNA747117](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA747117)
* There are 56 paired-end samples (112 fastq files)
    * As the data is very big we will work with a smaller subset to speed up processing
    * You can download the fastq files using this script which requires the `sratoolkit`

**Data files**

{% include alert.html type="danger" title="to-do" content="Add script to download fastq files" %}

* \[mini\-SRA\-accession\-list\]\(\{\{ site\.baseurl \}\}/assets/mini\-SRA\-accession\-list\) \(N=9 samples to download fastq\)
* \[mini\-manifest\.csv\]\(\{\{ site\.baseurl \}\}/assets/mini\-manifest\.csv\) \(N=9 samples 18 fastq files\)
* \[mini\-metadata\.tsv\]\(\{\{ site\.baseurl \}\}/assets/mini\-metadata\.tsv\) \(N=9 samples with metadata\)

**Folder structure**

This tutorial will assume the following folder structure where `Sample_A_1.fastq.gz` is the forward read file for *sample\_A* and `Sample_A_2.fastq.gz` is the reverse read file for *sample\_A*. The naming may not be exactly the same depending on the sequencing platform but generally follows some format (e.g. \*\_1/2, \*\_R1/R2, etc).

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

- You need to have 20GB of disk space preferably in your **home directory*- (`~`)


----

# Step 1: QC module

## 1a) QC: introduction

## 1b) QC: Generate PBS scripts

- The following command is all one line without the backslashes (`\`)
    - the backslash (`\`) at the end of each line informs the terminal that the command has not finished and there's more to come
    - we break up the command for readability purposes to explain each parameter

```
$ python3 qc_module.py -i ~/mima_tutorial/raw_data \
-o ~/mima_tutorial/output \
-m ~/mima_tutorial/manifest.csv \
-e your.email@addr.com \
--mode singularity \
--pbs-config pbs_header_qc.cfg
```

**Output:**

- Examine the output files

```
$ tree ~/mima_tutorial/output/QC_module
```

```
.
├── CleanReads
├── qcModule_0.pbs
├── qcModule_1.pbs
├── qcModule_2.pbs
├── QCReport
├── SRR17380115.sh
├── SRR17380118.sh
├── SRR17380122.sh
├── SRR17380209.sh
├── SRR17380218.sh
├── SRR17380222.sh
├── SRR17380231.sh
├── SRR17380232.sh
└── SRR17380236.sh
```

## 1c) QC: Submit PBS jobs

- Examine one of the PBS scripts to be submitted

```
$ cd ~/mima_tutorial/output/QC_module/qcModule_0.pbs
```

```
#!/bin/bash
#PBS -N QC_module_0
#PBS -l ncpus=8
#PBS -l walltime=2:00:00
#PBS -l mem=64GB
#PBS -m ae
#PBS -j oe

set -x
module load singularity/3.6.4

IMAGE_DIR=/home/z3534482/scratch/29_MRC_Pipelines/29.02_MRC_SS/mima-singularity-XYC/mima-pipeline
export SINGULARITY_BIND="/srv/scratch/z3534482:/srv/scratch/z3534482,/srv/scratch/mrcbio:/srv/scratch/mrcbio,/srv/scratch/mrcgut:/srv/scratch/mrcgut"


cd /home/z3534482/examples/mini_mock_v2/output03/QC_module/

singularity exec ${IMAGE_DIR} bash /home/z3534482/examples/mini_mock_v2/output03/QC_module/SRR17380209.sh > SRR17380209_qc_module.log 2>&1
singularity exec ${IMAGE_DIR} bash /home/z3534482/examples/mini_mock_v2/output03/QC_module/SRR17380232.sh > SRR17380232_qc_module.log 2>&1
singularity exec ${IMAGE_DIR} bash /home/z3534482/examples/mini_mock_v2/output03/QC_module/SRR17380236.sh > SRR17380236_qc_module.log 2>&1
```

- Submit the PBS job

```
$ qsub qcModule_0.pbs
```

## 1d) QC: outputs

- After the PBS job completes then you should have the following outputs

```
$ tree ~/mima_tutorial/output/QC_module
```

- only a subset of the outputs are shown below with `...` meaning *and others*
- you'll have a set of output for each sample listed in the `manifest.csv` file

```
.
├── CleanReads
│   ├── SRR17380209_clean_1.fq.gz
│   ├── SRR17380209_clean_2.fq.gz
│   └── ...
├── QC_module_0.o3492023
├── qcModule_0.pbs
├── qcModule_1.pbs
├── qcModule_2.pbs
├── QCReport
│   ├── SRR17380209.json
│   ├── SRR17380209.outreport.html
│   └── ...
├── ...
├── SRR17380209_qc_module.log
├── SRR17380209.sh
├── SRR17380209_singletons.fq.gz
└── ...
```

## 1e) (Optional) QC report


----

# Step 2: Taxonomy profiling

## 2a) Taxa: introduction

## 2b) Taxa: Generate PBS script

- The following command is all one line without the backslashes (`\`)
    - the backslash (`\`) at the end of each line informs the terminal that the command has not finished and there's more to come
    - we break up the command for readability purposes to explain each parameter

```
$ python3 taxa_module.py -i ~/examples/mini_mock_v2/output03/QC_module/CleanReads \
-o ~/examples/mini_mock_v2/output03 \
--reference-path ~/scratch/REF/GTDB/release_95/GTDB_Kraken2 \
--fwd-suffix _clean_1.fq.gz \
--rev-suffix _clean_2.fq.gz \
--read-length 150 \
--threshold 100 \
-e your.email@address.com \
--mode singularity \
--pbs-config pbs_header_taxa.cfg
```

- Examine the output files

```
$ cd ~/mima_tutorial/output/Taxonomy_profiling
$ tree .
```

**Output:**

- Examine the output files

```
.
├── bracken
├── featureTables
│   └── generate_bracken_feature_table.py
├── kraken2
├── run_taxa_profiling.pbs
├── SRR17380209.sh
├── SRR17380232.sh
└── SRR17380236.sh
```

## 2c) Taxa: Submit PBS job

- First we'll examine the PBS script to be submitted

```
$ cat ~/mima_tutorial/output/Taxonomy_profiling/run_taxa_profiling.pbs
```

- only the top lines are shown with `...` at the end meaning more
- the first N lines are directly copied from the `pbs_header.cfg` file
- you must specify the

```
#!/bin/bash
#PBS -N QC_module_0
#PBS -l ncpus=28
#PBS -l walltime=10:00:00
#PBS -l mem=300GB
#PBS -m ae
#PBS -j oe

set -x
module load singularity/3.6.4

IMAGE_DIR=/home/z3534482/scratch/29_MRC_Pipelines/29.02_MRC_SS/mima-singularity-XYC/mima-pipeline
export SINGULARITY_BIND="/srv/scratch/z3534482:/srv/scratch/z3534482,/srv/scratch/mrcbio:/srv/scratch/mrcbio,/srv/scratch/mrcgut:/srv/scratch/mrcgut"


cd /home/z3534482/examples/mini_mock_v2/output03/Taxonomy_profiling/

singularity exec ${IMAGE_DIR} bash /home/z3534482/examples/mini_mock_v2/output03/Taxonomy_profiling/SRR17380209.sh
singularity exec ${IMAGE_DIR} bash /home/z3534482/examples/mini_mock_v2/output03/Taxonomy_profiling/SRR17380232.sh
singularity exec ${IMAGE_DIR} bash /home/z3534482/examples/mini_mock_v2/output03/Taxonomy_profiling/SRR17380236.sh
singularity exec ${IMAGE_DIR} bash /home/z3534482/examples/mini_mock_v2/output03/Taxonomy_profiling/SRR17380231.sh
singularity exec ${IMAGE_DIR} bash /home/z3534482/examples/mini_mock_v2/output03/Taxonomy_profiling/SRR17380218.sh
singularity exec ${IMAGE_DIR} bash /home/z3534482/examples/mini_mock_v2/output03/Taxonomy_profiling/SRR17380222.sh
...
```

- Submit the PBS job

```
$ cd ~/mima_tutorial/output/Taxonomy_profiling
$ qsub run_taxa_profiling.pbs
```

## 2d) Taxa: outputs

- After the PBS job completes then you should have the following outputs

```
$ tree ~/mima_tutorial/output/Taxonomy_profiling
```

- only a subset of the outputs are shown below with `...` meaning *and others*
- you'll have a set of output for each sample listed in the `manifest.csv` file

```
.
├── bracken
│   ├── SRR17380218_class
│   ├── SRR17380218_family
│   ├── SRR17380218_genus
│   ├── SRR17380218.kraken2_bracken_classes.report
│   ├── SRR17380218.kraken2_bracken_families.report
│   ├── SRR17380218.kraken2_bracken_genuses.report
│   ├── SRR17380218.kraken2_bracken_orders.report
│   ├── SRR17380218.kraken2_bracken_phylums.report
│   ├── SRR17380218.kraken2_bracken_species.report
│   ├── SRR17380218_order
│   ├── SRR17380218_phylum
│   ├── SRR17380218_species
│   └── ...
├── featureTables
│   └── generate_bracken_feature_table.py
├── kraken2
│   ├── SRR17380218.kraken2.output
│   ├── SRR17380218.kraken2.report
│   ├── ...
│   ├── SRR17380231.kraken2.output
│   └── SRR17380231.kraken2.report
├── QC_module_0.o3492470
├── run_taxa_profiling.pbs
├── SRR17380209.sh
├── SRR17380218_bracken.log
├── SRR17380218.sh
├── SRR17380222_bracken.log
├── SRR17380222.sh
├── SRR17380231_bracken.log
├── SRR17380231.sh
├── SRR17380232.sh
└── SRR17380236.sh
```

## 2e) Taxa: Generate taxonomy abundance table

```
$ cd ~/mima_tutorial/output/Taxonomy_profiling/featureTables
$ singularity exec $SANDBOX python3 generate_bracken_feature_table.py
$ tree .
```

- All bracken output files from Step 3b will be concatenated into a table, one for each taxonomic rank from Phylum to Species
    - table rows are taxonomy features
    - table columns are abundances
- by default, the tables contain both discrete counts and relative abundances
- the `generate_bracken_feature_table.py` will split the default output into two files with the suffices:
    - `_counts` for discrete counts and
    - `_relAbund` for relative abundances

```
.
├── bracken_FT_class
├── bracken_FT_class_counts
├── bracken_FT_class_relAbund
├── bracken_FT_family
├── bracken_FT_family_counts
├── bracken_FT_family_relAbund
├── bracken_FT_genus
├── bracken_FT_genus_counts
├── bracken_FT_genus_relAbund
├── bracken_FT_order
├── bracken_FT_order_counts
├── bracken_FT_order_relAbund
├── bracken_FT_phylum
├── bracken_FT_phylum_counts
├── bracken_FT_phylum_relAbund
├── bracken_FT_species
├── bracken_FT_species_counts
├── bracken_FT_species_relAbund
├── combine_bracken_class.log
├── combine_bracken_family.log
├── combine_bracken_genus.log
├── combine_bracken_order.log
├── combine_bracken_phylum.log
├── combine_bracken_species.log
└── generate_bracken_feature_table.py
```


---

# Step 3: Functional profiling

## 3a) Function: introduction


## 3b) Function: Generate PBS scripts

- The following command is all one line without the backslashes (`\`)
    - the backslash (`\`) at the end of each line informs the terminal that the command has not finished and there's more to come
    - we break up the command for readability purposes to explain each parameter

```
$ python3 func_profiling.py -i /<PROJECT_PATH>/output/QC_module/CleanReads \
-o /<PROJECT_PATH>/output \
--fwd-suffix _clean_1.fq.gz \
--rev-suffix _clean_2.fq.gz \
--nucleotide-database /srv/scratch/mrcbio/db/humann3/chocophlan \
--protein-database /srv/scratch/mrcbio/db/humann3/uniref \
--metaphlan-database="--bowtie2db /srv/scratch/mrcbio/db/metaphlan_databases" \
-e <your.email@address.com> \
--mode singularity \
--pbs-config pbs_header_taxa.cfg
```

**Output:**

- Examine the output files

```
$ tree ~/mima_tutorial/output/Function_profiling
```

```
├── featureTables
│   └── generate_func_feature_tables.pbs
├── SRR17380209.pbs
├── SRR17380218.pbs
├── SRR17380222.pbs
├── SRR17380231.pbs
├── SRR17380232.pbs
└── SRR17380236.pbs
```

## 3c) Function: Submit PBS jobs

```
$ cat ~/mima_tutorial/output/Function_profiling/SRR17380209.pbs
```

```
#!/bin/bash
#PBS -N QC_module_0
#PBS -l ncpus=8
#PBS -l walltime=8:00:00
#PBS -l mem=64GB
#PBS -m ae
#PBS -j oe

set -x
module load singularity/3.6.4

IMAGE_DIR=/home/z3534482/scratch/29_MRC_Pipelines/29.02_MRC_SS/mima-singularity-XYC/mima-pipeline
export SINGULARITY_BIND="/srv/scratch/z3534482:/srv/scratch/z3534482,/srv/scratch/mrcbio:/srv/scratch/mrcbio,/srv/scratch/mrcgut:/srv/scratch/mrcgut"


cd /home/z3534482/mima_tutorial/output/Function_profiling/

# Execute HUMAnN3
cat /home/z3534482/mima_tutorial/output/QC_module/CleanReads/SRR17380209_clean_1.fq.gz /home/z3534482/mima_tutorial/output/QC_module/CleanReads/SRR17380209_clean_2.fq.gz > /home/z3534482/mima_tutorial/output/Function_profiling/SRR17380209_combine.fq.gz

outdir=/home/z3534482/mima_tutorial/output/Function_profiling/
singularity exec ${IMAGE_DIR} humann -i ${outdir}SRR17380209_combine.fq.gz --threads 28 \
-o $outdir --memory-use maximum \
--nucleotide-database /srv/scratch/mrcbio/db/humann3/chocophlan \
--protein-database /srv/scratch/mrcbio/db/humann3/uniref \
--metaphlan-options="--bowtie2db --bowtie2db /srv/scratch/mrcbio/db/metaphlan_databases" \
--search-mode uniref90
```


## 3d) Function: output

- After the PBS job completes then you should have the following outputs

```
$ tree ~/mima_tutorial/output/Function_profiling
```

- only a subset of the outputs are shown below with `...` meaning *and others*
- you'll have a set of output for each sample listed in the `manifest.csv` file

```
```

## 3e) Function: Generate function feature tables