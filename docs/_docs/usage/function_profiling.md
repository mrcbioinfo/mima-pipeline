---
title: func_profiling.py
---

The Functional Profiling module takes the CleanReads after quality check ([[QC module]]) and annotates each sequence read to a taxon depending on the selected approach.

This module currently creates one PBS script for each sample (with the *_clean1.fq.gz suffix, output from the [[QC module]])

Currently supported functional annotation approaches (select one or more): 

1. Humann2 ()
1. Humann3 ()


1. Create output directory **FunctProfiling**  <br/>
2. Set input directory as **CleanReads**  <br/>
3. Use julia to call the function below, ensuring --pipeline_dir is set to filepath for pipeline scripts  <br/>


***

# Basic usage

```
$ python3 functional_profiling.py -i </full_path/project_output>/QC_module/CleanReads \
-o </full_path/project_output> \
-e <your.email@address.com> \
--function-profiler humann3 \
--nucleotide-database </path_to/chocophlan> \
--protein-database </path_to/uniref>
```

## Required inputs

* **Input_dir** - Path to directory with all the *_clean1.fq.gz output from [[QC module]]

* **Output_dir**  - Path to directory where output will be generated, the "PBS_scripts" subdirectory will be created

* **Email** - to generate the PBS script

* **Profiler** - select which approach to use currently 'humann3'

## Outputs

The Functional profiling module will create two directories in the specified `<output_dir>` and a PBS script for each sample.

```
output_dir
├── Functional_profiling
    ├── featureTables/
```

|Directory | Description |
|:---------|:-------------|
| Functional_profiling | root directory of the functional profiling module, will have a subdirectory for each approach (e.g., humann3) |
| PBS_scripts | currently one PBS script is generated for each sample |


see [Combining function output](#combining-function-output) below


***

# Full help

```
usage: func_profiling.py -i INPUT_DIR -o OUTPUT_DIR -e EMAIL
                         [--function-profiler {humann3,humann2}]
                         [--fwd-suffix FWD_SUFFIX] [--rev-suffix REV_SUFFIX]
                         [--nucleotide-database NUCLEOTIDE_DATABASE]
                         [--protein-database PROTEIN_DATABASE] [--mode MODE]
                         [-w WALLTIME] [-M MEM] [-t THREADS] [-h]
                         [--pipeline-dir PIPELINE_DIR] [--verbose] [--debug]

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
  --mode MODE           Mode to generate PBS scripts, currently supports
                        single sample mode only [default=single]
  -w WALLTIME, --walltime WALLTIME
                        walltime hours required for PBS job of MODE
                        [default=20]
  -M MEM, --mem MEM     memory (GB) required for PBS job of MODE [default=60]
  -t THREADS, --threads THREADS
                        number of threads for PBS job of MODE [default=4]

[4] Optional arguments:
  -h, --help            show this help message and exit
  --pipeline-dir PIPELINE_DIR
                        directory of pipeline script for finding
                        combine_fastq.jl
  --verbose             turn on to show verbose messages
  --debug               turn on to show debugging messages

````
