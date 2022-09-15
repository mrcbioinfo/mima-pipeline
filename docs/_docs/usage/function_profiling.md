---
title: func_profiling.py
---

The Functional Profiling module takes the CleanReads after [quality check](qc_module) and matches each read against a reference database of gene sequences. One PBS script per sample is then generated for submission to the job handler.

Currently, the pipeline supports Humann3.

***

# Basic usage

**note** the command below is all on one line, parameters are put on separate lines for readability (the ending backslash `\` informs the terminal that the command continues onto the next line)

```
$ singularity run --app mima-function-profiling $SANDBOX \
-i </full_path/project_output>/QC_module/CleanReads \
-o </full_path/project_output> \
--nucleotide-database </path_to/chocophlan> \
--protein-database </path_to/uniref> \
--utility-database <path_to/humann3/utility_mapping> \
--metaphlan-database </path_to/metaphlan_databases> 
```

## Required inputs

| Parameter | Description |
|:----------|:------------|
| `-i <input_dir>` | Path to directory with all the cleaned reads output from [QC module](qc_module) |
| `-o <output_dir>` | Path to directory where the PBS scripts and sub-directories will be generated |
| `--nucleotide-database` | Path to the Humann3 Chocophlan reference database for nucleotide search |
| `--protein-database` | Path to the Humann3 Uniref reference database for protein search |
| `--utility-database <path>` | directory containing the protein database, (default=/refdb/humann/utility_mapping) |
| `--metaphlan-database` | Path to the Metaphlan3 reference database for species matching |
| `--mpa3` | (optional) set this parameter if you need to run with Metaphlan 3 algorithm using the MIMA image with Metaphlan 4.0.1 installed|


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
usage: func_profiling.py -i INPUT_DIR -o OUTPUT_DIR [--function-profiler {humann3,humann2}]
                         [--fwd-suffix FWD_SUFFIX] [--rev-suffix REV_SUFFIX]
                         [--nucleotide-database NUCLEOTIDE_DATABASE]
                         [--protein-database PROTEIN_DATABASE]
                         [--utility-database UTILITY_DATABASE]
                         [--metaphlan-database METAPHLAN_DATABASE] [--mpa3]
                         [--mode {single,singularity}] [-w WALLTIME] [-M MEM] [-t THREADS]
                         [-e EMAIL] [--pbs-config PBS_CONFIG] [-h] [--pipeline-dir PIPELINE_DIR]
                         [--verbose] [--debug]

Function profiling module part of the MRC Metagenomics pipeline

[1] Required arguments:
  -i INPUT_DIR, --input-dir INPUT_DIR
                        path to input directory of cleaned sequences (e.g. QC_module/CleanReads)
  -o OUTPUT_DIR, --output-dir OUTPUT_DIR
                        path to output directory

[2] Function profile settings:
  --function-profiler {humann3,humann2}
                        select profiler for function profiling [default=humann3]
  --fwd-suffix FWD_SUFFIX
                        suffix of cleaned reads to search for in input_dir
                        [default=_clean_1.fq.gz]
  --rev-suffix REV_SUFFIX
                        suffix of reverse cleaned reads for PBS script [default=_clean_2.fq.gz]
  --nucleotide-database NUCLEOTIDE_DATABASE
                        HUMAnN3 directory containing the nucleotide database
                        [default=/refdb/humann/data/chocophlan]
  --protein-database PROTEIN_DATABASE
                        HUMAnN3 directory containing the protein database
                        [default=/refdb/humann/data/uniref]
  --utility-database UTILITY_DATABASE
                        HUMAnN3 utility mapping file
                        [default=/refdb/humann/data/utility_mapping]
  --metaphlan-database METAPHLAN_DATABASE
                        Metaphlan3 reference database (CHOCOPhlAn)
                        [default=/refdb/humann/metaphlan_databases]
  --mpa3                use Metaphlan 3 algorithm, used for backward compatibility with
                        Metaphlan 3 databases

[3] PBS settings:
  --mode {single,singularity}
                        Mode to generate PBS scripts, currently supports single sample mode only
                        [default=single]
  -w WALLTIME, --walltime WALLTIME
                        walltime hours required for PBS job of MODE [default=24]
  -M MEM, --mem MEM     memory (GB) required for PBS job of MODE [default=64]
  -t THREADS, --threads THREADS
                        number of threads for PBS job of MODE [default=28]
  -e EMAIL, --email EMAIL
                        PBS setting - email address
  --pbs-config PBS_CONFIG
                        Must be set when --mode singularity. Path to PBS configuration file
                        which must includ PBS headers and any other required settings to run the
                        singularity image. Contents in the config file will be included at the
                        top of all generated PBS scripts [default=None]

[4] Optional arguments:
  -h, --help            show this help message and exit
  --pipeline-dir PIPELINE_DIR
                        directory of pipeline script for finding combine_fastq.jl
  --verbose             turn on to show verbose messages
  --debug               turn on to show debugging messages
````
