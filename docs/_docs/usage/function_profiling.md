---
title: func_profiling.py
---

The Functional Profiling module takes the CleanReads after [quality check](../qc_module) and matches each read against a reference database of gene sequences. One PBS script per sample is then generated for submission to the job handler.

Currently, the pipeline supports Humann3.

***

# Basic usage

**note** the command below is all on one line, parameters are put on separate lines for readability (the ending backslash `\` informs the terminal that the command continues onto the next line)
```
$ python3 functional_profiling.py -i </full_path/project_output>/QC_module/CleanReads \
-o </full_path/project_output> \
--fwd-suffix <_clean_1.fq.gz> \
--rev-suffix <_clean_1.fq.gz> \
--nucleotide-database </path_to/chocophlan> \
--protein-database </path_to/uniref> \
--metaphlan-database </path_to/metaphlan_databases> \
-e <your.email@address.com>
```

## Required inputs

| Parameter | Description |
|:----------|:------------|
| `-i <input_dir>` | Path to directory with all the cleaned reads output from [QC module](../qc_module) |
| `-o <output_dir>` | Path to directory where the PBS scripts and sub-directories will be generated |
| `--fwd-suffix`/`--rev-suffix` | file suffix for cleaned reads from [QC module](../qc_module) |
| `--nucleotide-database` | Path to the Humann3 Chocophlan reference database for nucleotide search |
| `--protein-database` | Path to the Humann3 Uniref reference database for protein search |
| `--metaphlan-database` | Path to the Metaphlan3 reference database for species matching |
| `-e <email>` | Email address to include in the PBS wrapper script, notification of job ending or aborting will be sent to this address |


## Outputs

The Functional profiling module will create a root sub-directory, `Functional_profiling` in the specified `<output_dir>` path. Within this will be the PBS scripts, one per sample. The scripts need to be submitted to the job handler which will then generated the Humann3 output files. 

```
output_dir
├── Functional_profiling
    ├── featureTables/
```

| Output | Description |
|:---------|:-------------|
| `Functional_profiling` | Root sub-directory of the functional profiling module |
| `Functional_profiling/*.pbs` |  PBS scripts (one per sample) to be submitted to the job handler. After the job completes, a set of output files per sample will be located in the `Functional_pofiling/` directory. The user then needs to **combine functional feature tables**. |


### Combine functional feature tables

Once all samples have been processed, the user can then submit the `featureTables/generate_func_feature_tables.pbs` script to concatenate and normalise the abundances for the three functional feature tables: i) gene families, ii) path abundances and iii) path coverage.



***

# Full help

```
usage: func_profiling.py -i INPUT_DIR -o OUTPUT_DIR
                         [--function-profiler {humann3,humann2}]
                         [--fwd-suffix FWD_SUFFIX] [--rev-suffix REV_SUFFIX]
                         [--nucleotide-database NUCLEOTIDE_DATABASE]
                         [--protein-database PROTEIN_DATABASE]
                         [--metaphlan-database METAPHLAN_DATABASE] -e EMAIL
                         [--mode {single,singularity}] [-w WALLTIME] [-M MEM]
                         [-t THREADS] [-h] [--pipeline-dir PIPELINE_DIR]
                         [--verbose] [--debug]

Function profiling module part of the MRC Metagenomics pipeline

[1] Required arguments:
  -i INPUT_DIR, --input-dir INPUT_DIR
                        path to input directory of cleaned sequences (e.g.
                        QC_module/CleanReads)
  -o OUTPUT_DIR, --output-dir OUTPUT_DIR
                        path to output directory
  -e EMAIL, --email EMAIL
                        PBS setting - email address

[2] Function profile settings:
  --function-profiler {humann3,humann2}
                        select profiler for function profiling
                        [default=humann3]
  --fwd-suffix FWD_SUFFIX
                        suffix of cleaned reads to search for in input_dir
                        [default=_clean_1.fq.gz]
  --rev-suffix REV_SUFFIX
                        suffix of reverse cleaned reads for PBS script
                        [default=_clean_2.fq.gz]
  --nucleotide-database NUCLEOTIDE_DATABASE
                        HUMAnN3 directory containing the nucleotide database
                        [default=/refdb/humann/data/chocophlan]
  --protein-database PROTEIN_DATABASE
                        HUMAnN3 directory containing the protein database
                        [default=/refdb/humann/data/uniref]
  --metaphlan-database METAPHLAN_DATABASE
                        Metaphlan3 reference database (CHOCOPhlAn)
                        [default=/refdb/humann/metaphlan_databases]

[3] PBS settings:
  --mode {single,singularity}
                        Mode to generate PBS scripts, currently supports
                        single sample mode only [default=single]
  -w WALLTIME, --walltime WALLTIME
                        walltime hours required for PBS job of MODE
                        [default=24]
  -M MEM, --mem MEM     memory (GB) required for PBS job of MODE [default=64]
  -t THREADS, --threads THREADS
                        number of threads for PBS job of MODE [default=28]

[4] Optional arguments:
  -h, --help            show this help message and exit
  --pipeline-dir PIPELINE_DIR
                        directory of pipeline script for finding
                        combine_fastq.jl
  --verbose             turn on to show verbose messages
  --debug               turn on to show debugging messages

````
