---
title: Taxonomy Profiling
description: assign reads to taxa, generating a taxonomy feature table ready for analysis
weight: 120
---

## Introduction to Taxonomy Profiling

Taxonomy profiling takes the quality controlled (clean) sequenced reads as input and matches them against a reference database of previously characterised sequences for taxonomy classification.

There are many different classification tools, for example: Kraken2, MetaPhlAn, Clark, Centrifuge, MEGAN, and many more.

This pipeline uses Kraken2 and Bracken abundance estimation. Both require access to [reference database]({{< ref "data-dependencies.md#taxonomy-profiling" >}}) or you can generate your own reference data. In this pipeline, we will use the <a href="https://gtdb.ecogenomic.org/" target="_blank">GTDB</a> database (release 95) and have built a Kraken2 database.

### Workflow description

Kraken2 requires big memory (~300GB) to run, so there is only one PBS script that will execute each sample sequentially. 

In this tutorial, we have 9 samples which will be executed within one PBS job.

Steps in the taxonomy profiling module:

<table class="table table-borderless">
<tr>
  <th>Step</th>
  <th></th>
</tr>
<tr>
  <td><b>Kraken2</b> assigns each read to a lowest common ancestor by matching the sequenced reads against a reference database of previously classified species</td>
  <td rowspan=3 style="width:40%"><img src="../images/tut_TAXApipeline.png"/></td>
</tr>
<tr>
  <td><b>Bracken</b> takes the Kraken2 output to estimate abundances for a given taxonomic rank. This is repeated from Phylum to Species rank.</td>
</tr>
<tr>
  <td><b>Generate feature table</b> is performed after <i>all samples</i> assigned to a taxa and abundances estimated. This step combines the output for all samples and generates a <i>feature table</i> for a given taxonomic rank. The feature table contains discrete counts and relative abundances of <i>"taxon X occurring in sample Y"</i>.</td>
</tr>
</table>


## Step 1. Generate PBS script

Before starting, have you understood the [need to know]({{< ref "need-to-know" >}}) points?

