---
title: Tutorial with Singularity
---

# Data processing with Singularity

This tutorial takes you through the steps of running the MIMA pipeline for data processing of shotgun metagenomics sequenced reads using the assembly-free approach. 

This tutorial depends on the following:

- **Compute environment**
  - OpenPBS system on a high-performance cluster (HPC)
  - System must have `Singularity` installed via `modules` (or you can skip the module lines)

- **Reference databases**
  - Many of the data processing steps require access to reference databases that are too big to be included in the Singularity container
  - You will need to have these already installed on your system or HPC environment and tell the pipeline of the locations (highlighted below)
  - See [Requirements]({{site.baseurl}}/docs/requirements) for details regarding reference databases

- **Data suitability**
  - The pipeline expects paired-end sequences with two files per sample
    - forward read, usually some variation of _R1.fq.gz or _1.fq.gz filename suffix, and
    - reverse read, usually some variation of _R2.fq.gz or _1.fq.gz filename suffix

----

# The pipeline: data processing

This tutorial covers the data processing pipeline, which consists of the following three steps and shown in the below diagram:

<table class="table table-borderless">
<tr>
  <td>1. <b>Quality control</b> (QC) of the sequenced reads</td>
  <td rowspan=4 style="width:40%"><img src="{{site.baseurl}}/assets/img/tutorials/pipeline/tut_OverallSchema.png"/></td>
</tr>
<tr><td>2. <b>Taxonomy profiling</b> after QC, for assigning reads to taxon (this step can be run in parallel with step 3)</td></tr>
<tr><td>3. <b>Functional profiling</b> after QC, for assigning reads to genes (this step can be run in parallel with step 2)</td></tr>
<tr><td>4. <b>Analysis and visualisation</b> comes after the data has been processed and is covered in a separate tutorial, <a href="core-diversity-analysis-visualisation.html">Core diversity analysis and visualisation</a></td></tr>
</table>

{% include alert.html type='warning' title='Note' content="In steps 1 to 3, the pipeline generates one or more PBS scripts, which then have to be submitted to the PBS manager to actually process the reads and generate the output." %}

----

# Getting started

For this tutorial, you need to first

1. [Install MIMA Pipeline Singularity container]({{site.baseurl}}/docs/installation) 
   - check that you've created your *sandbox*
   - remember to start an interactive PBS job
   - set the `SANDBOX` environment variable
2. Check [Requirements]({{site.baseurl}}/docs/requirements): reference data are met - remember to take note of the paths to the reference databases
3. [Download tutorial data](download-tutorial-data)

## Working directory

After downloading the tutorial data, we assume that the `mima_tutorial` is the working directory located in your *home directory* (specified by the tilde, `~`). Hence, we will try to always make sure we are in the right directory first before executing a command, for example, run the following commands:

```
$ cd ~/mima_tutorial
$ tree .
```

- the starting directory structure for `mima_tutorial` should look like:

```
mima_tutorial
├── manifest.csv
├── pbs_header_func.cfg
├── pbs_header_qc.cfg
├── pbs_header_taxa.cfg
└── raw_data/
    ├── SRR17380115
    │   └── SRR17380115.sra
    ├── SRR17380115_1.fastq.gz
    ├── SRR17380115_2.fastq.gz
    └── ...
```

From here on, `~/mima_tutorial` will refer to the project directory as depicted above. Replace this path if you saved the tutorial data in another location.

## Terminal editors (`vim`)

{% capture tip_vim %}
<p>There are several places where you may need to edit the config files or scripts. You can use the <code class="language-plaintext highlighter-rouge">vi</code> or <code class="language-plaintext highlighter-rouge">vim</code> tool to edit text files directly on the terminal. See <a href="https://www.tutorialspoint.com/vim/vim_editing.htm" target="_blank">https://www.tutorialspoint.com/vim/vim_editing.htm</a></p>

<p>For example, to edit the <code class="language-plaintext highlighter-rouge">pbs_head_qc.cfg</code>, enter the command:</p>
<div class="language-plaintext highlighter-rouge">
  <div class="highlight">
    <pre class="highlight">
      <code>$ vim pbs_header_qc.cfg</code>
    </pre>
  </div>
</div>
{% endcapture %}

{% include alert.html type='info' title='Tip' content=tip_vim %}


## PBS configuration files

*pbs_header_*.cfg* is a configuration file containing PBS and Singularity settings. This be copied to the top of all PBS script files. Below is the PBS configuration file we have provided for you.

- There are 3 configuration files, one for each step as they require different PBS settings, which are indicated by the `#PBS` lines: 
  - `-N`: name of the job
  - `ncpus`: number of CPUs required
  - `walltime`: how long the job will take, here it's 2 hours. *Note* check the log files whether your jobs have completed correctly or failed due to not enough time
  - `-j oe`: standard output logs and error logs are concatenated into one file

