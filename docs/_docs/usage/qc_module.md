---
title: qc_module.py
---

The Quality Checking (QC) module is the entry point to the pipeline. It will generate a bash script for each sample consisting of the following key steps:

1. **Deduplicate** - removes duplicate reads
2. **Quality control** - removes reads that are too low in quality, too short or too long
3. **Host decontamination** - removes reads that map to the Human genome

The bash script is then wrapped within a PBS script for submission to the job handler. At most, $N$ (default=4) PBS scripts are generated the the number of samples are evenly distributed among the PBS scripts. For example, given a study with 20 samples, and 4 PBS scripts are generated, each PBS script will execute 5 samples for QC processing. By the end of all PBS jobs, there should be 30 sets of outputs (see below), one per sample.

***

# Basic usage

```
$python3 qc_module.py -i </full_path/to/raw_data> -o </full_path/to/output_dir> -m </full_path/to/manifest.csv> -e <email>
```

## Required inputs

| Parameter | Description |
|:----------|:------------|
| `-i <raw_data>` | Path to directory with all the raw read (fastQ) files |
| `-o <output_dir>` | Path to directory where the bash scripts and PBS wrapper will be generated |
| `-e <email>` | Email address to include in the PBS wrapper script, notification of job ending or aborting will be sent to this address |
| `-m <manifest.csv>` | The manifest file is a CSV text file that contains metadata about the raw FastQ files. The current version expected paired-end reads with separate files for the forward and reverse reads. The CSV format contains three columns with the headings: **Sample_ID,FileID_R1,FileID_R2**. The headings are case sensitive with no spaces between commas (see example below) |

```
      Sample_ID,FileID_R1,FileID_R2
      SRR123456,SRR123456_R1_001.fastq.gz,SRR123456_R2_001.fastq.gz
      SRR999999,SRR999999_R1_001.fastq.gz,SRR999999_R2_001.fastq.gz
```



## Outputs

The QC module will create the output directory `QC_module` in the specified  `<output_dir>`. Within `QC_module/` directory will be one bash scripts (`*.sh` extension) per sample and $N$ number of PBS scripts as specified by the `--num--pbs-jobs` parameter (see below).

There are also two subdirectories `CleanReads` and `QCReport` that hold the outputs from the bash script. These are described in the table below.

The directory structure resembles:
```
<output_dir>
├── QC_module/
    ├── CleanReads/
    ├── QCReport/
```

| Output | Description |
|:---------|:-------------|
| `QC_module/` | Root sub-directory that contains all output from the QC module |
| `QC_module/CleanReads/` | directory that contains the final processed reads and is used as the input directory for [Taxonomic Profiling](../taxonomy_profiling) and [Functional profiling](../functional_profiling) |
| `QC_module/QCReport/`  | directory that contains Fastp reports for each sample, one HTML and json file per sample |
| `QC_module/*.sh` | the root sub-directory will contain bash scripts, one for each sample |
| `QC_module/*.pbs` | the root sub-directory will contain $N$ number of PBS wrapper scripts as specified by the `--num-pbs-jobs` parameter. These are submitted to the job manager and after the jobs completes, the output files will be located in `CleanReads/` and `QCReport/`. |


***


# Full help

```
usage: qc_module.py -i INPUT_DIR -o OUTPUT_DIR -m MANIFEST [-s SUBS] [-r REF]
                    -e EMAIL [--mode {single,singularity}] [-w WALLTIME]
                    [-M MEM] [-t THREADS] [--num-pbs-jobs NUM_PBS_JOBS] [-h]
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
                        [default=2]
  -M MEM, --mem MEM     memory (GB) required for PBS job of MODE [default=64]
  -t THREADS, --threads THREADS
                        number of threads for PBS job of MODE [default=8]
  --num-pbs-jobs NUM_PBS_JOBS
                        Number of PBS jobs where the number of samples
                        processed will be equally distributed amongst the
                        number of jobs [default=4]

[4] Optional arguments:
  -h, --help            show this help message and exit
  --verbose             turn on will return verbose meessages
  --debug               turn on will return debugging messages

```       
