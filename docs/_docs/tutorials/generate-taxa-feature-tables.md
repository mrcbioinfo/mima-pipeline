---
title: Generate taxonomic feature tables
---

# Combining taxonomic output

A taxonomy file will be generated for each input file, you will need to manually combine the taxonomy files to generate a feature table. 

**Feature table**: is a text file with $i$ rows (usually samples) and $j$ columns (usually taxon features), where the cells contain the count or proportion of taxon-$j$ for sample-$i$. Some tools require the feature table formatted the other way around with rows being features and rows being samples.

## Metaphlan2

````
perl metaphlan2_merge_table_2_ranks.pl <input_matrix> <metadata> <out_dir>
````

## KrakenUniq

```
usage: merge_krakenuniq_reports.jl [-i INPUT] -o OUTPUT
```

## Metaphlan3 

Use metadata from QC as input and direct files to your CleanRead folder as ` --input_dir`. 

```python
usage: mpa_tax.py [-h] --metadata METADATA [--type TYPE] [--threads THREADS]
                  --input_dir INPUT_DIR

optional arguments:
  -h, --help            show this help message and exit
  --metadata METADATA   path to metadata file in .csv format
  --type TYPE, -f TYPE  mem in Gb
  --threads THREADS, -t THREADS
                        number of threads
  --input_dir INPUT_DIR
                        file path to input directory of raw sequences
```


----

Once your command are generated, in Katana, create an array job to run the output of mpa_tax.py, example below

```python
#!/bin/bash
#PBS -l nodes=1:ppn=30
#PBS -l walltime=100:00:00
#PBS -l mem=100Gb


#PBS -J 1-394

cd /path/to/dir

source activate conda env

export FILENAME=`head -n $PBS_ARRAY_INDEX /path/to/dir/mpa.sh | tail -n 1`

(exec $FILENAME")
```
