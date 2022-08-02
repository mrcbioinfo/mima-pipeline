---
title: taxa_module.py
---

The Taxonomy Profiling module takes the CleanReads after [quality check](../qc_module) and classifies each sequence read to a taxon using the selected profiler. This module creates one bash script per sample and then a wrapper PBS script that calls each of the bash script sequentially.

Currently, the pipeline supports the Kraken2 (https://ccb.jhu.edu/software/kraken2) classifier and each bash script contains two steps:

1. Taxonomy classification by Kraken2
2. Abundance estimation with Bracken


***


# Basic usage

There are three steps for taxonomy profiling (see the tutorial for full instructions of all three steps):

1. Generate the bash and PBS scripts (**this documentation**)
2. Submit the PBS job
3. Run `<output_dir>/featureTables/generate_bracken_feature_table.py` to get the final output


Generating the bash and PBS scripts, **note** the command below is all on one line, parameters are put on separate lines for readability (the ending backslash `\` informs the terminal that the command continues onto the next line)

```
$ python3 taxa_module.py -i </full_path/project_output>/QC_module/CleanReads \
-o </full_path/project_output> \
--fwd-suffix <_clean_1.fq.gz> \
--rev-suffix <_clean_2.fq.gz> \
--reference-path </full_path/to/reference_database>
--read-length <150> \
--threshold <100> \
-e <email> 
```

## Required inputs


| Parameter | Description |
|:----------|:------------|
| `-i <input_dir>` | Path to directory with all the cleaned reads output from [QC module](../qc_module) |
| `-o <output_dir>` | Path to directory where the bash scripts, PBS files and sub-directories will be generated |
| `--fwd-suffix`/`--rev-suffix` | file suffix for cleaned reads from [QC module](../qc_module) |
| `--reference-path` | Path to the reference database (this pipeline uses the GTDB release 95 reference database) |
| `--read-length` | Read length for Bracken estimation, choose the value closests to your sequenced read length (choose from 50, 75, 100 and 150) |
| `--threshold` | Bracken filtering threshold, features with counts below this value are filtered in the abundance estimation |
| `-e <email>` | Email address to include in the PBS wrapper script, notification of job ending or aborting will be sent to this address |

## Outputs

The Taxonomy profiling module will the following directory structure in the specified `<output_dir>`. A root sub-directory `Taxonomy_profiling/` will be created within which contains the bash scripts that calls Kraken2 and Bracken (*.sh extension). One bash script is generated per sample. A PBS wrapper script is generated that calls each of the bash script sequentially. The PBS script needs to be submitted to the job handler. After the job completes, the output files are saved to the other subdirectories `kraken2/` and `bracken/`.

```
output_dir
├── Taxonomy_profiling/
    ├── bracken/
    ├── featureTables/
    ├── kraken2/
    └── run_taxa_profiling.pbs
```

| Output | Description |
|:---------|:-------------|
| `Taxonomy_profiling/` | Root sub-directory of the taxonomy profiling module |
| `bracken/` | Directory that contains output from Bracken after abundance estimation |
| `featureTables/` | Directory that contains the taxonomic feature abundance tables. These are text files of concatenated output from `bracken/` | 
| `kraken2/` | Directory that contains the output from Kraken2 |
| `Taxonomy_profiling/*.sh` | the root sub-directory will contain bash scripts, one for each sample |
| `Taxonomy_profiling/run_taxa_profiling.pbs` | the PBS wrapper script that calls the bash scripts sequentially. This is submitted to the job manager and after the job completes, the output files will be located in `bracken/` and `kraken2/`. |

***


# Full help

```
usage: taxa_module.py -i INPUT_DIR -o OUTPUT_DIR [--taxon-profiler {kraken2}]
                      [--fwd-suffix FWD_SUFFIX] [--rev-suffix REV_SUFFIX]
                      --reference-path REFERENCE_PATH
                      [--read-length READ_LENGTH] [--threshold THRESHOLD] -e
                      EMAIL [--mode {single,singularity}] [-w WALLTIME]
                      [-M MEM] [-t THREADS] [-h] [-f FILE_TYPE] [--verbose]
                      [--debug]

Taxonomy profiling module part of the MRC Metagenomics pipeline

[1] Required arguments:
  -i INPUT_DIR, --input-dir INPUT_DIR
                        path to input directory of cleaned sequences (e.g.
                        QC_module/CleanReads)
  -o OUTPUT_DIR, --output-dir OUTPUT_DIR
                        path to output directory
  --reference-path REFERENCE_PATH
                        specify the path to the reference required for the
                        selected taxonomic profiler
  --read-length READ_LENGTH
                        read length for Bracken estimation of abundances
  --threshold THRESHOLD
                        threshold [default=1000] for Bracken estimation of
                        abundances, species with reads below threshold are
                        removed
  -e EMAIL, --email EMAIL
                        PBS setting - email address

[2] Taxonomy profile settings:
  --taxon-profiler {kraken2}
                        select which taxonomy profiler to use, default
                        [default=kraken2]
  --fwd-suffix FWD_SUFFIX
                        suffix of forward cleaned reads to search for in
                        input_dir [default=_clean_1.fq.gz]
  --rev-suffix REV_SUFFIX
                        suffix of reverse cleaned reads for PBS script
                        [default=_clean_2.fq.gz]

[3] PBS settings:
  --mode {single,singularity}
                        Mode to generate PBS scripts, currently supports
                        single sample mode only [default=single]
  -w WALLTIME, --walltime WALLTIME
                        walltime hours required for PBS job of MODE
                        [default=48]
  -M MEM, --mem MEM     memory (GB) required for PBS job of MODE [default=320]
  -t THREADS, --threads THREADS
                        number of threads for PBS job of MODE [default=28]

[4] Optional arguments:
  -h, --help            show this help message and exit
  -f FILE_TYPE, --file-type FILE_TYPE
                        input file type: [default=fastq]
  --verbose             turn on will return verbose messages
  --debug               turn on will return debugging message


```