- `module load singularity` loads Singularity from the *modules* environment and we are using version 3.6.4. **change this line as required**
  - if you don't need to use modules, then comment out or delete this line 

- Singularity settings
    - `IMAGE_DIR` specifies the location of the *sandbox* container created in [Install MIMA singularity container], **change this location as required**. The path should be the same as your `SANDBOX` environment variable

{% capture box_singularity_bind %}
<p><b>Make sure to check and see if you need to set the <code class="language-plaintext highlighter-rouge">SINGULARITY_BIND</code> environment variable if the data is not located in your home directory.</b> You can skip this step if all data is located in your home directory.</p>

<p><code class="language-plaintext highlighter-rouge">SINGULARITY_BIND</code> is an environment variable for mounting directory paths that will be used within the Singularity container. By default, the sandbox will only load the bare minimum locations in order to function, such as your home directory. If the files you need to access are located elsewhere then you need to inform the Singularity container of those locations. (If you have softlinks in your home directory that point to elsewhere, then you also need to bind to the original locations.)</p>

<ul>
  <li>format is comma separated pairs of <code class="language-plaintext highlighter-rouge"></local/source/path>:</singularity/bind/path></code> (both source and bind path can be the same, see example below)</li>
  <li>for example, let's say we have reference databases locations for each of the four tools</li>
    <ul>
      <li>minimap2: <code class="language-plaintext highlighter-rouge">/opt/refDB/human/GRCh38</code>,</li>
      <li>kraken2: <code class="language-plaintext highlighter-rouge">/shared/drive/GTDB_Kraken2</code>,</li>
      <li>humann: <code class="language-plaintext highlighter-rouge">/shared/drive/humann</code></li>
      <li>metaphlan: <code class="language-plaintext highlighter-rouge">/opt/refDB/metaphlan_databases</code></li>
    </ul>
  <li>then update the line to</li>
</ul>

<div class="language-plaintext highlighter-rouge">
  <div class="highlight">
    <pre class="highlight">
      <code>SINGULARITY_BIND="/opt/refDB:/opt/refDB,/shared/drive:/shared/drive"</code>
    </pre>
  </div>
</div>

<p>In this example, we identify the common parent paths and specify those:</p>
<ul>
  <li><code class="language-plaintext highlighter-rouge">/opt/refDB -> /opt/refDB</code> : which is used by minimap2 and metaplan</li>
  <li><code class="language-plaintext highlighter-rouge">/shared/drive -> /shared/drive</code> : which is used by kraken2 and humann</li>
</ul>

{% endcapture %}

{% include alert.html type='box' title='Setting SINGULARITY_BIND environment variable' content=box_singularity_bind %}

- Find the paths where your reference data are located and update the `SINGULARITY_BIND` environment variable accordingly in all 3 PBS configuration files (*.cfg)

``` bash
#!/bin/bash
#PBS -N mima-qc
#PBS -l ncpus=8
#PBS -l walltime=2:00:00
#PBS -l mem=64GB
#PBS -j oe

set -x
module load singularity/3.6.4

IMAGE_DIR=~/mima-pipeline
export SINGULARITY_BIND="</path/to/source1>:</path/to/destination1>,</path/to/source2>:</path/to/destination2>"
```

{% capture tip_export %}
If the <code class="language-plaintext highlighter-rouge">mima_tutorial</code> folder is not in your home directory (~) then you also need to set up the environment variable on the terminal using the <code class="language-plaintext highlighter-rouge">export</code> command. That is, run the last line of the configuration file on the terminal.
{% endcapture %}

{% include alert.html type='info' title='Tip' content=tip_export %}


## Check the Manifest.csv file

*Manifest.csv* file is a three column coma-separated file listing:
  - sampleID, 
  - filename of the forward fastq file and 
  - filename of the reverse fastq file

Check the filenames are the same as the fastq files extract, update as necessary

Note that the filenames don't need to be absolute paths as we will specify the fullpath in step 1 QC module.

```
Sample_ID,FileID_R1,FileID_R2
SRR17380209,SRR17380209.sra_1.fastq.gz,SRR17380209.sra_2.fastq.gz
SRR17380232,SRR17380232.sra_1.fastq.gz,SRR17380232.sra_2.fastq.gz
SRR17380236,SRR17380236.sra_1.fastq.gz,SRR17380236.sra_2.fastq.gz
SRR17380231,SRR17380231.sra_1.fastq.gz,SRR17380231.sra_2.fastq.gz
SRR17380218,SRR17380218.sra_1.fastq.gz,SRR17380218.sra_2.fastq.gz
...
```

