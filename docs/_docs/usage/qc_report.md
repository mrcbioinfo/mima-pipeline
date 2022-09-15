---
title: qc_report.py
---

This script parses the PBS log files and the Fastp JSON output files for all samples defined in the *`manifest.csv`* file. The script generates a tab-separated output file in: `output_dir/QCmodule/qc_report.tsv`.

**!!NOTE** the current version assumes the PBS log files are in the `input_dir` path and that this location contains the `QCReport` directory from [qc_module]({{ site.baseurl }}/docs/usage/qc_module).

The table columns are described below.


***


# Basic usage

```
singularity run --app mima-qc-report $SANDBOX -i <path/to/input_dir> -o <path/to/output_dir> -m <path/to/METADATA>
```

## Required inputs

| Parameter | Description |
|:----------|:------------|
| `-i <input_dir>` | Path to directory where your PBS log files are located from the [QC module](../qc_module) |
| `-o <output_dir>` | Path to output directory where QC_report.csv is saved |
| `-m <manifest.csv>` | The manifest file is a CSV text file that contains metadata about the raw FastQ files. The current version expected paired-end reads with separate files for the forward and reverse reads. The CSV format contains three columns with the headings: **Sample_ID,FileID_R1,FileID_R2**. The headings are case sensitive with no spaces between commas (see example below) |

```
      Sample_ID,FileID_R1,FileID_R2
      SRR123456,SRR123456_R1_001.fastq.gz,SRR123456_R2_001.fastq.gz
      SRR999999,SRR999999_R1_001.fastq.gz,SRR999999_R2_001.fastq.gz
```



## Outputs

The QC report is a tab-separated file with the following columns:

|Column name    | Description |
|:--------------|:------------|
|SampleId       |Sample identifier from manifest.csv file|
|Rawreads_seqs  |Number of raw reads in the FastQ files|
|Derep_seqs     |Number of dereplicated reads that were removed|
|PCR_duplicates(%)|Percentage of duplicated reads|
|Post_QC_seqs   |Number of reads remaining after quality check (with Fastp)|
|low_quality_reads(%)|Percentage of low quality reads that were removed|
|Host_seqs      |Number of reads that mapped to the host genome (with minimap2)|
|Host(%)        |Percentage of host reads that were removed|
|Clean_reads    |Number of cleaned reads that remain after all quality checking steps have completed|


***


# Full help

```
usage: qc_report.py -i INPUT_DIR -o OUTPUT_DIR -m MANIFEST [-h] [--verbose] [--debug]

Generates QC report of your sequences

[1] Required arguments:
  -i INPUT_DIR, --input-dir INPUT_DIR
                        path to directory which consists the QCReport folder from qc_module.py
                        script. The QCReport folder contains the JSON report from FastP. This
                        script assumes that the PBS log files are in this directory. It will
                        search for PBS log files with the suffix 'qc_module.oXXX' where XXX is
                        the PBS job ID.
  -o OUTPUT_DIR, --output-dir OUTPUT_DIR
                        path to output directory
  -m MANIFEST, --manifest MANIFEST
                        path to manifest file in .csv format. The header line is case sensitive,
                        and must follow the following format with no spaces between commas.
                        Sample_ID,FileID_R1,FileID_R2

[2] Optional arguments:
  -h, --help            show this message and exit
  --verbose             turn on will return verbose message
  --debug               turn on will return debugging messages

```