## Create batch commands for Humann3 profiling 

Use metadata from QC as input and direct files to your CleanRead folder as ` --input_dir`. 

```
usage: humann3_func.py [-h] --metadata METADATA [--threads THREADS]
                       --input_dir INPUT_DIR

optional arguments:
  -h, --help            show this help message and exit
  --metadata METADATA   path to metadata file in .csv format
  --threads THREADS, -t THREADS
                        number of threads
  --input_dir INPUT_DIR
                        file path to input directory of clean sequences (post
                        QC)
```


Once your command are generated, in Katana, create and array job to run the output of humann3_func.py, example below

```python
#!/bin/bash
#PBS -l nodes=1:ppn=30
#PBS -l walltime=100:00:00
#PBS -l mem=100Gb


#PBS -J 1-XXX #number of lines of file 

cd /path/to/dir

source activate conda env #conda env name

export FILENAME=`head -n $PBS_ARRAY_INDEX /path/to/dir/humann3comands.sh | tail -n 1`

(exec $FILENAME")
```