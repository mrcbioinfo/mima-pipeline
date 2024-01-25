---
title: Biodiversity bar plots
description: generate bar plots to visualise the overall biodiversity in your samples
weight: 200
---


## Introduction

When starting a new metagenomics study, it is useful to visualise the microbial diversity present in the individual samples. You can also average the relative abundances of the most abundant species present and observe how they are distributed between groups in your study (e.g., *controls* versus *disease* or *placebo* versus *treatment*). 

For taxonomy features, the biodiversity bar plots can be generated for each taxonomic rank from Phylum to Species.


## Example data

The data set used for this tutorial is based on the *full* data set from the [data processing tutorials]({{< ref "data-processing" >}}) <a href="https://journals.asm.org/doi/10.1128/spectrum.01915-21" target="_blank">(Tourlousse, *et al.*, 2022)</a> that was pre-process with the same pipeline. There are 56 samples in total from the study, but after taxonomy profiling with Kraken2 and Bracken, 4 samples fell below the abundance threshold and therefore the final taxonomy abundance table has 52 samples.

This data set consists of two mock communities: (i) *DNA-mock* and (ii) *Cell-mock* processed in three different labs: A, B and C.

## Check list

For this set of tutorial, you need

  - System with `Apptainer` or `Singularity` installed (currently only tested on UNIX-based system)
  - [Install MIMA Pipeline Singularity container]({{< ref "installation" >}}) and check that you have
    - started an interactive PBS job
    - build the *sandbox* container
    - set the `SANDBOX` environment variable

## Step 1) Data preparation

  - Create a directory `vis-tutorial`
  - Change into this directory

