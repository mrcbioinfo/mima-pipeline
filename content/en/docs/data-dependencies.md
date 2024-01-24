---
title: Data dependencies
weight: 30
---

Many steps in the pipeline require access to reference databases. These reference databases are very big and are often already downloaded by the system administrators. As such they are not included in the container images.

{{% pageinfo color=warning %}}
To run the pipeline you need to know the [absolute paths](/docs/tutorials/data-processing/need-to-know/#use-absolute-paths) for the below reference databases. 

* minimap2
* kraken2 and bracken
* humann
  * CHOCOPhlAn
  * uniref
* metaphlan CHOCOPhlAn database

You might also need to set up [path binding](../what-is-container/#path-binding) when deploying the containers.
{{% /pageinfo %}}

If you are missing any reference datasets, see below for download information.

## QC: decontamination step

| Tool | Description | URL                |
|------|-------------|--------------------|
| Minimap2 | requires reference genome, we used the Humann reference genome GRCh38.p14 from NCBI (~800MB) | <a href="https://www.ncbi.nlm.nih.gov/data-hub/genome/GCF_000001405.40/" target="_blank;">https://www.ncbi.nlm.nih.gov/data-hub/genome/GCF_000001405.40/</a> (download the Genomic sequence, fasta file) |


## Taxonomy profiling


| Tool | Description | URL |
|------|-------------|-----|
| Kraken2 | requires taxonomy reference database | Pre-built: <a href="https://benlangmead.github.io/aws-indexes/k2" target="_blank;">https://benlangmead.github.io/aws-indexes/k2</a> |
| Bracken | build indexes from Kraken2 database | Pre-built: <a href="https://benlangmead.github.io/aws-indexes/k2" target="_blank;">https://benlangmead.github.io/aws-indexes/k2</a> or see the <a href="https://ccb.jhu.edu/software/bracken/index.shtml?t=manual#step1" target="_blank">Bracken build tutorial</a> |


## Functional profiling

### HUMAnN database

- Requires 3 reference databases, below are instructions to download using the MIMA container setup or you can refer to the <a href="https://huttenhower.sph.harvard.edu/humann" target="_blank;">developer's documentation</a>
- Estimated disk space: ~53GB (you might need several hours for downloading)
- After [installing MIMA container](../installation), ensure you have [set the `SANDBOX` environment variable](../installation/#build-a-sandbox)
- You can check required database version using the command:
```
$ singularity exec $SANDBOX humann_databases --available
```
  
*output:*

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

- The first command creates a new folder `~/refDB/humann3` in your home directory
- The next three commands install the three required databases
  - note that many HPC systems have limited space in your home directory (`~`).
- Replace `~/refDB/humann3` with your preferred location as needed, if [installing to external path](#installing-to-external-path) remember to set path binding.

```bash
$ mkdir -p ~/refDB/humann3
$ apptainer exec $SANDBOX humann_databases --download chocophlan full ~/refDB/humann3
$ apptainer exec $SANDBOX humann_databases --download uniref uniref90_diamond ~/refDB/humann3
$ apptainer exec $SANDBOX humann_databases --download utility_mapping full ~/refDB/humann3
```

- After installation, check the files

```
$ tree -d ~/refDB/humann3
.
├── chocophlan
├── uniref
└── utility_mapping
```


### MetaPhlAn database

- Estimated disk space: ~26GB or see the <a href=" [https://github.com/biobakery/MetaPhlAn" target="_blank">developer's documentation</a>
- After [installing MIMA container](../installation), ensure you have [set the `SANDBOX` environment variable](../installation/#build-a-sandbox)
- The command below installs the required Bowtie2 database where the `--bowtie2db` parameter lets you set the path
  - the example below installs it in your home directory (`~`)
- Replace `~/refDB/metaphlan_databases/` with your preferred location as needed, if [installing to external path](#installing-to-external-path) remember to set path binding.

```
$ mkdir -p ~/refDB/metaphlan_databases
$ apptainer exec $SANDBOX metaphlan --install --bowtie2db ~/refDB/metaphlan_databases/
```


## Installing to external path

If you are using the MIMA container to install reference databases to a location other than your home directory, remember to set [path binding](../what-is-container/#path-binding).

The example below uses `-B` parameter:
```
$ apptainer exec -B /another/loc/metaphlan_databases:/another/loc/metaphlan_databases $SANDBOX metaphlan --install --bowtie2db /another/loc/metaphlan_databases
```