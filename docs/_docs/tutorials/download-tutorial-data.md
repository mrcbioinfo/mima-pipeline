---
title: Download tutorial data
---

# Tutorial data

In the tutorials, [Data processing with Singularity](tutorial-with-singularity) and [Data processing without Singularity](tutorial-no-singularity), we will use data from the study by 

> [Tourlousse, *et al.* (2022)](https://journals.asm.org/doi/10.1128/spectrum.01915-21){:target="_blank"}, Characterization and Demonstration of Mock Communities as Control Reagents for Accurate Human Microbiome Community Measures, Microbiology Spectrum.
> 
> This data set consists of two mock communities: *DNA-mock* and *Cell-mock*. The mock communities consists of bacteria that are mainly detected the human gastrointestinal tract ecosystem with a small mixture of some skin microbiota. The data was processed in three different labs: A, B and C. In the previous tutorial, , we only processed a subset of the samples (n=9). In this tutorial we will be working with the full data set which has been pre-processed using the same pipeline. In total there were 56 samples of which 4 samples fell below the abundance threshold and therefore the final taxonomy abundance table has 52 samples. We will train the random forest classifier to distinguish between the three labs.

- The raw reads are available from NCBI SRA [Project PRJNA747117](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA747117){:target="_blank"}, and there are 56 paired-end samples (112 fastq files)
- As the data is very big we will work with a subset (n=9 samples, 18 fastq files)
- This tutorial teaches you how to prepare the required raw fastq files
  
{% include alert.html type="warning" title="Note" content="You will need about 80GB of disk space depending on which option you used for downloading." %}

---

# Step 1) Download tutorial files

- Enter the commands below in your terminal
  - `wget` downloads the zip file [mima_tutorial.zip](https://github.com/xychua/test-gitpages/raw/master/examples/mima_tutorial.zip)
  - `unzip` unpacks the file
  - `tree` checks the directory structure

{% include alert.html type='warning' title="Working directory" content="We will assume that the `~/mima_tutorial` directory is located in your *home directory* (indicated by the tilde, `~`, symbol), **change the paths as needed** if you downloaded the files in another location." %}

```
$ wget https://github.com/xychua/test-gitpages/raw/master/examples/mima_tutorial.zip
$ unzip mima_tutorial.zip
$ tree mima_tutorial
```

```
~/mima_tutorial
├── ftp_download_files.sh
├── manifest.csv
├── pbs_header_func.cfg
├── pbs_header_qc.cfg
├── pbs_header_taxa.cfg
├── raw_data
└── SRA_files
```

**Data files**

| File                  | Description |
|:----------------------|:------------|
| ftp_download_files.sh | direct download FTP links used in [Option A: direct download](#option-a-direct-download) below |
| SRA_files             | contains the SRA identifier of the 9 samples used in [Option B](#option-b-download-with-sratoolkit) and [Option C](#option-c-download-via-mima-singularity) below |
| manifest.csv          | comma separated file of 3 columns, that lists the `sampleID, forward_filename, reverse_filename`|
| pbs_header_*.cfg      | PBS and Singularity configuration files, these are required for [Data processing with Singularity](tutorial-with-singularity) tutorial (not here) |


# Step 2) Download SRA files

There are 3 options for data download depending on your environment setup.

- [Option A: direct download](#option-a-direct-download) using `curl` command, the files will already be compressed, **you will need ~24GB disk space**. This is specific for this tutorial.

- Options B and C uses the [sratoolkit](https://www.ncbi.nlm.nih.gov/sra/docs/sradownload/) command line tool to download SRA files and unpack them using `fasterq-dump`. **You will need ~75GB disk space before compression**, after compression this will reduce to ~24GB. This option is useful for any public data that is available on NCBI SRA.
  - Follow [Option B: download with `sratoolkit`](#option-b-download-with-sratoolkit) if your system already have the `sratoolkit` installed or via *modules*
  - Follow [Option C: download via MIMA](#option-c-download-via-MIMA) if your system does not have `sratoolkit`


## Option A: direct download

- Run the following command for direct download (for this tutorial)

```
$ bash FTP_download_files.sh
```


## Option B: download with `sratoolkit`

- Download the SRA files using `prefetch` command

```
$ prefetch --option-file SRA_files --output-directory raw_data
```

Below is the output, wait until all files are downloaded

```
2022-09-08T05:50:42 prefetch.3.0.0: Current preference is set to retrieve SRA Normalized Format files with full base quality scores.
2022-09-08T05:50:42 prefetch.3.0.0: 1) Downloading 'SRR17380209'...
2022-09-08T05:50:42 prefetch.3.0.0: SRA Normalized Format file is being retrieved, if this is different from your preference, it may be due to current file availability.
2022-09-08T05:50:42 prefetch.3.0.0:  Downloading via HTTPS...
...
```

- After download finish, check the downloaded files with the `tree` command

```
$ tree raw_data
```

```
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

```
$ cd ~/mima_tutorial/raw_data
$ fasterq-dump --split-files */*.
$ bzip2 *.fastq
$ tree .
```

```
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

---

## Option C: download via MIMA Singularity

- First run [Install MIMA Pipeline Singularity container](installation) and set up the `SANDBOX` environment variable
- Download the SRA files using `prefetch` command

```
$ singularity exec $SANDBOX prefetch --option-file SRA_files --output-directory raw_data
```

- Below is the output, wait until all files are downloaded

```
2022-09-08T05:50:42 prefetch.3.0.0: Current preference is set to retrieve SRA Normalized Format files with full base quality scores.
2022-09-08T05:50:42 prefetch.3.0.0: 1) Downloading 'SRR17380209'...
2022-09-08T05:50:42 prefetch.3.0.0: SRA Normalized Format file is being retrieved, if this is different from your preference, it may be due to current file availability.
2022-09-08T05:50:42 prefetch.3.0.0:  Downloading via HTTPS...
...
```

- After download finishes, check the downloaded files

```
$ tree raw_data
```

```
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

```
$ cd ~/mima_tutorial/raw_data
$ singularity exec $SANDBOX fasterq-dump --split-files */*.
$ singularity exec $SANDBOX bzip2 *.fastq
$ tree .
```

```
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

---

# Check manifest.csv

- check that the filenames (columns 2 and 3) listed in the `manifest.csv` match with the fastq files present
- if not then update the `manifest.csv` file as required

```
$ cat ~/mima_tutorial/manifest.csv
```

```
Sample_ID,FileID_R1,FileID_R2
SRR17380209,SRR17380209.sra_1.fastq.gz,SRR17380209.sra_2.fastq.gz
SRR17380232,SRR17380232.sra_1.fastq.gz,SRR17380232.sra_2.fastq.gz
SRR17380236,SRR17380236.sra_1.fastq.gz,SRR17380236.sra_2.fastq.gz
SRR17380231,SRR17380231.sra_1.fastq.gz,SRR17380231.sra_2.fastq.gz
SRR17380218,SRR17380218.sra_1.fastq.gz,SRR17380218.sra_2.fastq.gz
SRR17380222,SRR17380222.sra_1.fastq.gz,SRR17380222.sra_2.fastq.gz
SRR17380118,SRR17380118.sra_1.fastq.gz,SRR17380118.sra_2.fastq.gz
SRR17380115,SRR17380115.sra_1.fastq.gz,SRR17380115.sra_2.fastq.gz
SRR17380122,SRR17380122.sra_1.fastq.gz,SRR17380122.sra_2.fastq.gz
```

Now you're ready to begin the tutorials:

- [Data processing with Singularity](tutorial-with-singularity) or
- [Data processing without Singularity](tutorial-no-singularity)

---

# References

- https://www.ncbi.nlm.nih.gov/sra/docs/sradownload/