```Shell
mkdir vis-tutorial
cd vis-tutorial
```

  - Download [taxonomy-feature-table.tar.gz](https://github.com/mrcbioinfo/mima-pipeline/raw/master/examples/taxonomy-feature-table.tar.gz)
    - *Note* only the processed feature tables are provided in this download; intermediate files from the [data processing pipeline]({{< ref "data-processing" >}}) are not provided.

```Shell
wget https://github.com/mrcbioinfo/mima-pipeline/raw/master/examples/taxonomy-feature-table.tar.gz
```

  - Extract the archived file

```Shell
tar xf taxonomy-feature-table.tar.gz
```

  - Check the directory structure matches
  - Only a subset of the files are shown below and `...` means "and others"

```Shell
tree .
```
```
~/vis-tutorial/
├── metadata.tsv
├── taxonomy-feature-table.tar.gz
└── Taxonomy_profiling
    └── featureTables
        ├── bracken_FT_class
        ├── bracken_FT_class_counts
        ├── bracken_FT_class_relAbund
        ├── ...
        ├── bracken_FT_genus
        ├── bracken_FT_genus_counts
        ├── bracken_FT_genus_relAbund
        ├── combine_bracken_class.log
        ├── ...
        ├── combine_bracken_genus.log
        └── generate_bracken_feature_table.py
```

{{% alert color=warning title="Note! Assumed working directory" %}}
This tutorial assumes the `vis-tutorial` directory is in your home directory as indicated by the `~` (tilde) sign. 
If you have put the files in another location then replace all occurrences of `~/vis-tutorial` with your location
{{% /alert %}}


### Data files explained

| Directory / File | Description |
|------------------|-------------|
| `metadata.tsv`   | is a tab-separated text file of the study metadata |
| `Taxonomy_profiling/featureTables` | <p>directory contains the [taxonomy feature tables]({{< ref "mima-apptainer-taxonomy.md#step-5-generate-taxonomy-abundance-table" >}}) using Kraken2 and Bracken. </p><p>There are feature tables for each taxonomy rank from Phylum to Species. As some analysis tools might require feature table input to be discrete counts while others might require relative abundances, two formats are provided with the suffixes:</p><ul><li>`*_count` files have discrete counts of features (row) per samples (columns)</li><li>`*_relAbund` files ahve the relative abundances of features (row) per samples (columns)</li></ul> |


- Confirm you have the following 3 files (if they don't exists, there will be an error message)

```Shell
ls metadata.tsv
ls Taxonomy_profiling/featureTables/bracken_FT_genus_counts
ls Taxonomy_profiling/featureTables/bracken_FT_genus_relAbund
```

## Step 2) Examine input files

### Examine metadata

- Examine the `metadata.csv` file:
  - `head` shows the first 10 rows
  - `column` formats the output into columns using tab as the separator (prettier view)

```Shell
head metadata.tsv | column -t -s $'\t'
```

```
Sample_ID    biosample     experiment   instrument           library.name                     sample.name                                         lab   type                 n_species
SRR17380113  SAMN20256237  SRX13554346  Illumina HiSeq 2500  metagenome_mockCell_labC_lib016  Cell mock community, blend of 18 bacterial species  labC  Cell mock community  18
SRR17380114  SAMN20256237  SRX13554345  Illumina HiSeq 2500  metagenome_mockCell_labC_lib015  Cell mock community, blend of 18 bacterial species  labC  Cell mock community  18
SRR17380115  SAMN20256237  SRX13554344  Illumina HiSeq 2500  metagenome_mockCell_labC_lib014  Cell mock community, blend of 18 bacterial species  labC  Cell mock community  18
SRR17380116  SAMN20256237  SRX13554343  Illumina HiSeq 2500  metagenome_mockCell_labC_lib013  Cell mock community, blend of 18 bacterial species  labC  Cell mock community  18
SRR17380117  SAMN20256237  SRX13554342  Illumina HiSeq 2500  metagenome_mockCell_labC_lib012  Cell mock community, blend of 18 bacterial species  labC  Cell mock community  18
SRR17380118  SAMN20256237  SRX13554341  Illumina HiSeq 2500  metagenome_mockCell_labC_lib011  Cell mock community, blend of 18 bacterial species  labC  Cell mock community  18
SRR17380119  SAMN20256237  SRX13554340  Illumina HiSeq 2500  metagenome_mockCell_labC_lib010  Cell mock community, blend of 18 bacterial species  labC  Cell mock community  18
SRR17380120  SAMN20256237  SRX13554339  Illumina HiSeq 2500  metagenome_mockCell_labC_lib009  Cell mock community, blend of 18 bacterial species  labC  Cell mock community  18
SRR17380121  SAMN20256237  SRX13554338  Illumina HiSeq 2500  metagenome_mockCell_labC_lib008  Cell mock community, blend of 18 bacterial species  labC  Cell mock community  18
```

- There should be 9 columns in the `metadata.tsv` file
  - row 1 is the header and the columns are pretty much self-explanatory
  - column 1 is the `Sample_ID`, which **must correspond** with the sample names in the feature tables
  - column 8 is the `lab` where the sample was processed, this will be our grouping factor in later steps

### Examine taxonomy feature table
 
- You can have a quick look at the taxonomy input table
  - this command will show the first 10 rows and 6 columns

```Shell
head Taxonomy_profiling/featureTables/bracken_FT_genus_relAbund | cut -f1-6 | column -t -s $'\t'
```

- For example, check the sample IDs (columns) are the same as the `metadata.tsv`
  
```
name                        SRR17380113  SRR17380114  SRR17380116  SRR17380117  SRR17380119
s__Escherichia flexneri     0.06616      0.06187      0.06694      0.06276      0.0674
s__Escherichia dysenteriae  0.0346       0.03221      0.03489      0.03252      0.03523
s__Escherichia coli_D       0.03155      0.02893      0.03205      0.02955      0.03223
s__Escherichia coli         0.0185       0.01747      0.01875      0.01766      0.01872
s__Escherichia coli_C       0.00975      0.00943      0.00986      0.00956      0.00994
s__Escherichia sp004211955  0.00458      0.00473      0.0046       0.00474      0.00463
s__Escherichia sp002965065  0.00375      0.00399      0.00381      0.00402      0.00379
s__Escherichia fergusonii   0.00398      0.00371      0.00405      0.00375      0.00405
s__Escherichia sp000208585  0.00321      0.0033       0.00326      0.00334      0.00328
```


## Step 3) Generate taxonomy bar plots

- Enter the following command
  - if `/vis-tutorial` is not in your home directory (`~`), change the `~/vis-tutorial/` to the [absolute path]({{< ref "need-to-know.md#use-absolute-paths" >}}) where you [downloaded the tutorial data](#step-1-data-preparation)
  - the backslash (`\`) at the end of each line informs the terminal that the command has not finished and there's more to come (we broke up the command for readability purposes to explain each parameter below)
  - *note* if you enter the command as one line, remove the backslashes
  

{{< highlight Tcsh "linenos=table,linenostart=1" >}}
apptainer run --app mima-vis-taxa $SANDBOX \
~/vis-tutorial/Taxonomy_profiling/featureTables/bracken_FT_genus_relAbund \
~/vis-tutorial/metadata.tsv \
lab:labA:labB:labC \
~/vis-tutorial/analysis \
LAB 8 10 6
{{< /highlight >}}

### Parameters explained

| Line | Parameters | Description |
|------|------------|-------------|
| 2 | `<feature_table.tsv>` | file path of the *relative abundance* feature table |
| 3 | `<metadata.tsv>` | file path of the study metadata table. Expect a tab separated text file with one row per sample with the first row being the header, and columns are the different metadata. |
| 4 | `<column_group:g1:g2>` | column name in `metadata.tsv` that holds the grouping information and the group levels. Format is `group_column:group1:group2:...`.<br/>**Note:** the values are case sensitive. <br/>In this tutorial, the `lab` column is used and has 3 groups: `labA`, `labB` and `labC`. |
| 5 | `<output_dir>` | output directory path where results are stored |
| 6-1* | `<output_prefix>` | prefix that will be used for output files.<br/>In the example, `LAB` is set as the prefix for output files. |
| 6-2* | `<top_N>` | the number of top taxa to colour in the stack bar plot, remaining detected taxa are grouped together as *'Other'*. |
| 6-3* | `<figure_width>` | output figure width (inches) |
| 6-4* | `<figure_height>` | output figure height (inches) |

*the last 4 parameters are all on line 6 separated by a space

{{% alert color=danger title="Note! Parameter order matters" %}}
The parameters must be in the same order described above.
{{% /alert %}}



## Step 4) Check output files

* You should have the following output files after running [Step 2](#step-2-examine-input-files)

```Shell
tree ~/vis-tutorial/analysis
```

```
analysis_v3/
├── LAB.select.average.table.txt
├── LAB.select.average.top_7_.barchart.pdf
├── LAB.select.average.top_7_seperategroup.barchart.pdf
├── LAB.select.average.top_7_seperategroup.table.txt
├── LAB.select.average.top_7_seperategroup.table.txt.7.R
├── LAB.select.average.top_7.table.txt
├── LAB.select.average.top_7.table.txt.7.R
├── LAB.select.meta.txt
├── LAB.select.table_top_7_seperategroup.txt
├── LAB.select.table_top_7_seperategroup.txt.7.R
├── LAB.select.table_top_7.txt
├── LAB.select.table_top_7.txt.7.R
├── LAB.select.table.txt
├── LAB.select.top_7_.barchart.pdf
└── LAB.select.top_7_seperategroup.barchart.pdf
```

- There are 15 output files
  - 4 PDF files - plots
  - 7 text files - data
  - 4 R scripts that generate plots

| Output files       | Description |
|--------------------|-------------|
| `*.average.top_*`  | mean group abundances for the overall top 7 taxa across the entire study |
| `*.average.top_*_separategroup` | mean group abundances for the top 7 taxa within each group |
| `*.meta.txt`       | study metadata specific for the plots |
| `*.table_top_*`    | sample abundances of the overall top 7 taxa across the entire study |
| `*.table_top_*_separategroup.*` | sample abundances of the top 7 taxa within each group |

### Example plots

{{< card header="**Relative abundances across all samples**" 
        subtitle="File: LAB.select.top_8_.barchart.pdf"
        footer="This plot shows the relative abundances for the top 8 genera for each sample, where the top 8 genera is across all samples in the study.">}}
  <img src="/images/tutorials/visualisation/LAB.select.top_8_.barchart.png" height="75%"/>
{{< /card >}}

&nbsp;

{{< card header="**Overall top 8 Genera**" 
          subtitle="File: LAB.select.average.top_8_.barchart.pdf"
          footer="This plot shows the mean relative abundances for the top 8 genera occurring across all samples in the study. All other detected taxa not in the top 7 are aggregated as *Others*. In this example, *Pseudomonas E* is the most abundant in samples processed by Lab-C.">}}
  <img src="/images/tutorials/visualisation/LAB.select.average.top_8_.barchart.png"/>
{{< /card >}}


{{% alert color=primary title="Plots from Phylum to Species" %}}
You can repeat [Step 3](#step-3-generate-taxonomy-bar-plots) and change the input file from Phylum to Species feature tables to generate bar plots for the different or desired taxonomic ranks.

Alternatively if you have other grouping variables in your study design, you can change `column_group` [parameter](#parameters-explained) in the command.
{{% /alert %}}