- After [QC checking]({{< ref "mima-apptainer-qc" >}}) your sequence samples and generating a set of `CleanReads`
- Find the [absolute paths]({{< ref "need-to-know.md#use-absolute-paths" >}}) for the **Kraken2** and **Bracken** reference databases on your HPC system (**!!** they need to be in the same directory)
- Replace the highlighted line `--reference-path <path/to/Kraken2_db>` with the Kraken2 absolute path
  - the backslash (`\`) at the end of each line informs the terminal that the command has not finished and there's more to come (we broke up the command for readability purposes to explain each parameter below)
  - *note* if you enter the command as one line, remove the backslashes

{{< highlight Tcsh "linenos=table,hl_lines=4,linenostart=1" >}}
apptainer run --app mima-taxa-profiling $SANDBOX \
-i ~/mima_tutorial/output/QC_module/CleanReads \
-o ~/mima_tutorial/output \
--reference-path </path/to/Kraken2_db> \
--read-length 150 \
--threshold 100 \
--mode container \
--pbs-config ~/mima_tutorial/pbs_header_taxa.cfg
{{< /highlight >}}


{{% alert info=warn %}}
For MRC users, see <a href="https://unsw.sharepoint.com/:w:/r/sites/mrc_bioinformatics_unit/_layouts/15/doc2.aspx?sourcedoc=%7BBF4C59B2-9C8D-4868-AB8C-5B6B4C206252%7D&file=Katana%20reference%20databases%20-%20MIMA%20pipeline.docx&action=default&mobileredirect=true" target="_blank;">here for file locations</a>
{{% /alert %}}


### Parameters explained

| <div style="width:150px">Parameter</div> | Required? | Description |
|--------------|-----------|-------------|
| `-i <input>` | yes | full path to the `~/mima_tutorial/output/QC_module/CleanReads` directory that was generated from Step 1) QC, above. This directory should hold all the `*_clean.fastq` files |
| `-o <output>` | yes | full path to the `~/mima_tutorial/output` directory where you would like the output files to be saved, can be the same as Step 1) QC |
| `--reference-path` | yes | full path to the reference database (this pipeline uses the GTDB release 95 reference database) |
| `--read-length` | no (default=150) | read length for Bracken estimation, choose the value closest to your sequenced read length (choose from 50, 75, 100 and 150) |
| `--threshold` | no (default=1000) | Bracken filtering threshold, features with counts below this value are filtered in the abundance estimation |
| `--mode container` | no (default=single) | set this if you are running as a Container. By default, the PBS scripts generated are for the 'standalone' option, that is without Singularity |
| `--pbs-config` | yes if `--mode container` | path to the pbs configuration file (see below). You must specify this parameter if `--mode container` is set. You do not need to set this parameter if running outside of Singularity | 

If you changed the file extension of the cleaned files or are working with already cleaned files from somewhere else, you can specify the forward and reverse suffix using:

| <div style="width:150px">Parameter</div> | Required? | Description |
|--------------|-----------|-------------|
| `--fwd-suffix` | default=_clean_1.fq.gz | file suffix for cleaned forward reads from QC module |
| `--rev-suffix` | default=_clean_2.fq.gz | file suffix for cleaned reverse reads from QC module |



## Step 2. Check generated scripts

- After Step 1, you should see in the output directory: `~/mima_tutorial/output/Taxonomy_profiling`
  - one PBS script
  - one bash script/sample (total of 9 bash scripts in this tutorial)
- Have a look at the directory structure using `tree`

```Shell
tree ~/mima_tutorial/output/Taxonomy_profiling
```

Expected directory structure
  - **braken/** and **kraken2/** are subdirectories created by Step 2 to store the output files after PBS job is executed

```Text
.
├── bracken
├── featureTables
│   └── generate_bracken_feature_table.py
├── kraken2
├── run_taxa_profiling.pbs
├── SRR17380209.sh
├── SRR17380232.sh
├── SRR17380236.sh
└── ...
```


## Step 3. Submit Taxonomy job

- Let's examine the PBS script to be submitted

```Shell
cat ~/mima_tutorial/output/Taxonomy_profiling/run_taxa_profiling.pbs
```

* Your PBS script should look something like below, with some differences
  - line 10: `IMAGE_DIR` should be where you installed MIMA and [build the sandbox]({{< ref "installation.md#build-a-sandbox" >}})
  - line 11: `APPTAINER_BIND` should be setup during installation when [binding paths]({{< ref "what-is-container.md#path-binding" >}})
    - make sure to include the path where the host reference genome file is located
  - line 14: `/home/user` is replaced with the [absolute path]({{< ref "need-to-know.md#use-absolute-paths" >}}) to your actual home directory

{{< highlight Bash "linenos=table,hl_lines=10-11 14,linenostart=1" >}}
#!/bin/bash
#PBS -N mima-taxa
#PBS -l ncpus=28
#PBS -l walltime=10:00:00
#PBS -l mem=300GB
#PBS -j oe

set -x

IMAGE_DIR=~/mima-pipeline
export SINGULARITY_BIND="/path/to/kraken2/reference_database:/path/to/kraken2/reference_database"


cd /home/user/mima_tutorial/output/Taxonomy_profiling/

apptainer exec ${IMAGE_DIR} bash /home/user/mima_tutorial/output/Taxonomy_profiling/SRR17380209.sh
apptainer exec ${IMAGE_DIR} bash /home/user/mima_tutorial/output/Taxonomy_profiling/SRR17380232.sh
...
{{< /highlight >}}

{{% alert color=info title="Tip: when running your own study" %}}
- increase the walltime if you have alot of samples
- increase the memory as needed
{{% /alert %}}


- Change directory to `~/mima_tutorial/output/Taxonomy_profiling`
- Submit PBS job using `qsub`

```Shell
cd ~/mima_tutorial/output/Taxonomy_profiling
qsub run_taxa_profiling.pbs
```

- You can check the job statuses with `qstat`
- Wait for the job to complete


## Step 4. Check Taxonomy outputs

- After the PBS job completes, you should have the following outputs

```Shell
tree ~/mima_tutorial/output/Taxonomy_profiling
```

- Only a subset of the outputs are shown below with `...` meaning *"and others"*
- You'll have a set of output for each sample that passed the QC step

```Text
~/mima_tutorial/output/Taxonomy_profiling
├── bracken
│   ├── SRR17380218_class
│   ├── SRR17380218_family
│   ├── SRR17380218_genus
│   ├── SRR17380218.kraken2_bracken_classes.report
│   ├── SRR17380218.kraken2_bracken_families.report
│   ├── SRR17380218.kraken2_bracken_genuses.report
│   ├── SRR17380218.kraken2_bracken_orders.report
│   ├── SRR17380218.kraken2_bracken_phylums.report
│   ├── SRR17380218.kraken2_bracken_species.report
│   ├── SRR17380218_order
│   ├── SRR17380218_phylum
│   ├── SRR17380218_species
│   └── ...
├── featureTables
│   └── generate_bracken_feature_table.py
├── kraken2
│   ├── SRR17380218.kraken2.output
│   ├── SRR17380218.kraken2.report
│   ├── ...
│   ├── SRR17380231.kraken2.output
│   └── SRR17380231.kraken2.report
├── QC_module_0.o3492470
├── run_taxa_profiling.pbs
├── SRR17380209.sh
├── SRR17380218_bracken.log
├── SRR17380218.sh
├── SRR17380222_bracken.log
├── SRR17380222.sh
├── SRR17380231_bracken.log
├── SRR17380231.sh
├── SRR17380232.sh
└── SRR17380236.sh
```

#### Output files

| Directory / Files | Description |
| ----------------- | ----------- |
| output | specified in the `--output-dir <output>` parameter set in step 1b) |
| Taxonomy_profiling | contains all files and output from this step |
| Taxonomy_profiling/\*.sh | are all the bash scripts generated by step 2b) for taxonomy profiling |
| Taxonomy_profiling/run_taxa_profiling.pbs | is the PBS wrapper generated by step 2b) that will execute each sample sequentially |
| Taxonomy_profiling/bracken | consists of the abundance estimation files from Bracken, one per sample, output after PBS submission |
| Taxonomy_profiling/featureTables | consists of the merged abundance tables generated by step 2e) below |
| Taxonomy_profiling/kraken2 | consists of the output from Kraken2 (two files per sample), output after PBS submission |


See the tool website for further details about the <a href="https://github.com/DerrickWood/kraken2/wiki/Manual#output-formats" target="_blank;">Kraken2 output</a> and <a href="https://ccb.jhu.edu/software/bracken/index.shtml?t=manual#format" target="_blank;">Bracken output</a>


## Step 5. Generate taxonomy abundance table

- After **all samples** have been taxonomically annotated by Kraken2 and abundance estimated by Bracken, we need to combine the tables
- Navigate to `~/mima_tutorial/output/Taxonomy_profiling/featureTables`
- Run the commands below directly from terminal (not a PBS job)
- Check the output with `tree`

```Shell
cd ~/mima_tutorial/output/Taxonomy_profiling/featureTables
apptainer exec $SANDBOX python3 generate_bracken_feature_table.py
tree .
```

- All bracken output files will be concatenated into a table, one for each taxonomic rank from Phylum to Species
    - table rows are taxonomy features
    - table columns are abundances
- By default, the tables contain two columns for one sample: (i) discrete counts and (ii) relative abundances 
- The `generate_bracken_feature_table.py` will split the output into two files with the suffices:
    - `_counts` for discrete counts and
    - `_relAbund` for relative abundances

```Text
.
├── bracken_FT_class
├── bracken_FT_class_counts
├── bracken_FT_class_relAbund
├── bracken_FT_family
├── bracken_FT_family_counts
├── bracken_FT_family_relAbund
├── bracken_FT_genus
├── bracken_FT_genus_counts
├── bracken_FT_genus_relAbund
├── bracken_FT_order
├── bracken_FT_order_counts
├── bracken_FT_order_relAbund
├── bracken_FT_phylum
├── bracken_FT_phylum_counts
├── bracken_FT_phylum_relAbund
├── bracken_FT_species
├── bracken_FT_species_counts
├── bracken_FT_species_relAbund
├── combine_bracken_class.log
├── combine_bracken_family.log
├── combine_bracken_genus.log
├── combine_bracken_order.log
├── combine_bracken_phylum.log
├── combine_bracken_species.log
└── generate_bracken_feature_table.py
```

## Step 6. (optional) Generate summary report

- You can generate a summary report after the Bracken abundance estimation step
- This step can be run directly from the command line
- You need to specify the [absolute input path]({{< ref "need-to-know.md#use-absolute-paths" >}}) (`-i` parameter)
  - this is the directory that contains the `*_bracken.log` files, by default these should be in the `output/Taxonomy_profiling` directory
  - update this path if you have the `*_bracken.log` files in another location

```Tcsh
apptainer run --app mima-bracken-report $SANDBOX \
-i ~/mima_tutorial/output/Taxonomy_profiling
```

- The output is a tab separated text file
- By default, the output file `bracken-summary.tsv` will be in the same location as the input directory. You can override this using the `-o` parameter to specify the full path to the output file.
- Examine the output report using `head`
  - `column` formats the text file as columns like a table for readabilty

```Shell
head ~/mima_tutorial/output/Taxonomy_profiling/bracken-summary.tsv | column -t
```

- Your output should resemble something like below (only the first 9 columns are shown in the example below)
  - numbers might be different depending on the threhsold setting or tool version


```Text
sampleID     taxon_rank  log_status             threshold  num_taxon  num_tx_above_thres  num_tx_below_thres  total_reads  reads_above_thres
SRR17380209  phylum      ok-reads_unclassified  100        96         21                  75                  4784142      4449148
SRR17380209  class       ok-reads_unclassified  100        230        21                  209                 4784142      4438812
SRR17380209  order       ok-reads_unclassified  100        524        53                  471                 4784142      4404574
SRR17380209  family      ok-reads_unclassified  100        1087       103                 984                 4784142      4363888
SRR17380209  genus       ok-reads_unclassified  100        3260       228                 3032                4784142      4239221
SRR17380209  species     ok-reads_unclassified  100        8081       571                 7510                4784142      3795061
SRR17380232  phylum      ok-reads_unclassified  100        87         21                  66                  5551148      5216610
SRR17380232  class       ok-reads_unclassified  100        207        19                  188                 5551148      5201532
SRR17380232  order       ok-reads_unclassified  100        464        51                  413                 5551148      5165978
SRR17380232  family      ok-reads_unclassified  100        949        105                 844                 5551148      5126854
```

---

**Next:** if you haven't already, you can also [generate functional profiles]({{< ref "mima-apptainer-function" >}}) with your shotgun metagenomics data.
