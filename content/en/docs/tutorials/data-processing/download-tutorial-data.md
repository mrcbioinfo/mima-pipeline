---
title: Download tutorial data
description: metadata and sequence data files for shotgun metagenomics data-processing
weight: 90
---

In the [data processing tutorials](../data-processing), we will use data from the study by 

{{% pageinfo %}}
[Tourlousse, *et al.* (2022)](https://journals.asm.org/doi/10.1128/spectrum.01915-21), Characterization and Demonstration of Mock Communities as Control Reagents for Accurate Human Microbiome Community Measures, Microbiology Spectrum.
 
This data set consists of two mock communities: *DNA-mock* and *Cell-mock*. The mock communities consists of bacteria that are mainly detected the human gastrointestinal tract ecosystem with a small mixture of some skin microbiota. The data was processed in three different labs: A, B and C. In the previous tutorial, , we only processed a subset of the samples (n=9). In this tutorial we will be working with the full data set which has been pre-processed using the same pipeline. In total there were 56 samples of which 4 samples fell below the abundance threshold and therefore the final taxonomy abundance table has 52 samples. We will train the random forest classifier to distinguish between the three labs.

- The raw reads are available from NCBI SRA <a href="https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA747117" target="_blank">Project PRJNA747117</a>, and there are 56 paired-end samples (112 fastq files)
- As the data is very big we will work with a subset (n=9 samples, 18 fastq files)
- This tutorial teaches you how to prepare the required raw fastq files
{{% /pageinfo %}}  


{{% alert title="Note" color="warning" %}}
You will need about 80GB of disk space depending on which option you used for downloading.
{{% /alert %}}

---

## Step 1) Download tutorial files

- Download the zip file [mima_tutorial.zip](https://github.com/mrcbioinfo/mima-pipeline/raw/master/examples/mima_tutorial.zip) via `wget`

```Shell
wget https://github.com/mrcbioinfo/mima-pipeline/raw/master/examples/mima_tutorial.zip
```

- Extract the archived file using `unzip`

```Shell
unzip mima_tutorial.zip
```

- Check the directory structure matches using `tree`

```Shell
tree mima_tutorial
```

```Text
~/mima_tutorial
├── ftp_download_files.sh
├── manifest.csv
├── pbs_header_func.cfg
├── pbs_header_qc.cfg
├── pbs_header_taxa.cfg
├── raw_data
└── SRA_files
```

{{% alert color=warning title="Note! Assumed working directory" %}}
This tutorial assumes the `~/mima_tutorial` directory is located in your *home directory* as indicated by the `~` (tilde) sign. If you have put the files in another location then replace all occurrences of `~/mima_tutorial` with your location (remember to use [absolute paths](../need-to-know#use-absolute-paths)).
{{% /alert %}}

**Data files**

| File                  | Description |
|:----------------------|:------------|
| ftp_download_files.sh | direct download FTP links used in [Option A: direct download](#option-a-direct-download) below |
| SRA_files             | contains the SRA identifier of the 9 samples used in [Option B](#option-b-download-with-sratoolkit) and [Option C](#option-c-download-via-mima-singularity) below |
| manifest.csv          | comma separated file of 3 columns, that lists the `sampleID, forward_filename, reverse_filename`|
| pbs_header_*.cfg      | PBS and Singularity configuration files, these are required for [Data processing with Singularity](tutorial-with-singularity) tutorial (not here) |


## Step 2) Download Sequence files

Choose from the 3 options for downloading the tutorial data depending on your environment setup:

| Option | Tool | Est. size | Description |
|--------|------|-----------|-------------|
| [A](#option-a-direct-download)      | `curl` | 24GB      | direct download using `curl` command, files are already compressed |
| [B](#option-b-download-with-sratoolkit)      | <a href="https://www.ncbi.nlm.nih.gov/sra/docs/sradownload/" target="_blank;">sratoolkit</a><br/>(installed on system) | 75GB | <p>download using `sratoolkit` which is available on your system or via *modules*</p><p>Thefiles are not compressed when downloaded; compression is a post-processing step</p> |
| [C](#option-c-download-via-mima)      | sratoolkit<br/>(installed in MIMA) | 75GB | installed in MIMA container; same as option B downloaded files are not compressed |


### Option A: direct download

- Run the following command for direct download

```Shell
bash FTP_download_files.sh
```


### Option B: download with `sratoolkit`

- Download the SRA files using `prefetch` command

```Shell
prefetch --option-file SRA_files --output-directory raw_data
```

Below is the output, wait until all files are downloaded

```Text
2022-09-08T05:50:42 prefetch.3.0.0: Current preference is set to retrieve SRA Normalized Format files with full base quality scores.
2022-09-08T05:50:42 prefetch.3.0.0: 1) Downloading 'SRR17380209'...
2022-09-08T05:50:42 prefetch.3.0.0: SRA Normalized Format file is being retrieved, if this is different from your preference, it may be due to current file availability.
2022-09-08T05:50:42 prefetch.3.0.0:  Downloading via HTTPS...
...
```

- After download finish, check the downloaded files with the `tree` command

```Shell
tree raw_data
```

```Text
raw_data/
├── SRR17380115
│   └── SRR17380115.sra
├── SRR17380118
│   └── SRR17380118.sra
├── SRR17380122
│   └── SRR17380122.sra
├── SRR17380209
│   └── SRR17380209.sra
├── SRR17380218
│   └── SRR17380218.sra
├── SRR17380222
│   └── SRR17380222.sra
├── SRR17380231
│   └── SRR17380231.sra
├── SRR17380232
│   └── SRR17380232.sra
└── SRR17380236
    └── SRR17380236.sra
```

- Extract the fastq files using the `fasterq-dump` command
- We'll also save some disk space by zipping up the fastq files using `bzip` (or `pigz`)

```Shell
cd ~/mima_tutorial/raw_data
fasterq-dump --split-files */*.
bzip2 *.fastq
tree .
```

```Text
.
├── SRR17380115
│   └── SRR17380115.sra
├── SRR17380115_1.fastq.gz
├── SRR17380115_2.fastq.gz
├── SRR17380118
│   └── SRR17380118.sra
├── SRR17380118_1.fastq.gz
├── SRR17380118_2.fastq.gz
├── SRR17380122
│   └── SRR17380122.sra
├── SRR17380122_1.fastq.gz
├── SRR17380122_2.fastq.gz
├── SRR17380209
│   └── SRR17380209.sra
├── SRR17380209_1.fastq.gz
├── SRR17380209_2.fastq.gz
├── SRR17380218
│   └── SRR17380218.sra
├── SRR17380218_1.fastq.gz
├── SRR17380218_2.fastq.gz
├── SRR17380222
│   └── SRR17380222.sra
├── SRR17380222_1.fastq.gz
├── SRR17380222_2.fastq.gz
├── SRR17380231
│   └── SRR17380231.sra
├── SRR17380231_1.fastq.gz
├── SRR17380231_2.fastq.gz
├── SRR17380232
│   └── SRR17380232.sra
├── SRR17380232_1.fastq.gz
├── SRR17380232_2.fastq.gz
├── SRR17380236
│   └── SRR17380236.sra
├── SRR17380236_1.fastq.gz
└── SRR17380236_2.fastq.gz
```


### Option C: download via MIMA

- Assume have [installed](/docs/installation) MIMA and set up the `SANDBOX` environment variable
- Download the SRA files using the following command

```Shell
apptainer exec $SANDBOX prefetch --option-file SRA_files --output-directory raw_data
```

- Below is the output, wait until all files are downloaded

```Text
2022-09-08T05:50:42 prefetch.3.0.0: Current preference is set to retrieve SRA Normalized Format files with full base quality scores.
2022-09-08T05:50:42 prefetch.3.0.0: 1) Downloading 'SRR17380209'...
2022-09-08T05:50:42 prefetch.3.0.0: SRA Normalized Format file is being retrieved, if this is different from your preference, it may be due to current file availability.
2022-09-08T05:50:42 prefetch.3.0.0:  Downloading via HTTPS...
...
```

- After download finishes, check the downloaded files

```Shell
tree raw_data
```

```Text
raw_data/
├── SRR17380115
│   └── SRR17380115.sra
├── SRR17380118
│   └── SRR17380118.sra
├── SRR17380122
│   └── SRR17380122.sra
├── SRR17380209
│   └── SRR17380209.sra
├── SRR17380218
│   └── SRR17380218.sra
├── SRR17380222
│   └── SRR17380222.sra
├── SRR17380231
│   └── SRR17380231.sra
├── SRR17380232
│   └── SRR17380232.sra
└── SRR17380236
    └── SRR17380236.sra
```

- Extract the fastq files using the `fasterq-dump` command
- We'll also save some disk space by zipping up the fastq files using `bzip` (or `pigz`)

```Shell
cd ~/mima_tutorial/raw_data
singularity exec $SANDBOX fasterq-dump --split-files */*.
singularity exec $SANDBOX bzip2 *.fastq
tree .
```

```Text
.
├── SRR17380115
│   └── SRR17380115.sra
├── SRR17380115_1.fastq.gz
├── SRR17380115_2.fastq.gz
├── SRR17380118
│   └── SRR17380118.sra
├── SRR17380118_1.fastq.gz
├── SRR17380118_2.fastq.gz
├── SRR17380122
│   └── SRR17380122.sra
├── SRR17380122_1.fastq.gz
├── SRR17380122_2.fastq.gz
├── SRR17380209
│   └── SRR17380209.sra
├── SRR17380209_1.fastq.gz
├── SRR17380209_2.fastq.gz
├── SRR17380218
│   └── SRR17380218.sra
├── SRR17380218_1.fastq.gz
├── SRR17380218_2.fastq.gz
├── SRR17380222
│   └── SRR17380222.sra
├── SRR17380222_1.fastq.gz
├── SRR17380222_2.fastq.gz
├── SRR17380231
│   └── SRR17380231.sra
├── SRR17380231_1.fastq.gz
├── SRR17380231_2.fastq.gz
├── SRR17380232
│   └── SRR17380232.sra
├── SRR17380232_1.fastq.gz
├── SRR17380232_2.fastq.gz
├── SRR17380236
│   └── SRR17380236.sra
├── SRR17380236_1.fastq.gz
└── SRR17380236_2.fastq.gz
```


## Step 3) Check manifest

- Examine the manifest file

```Shell
cat mima_tutorial/manifest.csv
```

- Your output should looking like something below
  - Check column 2 (`FileID_R1`) and column 3 (`FileID_R2`) match the names of the files in `raw_data`
- Update the manifest file as required

```Text
Sample_ID,FileID_R1,FileID_R2
SRR17380209,SRR17380209_1.fastq.gz,SRR17380209_2.fastq.gz
SRR17380232,SRR17380232_1.fastq.gz,SRR17380232_2.fastq.gz
SRR17380236,SRR17380236_1.fastq.gz,SRR17380236_2.fastq.gz
SRR17380231,SRR17380231_1.fastq.gz,SRR17380231_2.fastq.gz
SRR17380218,SRR17380218_1.fastq.gz,SRR17380218_2.fastq.gz
SRR17380222,SRR17380222_1.fastq.gz,SRR17380222_2.fastq.gz
SRR17380118,SRR17380118_1.fastq.gz,SRR17380118_2.fastq.gz
SRR17380115,SRR17380115_1.fastq.gz,SRR17380115_2.fastq.gz
SRR17380122,SRR17380122_1.fastq.gz,SRR17380122_2.fastq.gz
```

{{% alert color=warning title="Manifest file formats" %}}
  - the first row is the header and is case sensitive, it must have the three columns: `Sample_ID,FileID_R1,FileID_R2`
  - the filenames in columns 2 and 3 do not need to be [absolute paths](../need-to-know/#use-absolute-paths) as the directory where the files are located will be specified during [quality checking](../mima-apptainer-qc)
{{% /alert %}}


Remember to check out what else you [need to know](../need-to-know) before jumping into [quality checkking](../mima-apptainer-qc)