----

# How this tutorial works

The tutorial have three steps and each step has five sub-sections:

STEP:
    
a) Brief introduction

b) Command to generate PBS scripts 

c) Command to submit PBS scripts as jobs

d) Expected outputs after PBS job completes

e) Post-processing step (some are optional)

----

# Step 1: QC module

## 1a) QC: introduction

Quality control (QC) checks to make sure that the sequenced reads obtained from the sequencing machine is of good quality. Bad quality reads or artefacts due to sequencing error if not removed can lead to spurious results and affect downstream analyses. There are a number of tools available for checking read quality of high-throughput read sequences.

This step must be done before Taxonomy and Function profiling.

This pipeline uses the following tools:

* [BBTool suite](https://jgi.doe.gov/data-and-tools/software-tools/bbtools/)
* [Fastp](https://github.com/OpenGene/fastp)
* [Minimap2](https://github.com/lh3/minimap2)

**Pipeline**

One bash (*.sh) script per sample is generated by this module that performs the following key steps. The module also generates $N$ number of PBS scripts (set using `--num-pbs-jobs` parameter, see below). In this tutorial, we have 9 samples, which we will spread across 3 PBS jobs. One PBS job will execute three bash scripts, one per sample.

<table class="table table-borderless">
<tr>
  <td>1. <b>repair</b> - uses repair.sh from BBTools/BBMap tool suite - repairs the sequenced reads and outputs any singleton reads (orphaned reads that are missing either the forward or reverse partner read)</td>
  <td rowspan=5 style="width:40%"><img src="{{site.baseurl}}/assets/img/tutorials/pipeline/tut_QCpipeline.png"/></td>
</tr>
<tr><td>2. <b>dereplicate</b> - uses clumpify.sh from BBTools/BBMap tool suite and removes duplicate reads (it also clusters reads for faster downstream processing)</td></tr>
<tr><td>3. <b>quality check</b> - uses fastp.sh and checks the quality of the reads and removes any reads that are of low quality, too long or too short</td></tr>
<tr><td>4. <b>decontamination</b> - uses minimap2.sh to map sequenced reads against a user-specified reference genome (e.g., human) and removes these host-reads from the data. The **cleaned** sequence output then becomes the input for taxonomy and function profiling</td></tr>
<tr><td>5. (optional) <b>QC report</b> generates a summary report *after all* PBS scripts have been run for all samples in the study</td></tr>
</table>


## 1b) QC: Generate PBS scripts

- Enter the following command, you can put them all on one line without the backslashes (`\`) at the end
  - the backslashes (`\`) at the end of each line informs the terminal that the command has not finished and there's more to come
  - we broke up the command for readability purposes to explain each parameter below

```
$ singularity run --app mima-qc $SANDBOX \
-i ~/mima_tutorial/raw_data \
-o ~/mima_tutorial/output \
-m ~/mima_tutorial/manifest.csv \
--num-pbs-jobs 3 \
--ref <path/to/human/GRCh38_latest_genome.fna>
--mode singularity \
--pbs-config pbs_header_qc.cfg
```

**Parameters explained**

| Parameters | Required? | Description |
| ---------- | ---------| ----------- |
| `-i <input>` | yes | must be *full path* to where the raw sequenced reads are stored (these files often have the \*.fastq.gz or \*.fq.gz extension). This path is used to find the *FileID\_R1* and *FileID\_R2* columns specified in the *manifest.csv* file provided (see below). |
| `-o <output>` | yes | must be the *full path* to where you would like the output files to be saved. The `<output>` path will be created if it does not exists. **Note** if there are already existing subdirectories in the `<output>` path, then this step will fail. |
| `-m <manifest.csv>` | yes | a comma-seperated file (\*.csv) that has three columns with the headers: **Sample\_ID, FileID\_R1, FileID\_R2** see the example below. *Note* the fileID\_R1 and fileID\_R2 are relative to the `-i <input>` path provided. |
| `--num-pbs-jobs` | no (default=4) | number of PBS scripts to generate by default 4 jobs are created with samples split equally between the jobs |
| `--ref` | yes | path to the host genome file GRCh38_latest_genome.fna |
| `--mode simgularity` | no (default='single') | set this if you are running in the singularity mode. By default, the PBS scripts generated are for the 'standalone' option, that is without Singularity |
| `--pbs-config` | yes if `--mode singularity` | path to the pbs configuration file (see below). You must specify this parameter if `--mode singularity` is set. You do not need to set this parameter if running outside of Singularity | 


### QC PBS output

* After running this command you should get a new `output` directory within `~/mima_tutorial`
* Within `output/`, there will be a sub-directory `QC_module`
    * inside `output/QC_module` should be 3 PBS scripts (\*.pbs extension)
    * we need these PBS scripts for the next step

```
$ tree ~/mima_tutorial
```

- only the `output` folder is shown in the snapshot below

```
mima_tutorial
└── output/
    └──  QC_module
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
$ cat ~/mima_tutorial/output/QC_module/qcModule_0.pbs
```

Your PBS script should look something like below, with some differences
  - the `/home/user` is replaced with the full path to your actual home directory
  - your IMAGE_DIR might be in a different location
  - remember to configure the `SINGULARITY_BIND` environment variable to include the directory where **minimap2** database is stored (see above [PBS configuration files](#pbs-configuration-files) for explanation)

``` bash
#!/bin/bash
#PBS -N QC_module_0
#PBS -l ncpus=8
#PBS -l walltime=2:00:00
#PBS -l mem=64GB
#PBS -j oe

set -x
module load singularity/3.6.4

IMAGE_DIR=~/mima-pipeline
export SINGULARITY_BIND="/path/to/human/GRCh38:/path/to/human/GRCh38"


cd /home/user/mima_tutorial/output/QC_module/

singularity exec ${IMAGE_DIR} bash /home/user/mima_tutorial/output/QC_module/SRR17380209.sh > SRR17380209_qc_module.log 2>&1
singularity exec ${IMAGE_DIR} bash /home/user/mima_tutorial/output/QC_module/SRR17380232.sh > SRR17380232_qc_module.log 2>&1
singularity exec ${IMAGE_DIR} bash /home/user/mima_tutorial/output/QC_module/SRR17380236.sh > SRR17380236_qc_module.log 2>&1
```

- Submit PBS job
  - Navigate to the `~/mima_tutorial/output/QC_module`
  - Submit the job by typing the `qsub` command
  - You can check the job has been submitted with `qstat`

```
$ cd ~/mima_tutorial/output/QC_module
$ qsub qcModule_0.pbs
```

- repeat the `qsub` command for each of the `qcModule_1.pbs` and `qcModule_2.pbs` files
- wait until all PBS jobs have completed

{% capture tip_navigate %}
We navigate to the directory that contains the PBS files because the PBS log files will be saved in the directory from where the job is submitted. Some management systems will allow the PBS directory <code class="language-plaintext highlighter-rouge">#PBS -j /path/to/log/file/</code> see the documentation for your system. You can modify these settings in the <code class="language-plaintext highlighter-rouge">pbs_header_qc.cfg</code> to suit your system needs.
{% endcapture %}

{% include alert.html type="info" title="Tip" content=tip_navigate %}


## 1d) QC: outputs

- After the PBS job completes then you should have the following outputs

```
$ tree ~/mima_tutorial/output/QC_module
```


- We only show outputs for one sample below with `...` meaning *and others*
- You'll have a set of output for each sample listed in the `manifest.csv` file (provided the corresponding *.fastq files exists)

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

## 1e) [optional] QC report

- You can generate a summary QC Report after all samples have been quality checked
- This step can be run directly from command line

```
$ singularity run --app mima-qc-report $SANDBOX \
-i ~/mima_tutorial/output/QC_module \
-o ~/mima_tutorial/output \
--manifest ~/mima_tutorial/manifest.csv
```

{% include alert.html type="warning" title="Troubleshoot" content='If your files are not located in your home directory then you will need to set up the SINGULARITY_BIND environment variable. See <a href="#pbs-configuration-files">Setting environment variable</a> above.' %}


The output is a comma separated table file located in `~/mima_tutorial/output/QC_module/QC_report.csv`, we can inspect the first few lines with `head` command
```
$ head ~/mima_tutorial/output/QC_module/QC_report.csv
```

```
SampleId,Rawreads_seqs,Derep_seqs,PCR_duplicates(%),Post_QC_seqs,low_quality_reads(%),Host_seqs,Host(%),Clean_reads
SRR17380209,14072002,14045392,0.0809091,9568710,31.87295876113675,482,0.005037251625349707,9568228
SRR17380232,11822934,11713130,0.0706387,11102358,5.214421764293575,62,0.0005584399278063273,11102296
SRR17380236,11756456,11656800,0.0688868,10846582,6.950603939331549,48,0.0004425357223132596,10846534
SRR17380231,12223354,12104874,0.069757,11414164,5.7060486544510916,16,0.00014017671377421947,11414148
SRR17380218,14913690,14874174,0.0856518,11505850,22.645452446636703,256,0.002224955131520053,11505594
SRR17380222,16927002,16905928,0.0980011,11692516,30.83777477344042,320,0.0027367933471290525,11692196
SRR17380118,40510808,40299722,0.235332,40148912,0.3742209437573788,324,0.0008069957163471828,40148588
SRR17380115,40393998,40186880,0.234584,40048860,0.3434454229838196,194,0.00048440829526733096,40048666
SRR17380122,43683114,41809064,0.24366,41697506,0.2668273080688915,1548,0.003712452250741327,41695958
```

{% include alert.html type="warning" title="Troubleshoot" content="Beware that if you have failed PBS log files (*.o) in your input directory, the QC report module may fail." %}


----

# Step 2: Taxonomy profiling

## 2a) Taxa: introduction

Taxonomy profiling takes the cleaned sequence reads as input and matches them against a reference database of previously characterised sequences for taxonomy classification. There are many different classification tools, for example: Kraken2, Metaphlan, Clark, Centrifuge, MEGAN, and many more. This pipeline uses Kraken2, which comes with its own reference database but you can also generate your own, see [Requirements]({{site.baseurl}}/docs/requirements) guide. In this pipeline, we will use the [GTDB](https://gtdb.ecogenomic.org/) database (release 95) and have built a Kraken2 database.

**Pipeline**

Since Kraken requires big memory (~300GB), there is only one PBS script that will execute each sample sequentially. In this tutorial, we have 9 samples which will be executed within one PBS job.

Key steps in the taxonomy profiling module are:

<table class="table table-borderless">
<tr>
<td>1. Kraken2 classifies the reads to taxa</td>
<td rowspan=3 style="width:40%"><img src="{{site.baseurl}}/assets/img/tutorials/pipeline/tut_TAXApipeline.png"/></td>
</tr>
<tr><td>2. Bracken takes the Kraken2 output to estimate abundances for a given taxonomic rank. This is repeated from Phylum to Species level.</td></tr>
<tr><td>3. Generate feature table is performed after <i>all samples</i> have been processed. This combines the output and generates a <i>feature table</i> for a given taxonomic rank. The feature table contains discrete counts and relative abundances of <i>"taxon X occurring in sample Y"</i>.</td></tr>
</table>


## 2b) Taxa: Generate PBS script

- Enter the following command, you can put them all on one line without the backslashes (`\`)
  - the backslash (`\`) at the end of each line informs the terminal that the command has not finished and there's more to come
  - we broke up the command for readability purposes to explain each parameter below
- **Make sure** to change the path for `--reference-path` parameter below to where your Kraken database is located

```
$ singularity run --app mima-taxa-profiling $SANDBOX\
-i ~/mima_tutorial/output/QC_module/CleanReads \
-o ~/mima_tutorial/output \
--reference-path </path/to/Kraken2_db> \
--read-length 150 \
--threshold 100 \
--mode singularity \
--pbs-config pbs_header_taxa.cfg
```

**Parameters explained**

| Parameters   | Required? | Description |
|--------------|-----------|-------------|
| `-i <input>` | yes | full path to the `~/mima_tutorial/output/QC_module/CleanReads` directory that was generated from Step 1) QC, above. This directory should hold all the `*_clean.fastq` files |
| `-o <output>` | yes | full path to the `~/mima_tutorial/output` directory where you would like the output files to be saved, can be the same as Step 1) QC |
| `--reference-path` | yes | full path to the reference database (this pipeline uses the GTDB release 95 reference database) |
| `--read-length` | no (default=150) | read length for Bracken estimation, choose the value closest to your sequenced read length (choose from 50, 75, 100 and 150) |
| `--threshold` | no (default=1000) | Bracken filtering threshold, features with counts below this value are filtered in the abundance estimation |
| `--mode simgularity` | no (default=single) | set this if you are running in the singularity mode. By default, the PBS scripts generated are for the 'standalone' option, that is without Singularity |
| `--pbs-config` | yes if `--mode singularity` | path to the pbs configuration file (see below). You must specify this parameter if `--mode singularity` is set. You do not need to set this parameter if running outside of Singularity | 

If you changed the file extension of the cleaned files or are working with already cleaned files from somewhere else, you can specify the forward and reverse suffix using:

| `--fwd-suffix` | no (default=_clean_1.fq.gz) | file suffix for cleaned forward reads from QC module |
| `--rev-suffix` | no (default=_clean_2.fq.gz) | file suffix for cleaned reverse reads from QC module |



### Taxonomy PBS output

- After this step you should get one PBS script and n=9 bash scripts in the output directory `~/mima_tutorial/output/Taxonomy_profiling`
- have a look at the directory structure using `tree`

```
$ tree ~/mima_tutorial/output/Taxonomy_profiling
```

Directory structure
  - **braken/** and **kraken2/** are subdirectories created by this step to store the output files after PBS job is executed
```
.
├── bracken
├── featureTables
│   └── generate_bracken_feature_table.py
├── kraken2
├── run_taxa_profiling.pbs
├── SRR17380209.sh
├── SRR17380232.sh
├── SRR17380236.sh
└── ...
```


## 2c) Taxa: Submit PBS job

- First we'll examine the PBS script to be submitted

```
$ cat ~/mima_tutorial/output/Taxonomy_profiling/run_taxa_profiling.pbs
```

Your PBS script should look something like below, with some differences
  - the `/home/user` is replaced with the full path to your actual home directory
  - your IMAGE_DIR might be in a different location
  - remember to configure the `SINGULARITY_BIND` environment variable to include the directory where **Kraken2** database is stored (see above [PBS configuration files](#pbs-configuration-files) for explanation)
  - note that walltime is set to 10 hours, increase this if you have more samples
  - note that memory this time is set to 300GB, increase if you need


``` bash
#!/bin/bash
#PBS -N mima-taxa
#PBS -l ncpus=28
#PBS -l walltime=10:00:00
#PBS -l mem=300GB
#PBS -j oe

set -x
module load singularity/3.6.4

IMAGE_DIR=~/mima-pipeline
export SINGULARITY_BIND="/path/to/kraken2/reference_database:/path/to/kraken2/reference_database"


cd /home/user/mima_tutorial/output/Taxonomy_profiling/

singularity exec ${IMAGE_DIR} bash /home/user/mima_tutorial/output/Taxonomy_profiling/SRR17380209.sh
singularity exec ${IMAGE_DIR} bash /home/user/mima_tutorial/output/Taxonomy_profiling/SRR17380232.sh
...
```

- Change directory to `~/mima_tutorial/output/Taxonomy_profiling`
- Submit PBS script with `qsub`

```
$ cd ~/mima_tutorial/output/Taxonomy_profiling
$ qsub run_taxa_profiling.pbs
```

- You can check the job has been submitted with `qstat`
- Wait for the job to complete


## 2d) Taxa: outputs

- After the PBS job completes then you should have the following outputs

```
$ tree ~/mima_tutorial/output/Taxonomy_profiling
```

- only a subset of the outputs are shown below with `...` meaning *and others*
- you'll have a set of output for each sample that passed the QC step

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

**Output files**

| Directory / Files | Description |
| ----------------- | ----------- |
| output | specified in the `--output-dir <output>` parameter set in step 1b) |
| Taxonomy_profiling | contains all files and output from this step |
| Taxonomy_profiling/\*.sh | are all the bash scripts generated by step 2b) for taxonomy profiling |
| Taxonomy_profiling/run_taxa_profiling.pbs | is the PBS wrapper generated by step 2b) that will execute each sample sequentially |
| Taxonomy_profiling/bracken | consists of the abundance estimation files from Bracken, one per sample, output after PBS submission |
| Taxonomy_profiling/featureTables | consists of the merged abundance tables generated by step 2e) below |
| Taxonomy_profiling/kraken2 | consists of the output from Kraken2 (two files per sample), output after PBS submission |

**Profiler output**

* For details of Kraken2 output files, see their [documentation](https://github.com/DerrickWood/kraken2/wiki/Manual#output-formats)
* For details of Bracken output files, see their [documentation](https://ccb.jhu.edu/software/bracken/index.shtml?t=manual#format)

## 2e) Taxa: Generate taxonomy abundance table

- After **all samples** have been taxonomically annotated and abundance estimated by Bracken, we need to combine the tables
- Navigate to `~/mima_tutorial/output/Taxonomy_profiling/featureTables`
- Run the `singularity` command directly from terminal (not a PBS job)
- Check the output

```
$ cd ~/mima_tutorial/output/Taxonomy_profiling/featureTables
$ singularity exec $SANDBOX python3 generate_bracken_feature_table.py
$ tree .
```

- All bracken output files will be concatenated into a table, one for each taxonomic rank from Phylum to Species
    - table rows are taxonomy features
    - table columns are abundances
- By default, the tables contain both discrete counts and relative abundances
- The `generate_bracken_feature_table.py` will split the default output into two files with the suffices:
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

Functional profiling, like taxonomy profiling, takes the cleaned sequenced reads as input and matches them against a reference database of previously characterised gene sequences. There are different types of functional classification tools available. This pipeline uses [HUMAnN](https://huttenhower.sph.harvard.edu/humann/), which comes with its own reference databases. You will need to download these on to the HPC environment you are working with if it's not already done so. If it's already downloaded, then you will need to know the paths to the reference databases for this step. See [Requirements](requirements) guide.

**Pipeline**

One PBS script per sample will be generated in this module. The key steps are shown in the figure below and described as follows:

<table class="table table-borderless">
<tr>
<td>1. HUMAnN is used for processing and generates three outputs for each sample: (i) gene families, (ii) pathway abundances and (iii) pathway coverage</td>
<td rowspan=2 style="width:40%"><img src="{{site.baseurl}}/assets/img/tutorials/pipeline/tut_function_pipeline.png"/></td>
</tr>
<tr><td>2. Generate feature table is performed after <i>all samples</i> have been processed. This combines the output and generates a <i>feature table</i> that contains the abundance of gene/pathway X in sample Y.</td></tr>
</table>


## 3b) Function: Generate PBS scripts

- Enter the following command, you can put them all on one line without the backslashes (`\`)
  - the backslash (`\`) at the end of each line informs the terminal that the command has not finished and there's more to come
  - we broke up the command for readability purposes to explain each parameter below

- **Make sure** to change the paths for all the `--*-database` parameter settings to where your reference database are located

```
$ singularity run --app mima-function-profiling $SANDBOX \
-i ~/mima_tutorial/output/QC_module/CleanReads \
-o ~/mima_tutorial/output \
--nucleotide-database </path/to>/humann3/chocophlan \
--protein-database /<path/to>/humann3/uniref \
--utility-database /<path/to>/humann3/unitility_mapping \
--metaphlan-database="--bowtie2db /<path/to>/metaphlan_databases" \
--mode singularity \
--pbs-config pbs_header_func.cfg
```

**Parameters explained**

| Parameters &nbsp; &nbsp; &nbsp; &nbsp;| Required? | Description |
| ---------- | --------- | ----------- |
| `-i <input>` | yes | full path to the `~/mima_tutorial/output/QC_module/CleanReads` directory that was generated from Step 1) QC, above. This directory should hold all the `*_clean.fastq` files |
| `-o <output>` | yes | full path to the `~/mima_tutorial/output` output directory where you would like the output files to be saved, can be the same as Step 1) QC |
| `--nucleotide-database <path>` | yes | directory containing the nucleotide database, (default=/refdb/humann/chocophlan) |
| `--protein-database <path>` | yes | directory containing the protein database, (default=/refdb/humann/uniref) |
| `--utility-database <path>` | yes | directory containing the protein database, (default=/refdb/humann/utility_mapping) |
| `--metaphlan-database <path>` | yes | directory containing the metaphlan database, (default=/refdb/humann/metaphlan_databases) |
| `--mode simgularity` | no (default='single') | set this if you are running in the singularity mode. By default, the PBS scripts generated are for the 'standalone' option, that is without Singularity |
| `--pbs-config` | yes if `--mode singularity` | path to the pbs configuration file (see below). You must specify this parameter if `--mode singularity` is set. You do not need to set this parameter if running outside of Singularity | 
| ---------- | --------- | ----------- |
| `--mpa3` | no | **note!** if you are using mima_h350_mpa401.sif container which contains Metaphlan 4, you can set `--mpa3` for backward compatibility with Metaphlan 3 databases (see [here](https://forum.biobakery.org/t/announcing-metaphlan-4/3994){:target="_blank"}) |

**Expected output**

- After this step you should get the following PBS scripts (one per sample) in the output directory `~/mima_tutorial/output/Function_profiling`

```
$ tree ~/mima_tutorial/output/Function_profiling
```

```
├── featureTables
│   ├── generate_func_feature_tables.pbs
│   └── generate_func_feature_tables.sh
├── SRR17380209.pbs
├── SRR17380218.pbs
├── SRR17380222.pbs
├── SRR17380231.pbs
├── SRR17380232.pbs
└── SRR17380236.pbs
```

## 3c) Function: Submit PBS jobs

- Examine one of the PBS scripts

```
$ cat ~/mima_tutorial/output/Function_profiling/SRR17380209.pbs
```

Your PBS script should look something like below, with some differences
  - the `/home/user` is replaced with the full path to your actual home directory
  - `<path/to/db>` databases will be replaced with what you set above for `--nucleotide-database` etc
  - remember to configure the `SINGULARITY_BIND` environment variable to include the directory where **HUMAnN** and **MetaPhlAn** databases are stored (see above [PBS configuration files](#pbs-configuration-files) for explanation)
  - note that the walltime is set to 8 hours, you might need to increase this for your own samples if they are larger than the examples used in this tutorial

``` bash
#!/bin/bash
#PBS -N mima-func
#PBS -l ncpus=8
#PBS -l walltime=8:00:00
#PBS -l mem=64GB
#PBS -j oe

set -x
module load singularity/3.6.4

IMAGE_DIR=~/mima-pipeline
export SINGULARITY_BIND="/path/to/humann3_database:/path/to/humann3_database,/path/to/metaphlan_databases:/path/to/metaphlan_databases"


cd /home/user/mima_tutorial/output/Function_profiling/

# Execute HUMAnN3
cat /home/user/mima_tutorial/output/QC_module/CleanReads/SRR17380209_clean_1.fq.gz ~/mima_tutorial/output/QC_module/CleanReads/SRR17380209_clean_2.fq.gz > ~/mima_tutorial/output/Function_profiling/SRR17380209_combine.fq.gz

outdir=/home/user/mima_tutorial/output/Function_profiling/
singularity exec ${IMAGE_DIR} humann -i ${outdir}SRR17380209_combine.fq.gz --threads 28 \
-o $outdir --memory-use maximum \
--nucleotide-database </path/to/humann3>/chocophlan \
--protein-database </path/to/humann3>/uniref \
--utility-database </path/to/humann3>/utility_mapping \
--metaphlan-options="--bowtie2db --bowtie2db </path/to/>metaphlan_databases" \
--search-mode uniref90
```

- Change directory to `~/mima_tutorial/output/Functional_profiling`
- Submit the PBS job using `qsub`
- Repeat this for each `*.pbs` file

```
$ cd ~/mima_tutorial/output/Functional_profiling
$ qsub SRR17380209.pbs
```

- You can check your jobs using `qstat`
- Wait until all PBS jobs have completed

## 3d) Function: output

- After all PBS job completes then you should have the following outputs

```
$ ls -1 ~/mima_tutorial/output/Function_profiling
```

- only a subset of the outputs are shown below with `...` meaning *and others*
- you'll have a set of output for each sample that passed the QC step

```
featureTables
...
SRR17380115_combine_genefamilies.tsv
SRR17380115_combine_humann_temp
SRR17380115_combine_pathabundance.tsv
SRR17380115_combine_pathcoverage.tsv
SRR17380115.pbs
SRR17380118_combine_genefamilies.tsv
SRR17380118_combine_humann_temp
SRR17380118_combine_pathabundance.tsv
SRR17380118_combine_pathcoverage.tsv
SRR17380118.pbs
...
SRR17380236.pbs
```


**Profiler output**

* For details of HUMAnN3 output files, see their [documentation](https://github.com/biobakery/humann#output-files)


## 3e) Function: Generate function feature tables

- After **all samples** have been functionally annotated, we need to combine the tables together and normalise the abundances
- Navigate to `~/mima_tutorial/output/Fuctional_profiling/featureTables`
- Submit the PBS script file `generate_func_feature_tables.pbs`

```
$ cd <PROJECT_PATH>/output/Functional_profiling/featureTables
$ qsub generate_func_feature_tables.pbs
```

- Check the output
- Once the job completes you will have 7 output files, those starting with `merge_humann3table_` prefixes

```
~/mima_tutorial/
└── output/
    ├── Function_profiling
    │   ├── featureTables
    │   ├── func_table.o2807928
    │   ├── generate_func_feature_tables.pbs
    │   ├── generate_func_feature_tables.sh
    │   ├── merge_humann3table_genefamilies.cmp_uniref90_KO.txt
    │   ├── merge_humann3table_genefamilies.cpm.txt
    │   ├── merge_humann3table_genefamilies.txt
    │   ├── merge_humann3table_pathabundance.cmp.txt
    │   ├── merge_humann3table_pathabundance.txt
    │   ├── merge_humann3table_pathcoverage.cmp.txt
    │   └── merge_humann3table_pathcoverage.txt
    ├── ...
```

{% capture tip_custom_mapping %}
<p>In the file <code>generate_func_feature_tables.sh</code>, by default the last step in the <code class="language-plaintext highlighter-rouge">humann_regroup_table</code> command uses the KEGG orthology mapping file, that is the <code class="language-plaintext highlighter-rouge">-c</code> parameter:</p>

<div class="language-plaintext highlighter-rouge">
  <div class="highlight">
    <pre class="highlight">
      <code>-g uniref90_rxn -c <path/to/>map_ko_uniref90.txt.gz</code>
    </pre>
  </div>
</div>

<p>If you prefer other mappings than change this line accordingly before running the PBS job using <code class="language-plaintext highlighter-rouge">generate_func_feature_tables.pbs</code>.</p>
{% endcapture %}


{% include alert.html type='info' title='Tip' content=tip_custom_mapping %}

----

# Congratulations !

You have completed processing your metagenomics data and are now ready for further analyses

Analyses usually take in the feature-tables that were created in Step 2e) Taxonomy feature tables and Step 3e) Function feature tables.
