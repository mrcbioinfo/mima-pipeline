---
title: qc_module.py
---

The Quality Checking (QC) module is the entry point to the pipeline. It will generate a PBS script for each sample, with the script consisting of the following key steps:

- **Deduplicate** - removes duplicate reads
- **Quality control** - removes reads that are too low in quality, too short or too long
- **Host decontamination** - removes reads that map to the Human genome

***

# Basic usage

```
$python3 qc_module.py -i </full_path/to/input_dir> -o </full_path/to/output_dir> -m </full_path/to/manifest.csv> -e email
```

## Required inputs

**Input_dir** - Path to directory with all the fastQ files

**Output_dir**  - Path to directory where output will be generated

**Manifest (CSV)** - the manifest file is a CSV text file that contains metadata about the raw FastQ files. The current version expected paired-end reads with separate files for the forward and reverse reads. The CSV format contains three columns with the following headings (case sensitive and no spaces between commas):

|Sample_ID|FileID_R1|FileID_R2|
|:-------|:-------|:------|
|test1|test1_R1_001.fastq.gz|test1_R2_001.fastq.gz|
|test2|test2_R1_001.fastq.gz|test2_R2_001.fastq.gz|

**Email** - to generate the PBS script

## Outputs

The QC module will create three directories in the specified  `<output_dir>` and a PBS script for each sampleID provided in the manifest.

```
<output_dir>
├── QCmodule
    ├── CleanReads
    ├── QCReport
```

|Directory | Description |
|:---------|:-------------|
| CleanReads| contains the final processed reads and is used as the input directory for [[Taxonomic Profiling]] and [[Functional profiling]] |
| QCReport  | contains Fastp reports for each sample, one HTML and Json file per sample |
| RawReads  | contains the raw reads files (unzipped) |


***


# Full help

```
usage: qc_module.py -i INPUT_DIR -o OUTPUT_DIR -m MANIFEST -e EMAIL [-s SUBS]
                    [-r REF] [--mode {single,singularity}] [-w WALLTIME]
                    [-M MEM] [-t THREADS]
                    [--singularity-pbs-file SINGULARITY_PBS_FILE] [-h]
                    [--verbose] [--debug]

Quality checking module part of the MRC Metagenomics pipeline

[1] Required arguments:
  -i INPUT_DIR, --input-dir INPUT_DIR
                        path to input directory of raw sequences (e.g., fastQ)
  -o OUTPUT_DIR, --output-dir OUTPUT_DIR
                        path to output directory
  -m MANIFEST, --manifest MANIFEST
                        path to manifest file in .csv format. The header line
                        is case sensitive, and must follow the following
                        format with no spaces between commas.
                        Sample_ID,FileID_R1,FileID_R2
  -e EMAIL, --email EMAIL
                        PBS setting - email address

[2] QC settings:
  -s SUBS, --subs SUBS  Maximum number of substitutions allowed between
                        duplicates used for clumpify.sh from BBTools
  -r REF, --ref REF     file path to reference host genome

[3] PBS settings:
  --mode {single,singularity}
                        Mode to generate PBS scripts, currently supports
                        single sample mode only [default=single]
  -w WALLTIME, --walltime WALLTIME
                        walltime hours required for PBS job of MODE
                        [default=100]
  -M MEM, --mem MEM     memory (GB) required for PBS job of MODE [default=60]
  -t THREADS, --threads THREADS
                        number of threads for PBS job of MODE [default=8]
  --singularity-pbs-file SINGULARITY_PBS_FILE
                        only used if --mode singularity is set, path to file
                        with singularity parameters to include in PBS scripts

[4] Optional arguments:
  -h, --help            show this help message and exit
  --verbose             turn on will return verbose meessages
  --debug               turn on will return debugging messages

```       
