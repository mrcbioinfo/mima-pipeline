---
title: taxa_module.py
---

The Taxonomy Profiling module takes the CleanReads after quality check ([[QC module]]) and annotates each sequence read to a taxon depending on the selected approach.

This module currently creates one PBS script for each sample (with the *_clean1.fq.gz suffix, output from the [[QC module]])

Currently supported taxonomy annotation approaches (select one or more): 

1. Metaphlan2 (https://bitbucket.org/biobakery/metaphlan2/src/default/)
1. Metaphlan3 ()
1. KrakenUniq (https://github.com/fbreitwieser/krakenuniq)
1. IGGsearch (https://github.com/snayfach/IGGsearch)
1. Samtools/1.9


***


# Basic usage

```
$ python3 taxa_module.py -i </full_path/project_output>/QC_module/CleanReads \
-o </full_path/project_output> \
-e email \
--reference-path </full_path/to/reference_database>
```

## Required inputs

* **Input_dir** - Path to directory with all the *_clean1.fq.gz output from [[QC module]]

* **Output_dir**  - Path to directory where output will be generated, the "PBS_scripts" subdirectory will be created

* **Email** - to generate the PBS script

* **Profiler** - select which approach to use for taxonomic annotation profiling

## Outputs

The Taxonomy profiling module will create two directories in the specified `<output_dir>` and a PBS script for each sample.

```
output_dir
├── Taxonomy_profiling
    ├── featureTables/
```

|Directory | Description |
|:---------|:-------------|
| Taxonomy_profiling | root directory of the taxonomy profiling module, will have a subdirectory for each approach (e.g., metaphlan3) |
| PBS_scripts | currently one PBS script is generated for each sample |


***


# Full help

```
usage: taxa_module.py -i INPUT_DIR -o OUTPUT_DIR -e EMAIL
                      [--taxon-profiler {kraken2,metaphlan3,metaphlan2,krakenUniq,IGG}]
                      [--fwd-suffix FWD_SUFFIX] [--rev-suffix REV_SUFFIX]
                      --reference-path REFERENCE_PATH [--mode MODE]
                      [-w WALLTIME] [-M MEM] [-t THREADS] [-h] [-f FILE_TYPE]
                      [--verbose] [--debug]

Taxonomy profiling module part of the MRC Metagenomics pipeline

[1] Required arguments:
  -i INPUT_DIR, --input-dir INPUT_DIR
                        path to input directory of cleaned sequences (e.g.
                        QC_module/CleanReads)
  -o OUTPUT_DIR, --output-dir OUTPUT_DIR
                        path to output directory
  -e EMAIL, --email EMAIL
                        PBS setting - email address
  --reference-path REFERENCE_PATH
                        specify the path to the reference required for the
                        selected taxonomic profiler

[2] Taxonomy profile settings:
  --taxon-profiler {kraken2,metaphlan3,metaphlan2,krakenUniq,IGG}
                        select which taxonomy profiler to use, default
                        [default=kraken2]
  --fwd-suffix FWD_SUFFIX
                        suffix of forward cleaned reads to search for in
                        input_dir [default=_clean_1.fq.gz]
  --rev-suffix REV_SUFFIX
                        suffix of reverse cleaned reads for PBS script
                        [default=_clean_2.fq.gz]

[3] PBS settings:
  --mode MODE           Mode to generate PBS scripts, currently supports
                        single sample mode only [default=single]
  -w WALLTIME, --walltime WALLTIME
                        walltime hours required for PBS job of MODE
                        [default=100]
  -M MEM, --mem MEM     memory (GB) required for PBS job of MODE [default=300]
  -t THREADS, --threads THREADS
                        number of threads for PBS job of MODE [default=18]

[4] Optional arguments:
  -h, --help            show this help message and exit
  -f FILE_TYPE, --file-type FILE_TYPE
                        input file type: [default=fastq]
  --verbose             turn on will return verbose messages
  --debug               turn on will return debugging message

```
