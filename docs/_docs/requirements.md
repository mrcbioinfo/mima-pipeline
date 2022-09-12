---
title: Requirements
---

# Reference databases

Many steps in the pipeline require access to reference databases. These reference databases can be very big and often are already downloaded by the administators of the high-performance computing clusters. As such they are not included in the Singularity build. To run the pipeline you will need to know where the required reference databases are stored in order to provide the paths as a parameter setting.

## QC - decontamination

| Tool | Description |
|------|-------------|
| Minimap2 | requires reference genome |


## Taxonomy profiling


| Tool | Description |
|------|-------------|
| Kraken2 | requires reference database |


## Functional profiling


| Tool | Description |
|------|-------------|
| HUMAnN | requires reference databases |
| Metaphlan3 | requires reference database |


### Metaphlan database

- Disk space required:  ~26GB

- first following, [Install MIMA Singularity container](installation) tutorial
- ensure you have set the `SANDBOX` environment variable
- enter the command below to install the required database
  - `--bowtie2db` parameter lets you set a path to install the database (in the example below we are installing it in your home directory `~`) 

```
$ mkdir -p ~/refDB/metaphlan_databases
$ singularity exec $SANDBOX metaphlan --install --bowtie2db ~/refDB/metaphlan_databases/
```

- (OPTIONAL), if you want to install to another location, not your home drive then remember to use the `-B` parameter to mount paths when calling `singularity
  - as Singularity loads with minimum settings and won't know your local disk structure
- For example, below we are installing the metaphlan databases into the path `/another/loc/metaphlan_databases` and first have to use the `-B` parameter
```
$ singularity exec -B /another/loc/metaphlan_databases:/another/loc/metaphlan_databases $SANDBOX metaphlan --install --bowtie2db /another/loc/metaphlan_databases
```