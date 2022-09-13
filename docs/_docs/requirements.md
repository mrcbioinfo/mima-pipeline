---
title: Requirements
---

# Reference databases

Many steps in the pipeline require access to reference databases. These reference databases can be very big and often are already downloaded by the administators of the high-performance computing clusters. As such they are not included in the Singularity build. To run the pipeline you will need to know where the required reference databases are stored in order to provide the paths as a parameter setting.

## QC - decontamination

| Tool | Description | URL                |
|------|-------------|--------------------|
| Minimap2 | requires reference genome, we used the Humann reference genome GRCh38.p14 from NCBI (~800MB) | https://www.ncbi.nlm.nih.gov/data-hub/genome/GCF_000001405.40/ (download the Genomic sequence, fasta file) |


## Taxonomy profiling


| Tool | Description | URL |
|------|-------------|-----|
| Kraken2 | requires taxonomy reference database | Pre-built: https://benlangmead.github.io/aws-indexes/k2 |
| Bracken | build indexes from Kraken2 database | Pre-built: https://benlangmead.github.io/aws-indexes/k2 or see tutorial for [Bracken-build](https://ccb.jhu.edu/software/bracken/index.shtml?t=manual#step1){:target="_blank"} |


## Functional profiling


| Tool | Description | URL |
|------|-------------|-----|
| HUMAnN | requires gene reference databases | See below, https://huttenhower.sph.harvard.edu/humann |
| Metaphlan3 | requires taxonomy reference database | See below, https://github.com/biobakery/MetaPhlAn |

### HUMAnN database

- Disk space required: ~53GB
- Good network connection, some HPCs setup have specialised nodes for faster download
- Will require running several hours for download

- first follow [Install MIMA Singularity container](installation) tutorial
- ensure you have set the `SANDBOX` environment variable
- check database version

```
$ singularity exec $SANDBOX humann_databases --available
```

- this installs `v201901_v31` database version:
```
HUMAnN Databases ( database : build = location )
chocophlan : full = http://huttenhower.sph.harvard.edu/humann_data/chocophlan/full_chocophlan.v201901_v31.tar.gz
chocophlan : DEMO = http://huttenhower.sph.harvard.edu/humann_data/chocophlan/DEMO_chocophlan.v201901_v31.tar.gz
uniref : uniref50_diamond = http://huttenhower.sph.harvard.edu/humann_data/uniprot/uniref_annotated/uniref50_annotated_v201901b_full.tar.gz
uniref : uniref90_diamond = http://huttenhower.sph.harvard.edu/humann_data/uniprot/uniref_annotated/uniref90_annotated_v201901b_full.tar.gz
uniref : uniref50_ec_filtered_diamond = http://huttenhower.sph.harvard.edu/humann_data/uniprot/uniref_ec_filtered/uniref50_ec_filtered_201901b_subset.tar.gz
uniref : uniref90_ec_filtered_diamond = http://huttenhower.sph.harvard.edu/humann_data/uniprot/uniref_ec_filtered/uniref90_ec_filtered_201901b_subset.tar.gz
uniref : DEMO_diamond = http://huttenhower.sph.harvard.edu/humann_data/uniprot/uniref_annotated/uniref90_DEMO_diamond_v201901b.tar.gz
utility_mapping : full = http://huttenhower.sph.harvard.edu/humann_data/full_mapping_v201901b.tar.gz
```

- enter the command below to install the required databases
  - in the example below we are installing it to the path `~/refDB/humann3` (which is in your home directory), replace this with the location where you want to install the database
  - many HPC systems have limited space in your home directory, see your HPC setup

```
$ mkdir -p ~/refDB/humann3
$ singularity exec $SANDBOX humann_databases --download chocophlan full ~/refDB/humann3
$ singularity exec $SANDBOX humann_databases --download uniref uniref90_diamond ~/refDB/humann3
$ singularity exec $SANDBOX humann_databases --download utility_mapping full ~/refDB/humann3
$ tree -d .
```

```
.
├── chocophlan
├── uniref
└── utility_mapping
```


### Metaphlan database

- Disk space required:  ~26GB

- first follow [Install MIMA Singularity container](installation) tutorial
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