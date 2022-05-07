---
title: Installation
---

# Setting up the MIMA environent

In order to use the MIMA pipeline **without Singularity**, you will need to install the following

1. Install Miniconda [guide](https://docs.conda.io/en/latest/miniconda.html#installing)
2. Download the `mima-conda-env.yml` configuration file [download]()
3. Create the MIMA environment, in the terminal where you downloaded the `mima-conda-env.yml` file, type

```
$ conda env create -f mima-conda-env.yml
```

Test the installation:

```
$ conda activate mima
```


{% include alert.html type="danger" title="Install MIMA" content="Need instructions to install the mima scripts within the mima conda environment" %}





```
conda activate mpa3.7
conda install -c bioconda bbmap
conda install -c bioconda fastp
conda install -c bioconda minimap2
conda install -c bioconda kraken2
conda install -c bioconda bracken
conda install -c biobakery humann
conda install -c anaconda pandas
```

tested versions from bioconda, biobakery and anaconda
- bbmap v38.96
- minimap2 v2.24
- fastp v0.23.2
- kraken2 v2.1.2
- bracken v2.6.2
- humann v3.0.1
